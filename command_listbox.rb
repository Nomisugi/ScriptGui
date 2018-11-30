
class CommandList < Phi::ListBox
  def initialize box
    super box
    @sheet
    @ref_count = 0
  end

  def set_sheet sheet
    @sheet = sheet
  end

  def clear
    @ref_count = 0
    self.items.clear
  end

  def del_item_terminator
    point = 0
    while point != -1
      point = self.items.index_of("-delete-")
      self.items.delete point
    end
#    self.compact!
  end

  def ref_set
    @ref_count += 1
#    print "参照" + @ref_count.to_s + "\n"
  end

  def ref_del
    @ref_count -= 1
#    print "解除" + @ref_count.to_s + "\n"
  end

  def ref?
    if @ref_count > 0
      return true
    else
      return false
    end
  end

  #<関数内の全命令を削除>
  # @param commands:関数のリストオブジェクト(再帰呼び出し可能とする)
  def del_item_all
    for i in 0..self.items.count-1
      del_item i
    end
  end

  #<命令の削除>
  # @param func_number:関数の番号
  # @param command_number:削除する命令の番号
  def del_item command_number
    name = self.items[command_number]
    del_extsheet_func name
    self.items[command_number] = "-delete-"
  end

  #<命令の追加>
  # @param inst_text:追加する命令の文字列
  def add_item inst_text
    if inst_text.size > 64
      Phi::message_dlg('一行に書ける文字列は64文字以内です', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      return
    end
    self.items.add inst_text
    add_extsheet_func inst_text  #シートへの挿入が必要な命令の場合
  end

  #<命令の編集>
  # @param inst_text:追加(上書き)する命令の文字列
  def edit_item inst_text
    if inst_text.size > 64
      Phi::message_dlg('一行に書ける文字列は64文字以内です', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      return
    end
    #以前の命令が関数を調査
    dele_flag =  del_extsheet_func self.items[self.item_index] #設定済みを削除
    if( dele_flag == false )
      return false
    end

    self.items[self.item_index] = inst_text
    add_extsheet_func inst_text  #シートへの挿入が必要な命令の場合
  end

  #<外部シートの関数操作(追加)が必要な場合に呼び出す>
  #また、自己呼び出し[recog0]でTBC [recog0]などの場合は何も行わない
  def add_extsheet_func text
    array = text.split(' ')
    if( array[0] =~/TBC/ || array[0] =~ /PRG/ )&&( array[1] =~/\[recog/ )
      label = text.scan(/\[recog[0-9]*\]/).to_s
      if @sheet.caption == label
        return
      end
      add_sheet_func label
    end
    if( array[0] =~/PIS/ )&&( array[1] =~/\[port_in/ )
      label = text.scan(/\[port_in[0-9]*\]/).to_s
      if @sheet.edit_func == label 
        return
      end
      add_sheet_func label
    end
    if( array[0] =~/CYS/ )&&( array[1] =~/\[cycle/ )
      label = text.scan(/\[cycle[0-9]*\]/).to_s
      if @sheet.edit_func == label 
        return
      end
      add_sheet_func label
    end
    if( array[0] =~/ALS/ )&&( array[1] =~/\[alarm/ )
      label = text.scan(/\[alarm[0-9]*\]/).to_s
      if @sheet.edit_func == label 
        return
      end
      add_sheet_func label
    end
    if( array[0] =~/FNC/ )&&( array[1] =~/\[func_/ )
      label = text.scan(/\[func_[^#]*\]/).to_s
      if @sheet.edit_func == label 
        return
      end
      add_sheet_func label
    end
  end

  #<外部シートの関数操作(削除)が必要な場合に呼び出す>
  #また、自己呼び出し[recog0]でTBC [recog0]などの場合は何も行わない
  def del_extsheet_func text
    array = text.split(' ')
    if( array[0] =~/TBC/ || array[0] =~ /PRG/ )&&( array[1] =~/\[recog/ )
      label = text.scan(/\[recog[0-9]*\]/).to_s
      if @sheet.caption == label 
        return
      end
      del_sheet_func label
    end
    if( array[0] =~/PIS/ )&&( array[1] =~/\[port_in/ )
      label = text.scan(/\[port_in[0-9]*\]/).to_s
      if @sheet.edit_func == label 
        return
      end
      del_sheet_func label
    end
    if( array[0] =~/CYS/ )&&( array[1] =~/\[cycle/ )
      label = text.scan(/\[cycle[0-9]*\]/).to_s
      if @sheet.edit_func == label 
        return
      end
      del_sheet_func label
    end
    if( array[0] =~/ALS/ )&&( array[1] =~/\[alarm/ )
      label = text.scan(/\[alarm[0-9]*\]/).to_s
      if @sheet.edit_func == label 
        return
      end
      del_sheet_func label
    end
    if( array[0] =~/FNC/ )&&( array[1] =~/\[func_/ )
      label = text.scan(/\[func_[^#]*\]/).to_s
      if @sheet.edit_func == label 
        return
      end
      del_sheet_func label
    end
  end
end
