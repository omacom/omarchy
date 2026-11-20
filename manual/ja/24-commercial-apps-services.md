# 商用アプリ/サービス

Omarchy は主に無料のオープンソースソフトウェアの提供に注力しているが、そこに教条的にこだわっているわけではない。最適な解決策が商用製品であることもあるし、それでまったく問題ない。ここでは、簡単にインストールできるようにしている選択肢の一部を紹介する。

## 1Password

パスワードをパスワードマネージャーに保管するのはベストプラクティスだ。チームで作業しているなら、なおさらだ。そして [1password](https://1password.com/) は優れたソリューションで、スクリプトにキー検索を組み込むためのコマンドラインツールも付属している。

1Password は `Super + Shift + /` で起動する。まだインストールされていなければ、そのホットキーがまずインストールを開始する（Omarchy メニューから _Install > Service > 1Password_ を使うこともできる）。インストーラーでは 1Password コマンドラインツールも導入され、Chrome と Chromium 向けの 1Password 拡張機能もセットアップされる。読み込むにはブラウザーを再起動すること。

## Bitwarden

[Bitwarden](https://bitwarden.com/) はパスワードマネージャー分野におけるオープンソースの代替選択肢で、個人利用のほとんどをカバーする無料プランがある。Omarchy メニューから _Install > Service > Bitwarden_ でインストールすると、Bitwarden コマンドラインツールも一緒に導入される。

## Spotify

[Spotify](https://spotify.com/) は世界で最も人気のある音楽ストリーミングサービスだ。Omarchy には Web アプリとして搭載されており、完全なプレイヤー、メディアキー、Spotify Connect が使えるが、オフライン再生のためのダウンロードはできない。`Super + Shift + M` で起動する。

## Slack

[Slack](https://slack.com/) は、社内でも外部の共同作業者とも、多くのチームがチャットに使っている場所だ。Omarchy メニューから _Install > Service > Slack_ でインストールすると、準備ができ次第開く。

## Notion

[Notion](https://www.notion.com/) はメモ、ドキュメント、プロジェクトのためのワークスペースだ。Omarchy メニューから _Install > Service > Notion_ でデスクトップアプリをインストールできる。

## Dropbox

[Dropbox](https://www.dropbox.com/) は、クラウドにバックアップを保持しながらマシン間でファイルを同期する優れた方法だ。セットアップするには、Omarchy メニューから _Install > Service > Dropbox_ を選択する。バーに Dropbox アイコンが追加される。それをクリックしてログインし、同じパネルでストレージの使用状況を確認したり、最近同期したファイルを開いたりできる。

## Tailscale

[Tailscale](https://tailscale.com/) はメッシュ VPN で、インターネット経由で自分のすべてのコンピューターとサーバーに安全にアクセスすることを非常に簡単にしてくれる。セットアップするには、Omarchy メニューから _Install > Service > Tailscale_ を選択する。

バーにパネルが追加され、管理コンソール用の Web アプリと、マシン間でファイルを送るための Taildrop が使えるようになる。[ネットワーク](35-networking.md) を参照すること。

## ONCE

[ONCE](https://once.com/) は 37signals のソフトウェアラインで、Campfire チャットシステムのように、一度買って自分のサーバーで動かすものだ。Omarchy メニューから _Install > Service > ONCE_ を選択してインストールすると、そのバックグラウンドサービスが有効化され、ONCE ターミナルインターフェースが開くので、そこから先へ進められる。

## NordVPN

[NordVPN](https://nordvpn.com/) は標準的な VPN サービスで、世界中のほとんどの地域からトラフィックを出口に出せる。セットアップするには、Omarchy メニューから _Install > Service > NordVPN_ を選択する。求められる再起動の後、`nordvpn login` を実行して認証すること。
