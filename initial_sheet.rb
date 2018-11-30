#初期化設定登録用シート
#
#    $Author: sugiura $
#    $Date: 2004/08/31 11:11:32 $
#    $Name:  $
#
#
$KCODE = "SJIS"

#[initialize]関数シート
class InitialFuncSheet <  ActionSheet
  def initialize pc, fs, name
    super pc, fs, name
    #paramater
    @flbox.hide
    panel =Phi::GroupBox.new @funcbox, :main_panel, '初期設定'
    panel.align = AL_LEFT
    add_func '[initialize]'
  end

  def get_script
    #ゴミが添付してしまう問題を解決するための対応
    num = @flbox.items.index_of '[initialize'
    if num != -1
      @flbox.items.delete num
    end
    text = super
    return text
  end

  def load ps
    add_func '[initialize]'
    super ps
  end

  #<PSstorにて保存>
  def save ps
    ps[self.caption] = @flbox.items.text
    save_text = self.caption + "0".to_s
    ps[save_text] = @comlboxs[0].items.text
  end
end
