# テーマ

Omarchy には22種類の美しいテーマが付属しています。Omarchy Menu（`Super + Space`）の _Appearance > Theme_ から選択することも、`Super + Ctrl + T` でテーマセレクターに直接移動することもできます。

各テーマはデスクトップ、ターミナル、neovim、アクティビティ画面（btop）、Chromium、そしてトップバー、メニュー、通知、OSD、ロック画面を含む Omarchy シェル全体のスタイルを決定します。（Obsidian については、アプリ内の _Appearance > Themes_ から Omarchy テーマを手動で選択する必要があります）。

テーマには背景画像のセットがあり、`Super + Ctrl + W` を使って切り替えることができます。

さらに多くのテーマは[追加テーマのページ](https://omarchy.org/themes/)で見つけることも、[自分でテーマを作成する](43-making-your-own-theme.md)こともできます。

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

### アプリアイコン

アプリランチャーとドックのアイコンは使用中のテーマの色で描画されるため、テーマと一緒に変わります。これらはアイコンセットから提供され、_Appearance > Icons_ でテーマとは別に選択できます。各セットのプレビューから、テーマを選ぶのと同じ方法で選択します。

- _Papercraft_ がデフォルトです。インストールされているすべてのものが1つのスタイルで描画されます。Chrome、HEY、YouTube のようにロゴで知られているアプリは、その形を維持したままテーマの色になります。
- _Arcade_ は同じアプリを、昔のゲーム機のような8ビットのピクセルアートとして描画します。
- _Original_ はすべてのアプリを、その製作者が用意したアイコンで表示します。

他の人が作成したアイコンセットは _Install > Style > Icons_（または `omarchy icons install <git url>`）でインストールでき、_Remove > Icons_ で再び削除できます。_Update > Extra Icons_ はインストール済みのセットの最新バージョンを取得します。

自分で作成するには、アイコンを `~/.config/omarchy/icons/<name>/` に配置します。アプリごとに1ファイルとし、アプリの `.desktop` ファイルの `Icon=` 行に合わせて名前を付けます。`.svg` で終わるファイルはそのまま表示されます。`.svg.tpl` で終わるファイルはテーマの色で描画されます。色を指定する場所に `{{ icon_main }}`、`{{ icon_mark }}`、`{{ icon_paper }}`、`{{ icon_body }}`、`{{ icon_edge }}`、`{{ icon_ink }}`、または `{{ icon_shadow }}` と記述します。`/usr/share/omarchy/icons/papercraft/` にあるデフォルトセットは、作成を始めるのに適した出発点です。`preview.png` を追加すると、ピッカーに自分のセットを表示できます。ない場合は、Omarchy があなたのアイコンからプレビューを描画します。デフォルトセットのアイコンを1つだけ変更するには、自分のバージョンを `~/.config/omarchy/icons/papercraft/` に配置します。

### ロック解除

テーマにはカスタムのロック解除デザインも用意でき、ブート時の復号プロセスに使用されます。これらは _Appearance > Unlock_ で選択できます。見た目は次のとおりです。

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
