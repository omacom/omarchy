# テーマ

Omarchyには23の美しいテーマが付属している。Omarchy Menu（`Super + Space`）の_外観 > テーマ_から選択できるほか、`Super + Ctrl + T`でテーマセレクターに直接移動することもできる。

各テーマは、デスクトップ、ターミナル、neovim、アクティビティ画面（btop）、ブラウザ（Chrome、Chromium、EdgeまたはBrave）、そしてトップバー、メニュー、通知、OSD、ロック画面を含むOmarchyシェル全体のスタイルを決める。（Obsidianについては、アプリ内の_外観 > テーマ_からOmarchyテーマを手動で選択する必要がある）。

テーマには背景画像のセットが用意されており、`Super + Ctrl + W`で切り替えることができる。

さらに多くのテーマは[追加のテーマページ](https://omarchy.org/themes/)で見つけることができるし、[独自のテーマを作る](43-making-your-own-theme.md)こともできる。

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### アプリアイコン

アプリランチャーやドックのアイコンはテーマの色で描画されるため、テーマと一緒に変わる。これらはアイコンセットによるもので、テーマとは別に_外観 > アイコン_から、テーマを選ぶのと同じように各セットのプレビューを見て選ぶ：

- _Papercraft_がデフォルトだ：インストールされているすべてのものが、1つのスタイルで描かれる。Chrome、HEY、YouTubeのようにロゴで知られるアプリは、その形を保ちながらテーマの色を取り入れる。
- _Arcade_は、同じアプリを昔のゲーム機のような8ビットのピクセルアートで描く。
- _Original_は、すべてのアプリをその製作者が用意したアイコンで表示する。

誰かが作ったアイコンセットは_インストール > スタイル > アイコン_（または`omarchy icons install <git url>`）でインストールでき、_削除 > アイコン_で再度削除できる。_更新 > 追加のアイコン_は、インストール済みのセットの最新バージョンを取得する。

独自のものを作るには、`~/.config/omarchy/icons/<name>/`にアイコンを置く。1アプリにつき1ファイルとし、アプリの`.desktop`ファイルの`Icon=`行にちなんで名前を付ける。`.svg`で終わるファイルはそのまま表示される。`.svg.tpl`で終わるファイルはテーマの色で描画される：色が入る場所に`{{ icon_main }}`、`{{ icon_mark }}`、`{{ icon_paper }}`、`{{ icon_body }}`、`{{ icon_edge }}`、`{{ icon_ink }}`、または`{{ icon_shadow }}`と書く。`/usr/share/omarchy/icons/papercraft/`にあるデフォルトセットは、良い出発点になる。ピッカーで自分のセットを表示するには`preview.png`を追加する；なければ、Omarchyがアイコンからプレビューを描く。デフォルトセットのアイコンを1つだけ変更するには、自分のバージョンを`~/.config/omarchy/icons/papercraft/`に置く。

### 起動とログイン

コンピューターの起動時にドライブのパスワードを求める画面と、ログイン画面もテーマに従う。テーマを切り替えるたびに、その背景、テキスト、アクセント、赤の色が反映されるため、ロック解除用のデザインを別に選ぶ必要はない。Apple Silicon Macでは、ドライブのパスワード画面はテーマにかかわらずOmarchyのデフォルトの見た目のままになる。
