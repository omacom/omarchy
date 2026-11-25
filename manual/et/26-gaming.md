# Mängimine

Omarchy pole mõeldud ainult _pRoDUcTiVItY_ jaoks, see on ka lõbutsemiseks ja mis oleks lõbusam kui mängimine? Omarchyga tuleb kaasa terve hulk mängimisvõimalusi — Steam ja RetroArch kohalike ja retromängude jaoks, Battle.net, Lutris ja Heroic mitte-Steami poodide jaoks, Moonlight arvutist striimimiseks, Xbox Cloud Gaming + NVIDIA GeForce NOW pilvemängudeks, lisaks igihaljas Minecraft.

Tänu Valve'i uskumatule tööle [Protoni ühilduvuskihiga](https://en.wikipedia.org/wiki/Proton_(software)) on Linuxil nüüd kümneid tuhandeid mängitavaid kaasaegseid mänge. Ja kas teadsid, et [Steam Deck](https://store.steampowered.com/steamdeck/) töötab tegelikult Archi peal!

Kõik mängude paigaldajad asuvad Omarchy menüüs (`Super + Space`) jaotuses _Paigalda > Mängimine_. Kui tahad mõne neist kunagi tagasi võtta, kasuta jaotust _Eemalda > Mängimine_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris ja Heroic on saadaval ainult x86 masinatel.

## Steam

Paigalda [Steam](https://store.steampowered.com/) valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > Steam_.

Pärast paigaldamist saad Steami käivitada `Super + Space` abil.

Pea meeles, et Steami käivitumine võib võtta 10-20 sekundit ja see ei anna mingit visuaalset märku, et see laadib.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Paigalda [RetroArch](https://www.retroarch.com/) valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > RetroArch_. Sellega tuleb kaasa kogu libretro tuumade komplekt, nii et kõik klassikalised süsteemid on kaetud.

RetroArch on täielikult eelkonfigureeritud kauni CRT Royale shaderiga selle täiusliku retro välimuse jaoks.

Alustamiseks:

1. Pane oma BIOS-failid kausta `~/Games/bios` ja ROM-id kausta `~/Games/roms`.
2. Käivita RetroArch `Super + Space` abil ja tippides `retro`.
3. Skanni `~/Games/roms` kataloogi ja oledki mängimiseks valmis.

Sa saad oma lemmikmängule anda ka rakenduste käivitajas oma kirje valikuga _Paigalda > Mängimine > RetroArch Game Launcher_, mis laseb sul valida tuuma ja ROM-i ning hüpata `Super + Space` kaudu otse mängu.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Paigalda Xbox Cloud Gaming veebirakendus valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > Xbox Cloud Gaming_. See on „lihtsalt“ teenuse veebirakendus, aga käivitub kiiresti ja töötab 1080p juures suurepäraselt.

Kui sul on juba Xbox Game Pass, on see kindel viis mängida Fortnite'it ja teisi mänge, mida sa Linuxil natiivselt jooksutada ei saa.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Paigalda pilvemänguteenus [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > NVIDIA GeForce NOW_. Teine suurepärane viis mängida mänge, mis pole Linuxil natiivselt saadaval.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Paigalda Minecraft valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > Minecraft_.

Steami sarnaselt pea meeles, et pärast sisselogimist või käivitamist võib järgmise ekraani ilmumine aega võtta ja sa ei saa ootamise ajal mingit tagasisidet.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xboxi kontrollerid

Paigalda Bluetooth Xboxi kontrollerite tugi valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > Xbox Controllers_. Paarista kontrollerid Bluetoothi kaudu (`Super + Ctrl + B`) ja need töötavad kõigis su mängudes. Seda pole vaja, kui ühendad kontrolleri lihtsalt USB-C kaabliga.

## Moonlight (mängude striimimine arvutist)

Paigalda [Moonlight klient](https://github.com/moonlight-stream/moonlight-qt) valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > Moonlight_ ja saad striimida mänge Windowsi arvutist, kus töötab [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Kui nii su Omarchy masin kui ka kaugmänguarvuti on juhtmega ühendatud, on kogemus kohalikust mängimisest eristamatu. Keera resolutsioon natiivse peale, sea värskendussagedus 120Hz peale ja pane bitikiirus maksimumi — see on parim viis mängida Linuxil võistluslikke tulistamismänge nagu Fortnite.

Saad Omarchy masina muuta ka hostiks, käivitades `omarchy install service sunshine`, mis paigaldab Sunshine'i ja avab Moonlighti striimimisepordid su LAN-i ja Tailscale'i jaoks.

## Battle.net

Paigalda [Battle.net](https://eu.shop.battle.net/en-us) valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > Battle.net_. See annab sulle mängud nagu Diablo, Starcraft ja World of Warcraft eraldiseisva paigaldusena, mis töötab GE-Proton all — Steami, Lutrist ega Heroicut pole vaja.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windowsi mängud)

Paigalda [Lutris](https://lutris.net/) valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > Lutris_. Lutris on viis mängida Windowsi mänge poodidest nagu EA ja Ubisoft Connect, millel pole ülal oma paigaldajat.

Paigaldamine on natuke kohmakas ja kohati tundub, et midagi ei toimu — ole lihtsalt kannatlik, see töötab taustal.

## Heroic Launcher (Epic Games)

Paigalda [Heroic Launcher](https://heroicgameslauncher.com/) valides Omarchy menüüst (`Super + Space`) _Paigalda > Mängimine > Heroic (Epic Games)_. Heroic laseb sul jooksutada Epic Gamesi mänge, nagu OddSparks, mis ei tugine petmisvastasele kaitsele — pluss mänge GOG-ist ja Amazon Prime Gamingust. Kahjuks tähendab see, et ei mingit Fortnite'it ega Rocket League'i — kuni Tim Sweeney Linuxile ei tule, on see nii lähedal kui võimalik.

Nagu Lutrisegi puhul, võib mängude paigaldamine tunduda aeglane ja kohmakas. Anna sellele aega.
