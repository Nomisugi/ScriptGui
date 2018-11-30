#WAVファイルをインストールするモジュール
#
#    $Author: sugiura $
#    $Date: 2004/09/02 15:16:21 $
#    $Name:  $
#
#

class WavFileSetting < Phi::Form
  class WavBox < Phi::GroupBox
    def initialize pc, fs, name
      super pc, fs, name
      Phi::Edit.new self, :edit, ''
      Phi::Button.new self, :button, '参照'
      edit.align = Phi::AL_CLIENT
      edit.read_only = true
      button.align = Phi::AL_RIGHT
      self.height = 52; self.width = 400

      Phi::ProgressBar.new self, :progbar
      progbar.align = Phi::AL_BOTTOM

      button.on_click = proc do
        dlg = Phi::OpenDialog.new
        dlg.filter = 'WavFile(*.wav)'
        if dlg.execute
          edit.text = dlg.file_name
          if ( wav_check dlg.file_name ) == false
            Phi::message_dlg('WAVファイルではないか、対応していないWAVファイルです',
                             Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
            edit.text = ""
          end
        end
      end

      #対応されているWAVファイルかチェックを行う(ファイルサイズを返す)
      def wav_check file_name
        data = []
        count = 0
        f = File::open file_name, "r+b"
        f.each_byte do |c|
          data << c
          if count > 100
            break;
          end
          count += 1
        end
        f.close
        if data[0..3].pack("CCCC") != "RIFF"
          return false
        end
        if data[36..39].pack("CCCC") != "data"
          return false
        end
        return  true
      end
    end
    
    def load ps
      edit.text = ps[self.caption] if ps.root?(self.caption)
    end
      
    def save ps
      ps[self.caption] = edit.text
    end
    
    def clear
      edit.text = ""
    end
  end
  
  def initialize
    super
    self.caption = 'WAVファイルのインストール'
    self.height = 270; self.width = 400
    @wav = []
    @send_flag = false
    
    for i in 0..3
      name = "wav" + i.to_s
      @wav[i] = WavBox.new self, nil, name
    end

    @wav[3].align = Phi::AL_TOP
    @wav[2].align = Phi::AL_TOP
    @wav[1].align = Phi::AL_TOP
    @wav[0].align = Phi::AL_TOP
    
    new_menu(self,:menu,[@menu_send = new_item('ターゲットに転送','',:menu_file1)])
    @count = 0
    @reg = /^wav>>$/
    @proc = Proc::new {|obj|
      file_send
    }

    @menu_send.on_click = proc do
      if $main.target? == false
	Phi::message_dlg('ターゲットに接続されていません',
			 Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        return
      end
      if @send_flag
	Phi::message_dlg('WAVファイルの転送中です',
			 Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        return
      end
      if $main.target_condition? != "START"
	Phi::message_dlg('現在ボードの状態はビジーです',
			 Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        break
      end

      @send_flag = true
      $log.memo.set_callback @reg, @proc
      if $main.target?
        $log.memo.send "wav\n"
      end
    end

    self.on_close = proc{
      if @send_flag
	Phi::message_dlg('WAVファイルの転送中です',
			 Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      end
    }
  end

  def file_send_end
    @count = 0
    $log.memo.del_callback @reg, @proc
    $log.memo.send "exit\n"
    @send_flag = false
  end

  #ファイルを送信する
  def file_send
    send_count = 0
    if @count >= 3
      file_send_end
      return
    end

    #設定されていない場所は抜かす
    if @wav[@count].edit.text == ""
      @count = @count+1
      $log.memo.send "next\n"
      return
    end

    file = @wav[@count].edit.text
    size = File::size file
    @wav[@count].progbar.max = size
    $log.memo.send "inst\n"

    $log.memo.send @count.to_s + "\n"
    name = file.split("\/")
    name = name[name.size-1].to_s + "\n"
    $log.memo.send name
    f = File::open file, "r+b"

    f.each_byte do |c|
      $log.memo.comm.send_char c
      @wav[@count].progbar.position = send_count
      send_count += 1
    end
    @count = @count+1
  end

  def load ps
    @wav.each do |w|
      w.load ps
    end
  end

  def save ps
    @wav.each do |w|
      w.save ps
    end
  end
  
  def clear
    @wav.each do |w|
      w.clear
    end
  end
end
