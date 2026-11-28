# ゲーム

Omarchyは_pRoDUcTiVItY_のためだけにあるんじゃない。楽しむためのものでもあるし、ゲームより楽しいものなんてあるだろうか？Omarchyにはゲームのオプションが一式そろっている。ネイティブなプレイとレトロなプレイのためのSteamとRetroArch、Steam以外のストアのためのBattle.net、Lutris、Heroic、PCストリーミングのためのMoonlight、クラウドのためのXbox Cloud Gaming + NVIDIA GeForce NOW、そして定番のMinecraftだ。

Valveが[Proton互換レイヤー](https://en.wikipedia.org/wiki/Proton_(software))で成し遂げた素晴らしい仕事のおかげで、今ではLinuxでプレイできるモダンなゲームが何万本もある。ああ、それから、[Steam Deck](https://store.steampowered.com/steamdeck/)が実はArchで動いているって知っていた？

すべてのゲーム用インストーラーは、Omarchyメニュー（`Super + Space`）の_Install > Gaming_にある。元に戻したくなったら、_Remove > Gaming_を使おう。Minecraft、NVIDIA GeForce NOW、Battle.net、Lutris、Heroicは、x86マシンでのみ提供される。

## Steam

Omarchyメニュー（`Super + Space`）から_Install > Gaming > Steam_を選んで、[Steam](https://store.steampowered.com/)をインストールしよう。

インストールすれば、`Super + Space`でSteamを起動できるようになる。

Steamは起動に10〜20秒かかることがあり、読み込み中であることを示す視覚的なフィードバックは何も表示されない点に注意しよう。

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchyメニュー（`Super + Space`）から_Install > Gaming > RetroArch_を選んで、[RetroArch](https://www.retroarch.com/)をインストールしよう。libretroコア一式が入っているので、定番のシステムはすべてカバーされる。

RetroArchは美しいCRT Royaleシェーダーで完全に事前設定されており、完璧なレトロな見た目が楽しめる。

始めるには：

1. BIOSファイルを`~/Games/bios`に、ROMを`~/Games/roms`に入れる。
2. `Super + Space`でRetroArchを起動し、`retro`と入力する。
3. `~/Games/roms`ディレクトリをスキャンすれば、プレイする準備は完了だ。

_Install > Gaming > RetroArch Game Launcher_で、お気に入りのゲームにアプリランチャー専用の項目を与えることもできる。コアとROMを選べば、`Super + Space`からそのままゲームに飛び込める。

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchyメニュー（`Super + Space`）から_Install > Gaming > Xbox Cloud Gaming_を選んで、Xbox Cloud GamingのWebアプリをインストールしよう。これはサービスの『ただの』Webアプリだが、起動は速いし、1080pでも素晴らしく動く。

すでにXbox Game Passを持っているなら、Fortniteや、Linuxでネイティブには動かせないその他のタイトルをプレイするのに、これは確実な方法だ。

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchyメニュー（`Super + Space`）から_Install > Gaming > NVIDIA GeForce NOW_を選んで、クラウドゲーミングサービスの[NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/)をインストールしよう。Linuxでネイティブには利用できないタイトルをプレイする、もう一つの素晴らしい方法だ。

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchyメニュー（`Super + Space`）から_Install > Gaming > Minecraft_を選んで、Minecraftをインストールしよう。

Steamと同じく、ログイン後や起動後に次の画面が表示されるまで時間がかかることがあり、待っている間は何のフィードバックも得られない点に注意しよう。

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xboxコントローラー

Omarchyメニュー（`Super + Space`）から_Install > Gaming > Xbox Controllers_を選んで、Bluetooth Xboxコントローラーのサポートをインストールしよう。Bluetooth（`Super + Ctrl + B`）でコントローラーをペアリングすれば、すべてのゲームで使えるようになる。USB-Cケーブルでコントローラーを有線接続するだけなら、これは要らない。

## Moonlight（PCからのゲームストリーミング）

Omarchyメニュー（`Super + Space`）から_Install > Gaming > Moonlight_を選んで、[Moonlightクライアント](https://github.com/moonlight-stream/moonlight-qt)をインストールすれば、[Sunshine](https://app.lizardbyte.dev/Sunshine/)を実行しているWindows PCからゲームをストリーミングできる。

OmarchyマシンとリモートのゲーミングPCの両方が有線接続なら、体験はローカルでプレイするのと見分けがつかない。解像度をネイティブまで上げ、リフレッシュレートを120Hzに設定し、ビットレートを最大にしよう。これがLinuxでFortniteのような対戦型シューターをプレイする最良の方法だ。

`omarchy install service sunshine`を実行して、Omarchyマシンをホストにすることもできる。これでSunshineがインストールされ、LANとTailscale向けにMoonlightのストリーミングポートが開かれる。

## Battle.net

Omarchyメニュー（`Super + Space`）から_Install > Gaming > Battle.net_を選んで、[Battle.net](https://eu.shop.battle.net/en-us)をインストールしよう。これで、Diablo、Starcraft、World of Warcraftといったタイトルを、GE-Protonで動くスタンドアロンのインストールとして手に入れられる。Steamも、Lutrisも、Heroicも要らない。

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris（Windowsゲーム）

Omarchyメニュー（`Super + Space`）から_Install > Gaming > Lutris_を選んで、[Lutris](https://lutris.net/)をインストールしよう。Lutrisは、EAやUbisoft Connectのように上で紹介した独自のインストーラーがないストアのWindowsゲームをプレイするための方法だ。

インストールは少しぎこちなく、時には何も起きていないように見える。ただ辛抱しよう。裏ではちゃんと動いている。

## Heroic Launcher（Epic Games）

Omarchyメニュー（`Super + Space`）から_Install > Gaming > Heroic (Epic Games)_を選んで、[Heroic Launcher](https://heroicgameslauncher.com/)をインストールしよう。Heroicでは、OddSparksのようなアンチチートに依存しないEpic Gamesのタイトルに加え、GOGやAmazon Prime Gamingのゲームも動かせる。残念ながら、それはFortniteもRocket Leagueもないということだ。Tim SweeneyがLinuxに来るまでは、これが精一杯だ。

Lutrisと同じく、ゲームのインストール中は動作が遅くぎこちなく感じることがある。時間をかけよう。
