# Jocuri

Omarchy nu e doar pentru _pRoDuCtIvItAtE_, e și pentru distracție, iar ce e mai distractiv decât jocurile? Omarchy vine cu o întreagă suită de opțiuni de gaming — Steam și RetroArch pentru jocuri native și retro, Battle.net, Lutris și Heroic pentru magazine din afara Steam, Moonlight pentru streaming de pe PC, Xbox Cloud Gaming + NVIDIA GeForce NOW pentru cloud, plus veșnicul verde Minecraft.

Datorită muncii incredibile depuse de Valve la [stratul de compatibilitate Proton](https://en.wikipedia.org/wiki/Proton_(software)), acum există zeci de mii de jocuri moderne care pot fi jucate pe Linux. Ah, și știai că [Steam Deck](https://store.steampowered.com/steamdeck/) rulează de fapt Arch!

Toate programele de instalare pentru jocuri se află sub _Instalare > Jocuri_ în meniul Omarchy (`Super + Space`). Dacă vrei vreodată să anulezi una dintre ele, folosește _Eliminare > Jocuri_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris și Heroic sunt oferite doar pe mașinile x86.

## Steam

Instalează [Steam](https://store.steampowered.com/) selectând _Instalare > Jocuri > Steam_ din meniul Omarchy (`Super + Space`).

După ce l-ai instalat, vei putea lansa Steam cu `Super + Space`.

Reține că Steam poate avea nevoie de 10-20 de secunde ca să pornească și nu îți va oferi niciun feedback vizual că se încarcă.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instalează [RetroArch](https://www.retroarch.com/) selectând _Instalare > Jocuri > RetroArch_ din meniul Omarchy (`Super + Space`). Vine cu setul complet de nuclee libretro, așa că toate sistemele clasice sunt acoperite.

RetroArch este complet preconfigurat cu frumosul shader CRT Royale, pentru acel aspect retro perfect.

Ca să începi:

1. Pune fișierele BIOS în `~/Games/bios` și ROM-urile în `~/Games/roms`.
2. Lansează RetroArch cu `Super + Space` și tastând `retro`.
3. Scanează directorul `~/Games/roms` și ești gata de joacă.

Poți, de asemenea, să îi dai unui joc favorit o intrare proprie în lansatorul de aplicații cu _Instalare > Jocuri > RetroArch Game Launcher_, care îți permite să alegi un nucleu și un ROM și să sari direct în joc din `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instalează aplicația web Xbox Cloud Gaming selectând _Instalare > Jocuri > Xbox Cloud Gaming_ din meniul Omarchy (`Super + Space`). Este „doar” o aplicație web pentru serviciu, dar pornește repede și rulează excelent la 1080p.

Dacă ai deja Xbox Game Pass, acesta este un mod solid de a juca Fortnite și alte titluri pe care nu le poți rula nativ pe Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instalează serviciul de cloud gaming [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) selectând _Instalare > Jocuri > NVIDIA GeForce NOW_ din meniul Omarchy (`Super + Space`). O altă modalitate excelentă de a juca titluri care nu sunt disponibile nativ pe Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instalează Minecraft selectând _Instalare > Jocuri > Minecraft_ din meniul Omarchy (`Super + Space`).

La fel ca la Steam, reține că poate dura ceva până apare ecranul următor după ce te autentifici sau după pornire și nu vei primi niciun feedback cât timp aștepți.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Controlere Xbox

Instalează suportul pentru controlere Xbox prin Bluetooth selectând _Instalare > Jocuri > Controlere Xbox_ din meniul Omarchy (`Super + Space`). Asociază controlerele prin Bluetooth (`Super + Ctrl + B`) și vor funcționa în toate jocurile tale. Nu ai nevoie de asta dacă îți conectezi controlerul direct, cu un cablu USB-C.

## Moonlight (Streaming de jocuri de pe un PC)

Instalează [clientul Moonlight](https://github.com/moonlight-stream/moonlight-qt) selectând _Instalare > Jocuri > Moonlight_ din meniul Omarchy (`Super + Space`) și poți reda în streaming jocuri de pe un PC cu Windows care rulează [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Dacă atât mașina ta Omarchy, cât și PC-ul de gaming de la distanță sunt conectate prin cablu, experiența nu se deosebește cu nimic de jocul local. Ridică rezoluția la nivelul nativ, setează rata de reîmprospătare la 120Hz și urcă bitrate-ul la maximum — acesta este cel mai bun mod de a juca shootere competitive precum Fortnite pe Linux.

Poți transforma, de asemenea, o mașină Omarchy în gazdă rulând `omarchy install service sunshine`, care instalează Sunshine și deschide porturile de streaming Moonlight pentru rețeaua ta LAN și pentru Tailscale.

## Battle.net

Instalează [Battle.net](https://eu.shop.battle.net/en-us) selectând _Instalare > Jocuri > Battle.net_ din meniul Omarchy (`Super + Space`). Asta îți oferă titluri precum Diablo, Starcraft și World of Warcraft ca instalare de sine stătătoare, care rulează sub GE-Proton — fără să ai nevoie de Steam, Lutris sau Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Jocuri Windows)

Instalează [Lutris](https://lutris.net/) selectând _Instalare > Jocuri > Lutris_ din meniul Omarchy (`Super + Space`). Lutris este modul în care joci jocuri Windows din magazine precum EA și Ubisoft Connect, care nu au propriul program de instalare dintre cele de mai sus.

Instalarea este puțin anevoioasă și, pe alocuri, pare că nu se întâmplă nimic — ai răbdare, lucrează în fundal.

## Heroic Launcher (Epic Games)

Instalează [Heroic Launcher](https://heroicgameslauncher.com/) selectând _Instalare > Jocuri > Heroic (Epic Games)_ din meniul Omarchy (`Super + Space`). Heroic îți permite să rulezi titluri Epic Games, precum OddSparks, care nu se bazează pe anti-cheat — plus jocuri de la GOG și Amazon Prime Gaming. Din păcate, asta înseamnă fără Fortnite și fără Rocket League — până când Tim Sweeney nu ajunge pe Linux, atât de aproape se poate.

La fel ca Lutris, poate părea lent și anevoios în timp ce instalează jocuri. Dă-i timp.
