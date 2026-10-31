# ドットファイル

Omarchy は主に、`~/.config` にあるいわゆるドットファイルを通じて設定する。それらは、君が変更を加えるための君のファイルだと考えられている。`/usr/share/omarchy` にあるファイルは Omarchy 自体に属するもので、君が手を出すべきものではない。`/usr/share/omarchy` の何かを変更する必要があるなら、代わりに `~/.config` でその値を上書きすべきだ。

主要な設定は、_Setup > Keybindings_、_Setup > Input_、_Setup > Config > [file]_ のように、Omarchy メニュー（`Super + Space`）から直接編集できる。この方法で編集すると、設定の編集後に再起動が必要なプロセスは、エディタを終了した後に自動で再起動される（デフォルトは Neovim — `:wq`、覚えておくこと！ — だが、_Setup > Defaults > Editor_ から変更できる）。

以下は `~/.config` の主要ファイルと、それぞれが制御するものの一覧だ：

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprland のメイン設定。Omarchy のデフォルトに加え、以下の自分の上書きファイルを読み込む。[Hyprland の設定について詳しく見る](https://wiki.hypr.land/Configuring/)。  |
| `~/.config/hypr/bindings.lua` | 自分のキーバインドと、デフォルトの上書き。 |
| `~/.config/hypr/monitors.lua` | モニターパネルでは扱えないモニター設定。回転、追加モード、モニターをオフのままにするなど。 |
| `~/.config/hypr/input.lua` | キーボードレイアウト、マウス、トラックパッドの設定を制御する。 |
| `~/.config/hypr/looknfeel.lua` | ギャップ、ボーダー、アニメーション、その他の見た目を制御する。 |
| `~/.config/hypr/autostart.lua` | セッションと一緒に起動する追加プロセスを制御する。 |
| `~/.config/omarchy/shell.json` | Omarchy シェルを制御する：バーの位置、レイアウト、ウィジェットに加え、スクリーンセーバー、ロック、アイドル時間。 |
| `~/.config/foot/foot.ini` | ターミナルを制御する（デフォルトは foot）。 |
| `~/.XCompose` | クイックアクセス用の絵文字と、名前／メールの自動補完を定義する。変更後は必ず `omarchy-restart-xcompose` を実行すること。 |

自分のセットアップを調整するためにたくさん変更するようになったら、これらのドットファイルをすべてバックアップしておくといい。[Stow はそのための優れた方法だ](https://www.youtube.com/watch?v=NoFiYOqnC4o)。

### 自分のアプリをセッションと一緒に起動する

ログインするたびに何かを実行したいなら — 同期デーモン、チャットアプリ、自分のスクリプトなど — それを `~/.config/hypr/autostart.lua` に置く：

```lua
o.launch_on_start("my-service")
```

これによりコマンドはセッションの一部として起動するので、再びログアウトしたときにきちんとクリーンアップされる。

### システムイベントでスクリプトを実行する

Omarchy はいくつかのタイミングでフックを発火させる。そこに自分のスクリプトを引っかけられる。フックは `~/.config/omarchy/hooks/<event>.d/` にあり、イベントごとに1つのディレクトリがある。イベントが発生すると、その中にある実行可能なファイルがすべて実行される：

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | デスクトップが起動した直後 |
| `post-update` | `omarchy update` の終盤、パッケージ、マイグレーション、サービスの再起動の後、mise ツールが更新される前 |
| `pre-refresh-pacman` | `omarchy refresh pacman` がパッケージ設定を再同期した後、パッケージを更新する前；チャンネル切り替えでは、その同じ refresh ステップ中に実行される |
| `theme-set` | テーマ変更の後（テーマ名は `$1`） |
| `font-set` | フォント変更の後（フォント名は `$1`） |
| `battery-low` | バッテリーが少なくなったとき（パーセンテージは `$1`） |

`pre-refresh-pacman` フックは、カスタムリポジトリや `IgnorePkg` 行を置く場所だ。パッケージトランザクションの前に実行されるからだ。更新関連のフックはどちらも、Omarchy がキャッシュした sudo 認証をクリアした後に、あなたのユーザーとして実行される。だから `sudo` を使うフックは独自の認証が必要で、パスワードを求められる場合がある。

これらのディレクトリにはそれぞれ、フックの形を示す `.sample` ファイルがすでに入っている — 名前から `.sample` を外せば使えるようになる。別の場所で書いたスクリプトをインストールするには、`omarchy hook install post-boot ~/my-hook` を使う。これでコピーされ、実行可能になる。

### 自分のメニュー項目を追加する

Omarchy メニュー（`Super + Space`）は、`~/.config/omarchy/extensions/omarchy-menu.jsonc` を編集することで、自分の行を追加して拡張できる。項目はドット区切りの id をキーとし、その id がツリー内の配置を決める。だから `personal` はルートメニューに表示され、`personal.notes` はその中に表示される：

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

既存の id を再利用すると、新しい行を追加する代わりにその行を上書きする。このファイルには、利用可能なすべてのフィールドがコメントとして文書化された状態で同梱されている。

### 自分のシェルのエクスポート、関数、エイリアスを追加する

Omarchy には、使いやすいエイリアスと便利な関数がたくさん同梱されているが、自分でも追加したくなるのはごく普通のことだ。エイリアス、関数、エクスポートはすべて `~/.bashrc` に追加すること。このファイルはアップデートで上書きされない。Omarchy のデフォルトのいずれかを変更したい場合も、ここに安全に追加できる。

### デスクトップ用の環境変数を設定する

デスクトップセッションのエクスポートは `~/.config/uwsm/env.d/` に置く。これらのファイルはデスクトップが起動する前に実行されるので、シェルのエラーでログイン画面に戻されてしまうことがある。編集するときは、動作するターミナルを開いたままにしておくこと。上書きを無効にするには、`env.d` の外に移動する。変更によってログインできなくなった場合は、[ログインの復旧](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) を参照すること。

### Omarchy の内部ファイルを変更する

いいか、これは君のコンピュータだ。好きなようにしていい。だが、`/usr/share/omarchy` 内のファイルを直接変更するのはやめておくよう勧める。あれは Omarchy の pacman パッケージに属しているので、君の変更は次回のアップデートで単に上書きされてしまう。代わりに、気に入らないデフォルト値は `~/.config/*` フォルダで上書きしたほうがずっといい。

その方法で、デフォルトのキーバインドなど、ほぼすべてを変更できる。たとえば [Obsidian](https://obsidian.md/) を [Joplin](https://joplinapp.org/) に置き換えるには（`omarchy-pkg-add joplin-bin` でインストールする）、`~/.config/hypr/bindings.lua` を編集するだけだ：

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` は、置換を追加する前に既存のバインドを削除する。引数は `o.bind` と同じで、起動ヘルパーやバインドオプションも含む。バインドを追加するには `o.bind` を、置換せずに削除するには `hl.unbind` を使う。

それでも Omarchy の内部ファイルをハックしたいと言うなら、_Update > Channel > Dev_ から dev チャンネルに切り替えること。そうすると Omarchy は `~/omarchy` にあるソースコードの git チェックアウトにリンクされ、心ゆくまで自由に変更できる。ここで君にあれこれ指図する人間などいないのだ！

### 変更をリセットする

設定をめちゃくちゃにしてしまったら、Omarchy メニューの _Update > Config_ からいつでもデフォルトに戻せる。あるいは `omarchy reinstall configs` を実行してすべてをリセットすることもできる。
