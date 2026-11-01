# Web アプリ

独自の Web アプリは Omarchy メニュー（`Super + Space`）の _インストール > Web App_ で追加できます。アプリ名、アプリ URL、そして favicon 経由で取得できなければアイコン URL を尋ねられます。多くの人気 Web アプリ向けの素晴らしい PNG アイコンは [Dashboard Icons](https://dashboardicons.com) で入手できます。

その後はアプリランチャー（`Super + Space`）からアクセスでき、美しいフレームレスな Web アプリウィンドウを使えます。

Web アプリを削除したい場合は、Omarchy メニューの _削除 > Web App_ へ移動してください。

Web アプリのショートカットを使う前に、通常のブラウザですべてのアカウントにログインしておくのが最善です。薄いラッパーフレームは 1password との相性が良くないため、まず直接ログインしておく方が簡単です。

これらの Web アプリ向けのキーボードホットキーはすべて `~/.config/hypr/bindings.lua` で変更できます。

Web アプリの中にいるとき、`Shift + Alt + L` で現在の URL をクリップボードにコピーできます。

デフォルトでは、Omarchy にはすでにデフォルトアプリの詰め合わせが同梱されています：

## HEY

[HEY](https://www.hey.com/) はメールとカレンダーのサービスで、Gmail、Outlook、Apple Mail に飽きた人々にとって優れた代替です。Omarchy が生まれた [37signals](https://37signals.com/) が作っています。

HEY Email は `Super + Shift + E` で起動でき、新しいメールの作成に直接ジャンプするには `Super + Shift + Alt + E` を、HEY Calendar の起動には `Super + Shift + C` を使ってください。

## Basecamp

[Basecamp](https://basecamp.com/) はプロジェクト管理サービスで、小規模チームがより速く動き、より多くの進捗を生むのを助けます。Trello、Slack、Asana、Notion などのごちゃ混ぜを継ぎはぎする代わりに、Basecamp ならすべてを1か所にまとめられます。Omarchy が生まれた [37signals](https://37signals.com/) が作っています。

Basecamp はアプリランチャー（`Super + Space`）で起動できます

## ChatGPT

[ChatGPT](https://chatgpt.com) は世界で最も人気のある AI チャットボットです。

ChatGPT は `Super + Shift + A` で起動できます。

## Grok

[Grok](https://grok.com) は xAI のチャットボットです。

Grok は `Super + Shift + Alt + A` で起動できます。

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) は世界で最も人気のあるメッセージングサービスの1つで、Web バージョンは Linux にとって優れた選択肢です。

WhatsApp は `Super + Shift + Alt + G` で起動できます。

## Google アプリ

Google Messages、Google Photos、Google Maps、Google Contacts もすべて Web アプリとして含まれています。

Google Messages は `Super + Shift + Ctrl + G`、Google Photos は `Super + Shift + P`、Google Maps は `Super + Shift + S` で起動できます。Google Contacts はアプリランチャー（`Super + Space`）から利用できます。

## X

X はニュースが速報される場所です。

X は `Super + Shift + X` で起動でき、`Super + Shift + Alt + X` で新しい投稿を書くところへ直接移動できます。

## YouTube

[YouTube](https://youtube.com/) は世界で最も人気のある動画プラットフォームです。

YouTube は `Super + Shift + Y` で起動できます。

## Zoom

[Zoom](https://zoom.us/) は米国で使われる最も人気のあるビデオチャットシステムです。世界中で素晴らしい接続が得られます。そして有料アカウントなしで40分の会議を開催できます。Omarchy は Zoom の Web クライアントをラップしており、zoom 会議リンクはその中へ直接開きます。

Zoom はアプリランチャー（`Super + Space`）で起動します。

## Discord

[Discord](https://discord.com/) は、[Omarchy 自身](https://discord.gg/tXFUdasqhY) を含む、ほとんどのゲームとオープンソースのコミュニティが集まる場所です。

Discord はアプリランチャー（`Super + Space`）で起動します。

## Microsoft アプリ

_インストール > Service > Microsoft_ を選ぶと、Outlook、Word、Excel、PowerPoint、Teams、OneDrive が Web アプリとして追加されます。各アプリには独自のランチャーがあり、直接開き、商用の Microsoft 365 URL と既存のブラウザプロファイルを使います。これらは Omarchy の他の Web アプリと同じブラウザアプリウィンドウで開きます。別個の Teams for Linux クライアントはインストールしません。

バンドルは _削除 > Service > Microsoft_ で削除するか、個別のアプリは _削除 > Web App_ で削除してください。欲しいアプリだけを _インストール > Web App_ でインストールすることもできます。

政府やソブリンクラウドの場合は、`~/.local/share/applications/` の下にある該当ランチャー（たとえば `Microsoft Teams.desktop`）の `Exec=` 行にある URL を、所属組織から提供された URL で編集してください。その行のリテラル `%` は `%%` と書いてください。変更は次の起動時に適用されます。バンドルインストーラーを再び実行すると、そのランチャーがデフォルト URL で置き換わります。

職場のサインインを別にしておくには、各ランチャーの `Exec=` 行にブラウザデータディレクトリを追記してください：

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

例のディレクトリを任意の絶対パスで置き換え、6つのランチャーすべてで同じパスを使って職場のサインインを共有してください。Web アプリは Omarchy が選択した対応ブラウザを使用し、デフォルトブラウザが非対応の場合は Chromium にフォールバックします。
