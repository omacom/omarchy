# ウェブアプリ

Omarchy メニュー（`Super + Space`）の _Install > Web App_ を使って、独自のウェブアプリを追加できます。アプリ名、アプリの URL、favicon 経由で取得できない場合はアイコンの URL を入力するよう求められます。多くの人気ウェブアプリ向けの素晴らしい PNG アイコンは [Dashboard Icons](https://dashboardicons.com) で入手できます。

追加したアプリはアプリランチャー（`Super + Space`）から利用でき、美しいフレームレスなウェブアプリウィンドウで表示されます。

ウェブアプリを削除したい場合は、Omarchy メニューの _Remove > Web App_ に進むだけです。

ウェブアプリのショートカットを使う前に、通常のブラウザですべてのアカウントにログインしておくのが最適です。薄いラッパーフレームは 1password とうまく相性が良くないため、最初から直接ログインしておくほうが簡単です。

これらのウェブアプリに対するすべてのキーボードホットキーは、`~/.config/hypr/bindings.lua` で変更できます。

ウェブアプリを使用しているときは、`Shift + Alt + L` で現在の URL をクリップボードにコピーできます。

デフォルトでは、Omarchy にはすでに各種のデフォルトアプリが同梱されています。

## HEY

[HEY](https://www.hey.com/) はメール・カレンダーサービスであり、Gmail、Outlook、Apple Mail にうんざりした人にとって優れた代替サービスです。Omarchy が生まれた [37signals](https://37signals.com/) によって作られています。

`Super + Shift + E` で HEY Email を起動でき、`Super + Shift + Alt + E` で新規メールの作成へ直接移動でき、`Super + Shift + C` で HEY Calendar を起動できます。

## Basecamp

[Basecamp](https://basecamp.com/) は、小規模チームがより速く行動し、より大きな進捗を生み出すためのプロジェクト管理サービスです。Trello、Slack、Asana、Notion などあれこれを継ぎはぎする代わりに、Basecamp でそのすべてを一か所にまとめることができます。Omarchy が生まれた [37signals](https://37signals.com/) によって作られています。

アプリケーションランチャー（`Super + Space`）を使って Basecamp を起動できます。

## ChatGPT

[ChatGPT](https://chatgpt.com) は世界で最も人気のある AI チャットボットです。

`Super + Shift + A` を使って ChatGPT を起動できます。

## Grok

[Grok](https://grok.com) は xAI のチャットボットです。

`Super + Shift + Alt + A` を使って Grok を起動できます。

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) は世界で最も人気のあるメッセージングサービスのひとつで、Web 版は Linux にとって優れた選択肢です。

`Super + Shift + Alt + G` を使って WhatsApp を起動できます。Omarchy の WhatsApp Slim 拡張機能付きで開き、テーマに従うようになり、ウィンドウ幅が狭いときにはチャット一覧が折りたたまれます。

## Google アプリ

Google Messages、Google Photos、Google Maps、Google Contacts もすべてウェブアプリとして含まれています。

`Super + Shift + Ctrl + G` で Google Messages、`Super + Shift + P` で Google Photos、`Super + Shift + S` で Google Maps を起動できます。Google Contacts はアプリランチャー（`Super + Space`）から利用できます。

## X

X はニュースが速報される場所です。

`Super + Shift + X` で X を起動でき、`Super + Shift + Alt + X` で新規投稿の作成へ直接移動できます。

## YouTube

[YouTube](https://youtube.com/) は世界で最も人気のある動画プラットフォームです。

`Super + Shift + Y` を使って YouTube を起動できます。

## Netflix

[Netflix](https://www.netflix.com/) は新規インストール時にウェブアプリとして含まれています。

アプリケーションランチャー（`Super + Space`）を使って Netflix を起動します。

## Zoom

[Zoom](https://zoom.us/) は米国で最も人気のあるビデオチャットシステムです。世界中で優れた接続が得られます。そして有料アカウントなしで 40 分間のミーティングを開催できます。Omarchy は Zoom の Web クライアントをラップしており、Zoom のミーティングリンクはそのままそのクライアントで開きます。

アプリケーションランチャー（`Super + Space`）を使って Zoom を起動します。

## Discord

[Discord](https://discord.com/) は、[Omarchy 自身の](https://discord.gg/tXFUdasqhY)ものも含め、ほとんどのゲーミングおよびオープンソースコミュニティが集まる場所です。

アプリケーションランチャー（`Super + Space`）を使って Discord を起動します。

## Microsoft アプリ

_Install > Service > Microsoft_ を選択して、Outlook、Word、Excel、PowerPoint、Teams、OneDrive をウェブアプリとして追加します。各アプリには独自のランチャーがあり、商用の Microsoft 365 の URL と既存のブラウザプロファイルを使って直接開きます。これらは Omarchy の他のウェブアプリと同じブラウザアプリウィンドウで開きます。Teams for Linux の別クライアントをインストールすることはありません。

_Remove > Services > Microsoft_ でバンドルを削除するか、_Remove > Web App_ で個別のアプリを削除します。_Install > Web App_ 経由で、必要なアプリだけをインストールすることもできます。

政府機関用またはソブリンクラウド向けには、`Microsoft Teams.desktop` などの `~/.local/share/applications/` 配下にある関連ランチャーの `Exec=` 行の URL を編集し、組織から提供された URL を使用してください。その行にリテラルの `%` を書く場合は、`%%` と記述してください。変更は次回起動時に適用されます。バンドルインストーラーを再度実行すると、そのランチャーはデフォルトの URL に置き換えられます。

仕事用サインインを分離した状態に保つには、各ランチャーの `Exec=` 行にブラウザのデータディレクトリを追加します。

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

例示のディレクトリを任意の絶対パスへ置き換え、6 つのランチャーすべてで同じパスを使用して、それらの間で仕事用サインインを共有してください。これらのウェブアプリは Omarchy が選択した対応ブラウザを使用し、デフォルトブラウザが対応していない場合は Chrome にフォールバックします。
