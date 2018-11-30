#音声認識合成エンジン、GUIスクリプト設定ツール
#
#    \file  :action_sheet.rb
#    \brief アクションシートClass
#
#    $Author: sugiura $
#    $Date: 2004/09/06 11:06:13 $
#    $Name:  $
#
#class ActionSheet < Phi::TabSheet

#ヘルプ表示用メッセージボード
class MessageBoard < Phi::GroupBox
  def initialize pc, fs, name
    super pc, fs, name
    Phi::Memo.new( self, :board, '')
    board.align = AL_CLIENT
    board.color = 0xBFBFBF
    board.scroll_bars = SS_VERTICAL
  end

  def clear
    board.clear
  end
  
  def write text
    text.each_line do |line|
      board.lines.text += line
    end
  end
end


#関数の編集用シートタブ
class ActionSheet < RGUI::TabSheet
  def initialize pc, fs, name
    super pc, fs, name
    #シートの参照関数数
    @ref_count = 0

    @funcbox = GroupBox::new self, :funcbox
    @funcbox.align = AL_CLIENT
    
    #関数リストBOX
    @flbox = Phi::ListBox::new(@funcbox, :flbox, '')
    @flbox.extended_select = true
    @flbox_label = Label::new(@funcbox, :recog_label, '')
    @flbox.align = AL_LEFT; @flbox.width = 200

    #コマンド実行リストのListBox配列
    @comlboxs = []
    @comlabel = Label::new @funcbox, nil, ''

    #ヘルプメッセージ関連のグループ
    MessageBoard.new self, :message_board, '命令の詳細を表示します'
    message_board.align = AL_BOTTOM

    #コマンド編集関連のグループ
    EditCommandBox.new self, :edit_box, '命令を編集します'
    edit_box.align = AL_RIGHT; edit_box.width = 220

    #flboxリスト選択で命令追加モードへ
    @flbox.on_click = proc do
      @comlboxs.each do |obj|
	obj.hide
      end
      edit_box.all_hide
      @comlboxs[@flbox.item_index].show
      @comlboxs[@flbox.item_index].hint = "右クリックで 削除\n命令を選択し↑↓で編集"
      @comlboxs[@flbox.item_index].show_hint = true

      @comlabel.caption = "「" + @flbox.items[@flbox.item_index] + "」に対する動作"
      @comlabel.left = 200; #comlabel.width = comlabel.caption.size * 6

      #命令リストのクリックで編集
      @comlboxs[@flbox.item_index].on_click = proc do
	edit_box.edit_command @comlboxs[@flbox.item_index].items[@comlboxs[@flbox.item_index].item_index]
      end
    end

    #命令変更用ポップアップ
    Phi.new_popup_menu self, :command_menu, [
      @menu_com_add = Phi.new_item('&Add Command', '', :mi_add),
      @menu_com_del = Phi.new_item('&Del Command', '', :mi_del),
    ]
    @menu_com_add.on_click = proc do
      edit_box.add_command @flbox.item_index, @comlboxs[@flbox.item_index].item_index
    end
    
    @menu_com_del.on_click = proc do
      if @comlboxs[@flbox.item_index].item_index == -1
        return
      end

      if @comlboxs[@flbox.item_index] != nil
        edit_box.all_hide
        @comlboxs[@flbox.item_index].del_item @comlboxs[@flbox.item_index].item_index
        del_sheet_check
      end
    end

    #右クリックで開くメニュー(現状範囲での場合分けが必要な仕組み)
    def self.on_context_popup( handled, point )
      self.screen_to_client point
      #命令リストBOX用ポップアップ
      if @comlboxs[0] != nil
      if (point.x > @comlboxs[0].left && point.x < @comlboxs[0].left+@comlboxs[0].width )
	if( point.y > @comlboxs[0].top &&
                      point.y < (@comlboxs[0].height + @comlboxs[0].top) )
	  if @comlboxs[@flbox.item_index] != nil
	    command_menu.popup( point.x + main_sheet_left + 65 ,
                                point.y + main_sheet_top + 65 )
	  end
	end
      end
      end

      #関数リストBOX用ポップアップ(RecogWord用)
     if (point.x > @flbox.left && point.x < @flbox.left+@flbox.width)
	if( point.y > @flbox.top && point.y < @flbox.height + @flbox.top )
	  if popup_menu != nil
	    popup_menu.popup( point.x + main_sheet_left + 70 ,
                              point.y + main_sheet_top + 65 ) 
	  end
	end
      end
    end
  end

  #<関数を関数リストBOX入れる>
  def add_func text
    if @flbox.items.index_of( text ) == -1
      @flbox.items.add text
      #命令を入れるリストボックスの作成
      comlbox = CommandList::new @funcbox
      comlbox.set_sheet self
      comlbox.width = 195;
      comlbox.top = 12; comlbox.left = 202; comlbox.height = 290
      comlbox.align = AL_CLIENT
      @comlboxs << comlbox
      #命令リストのクリックで編集(追加した段階で編集は可能となる)
      @comlboxs[@flbox.item_index].on_click = proc do
        edit_box.edit_command @comlboxs[@flbox.item_index].items[@comlboxs[@flbox.item_index].item_index]
      end
    end

    #命令選択
    @comlboxs[@flbox.item_index].on_key_down = proc do |obj, key, shift|
      select_box = @comlboxs[@flbox.item_index]
      select_num = select_box.item_index
      if select_num < 0
	return 
      end
      case key
      when 40 #下ボタンダウン
	if select_num < (select_box.items.count-1)
	  select_box.items.move( select_num, select_num+1 )
	  select_box.item_index = select_num+1
	end
      when 38 #上ボタンダウン
	if select_num > 0
	  select_box.items.move( select_num, select_num-1 )
	  select_box.item_index = select_num-1
	end
      else
      end
    end
  end

  #<関数を削除する>
  def del_func text
    number = @flbox.items.index_of text
    if number == -1
      return
    end
    if @comlboxs[number].ref? == false
      @comlboxs[number].del_item_all
      @flbox.items[number] = "-delete-"
    end
  end

  #<関数の削除の後処理>
  #全ての関数を検索し"-delete-"を全て消す
  def del_func_terminator
    point = 0
    @comlboxs.each do |com|
      com.del_item_terminator
    end
    while point != -1
      point = @flbox.items.index_of("-delete-")
      @flbox.items.delete point
    end
    if ref? == false
      self.tab_visible = false
    end
  end

  def sheet_name name
    return name.delete("0-9")
  end

  def add_command text
    @comlboxs[@flbox.item_index].add_item text
  end

  def edit_command text
    @comlboxs[@flbox.item_index].edit_item text
  end

  #現在編集中の関数名を取得(自己呼び出しの抑制のため)
  def edit_func
    if @flbox.item_index != -1
      return @flbox.items[@flbox.item_index]
    end
  end

  #<シート参照数チェック>
  #シートの参照数が0の場合falseを返す
  def ref?
#    print self.caption + @ref_count.to_s + "参照している\n" #debug
    if @ref_count > 0
      return true
    else
      return false
    end
  end

  #シートを参照しない
  def ref_del
    @ref_count -= 1
  end

  #シートを参照する
  def ref_set
    @ref_count += 1
  end

  #<シートの追加をチェック>
  def sheet_add_check name
    if name.delete("0-9") == self.caption
      ref_set #参照カウントを繰り上げる
      add_func name
      num = @flbox.items.index_of name
      @comlboxs[num].ref_set
      self.tab_visible = true
    end
  end

  #<シートの削除をチェック>
  def sheet_del_check name
    if name.delete("0-9") == self.caption
      ref_del
      num = @flbox.items.index_of name
      @comlboxs[num].ref_del
      if @comlboxs[num].ref? == false
        message = "関数" + name + "を完全に削除しますか?"
        result = Phi::message_dlg( message, Phi::MT_CONFIRMATION, [Phi::MB_YES, Phi::MB_NO], 0)
        case result
        when Phi::MR_YES
        when Phi::MR_NO
          return
        end
      end
      del_func name
#      @comlboxs.compact!
    end
  end

  #<シートの情報をスクリプトとして取得>
  def get_script
    i = 0
    text = ""
    @flbox.items.each do |obj|
      text += obj + "\n"
      if @comlboxs[i] != nil
        @comlboxs[i].items.each do |item|
          text += item + "\n"
        end
      end
      i += 1
      text += "end\n"
    end
    return text
  end


  #<PSstorにて保存>
  def save ps
    ps[self.caption] = @flbox.items.text
    i = 0
    @comlboxs.each do |obj|
      save_text = self.caption + i.to_s
      ps[save_text] = obj.items.text
      i += 1
    end
  end

  #<PSstorにてLoad>
  def load ps
    i = 0
    text = ""
    load_text = self.caption
    items = ps[load_text] if ps.root?(load_text)

    if items != nil
      items.each do |item|
        add_func item.chop #ファンクションの追加
        load_text = self.caption + i.to_s
        @comlboxs[i].items.text = ps[load_text].chop if ps.root?(load_text)
        @comlboxs[i].items.each do |item|
          @comlboxs[i].add_extsheet_func item
        end
        i += 1
      end
    end

    #一番最初のコマンドリストを表示しておく
    @flbox.item_index = 0
    if @comlboxs[0] != nil
      @comlboxs.each do |obj|
        obj.hide
      end
      @comlboxs[0].item_index = 0
      @comlboxs[0].show
    end
  end

  #<設定、参照を全て初期化する>
  def clear
    edit_box.all_hide
    i = 0
    @flbox.items.each do
      @comlboxs[i].clear
      i += 1
    end
    @ref_count = 0
    @flbox.items.clear
  end
end

# FNC [func_user]用　シート
class FncSheet < ActionSheet
  def initialize pc, fs, name
    super pc, fs, name
  end

  def sheet_add_check name
    if( name =~ /\[func/ )&&(self.caption == "[func_user]")
      ref_set #参照カウントを繰り上げる
      add_func name
      self.tab_visible = true
    end
  end

  def sheet_del_check name
    if( name =~ /\[func/ )&&(self.caption == "[func_user]")
      ref_del
      num = @flbox.items.index_of name
      @comlboxs[num].ref_del
      if @comlboxs[num].ref? == false
        message = "関数" + name + "を完全に削除しますか?"
        result = Phi::message_dlg( message, Phi::MT_CONFIRMATION, [Phi::MB_YES, Phi::MB_NO], 0)
        case result
        when Phi::MR_YES
        when Phi::MR_NO
          return
        end
      end

      del_func name
      @comlboxs.compact!
    end
  end
end
