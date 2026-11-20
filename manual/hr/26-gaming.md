# Igranje

Omarchy nije samo za _pRoDUcTiVItY_, služi i za zabavu, a što je zabavnije od igranja? Omarchy dolazi s cijelim paketom opcija za igranje — Steam i RetroArch za nativno i retro igranje, Battle.net, Lutris i Heroic za trgovine izvan Steama, Moonlight za streaming s PC-ja, Xbox Cloud Gaming + NVIDIA GeForce NOW za cloud, plus vječni Minecraft.

Zahvaljujući nevjerojatnom radu Valvea na [sloju za kompatibilnost Proton](https://en.wikipedia.org/wiki/Proton_(software)), na Linuxu je sada igrivo na desetke tisuća modernih igara. Oh, i jeste li znali da [Steam Deck](https://store.steampowered.com/steamdeck/) zapravo pokreće Arch!

Svi instalacijski programi za igre nalaze se pod _Install > Gaming_ u izborniku Omarchy (`Super + Space`). Ako neku instalaciju ikada poželite poništiti, upotrijebite _Remove > Gaming_.

## Steam

Instalirajte [Steam](https://store.steampowered.com/) odabirom _Install > Gaming > Steam_ iz izbornika Omarchy (`Super + Space`).

Nakon što ga instalirate, Steam ćete moći pokrenuti s `Super + Space`.

Imajte na umu da pokretanje Steama može potrajati 10-20 sekundi i da neće prikazati nikakvu vizualnu povratnu informaciju da se učitava.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instalirajte [RetroArch](https://www.retroarch.com/) odabirom _Install > Gaming > RetroArch_ iz izbornika Omarchy (`Super + Space`). Dolazi s kompletnim skupom jezgri libretro, pa su pokriveni svi klasični sustavi.

RetroArch je u potpunosti unaprijed konfiguriran s prekrasnim shaderom CRT Royale za savršen retro izgled.

Za početak:

1. Ubacite svoje BIOS datoteke u `~/Games/bios`, a svoje ROM-ove u `~/Games/roms`.
2. Pokrenite RetroArch s `Super + Space` i upisivanjem `retro`.
3. Skenirajte direktorij `~/Games/roms` i spremni ste za igru.

Omiljenoj igri možete dati i vlastiti unos u pokretaču aplikacija putem _Install > Gaming > RetroArch Game Launcher_, što vam omogućuje da odaberete jezgru i ROM te da ravno uskočite u igru iz `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instalirajte web-aplikaciju Xbox Cloud Gaming odabirom _Install > Gaming > Xbox Cloud Gaming_ iz izbornika Omarchy (`Super + Space`). To je "samo" web-aplikacija za tu uslugu, ali se brzo pokreće i odlično radi u 1080p.

Ako već imate Xbox Game Pass, ovo je dobar način za igranje Fortnitea i drugih naslova koje ne možete nativno pokrenuti na Linuxu.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instalirajte uslugu za igranje u oblaku [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) odabirom _Install > Gaming > NVIDIA GeForce NOW_ iz izbornika Omarchy (`Super + Space`). Još jedan odličan način za igranje naslova koji nisu dostupni nativno na Linuxu.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instalirajte Minecraft odabirom _Install > Gaming > Minecraft_ iz izbornika Omarchy (`Super + Space`).

Kao i kod Steama, imajte na umu da nakon prijave ili pokretanja može potrajati dok se ne pojavi sljedeći zaslon i da tijekom čekanja nećete dobiti nikakvu povratnu informaciju.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Instalirajte podršku za Bluetooth Xbox kontrolere odabirom _Install > Gaming > Xbox Controllers_ iz izbornika Omarchy (`Super + Space`). Uparite kontrolere putem Bluetootha (`Super + Ctrl + B`) i radit će u svim vašim igrama. Ovo vam ne treba ako kontroler samo spajate kabelom USB-C.

## Moonlight (streaming igara s PC-ja)

Instalirajte [klijent Moonlight](https://github.com/moonlight-stream/moonlight-qt) odabirom _Install > Gaming > Moonlight_ iz izbornika Omarchy (`Super + Space`) i moći ćete streamati igre s Windows PC-ja na kojem radi [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ako su i vaše Omarchy računalo i udaljeno računalo za igranje spojeni kabelom, iskustvo se ne razlikuje od lokalnog igranja. Podignite rezoluciju na nativnu, postavite osvježavanje na 120Hz i maksimalno povećajte bitrate — ovo je najbolji način za igranje kompetitivnih pucačina poput Fortnitea na Linuxu.

Omarchy računalo možete pretvoriti i u domaćina pokretanjem `omarchy install service sunshine`, čime se instalira Sunshine i otvaraju portovi za streaming Moonlight za vaš LAN i Tailscale.

## Battle.net

Instalirajte [Battle.net](https://eu.shop.battle.net/en-us) odabirom _Install > Gaming > Battle.net_ iz izbornika Omarchy (`Super + Space`). Time dobivate naslove poput Diablo, Starcraft i World of Warcraft kao samostalnu instalaciju koja radi pod GE-Proton — bez potrebe za Steamom, Lutrisom ili Heroicom.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows igre)

Instalirajte [Lutris](https://lutris.net/) odabirom _Install > Gaming > Lutris_ iz izbornika Omarchy (`Super + Space`). Lutris je način za igranje Windows igara iz trgovina poput EA i Ubisoft Connect koje nemaju vlastiti instalacijski program gore.

Instalacija je pomalo nespretna i povremeno izgleda kao da se ništa ne događa — samo budite strpljivi, radi u pozadini.

## Heroic Launcher (Epic Games)

Instalirajte [Heroic Launcher](https://heroicgameslauncher.com/) odabirom _Install > Gaming > Heroic (Epic Games)_ iz izbornika Omarchy (`Super + Space`). Heroic vam omogućuje pokretanje naslova s Epic Gamesa, poput OddSparks, koji se ne oslanjaju na anti-cheat — plus igre s GOG-a i Amazon Prime Gaminga. Nažalost, to znači bez Fortnitea i bez Rocket League — dok Tim Sweeney ne dođe na Linux, ovo je najbliže što možete dobiti.

Kao i Lutris, tijekom instaliranja igara može djelovati sporo i nespretno. Dajte mu vremena.
