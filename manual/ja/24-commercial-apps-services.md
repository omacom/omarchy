# 商用アプリ／サービス

Omarchy は主に無料のオープンソースソフトウェアの提供に注力していますが、それに固執しているわけではありません。時には最適な解決策が商用製品であることもあり、それでまったく問題ありません。ここでは、簡単にインストールできるようにしている選択肢の一部を紹介します。

## 1Password

パスワードをパスワードマネージャーに保存しておくことはベストプラクティスです。チームで作業しているならなおさらです。そして [1password](https://1password.com/) は優れたソリューションで、スクリプトからキーを参照できるコマンドラインツールも付属しています。

1Password は `Super + Shift + /` で起動します。まだインストールされていない場合、そのホットキーがまずインストールを開始します（Omarchy メニューから _Install > Service > 1Password_ を使うこともできます）。インストーラーは 1Password コマンドラインツールも導入し、Chrome と Chromium 向けの 1Password 拡張機能もセットアップします。読み込むにはブラウザを再起動してください。

## Bitwarden

[Bitwarden](https://bitwarden.com/) はパスワードマネージャーの分野におけるオープンソースの代替であり、無料プランで個人利用のほとんどをカバーできます。Omarchy メニューから _Install > Service > Bitwarden_ でインストールすると、Bitwarden コマンドラインツールも一緒に導入されます。

## Spotify

[Spotify](https://spotify.com/) は世界で最も人気のあるストリーミング音楽サービスです。Omarchy では Web アプリとして提供しており、フルプレーヤー、メディアキー、Spotify Connect が使えますが、オフライン再生用のダウンロードはできません。`Super + Shift + M` で起動します。

## Slack

[Slack](https://slack.com/) は多くのチームが社内でも社外の協力者ともチャットに使っている場所です。Omarchy メニューから _Install > Service > Slack_ でインストールすると、準備ができ次第すぐに開きます。

## Notion

[Notion](https://www.notion.com/) はノート、ドキュメント、プロジェクトのためのワークスペースです。Omarchy メニューから _Install > Service > Notion_ でデスクトップアプリをインストールします。

## WeChat

[WeChat](https://www.wechat.com/) は中国のほとんどの人が使っているメッセージングアプリで、チャット、通話、そして中国に住む人との連絡に使われています。Omarchy メニューから _Install > Service > WeChat_ で Tencent 公式の Linux クライアントをインストールすると、準備ができ次第すぐに開きます。x86 コンピューターでのみ利用できます。

## Dropbox

[Dropbox](https://www.dropbox.com/) は、クラウドにバックアップを保持しながらマシン間でファイルを同期する優れた方法です。セットアップするには、Omarchy メニューから _Install > Service > Dropbox_ を選択します。バーに Dropbox アイコンが追加されます。それをクリックしてログインし、同じパネルでストレージを確認したり、最近同期したファイルを開いたりできます。

## Tailscale

[Tailscale](https://tailscale.com/) はメッシュ VPN で、インターネット経由で自分のすべてのコンピューターやサーバーに安全にアクセスすることを非常に簡単にします。セットアップするには、Omarchy メニューから _Install > Service > Tailscale_ を選択します。

バーにパネルが追加され、管理コンソール用の Web アプリと、マシン間でファイルを送るための Taildrop が使えるようになります。[ネットワーク](35-networking.md) を参照してください。

## ONCE

[ONCE](https://once.com/) は 37signals の「一度買って自分のサーバーで動かす」ソフトウェアのラインで、Campfire チャットシステムのようなものです。インストールするには Omarchy メニューから _Install > Service > ONCE_ を選択します。これによりバックグラウンドサービスが有効になり、ONCE ターミナルインターフェースが開いて、そこから先を進められます。

## NordVPN

[NordVPN](https://nordvpn.com/) は標準的な VPN サービスで、世界中のほとんどの地域からトラフィックを出せます。セットアップするには、Omarchy メニューから _Install > Service > NordVPN_ を選択します。求められた再起動の後、`nordvpn login` を実行して認証してください。
