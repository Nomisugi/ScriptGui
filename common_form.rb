#シリアル送受信用のシリアル表示クラス(コールバック付き)
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

  #設定された行とマッチするまで文字列を取得する
  def get_string reg, proc
    @get_reg = reg
    @get_proc = proc
  end

  #コマンドを送信する
  def send str
    @comm.send str
  end

  #コールバックを登録する
  def set_callback reg, proc
    @regs << reg
    @procs << proc
    @get_line = self.text.count("\n")
  end

  #コールバックを削除する
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

  #コールバックを監視する (第2引数はライン変化の場合の処置)
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
  
  #一行加える
  def add_line line
#    line.delete!("\0")
    self.lines.add line
    callback_check line
  end

  #最後の一行を変更する
  def change_last_line line
    self.lines[self.text.count("\n")-1] = line
    callback_check line
  end

  #書き込みバッファに保存
  def write buf
    @lastlinebuf += buf
#    @lastlinebuf.delete!("\r")

    #受信バッファが中途半端な場合
    if !(buf =~ /\n/) && @lastlineflag
      change_last_line @lastlinebuf
    end

    #前の行が改行で終わっていない場合の処置
    if @lastlineflag && @lastlinebuf =~ /\n/
      change_last_line @lastlinebuf[0..@lastlinebuf.index(/\n/)].chop
      @lastlinebuf.slice! @lastlinebuf[0..@lastlinebuf.index(/\n/)]
      @lastlineflag = false
    end
    
    #受信バッファに改行が含まれていた場合
    if @lastlinebuf =~ /\n/
      while @lastlinebuf.index(/\n/) != nil
        add_line @lastlinebuf[0..@lastlinebuf.index(/\n/)].chop
        @lastlinebuf.slice! @lastlinebuf[0..@lastlinebuf.index(/\n/)]
      end
    elsif @lastlinebuf.size != 0 && @lastlineflag
      return
    end

    #受信バッファに余りあり
    if @lastlinebuf.size != 0
      add_line @lastlinebuf
      @lastlineflag = true
    end
  end

  attr_accessor :comm
end

#通信を設定表示するForm
class ComLogWindow < Phi::Form
  def initialize
    super
    self.caption = 'シリアル通信Log'
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

  #通信の初期設定を行うForm
  class InitialSettingDialog < Phi::Form
    def initialize
      super
      self.caption = 'COMポート設定'
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
      
      #ボタンが押されたときの処理
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
          Phi::message_dlg("ポートのオープンに失敗しました", 
                           Phi::MT_INFORMATION,[Phi::MB_OK], 0)
        end
        self.close
      end
    end
  end

  def line_add str
    @memo.wite str
  end

  #シリアルに文字列を送信する
  def send str
    @memo.send str
  end

  #初期設定を開く
  def open_port
    InitialSettingDialog::new
  end

  attr_accessor :memo
end

