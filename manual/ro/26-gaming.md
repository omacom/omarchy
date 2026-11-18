# Jocuri

Omarchy nu este doar pentru _pRoDUcTiVItAtE_, este și pentru distracție, iar ce este mai distractiv decât jocurile? Omarchy vine cu o întreagă suită de opțiuni pentru jocuri — Steam și RetroArch pentru jocuri native și retro, Battle.net, Lutris și Heroic pentru magazinele din afara Steam, Moonlight pentru streaming de pe PC, Xbox Cloud Gaming + NVIDIA GeForce NOW pentru cloud, plus veșnicul Minecraft.

Mulțumită muncii incredibile depuse de Valve la [stratul de compatibilitate Proton](https://en.wikipedia.org/wiki/Proton_(software)), acum există zeci de mii de jocuri moderne care pot fi jucate pe Linux. Ah, și știai că [Steam Deck](https://store.steampowered.com/steamdeck/) rulează, de fapt, Arch!

Toate programele de instalare pentru jocuri se află sub _Install > Gaming_ în meniul Omarchy (`Super + Space`). Dacă vrei vreodată să anulezi una dintre instalări, folosește _Remove > Gaming_.

## Steam

Instalează [Steam](https://store.steampowered.com/) selectând _Install > Gaming > Steam_ din meniul Omarchy (`Super + Space`).

După ce l-ai instalat, vei putea lansa Steam cu `Super + Space`.

Reține că Steam poate avea nevoie de 10-20 de secunde pentru a porni și nu îți va oferi niciun feedback vizual că se încarcă.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instalează [RetroArch](https://www.retroarch.com/) selectând _Install > Gaming > RetroArch_ din meniul Omarchy (`Super + Space`). Vine cu setul complet de nuclee libretro, așa că toate sistemele clasice sunt acoperite.

RetroArch este complet preconfigurat cu frumosul shader CRT Royale pentru acel aspect retro perfect.

Pentru a începe:

1. Pune fișierele BIOS în `~/Games/bios` și ROM-urile în `~/Games/roms`.
2. Lansează RetroArch cu `Super + Space` și tastând `retro`.
3. Scanează directorul `~/Games/roms` și ești gata de joacă.

De asemenea, poți oferi unui joc preferat propria intrare în lansatorul de aplicații cu _Install > Gaming > RetroArch Game Launcher_, care îți permite să alegi un nucleu și un ROM și să sari direct în joc din `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instalează aplicația web Xbox Cloud Gaming selectând _Install > Gaming > Xbox Cloud Gaming_ din meniul Omarchy (`Super + Space`). Este „doar” o aplicație web pentru serviciu, dar pornește rapid și merge grozav la 1080p.

Dacă ai deja Xbox Game Pass, acesta este un mod solid de a juca Fortnite și alte titluri pe care nu le poți rula nativ pe Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instalează serviciul de cloud gaming [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) selectând _Install > Gaming > NVIDIA GeForce NOW_ din meniul Omarchy (`Super + Space`). O altă modalitate excelentă de a juca titluri care nu sunt disponibile nativ pe Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instalează Minecraft selectând _Install > Gaming > Minecraft_ din meniul Omarchy (`Super + Space`).

Ca și Steam, reține că poate dura ceva timp după autentificare sau pornire până apare următorul ecran și nu vei primi niciun feedback în timp ce aștepți.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Instalează suportul pentru controllere Xbox Bluetooth selectând _Install > Gaming > Xbox Controllers_ din meniul Omarchy (`Super + Space`). Asociază controllerele prin Bluetooth (`Super + Ctrl + B`) și vor funcționa în toate jocurile tale. Nu ai nevoie de acest lucru dacă îți conectezi controllerul direct cu un cablu USB-C.

## Moonlight (Streaming de jocuri de pe un PC)

Instalează [clientul Moonlight](https://github.com/moonlight-stream/moonlight-qt) selectând _Install > Gaming > Moonlight_ din meniul Omarchy (`Super + Space`) și poți reda în streaming jocuri de pe un PC cu Windows care rulează [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Dacă atât mașina ta cu Omarchy, cât și PC-ul de gaming la distanță sunt conectate prin cablu, experiența nu se poate distinge de jocul local. Ridică rezoluția la cea nativă, setează rata de reîmprospătare la 120Hz și maximizează bitrate-ul — acesta este cel mai bun mod de a juca shootere competitive precum Fortnite pe Linux.

De asemenea, poți transforma o mașină cu Omarchy în gazdă rulând `omarchy install service sunshine`, care instalează Sunshine și deschide porturile de streaming Moonlight pentru LAN-ul și Tailscale-ul tău.

## Battle.net

Instalează [Battle.net](https://eu.shop.battle.net/en-us) selectând _Install > Gaming > Battle.net_ din meniul Omarchy (`Super + Space`). Acesta îți oferă titluri precum Diablo, Starcraft și World of Warcraft ca instalare independentă care rulează sub GE-Proton — nu este nevoie de Steam, Lutris sau Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Jocuri Windows)

Instalează [Lutris](https://lutris.net/) selectând _Install > Gaming > Lutris_ din meniul Omarchy (`Super + Space`). Lutris este modul de a juca jocuri Windows din magazine precum EA și Ubisoft Connect care nu au propriul program de instalare mai sus.

Instalarea este puțin anevoioasă și pare că nu se întâmplă nimic pe alocuri — ai doar răbdare, lucrează în fundal.

## Heroic Launcher (Epic Games)

Instalează [Heroic Launcher](https://heroicgameslauncher.com/) selectând _Install > Gaming > Heroic (Epic Games)_ din meniul Omarchy (`Super + Space`). Heroic îți permite să rulezi titluri Epic Games, precum OddSparks, care nu se bazează pe anti-cheat — plus jocuri de pe GOG și Amazon Prime Gaming. Din păcate, asta înseamnă fără Fortnite și fără Rocket League — până când Tim Sweeney nu vine pe Linux, atât de aproape se poate ajunge.

Ca și Lutris, poate părea lent și anevoios în timp ce instalează jocuri. Acordă-i timp.
