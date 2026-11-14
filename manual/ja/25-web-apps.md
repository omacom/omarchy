# Web アプリ

Omarchy メニュー（`Super + Space`）の _Install > Web App_ を使って、独自の Web アプリを追加できます。アプリ名、アプリの URL、そして favicon 経由で取得できない場合はアイコンの URL の入力を求められます。多くの人気 Web アプリ向けの優れた PNG アイコンは [Dashboard Icons](https://dashboardicons.com) で入手できます。

それらはその後、アプリランチャー（`Super + Space`）から利用できるようになり、美しいフレームレスな Web アプリウィンドウで開きます。

Web アプリを削除したい場合は、Omarchy メニューの _Remove > Web App_ へ移動するだけです。

Web アプリのショートカットを使う前に、通常のブラウザですべてのアカウントにログインしておくのがベストです。薄いラッパーフレームは 1password とうまく連携しないため、最初に直接ログインしておく方が簡単です。

これらの Web アプリのキーボードホットキーはすべて `~/.config/hypr/bindings.lua` で変更できます。

Web アプリ内にいるときは、`Shift + Alt + L` を使って現在の URL をクリップボードにコピーできます。

デフォルトでは、Omarchy にはすでに各種のデフォルトアプリが同梱されています：

## HEY

[HEY](https://www.hey.com/) は、Gmail、Outlook、Apple Mail にうんざりした人にとって優れた代替となるメールおよびカレンダーサービスです。Omarchy が生まれた [37signals](https://37signals.com/) によって作られています。

`Super + Shift + E` で HEY Email を起動でき、`Super + Shift + Alt + E` で直接新しいメールの作成へジャンプでき、`Super + Shift + C` で HEY Calendar を起動できます。

## Basecamp

[Basecamp](https://basecamp.com/) は、小規模チームがより速く動き、より多くの進捗を生むのを助けるプロジェクト管理サービスです。Trello、Slack、Asana、Notion など寄せ集めを継ぎはぎする代わりに、Basecamp でそのすべてを一か所にまとめられます。Omarchy が生まれた [37signals](https://37signals.com/) によって作られています。

アプリランチャー（`Super + Space`）を使って Basecamp を起動できます

## ChatGPT

[ChatGPT](https://chatgpt.com) は世界で最も人気のある AI チャットボットです。

`Super + Shift + A` を使って ChatGPT を起動できます。

## Grok

[Grok](https://grok.com) は xAI のチャットボットです。

`Super + Shift + Alt + A` を使って Grok を起動できます。

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) は世界で最も人気のあるメッセージングサービスのひとつで、Web 版は Linux 向けの優れた選択肢です。

`Super + Shift + Alt + G` を使って WhatsApp を起動できます。

## Google アプリ

Google Messages、Google Photos、Google Maps、Google Contacts はすべて Web アプリとしても含まれています。

Google Messages は `Super + Shift + Ctrl + G` で、Google Photos は `Super + Shift + P` で、Google Maps は `Super + Shift + S` で起動できます。Google Contacts はアプリランチャー（`Super + Space`）から利用できます。

## X

X はニュースが速報される場所です。

`Super + Shift + X` で X を起動でき、`Super + Shift + Alt + X` で直接新しい投稿の作成へ進めます。

## YouTube

[YouTube](https://youtube.com/) は世界で最も人気のある動画プラットフォームです。

`Super + Shift + Y` を使って YouTube を起動できます。

## Zoom

[Zoom](https://zoom.us/) は米国で使われている最も人気のあるビデオチャットシステムです。世界中で優れた接続が得られます。さらに、40 分間のミーティングは有料アカウントなしで開催できます。Omarchy は Zoom の Web クライアントをラップしており、zoom ミーティングリンクはそのままその中で開けます。

アプリランチャー（`Super + Space`）を使って Zoom を起動します。

## Discord

[Discord](https://discord.com/) は、[Omarchy 自体](https://discord.gg/tXFUdasqhY) を含め、ほとんどのゲーミングおよびオープンソースコミュニティが集まる場所です。

アプリランチャー（`Super + Space`）を使って Discord を起動します。

## Microsoft アプリ

_Install > Service > Microsoft_ を選択して、Outlook、Word、Excel、PowerPoint、Teams、OneDrive を Web アプリとして追加します。各アプリには独自のランチャーがあり、商用 Microsoft 365 の URL と既存のブラウザプロファイルを使って直接開きます。Omarchy の他の Web アプリと同じブラウザアプリウィンドウで開きます。別の Teams for Linux クライアントをインストールするわけではありません。

_Remove > Service > Microsoft_ でバンドルを削除でき、個別のアプリは _Remove > Web App_ で削除できます。_Install > Web App_ から必要なアプリだけをインストールすることもできます。

政府系またはソブリンクラウド向けには、`~/.local/share/applications/` 配下の該当ランチャー、例えば `Microsoft Teams.desktop` の `Exec=` 行にある URL を、組織から提供された URL を使って編集してください。その行にリテラルの `%` を書く場合は `%%` と書いてください。変更は次回起動時に適用されます。バンドルインストーラーを再度実行すると、そのランチャーはデフォルトの URL に置き換えられます。

仕事用サインインを分離するには、各ランチャーの `Exec=` 行にブラウザデータディレクトリを追加します：

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

例のディレクトリを任意の絶対パスに置き換え、6 つのランチャーすべてで同じパスを使って仕事用サインインをそれらの間で共有してください。Web アプリは Omarchy が選択した対応ブラウザを使用し、デフォルトブラウザが対応していない場合は Chrome にフォールバックします。
