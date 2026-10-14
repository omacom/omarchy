# ゲーミング

Omarchy は _pRoDUcTiVItY_（生産性）のためだけのものではなく、楽しむためのものでもあります。そしてゲームほど楽しいものはないでしょう。Omarchy にはゲームの選択肢一式が同梱されています — ネイティブとレトロなプレイには Steam と RetroArch、Steam 以外のストアには Battle.net、Lutris、Heroic、PC ストリーミングには Moonlight、クラウドには Xbox Cloud Gaming + NVIDIA GeForce NOW、そして常連の Minecraft です。

Valve による [プロトン互換レイヤー](https://en.wikipedia.org/wiki/Proton_(software)) への素晴らしい取り組みのおかげで、今や数万のモダンなゲームが Linux でプレイできるようになりました。ああ、それから [Steam Deck](https://store.steampowered.com/steamdeck/) が実際に Arch を動かしているのをご存知でしたか！

すべてのゲーミングインストーラーは Omarchy メニュー（`Super + Space`）の _インストール > Gaming_ の下にあります。いつか取り消したくなったら _削除 > Gaming_ を使ってください。

## Steam

Omarchy メニュー（`Super + Space`）の _インストール > Gaming > Steam_ を選んで [Steam](https://store.steampowered.com/) をインストールしてください。

インストールしたら、`Super + Space` で Steam を起動できます。

Steam は起動に10〜20秒かかることがあり、ロード中であるという視覚的フィードバックは一切提供しません。

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy メニュー（`Super + Space`）の _インストール > Gaming > RetroArch_ を選んで [RetroArch](https://www.retroarch.com/) をインストールしてください。libretro コアの完全なセットが付属しているため、すべてのクラシックなシステムをカバーします。

RetroArch は完璧なレトロな見た目を目指す美しい CRT Royale シェーダーで完全に事前構成されています。

始め方：

1. BIOS ファイルを `~/Games/bios` に、ROM を `~/Games/roms` に入れてください。
2. `Super + Space` で RetroArch を起動し、`retro` と入力してください。
3. `~/Games/roms` ディレクトリをスキャンすれば、プレイの準備完了です。

お気に入りのゲームにアプリランチャーへの独自のエントリを与えることもでき、_インストール > Gaming > RetroArch Game Launcher_ でコアと ROM を選んで、`Super + Space` からゲームへ直接ジャンプできます。

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy メニュー（`Super + Space`）の _インストール > Gaming > Xbox Cloud Gaming_ を選んで Xbox Cloud Gaming の Web アプリをインストールしてください。これはサービス向けの「単なる」Web アプリですが、起動が速く、1080p で素晴らしく動作します。

すでに Xbox Game Pass がある場合、これは Fortnite や Linux のネイティブで動かせない他のタイトルをプレイする確実な方法です。

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy メニュー（`Super + Space`）の _インストール > Gaming > NVIDIA GeForce NOW_ を選んでクラウドゲーミングサービス [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) をインストールしてください。Linux のネイティブで利用できないタイトルをプレイするもう1つの素晴らしい方法です。

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy メニュー（`Super + Space`）の _インストール > Gaming > Minecraft_ を選んで Minecraft をインストールしてください。

Steam と同様、ログインや起動の後、次の画面が現れるまでしばらくかかることがあり、待っている間フィードバックは一切得られない点に注意してください。

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox コントローラー

Omarchy メニュー（`Super + Space`）の _インストール > Gaming > Xbox Controllers_ を選んで Bluetooth Xbox コントローラーへのサポートをインストールしてください。Bluetooth（`Super + Ctrl + B`）経由でコントローラーをペアリングすれば、すべてのゲームで使えるようになります。USB-C ケーブルでコントローラーを有線接続するだけならこれは不要です。

## Moonlight（PC からのゲームストリーミング）

[Moonlight クライアント](https://github.com/moonlight-stream/moonlight-qt) は Omarchy にプリインストールされているため、[Sunshine](https://app.lizardbyte.dev/Sunshine/) を動かす Windows PC からすぐにゲームをストリーミングできます。Moonlight は `Super + Space` で起動してください。

あなたの Omarchy マシンとリモートゲーミング PC の両方が有線接続されている場合、その体験はローカルでプレイすることと見分けがつきません。解像度をネイティブへ上げ、リフレッシュを 120Hz に設定し、ビットレートを最大にしてください — これが Linux で Fortnite のような競技性シューターをプレイする最良の方法です。

`omarchy install service sunshine` を実行して Omarchy マシンをホストに変えることもでき、Sunshine がインストールされ、あなたの LAN と Tailscale 向けに Moonlight のストリーミングポートが開かれます。

## Battle.net

Omarchy メニュー（`Super + Space`）の _インストール > Gaming > Battle.net_ を選んで [Battle.net](https://eu.shop.battle.net/en-us) をインストールしてください。Diablo、Starcraft、World of Warcraft のようなタイトルを GE-Proton の下で動作するスタンドアロンインストールとして得られます — Steam、Lutris、Heroic は一切不要です。

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris（Windows ゲーム）

Omarchy メニュー（`Super + Space`）の _インストール > Gaming > Lutris_ を選んで [Lutris](https://lutris.net/) をインストールしてください。Lutris は上記に独自のインストーラーがない EA や Ubisoft Connect のようなストアから Windows ゲームをプレイするための手段です。

インストールは少し不安定で、ときどき何も起こっていないように見えます — ただ我慢してください、バックグラウンドで動いています。

## Heroic Launcher（Epic Games）

Omarchy メニュー（`Super + Space`）の _インストール > Gaming > Heroic (Epic Games)_ を選んで [Heroic Launcher](https://heroicgameslauncher.com/) をインストールしてください。Heroic は OddSparks のようなアンチチートに依存しない Epic Games のタイトル — それに GOG と Amazon Prime Gaming のゲーム — を動かせるようにします。悲しいことに、それは Fortnite も Rocket League もないことを意味します — Tim Sweeney が Linux に来る日までは、これが最も近いのです。

Lutris と同様、ゲームのインストール中は遅く、不安定に感じることがあります。時間をあげてください。
