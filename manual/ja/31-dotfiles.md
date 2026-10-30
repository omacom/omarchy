# Dotfiles

Omarchy は主に `~/.config` にある、いわゆる dotfiles を通じて設定されます。それらへの変更はあなたのファイルとして扱われます。`/usr/share/omarchy` にあるファイルは Omarchy 自体に属し、それらをいじるべきではありません。`/usr/share/omarchy` の中の何かを変更する必要がある場合、代わりに `~/.config` の値で上書きすべきです。

主要設定は Omarchy メニュー（`Super + Space`）から直接編集できます。たとえば _設定 > Monitors_、_設定 > Keybindings_、_設定 > Input_、_設定 > Config > [file]_ です。この方法で編集した場合、編集後に再起動が必要なプロセスは、エディタを終了した後に自動で再起動します（デフォルトは Neovim です — `:wq` ですよ、忘れずに！ — ただし _設定 > Defaults > Editor_ 経由で変更できます）。

`~/.config` の主要ファイルと、それらが制御する内容の一覧を以下に示します：

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | 主要な Hyprland 設定です。Omarchy デフォルトに加え、以下の上書きファイルを読み込みます。[Hyprland 設定についてさらに詳しく](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | あなた独自のキーバインドと、デフォルトの上書きです。 |
| `~/.config/hypr/monitors.lua` | モニター、解像度、位置を制御します。 |
| `~/.config/hypr/input.lua` | キーボード配列、マウス、トラックパッド設定を制御します。 |
| `~/.config/hypr/looknfeel.lua` | ギャップ、ボーダー、アニメーション、その他の見た目を制御します。 |
| `~/.config/hypr/autostart.lua` | セッションとともに起動する追加プロセスを制御します。 |
| `~/.config/omarchy/shell.json` | Omarchy シェルを制御します：バーの位置、レイアウト、ウィジェットに加え、スクリーンセーバー、ロック、アイドルのタイミングです。 |
| `~/.config/foot/foot.ini` | あなたのターミナルを制御します（foot がデフォルトです）。 |
| `~/.XCompose` | クイックアクセス用の絵文字と、名前／メールの自動補完を定義します。変更後に `omarchy-restart-xcompose` を実行するようにしてください。 |

自分のセットアップを微調整するために最終的に多くの変更を行うようであれば、これらの dotfiles すべてをバックアップするのは良い考えです。[Stow はそのための優れた方法です](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### セッションとともに独自のアプリを開始する

ログインのたびに何かを実行したい場合 — 同期デーモン、チャットアプリ、独自のスクリプト — `~/.config/hypr/autostart.lua` に入れます：

```lua
o.launch_on_start("my-service")
```

これにより、そのコマンドがセッションの一部として開始します。そのためログアウトし直したときに適切にクリーンアップされます。

### システムイベントでスクリプトを実行する

Omarchy は限られた瞬間にフックを発火し、あなたは自分のスクリプトをそこに掛けることができます。それらは `~/.config/omarchy/hooks/<event>.d/` に存在し、1イベントにつき1ディレクトリで、その中のすべての実行可能ファイルがイベントの発生時に実行されます：

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | デスクトップが起動した直後 |
| `post-update` | `omarchy update` の終わり近く、パッケージ、マイグレーション、サービスの再起動の後で、mise ツールが更新される前 |
| `pre-refresh-pacman` | `omarchy refresh pacman` がパッケージ設定を再同期した後、パッケージを更新する前；チャネル切り替えはその同じリフレッシュステップ中にこれを実行します |
| `theme-set` | テーマ変更の後（テーマ名が `$1` に入ります） |
| `font-set` | フォント変更の後（フォント名が `$1` に入ります） |
| `battery-low` | バッテリーが低下したとき（パーセンテージが `$1` に入ります） |

`pre-refresh-pacman` フックは、カスタムリポジトリや `IgnorePkg` 行が属すべき場所です。パッケージトランザクションの前に実行されるためです。更新関連の2つのフックは、Omarchy がキャッシュ済みの sudo 許可をクリアした後にあなたのユーザーとして実行されます。そのため `sudo` を使うフックは独自の許可を必要とし、パスワードを求める場合があります。

それらのディレクトリの各々にはすでに、フックの形を示す `.sample` ファイルが保有されています — 名前から `.sample` を落とせば働くようになります。どこかで書いたスクリプトをインストールするには、`omarchy hook install post-boot ~/my-hook` を使ってください。これがそれをコピーして実行可能にします。

### 独自のメニューエントリを追加する

Omarchy メニュー（`Super + Space`）は、`~/.config/omarchy/extensions/omarchy-menu.jsonc` を編集して自分自身の行で拡張できます。エントリはドット付き id をキーとし、その id がツリー内での位置を決めます。そのため `personal` はルートメニューに現れ、`personal.notes` はその中現れます：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

既存の id を再利用すると、新しい行を追加する代わりにその行を上書きします。ファイルには利用可能なすべてのフィールドがコメントとして同梱されています。

### 独自のシェル export、関数、エイリアスを追加する

Omarchy には人間工学的なエイリアスと便利な関数がたくさん同梱されていますが、自分自身のものを追加したくなるのはとても一般的です。エイリアス、関数、export はいずれも `~/.bashrc` に追加すべきです。このファイルは更新で上書きされません。Omarchy デフォルトのいずれかを変更したい場合も、ここへ安全に追加できます。

### 内部の Omarchy ファイルを変更する

いいですか、これはあなたのコンピュータです。やりたいようにできますが、`/usr/share/omarchy` のファイルに直接変更を加えることはおすすめしません。それらは Omarchy の pacman パッケージに属し、あなたの変更は次の更新で上書きされてしまうからです。代わりに `~/.config/*` フォルダで、好きでないデフォルト値を上書きする方が良いでしょう。

デフォルトのキーバインドのよう、ほとんどすべてをその方法で変更できます。`~/.config/hypr/bindings.lua` を編集して、たとえば [Obsidian](https://obsidian.md/) を [Joplin](https://joplinapp.org/)（`omarchy-pkg-add joplin-bin` でインストール）に置き換えます：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` は既存のバインドを取り除いてから置換を追加します。起動ヘルパーやバインドオプションを含め、`o.bind` と同じ引数を取ります。バインドを追加するには `o.bind` を、置換せずに削除するには `hl.unbind` を使ってください。

内部の Omarchy ファイルに手を入れることに固執するなら、_更新 > Channel > Dev_ で dev チャネルに切り替えてください。それにより Omarchy は `~/omarchy` にあるソースコードの git チェックアウトにリンクされ、心ゆくまで自由に変更できます。ここでは誰も指図してくれません！

### すべての変更をリセットする

設定を台無しにしてしまった場合、Omarchy メニューの _更新 > Config_ 経由でデフォルトへいつでも戻せます。あるいは `omarchy reinstall configs` を実行してすべてをリセットしてください。
