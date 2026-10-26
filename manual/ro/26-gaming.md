# Jocuri

Omarchy nu este doar pentru _pRoDUcTiVItY_, ci și pentru distracție, și ce e mai distractiv decât jocurile? Omarchy vine cu o întreagă suită de opțiuni pentru jocuri — Steam și RetroArch pentru joc nativ și retro, Battle.net, Lutris și Heroic pentru magazinele non-Steam, Moonlight pentru streaming de pe PC, Xbox Cloud Gaming + NVIDIA GeForce NOW pentru cloud, plus veșnicul Minecraft.

Grație muncii incredibile a Valve la [stratul de compatibilitate proton](https://en.wikipedia.org/wiki/Proton_(software)), există acum zeci de mii de jocuri moderne jucabile pe Linux. Ah, și știai că [Steam Deck](https://store.steampowered.com/steamdeck/) rulează de fapt Arch!

Toate programele de instalare pentru jocuri trăiesc sub _Instalează > Jocuri_ în meniul Omarchy (`Super + Space`). Dacă vrei vreodată să desfaci unul, folosește _Elimină > Jocuri_.

## Steam

Instalează [Steam](https://store.steampowered.com/) selectând _Instalează > Jocuri > Steam_ din meniul Omarchy (`Super + Space`).

După ce l-ai instalat, vei putea lansa Steam cu `Super + Space`.

Reține că Steam poate dura 10-20 de secunde ca să pornească și nu-ți va oferi niciun feedback vizual că se încarcă.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instalează [RetroArch](https://www.retroarch.com/) selectând _Instalează > Jocuri > RetroArch_ din meniul Omarchy (`Super + Space`). Vine cu setul complet de nuclee libretro, așa că toate sistemele clasice sunt acoperite.

RetroArch este complet preconfigurat cu frumosul shader CRT Royale pentru acel aspect retro perfect.

Ca să începi:

1. Pune-ți fișierele BIOS în `~/Games/bios` și ROM-urile în `~/Games/roms`.
2. Lansează RetroArch cu `Super + Space` și tastând `retro`.
3. Scanează directorul `~/Games/roms` și ești gata de joc.

Poți da unui joc favorit propria intrare în lansatorul de aplicații cu _Instalează > Jocuri > Lansator jocuri RetroArch_, ceea ce îți permite să alegi un nucleu și un ROM și să sari direct în joc din `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instalează aplicația web Xbox Cloud Gaming selectând _Instalează > Jocuri > Xbox Cloud Gaming_ din meniul Omarchy (`Super + Space`). Este „doar” o aplicație web pentru serviciu, dar pornește rapid și rulează excelent la 1080p.

Dacă ai deja Xbox Game Pass, este o cale solidă de a juca Fortnite și alte titluri pe care nu le poți rula nativ pe Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instalează serviciul de jocuri în cloud [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) selectând _Instalează > Jocuri > NVIDIA GeForce NOW_ din meniul Omarchy (`Super + Space`). O altă cale excelentă de a juca titluri care nu sunt disponibile nativ pe Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instalează Minecraft selectând _Instalează > Jocuri > Minecraft_ din meniul Omarchy (`Super + Space`).

Ca Steam, reține că poate dura un timp după conectare sau pornire până când apare următorul ecran și nu vei primi niciun feedback în timp ce aștepți.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Controlere Xbox

Instalează suportul pentru controlere Xbox Bluetooth selectând _Instalează > Jocuri > Controlere Xbox_ din meniul Omarchy (`Super + Space`). Asociază controlerele prin Bluetooth (`Super + Ctrl + B`) și vor funcționa în toate jocurile tale. Nu ai nevoie de asta dacă doar îți conectezi controlerul cu un cablu USB-C.

## Moonlight (streaming de jocuri de pe un PC)

[Clientul Moonlight](https://github.com/moonlight-stream/moonlight-qt) vine preinstalat cu Omarchy, așa că poți face streaming de jocuri de pe un PC Windows care rulează [Sunshine](https://app.lizardbyte.dev/Sunshine/) imediat. Lansează Moonlight prin `Super + Space`.

Dacă atât mașina ta Omarchy, cât și PC-ul de jocuri la distanță sunt conectate prin cablu, experiența nu se deosebește de jocul local. Urcă rezoluția la cea nativă, setează refresh-ul la 120 Hz și maximizează bitrate-ul — aceasta este cea mai bună cale de a juca shootere competitive precum Fortnite pe Linux.

Poți transforma și o mașină Omarchy în gazdă rulând `omarchy install service sunshine`, ceea ce instalează Sunshine și deschide porturile de streaming Moonlight pentru rețeaua ta locală și Tailscale.

## Battle.net

Instalează [Battle.net](https://eu.shop.battle.net/en-us) selectând _Instalează > Jocuri > Battle.net_ din meniul Omarchy (`Super + Space`). Asta îți dă titluri precum Diablo, Starcraft și World of Warcraft ca instalare independentă rulând sub GE-Proton — nu ai nevoie de Steam, Lutris sau Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (jocuri Windows)

Instalează [Lutris](https://lutris.net/) selectând _Instalează > Jocuri > Lutris_ din meniul Omarchy (`Super + Space`). Lutris este calea de a juca jocuri Windows din magazine precum EA și Ubisoft Connect, care nu au propriul program de instalare mai sus.

Instalarea este un pic haotică și pare că nu se întâmplă nimic o vreme — ai răbdare, lucrează în fundal.

## Heroic Launcher (Epic Games)

Instalează [Heroic Launcher](https://heroicgameslauncher.com/) selectând _Instalează > Jocuri > Heroic (Epic Games)_ din meniul Omarchy (`Super + Space`). Heroic îți permite să rulezi titluri Epic Games, precum OddSparks, care nu se bazează pe anti-cheat — plus jocuri de pe GOG și Amazon Prime Gaming. Din păcate, asta înseamnă fără Fortnite și fără Rocket League — până când Tim Sweeney vine la Linux, atât se poate.

Ca Lutris, poate părea lent și haotic în timp ce instalează jocuri. Dă-i timp.
