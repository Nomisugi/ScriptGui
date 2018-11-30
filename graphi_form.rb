#�֐��̌Ăяo���֌W��\��
#
#    $Author: sugiura $
#    $Date: 2004/08/26 15:03:46 $
#    $Name:  $
#
#
require 'pngobject' #Graphviz�̋@�\���g�p

#Graphviz���g�p( WinGraphviz�̃C���X�g�[�����K�{ )
require 'win32ole'

class GraphForm < Phi::Form
  def initialize
    super
    self.caption = '�֐��̌Ăяo���֌W�}'
    self.visible = false
    Phi::Image::new self, :image
    image.align = Phi::AL_CLIENT

    begin
      @dot = WIN32OLE.new('WinGraphviz.DOT')
    rescue #��O��ʒm
      raise
    end
  end

  #�O���t�����t���b�V�����A�\�����X�V����
  def refresh script
    if self.visible == false
      return
    end
    func_flag = false
    func_recog_flag = false
    dot_str = ""
    func_word = ""
    f_num = 0
    before = ""
    after  = ""
    dot_str += "digraph G {\n"
    dot_str += "size = \"8,8\";\n"
    dot_str += "node [style=filled];\n"
    dot_str += '"[initialize]" -> "[recog0]"' + "\n"
    script_temp = script

    #�֐����ɕ]���A�����������F���̏ꍇ�͔F���P��̕\���𔺂�
    script.each_line do |line|

      #�F������֐��̏ꍇ
      if line =~ /^\[recog[0-9]+_func/
	func_flag = true
	r_flag = false
	count = 0
	before = line.split('_')[0] + ']'
	r_num = line.split('_')[0].delete('[recog').to_i
	f_num = line.split('func')[1].delete(']').to_i
	script_temp.each_line do |tline|
          #�F���P��i�[�̏ꍇ
	  if tline =~/^\[recog#{r_num.to_s}\]/ 
	    r_flag = true
	    next
	  end
	  if r_flag
            #�u|�v�ł̔F���P��̃X�L�b�v
            if tline =~ /^\|/
              next
            end

	    if count == f_num
	      func_word = tline.chop
  	      func_recog_flag = true;
	      count = 0
	      break;
	    end
	    count += 1
	  end
	  if tline =~ /^end/
	    r_flag = false
	  end
	end
      end
      
      #�֐��i�[�̏ꍇ
      if( line =~/^\[port_in/)||( line =~/^\[cycle/)||( line =~/^\[alarm/) ||(line =~/^\[initialize/)
	func_flag = true
	func_recog_flag = false;
	before = line.chop
      end
      if line =~ /^end/
	func_flag = false
      end

      #.dot�t�@�C�����֐����ɐ���
      if func_flag
	if( line =~/^PIS/ )||( line =~/^TBC/ )||( line =~/^PRG/ )||(line =~/^CYS/)||(line =~/^ALS/)||(line =~/^FNC/)
          if ( line =~/^TBC/ || line =~/^PRG/)&&( line=~/RETURN/ )
            next
          end
	  after = line.split(' ')[1].split(',')[0]
	  if( func_recog_flag )
	    dot_str += '"' + before + '"' + '->' + '"' + after + '"' +
	      " [label = \"" + func_word + "\"];\n"
	  else
	    dot_str += '"' + before + '"' + '->' + '"' + after + '"' + ";\n"
	  end
	end
      end
    end
    dot_str += "}\n"
    png = @dot.ToPNG dot_str
    png.Save('graphi.png')
    image.picture.load 'graphi.png'
    self.width = image.picture.width + 6
    self.height = image.picture.height + 25
  end
end

