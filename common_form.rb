#�V���A������M�p�̃V���A���\���N���X(�R�[���o�b�N�t��)
#
#    $Author: sugiura $
#    $Date: 2004/09/02 15:16:21 $
#    $Name:  $
#
#
require 'comm'

class CommMemo < Phi::Memo
  def initialize pc
    super pc
    @comm = CommX::new
    @comm.port_no = 1
    @comm.bit_rate = 115200
#    @comm.open
    @lastlinebuf = ""
    @lastlineflag = false
    @regs = []
    @procs = []
    @get_reg = nil
    @get_proc = nil
    @get_script = ""

    @comm.on_receive = proc do |sender, size|
      buf = ' ' * size
      @comm.receive(buf)
      write buf
    end
  end

  #�ݒ肳�ꂽ�s�ƃ}�b�`����܂ŕ�������擾����
  def get_string reg, proc
    @get_reg = reg
    @get_proc = proc
  end

  #�R�}���h�𑗐M����
  def send str
    @comm.send str
  end

  #�R�[���o�b�N��o�^����
  def set_callback reg, proc
    @regs << reg
    @procs << proc
    @get_line = self.text.count("\n")
  end

  #�R�[���o�b�N���폜����
  def del_callback reg, proc
    count = 0
    @regs.each do |obj|
      if obj == reg
        if @procs[count] == proc
          @regs[count] = nil
          @procs[count] = nil
          @regs.compact!
          @procs.compact!
          break;
        end
      end
      count += 1
    end
  end

  #�R�[���o�b�N���Ď����� (��2�����̓��C���ω��̏ꍇ�̏��u)
  def callback_check line
    if line =~ @get_reg
      end_line = self.text.count("\n")-1
      for i in @get_line..end_line
        @get_script += self.lines[i] + "\n"
      end

      @get_reg = nil
      @get_proc.call @get_script
      @get_script = ""
    end
    
    for i in 0..@regs.size-1
      if line =~ @regs[i]
        @procs[i].call line
      end
    end
  end
  
  #��s������
  def add_line line
#    line.delete!("\0")
    self.lines.add line
    callback_check line
  end

  #�Ō�̈�s��ύX����
  def change_last_line line
    self.lines[self.text.count("\n")-1] = line
    callback_check line
  end

  #�������݃o�b�t�@�ɕۑ�
  def write buf
    @lastlinebuf += buf
#    @lastlinebuf.delete!("\r")

    #��M�o�b�t�@�����r���[�ȏꍇ
    if !(buf =~ /\n/) && @lastlineflag
      change_last_line @lastlinebuf
    end

    #�O�̍s�����s�ŏI����Ă��Ȃ��ꍇ�̏��u
    if @lastlineflag && @lastlinebuf =~ /\n/
      change_last_line @lastlinebuf[0..@lastlinebuf.index(/\n/)].chop
      @lastlinebuf.slice! @lastlinebuf[0..@lastlinebuf.index(/\n/)]
      @lastlineflag = false
    end
    
    #��M�o�b�t�@�ɉ��s���܂܂�Ă����ꍇ
    if @lastlinebuf =~ /\n/
      while @lastlinebuf.index(/\n/) != nil
        add_line @lastlinebuf[0..@lastlinebuf.index(/\n/)].chop
        @lastlinebuf.slice! @lastlinebuf[0..@lastlinebuf.index(/\n/)]
      end
    elsif @lastlinebuf.size != 0 && @lastlineflag
      return
    end

    #��M�o�b�t�@�ɗ]�肠��
    if @lastlinebuf.size != 0
      add_line @lastlinebuf
      @lastlineflag = true
    end
  end

  attr_accessor :comm
end

#�ʐM��ݒ�\������Form
class ComLogWindow < Phi::Form
  def initialize
    super
    self.caption = '�V���A���ʐMLog'
    self.width = 300
    self.height = 500
    self.top = 0
    self.left = 640
    self.visible = false
    @memo = CommMemo::new self
    @memo.align = Phi::AL_CLIENT
    @memo.scroll_bars = SS_VERTICAL
    @memo.word_wrap = false
  end

  #�ʐM�̏����ݒ���s��Form
  class InitialSettingDialog < Phi::Form
    def initialize
      super
      self.caption = 'COM�|�[�g�ݒ�'
      self.width = 200
      self.height = 100
      @combobox = Phi::ComboBox.new self
      @combobox.width = 60
      @button = Phi::Button.new(self, :button1, 'OK')
      @radio115200 = Phi::RadioButton.new(self, :button1, '115200')
      @radio9600 = Phi::RadioButton.new(self, :button1, '9600')
      @radio115200.align = AL_BOTTOM
      @radio115200.checked = true
      @radio9600.align = AL_BOTTOM
      @combobox.text = 'COM1'
      @button.align = Phi::AL_RIGHT

      for i in 1..6
        @combobox.items.add 'COM' + i.to_s
      end
      self.show
      
      #�{�^���������ꂽ�Ƃ��̏���
      @button.on_click = proc do
        com_number = @combobox.text.delete('COM').to_i
        if @radio115200.checked
          baud_rate = 115200
        else
          baud_rate = 9600
        end
        $log.memo.comm.port_no = com_number
        $log.memo.comm.bit_rate = baud_rate
        begin
          $log.memo.comm.open
        rescue
          Phi::message_dlg("�|�[�g�̃I�[�v���Ɏ��s���܂���", 
                           Phi::MT_INFORMATION,[Phi::MB_OK], 0)
        end
        self.close
      end
    end
  end

  def line_add str
    @memo.wite str
  end

  #�V���A���ɕ�����𑗐M����
  def send str
    @memo.send str
  end

  #�����ݒ���J��
  def open_port
    InitialSettingDialog::new
  end

  attr_accessor :memo
end

