# Mängimine

Omarchy pole ainult _pRoDUcTiVItY_ jaoks, see on ka lõbutsemiseks, ja mis on lõbusam kui mängimine? Omarchy tuleb terve mängimisvalikute komplektiga — Steam ja RetroArch natiivseks ja retromänguks, Battle.net, Lutris ja Heroic Steamivälistele poodidele, Moonlight arvuti voogedastuseks, Xbox Cloud Gaming + NVIDIA GeForce NOW pilve jaoks, pluss igihaljas Minecraft.

Tänu Valve'i uskumatusle tööle [proton ühilduvuskihiga](https://en.wikipedia.org/wiki/Proton_(software)) on Linuxis nüüd kümneid tuhandeid mängitavaid kaasaegseid mänge. Ah, ja kas teadsid, et [Steam Deck](https://store.steampowered.com/steamdeck/) töötab tegelikult Archil!

Kõik mängude paigaldajad elavad Omarchy menüüs (`Super + Space`) jaotises _Paigalda > Gaming_. Kui soovid kunagi ühe tagasi võtta, kasuta _Eemalda > Gaming_.

## Steam

Paigalda [Steam](https://store.steampowered.com/), valides Omarchy menüüst (`Super + Space`) _Paigalda > Gaming > Steam_.

Pärast selle paigaldamist saad Steami käivitada kombinatsiooniga `Super + Space`.

Pane tähele, et Steami käivitamine võib võtta 10-20 sekundit ja see ei anna visuaalset tagasisidet, et see laeb.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Paigalda [RetroArch](https://www.retroarch.com/), valides Omarchy menüüst (`Super + Space`) _Paigalda > Gaming > RetroArch_. See tuleb libretro tuumade täiskomplektiga, nii et kõik klassikalised süsteemid on kaetud.

RetroArch on täielikult eelkonfigureeritud kauni CRT Royale varjutajaga täiusliku retro välimuse jaoks.

Alustamiseks:

1. Pane oma BIOS-failid kausta `~/Games/bios` ja ROM-id kausta `~/Games/roms`.
2. Käivita RetroArch kombinatsiooniga `Super + Space` ja sisesta `retro`.
3. Skanni kaust `~/Games/roms` ja oled mängimiseks valmis.

Saad anda lemmikmängule ka oma kirje rakenduste käivitajas jaotisega _Paigalda > Gaming > RetroArch Game Launcher_, mis võimaldab valida tuuma ja ROM-i ning hüpata otse mängu kombinatsioonist `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Paigalda Xbox Cloud Gaming veebirakendus, valides Omarchy menüüst (`Super + Space`) _Paigalda > Gaming > Xbox Cloud Gaming_. See on "lihtsalt" teenuse veebirakendus, kuid seda on kiire käivitada ja see töötab 1080p juures suurepäraselt.

Kui sul on juba Xbox Game Pass, on see kindel viis mängida Fortnite'i ja teisi pealkirju, mida sa Linuxis natiivselt käitada ei saa.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Paigalda pilvemänguteenuse [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), valides Omarchy menüüst (`Super + Space`) _Paigalda > Gaming > NVIDIA GeForce NOW_. Veel üks suurepärane viis mängida pealkirju, mis pole Linuxis natiivselt saadaval.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Paigalda Minecraft, valides Omarchy menüüst (`Super + Space`) _Paigalda > Gaming > Minecraft_.

Nagu Steam, pane tähele, et pärast sisselogimist või käivitamist võib järgmise ekraani ilmumine veidi aega võtta ja sa ei saa oodates mingit tagasisidet.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox kontrollerid

Paigalda Bluetooth Xbox kontrollerite tugi, valides Omarchy menüüst (`Super + Space`) _Paigalda > Gaming > Xbox Controllers_. Seo kontrollerid Bluetoothi kaudu (`Super + Ctrl + B`) ja need töötavad kõigis sinu mängudes. Seda pole vaja, kui ühendad kontrolleri lihtsalt USB-C kaabliga.

## Moonlight (mängu voogedastus arvutist)

[Moonlight klient](https://github.com/moonlight-stream/moonlight-qt) on Omarchysse eelpaigaldatud, nii et saad kohe voogedastada mänge Windowsi arvutist, kus töötab [Sunshine](https://app.lizardbyte.dev/Sunshine/). Käivita Moonlight kombinatsiooniga `Super + Space`.

Kui nii sinu Omarchy masin kui ka kauge mänguarvuti on juhtmega ühendatud, on kogemus kohalikult mängimisest eristamatu. Keera eraldusvõime natiivsele, määra värskendus 120Hz-le ja maksimeeri bitikiirus — see on parim viis mängida Linuxis võistluslikke tulistamismänge nagu Fortnite.

Saad Omarchy masina muuta ka hostiks, käivitades `omarchy install service sunshine`, mis paigaldab Sunshine'i ja avab Moonlighti voogedastuspordid sinu LAN-i ja Tailscale'i jaoks.

## Battle.net

Paigalda [Battle.net](https://eu.shop.battle.net/en-us), valides Omarchy menüüst (`Super + Space`) _Paigalda > Gaming > Battle.net_. See annab sulle pealkirjad nagu Diablo, Starcraft ja World of Warcraft iseseisva paigaldusena, mis töötab GE-Protoni all — Steami, Lutrisit ega Heroicut pole vaja.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windowsi mängud)

Paigalda [Lutris](https://lutris.net/), valides Omarchy menüüst (`Super + Space`) _Paigalda > Gaming > Lutris_. Lutris on viis mängida Windowsi mänge poodidest nagu EA ja Ubisoft Connect, millel pole ülal oma paigaldajat.

Paigaldamine on veidi kohmakas ja tundub kohati, et midagi ei toimu — ole lihtsalt kannatlik, see töötab taustal.

## Heroic Launcher (Epic Games)

Paigalda [Heroic Launcher](https://heroicgameslauncher.com/), valides Omarchy menüüst (`Super + Space`) _Paigalda > Gaming > Heroic (Epic Games)_. Heroic võimaldab sul käitada Epic Gamesi pealkirju, nagu OddSparks, mis ei tugine petmisvastasele — pluss mänge GOG-ist ja Amazon Prime Gamingust. Kahjuks tähendab see, et pole Fortnite'i ega Rocket League'i — kuni Tim Sweeney Linuxile tuleb, on see nii lähedal kui võimalik.

Nagu Lutris, võib see mängude paigaldamise ajal tunduda aeglane ja kohmakas. Anna sellele aega.
