
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
#    print "�Q��" + @ref_count.to_s + "\n"
  end

  def ref_del
    @ref_count -= 1
#    print "����" + @ref_count.to_s + "\n"
  end

  def ref?
    if @ref_count > 0
      return true
    else
      return false
    end
  end

  #<�֐����̑S���߂��폜>
  # @param commands:�֐��̃��X�g�I�u�W�F�N�g(�ċA�Ăяo���\�Ƃ���)
  def del_item_all
    for i in 0..self.items.count-1
      del_item i
    end
  end

  #<���߂̍폜>
  # @param func_number:�֐��̔ԍ�
  # @param command_number:�폜���閽�߂̔ԍ�
  def del_item command_number
    name = self.items[command_number]
    del_extsheet_func name
    self.items[command_number] = "-delete-"
  end

  #<���߂̒ǉ�>
  # @param inst_text:�ǉ����閽�߂̕�����
  def add_item inst_text
    if inst_text.size > 64
      Phi::message_dlg('��s�ɏ����镶�����64�����ȓ��ł�', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      return
    end
    self.items.add inst_text
    add_extsheet_func inst_text  #�V�[�g�ւ̑}�����K�v�Ȗ��߂̏ꍇ
  end

  #<���߂̕ҏW>
  # @param inst_text:�ǉ�(�㏑��)���閽�߂̕�����
  def edit_item inst_text
    if inst_text.size > 64
      Phi::message_dlg('��s�ɏ����镶�����64�����ȓ��ł�', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      return
    end
    #�ȑO�̖��߂��֐��𒲍�
    dele_flag =  del_extsheet_func self.items[self.item_index] #�ݒ�ς݂��폜
    if( dele_flag == false )
      return false
    end

    self.items[self.item_index] = inst_text
    add_extsheet_func inst_text  #�V�[�g�ւ̑}�����K�v�Ȗ��߂̏ꍇ
  end

  #<�O���V�[�g�̊֐�����(�ǉ�)���K�v�ȏꍇ�ɌĂяo��>
  #�܂��A���ȌĂяo��[recog0]��TBC [recog0]�Ȃǂ̏ꍇ�͉����s��Ȃ�
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

  #<�O���V�[�g�̊֐�����(�폜)���K�v�ȏꍇ�ɌĂяo��>
  #�܂��A���ȌĂяo��[recog0]��TBC [recog0]�Ȃǂ̏ꍇ�͉����s��Ȃ�
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
