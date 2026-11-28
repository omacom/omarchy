# Igranje

Omarchy nije samo za _pRoDUkTiVnOsT_, već je i za zabavu, a što je zabavnije od igranja? Omarchy dolazi s cijelim paketom opcija za igranje — Steam i RetroArch za izvorno i retro igranje, Battle.net, Lutris i Heroic za trgovine izvan Steama, Moonlight za streaming s PC-ja, Xbox Cloud Gaming + NVIDIA GeForce NOW za igranje u oblaku, plus uvijek popularni Minecraft.

Zahvaljujući nevjerojatnom radu tvrtke Valve na [Proton sloju kompatibilnosti](https://en.wikipedia.org/wiki/Proton_(software)), danas postoje deseci tisuća modernih igara koje se mogu igrati na Linuxu. Oh, a jeste li znali da [Steam Deck](https://store.steampowered.com/steamdeck/) zapravo pokreće Arch!

Svi instalacijski programi za igre nalaze se pod _Instaliraj > Igre_ u izborniku Omarchy (`Super + Space`). Ako ikada poželite poništiti neki od njih, upotrijebite _Ukloni > Igre_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris i Heroic nude se samo na x86 uređajima.

## Steam

Instalirajte [Steam](https://store.steampowered.com/) odabirom _Instaliraj > Igre > Steam_ u izborniku Omarchy (`Super + Space`).

Nakon što ga instalirate, Steam ćete moći pokrenuti pomoću `Super + Space`.

Imajte na umu da pokretanje Steama može potrajati 10-20 sekundi i da neće pružiti nikakvu vizualnu povratnu informaciju da se učitava.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instalirajte [RetroArch](https://www.retroarch.com/) odabirom _Instaliraj > Igre > RetroArch_ u izborniku Omarchy (`Super + Space`). Dolazi s kompletnim skupom jezgri libretro, pa su pokriveni svi klasični sustavi.

RetroArch je u potpunosti unaprijed konfiguriran s prekrasnim shaderom CRT Royale za taj savršeni retro izgled.

Za početak:

1. Stavite svoje BIOS datoteke u `~/Games/bios`, a svoje ROM-ove u `~/Games/roms`.
2. Pokrenite RetroArch pomoću `Super + Space` i upisivanjem `retro`.
3. Skenirajte direktorij `~/Games/roms` i spremni ste za igru.

Omiljenoj igri možete dati i vlastiti unos u pokretaču aplikacija pomoću _Instaliraj > Igre > Pokretač igara za RetroArch_, koji vam omogućuje da odaberete jezgru i ROM te izravno uskočite u igru pomoću `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instalirajte web-aplikaciju Xbox Cloud Gaming odabirom _Instaliraj > Igre > Xbox Cloud Gaming_ u izborniku Omarchy (`Super + Space`). To je "samo" web-aplikacija za tu uslugu, ali brzo se pokreće i odlično radi pri 1080p.

Ako već imate Xbox Game Pass, ovo je pouzdan način za igranje Fortnitea i drugih naslova koje ne možete izvorno pokrenuti na Linuxu.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instalirajte uslugu za igranje u oblaku [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) odabirom _Instaliraj > Igre > NVIDIA GeForce NOW_ u izborniku Omarchy (`Super + Space`). Još jedan odličan način za igranje naslova koji nisu izvorno dostupni na Linuxu.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instalirajte Minecraft odabirom _Instaliraj > Igre > Minecraft_ u izborniku Omarchy (`Super + Space`).

Kao i kod Steama, imajte na umu da nakon prijave ili pokretanja može potrajati neko vrijeme dok se ne pojavi sljedeći zaslon i da tijekom čekanja nećete dobiti nikakvu povratnu informaciju.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox kontroleri

Instalirajte podršku za Bluetooth Xbox kontrolere odabirom _Instaliraj > Igre > Xbox kontroleri_ u izborniku Omarchy (`Super + Space`). Uparite kontrolere putem Bluetootha (`Super + Ctrl + B`) i radit će u svim vašim igrama. Ovo vam ne treba ako kontroler samo povezujete žicom pomoću USB-C kabela.

## Moonlight (streaming igara s PC-ja)

Instalirajte [Moonlight klijent](https://github.com/moonlight-stream/moonlight-qt) odabirom _Instaliraj > Igre > Moonlight_ u izborniku Omarchy (`Super + Space`) i možete streamati igre s Windows PC-ja na kojem radi [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Ako su i vaš Omarchy uređaj i udaljeno računalo za igranje povezani žicom, iskustvo se ne razlikuje od igranja lokalno. Podignite rezoluciju na izvornu, postavite osvježavanje na 120Hz i maksimalno povećajte bitrate — ovo je najbolji način za igranje natjecateljskih pucačina poput Fortnitea na Linuxu.

Omarchy uređaj možete pretvoriti i u hosta pokretanjem `omarchy install service sunshine`, čime se instalira Sunshine i otvaraju portovi za Moonlight streaming za vaš LAN i Tailscale.

## Battle.net

Instalirajte [Battle.net](https://eu.shop.battle.net/en-us) odabirom _Instaliraj > Igre > Battle.net_ u izborniku Omarchy (`Super + Space`). Time dobivate naslove poput Diabla, Starcrafta i World of Warcrafta kao samostalnu instalaciju koja radi pod GE-Protonom — nije potreban Steam, Lutris ni Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows igre)

Instalirajte [Lutris](https://lutris.net/) odabirom _Instaliraj > Igre > Lutris_ u izborniku Omarchy (`Super + Space`). Lutris je način za igranje Windows igara iz trgovina poput EA i Ubisoft Connect koje nemaju vlastiti instalacijski program naveden gore.

Instalacija je pomalo nespretna i ponekad izgleda kao da se ništa ne događa — samo budite strpljivi, radi u pozadini.

## Heroic Launcher (Epic Games)

Instalirajte [Heroic Launcher](https://heroicgameslauncher.com/) odabirom _Instaliraj > Igre > Heroic (Epic Games)_ u izborniku Omarchy (`Super + Space`). Heroic vam omogućuje pokretanje naslova s Epic Gamesa, poput OddSparksa, koji se ne oslanjaju na anti-cheat — plus igre s GOG-a i Amazon Prime Gaminga. Nažalost, to znači da nema Fortnitea i nema Rocket Leaguea — dok Tim Sweeney ne dođe na Linux, ovo je najbliže tome što ćete dobiti.

Kao i Lutris, može se činiti sporim i nespretnim tijekom instalacije igara. Dajte mu vremena.
