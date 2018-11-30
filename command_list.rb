#音声認識合成エンジン、GUIスクリプト設定ツール
#
#    \file  :command_list.rb
#    \brief スクリプト命令一覧＆ヘルプメッセージ
#
#    $Author: sugiura $
#    $Date: 2004/09/06 11:06:13 $
#    $Name:  $
#

#命令
#場合によっては表示しない方がいい命令もあるので
#コメントアウトすれば選択できなくなる
$command_list = [
  "TLK", "TWT", "TBC",
  "CAL", "CMP", "STR",
  "IFJ", "JMP", "LAB",
  "CYS", "CYD", "ALS", "ALD",
  "PIS", "PTO", "PID", "PIV",
  "SCO", "SST",
  "VCC", "RCC", "RVC",
#  "FNC", "PLY", "STP", "PRG",
  "FNC", "PLY", "PRG",
  "EXC"
]

#マルチコマンドエントリーBOX
#本来はグローバルにするのは不味いが、ファンクション引数破壊処理が
#判明するまでの借地措置

$command_entrys = []
$command_labels = []
$command = Hash::new

#  ヘルプメッセージ, 命令数(-1が無し, 0～が1個), 引数の添え字, 入力引数のProc
$command["TLK"] = [
  '[内容]指定の文字列を喋らせます
[文法]TLK カナ漢字文字, 音声空白時間(100ms単位)
[例文1]TLK お元気ですか？
[例文2]TLK こんにちは。,5
[補足]カナ漢字文字の他に$S00などの文字列レジスタを使用する事ができます',
  1,
  "カナ漢字交じり文字列",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  },
  "喋った後の空白時間(100ms単位)",
  Proc::new {|obj|
   $command_entrys[1] = Phi::ComboBox.new obj
    11.times do |i|
      $command_entrys[1].items.add i.to_s
    end
  }
]

$command["TKS"] = [
  '[内容]指定のシンボル文字列を喋らせます
[文法]TKS シンボル文字列
[例文]TKS simbol_string
[補足]シンボル文字列は専用ツールにて作成されます',
  0,
  "シンボル文字列",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

$command["TWT"] = [
  '[内容]ボードが発声中の音を音声認識してしまう事を抑制します
[文法]TWT
[例文]TWT
[補足]TLK命令は喋り始めた途中で次の命令が実行されます。
その場合、喋っている最中に音声認識が始まる可能性もあります。
この命令はTLK命令で喋った言葉が完全に喋り終わるまで待機します。
TLK命令やPLY命令の後に指定して下さい',
  -1 
]

$command["TBC"] = [
  '[内容]現在の認識テーブルから指定の認識テーブルに切り替えます
[文法]TBC [飛び先のテーブルリスト] 
[例文]TBC [recog3]
[補足]RETURNを選択すると飛び元のテーブルに戻ります.
TBC後に書かれた命令は飛び先でTBC RETRUNが実行された後に実行されます',
  0,
  "飛び先のテーブル",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    $command_entrys[0].items.add "RETURN"
    RECOG_TABLE_MAX.times do |i|
      table_text = "[recog" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  }
]

$command["PIS"] = [
  '[内容]ポート入力があった場合、指定関数を呼び出し、命令を実行します
[文法]PIS [[port_in0～31]までの呼び先], [ポートの種類PORT], [ポート一致値], [呼び出し条件], [マスク値]
[例文]PIS [port_in1], PORT, 0x00, TRUE, 0xfe
[補足]ポート説明書を参照ください',
  4,
  "呼び出しポート関数",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    32.times do |i|
      table_text = "[port_in" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  },
  "ポートの種類",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    $command_entrys[1].items.add "PORT"
    $command_entrys[1].items.add "SERIAL"
    $command_entrys[1].text = "PORT"
  },
  "ポート一致値",
  Proc::new {|obj|
    $command_entrys[2] = Phi::Edit.new obj, nil, '0x00'
  },
  "呼び出し変化",
  Proc::new {|obj|
    $command_entrys[3] = Phi::ComboBox.new obj
    $command_entrys[3].items.add "TRUE"
    $command_entrys[3].items.add "FALSE"
    $command_entrys[3].items.add "CHANGE"
    $command_entrys[3].text = "TRUE"
  },
  "マスク値",
  Proc::new {|obj|
    $command_entrys[4] = Phi::Edit.new obj
    $command_entrys[4].text = '0x00'
  }
]

$command["PID"] = [
  '[内容]PISで設定されたポート呼び出しを停止させます
[文法]PID [[port_in0～31]までの呼び先]
[例文]PID [port_in1]
[補足]既にポート関数が実行状態の場合も、実行が停止されます',
  0,
  "呼び出しポート関数",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..31
      table_text = "[port_in" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  }
]

$command["PIV"] = [
  '[内容]入力ポートの現在の値を取得します
[文法]PIV 整数格納レジスタ
[例文]PID $I00
[補足]',
  0,
  "整数格納レジスタ",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = "$I00"
  }
]


$command["CYS"] = [
  '[内容]周期的に関数を呼び出し、命令を実行する事ができます
[文法]CYS [周期的に呼び出す関数], 呼び出し時間(100ms単位)
[例文]CYS [cycle2], 10  # 1秒毎に [cycle2]を呼び出す事ができます
[補足]周期呼び出し関数は他の関数が動作している時は実行されません。他の関数の動作が完了し次第実行されます',
  1,
  "周期起動関数",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..4
      table_text = "[cycle" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  },
  "呼び出し時間(100ms単位)",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
    $command_entrys[1].text = '10'
  }
]

$command["CYD"] = [
  '[内容]CYSで設定された周期呼び出しを停止させます
[文法]CYD [周期的に呼び出す関数]
[例文]CYD [cycle1] # [cycle1]で周期呼び出しを停止します
[補足]この関数を呼び出す前に目的の周期関数の設定周期が来ても、周期関数の実行は停止します',
  0,
  "停止する周期起動関数",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..8
      table_text = "[cycle" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  }
]

$command["ALS"] = [
  '[内容]指定時間後に関数を呼び出し、命令を実行する事ができます
[文法]ALS [呼び出す関数], 呼び出し時間(100ms単位)
[例文]ALS [alarm0], 10  # 1秒毎に [alarm0]を呼び出す事ができます
[補足]指定時間が経った時に、他の関数が実行中の場合、その関数が終了してからアラーム関数が実行されます',
  1,
  "呼び出し関数",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    128.times do |i|
      alarm_func = sprintf "[alarm%d]", i
      $command_entrys[0].items.add alarm_func
    end
  },
  "呼び出し時間(100ms単位)",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
    $command_entrys[1].text = '10'
  }
]

$command["ALD"] = [
  '[内容]ALDで設定された周期呼び出しを停止させます
[文法]ALD [呼び出し関数]
[例文]ALD [alarm0] # [alarm0]の呼び出しを停止します
[補足]この関数を呼び出す前に目的のアラーム時間が来ても、関数の実行は停止します',
  0,
  "停止する呼び出し関数",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    128.times do |i|
      alarm_func = sprintf "[alarm%d]", i
      $command_entrys[0].items.add alarm_func
    end
  }
]
 
$command["CAL"] = [
  '[内容]整数の計算を行います
[文法]CAL 計算式(1回の計算のみ), 整数格納レジスタ
[例文]CAL 1+1, $I00 # $I00に2を代入します
[補足]計算式には整数レジスタや、RTCレジスタ($IAD(西暦), $IMONTH(月)..etcなども使用できます)',
  1,
  "計算式( +,-,*,/ )",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  },
  "整数格納レジスタ",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    for i in 0..99
      reg = sprintf "$I%02d", i
      $command_entrys[1].items.add reg
    end
  },
]

$command["CMP"] = [
  '[内容]整数の比較計算を行います。主にIFJで場合分けに使用します
[文法]CMP 比較式(1回の比較のみ), 真偽値格納レジスタ
[例文]CMP $I00 > 1, $B00 # $I00が1より大きい場合 $B00にTRUEを代入します
[補足]',
  1,
  "比較式( >,<,>=,<=,== )",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  },
  "真偽値格納レジスタ",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    for i in 0..99
      reg = sprintf "$B%02d", i
      $command_entrys[1].items.add reg
    end
  }
]

$command["STR"] = [
  '[内容]文字列の代入、連結を行います。
[文法]STR 文字列式, 文字列格納レジスタ
[例文]STR 今は%s時です:$IHOUR $S00 # %sに$IHOURの値が入り、その結果が$S00に格納されます
[補足]32文字以上の結果となる代入、連結はできません',
  1,
  "文字列式(%s:(代入整数),(文字列)+(文字列))",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  },
  "文字列格納レジスタ",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    for i in 0..19
      reg = sprintf "$S%02d", i
      $command_entrys[1].items.add reg
    end
  }
]

$command["IFJ"] = [
  '[内容]真偽値レジスタがTRUEの場合、指定ラベルにジャンプします
[文法]IFJ 真偽値レジスタ, ラベルネーム
[例文]IFJ $B00, label_test # $B00がTRUEの場合label_testにジャンプ
[補足]同一関数内のラベルのみ有効です。ラベルが存在しない場合はWarrningを表示し関数が終了します',
  1,
  "真偽値格納レジスタ",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..99
      reg = sprintf "$B%02d", i
      $command_entrys[0].items.add reg
    end
  },
  "飛び先のラベル",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
  }
]

$command["JMP"] = [
  '[内容]指定ラベルまで命令をジャンプさせます。
[文法]JMP ラベルネーム
[例文]JMP label_test
[補足]同一関数内のラベルのみ有効です。ラベルが存在しない場合はWarrningを表示し関数が終了します',
  0,
  "飛び先のラベル",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

$command["LAB"] = [
  '[内容]IFJ, JMPなどでジャンプする飛び先です
[文法]LAB ラベルネーム
[例文]LAB label_test  #名前には[*],[,],[#],[ ]など特殊文字は使用しないで下さい
[補足]同一関数内のみ有効です',
  0,
  "ラベルネーム",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

$command["SCO"] = [
  '[内容]8bitの値をシリアル出力します。
[文法]SCO 8bitの出力値
[例文]SCO 0x55
[補足]',
  0,
  "シリアル出力値(8bit)",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = '0x00'
  }
]


$command["SST"] = [
  '[内容]文字列を送信します
[文法]SST 文字列や文字列レジスタ
[例文]SST この文字を送信しますー
[補足]',
  0,
  "送信文字列",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

$command["PTO"] = [
  '[内容]8bitの値をポートから出力させます
[文法]PTO 8bitの出力値
[例文]PTO 0x55
[補足]',
  0,
  "ポート出力値(8bit)",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = '0x00'
  }
]

$command["VCC"] = [
  '[内容]TLKで男性の声、女性の声やスピードなど喋り方を変更します
[文法]VCC 男女音声, 読み方, アクセント, スピード, ボリューム
[例文]VCC FEMALE, BK, 10, *, 3
[補足]引数に「*」を指定すると前回の設定をそのまま使用出来ます
男女音声[ MALE(男性) | FEMALE(女性) | FEMALE2(女性) ]
読み方[ B (数字を分離読みします) | N(数字を自動判別して読みます) | K(記号を読みます) |A (英文字をアルファベット読みします) ]　(複数指定可能です)
アクセント[ 100( アクセントが強い ) ～ -100( アクセントが弱い ) ]
スピード[ 20( 早い ) ～ -20( 遅い ) ]
音のボリューム[ 8( 音が大きい) ～ -8( 消音 ) ]',
  4,
  "男女音声",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    $command_entrys[0].items.add "MALE"
    $command_entrys[0].items.add "FEMALE"
    $command_entrys[0].items.add "FEMALE2"
    $command_entrys[0].text = "MALE"
  },
  "読み方",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
    $command_entrys[1].text = "*"
  },
  "アクセント",
  Proc::new {|obj|
    $command_entrys[2] = Phi::ComboBox.new obj
    for i in -100..100 
      $command_entrys[2].items.add i.to_s
    end
    $command_entrys[2].text = "*"
  },
  "スピード",
  Proc::new {|obj|
    $command_entrys[3] = Phi::ComboBox.new obj
    for i in -20..20
      $command_entrys[3].items.add i.to_s
    end
    $command_entrys[3].text = "*"
  },
  "ボリューム",
  Proc::new {|obj|
    $command_entrys[4] = Phi::ComboBox.new obj
    for i in -8..8
      $command_entrys[4].items.add i.to_s
    end
    $command_entrys[4].text = "*"
  }
]

$command["RCC"] = [
  '[内容]音声認識のパラメータ調整を行います
[文法]VCC 認識成功レベル, リジェクトレベル, 終端検出時間, タイムアウト時間, 録音する音の大きさ
[例文]VCC , *, 30, 300, 5000, 3
[補足]引数に「*」を指定すると前回の設定をそのまま使用出来ます
認識成功スコア(20～140)　認識スコアが認識成功スコアに達した場合、認識成功となる　このスコアより低い場合は[recog_error]関数が起動されます。[recog_error]は認識成功スコアより低く、リジェクトスコアより高いスコアの場合のみ呼び出さる                                                 (現在設定しても無視されます)
リジェクトスコア(0～100) リジェクトスコアに認識スコアが達しなかった場合、無視される         (デフォルト設定30)
単語終端検出時間(1～10)[100ms] 単語を発音した後、音声の空白を確認し、認識作業を実行するまでの「音声の空白を確認する時間」。                                                                 (デフォルト設定300ms)
タイムアウト時間(10～10)[100ms] 単語の最大発音時間を設定。認識単語に長い言葉を認識させる場合は値を大きくしなければならない。逆に短い認識単語しか存在しなければ短く設定した方が認識率が良くなる。                                                                                    (デフォルト設定5000ms)
録音する音の大きさ( 0～15 ) 0で+0dB  15で最大+22.5dB にてマイク入力の調整を行います。(デフォルト設定5 (+7.5dB) )',
  4,
  "認識成功レベル",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 20..140
      $command_entrys[0].items.add i.to_s
    end
    $command_entrys[0].text = "*"
  },
  "リジェクトレベル",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    for i in 0..100 
      $command_entrys[1].items.add i.to_s
    end
    $command_entrys[1].text = "*"
  },
  "終端検出時間",
  Proc::new {|obj|
    $command_entrys[2] = Phi::Edit.new obj
    $command_entrys[2].text = "*"
  },
  "タイムアウト時間",
  Proc::new {|obj|
    $command_entrys[3] = Phi::Edit.new obj
    $command_entrys[3].text = "*"
  },
  "ボリューム",
  Proc::new {|obj|
    $command_entrys[4] = Phi::ComboBox.new obj
    for i in 0..15
      $command_entrys[4].items.add i.to_s
    end
    $command_entrys[4].text = "*"
  }
]

$command["RVC"] = [
  '[内容]音声認識の結果表示の変更
[文法]VCC RVC [認識結果の表示],[音声状態の表示],[認識スコアの表示], [レベルメータの表示], [認識候補数]
[例文]RVC TRUE, TRUE, TRUE, TRUE, 3  #認識単語候補を3つ表示する
[補足]通信LOGの表示にこの命令が反映されます。
認識結果の表示有無   (TRUE:表示させる FALSE:表示させない)   (デフォルト設定TRUE)
音声状態の表示有無　 (TRUE:表示させる FALSE:表示させない)   (デフォルト設定TRUE)
認識スコア表示の有無 (TRUE:表示させる FALSE:表示させない)   (デフォルト設定TRUE)
レベルメータの表示有無(TRUE:音声ボードにLEDレベルメータが表示  FALSE:表示しません) (デフォルト設定TRUE)
既存の設定を使用したい場合、引数に「*」を使用してください。
',
  4,
  "認識結果の表示",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    $command_entrys[0].items.add "TRUE"
    $command_entrys[0].items.add "FALSE"
    $command_entrys[0].items.add "*"
    $command_entrys[0].text = "*"
  },
  "音声状態の表示",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    $command_entrys[1].items.add "TRUE"
    $command_entrys[1].items.add "FALSE"
    $command_entrys[1].items.add "*"
    $command_entrys[1].text = "*"
  },
  "認識スコアの表示",
  Proc::new {|obj|
    $command_entrys[2] = Phi::ComboBox.new obj
    $command_entrys[2].items.add "TRUE"
    $command_entrys[2].items.add "FALSE"
    $command_entrys[2].items.add "*"
    $command_entrys[2].text = "*"
  },
  "レベルメータの表示",
  Proc::new {|obj|
    $command_entrys[3] = Phi::ComboBox.new obj
    $command_entrys[3].items.add "TRUE"
    $command_entrys[3].items.add "FALSE"
    $command_entrys[3].items.add "*"
    $command_entrys[3].text = "*"
  },
  "認識候補数",
  Proc::new {|obj|
    $command_entrys[4] = Phi::ComboBox.new obj
    for i in 1..5
      $command_entrys[4].items.add i.to_s
    end
    $command_entrys[4].text = "*"
  }
]


$command["FNC"] = [
  '[内容]定義したファンクションの呼び出しを行います
[文法]FNC 呼び出し関数
[例文]FNC [func_name]
[補足]関数の名前は必ず「[func_」を入れて「]」で閉じてください
日本語の名前も使用できますが、「#」「*」などは使用できません
',
  0,
  "呼び出し関数",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = "[func_name]"
  }
]

$command["PLY"] = [
  '[内容]設定したWAVファイルを再生する
[文法]PLY 再生ファイルインストール番号(0～3)
[例文1]PLY 1
[例文2]PLY install.wav
[補足]WAVファイルのインストールで転送を行ったファイルを再生
その場合ファイルネームを指定してもOK, インストール番号を指定してもOK
',
  0,
  "再生ファイル番号",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..3
      $command_entrys[0].items.add i.to_s
    end
    $command_entrys[0].text = "0"
  }
]

$command["STP"] = [
  '[内容]再生中のサウンドを停止する
[文法]STP SOUND
[例文]STP SOUND
[補足]
',
  0,
  "SOUND",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = "SOUND"
  }
]


$command["PRG"] = [
  '[内容]指定の認識時間のみ指定のテーブルの音声認識を行う
[文法]PRG [飛び先のテーブルリスト], 認識時間
[例文]PRG [recog3], 50    #5秒間 [recog3]の認識を行います
[補足]TBC同様、呼ばれた場所から認識が開始します。
認識作業が終了したら、PRG命令の下にある命令が実行されます
認識時間(10～100)[100ms]
もし認識時間の指定が無い場合はRCC命令で指定されたタイムアウト時間だけ
音声認識を行います.(デフォルト5秒)
',
  1,
  "飛び先のテーブル",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    $command_entrys[0].items.add "RETURN"
    RECOG_TABLE_MAX.times do |i|
      table_text = "[recog" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  },
  "認識時間(10～100)[100ms単位]",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
    $command_entrys[1].text = 50.to_s
  }
]

$command["EXC"] = [
  '[内容]文字列の命令を実行します
[文法]EXC 文字列及び文字列レジスタ
[例文]EXC $SSERIAL_STRING
[補足]EXC命令の多重呼び出し、LAB命令などは無効です。
',
  0,
  "呼び出し関数",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

