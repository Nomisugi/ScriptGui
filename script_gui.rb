#�����F�������G���W���AGUI�X�N���v�g�ݒ�c�[��
#
#    $Author: sugiura $
#    $Date: 2004/09/06 11:06:13 $
#    $Name:  $
#
#
$version = "2.08"
$frmversion = "�{�[�h����擾���Ă���܂���"
$pldversion = "�{�[�h����擾���Ă���܂���"
$boardversion = "�{�[�h����擾���Ă���܂���"

require 'phi'
include Phi
require 'rgui/ui'
require 'dialogs'
require 'comm'
require "pstore"
require 'jcode'
$KCODE='s'

APPLICATION.icon = Icon.new.load Dir::pwd.to_s + '/icon.ico'
RECOG_TABLE_MAX = 100
HOME_PATH = Dir::pwd
back_file = HOME_PATH.to_s + "/backup.ps"

require Dir::pwd.to_s + '/common_form.rb'     #�ʐM�p�t�H�[��
require Dir::pwd.to_s + '/command_list.rb'    #�X�N���v�g���߈ꗗ
require Dir::pwd.to_s + '/command_listbox.rb' #���߃��X�g�{�b�N�X
require Dir::pwd.to_s + '/edit_command.rb'    #���ߕҏW
require Dir::pwd.to_s + '/func_sheet.rb'      #�֐��V�[�g
require Dir::pwd.to_s + '/recog_sheet.rb'     #�F���p�֐��V�����V�[�g
require Dir::pwd.to_s + '/initial_sheet.rb'   #�������p�֐��V�[�g
require Dir::pwd.to_s + '/graphi_form.rb'     #�O���t�\���p�t�H�[��
require Dir::pwd.to_s + '/script_edit.rb'     #�X�N���v�g�G�N�X�|�[�g�p
require Dir::pwd.to_s + '/wav_install.rb'     #wav�t�@�C���̃C���X�g�[��
require Dir::pwd.to_s + '/udic_install.rb'    #���[�U�����̃C���X�g�[��

#���C���t�H�[���̐ݒ�
class MainForm < RGUI::Form
  def initialize
    super
    self.caption = '�X�N���v�g�G���W��GUI��'
    self.width = 640
    self.height = 500
    self.top = 0
    self.left = 0
    self.position = PO_DEFAULT_POS_ONLY

#     tb=ToolBar.new self
#     tb.show_captions=true 

#      btn=ToolButton.new tb
#      btn.caption='�L���v�V����'
#     ico = Icon.new          #�A�C�R���̏ꍇ
#     ico.load('blue.ico')
#     il = ImageList.new
#     il.masked=false         #�}�X�N�̎g�p�@���s���ł��̂�
# #    il.add(bmp,0)           #��2�����̓}�X�N�ł������
#     il.add_icon(ico)        #�}�X�N�͖���
#     tb.images=il            #0�Ԗ�pri.bmp�A1�Ԗ�ppm.ico���������B
#     btn.image_index = 0     #�����pri.bmp�Appm.ico�Ȃ�A1    �j
    
    @connect_flag = false  #�ʐM��Ԃ�ێ�
    @connect_target = false #�{�[�h�Ƃ̐ڑ����
    @target_td = "NO_CONNECT" #�^�[�Q�b�g�̏�Ԃ��擾
    $log = ComLogWindow::new
    @wav = WavFileSetting::new
    @udic = UserDictionarySetting.new 

    panel = Phi::Panel::new self
    Phi::StatusBar::new self, :status_bar, 'hoger' #�X�e�[�^�X�o�[
    status_bar.simple_panel = panel
    status_bar.simple_text = ""
    status_bar.visible = true

    #�V�[�g�̐ݒ�
    pc = PageControl.new self, :pc
    pc.align = Phi::AL_CLIENT
    @table_sheets = []
    @table_sheets[0] = InitialFuncSheet.new pc, :initialize, '[initialize]' #[initialize]�֐�
    for i in 1..RECOG_TABLE_MAX
      name = "recog"+(i-1).to_s
      @table_sheets[i] =  RecogWordSheet.new pc, :name,
	"[recog" + (i-1).to_s + "]"
      @table_sheets[i].tab_visible = false
    end
    @table_sheets[101] = ActionSheet.new pc, :port_in, '[port_in]'
    @table_sheets[101].tab_visible = false
    @table_sheets[102] = ActionSheet.new pc, :cycle, '[cycle]'
    @table_sheets[102].tab_visible = false
    @table_sheets[103] = ActionSheet.new pc, :alarm, '[alarm]'
    @table_sheets[103].tab_visible = false
    @table_sheets[104] = FncSheet.new pc, :func_, '[func_user]'
    @table_sheets[104].tab_visible = false

    @table_sheets[0].tab_visible = true
    @table_sheets[1].tab_visible = true

    #�Q�Ɗ֐��̃A�b�v([initialize]��[recog0]�͒ʏ�\��)
    @table_sheets[0].ref_set
    @table_sheets[1].ref_set

    #Menu�̐ݒ�
    Phi.new_menu self, :menu, [
      Phi.new_item('&�t�@�C��(F)', '', :mi_file).add(
						     @menu_save = Phi.new_item('&�Z�[�u', '', :mi_save),
						     @menu_load = Phi.new_item('&���[�h', '', :mi_open),
                                                     Phi.new_line,
						     @menu_script =  Phi.new_item('&�X�N���v�g�ŕۑ�', '', :mi_save_script),
						     @menu_export =  Phi.new_item('&�X�N���v�g�̃G�N�X�|�[�g', '', :mi_export_script),
                                                     Phi.new_line,
						     @menu_init = Phi.new_item('&�ݒ��������', '', :mi_initialize),
						     @menu_exit = Phi.new_item('E&xit', '', :mi_exit)),
      Phi.new_item('&�^�[�Q�b�g�ɐڑ�(T)', '', :mi_target).add(
                                                     @menu_pcinit = Phi.new_item('&PC�����ݒ�(I)', '', :mi_init),
                                                     @menu_target = Phi.new_item('&Target�ڑ�(T)', '', :mi_target),
                                                     Phi.new_line,
                                                     @menu_log = Phi.new_item('&�ʐMLog�\��(L)', '', :mi_log)),
      Phi.new_item('&�{�[�h�ɑ��M(I)', '', :mi_apinit ).add(
                                                     @menu_appwav =  Phi.new_item('&WAV�t�@�C���̃C���X�g�[��(W)', '', :mi_wav),
                                                     @menu_appudic = Phi.new_item('&���[�U�����̃C���X�g�[��(D)', '', :mi_wav),
                                                     Phi.new_line,
                                                     @menu_send = Phi.new_item('&�X�N���v�g���M(S)', '', :mi_send),
                                                     @menu_get = Phi.new_item('&Target����X�N���v�g�擾(G)', '', :mi_get)),
      
      @menu_graph = Phi.new_item('&�֌W�}(G)', '', :mi_graph),
      

      @menu_help = Phi.new_item('&�w���v(H)', '', :mi_help)
    ]
    self.show

    begin
      $graph = GraphForm::new #Graph�\��
      @graphviz = true
    rescue
      @graphviz = false
      @menu_graph.visible = false
    end

    #�w���v���b�Z�[�W�y�уo�[�W�������
    @menu_help.on_click = proc do
      info_str = "�����F�������X�N���v�g�G���W��GUI\n\n" +
 	"This Version : " + $version.to_s + "\n" +
 	"Fram Version : " + $frmversion.to_s + "\n"
      Phi::message_dlg( info_str,  Phi::MT_INFORMATION, [Phi::MB_OK], 0 )
    end

    @menu_appwav.on_click = proc do
      @wav.show
    end

    @menu_appudic.on_click = proc do
      @udic.show
    end

    #�I��
    @menu_exit.on_click = proc do
      exit
    end

    #�ݒ�̏�����
    @menu_init.on_click = proc do
      initial_load
    end

    def initial_load
      @table_sheets.each do |sheet|
	sheet.tab_visible = false
        sheet.clear
      end
      @wav.clear
      @udic.clear

      @table_sheets[0].tab_visible = true
      @table_sheets[1].tab_visible = true
      @table_sheets[0].ref_set
      @table_sheets[1].ref_set
    end

    #�t�@�C���̃Z�[�u
    @menu_save.on_click = proc do
      dlg = Phi::SaveDialog.new
      dlg.filter = 'SaveFile(*.ps)|*.ps|���ׂ�(*.*)|*|'
      if dlg.execute
        if dlg.file_name.split(/\./)[1] == nil
          dlg.file_name = dlg.file_name + ".ps"
        end
	s_ps = PStore.new(dlg.file_name)
	s_ps.transaction{|ps|
	  self.save ps
	}
      end
    end

    #�t�@�C���̃��[�h
    @menu_load.on_click = proc do
      dlg = Phi::OpenDialog.new
      dlg.filter = 'LoadFile(*.ps)|*.ps|���ׂ�(*.*)|*|'
      if dlg.execute
        path = File::expand_path(dlg.file_name)
        if FileTest::readable?(path)
          initial_load
          l_ps = PStore.new(dlg.file_name)
          l_ps.transaction{|ps|
            self.load ps
          }
        else
          Phi::message_dlg("#{path}: �ǂ݂��ނ��Ƃ��o���܂���B",
                           Phi::MT_ERROR, [Phi::MB_OK], 0)
        end
      end
    end

    #�X�N���v�g�ŃZ�[�u
    @menu_script.on_click = proc do
      dlg = Phi::SaveDialog.new
      dlg.filter = 'ScriptFile(*.txt)|*.txt|'
      if dlg.execute
        if dlg.file_name.split(/\./)[1] == nil
          dlg.file_name = dlg.file_name + ".txt"
        end
	f = File::open dlg.file_name, 'w'
	f.print make_script
	f.close
      end
    end

    #�����̃X�N���v�g���G�N�X�|�[�g
    @menu_export.on_click = proc do
      temp_file = HOME_PATH + '/temp.ps'
      dlg = Phi::OpenDialog.new
      dlg.filter = '�e�L�X�g(*.txt)|*.txt|���ׂ�(*.*)|*|'

      if dlg.execute
        path = File::expand_path(dlg.file_name)
        if FileTest::readable?(path)
          script_export( dlg.file_name, temp_file)
          initial_load
          ps = PStore.new(temp_file)
          ps.transaction{|ps|
            load ps
          }
        else
          Phi::message_dlg("#{path}: �ǂ݂��ނ��Ƃ��o���܂���B",
                           Phi::MT_ERROR, [Phi::MB_OK], 0)
        end
      end
    end
    
    #PC�������ݒ���s
    @menu_pcinit.on_click = proc do
      if @connect_flag == true
	Phi::message_dlg('COM�|�[�g�͊��ɊJ���Ă��܂�',
			 Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      else
	$log.open_port
      end
    end

    #Target�ڑ�����
    @menu_target.on_click = proc do
      if @connect_flag
        if @connect_target
          Phi::message_dlg("���Ƀ^�[�Q�b�g�Ɛڑ�����Ă��܂�", 
                           Phi::MT_INFORMATION,[Phi::MB_OK], 0)
          break
        end
	Phi::message_dlg("�{�[�h���N�����A���̓X�N���v�g�}�l�[�W���ŋN�����Ă��鎖���m�F���ĉ�����\n�{�[�h�ɍċN���R�}���h�𑗐M���܂�", 
			 Phi::MT_INFORMATION,[Phi::MB_OK], 0)
        reg = /^>>/
        reg2 = /^wav>>|^udic>>/

        connect2 = Proc::new {|obj|
          $log.send "exit\n"
        }
        connect = Proc::new {|obj|
          target_on
          version_get obj
          $log.memo.del_callback reg2, connect2
        }

        $log.memo.get_string reg, connect
        $log.memo.set_callback reg2, connect2
	$log.send "@1\n"
      else
	Phi::message_dlg('COM�|�[�g���J����Ă܂���', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      end
    end
    
    #�ʐMLOG�\��
    @menu_log.on_click = proc do
      $log.visible = true     
    end

    #���֊֌W�}�\��
    @menu_graph.on_click = proc do
      $graph.visible = true
      $graph.refresh make_script
    end

    #�ڑ���Ԃ��ŐV�̏�Ԃɕۂ�ComLogWindow
    timer = Phi::Timer::new
    timer.on_timer = proc do
      #�V���A���̒ʐM�󋵂�c��
      if $log.memo.comm.handle != -1
	@connect_flag = true;
      end
      
      str = '[COM:' + @connect_flag.to_s + ' baud = ' +
            $log.memo.comm.bit_rate.to_s + '][�{�[�h�ڑ�:' + @connect_target.to_s + ']' +
                 '[' + @target_td + ']'
      status_bar.simple_text = str
    end

    #�X�N���v�g���M����
    @menu_send.on_click = proc do
      if @connect_flag == true && @connect_target == true
        if target_condition? != "START"
          Phi::message_dlg('���݃{�[�h�̏�Ԃ̓r�W�[�ł�',
                           Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
          break
        end

	$log.send "script\n"
	$log.send "wgo\n"
	Phi::message_dlg('�t�@�C���𑗐M���܂�', Phi::MT_INFORMATION,[Phi::MB_OK], 0)
	text = make_script
	text.each_line do |line|
	  $log.send line
	end
	@connect_target = false
        @target_td = "�A�v���P�[�V�������쒆"
      else
	Phi::message_dlg('COM�|�[�g������Target���J����Ă܂���', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)	
      end
    end

    #�^�[�Q�b�g����X�N���v�g�����擾
    @menu_get.on_click = proc do
      get_proc = Proc::new{|script|
        temp_file = HOME_PATH + '/temp.ps'
        script_file = HOME_PATH + 'temp_script.txt'
        file = File.open script_file, "w"
        file.print script
        file.close
        script_export( script_file, temp_file)
        initial_load
        ps = PStore.new(temp_file)
        ps.transaction{|ps|
          load ps
        }
        $log.send "exit\n"
      }

      if @connect_flag == true && @connect_target == true
        if target_condition? != "START"
          Phi::message_dlg('���݃{�[�h�̏�Ԃ̓r�W�[�ł�',
                           Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
          break
        end
        $log.send "script\n"
        $log.memo.get_string( /^\s*\*.+\*/, get_proc )
        $log.send "read\n"
      else
	Phi::message_dlg('COM�|�[�g������Target���J����Ă܂���', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      end
    end

    #�^�[�Q�b�g�̑J�ڏ�Ԃ��擾
    td_reg1 = /^>>$/
    td_proc1 = Proc::new {|obj|
      @target_td = "START"
    }
    $log.memo.set_callback td_reg1, td_proc1
    td_reg2 = /^wav>>$/
    td_proc2 = Proc::new {|obj|
      @target_td = "WAV�t�@�C���̃C���X�g�[�����ł�"
    }
    $log.memo.set_callback td_reg2, td_proc2
    td_reg3 = /^udic>>$/
    td_proc3 = Proc::new {|obj|
      @target_td = "���[�U�����̃C���X�g�[�����ł�"
    }
    $log.memo.set_callback td_reg3, td_proc3
  end

  def version_get string
    string.each_line do |line|
      if line =~ /ScriptEngine\sversion/
        version = line.split( /\s/ )
        $frmversion =  version[2]
      end
    end
  end

  #�^�[�Q�b�g�̐ڑ���
  def target?
    return @connect_target
  end

  #���݂̃^�[�Q�b�g�̑J�ڏ�Ԃ�߂�
  def target_condition?
    return @target_td
  end

  #�V�[�g�̒ǉ�(�\��)
  def add_sheet_func name
    @table_sheets.each do |sheet|
      sheet.sheet_add_check name
    end

    if $graph
      $graph.refresh make_script
    end
  end
  
  #�V�[�g�̍폜
  def del_sheet_func name
    @table_sheets.each do |sheet|
      sheet.sheet_del_check name
    end

    if $graph
      $graph.refresh make_script
    end
  end

  #�폜���ꂽ�V�[�g�A���߂��Ō�ɏW�߂č폜����
  def del_sheet_check
    @table_sheets.each do |sheet|
      sheet.del_func_terminator
    end
    if $graph
      $graph.refresh make_script
    end
  end

  #�X�N���v�g�t�@�C�����쐬
  def make_script
    text = "\n"
    text += "DEBUG\nTIMER\nSERIAL\n"
    @table_sheets.each do |obj|
      text += obj.get_script
    end
    text += "*endscript*\n"
    return text
  end

  #�^�[�Q�b�g�ڑ��m�F�\��
  def target_on
    Phi::message_dlg('�^�[�Q�b�g�Ƃ̐ڑ��m�F!', Phi::MT_INFORMATION,[Phi::MB_OK], 0)	
    @connect_target = true
  end

  #�ݒ���̃Z�[�u
  def save ps
    @table_sheets.each do |sheet|
      sheet.save ps
    end
    @wav.save ps
    @udic.save ps
  end

  #�ݒ���̃��[�h
  def load ps
    @table_sheets.each do |sheet|
      sheet.load ps
    end
    @wav.load ps
    @udic.load ps
  end

  #�I�u�W�F�N�g�̃]���r�΍�(ruby apollo�ŗL�̖��)
  def destructor file
    save_ps = PStore.new file
    $log.close
    if $graph
      $graph.close
    end
    save_ps.transaction{|ps|
      $main.save ps
    }
    $main.initial_load
    @table_sheets.each do |sheet|
      sheet = nil
    end
    @wav.clear
    @wav.close
    @wav.hide
    @wav = nil
    GC.start

    @udic.clear
    @udic.close
    @udic = hide
    @udic = nil
    GC.start
  end
end

$main = MainForm::new

def main_sheet_top
  return $main.top
end

def main_sheet_left
  return $main.left
end

def add_sheet_func name
  $main.add_sheet_func name
end

def del_sheet_func name
  $main.del_sheet_func name
end

def del_sheet_check
  $main.del_sheet_check
end

#�I�����̃Z�[�u�ݒ�
$main.on_close = proc{
  GC.start
  $main.destructor back_file
  GC.start
}

load_ps = PStore.new(back_file)
load_ps.transaction{|ps|
   $main.load ps
}

Phi.mainloop

#�o�O���X�g:
# �o�O���e. ������ . �C����. �R�����g
#
# �E�N���b�N���j���[�͈̔�. 04/08/05. 04/08/025. �͈͂��C��
# �X�^�[�g�����COM�ڑ����Ă��܂�. 04/08/05. 04/09/01
# Graph�\����FALSE���\������Ă��܂�. 04/08/24. 04/08/24. graphi_form�̃o�O
# COMLOG�̕\�������ɃY���Ă��܂�. 04/08/24. 04/08/31. COMLOG��S�ʓI�ɏC��
# [initialize]��[initialize���o���Ă��܂�. 04/08/24. 04/08/24. initialize_func�ɏC�����𓱓�(���S�C���ł͂Ȃ�)
# �������X�N���v�g���G�N�X�|�[�g����Ȃ�. 04/08/25. 04/08/26. script_edit�C������
# �Q�Ƃ̖����֐��܂ŃG�N�X�|�[�g����Ă��܂�. 04/08/25
# [func_***]�̊֐����Q�Ƃ���Ă��Ȃ����\������Ă��܂�. 04/08/24
# [initialize]�̃G�N�X�|�[�g����邪�Z�[�u������Ȃ�. 04/08/26. 04/08/26. initialize_func���C��
# �p�C�v�Ōq�����F���P��̕�������64���������Ɉ���������. 04/09/01. 04/09/03. �P��`�F�b�N���[�`���̏C��
# ���݂��Ȃ��t�@�C�����J���Ɨ�����. 04/09/02. 04/09/03. �`�F�b�N���[�`��������
