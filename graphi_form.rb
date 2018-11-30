#関数の呼び出し関係を表示
#
#    $Author: sugiura $
#    $Date: 2004/08/26 15:03:46 $
#    $Name:  $
#
#
require 'pngobject' #Graphvizの機能を使用

#Graphvizを使用( WinGraphvizのインストールが必須 )
require 'win32ole'

class GraphForm < Phi::Form
  def initialize
    super
    self.caption = '関数の呼び出し関係図'
    self.visible = false
    Phi::Image::new self, :image
    image.align = Phi::AL_CLIENT

    begin
      @dot = WIN32OLE.new('WinGraphviz.DOT')
    rescue #例外を通知
      raise
    end
  end

  #グラフをリフレッシュし、表示を更新する
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

    #関数毎に評価、ただし音声認識の場合は認識単語の表示を伴う
    script.each_line do |line|

      #認識動作関数の場合
      if line =~ /^\[recog[0-9]+_func/
	func_flag = true
	r_flag = false
	count = 0
	before = line.split('_')[0] + ']'
	r_num = line.split('_')[0].delete('[recog').to_i
	f_num = line.split('func')[1].delete(']').to_i
	script_temp.each_line do |tline|
          #認識単語格納の場合
	  if tline =~/^\[recog#{r_num.to_s}\]/ 
	    r_flag = true
	    next
	  end
	  if r_flag
            #「|」での認識単語のスキップ
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
      
      #関数格納の場合
      if( line =~/^\[port_in/)||( line =~/^\[cycle/)||( line =~/^\[alarm/) ||(line =~/^\[initialize/)
	func_flag = true
	func_recog_flag = false;
	before = line.chop
      end
      if line =~ /^end/
	func_flag = false
      end

      #.dotファイルを関数毎に生成
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

