# ゲーミング

Omarchy は _pRoDUcTiVItY_ のためだけのものじゃない。楽しむためのものでもある。そしてゲームほど楽しいものがあるだろうか？ Omarchy にはゲーム向けの選択肢が一式そろっている。ネイティブプレイとレトロプレイには Steam と RetroArch、Steam 以外のストアには Battle.net、Lutris、Heroic、PC ストリーミングには Moonlight、クラウドには Xbox Cloud Gaming + NVIDIA GeForce NOW、そして鉄板の Minecraft だ。

Valve が [Proton 互換レイヤー](https://en.wikipedia.org/wiki/Proton_(software)) でやってのけた信じられない仕事のおかげで、今や Linux でプレイできる現代のゲームは数万本にもなる。あと、[Steam Deck](https://store.steampowered.com/steamdeck/) は実は Arch で動いているって、知っていたか！

ゲーミング用インストーラーはすべて、Omarchy メニュー（`Super + Space`）の _Install > Gaming_ にある。どれかを取り消したくなったら、_Remove > Gaming_ を使おう。

## Steam

Omarchy メニュー（`Super + Space`）から _Install > Gaming > Steam_ を選んで、[Steam](https://store.steampowered.com/) をインストールしよう。

インストールが終われば、`Super + Space` で Steam を起動できるようになる。

なお、Steam は起動に 10〜20 秒かかることがあり、読み込み中であることを示す視覚的なフィードバックは何も出ない。

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy メニュー（`Super + Space`）から _Install > Gaming > RetroArch_ を選んで、[RetroArch](https://www.retroarch.com/) をインストールしよう。libretro コア一式が付属しているので、往年のシステムはすべてカバーされている。

RetroArch は、その完璧なレトロな見た目を実現する美しい CRT Royale シェーダーで完全に事前設定されている。

始めるには：

1. BIOS ファイルを `~/Games/bios` に、ROM を `~/Games/roms` に入れよう。
2. `Super + Space` で RetroArch を起動し、`retro` と入力しよう。
3. `~/Games/roms` ディレクトリをスキャンすれば、プレイする準備は完了だ。

お気に入りのゲームにアプリランチャー専用の項目を与えることもできる。_Install > Gaming > RetroArch Game Launcher_ を使えば、コアと ROM を選んで、`Super + Space` からそのままゲームに飛び込める。

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy メニュー（`Super + Space`）から _Install > Gaming > Xbox Cloud Gaming_ を選んで、Xbox Cloud Gaming のウェブアプリをインストールしよう。これはサービスの「ただの」ウェブアプリだが、起動は速く、1080p で快適に動作する。

すでに Xbox Game Pass を持っているなら、これは Fortnite や、Linux ではネイティブに動作しない他のタイトルをプレイする確かな方法だ。

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy メニュー（`Super + Space`）から _Install > Gaming > NVIDIA GeForce NOW_ を選んで、クラウドゲーミングサービス [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) をインストールしよう。Linux ではネイティブに利用できないタイトルをプレイする、もう一つの優れた方法だ。

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy メニュー（`Super + Space`）から _Install > Gaming > Minecraft_ を選んで、Minecraft をインストールしよう。

Steam と同じく、ログイン後や起動後に次の画面が表示されるまで時間がかかることがあり、待っている間は何のフィードバックも得られない点に注意しよう。

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy メニュー（`Super + Space`）から _Install > Gaming > Xbox Controllers_ を選んで、Bluetooth Xbox コントローラーへの対応をインストールしよう。Bluetooth（`Super + Ctrl + B`）でコントローラーをペアリングすれば、すべてのゲームで使えるようになる。コントローラーを USB-C ケーブルで有線接続するだけなら、これは必要ない。

## Moonlight (PC からのゲームストリーミング)

Omarchy メニュー（`Super + Space`）から _Install > Gaming > Moonlight_ を選んで [Moonlight クライアント](https://github.com/moonlight-stream/moonlight-qt) をインストールすれば、[Sunshine](https://app.lizardbyte.dev/Sunshine/) を動かしている Windows PC からゲームをストリーミングできる。

Omarchy マシンとリモートのゲーミング PC の両方が有線接続なら、その体験はローカルでプレイするのと区別がつかない。解像度をネイティブまで上げ、リフレッシュレートを 120Hz に設定し、ビットレートを最大にしよう。これが Linux で Fortnite のような競技系シューターをプレイする最良の方法だ。

`omarchy install service sunshine` を実行すれば、Omarchy マシンをホストにすることもできる。これにより Sunshine がインストールされ、LAN と Tailscale 向けに Moonlight ストリーミング用ポートが開かれる。

## Battle.net

Omarchy メニュー（`Super + Space`）から _Install > Gaming > Battle.net_ を選んで、[Battle.net](https://eu.shop.battle.net/en-us) をインストールしよう。これにより、Diablo、Starcraft、World of Warcraft といったタイトルを、GE-Proton 上で動作するスタンドアロンのインストールとして利用できる。Steam も Lutris も Heroic も必要ない。

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows ゲーム)

Omarchy メニュー（`Super + Space`）から _Install > Gaming > Lutris_ を選んで、[Lutris](https://lutris.net/) をインストールしよう。Lutris は、上記の専用インストーラーがない EA や Ubisoft Connect といったストアの Windows ゲームをプレイする方法だ。

インストールは少し不格好で、時々何も起きていないように見える。ただ我慢しよう。裏ではちゃんと動作している。

## Heroic Launcher (Epic Games)

Omarchy メニュー（`Super + Space`）から _Install > Gaming > Heroic (Epic Games)_ を選んで、[Heroic Launcher](https://heroicgameslauncher.com/) をインストールしよう。Heroic を使えば、OddSparks のようにアンチチートに依存しない Epic Games のタイトルに加え、GOG や Amazon Prime Gaming のゲームも実行できる。残念ながら、それは Fortnite も Rocket League もないということだ。Tim Sweeney が Linux に来るまでは、これが精一杯だ。

Lutris と同じく、ゲームのインストール中は動作が遅く、不格好に感じることがある。時間をかけよう。
