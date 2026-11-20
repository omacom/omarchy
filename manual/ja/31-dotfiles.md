# ドットファイル

Omarchy は主に `~/.config` にある、いわゆるドットファイルを通じて設定します。それらは、あなたが変更するための、あなたのファイルだと考えてください。`/usr/share/omarchy` にあるファイルは Omarchy 自体に属するもので、あなたが触るべきものではありません。`/usr/share/omarchy` の何かを変更する必要がある場合は、代わりに `~/.config` でその値を上書きすべきです。

主要な設定は Omarchy メニュー（`Super + Space`）から直接編集できます。たとえば _Setup > Keyboard > Keybindings_、_Setup > Input_、_Setup > Config > [file]_ などです。この方法で編集すると、設定の編集後に再起動が必要なプロセスは、エディタを終了したときに自動的に再起動します（デフォルトでは Neovim です — `:wq`、覚えていますね！ — ただし _Setup > Defaults > Editor_ で変更できます）。

`~/.config` にある主要なファイルと、それぞれが制御するもののリストは次のとおりです：

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | メインの Hyprland 設定です。Omarchy のデフォルトと、下記のあなたの上書きファイルを読み込みます。[Hyprland の設定について詳しく見る](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | あなた独自のキーバインドと、デフォルトの上書きです。 |
| `~/.config/hypr/monitors.lua` | 回転、追加のモード、モニターをオフのままにするなど、モニターパネルがカバーしないモニター設定です。 |
| `~/.config/hypr/input.lua` | キーボードレイアウト、マウス、トラックパッドの設定を制御します。 |
| `~/.config/hypr/looknfeel.lua` | ギャップ、ボーダー、アニメーション、その他の外観を制御します。 |
| `~/.config/hypr/autostart.lua` | セッションとともに開始する追加のプロセスを制御します。 |
| `~/.config/omarchy/shell.json` | Omarchy シェルを制御します：バーの位置、レイアウト、ウィジェットに加え、スクリーンセーバー、ロック、アイドルのタイミングです。 |
| `~/.config/foot/foot.ini` | ターミナルを制御します（foot がデフォルトです）。 |
| `~/.XCompose` | クイックアクセス用の絵文字と、名前/メールアドレスの自動補完を定義します。変更後は必ず `omarchy-restart-xcompose` を実行してください。 |

独自のセットアップを微調整するために多くの変更を加えることになった場合は、これらすべてのドットファイルをバックアップしておくのがよいでしょう。[Stow はそのための優れた方法です](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 独自のアプリをセッションとともに起動する

ログインするたびに何かを実行したい場合 — 同期デーモン、チャットアプリ、独自のスクリプトなど — は、`~/.config/hypr/autostart.lua` に入れます：

```lua
o.launch_on_start("my-service")
```

これにより、そのコマンドがセッションの一部として開始されるため、再度ログアウトしたときに適切にクリーンアップされます。

### システムイベントでスクリプトを実行する

Omarchy はいくつかのタイミングでフックを発火させ、そこに独自のスクリプトを掛けることができます。それらは `~/.config/omarchy/hooks/<event>.d/` にあり、イベントごとに 1 つのディレクトリがあり、`.sample` で終わらないその中のすべてのファイルが、イベント発生時に bash で実行されます：

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | デスクトップが起動した直後 |
| `post-update` | `omarchy update` の終了近く、パッケージ、マイグレーション、サービスの再起動の後、mise ツールが更新される前 |
| `pre-refresh-pacman` | `omarchy refresh pacman` がパッケージ設定を再同期した後、パッケージを更新する前；チャンネルの切り替えは、その同じ更新ステップ中にこれを実行します |
| `theme-set` | テーマの変更後（テーマ名は `$1`） |
| `font-set` | フォントの変更後（フォント名は `$1`） |
| `battery-low` | バッテリーが少なくなったとき（パーセンテージは `$1`） |

`pre-refresh-pacman` フックは、カスタムリポジトリや `IgnorePkg` 行を置く場所です。パッケージのトランザクションの前に実行されるためです。どちらもあなたのユーザーとして実行されます。`post-update` は、`omarchy update` の sudo 認証がまだ有効な間に実行されるため、`sudo` を使うフックでもパスワードを再度尋ねられません；`pre-refresh-pacman` は、`omarchy refresh pacman` 自体が sudo を使用した直後に実行されます。

これらの各ディレクトリにはすでに、フックの形を示す `.sample` ファイルが含まれています — 名前から `.sample` を外せば、それが使えるようになります。別の場所で書いたスクリプトをインストールするには、`omarchy hook install post-boot ~/my-hook` を使用します。これによりコピーされ、実行可能になります。

### 独自のメニュー項目を追加する

Omarchy メニュー（`Super + Space`）は、`~/.config/omarchy/extensions/omarchy-menu.jsonc` を編集することで、独自の行で拡張できます。項目はドット区切りの id でキー付けされ、その id がツリー内での配置を決めます。そのため `personal` はルートメニューに表示され、`personal.notes` はその中に表示されます：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

既存の id を再利用すると、新しい行を追加する代わりに、その行を上書きします。このファイルには、利用可能なすべてのフィールドがコメントとして文書化された状態で出荷されています。

### 独自のシェルエクスポート、関数、エイリアスを追加する

Omarchy には、使い勝手のよいエイリアスと便利な関数がたくさん同梱されていますが、独自のものを追加したくなることは非常によくあります。エイリアス、関数、エクスポートはすべて `~/.bashrc` に追加すべきです。このファイルはアップデートで上書きされません。Omarchy のデフォルトのいずれかを変更したい場合も、ここに安全に追加できます。

### デスクトップの環境変数を設定する

デスクトップセッションのエクスポートは `~/.config/uwsm/env.d/` に属します。これらのファイルはデスクトップが起動する前に実行されるため、シェルエラーがあるとログイン画面に送り返される可能性があります。編集している間は、動作するターミナルを開いたままにしてください。上書きを無効にするには、`env.d` から移動してください。変更によりログインできなくなった場合は、[ログインの復旧](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) を参照してください。

### Omarchy の内部ファイルを変更する

いいですか、これはあなたのコンピュータです。好きなようにできますが、`/usr/share/omarchy` のファイルに直接変更を加えるのはおすすめしません。それらは Omarchy の pacman パッケージに属しているため、あなたの変更は次回のアップデートで単に上書きされてしまいます。代わりに、気に入らないデフォルト値は `~/.config/*` フォルダで上書きするほうがずっとよいでしょう。

その方法で、デフォルトのキーバインドのような、ほぼすべてを変更できます。たとえば、`~/.config/hypr/bindings.lua` を編集して、[Obsidian](https://obsidian.md/) を [Joplin](https://joplinapp.org/) に置き換えます（`omarchy-pkg-add joplin-bin` でインストールします）：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` は、置き換えを追加する前に既存のバインドを削除します。これは、起動ヘルパーやバインドオプションを含め、`o.bind` と同じ引数を取ります。バインドを追加するには `o.bind` を使い、置き換えずに削除するには `hl.unbind` を使います。

どうしても Omarchy の内部ファイルをハックしたい場合は、_Update > Channel > Dev_ から dev チャンネルに切り替えてください。これにより Omarchy が `~/omarchy` にあるソースコードの git チェックアウトにリンクされ、心ゆくまで自由に変更できるようになります。ここであなたに指図する人間なんていません！

### 変更をリセットする

設定をめちゃくちゃにしてしまった場合は、Omarchy メニューの _Update > Config_ からいつでもデフォルトに戻すことができます。または、`omarchy reinstall configs` を実行してすべてをリセットすることもできます。
