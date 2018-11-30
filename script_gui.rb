#音声認識合成エンジン、GUIスクリプト設定ツール
#
#    $Author: sugiura $
#    $Date: 2004/09/06 11:06:13 $
#    $Name:  $
#
#
$version = "2.08"
$frmversion = "ボードから取得しておりません"
$pldversion = "ボードから取得しておりません"
$boardversion = "ボードから取得しておりません"

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

require Dir::pwd.to_s + '/common_form.rb'     #通信用フォーム
require Dir::pwd.to_s + '/command_list.rb'    #スクリプト命令一覧
require Dir::pwd.to_s + '/command_listbox.rb' #命令リストボックス
require Dir::pwd.to_s + '/edit_command.rb'    #命令編集
require Dir::pwd.to_s + '/func_sheet.rb'      #関数シート
require Dir::pwd.to_s + '/recog_sheet.rb'     #認識用関数ションシート
require Dir::pwd.to_s + '/initial_sheet.rb'   #初期化用関数シート
require Dir::pwd.to_s + '/graphi_form.rb'     #グラフ表示用フォーム
require Dir::pwd.to_s + '/script_edit.rb'     #スクリプトエクスポート用
require Dir::pwd.to_s + '/wav_install.rb'     #wavファイルのインストール
require Dir::pwd.to_s + '/udic_install.rb'    #ユーザ辞書のインストール

#メインフォームの設定
class MainForm < RGUI::Form
  def initialize
    super
    self.caption = 'スクリプトエンジンGUI版'
    self.width = 640
    self.height = 500
    self.top = 0
    self.left = 0
    self.position = PO_DEFAULT_POS_ONLY

#     tb=ToolBar.new self
#     tb.show_captions=true 

#      btn=ToolButton.new tb
#      btn.caption='キャプション'
#     ico = Icon.new          #アイコンの場合
#     ico.load('blue.ico')
#     il = ImageList.new
#     il.masked=false         #マスクの使用法が不明ですので
# #    il.add(bmp,0)           #第2引数はマスクですが･･･
#     il.add_icon(ico)        #マスクは無い
#     tb.images=il            #0番目pri.bmp、1番目ppm.icoが入った。
#     btn.image_index = 0     #こればpri.bmp、ppm.icoなら、1    ）
    
    @connect_flag = false  #通信状態を保持
    @connect_target = false #ボードとの接続状態
    @target_td = "NO_CONNECT" #ターゲットの状態を取得
    $log = ComLogWindow::new
    @wav = WavFileSetting::new
    @udic = UserDictionarySetting.new 

    panel = Phi::Panel::new self
    Phi::StatusBar::new self, :status_bar, 'hoger' #ステータスバー
    status_bar.simple_panel = panel
    status_bar.simple_text = ""
    status_bar.visible = true

    #シートの設定
    pc = PageControl.new self, :pc
    pc.align = Phi::AL_CLIENT
    @table_sheets = []
    @table_sheets[0] = InitialFuncSheet.new pc, :initialize, '[initialize]' #[initialize]関数
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

    #参照関数のアップ([initialize]と[recog0]は通常表示)
    @table_sheets[0].ref_set
    @table_sheets[1].ref_set

    #Menuの設定
    Phi.new_menu self, :menu, [
      Phi.new_item('&ファイル(F)', '', :mi_file).add(
						     @menu_save = Phi.new_item('&セーブ', '', :mi_save),
						     @menu_load = Phi.new_item('&ロード', '', :mi_open),
                                                     Phi.new_line,
						     @menu_script =  Phi.new_item('&スクリプトで保存', '', :mi_save_script),
						     @menu_export =  Phi.new_item('&スクリプトのエクスポート', '', :mi_export_script),
                                                     Phi.new_line,
						     @menu_init = Phi.new_item('&設定を初期化', '', :mi_initialize),
						     @menu_exit = Phi.new_item('E&xit', '', :mi_exit)),
      Phi.new_item('&ターゲットに接続(T)', '', :mi_target).add(
                                                     @menu_pcinit = Phi.new_item('&PC初期設定(I)', '', :mi_init),
                                                     @menu_target = Phi.new_item('&Target接続(T)', '', :mi_target),
                                                     Phi.new_line,
                                                     @menu_log = Phi.new_item('&通信Log表示(L)', '', :mi_log)),
      Phi.new_item('&ボードに送信(I)', '', :mi_apinit ).add(
                                                     @menu_appwav =  Phi.new_item('&WAVファイルのインストール(W)', '', :mi_wav),
                                                     @menu_appudic = Phi.new_item('&ユーザ辞書のインストール(D)', '', :mi_wav),
                                                     Phi.new_line,
                                                     @menu_send = Phi.new_item('&スクリプト送信(S)', '', :mi_send),
                                                     @menu_get = Phi.new_item('&Targetからスクリプト取得(G)', '', :mi_get)),
      
      @menu_graph = Phi.new_item('&関係図(G)', '', :mi_graph),
      

      @menu_help = Phi.new_item('&ヘルプ(H)', '', :mi_help)
    ]
    self.show

    begin
      $graph = GraphForm::new #Graph表示
      @graphviz = true
    rescue
      @graphviz = false
      @menu_graph.visible = false
    end

    #ヘルプメッセージ及びバージョン情報
    @menu_help.on_click = proc do
      info_str = "音声認識合成スクリプトエンジンGUI\n\n" +
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

    #終了
    @menu_exit.on_click = proc do
      exit
    end

    #設定の初期化
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

    #ファイルのセーブ
    @menu_save.on_click = proc do
      dlg = Phi::SaveDialog.new
      dlg.filter = 'SaveFile(*.ps)|*.ps|すべて(*.*)|*|'
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

    #ファイルのロード
    @menu_load.on_click = proc do
      dlg = Phi::OpenDialog.new
      dlg.filter = 'LoadFile(*.ps)|*.ps|すべて(*.*)|*|'
      if dlg.execute
        path = File::expand_path(dlg.file_name)
        if FileTest::readable?(path)
          initial_load
          l_ps = PStore.new(dlg.file_name)
          l_ps.transaction{|ps|
            self.load ps
          }
        else
          Phi::message_dlg("#{path}: 読みこむことが出来ません。",
                           Phi::MT_ERROR, [Phi::MB_OK], 0)
        end
      end
    end

    #スクリプトでセーブ
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

    #既存のスクリプトをエクスポート
    @menu_export.on_click = proc do
      temp_file = HOME_PATH + '/temp.ps'
      dlg = Phi::OpenDialog.new
      dlg.filter = 'テキスト(*.txt)|*.txt|すべて(*.*)|*|'

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
          Phi::message_dlg("#{path}: 読みこむことが出来ません。",
                           Phi::MT_ERROR, [Phi::MB_OK], 0)
        end
      end
    end
    
    #PC初期化設定実行
    @menu_pcinit.on_click = proc do
      if @connect_flag == true
	Phi::message_dlg('COMポートは既に開いています',
			 Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      else
	$log.open_port
      end
    end

    #Target接続処理
    @menu_target.on_click = proc do
      if @connect_flag
        if @connect_target
          Phi::message_dlg("既にターゲットと接続されています", 
                           Phi::MT_INFORMATION,[Phi::MB_OK], 0)
          break
        end
	Phi::message_dlg("ボードが起動中、又はスクリプトマネージャで起動している事を確認して下さい\nボードに再起動コマンドを送信します", 
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
	Phi::message_dlg('COMポートが開かれてません', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      end
    end
    
    #通信LOG表示
    @menu_log.on_click = proc do
      $log.visible = true     
    end

    #相関関係図表示
    @menu_graph.on_click = proc do
      $graph.visible = true
      $graph.refresh make_script
    end

    #接続状態を最新の状態に保つComLogWindow
    timer = Phi::Timer::new
    timer.on_timer = proc do
      #シリアルの通信状況を把握
      if $log.memo.comm.handle != -1
	@connect_flag = true;
      end
      
      str = '[COM:' + @connect_flag.to_s + ' baud = ' +
            $log.memo.comm.bit_rate.to_s + '][ボード接続:' + @connect_target.to_s + ']' +
                 '[' + @target_td + ']'
      status_bar.simple_text = str
    end

    #スクリプト送信処理
    @menu_send.on_click = proc do
      if @connect_flag == true && @connect_target == true
        if target_condition? != "START"
          Phi::message_dlg('現在ボードの状態はビジーです',
                           Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
          break
        end

	$log.send "script\n"
	$log.send "wgo\n"
	Phi::message_dlg('ファイルを送信します', Phi::MT_INFORMATION,[Phi::MB_OK], 0)
	text = make_script
	text.each_line do |line|
	  $log.send line
	end
	@connect_target = false
        @target_td = "アプリケーション動作中"
      else
	Phi::message_dlg('COMポートが又はTargetが開かれてません', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)	
      end
    end

    #ターゲットからスクリプト情報を取得
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
          Phi::message_dlg('現在ボードの状態はビジーです',
                           Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
          break
        end
        $log.send "script\n"
        $log.memo.get_string( /^\s*\*.+\*/, get_proc )
        $log.send "read\n"
      else
	Phi::message_dlg('COMポートが又はTargetが開かれてません', Phi::MT_INFORMATION,[Phi::MB_ABORT], 0)
      end
    end

    #ターゲットの遷移状態を取得
    td_reg1 = /^>>$/
    td_proc1 = Proc::new {|obj|
      @target_td = "START"
    }
    $log.memo.set_callback td_reg1, td_proc1
    td_reg2 = /^wav>>$/
    td_proc2 = Proc::new {|obj|
      @target_td = "WAVファイルのインストール中です"
    }
    $log.memo.set_callback td_reg2, td_proc2
    td_reg3 = /^udic>>$/
    td_proc3 = Proc::new {|obj|
      @target_td = "ユーザ辞書のインストール中です"
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

  #ターゲットの接続可否
  def target?
    return @connect_target
  end

  #現在のターゲットの遷移状態を戻す
  def target_condition?
    return @target_td
  end

  #シートの追加(表示)
  def add_sheet_func name
    @table_sheets.each do |sheet|
      sheet.sheet_add_check name
    end

    if $graph
      $graph.refresh make_script
    end
  end
  
  #シートの削除
  def del_sheet_func name
    @table_sheets.each do |sheet|
      sheet.sheet_del_check name
    end

    if $graph
      $graph.refresh make_script
    end
  end

  #削除されたシート、命令を最後に集めて削除する
  def del_sheet_check
    @table_sheets.each do |sheet|
      sheet.del_func_terminator
    end
    if $graph
      $graph.refresh make_script
    end
  end

  #スクリプトファイルを作成
  def make_script
    text = "\n"
    text += "DEBUG\nTIMER\nSERIAL\n"
    @table_sheets.each do |obj|
      text += obj.get_script
    end
    text += "*endscript*\n"
    return text
  end

  #ターゲット接続確認表示
  def target_on
    Phi::message_dlg('ターゲットとの接続確認!', Phi::MT_INFORMATION,[Phi::MB_OK], 0)	
    @connect_target = true
  end

  #設定情報のセーブ
  def save ps
    @table_sheets.each do |sheet|
      sheet.save ps
    end
    @wav.save ps
    @udic.save ps
  end

  #設定情報のロード
  def load ps
    @table_sheets.each do |sheet|
      sheet.load ps
    end
    @wav.load ps
    @udic.load ps
  end

  #オブジェクトのゾンビ対策(ruby apollo固有の問題)
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

#終了時のセーブ設定
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

#バグリスト:
# バグ内容. 発見日 . 修正日. コメント
#
# 右クリックメニューの範囲. 04/08/05. 04/08/025. 範囲を修正
# スタートするとCOM接続してしまう. 04/08/05. 04/09/01
# Graph表示でFALSEが表示されてしまう. 04/08/24. 04/08/24. graphi_formのバグ
# COMLOGの表示が下にズレてしまう. 04/08/24. 04/08/31. COMLOGを全面的に修正
# [initialize]に[initializeが出来てしまう. 04/08/24. 04/08/24. initialize_funcに修正個所を導入(完全修正ではない)
# 正しくスクリプトがエクスポートされない. 04/08/25. 04/08/26. script_edit修正完了
# 参照の無い関数までエクスポートされてしまう. 04/08/25
# [func_***]の関数が参照されていないが表示されてしまう. 04/08/24
# [initialize]のエクスポートされるがセーブがされない. 04/08/26. 04/08/26. initialize_funcを修正
# パイプで繋いだ認識単語の文字数が64文字制限に引っかかる. 04/09/01. 04/09/03. 単語チェックルーチンの修正
# 存在しないファイルを開くと落ちる. 04/09/02. 04/09/03. チェックルーチンを入れる
