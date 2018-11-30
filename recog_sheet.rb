#�F���e�[�u���o�^�p�V�[�g
class RecogWordSheet < ActionSheet
  def initialize pc, fs, name
    super pc, fs, name

    @funcbox.caption = '�F���P��'
    @flbox.hint = '�E�N���b�N�ŒP��ǉ� or �폜 or �ҏW'
    @flbox.show_hint = true

    #�F���P��ǉ��p�|�b�v�A�b�v
    Phi.new_popup_menu self, :popup_menu, [
      @menu_func_add = Phi.new_item('&Add Recog Word', '', :mi_add),
      @menu_func_edit = Phi.new_item('&Edit Recog Word', '', :mi_edit),
      @menu_func_del = Phi.new_item('&Del Recog Word', '', :mi_del),
    ]
    
    #Add Recog Word�̏���
    @menu_func_add.on_click = proc do
      add_recog_form = Form::new(:ad_form, '�F���P������Ă�������')
      add_recog_form.height = 50
      add_edit = Phi::Edit.new( add_recog_form, :aredit)
      add_edit.align = Phi::AL_CLIENT
      add_button = Phi::Button.new( add_recog_form, :adbutton, 'OK' )
      add_button.align = Phi::AL_RIGHT
      add_recog_form.show

      #���^�[���L�[�œo�^
      add_edit.on_key_down = proc{|sender,key,shift|
        if( key == 13 )
          if word_check( add_edit.text ) == false
            return
          end
          add_func add_edit.text
          add_recog_form.hide
        end
      }

      add_button.on_click = proc do
        if word_check( add_edit.text ) == false
          return
        end

        add_func add_edit.text
        add_recog_form.hide
      end
    end

    def word_check word
      words = word.split /\|/
      words.each do |w|
        reg = Regexp.new('[��-��,�[,��-��]+')
        w =~ reg
        #�Ђ炪�ȃ`�F�b�N&�F���P��̒����`�F�b�N
        
        if $& != w || w.size > 64
          Phi::message_dlg("�s���ȒP�ꂪ�o�^����Ă��܂�",
                           Phi::MT_INFORMATION,[Phi::MB_OK], 0)
          return false
        end
      end
      return true
    end
    
    #Edit Recog Word�̏���
    @menu_func_edit.on_click = proc do
      if @flbox.item_index == -1
        return
      end

      add_recog_form = Form::new(:ad_form, '�F���P���ҏW���Ă�������')
      add_recog_form.height = 50
      add_edit = Phi::Edit.new( add_recog_form, :aredit)
      add_edit.align = Phi::AL_CLIENT
      add_edit.text = @flbox.items[@flbox.item_index]
      add_button = Phi::Button.new( add_recog_form, :adbutton, 'EDIT' )
      add_button.align = Phi::AL_RIGHT
      add_recog_form.show

      #���^�[���L�[�œo�^
      add_edit.on_key_down = proc{|sender,key,shift|
        if( key == 13 )
          @flbox.items[@flbox.item_index] = add_edit.text
          add_recog_form.hide
        end
      }
      
      add_button.on_click = proc do
	@flbox.items[@flbox.item_index] = add_edit.text
	add_recog_form.hide
      end
    end

    #Dell Recog Word�̏���
    @menu_func_del.on_click = proc do
      if @flbox.item_index == -1
        return
      end
      @comlboxs[@flbox.item_index].del_item_all
      @flbox.items[@flbox.item_index] = "-delete-"
      del_sheet_check
    end
  end

  #<�֐��폜����
  #�F���̍폜�̏ꍇ�S�Ă̊֐����폜���Ă���
  def del_func text
    if ref? == false
      message = "�F���P��e�[�u��" + self.caption + "�����S�ɍ폜���܂���?"
      result = Phi::message_dlg( message, Phi::MT_CONFIRMATION, [Phi::MB_YES, Phi::MB_NO], 0)
      case result
      when Phi::MR_YES
#        @visible_flag = false
      when Phi::MR_NO
#        @visible_flag = true
        return
      end

      @flbox.items.each do |func|
        super func
      end
    end
  end

  def del_func_terminator
    super
#    if @visible_flag
#      self.tab_visible = true
#    end
  end

  #<�V�[�g�̒ǉ����`�F�b�N>
  def sheet_add_check name
    if self.caption == name
      ref_set
      self.tab_visible = true
    end
  end

  #<�V�[�g�̍폜���`�F�b�N>
  def sheet_del_check name
    if self.caption == name
      ref_del
      del_func name
    end
  end

  #<�X�N���v�g�`���ŃV�[�g�̓��e��Ԃ�>
  def get_script
    text = ""
    if @flbox.items.count != 0
      text += self.caption + "\n"
      @flbox.items.each do |item|
        flag = false
        array = item.split /\|/
        array.each do |word|
          if flag
            text += "|" + word + "\n"
          else
            text += word + "\n"
            flag = true
          end
        end
      end
      text += "end\n"
    end

    i = 0
    @flbox.items.each do |obj|
      text += self.caption.chop + "_func" + i.to_s + "]\n"
      @comlboxs[i].items.each do |item|
	text += item + "\n"
      end
      text += "end\n"
      i += 1
    end
    return text
  end

  def save ps
    #�֐�ListBox�̃A�C�e���ۑ�
    save_text = @sheet_name 
    ps[save_text] = @flbox.items.text
    super
  end
end
