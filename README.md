# ScriptGui
ruby gui(Apollo) scrpit(Voice Recognition/Voice Play scrpit)

実行にはApollo(http://www.moriq.com/apollo/)が必要となります。

組み込み用の音声認識、音声合成をスクリプト言語で組み込むためのGUIアプリケーションを作成
別途組み込み用の音声認識合成ボード(VoiceScript)が必要となります。
組み込み向けグラフィカルプログラミングの走りとなるGUIは当時(2003年)としては画期的だと思います。
マイコンのパワーとROM容量を極限まで減らすことができる仕組みとなっていました。

GUIプログラム
↓
Scriptプログラム
↓
組み込み形式に変換(ボード依存)
↓
実行(ボード依存)

というパターンで実行されます。
音声認識という場合分けが確定された処理を簡単にすることが目的でしたが
組み込みペリフェラルを共通概念としてGUIテンプレートに仕上げています。
