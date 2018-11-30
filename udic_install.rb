#ユーザ辞書をインストールするモジュール
#
#    $Author: sugiura $
#    $Date: 2004/09/06 11:06:13 $
#    $Name:  $
#
#逐次呼び出し処理の地獄になってしまっている
#

USER_DICTIONARY_MAX = 512

class UserDictionarySetting < Phi::Form

  class UserVocable < Phi::GroupBox
    def initialize pc, fs, name
      super pc, fs, name
      self.height = 40
      Phi::Edit.new self, :midashi, ''
      Phi::Edit.new self, :yomi, ''
      Phi::ComboBox.new self, :accent

      midashi.width = 170
      midashi.align = Phi::AL_LEFT
      yomi.width = 170
      yomi.align = Phi::AL_LEFT
      accent.align = Phi::AL_CLIENT
      accent.width = 30
      accent.on_enter = proc do
        count = yomi.text.size / 2
        accent.items.clear
        for i in 0..count
          accent.items.add i.to_s
        end
      end
    end

    def check
      reg1 = Regexp.new('[あ-ん,ー,ぁ-ょ,亜-熙]+')
      midashi.text =~ reg1
      if $& != midashi.text && midashi.text.size != 0
        message = midashi.text + ':不正な見出し文が登録されています(全角文字列のみ)'
        Phi::message_dlg( message,
                          Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        return false
      end
      if midashi.text.size > 20
        message = midashi.text + ':見出しは全角で10文字までです' 
        Phi::message_dlg( message,
                         Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        return false
      end

      reg2 = Regexp.new('[あ-ん,ー,ぁ-ょ]+')
      yomi.text =~ reg2
      if $& != yomi.text && yomi.text.size != 0
        message = yomi.text + ':不正な読み文が登録されています(ひらがなのみ)'
        Phi::message_dlg( message,
                         Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        return false
      end
      if yomi.text.size > 40
        message = yomi.text + ':読みはひらがなで20文字までです'
        Phi::message_dlg( message,
                         Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        return false
      end
      return true
    end

    def save ps
      ps[self.caption] = midashi.text + ',' + yomi.text + ',' + accent.text
    end

    def load ps
      data = ps[self.caption] if ps.root?( self.caption )
      if data != nil
        array = data.split( /,/ )
        midashi.text = array[0] if array[0] != nil
        yomi.text = array[1] if array[1] != nil
        accent.text = array[2] if array[2] != nil
      end
    end

    def clear
      midashi.text = ''; yomi.text = ''; accent.text = ''
    end

    attr_accessor :midashi, :yomi, :accent
  end

  def initialize
    super
    self.caption = 'ユーザ辞書のインストール'
    self.height = 500; self.width = 400
    @words = []
    @send_flag = false
    @now_dic_string = ""
    @check_flag = true

    new_menu(self,:menu,[
               @menu_send = new_item('ターゲットに追加','',:nil),
               @menu_read = new_item('ターゲット設定読込み','',:nil),
               @menu_clear = new_item('ターゲット辞書初期化','',:nil)
             ])

    count = USER_DICTIONARY_MAX-1
    for i in 0..count
      name = "word" + i.to_s
      @words[i] = UserVocable.new self, nil, name
    end
    count.step(0, -1) do |i|
      @words[i].align = Phi::AL_TOP
    end

    @reg = /^udic>>$/
    @count = 0
    @menu_send.on_click = proc do
      @words.each do |obj|
        if obj.check == false
          @check_flag = false
          @send_flag = false
          break
        end
        @check_flag = true
      end

      if @check_flag #エラーがある場合は転送しない
        if $main.target? == false
          Phi::message_dlg('ターゲットに接続されていません',
                           Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
          break
        end
        if @send_flag
          Phi::message_dlg('ユーザ辞書の転送中です',
                           Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
          break
        end
        if $main.target_condition? != "START"
          Phi::message_dlg('現在ボードの状態はビジーです',
                           Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
          break
        end

        #ユーザ辞書をインストールする
        if $main.target?
          udic_send
        end
      end
    end

    @menu_read.on_click = proc do
      if $main.target? == false
	Phi::message_dlg('ターゲットに接続されていません',
			 Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        break
      end
      if @send_flag
	Phi::message_dlg('ユーザ辞書の転送中です',
			 Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        break
      end
      if $main.target_condition? != "START"
	Phi::message_dlg('現在ボードの状態はビジーです',
			 Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
        break
      end

      if $main.target?
        read_proc = Proc::new {
          @now_dic_string.each_line do |line|
            if line =~ /^No/
              array = line.split /\s/
              array[0].delete!("No.")
              num = array[0].delete!(":").to_i
              @words[num].midashi.text = array[2] if array[2] != nil
              @words[num].yomi.text    = array[5] if array[5] != nil
              @words[num].accent.text  = array[8].chomp if array[8] != nil
            end
          end
        }
        udic_get read_proc
      end
    end

    @menu_clear.on_click = proc do
      udic_delete
    end
  end

  #ユーザ辞書を送信する
  def udic_send
    @send_flag = true
    write_proc = Proc::new {|obj|
      if @count >= USER_DICTIONARY_MAX-1
        @count = 0
        $log.memo.del_callback @reg, write_proc
        $log.memo.send "exit\n"
        @send_flag = false
      else
        midashi = @words[@count].midashi.text
        yomi    = @words[@count].yomi.text
        accent  = @words[@count].accent.text

        #設定されていない物は無視する
        if midashi.size == 0 || yomi.size == 0 || accent.size == 0
          @count += 1
          $log.memo.send "next\n"
        else
          $log.memo.send "inst\n"
          $log.memo.send midashi + "\n"
          $log.memo.send yomi + "\n"
          $log.memo.send accent + "\n"
          @count += 1
        end
      end
    }
    $log.memo.set_callback @reg, write_proc
    $log.memo.send "udic\n"
  end

  #現在のユーザ辞書情報を取得する
  def udic_get proc
    read_proc2 = Proc::new {|obj|
      @now_dic_string = obj
      $log.memo.send "exit\n"
      proc.call
    }
    read_proc = Proc::new {|obj|
      $log.memo.del_callback @reg, read_proc
      $log.memo.get_string @reg, read_proc2
      $log.memo.send "disp\n"      
    }
    $log.memo.set_callback @reg, read_proc
    $log.memo.send "udic\n"
  end

  #ユーザ辞書を削除する
  def udic_delete
    delete_list = []  #削除する番号を配列で保存
    del_proc = Proc::new {
      @now_dic_string.each do |line|
        if line =~ /^No/
          array = line.split /\s/
          array[0].delete!("No.")
          array[0].delete!(":")
          delete_list << array[0]
        end
      end

      $log.memo.send "udic\n"
      delete_list.each do |n|
        $log.memo.send "dele\n"
        $log.memo.send n + "\n"
      end
      $log.memo.send "exit\n"
    }
    udic_get del_proc         #ユーザ辞書情報を保存
  end

  def save ps
    @words.each do |w|
      w.save ps
    end
  end

  def load ps
    @words.each do |w|
      w.load ps
    end
  end

  def clear
    @words.each do |w|
      w.clear
    end
  end
end
