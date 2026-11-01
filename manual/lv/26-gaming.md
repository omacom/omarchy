# Spēles

Omarchy nav paredzēts tikai _PrOdUkTiViTāTeI_, tas ir paredzēts arī jautrībai, un kas gan ir jautrāk par spēlēm? Omarchy tiek piegādāts ar veselu spēļu iespēju komplektu — Steam un RetroArch vietējām un retro spēlēm, Battle.net, Lutris un Heroic veikaliem, kas nav Steam, Moonlight datora spēļu straumēšanai, Xbox Cloud Gaming + NVIDIA GeForce NOW mākoņspēlēm, kā arī vienmēr aktuālais Minecraft.

Pateicoties Valve neticamajam darbam pie [Proton saderības slāņa](https://en.wikipedia.org/wiki/Proton_(software)), tagad Linux vidē ir spēlējamas desmitiem tūkstošu mūsdienīgu spēļu. Ak, un vai zinājāt, ka [Steam Deck](https://store.steampowered.com/steamdeck/) patiesībā darbojas uz Arch!

Visi spēļu instalētāji atrodas Omarchy izvēlnē (`Super + Space`) sadaļā _Instalēt > Gaming_. Ja kādreiz vēlaties kādu no tiem atsaukt, izmantojiet _Noņemt > Gaming_.

## Steam

Instalējiet [Steam](https://store.steampowered.com/), Omarchy izvēlnē (`Super + Space`) atlasot _Instalēt > Gaming > Steam_.

Kad tas būs instalēts, Steam varēsiet palaist ar `Super + Space`.

Ievērojiet, ka Steam palaišana var aizņemt 10–20 sekundes un tas nesniegs nekādu vizuālu pazīmi par to, ka veic ielādi.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instalējiet [RetroArch](https://www.retroarch.com/), Omarchy izvēlnē (`Super + Space`) atlasot _Instalēt > Gaming > RetroArch_. Tam nāk līdzi pilns libretro kodolu komplekts, tāpēc visas klasiskās sistēmas ir aptvertas.

RetroArch ir pilnībā iepriekš konfigurēts ar skaistu CRT Royale ēnotāju, lai iegūtu to perfekto retro izskatu.

Lai sāktu darbu:

1. BIOS failus iemetiet mapē `~/Games/bios`, bet ROM failus — mapē `~/Games/roms`.
2. Palaidiet RetroArch ar `Super + Space` un ierakstiet `retro`.
3. Skenējiet direktoriju `~/Games/roms`, un esat gatavs spēlēt.

Iecienītajai spēlei varat piešķirt arī savu ierakstu lietotņu palaidējā ar _Instalēt > Gaming > RetroArch Game Launcher_, kas ļauj izvēlēties kodolu un ROM un pārlēkt tieši spēlē ar `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instalējiet Xbox Cloud Gaming tīmekļa lietotni, Omarchy izvēlnē (`Super + Space`) atlasot _Instalēt > Gaming > Xbox Cloud Gaming_. Tā ir “tikai” pakalpojuma tīmekļa lietotne, taču tā ātri sākas un lieliski darbojas 1080p izšķirtspējā.

Ja jums jau ir Xbox Game Pass, tas ir pamatīgs veids, kā spēlēt Fortnite un citus nosaukumus, kurus Linux vidē nevar darbināt vietēji.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instalējiet mākoņspēļu pakalpojumu [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), Omarchy izvēlnē (`Super + Space`) atlasot _Instalēt > Gaming > NVIDIA GeForce NOW_. Vēl viens lielisks veids, kā spēlēt nosaukumus, kas Linux vidē nav pieejami vietēji.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instalējiet Minecraft, Omarchy izvēlnē (`Super + Space`) atlasot _Instalēt > Gaming > Minecraft_.

Tāpat kā Steam gadījumā, ievērojiet, ka pēc pierakstīšanās vai palaišanas var paiet kāds laiks, līdz parādās nākamais ekrāns, un gaidīšanas laikā jūs nesaņemsiet nekādu atgriezenisko saiti.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox pultis

Instalējiet Bluetooth Xbox pulšu atbalstu, Omarchy izvēlnē (`Super + Space`) atlasot _Instalēt > Gaming > Xbox Controllers_. Sapārojiet pultis caur Bluetooth (`Super + Ctrl + B`), un tās darbosies visās jūsu spēlēs. Tas jums nav nepieciešams, ja pulti vienkārši pievienojat ar USB-C kabeli.

## Moonlight (spēļu straumēšana no datora)

[Moonlight klients](https://github.com/moonlight-stream/moonlight-qt) Omarchy ir iepriekš instalēts, tāpēc varat uzreiz straumēt spēles no Windows datora, kurā darbojas [Sunshine](https://app.lizardbyte.dev/Sunshine/). Palaidiet Moonlight ar `Super + Space`.

Ja gan jūsu Omarchy dators, gan attālinātais spēļu dators ir pievienoti ar vadu, pieredze neatšķiras no spēlēšanas uz vietas. Paceliet izšķirtspēju līdz vietējai, atsvaidzināšanas biežumu iestatiet uz 120 Hz un bitu pārraides ātrumu uzstādiet maksimālo — tas ir labākais veids, kā Linux vidē spēlēt sacensību šāvējus, piemēram, Fortnite.

Omarchy datoru varat pārvērst arī par resursdatoru, palaižot `omarchy install service sunshine`, kas instalē Sunshine un atver Moonlight straumēšanas portus jūsu lokālajam tīklam un Tailscale.

## Battle.net

Instalējiet [Battle.net](https://eu.shop.battle.net/en-us), Omarchy izvēlnē (`Super + Space`) atlasot _Instalēt > Gaming > Battle.net_. Tas sniedz jums tādus nosaukumus kā Diablo, Starcraft un World of Warcraft kā patstāvīgu instalāciju, kas darbojas zem GE-Proton — Steam, Lutris vai Heroic nav nepieciešami.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows spēles)

Instalējiet [Lutris](https://lutris.net/), Omarchy izvēlnē (`Super + Space`) atlasot _Instalēt > Gaming > Lutris_. Lutris ir veids, kā spēlēt Windows spēles no tādiem veikaliem kā EA un Ubisoft Connect, kuriem iepriekš nav sava instalētāja.

Instalēšana ir nedaudz neveikla, un reizēm izskatās, ka nekas nenotiek — vienkārši esiet pacietīgs, tas fonā darbojas.

## Heroic Launcher (Epic Games)

Instalējiet [Heroic Launcher](https://heroicgameslauncher.com/), Omarchy izvēlnē (`Super + Space`) atlasot _Instalēt > Gaming > Heroic (Epic Games)_. Heroic ļauj darbināt Epic Games nosaukumus, piemēram, OddSparks, kuri nav atkarīgi no krāpšanās apkarošanas (anti-cheat), — turklāt arī spēles no GOG un Amazon Prime Gaming. Diemžēl tas nozīmē, ka nav ne Fortnite, ne Rocket League — kamēr Tim Sweeney nenāks pie Linux, tuvāk tam tikt nevar.

Tāpat kā Lutris, arī Heroic spēļu instalēšanas laikā var šķist lēns un neveikls. Dodiet tam laiku.
