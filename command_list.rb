#�����F�������G���W���AGUI�X�N���v�g�ݒ�c�[��
#
#    \file  :command_list.rb
#    \brief �X�N���v�g���߈ꗗ���w���v���b�Z�[�W
#
#    $Author: sugiura $
#    $Date: 2004/09/06 11:06:13 $
#    $Name:  $
#

#����
#�ꍇ�ɂ���Ă͕\�����Ȃ������������߂�����̂�
#�R�����g�A�E�g����ΑI���ł��Ȃ��Ȃ�
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

#�}���`�R�}���h�G���g���[BOX
#�{���̓O���[�o���ɂ���͕̂s�������A�t�@���N�V���������j�󏈗���
#��������܂ł̎ؒn�[�u

$command_entrys = []
$command_labels = []
$command = Hash::new

#  �w���v���b�Z�[�W, ���ߐ�(-1������, 0�`��1��), �����̓Y����, ���͈�����Proc
$command["TLK"] = [
  '[���e]�w��̕�����𒝂点�܂�
[���@]TLK �J�i��������, �����󔒎���(100ms�P��)
[�ᕶ1]TLK �����C�ł����H
[�ᕶ2]TLK ����ɂ��́B,5
[�⑫]�J�i���������̑���$S00�Ȃǂ̕����񃌃W�X�^���g�p���鎖���ł��܂�',
  1,
  "�J�i���������蕶����",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  },
  "��������̋󔒎���(100ms�P��)",
  Proc::new {|obj|
   $command_entrys[1] = Phi::ComboBox.new obj
    11.times do |i|
      $command_entrys[1].items.add i.to_s
    end
  }
]

$command["TKS"] = [
  '[���e]�w��̃V���{��������𒝂点�܂�
[���@]TKS �V���{��������
[�ᕶ]TKS simbol_string
[�⑫]�V���{��������͐�p�c�[���ɂč쐬����܂�',
  0,
  "�V���{��������",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

$command["TWT"] = [
  '[���e]�{�[�h���������̉��������F�����Ă��܂�����}�����܂�
[���@]TWT
[�ᕶ]TWT
[�⑫]TLK���߂͒���n�߂��r���Ŏ��̖��߂����s����܂��B
���̏ꍇ�A�����Ă���Œ��ɉ����F�����n�܂�\��������܂��B
���̖��߂�TLK���߂Œ��������t�����S�ɒ���I���܂őҋ@���܂��B
TLK���߂�PLY���߂̌�Ɏw�肵�ĉ�����',
  -1 
]

$command["TBC"] = [
  '[���e]���݂̔F���e�[�u������w��̔F���e�[�u���ɐ؂�ւ��܂�
[���@]TBC [��ѐ�̃e�[�u�����X�g] 
[�ᕶ]TBC [recog3]
[�⑫]RETURN��I������Ɣ�ь��̃e�[�u���ɖ߂�܂�.
TBC��ɏ����ꂽ���߂͔�ѐ��TBC RETRUN�����s���ꂽ��Ɏ��s����܂�',
  0,
  "��ѐ�̃e�[�u��",
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
  '[���e]�|�[�g���͂��������ꍇ�A�w��֐����Ăяo���A���߂����s���܂�
[���@]PIS [[port_in0�`31]�܂ł̌Ăѐ�], [�|�[�g�̎��PORT], [�|�[�g��v�l], [�Ăяo������], [�}�X�N�l]
[�ᕶ]PIS [port_in1], PORT, 0x00, TRUE, 0xfe
[�⑫]�|�[�g���������Q�Ƃ�������',
  4,
  "�Ăяo���|�[�g�֐�",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    32.times do |i|
      table_text = "[port_in" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  },
  "�|�[�g�̎��",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    $command_entrys[1].items.add "PORT"
    $command_entrys[1].items.add "SERIAL"
    $command_entrys[1].text = "PORT"
  },
  "�|�[�g��v�l",
  Proc::new {|obj|
    $command_entrys[2] = Phi::Edit.new obj, nil, '0x00'
  },
  "�Ăяo���ω�",
  Proc::new {|obj|
    $command_entrys[3] = Phi::ComboBox.new obj
    $command_entrys[3].items.add "TRUE"
    $command_entrys[3].items.add "FALSE"
    $command_entrys[3].items.add "CHANGE"
    $command_entrys[3].text = "TRUE"
  },
  "�}�X�N�l",
  Proc::new {|obj|
    $command_entrys[4] = Phi::Edit.new obj
    $command_entrys[4].text = '0x00'
  }
]

$command["PID"] = [
  '[���e]PIS�Őݒ肳�ꂽ�|�[�g�Ăяo�����~�����܂�
[���@]PID [[port_in0�`31]�܂ł̌Ăѐ�]
[�ᕶ]PID [port_in1]
[�⑫]���Ƀ|�[�g�֐������s��Ԃ̏ꍇ���A���s����~����܂�',
  0,
  "�Ăяo���|�[�g�֐�",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..31
      table_text = "[port_in" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  }
]

$command["PIV"] = [
  '[���e]���̓|�[�g�̌��݂̒l���擾���܂�
[���@]PIV �����i�[���W�X�^
[�ᕶ]PID $I00
[�⑫]',
  0,
  "�����i�[���W�X�^",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = "$I00"
  }
]


$command["CYS"] = [
  '[���e]�����I�Ɋ֐����Ăяo���A���߂����s���鎖���ł��܂�
[���@]CYS [�����I�ɌĂяo���֐�], �Ăяo������(100ms�P��)
[�ᕶ]CYS [cycle2], 10  # 1�b���� [cycle2]���Ăяo�������ł��܂�
[�⑫]�����Ăяo���֐��͑��̊֐������삵�Ă��鎞�͎��s����܂���B���̊֐��̓��삪������������s����܂�',
  1,
  "�����N���֐�",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..4
      table_text = "[cycle" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  },
  "�Ăяo������(100ms�P��)",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
    $command_entrys[1].text = '10'
  }
]

$command["CYD"] = [
  '[���e]CYS�Őݒ肳�ꂽ�����Ăяo�����~�����܂�
[���@]CYD [�����I�ɌĂяo���֐�]
[�ᕶ]CYD [cycle1] # [cycle1]�Ŏ����Ăяo�����~���܂�
[�⑫]���̊֐����Ăяo���O�ɖړI�̎����֐��̐ݒ���������Ă��A�����֐��̎��s�͒�~���܂�',
  0,
  "��~��������N���֐�",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..8
      table_text = "[cycle" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  }
]

$command["ALS"] = [
  '[���e]�w�莞�Ԍ�Ɋ֐����Ăяo���A���߂����s���鎖���ł��܂�
[���@]ALS [�Ăяo���֐�], �Ăяo������(100ms�P��)
[�ᕶ]ALS [alarm0], 10  # 1�b���� [alarm0]���Ăяo�������ł��܂�
[�⑫]�w�莞�Ԃ��o�������ɁA���̊֐������s���̏ꍇ�A���̊֐����I�����Ă���A���[���֐������s����܂�',
  1,
  "�Ăяo���֐�",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    128.times do |i|
      alarm_func = sprintf "[alarm%d]", i
      $command_entrys[0].items.add alarm_func
    end
  },
  "�Ăяo������(100ms�P��)",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
    $command_entrys[1].text = '10'
  }
]

$command["ALD"] = [
  '[���e]ALD�Őݒ肳�ꂽ�����Ăяo�����~�����܂�
[���@]ALD [�Ăяo���֐�]
[�ᕶ]ALD [alarm0] # [alarm0]�̌Ăяo�����~���܂�
[�⑫]���̊֐����Ăяo���O�ɖړI�̃A���[�����Ԃ����Ă��A�֐��̎��s�͒�~���܂�',
  0,
  "��~����Ăяo���֐�",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    128.times do |i|
      alarm_func = sprintf "[alarm%d]", i
      $command_entrys[0].items.add alarm_func
    end
  }
]
 
$command["CAL"] = [
  '[���e]�����̌v�Z���s���܂�
[���@]CAL �v�Z��(1��̌v�Z�̂�), �����i�[���W�X�^
[�ᕶ]CAL 1+1, $I00 # $I00��2�������܂�
[�⑫]�v�Z���ɂ͐������W�X�^��ARTC���W�X�^($IAD(����), $IMONTH(��)..etc�Ȃǂ��g�p�ł��܂�)',
  1,
  "�v�Z��( +,-,*,/ )",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  },
  "�����i�[���W�X�^",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    for i in 0..99
      reg = sprintf "$I%02d", i
      $command_entrys[1].items.add reg
    end
  },
]

$command["CMP"] = [
  '[���e]�����̔�r�v�Z���s���܂��B���IFJ�ŏꍇ�����Ɏg�p���܂�
[���@]CMP ��r��(1��̔�r�̂�), �^�U�l�i�[���W�X�^
[�ᕶ]CMP $I00 > 1, $B00 # $I00��1���傫���ꍇ $B00��TRUE�������܂�
[�⑫]',
  1,
  "��r��( >,<,>=,<=,== )",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  },
  "�^�U�l�i�[���W�X�^",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    for i in 0..99
      reg = sprintf "$B%02d", i
      $command_entrys[1].items.add reg
    end
  }
]

$command["STR"] = [
  '[���e]������̑���A�A�����s���܂��B
[���@]STR ������, ������i�[���W�X�^
[�ᕶ]STR ����%s���ł�:$IHOUR $S00 # %s��$IHOUR�̒l������A���̌��ʂ�$S00�Ɋi�[����܂�
[�⑫]32�����ȏ�̌��ʂƂȂ����A�A���͂ł��܂���',
  1,
  "������(%s:(�������),(������)+(������))",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  },
  "������i�[���W�X�^",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    for i in 0..19
      reg = sprintf "$S%02d", i
      $command_entrys[1].items.add reg
    end
  }
]

$command["IFJ"] = [
  '[���e]�^�U�l���W�X�^��TRUE�̏ꍇ�A�w�胉�x���ɃW�����v���܂�
[���@]IFJ �^�U�l���W�X�^, ���x���l�[��
[�ᕶ]IFJ $B00, label_test # $B00��TRUE�̏ꍇlabel_test�ɃW�����v
[�⑫]����֐����̃��x���̂ݗL���ł��B���x�������݂��Ȃ��ꍇ��Warrning��\�����֐����I�����܂�',
  1,
  "�^�U�l�i�[���W�X�^",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..99
      reg = sprintf "$B%02d", i
      $command_entrys[0].items.add reg
    end
  },
  "��ѐ�̃��x��",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
  }
]

$command["JMP"] = [
  '[���e]�w�胉�x���܂Ŗ��߂��W�����v�����܂��B
[���@]JMP ���x���l�[��
[�ᕶ]JMP label_test
[�⑫]����֐����̃��x���̂ݗL���ł��B���x�������݂��Ȃ��ꍇ��Warrning��\�����֐����I�����܂�',
  0,
  "��ѐ�̃��x��",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

$command["LAB"] = [
  '[���e]IFJ, JMP�ȂǂŃW�����v�����ѐ�ł�
[���@]LAB ���x���l�[��
[�ᕶ]LAB label_test  #���O�ɂ�[*],[,],[#],[ ]�ȂǓ��ꕶ���͎g�p���Ȃ��ŉ�����
[�⑫]����֐����̂ݗL���ł�',
  0,
  "���x���l�[��",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

$command["SCO"] = [
  '[���e]8bit�̒l���V���A���o�͂��܂��B
[���@]SCO 8bit�̏o�͒l
[�ᕶ]SCO 0x55
[�⑫]',
  0,
  "�V���A���o�͒l(8bit)",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = '0x00'
  }
]


$command["SST"] = [
  '[���e]������𑗐M���܂�
[���@]SST ������╶���񃌃W�X�^
[�ᕶ]SST ���̕����𑗐M���܂��[
[�⑫]',
  0,
  "���M������",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

$command["PTO"] = [
  '[���e]8bit�̒l���|�[�g����o�͂����܂�
[���@]PTO 8bit�̏o�͒l
[�ᕶ]PTO 0x55
[�⑫]',
  0,
  "�|�[�g�o�͒l(8bit)",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = '0x00'
  }
]

$command["VCC"] = [
  '[���e]TLK�Œj���̐��A�����̐���X�s�[�h�Ȃǒ������ύX���܂�
[���@]VCC �j������, �ǂݕ�, �A�N�Z���g, �X�s�[�h, �{�����[��
[�ᕶ]VCC FEMALE, BK, 10, *, 3
[�⑫]�����Ɂu*�v���w�肷��ƑO��̐ݒ�����̂܂܎g�p�o���܂�
�j������[ MALE(�j��) | FEMALE(����) | FEMALE2(����) ]
�ǂݕ�[ B (�����𕪗��ǂ݂��܂�) | N(�������������ʂ��ēǂ݂܂�) | K(�L����ǂ݂܂�) |A (�p�������A���t�@�x�b�g�ǂ݂��܂�) ]�@(�����w��\�ł�)
�A�N�Z���g[ 100( �A�N�Z���g������ ) �` -100( �A�N�Z���g���ア ) ]
�X�s�[�h[ 20( ���� ) �` -20( �x�� ) ]
���̃{�����[��[ 8( �����傫��) �` -8( ���� ) ]',
  4,
  "�j������",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    $command_entrys[0].items.add "MALE"
    $command_entrys[0].items.add "FEMALE"
    $command_entrys[0].items.add "FEMALE2"
    $command_entrys[0].text = "MALE"
  },
  "�ǂݕ�",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
    $command_entrys[1].text = "*"
  },
  "�A�N�Z���g",
  Proc::new {|obj|
    $command_entrys[2] = Phi::ComboBox.new obj
    for i in -100..100 
      $command_entrys[2].items.add i.to_s
    end
    $command_entrys[2].text = "*"
  },
  "�X�s�[�h",
  Proc::new {|obj|
    $command_entrys[3] = Phi::ComboBox.new obj
    for i in -20..20
      $command_entrys[3].items.add i.to_s
    end
    $command_entrys[3].text = "*"
  },
  "�{�����[��",
  Proc::new {|obj|
    $command_entrys[4] = Phi::ComboBox.new obj
    for i in -8..8
      $command_entrys[4].items.add i.to_s
    end
    $command_entrys[4].text = "*"
  }
]

$command["RCC"] = [
  '[���e]�����F���̃p�����[�^�������s���܂�
[���@]VCC �F���������x��, ���W�F�N�g���x��, �I�[���o����, �^�C���A�E�g����, �^�����鉹�̑傫��
[�ᕶ]VCC , *, 30, 300, 5000, 3
[�⑫]�����Ɂu*�v���w�肷��ƑO��̐ݒ�����̂܂܎g�p�o���܂�
�F�������X�R�A(20�`140)�@�F���X�R�A���F�������X�R�A�ɒB�����ꍇ�A�F�������ƂȂ�@���̃X�R�A���Ⴂ�ꍇ��[recog_error]�֐����N������܂��B[recog_error]�͔F�������X�R�A���Ⴍ�A���W�F�N�g�X�R�A��荂���X�R�A�̏ꍇ�̂݌Ăяo����                                                 (���ݐݒ肵�Ă���������܂�)
���W�F�N�g�X�R�A(0�`100) ���W�F�N�g�X�R�A�ɔF���X�R�A���B���Ȃ������ꍇ�A���������         (�f�t�H���g�ݒ�30)
�P��I�[���o����(1�`10)[100ms] �P��𔭉�������A�����̋󔒂��m�F���A�F����Ƃ����s����܂ł́u�����̋󔒂��m�F���鎞�ԁv�B                                                                 (�f�t�H���g�ݒ�300ms)
�^�C���A�E�g����(10�`10)[100ms] �P��̍ő唭�����Ԃ�ݒ�B�F���P��ɒ������t��F��������ꍇ�͒l��傫�����Ȃ���΂Ȃ�Ȃ��B�t�ɒZ���F���P�ꂵ�����݂��Ȃ���ΒZ���ݒ肵�������F�������ǂ��Ȃ�B                                                                                    (�f�t�H���g�ݒ�5000ms)
�^�����鉹�̑傫��( 0�`15 ) 0��+0dB  15�ōő�+22.5dB �ɂă}�C�N���͂̒������s���܂��B(�f�t�H���g�ݒ�5 (+7.5dB) )',
  4,
  "�F���������x��",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 20..140
      $command_entrys[0].items.add i.to_s
    end
    $command_entrys[0].text = "*"
  },
  "���W�F�N�g���x��",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    for i in 0..100 
      $command_entrys[1].items.add i.to_s
    end
    $command_entrys[1].text = "*"
  },
  "�I�[���o����",
  Proc::new {|obj|
    $command_entrys[2] = Phi::Edit.new obj
    $command_entrys[2].text = "*"
  },
  "�^�C���A�E�g����",
  Proc::new {|obj|
    $command_entrys[3] = Phi::Edit.new obj
    $command_entrys[3].text = "*"
  },
  "�{�����[��",
  Proc::new {|obj|
    $command_entrys[4] = Phi::ComboBox.new obj
    for i in 0..15
      $command_entrys[4].items.add i.to_s
    end
    $command_entrys[4].text = "*"
  }
]

$command["RVC"] = [
  '[���e]�����F���̌��ʕ\���̕ύX
[���@]VCC RVC [�F�����ʂ̕\��],[������Ԃ̕\��],[�F���X�R�A�̕\��], [���x�����[�^�̕\��], [�F����␔]
[�ᕶ]RVC TRUE, TRUE, TRUE, TRUE, 3  #�F���P�����3�\������
[�⑫]�ʐMLOG�̕\���ɂ��̖��߂����f����܂��B
�F�����ʂ̕\���L��   (TRUE:�\�������� FALSE:�\�������Ȃ�)   (�f�t�H���g�ݒ�TRUE)
������Ԃ̕\���L���@ (TRUE:�\�������� FALSE:�\�������Ȃ�)   (�f�t�H���g�ݒ�TRUE)
�F���X�R�A�\���̗L�� (TRUE:�\�������� FALSE:�\�������Ȃ�)   (�f�t�H���g�ݒ�TRUE)
���x�����[�^�̕\���L��(TRUE:�����{�[�h��LED���x�����[�^���\��  FALSE:�\�����܂���) (�f�t�H���g�ݒ�TRUE)
�����̐ݒ���g�p�������ꍇ�A�����Ɂu*�v���g�p���Ă��������B
',
  4,
  "�F�����ʂ̕\��",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    $command_entrys[0].items.add "TRUE"
    $command_entrys[0].items.add "FALSE"
    $command_entrys[0].items.add "*"
    $command_entrys[0].text = "*"
  },
  "������Ԃ̕\��",
  Proc::new {|obj|
    $command_entrys[1] = Phi::ComboBox.new obj
    $command_entrys[1].items.add "TRUE"
    $command_entrys[1].items.add "FALSE"
    $command_entrys[1].items.add "*"
    $command_entrys[1].text = "*"
  },
  "�F���X�R�A�̕\��",
  Proc::new {|obj|
    $command_entrys[2] = Phi::ComboBox.new obj
    $command_entrys[2].items.add "TRUE"
    $command_entrys[2].items.add "FALSE"
    $command_entrys[2].items.add "*"
    $command_entrys[2].text = "*"
  },
  "���x�����[�^�̕\��",
  Proc::new {|obj|
    $command_entrys[3] = Phi::ComboBox.new obj
    $command_entrys[3].items.add "TRUE"
    $command_entrys[3].items.add "FALSE"
    $command_entrys[3].items.add "*"
    $command_entrys[3].text = "*"
  },
  "�F����␔",
  Proc::new {|obj|
    $command_entrys[4] = Phi::ComboBox.new obj
    for i in 1..5
      $command_entrys[4].items.add i.to_s
    end
    $command_entrys[4].text = "*"
  }
]


$command["FNC"] = [
  '[���e]��`�����t�@���N�V�����̌Ăяo�����s���܂�
[���@]FNC �Ăяo���֐�
[�ᕶ]FNC [func_name]
[�⑫]�֐��̖��O�͕K���u[func_�v�����āu]�v�ŕ��Ă�������
���{��̖��O���g�p�ł��܂����A�u#�v�u*�v�Ȃǂ͎g�p�ł��܂���
',
  0,
  "�Ăяo���֐�",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = "[func_name]"
  }
]

$command["PLY"] = [
  '[���e]�ݒ肵��WAV�t�@�C�����Đ�����
[���@]PLY �Đ��t�@�C���C���X�g�[���ԍ�(0�`3)
[�ᕶ1]PLY 1
[�ᕶ2]PLY install.wav
[�⑫]WAV�t�@�C���̃C���X�g�[���œ]�����s�����t�@�C�����Đ�
���̏ꍇ�t�@�C���l�[�����w�肵�Ă�OK, �C���X�g�[���ԍ����w�肵�Ă�OK
',
  0,
  "�Đ��t�@�C���ԍ�",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    for i in 0..3
      $command_entrys[0].items.add i.to_s
    end
    $command_entrys[0].text = "0"
  }
]

$command["STP"] = [
  '[���e]�Đ����̃T�E���h���~����
[���@]STP SOUND
[�ᕶ]STP SOUND
[�⑫]
',
  0,
  "SOUND",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
    $command_entrys[0].text = "SOUND"
  }
]


$command["PRG"] = [
  '[���e]�w��̔F�����Ԃ̂ݎw��̃e�[�u���̉����F�����s��
[���@]PRG [��ѐ�̃e�[�u�����X�g], �F������
[�ᕶ]PRG [recog3], 50    #5�b�� [recog3]�̔F�����s���܂�
[�⑫]TBC���l�A�Ă΂ꂽ�ꏊ����F�����J�n���܂��B
�F����Ƃ��I��������APRG���߂̉��ɂ��閽�߂����s����܂�
�F������(10�`100)[100ms]
�����F�����Ԃ̎w�肪�����ꍇ��RCC���߂Ŏw�肳�ꂽ�^�C���A�E�g���Ԃ���
�����F�����s���܂�.(�f�t�H���g5�b)
',
  1,
  "��ѐ�̃e�[�u��",
  Proc::new {|obj|
    $command_entrys[0] = Phi::ComboBox.new obj
    $command_entrys[0].items.add "RETURN"
    RECOG_TABLE_MAX.times do |i|
      table_text = "[recog" + i.to_s + "]"
      $command_entrys[0].items.add table_text
    end
  },
  "�F������(10�`100)[100ms�P��]",
  Proc::new {|obj|
    $command_entrys[1] = Phi::Edit.new obj
    $command_entrys[1].text = 50.to_s
  }
]

$command["EXC"] = [
  '[���e]������̖��߂����s���܂�
[���@]EXC ������y�ѕ����񃌃W�X�^
[�ᕶ]EXC $SSERIAL_STRING
[�⑫]EXC���߂̑��d�Ăяo���ALAB���߂Ȃǂ͖����ł��B
',
  0,
  "�Ăяo���֐�",
  Proc::new {|obj|
    $command_entrys[0] = Phi::Edit.new obj
  }
]

