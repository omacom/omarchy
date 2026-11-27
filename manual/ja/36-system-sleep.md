# システムのスリープ

Omarchy はデフォルトでサスペンドを有効にし、セットアップすればハイバネーションも有効にするが、自分のマシンでどちらかに問題がある場合は、オフに切り替えることができる。

DGX Spark や ASUS Ascent GX10 などの NVIDIA GB10 マシンでは、NVIDIA の DGX OS と同様に、サスペンドとハイバネーションはオフになっている。あのハードウェアではスリープが動作することがまだ確認されていないからだ。ASUS Zenbook A16 (UX3607OA) も同じで、サスペンドではまだチップが完全にスリープせず、夜間にハングすることがある。そこではサスペンドの切り替えとハイバネーションのセットアップは適用されない。スリープを再びオンにするには、`sudo rm` で `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` を削除する。すると Suspend がメニューに戻り、他のマシンと同様にハイバネーションをセットアップできるようになる。`sudo omarchy apply hardware --install-user "$USER"` を実行すると、そのファイルが元に戻る。

### 電源プロファイル

ノートパソコンでは、Omarchy は電源に接続しているときとバッテリーで動作しているときの電源プロファイルを別々に記憶し、接続したり取り外したりするのに合わせて両者を切り替える。初期状態では、AC 電源では performance、バッテリーでは balanced になる。

自分のマシンで何が使えるかは `omarchy powerprofiles list` で確認でき、今いる状態に使いたいものは `omarchy powerprofiles set autodetect power-saver` で設定できる。何も取り外さずにもう一方の状態を設定するには、直接名前を指定する：`omarchy powerprofiles set battery power-saver`。選んだものが、次にその状態になったときに再び適用される。

### サスペンドの切り替え

サスペンドは、ターミナルから `omarchy toggle suspend` を実行して切り替える。それは単に _System_（または `Super + Esc`）の下にあるオプションを表示／非表示にするだけなので、自分のシステムで安定して動作するか確認できる。動作しなければ、同じコマンドで再び非表示にできる。

### ハイバネーションの切り替え

ハイバネーションは、ターミナルから `omarchy hibernation setup` を実行してセットアップする（Apple Silicon Mac では利用できない）。ハイバネーションは、物理 RAM 割り当てと同じサイズの /swap サブボリュームをブートドライブ上に作成するので、十分な空き容量があることを確認すること。32GB のマシンでは、このボリュームのために常に 32GB 以上の空き容量が必要になる。ハイバネーションには、デフォルトの Limine ブートローダーも必要だ。

セットアップすると、_System_（または `Super + Esc`）の下に hibernate オプションが表示されるので、自分のシステムで安定して動作するか確認できる。動作しなければ、`omarchy hibernation remove` を実行して再び削除できる。
