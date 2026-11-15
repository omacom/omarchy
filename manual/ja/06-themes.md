# テーマ

Omarchy には22の美しいテーマが付属しています。Omarchy Menu（`Super + Space`）の _外観 > テーマ_ から選択できますし、`Super + Ctrl + T` でテーマセレクターに直接移動することもできます。

各テーマは、デスクトップ、ターミナル、neovim、アクティビティ画面（btop）、Chromium、そしてトップバー、メニュー、通知、OSD、ロック画面といった Omarchy シェル全体のスタイルを設定します。（Obsidian については、アプリ内の _外観 > テーマ_ から Omarchy テーマを手動で選択する必要があります）。

テーマには背景画像のセットが用意されており、`Super + Ctrl + W` を使って切り替えられます。

さらに多くのテーマは[追加テーマのページ](https://omarchy.org/themes/)で見つけることができ、[独自のテーマを作成](43-making-your-own-theme.md)することもできます。

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

### アプリのアイコン

アプリランチャーやドックのアイコンはテーマの色で描かれるため、テーマと一緒に変わります。これらはアイコンセットから来ており、テーマとは別に _外観 > アイコン_ で選択します：

- _Papercraft_ がデフォルトです：インストールされているすべてのものが、ひとつのスタイルで描かれます。Chrome、HEY、YouTube のようにロゴで知られるアプリは、その形を保ちながらテーマの色を取り入れます。
- _Arcade_ は同じアプリを、古いゲームコンソールのような8ビットのピクセルアートで描きます。
- _Original_ はすべてのアプリを、その製作者が用意したアイコンで表示します。

他の誰かが作ったアイコンセットは、_インストール > スタイル > アイコン_（または `omarchy icons install <git url>`）でインストールでき、_削除 > アイコン_ で再び削除できます。_アップデート > 追加アイコン_ は、インストール済みのセットの最新バージョンを取得します。

独自のアイコンを作るには、アイコンを `~/.config/omarchy/icons/<name>/` に置き、アプリごとに1ファイル、アプリの `.desktop` ファイルの `Icon=` 行にちなんで名前を付けます。`.svg` で終わるファイルはそのまま表示されます。`.svg.tpl` で終わるファイルはテーマの色で描かれます：色が入る場所に `{{ icon_main }}`、`{{ icon_mark }}`、`{{ icon_paper }}`、`{{ icon_body }}`、`{{ icon_edge }}`、`{{ icon_ink }}`、または `{{ icon_shadow }}` と書いてください。`/usr/share/omarchy/icons/papercraft/` にあるデフォルトセットは、出発点として最適です。デフォルトセットのアイコンをひとつだけ変更するには、自分のバージョンを `~/.config/omarchy/icons/papercraft/` に置いてください。

### アンロック画面

テーマにはカスタムのアンロックデザインも用意でき、これはブート時の復号プロセスに使用されます。そのひとつを _外観 > アンロック_ で選択できます。次のような見た目です：

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
