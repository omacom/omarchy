# Spēles

Omarchy nav domāts tikai _pRoDUkTiViTāTeI_, tas ir domāts arī izklaidei, un kas gan var būt izklaidējošāks par spēlēm? Omarchy komplektā ir vesels spēļu iespēju klāsts — Steam un RetroArch vietējai un retro spēlēšanai, Battle.net, Lutris un Heroic citiem veikaliem ārpus Steam, Moonlight straumēšanai no PC, Xbox Cloud Gaming + NVIDIA GeForce NOW mākoņspēlēm, kā arī mūžīgais Minecraft.

Pateicoties Valve neticamajam darbam pie [proton saderības slāņa](https://en.wikipedia.org/wiki/Proton_(software)), tagad Linux platformā ir desmitiem tūkstošu spēlējamu mūsdienu spēļu. Ak, un vai tu zināji, ka [Steam Deck](https://store.steampowered.com/steamdeck/) patiesībā darbojas ar Arch!

Visi spēļu instalētāji atrodas Omarchy izvēlnē (`Super + Space`) sadaļā _Install > Gaming_. Ja kādreiz vēlēsies kādu atinstalēt, izmanto _Remove > Gaming_.

## Steam

Instalē [Steam](https://store.steampowered.com/), Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > Steam_.

Pēc instalēšanas varēsi palaist Steam ar `Super + Space`.

Ņem vērā, ka Steam palaišana var aizņemt 10-20 sekundes un tas nesniegs nekādu vizuālu atgriezenisko saiti, ka notiek ielāde.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instalē [RetroArch](https://www.retroarch.com/), Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > RetroArch_. Tas nāk kopā ar pilnu libretro kodolu komplektu, tāpēc visas klasiskās sistēmas ir nodrošinātas.

RetroArch ir pilnībā iepriekš konfigurēts ar skaisto CRT Royale šeideri, lai iegūtu perfektu retro izskatu.

Lai sāktu:

1. Ievieto savus BIOS failus `~/Games/bios` un savus ROM failus `~/Games/roms`.
2. Palaid RetroArch ar `Super + Space` un ieraksti `retro`.
3. Skenē `~/Games/roms` direktoriju, un vari sākt spēlēt.

Tu vari arī piešķirt iecienītajai spēlei atsevišķu ierakstu lietotņu palaišanas rīkā ar _Install > Gaming > RetroArch Game Launcher_, kas ļauj izvēlēties kodolu un ROM un no `Super + Space` uzreiz pāriet spēlē.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instalē Xbox Cloud Gaming tīmekļa lietotni, Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > Xbox Cloud Gaming_. Tā ir „tikai” pakalpojuma tīmekļa lietotne, bet tā ātri startējas un lieliski darbojas 1080p izšķirtspējā.

Ja tev jau ir Xbox Game Pass, šis ir labs veids, kā spēlēt Fortnite un citas spēles, kuras nevar palaist vietēji Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instalē mākoņspēļu pakalpojumu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > NVIDIA GeForce NOW_. Vēl viens lielisks veids, kā spēlēt spēles, kas Linux nav pieejamas vietēji.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instalē Minecraft, Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > Minecraft_.

Tāpat kā Steam gadījumā, ņem vērā, ka pēc pieteikšanās vai palaišanas nākamā ekrāna parādīšanās var kādu laiku aizkavēties, un gaidīšanas laikā tu nesaņemsi nekādu atgriezenisko saiti.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox kontrolieri

Instalē atbalstu Bluetooth Xbox kontrolieriem, Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > Xbox Controllers_. Savieno kontrolierus pārī, izmantojot Bluetooth (`Super + Ctrl + B`), un tie darbosies visās tavās spēlēs. Tas tev nav nepieciešams, ja kontrolieri vienkārši pievieno ar vadu, izmantojot USB-C kabeli.

## Moonlight (spēļu straumēšana no PC)

Instalē [Moonlight klientu](https://github.com/moonlight-stream/moonlight-qt), Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > Moonlight_, un tu vari straumēt spēles no Windows PC, kurā darbojas [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ja gan tava Omarchy iekārta, gan attālais spēļu PC ir pievienoti ar vadu, pieredze neatšķirsies no spēlēšanas lokāli. Uzgriez izšķirtspēju līdz vietējai, iestati atsvaidzi uz 120Hz un maksimāli palielini bitreitu — tas ir labākais veids, kā Linux spēlēt sacensību šāvējus, piemēram, Fortnite.

Tu vari arī pārvērst Omarchy iekārtu par resursdatoru, palaižot `omarchy install service sunshine`, kas instalē Sunshine un atver Moonlight straumēšanas portus tavam LAN un Tailscale.

## Battle.net

Instalē [Battle.net](https://eu.shop.battle.net/en-us), Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > Battle.net_. Tas nodrošina tādas spēles kā Diablo, Starcraft un World of Warcraft kā atsevišķu instalāciju, kas darbojas ar GE-Proton — Steam, Lutris vai Heroic nav nepieciešams.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows spēles)

Instalē [Lutris](https://lutris.net/), Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > Lutris_. Lutris ir veids, kā spēlēt Windows spēles no veikaliem, piemēram, EA un Ubisoft Connect, kuriem iepriekš nav sava instalētāja.

Instalēšana ir nedaudz neveikla, un brīžiem šķiet, ka nekas nenotiek — vienkārši esi pacietīgs, tā darbojas fonā.

## Heroic Launcher (Epic Games)

Instalē [Heroic Launcher](https://heroicgameslauncher.com/), Omarchy izvēlnē (`Super + Space`) atlasot _Install > Gaming > Heroic (Epic Games)_. Heroic ļauj palaist Epic Games spēles, piemēram, OddSparks, kas nepaļaujas uz anti-cheat, — kā arī spēles no GOG un Amazon Prime Gaming. Diemžēl tas nozīmē nekādu Fortnite un nekādu Rocket League — kamēr Tim Sweeney nenāks uz Linux, tuvāk tam tikt nevar.

Tāpat kā Lutris, tas spēļu instalēšanas laikā var šķist lēns un neveikls. Dod tam laiku.
