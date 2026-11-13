# FAQ

### キーボードレイアウトを切り替えるには？

`~/.config/hypr/input.lua` ファイルを編集し、`Left Alt + Right Alt` でレイアウトを切り替えられるように次を追加します:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

複数のレイアウトを設定すると、バーに現在のキーボードレイアウトが自動で表示されます（クリックして切り替えることもできます）。

### 時計の形式を12時間制に変えるには？

バーの時計を右クリックすると、12時間制を含む一般的な形式を順に切り替えられます。形式を直接設定することもできます:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

これで 日曜日 10:55 AM と表示されます。

### タイムゾーンを変更するには？

Omarchy メニューで _Update > Timezone_ を実行し、一覧から選びます。タイムゾーンは合っているのに時計自体がずれている場合は、_Update > Time_ で時刻同期を再起動できます。

### DNS を変更したり、Wi-Fi を共有したり、接続速度を確認したりするには？

それらはすべて [ネットワーク](35-networking.md) にあります。

### ディスクの速度を確認するには？

_Trigger > Speed Test > Disk Speed Test_ でドライブの読み取り速度と書き込み速度をリアルタイムに測定できます。ターミナルから `omarchy disk speedtest` を実行しても構いません。

### プリンターを追加するには？

印刷は最初から設定済みで動作しています。各プリンターはアプリランチャー（`Super + Space`）の _Print Settings_ から自分で追加します。

_Add_ を選び、検索が終わるまで少し待ちます。USB で接続されたプリンターや、ほとんどのネットワークプリンターは自動で見つかります。使っているプリンターが一覧にない場合は、_Network Printer > Internet Printing Protocol (ipp)_ を選び、そのアドレスを入力します。アドレスはプリンター本体のディスプレイやその Web ページで確認でき、通常は `192.168.1.50` のようなアドレスで、キューは `ipp/print` です。次に _Forward_ でドライバーが提示されます。最近のプリンターはドライバー不要の _IPP Everywhere_ プロファイルが最適で、古いプリンターはそのモデル専用のドライバーが必要です。

プリンターを右クリックして _Set as Default_ を選ぶとアプリが最初に使うプリンターを指定でき、_Properties_ では用紙サイズ、両面印刷、品質を設定できます。

ネットワーク上のプリンターを追加しなくても表示される自動検出は、作り直し中のため一時的に無効になっています。そのため、上の最初の手順は自動ではなく手動で行います。PDF ファイルへの印刷は、プリンターがまったくなくても動作します。

### スクリーンショットや画面録画の保存先を変更するには？

保存されたスクリーンショットは、デフォルトで `~/Pictures/Screenshots` に入ります。別のディレクトリを使うには、`~/.config/uwsm/env.d/` 配下のファイル（`~/.config/uwsm/env.d/capture` など）に次を追加します:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

画面録画についても `OMARCHY_SCREENRECORD_DIR` を使って同じことができます。

Omasnap はスクリーンショット用ディレクトリを自動で作成します。画面録画用ディレクトリは自分で作成し、どちらの環境変更も反映させるために Omarchy を再起動してください。

### Apple Studio Display のスピーカーと Web カメラを使えるようにするには？

USB C を差すだけで全部動くと思いがちですが、残念ながらそうはいきません。確実に動かすために私が見つけた解決策は、[WJESOG DisplayPort + USB-A => USB-C ケーブル](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) を使うことです。そうすればスピーカーも Web カメラも見事に動作します。

Apple Displays（Studio と XDR の両方）については、Omarchy に輝度コントロールが組み込まれていて、通常のキーボードの輝度ボタンで操作できることも覚えておいてください。

### 余分なソフトウェアを全部取り除くには？

Obsidian や LibreOffice のようなプログラム、その他のプリインストールされたものが不要なら、とても簡単に削除できます。

_Remove > Package_ を実行すると、インストールされているすべてのパッケージが表示されます。削除したいパッケージは tab で選択し、return で選択したものをすべて削除し始められます。

不要なプリインストール済み Web アプリは、Omarchy メニューの _Remove > Web App_ から削除できます。

あるいは _Remove > Preinstalls_ を実行すれば、プリインストールされた余分なもの — Web アプリ、TUIs、オプションのアプリケーション — を一度に一掃できます。それらを起動していたホットキーも一緒に消えるので、`~/.config/hypr/bindings.lua` には自分のものを入れるためのまっさらなバインディングが残ります。

---

エラーや壊れた部分については、[トラブルシューティングのセクション](45-troubleshooting.md) を参照してください。
