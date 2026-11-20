# FAQ

### キーボードレイアウトを切り替えるには？

`~/.config/hypr/input.lua` ファイルを編集し、`Left Alt + Right Alt` でレイアウトを切り替えられるよう以下を追加します:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

複数のレイアウトを設定すると、バーに現在のキーボードレイアウトが自動的に表示されます（クリックして切り替えることもできます）。

### 時計の形式を12時間表示に変更するには？

バーの時計を右クリックすると、12時間表示を含む一般的な形式を順に切り替えることができます。形式を直接設定することもできます:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

これにより 日曜日 10:55 AM と表示されます。

### タイムゾーンを変更するには？

Omarchy メニューで _Setup > Region > Timezone_ を実行し、リストから選択します。タイムゾーンは合っているのに時計自体がずれている場合は、_Update > Time_ で時刻同期を再起動してくれます。

### DNSを変更したり、Wi-Fiを共有したり、接続速度を確認したりするには？

それらはすべて[ネットワーク](35-networking.md)にあります。

### ディスクの速度を確認するには？

_Trigger > Speed Test > Disk Speed Test_ でドライブの現在の読み取り速度と書き込み速度を測定できます。ターミナルから `omarchy disk speedtest` を実行しても測定できます。

### プリンターを追加するには？

印刷は最初から設定済みで動作しており、各プリンターはアプリランチャー（`Super + Space`）の _Print Settings_ から自分で追加します。

_Add_ を選択し、しばらく検索を待ちます。USBで接続されたプリンターと、ほとんどのネットワークプリンターは自動的に見つかります。お使いのプリンターがリストにない場合は、_Network Printer > Internet Printing Protocol (ipp)_ を選択してそのアドレスを入力します — そのアドレスはプリンター本体のディスプレイやそのWebページで確認できます。通常は `192.168.1.50` のようなもので、キューは `ipp/print` です。_Forward_ を進めるとドライバーが提示されます。最新のプリンターではドライバーレスの _IPP Everywhere_ プロファイルが最適で、古いプリンターではそのモデル専用のドライバーが必要です。

プリンターを右クリックして _Set as Default_ を選択するとアプリが最初に使うプリンターを選べ、_Properties_ で用紙サイズ、両面印刷、品質を設定できます。

ネットワーク上のプリンターが追加なしで表示される自動検出は、改修中のため一時的にオフになっています。そのため、上記の最初の手順は自動ではなく手動で行う必要があります。PDFファイルへの印刷はプリンターがまったくなくても動作します。

### スクリーンショットや画面録画の保存先を変更するには？

保存されたスクリーンショットはデフォルトで `~/Pictures/Screenshots` に保存されます。別のディレクトリを使うには、`~/.config/uwsm/env.d/` 配下のファイル（`~/.config/uwsm/env.d/capture` など）に以下を追加します:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

画面録画についても `OMARCHY_SCREENRECORD_DIR` を使って同じことができます。

Omasnap はスクリーンショットのディレクトリを自動的に作成します。画面録画のディレクトリは自分で作成し、その後 Omarchy を再起動するとどちらの環境変更も有効になります。

### Apple Studio Display でスピーカーとウェブカメラを動作させるには？

USB C を差し込むだけで全部動くと思うでしょうが、残念ながらそうはいきません。確実に動作させるために私が見つけた解決策は、[WJESOG DisplayPort + USB-A => USB-C ケーブル](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)を使うことです。そうすればスピーカーとウェブカメラが嘘みたいに快調に動作します。

Apple Displays（Studio と XDR の両方）には Omarchy に内蔵の輝度コントロールがあり、通常のキーボードの輝度ボタンで使えることも覚えておいてください。

### 余分なソフトウェアをすべて取り除くには？

Obsidian や LibreOffice などのプリインストールされたものが不要なら、とても簡単に削除できます。

_Remove > Package_ を実行すると、インストールされているすべてのパッケージが表示されます。そして tab で削除したいパッケージを選択し、return で選択したすべての削除を開始できます。

また、Omarchy メニューから _Remove > Web App_ を使えば、不要なプリインストール済みWebアプリを削除できます。

あるいは _Remove > Preinstalls_ を実行すれば、プリインストールされた追加分 — Webアプリ、TUI、オプションのアプリケーション — を一度にまとめて削除できます。それらを起動していたホットキーも一緒に消えるので、`~/.config/hypr/bindings.lua` に自分のものを入れるためのまっさらなバインディングが残ります。

---

エラーや壊れた部分については、[トラブルシューティングのセクション](45-troubleshooting.md)を参照してください。
