#brief 命令の編集と追加を行うエディットBOX
#
#    $Author: sugiura $
#    $Date: 2004/08/26 15:03:46 $
#    $Name:  $
#
#

#コマンドエディター
class EditCommandBox <Phi::GroupBox
  def initialize sheet, fs, name
    super sheet, fs, name
    @sheet = sheet
    #コマンドラベルのLabel配列
    @command_labels = []

    #コンボボックスに命令を追加
    comlabel = Phi::Label::new( self, :comlab_edit, '' )
    comlab_edit.top = 23; comlab_edit.left = 70
    @combobox = Phi::ComboBox.new self
    @combobox.width = 60; @combobox.left = 4
    @combobox.top = 20; @combobox.height = 30
    $command_list.each do |item|
      @combobox.items.add item
    end

    #命令を変更した場合の処理
    @combobox.on_change = proc do
      $command_entrys.each do |obj|
	obj.hide
	obj.text = ''
      end
      @command_labels.each do |obj|
	obj.caption = ''
      end
      text = $command[@combobox.text]
      if text != nil
	@sheet.message_board.clear
        @sheet.message_board.write text[0]

	for i in 0..text[1]
	  $command_entrys[i].hide if $command_entry != nil
	  @command_labels[i].caption = '' if $command_label != nil
	  text[3+2*i].call(self)
	  @command_labels[i].caption = text[2 + 2*i]
	  $command_entrys[i].top = 65 + 40*i;
	  $command_entrys[i].left = 5;
	  $command_entrys[i].width = 200
	end
      end
    end

    for i in 0..5
      @command_labels << Label::new(self, :recog_label, '')
      @command_labels[i].top = 50 + 40*i
      @command_labels[i].left = 5
      @command_labels[i].width = 200
    end
    @combobox.hide

    #追加ボタン
    Phi::Button::new( self, :add_button, '' )
    add_button.top = 20; add_button.left = 90; add_button.height = 21
    add_button.anchors =[AK_TOP,AK_RIGHT]
    add_button.hide
    add_button.on_click = proc do
      @sheet.add_command edit_get
    end

    #編集ボタン
    Phi::Button::new( self, :edit_button, '' )
    edit_button.top = 20; edit_button.left = 100; edit_button.height = 21
    edit_button.anchors =[AK_TOP,AK_RIGHT]
    edit_button.hide
    edit_button.on_click = proc do
      @sheet.edit_command edit_get
      del_sheet_check
    end

    def edit_get
      inst_text = @combobox.text + ' ' 
      if @combobox.text.length == 0
	Phi::message_dlg('命令が指定されていません', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
	break
      end
      text = $command[@combobox.text]
      for i in 0..text[1]
        if $command_entrys[i].text != ""
          inst_text += $command_entrys[i].text + ','#空白削除で入れる
        end
      end
      return inst_text.chop
    end

  end

  #<命令の編集実行>
  def edit_command text
    @combobox.show
    comlab_edit.caption = '命令編集'
    add_button.hide
    edit_button.caption = '編集'
    edit_button.show
    arg_list = nil

    command = (text.split(' '))[0]
    text = text[4,text.size-4]
    if text != nil
      arg_list = text.split(',')
    end
    @combobox.text = command

    $command_entrys.each do |obj|
      obj.hide
      obj.text = ''
    end
    @command_labels.each do |obj|
      obj.caption = ''
    end
    text = $command[@combobox.text]
    @sheet.message_board.clear
    @sheet.message_board.write text[0]

    for i in 0..text[1]
      $command_entrys[i].hide if $command_entry != nil
      @command_labels[i].caption = '' if $command_label != nil
      text[3+2*i].call(self)
      @command_labels[i].caption = text[2 + 2*i]
      $command_entrys[i].top = 65 + 40*i;
      $command_entrys[i].left = 5;
      $command_entrys[i].width = 200
      if arg_list != nil
        if arg_list[i] != nil
          $command_entrys[i].text = arg_list[i]
        end
      end
    end

  end

  #<コマンド追加の際の処理>
  def add_command sheet_number, command_number
    @combobox.show
    @combobox.text = ''
    comlab_edit.caption = '追加命令'
    add_button.caption = '追加'
    edit_button.hide
    add_button.show

    $command_entrys.each do |obj|
      obj.hide
      obj.text = ''
    end
    @command_labels.each do |obj|
      obj.caption = ''
    end
  end

  #<他のテーブルが選択されたときに必要ないものは隠す
  def all_hide
    comlab_edit.caption = ''
    edit_button.hide
    add_button.hide
    @combobox.hide
    $command_entrys.each do |obj|
      obj.hide
      obj.text = ''
    end
    @command_labels.each do |obj|
      obj.caption = ''
    end
  end
end
