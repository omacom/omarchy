# Spēles

Omarchy nav paredzēts tikai _pRoDuKtIvItĀtEi_, tas ir paredzēts arī izklaidei, un kas gan ir jautrāks par spēlēm? Omarchy komplektā ir vesels spēļu iespēju klāsts — Steam un RetroArch vietējai un retro spēlēšanai, Battle.net, Lutris un Heroic veikaliem ārpus Steam, Moonlight straumēšanai no PC, Xbox Cloud Gaming + NVIDIA GeForce NOW mākonim, kā arī mūžzaļais Minecraft.

Pateicoties Valve neticamajam darbam pie [proton saderības slāņa](https://en.wikipedia.org/wiki/Proton_(software)), tagad Linux sistēmā ir spēlējami desmitiem tūkstošu mūsdienīgu spēļu. Ak, un vai zinājāt, ka [Steam Deck](https://store.steampowered.com/steamdeck/) patiesībā darbojas ar Arch!

Visi spēļu instalētāji atrodas Omarchy izvēlnē (`Super + Space`) sadaļā _Install > Gaming_. Ja kādreiz vēlaties kādu no tiem atsaukt, izmantojiet _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris un Heroic tiek piedāvāti tikai x86 datoros.

## Steam

Instalējiet [Steam](https://store.steampowered.com/), Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > Steam_.

Pēc instalēšanas Steam varēsiet palaist ar `Super + Space`.

Ņemiet vērā, ka Steam startēšanās var aizņemt 10-20 sekundes, un tas nesniegs nekādu vizuālu atgriezenisko saiti, ka tas ielādējas.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instalējiet [RetroArch](https://www.retroarch.com/), Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > RetroArch_. Tas tiek piegādāts ar pilnu libretro kodolu komplektu, tāpēc visas klasiskās sistēmas ir iekļautas.

RetroArch ir pilnībā iepriekš konfigurēts ar skaisto CRT Royale shader, lai iegūtu ideālu retro izskatu.

Lai sāktu:

1. Ievietojiet savus BIOS failus mapē `~/Games/bios` un savus ROM mapē `~/Games/roms`.
2. Palaidiet RetroArch ar `Super + Space` un ierakstiet `retro`.
3. Skenējiet direktoriju `~/Games/roms`, un esat gatavs spēlēt.

Mīļākajai spēlei varat arī piešķirt atsevišķu ierakstu lietotņu palaidējā, izmantojot _Install > Gaming > RetroArch Game Launcher_, kas ļauj izvēlēties kodolu un ROM un uzreiz pāriet uz spēli no `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instalējiet Xbox Cloud Gaming tīmekļa lietotni, Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > Xbox Cloud Gaming_. Tā ir "tikai" tīmekļa lietotne šim pakalpojumam, bet to var ātri palaist un tā lieliski darbojas 1080p izšķirtspējā.

Ja jums jau ir Xbox Game Pass, tas ir labs veids, kā spēlēt Fortnite un citas spēles, kuras nevarat palaist vietēji Linux sistēmā.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instalējiet mākoņspēļu pakalpojumu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > NVIDIA GeForce NOW_. Vēl viens lielisks veids, kā spēlēt spēles, kas Linux sistēmā nav pieejamas vietēji.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instalējiet Minecraft, Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > Minecraft_.

Tāpat kā Steam gadījumā, ņemiet vērā, ka pēc pieteikšanās vai startēšanas var paiet kāds laiks, līdz parādās nākamais ekrāns, un gaidīšanas laikā jūs nesaņemsiet nekādu atgriezenisko saiti.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox kontrolieri

Instalējiet Bluetooth Xbox kontrolieru atbalstu, Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > Xbox Controllers_. Savienojiet kontrolierus pārī, izmantojot Bluetooth (`Super + Ctrl + B`), un tie darbosies visās jūsu spēlēs. Tas nav nepieciešams, ja kontrolieri vienkārši pievienojat ar USB-C kabeli.

## Moonlight (spēļu straumēšana no PC)

Instalējiet [Moonlight client](https://github.com/moonlight-stream/moonlight-qt), Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > Moonlight_, un varēsiet straumēt spēles no Windows PC, kurā darbojas [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ja gan jūsu Omarchy dators, gan attālais spēļu PC ir savienoti ar vadu, pieredze neatšķiras no spēlēšanas lokāli. Iestatiet izšķirtspēju uz vietējo, atsvaidzi uz 120Hz un bitu ātrumu uz maksimālo — tas ir labākais veids, kā spēlēt sacensību šauteurspēles, piemēram, Fortnite, Linux sistēmā.

Varat arī pārvērst Omarchy datoru par resursdatoru, palaižot `omarchy install service sunshine`, kas instalē Sunshine un atver Moonlight straumēšanas portus jūsu LAN un Tailscale.

## Battle.net

Instalējiet [Battle.net](https://eu.shop.battle.net/en-us), Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > Battle.net_. Tas sniedz jums tādas spēles kā Diablo, Starcraft un World of Warcraft kā atsevišķu instalāciju, kas darbojas ar GE-Proton — Steam, Lutris vai Heroic nav nepieciešami.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows spēles)

Instalējiet [Lutris](https://lutris.net/), Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > Lutris_. Lutris ir veids, kā spēlēt Windows spēles no veikaliem, piemēram, EA un Ubisoft Connect, kuriem augstāk nav sava instalētāja.

Instalēšana ir nedaudz neveikla, un brīžiem izskatās, ka nekas nenotiek — vienkārši esiet pacietīgi, tas darbojas fonā.

## Heroic Launcher (Epic Games)

Instalējiet [Heroic Launcher](https://heroicgameslauncher.com/), Omarchy izvēlnē (`Super + Space`) izvēloties _Install > Gaming > Heroic (Epic Games)_. Heroic ļauj palaist Epic Games spēles, piemēram, OddSparks, kuras nav atkarīgas no anti-cheat — kā arī spēles no GOG un Amazon Prime Gaming. Diemžēl tas nozīmē nekādu Fortnite un nekādu Rocket League — kamēr Tim Sweeney nenāks uz Linux, tuvāk tam tikt nevar.

Tāpat kā Lutris gadījumā, spēļu instalēšanas laikā tas var šķist lēns un neveikls. Dodiet tam laiku.
