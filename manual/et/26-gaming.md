# Mängimine

Omarchy pole mõeldud ainult _tOoTLiKKuSe_ jaoks, see on mõeldud ka lõbutsemiseks, ja mis oleks lõbusam kui mängimine? Omarchyga tuleb kaasa terve hulk mänguvõimalusi — Steam ja RetroArch kohalikuks ja retromängimiseks, Battle.net, Lutris ja Heroic mitte-Steami poodide jaoks, Moonlight arvutist striimimiseks, Xbox Cloud Gaming + NVIDIA GeForce NOW pilvemängimiseks ning lisaks igihaljas Minecraft.

Tänu Valve'i uskumatule tööle [Protoni ühilduvuskihi](https://en.wikipedia.org/wiki/Proton_(software)) kallal on Linuxis nüüd mängitavaid kaasaegseid mänge kümneid tuhandeid. Ah jaa, kas teadsid, et [Steam Deck](https://store.steampowered.com/steamdeck/) töötab tegelikult Archi peal!

Kõik mängude installerid asuvad Omarchy menüüs (`Super + Space`) jaotuses _Install > Gaming_. Kui tahad mõne neist kunagi tagasi võtta, kasuta jaotust _Remove > Gaming_.

## Steam

Installi [Steam](https://store.steampowered.com/), valides Omarchy menüüst (`Super + Space`) _Install > Gaming > Steam_.

Pärast installimist saad Steami käivitada klahvikombinatsiooniga `Super + Space`.

Pea meeles, et Steami käivitumine võib võtta 10-20 sekundit ja see ei anna mingit visuaalset märki, et see laeb.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installi [RetroArch](https://www.retroarch.com/), valides Omarchy menüüst (`Super + Space`) _Install > Gaming > RetroArch_. Sellega tuleb kaasa libretro tuumade täiskomplekt, nii et kõik klassikalised süsteemid on kaetud.

RetroArch on täielikult eelkonfigureeritud kauni CRT Royale shaderiga, et saavutada see täiuslik retrovälimus.

Alustamiseks:

1. Pane oma BIOS-failid kausta `~/Games/bios` ja ROM-id kausta `~/Games/roms`.
2. Käivita RetroArch klahvikombinatsiooniga `Super + Space` ja kirjuta `retro`.
3. Skanni kausta `~/Games/roms` ja oledki mängimiseks valmis.

Lemmikmängule saad rakenduste käivitajas anda ka oma kirje valikuga _Install > Gaming > RetroArch Game Launcher_, mis laseb sul valida tuuma ja ROM-i ning hüpata mängu otse klahvikombinatsiooniga `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installi Xbox Cloud Gamingu veebirakendus, valides Omarchy menüüst (`Super + Space`) _Install > Gaming > Xbox Cloud Gaming_. See on „lihtsalt“ teenuse veebirakendus, kuid see käivitub kiiresti ja töötab 1080p juures suurepäraselt.

Kui sul on juba Xbox Game Pass, on see kindel viis mängida Fortnite'it ja muid mänge, mida sa Linuxis kohalikult käitada ei saa.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installi pilvemänguteenus [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), valides Omarchy menüüst (`Super + Space`) _Install > Gaming > NVIDIA GeForce NOW_. Veel üks suurepärane viis mängida mänge, mis pole Linuxis kohalikult saadaval.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installi Minecraft, valides Omarchy menüüst (`Super + Space`) _Install > Gaming > Minecraft_.

Nagu Steami puhul, pea meeles, et pärast sisselogimist või käivitamist võib järgmise ekraani ilmumine aega võtta ja sa ei saa oodates mingit tagasisidet.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Installi Bluetooth Xboxi kontrollerite tugi, valides Omarchy menüüst (`Super + Space`) _Install > Gaming > Xbox Controllers_. Seo kontrollerid Bluetoothi kaudu (`Super + Ctrl + B`) ja need töötavad kõigis su mängudes. Seda pole vaja, kui ühendad kontrolleri lihtsalt USB-C kaabliga.

## Moonlight (mängude striimimine arvutist)

Installi [Moonlighti klient](https://github.com/moonlight-stream/moonlight-qt), valides Omarchy menüüst (`Super + Space`) _Install > Gaming > Moonlight_, ja saad striimida mänge Windowsi arvutist, kus töötab [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Kui nii sinu Omarchy masin kui ka kaugmänguarvuti on juhtmega ühendatud, ei erine kogemus kohalikult mängimisest. Keera eraldusvõime kohaliku tasemeni, sea värskendussageduseks 120Hz ja pane bitikiirus maksimumi — see on parim viis mängida Linuxis võistluslikke tulistamismänge nagu Fortnite.

Omarchy masina saad muuta ka hostiks, käivitades käsu `omarchy install service sunshine`, mis installib Sunshine'i ja avab Moonlighti striimimispordid sinu LAN-i ja Tailscale'i jaoks.

## Battle.net

Installi [Battle.net](https://eu.shop.battle.net/en-us), valides Omarchy menüüst (`Super + Space`) _Install > Gaming > Battle.net_. See annab sulle mängud nagu Diablo, Starcraft ja World of Warcraft eraldi installina, mis töötab GE-Protoni all — Steami, Lutrist ega Heroicut pole vaja.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windowsi mängud)

Installi [Lutris](https://lutris.net/), valides Omarchy menüüst (`Super + Space`) _Install > Gaming > Lutris_. Lutris on viis mängida Windowsi mänge poodidest nagu EA ja Ubisoft Connect, millel pole ülal oma installerit.

Installimine on natuke kohmakas ja kohati tundub, et midagi ei toimu — ole lihtsalt kannatlik, see töötab taustal.

## Heroic Launcher (Epic Games)

Installi [Heroic Launcher](https://heroicgameslauncher.com/), valides Omarchy menüüst (`Super + Space`) _Install > Gaming > Heroic (Epic Games)_. Heroic laseb sul käitada Epic Gamesi mänge, nagu OddSparks, mis ei tugine petmisvastasele kaitsele — lisaks mänge GOG-ist ja Amazon Prime Gamingust. Kahjuks tähendab see, et ei mingit Fortnite'it ega Rocket League'i — kuni Tim Sweeney Linuxisse tuleb, on see parim, mis võimalik.

Nagu Lutrise puhul, võib see mängude installimisel tunduda aeglane ja kohmakas. Anna sellele aega.
