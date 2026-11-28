# Paglalaro

Hindi lang para sa _pRoDuKtIbIdAd_ ang Omarchy, para rin ito sa pagsasaya, at ano pa bang mas masaya kaysa sa paglalaro? May kasamang buong suite ng mga opsyon sa paglalaro ang Omarchy — Steam at RetroArch para sa native at retro na paglalaro, Battle.net, Lutris, at Heroic para sa mga store na hindi Steam, Moonlight para sa PC streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW para sa cloud, at ang walang-kupas na Minecraft.

Salamat sa hindi kapani-paniwalang trabaho ng Valve sa [layer ng compatibility ng Proton](https://en.wikipedia.org/wiki/Proton_(software)), mayroon na ngayong sampu-sampung libong modernong laro na puwedeng laruin sa Linux. Oh, at alam mo bang Arch talaga ang tumatakbo sa [Steam Deck](https://store.steampowered.com/steamdeck/)!

Nasa ilalim ng _Install > Gaming_ sa menu ng Omarchy (`Super + Space`) ang lahat ng installer para sa paglalaro. Kung gusto mong bawiin ang isa, gamitin ang _Remove > Gaming_. Inaalok lang sa mga makinang x86 ang Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris, at Heroic.

## Steam

I-install ang [Steam](https://store.steampowered.com/) sa pamamagitan ng pagpili sa _Install > Gaming > Steam_ mula sa menu ng Omarchy (`Super + Space`).

Pagkatapos mo itong i-install, mailulunsad mo ang Steam gamit ang `Super + Space`.

Tandaang maaaring tumagal ng 10-20 segundo bago magbukas ang Steam, at hindi ito magbibigay ng anumang visual na feedback na naglo-load ito.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

I-install ang [RetroArch](https://www.retroarch.com/) sa pamamagitan ng pagpili sa _Install > Gaming > RetroArch_ mula sa menu ng Omarchy (`Super + Space`). Kasama nito ang buong set ng mga libretro core, kaya sakop ang lahat ng klasikong system.

Ganap nang naka-preconfigure ang RetroArch gamit ang magandang CRT Royale shader para sa perpektong retro na hitsura.

Para magsimula:

1. Ilagay ang iyong mga BIOS file sa `~/Games/bios` at ang iyong mga ROM sa `~/Games/roms`.
2. Ilunsad ang RetroArch gamit ang `Super + Space` at pag-type ng `retro`.
3. I-scan ang direktoryong `~/Games/roms` at handa ka nang maglaro.

Puwede mo ring bigyan ang isang paboritong laro ng sarili nitong entry sa app launcher gamit ang _Install > Gaming > RetroArch Game Launcher_, na hinahayaan kang pumili ng core at ROM, at dumiretso sa laro mula sa `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

I-install ang web app ng Xbox Cloud Gaming sa pamamagitan ng pagpili sa _Install > Gaming > Xbox Cloud Gaming_ mula sa menu ng Omarchy (`Super + Space`). Isa "lang" itong web app para sa serbisyo, pero mabilis itong magbukas at mahusay na tumatakbo sa 1080p.

Kung mayroon ka nang Xbox Game Pass, matibay itong paraan para laruin ang Fortnite at iba pang larong hindi mo mapapatakbo nang native sa Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

I-install ang cloud-gaming na serbisyong [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) sa pamamagitan ng pagpili sa _Install > Gaming > NVIDIA GeForce NOW_ mula sa menu ng Omarchy (`Super + Space`). Isa pang mahusay na paraan para laruin ang mga larong hindi available nang native sa Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

I-install ang Minecraft sa pamamagitan ng pagpili sa _Install > Gaming > Minecraft_ mula sa menu ng Omarchy (`Super + Space`).

Tulad ng Steam, tandaang maaaring matagalan bago lumabas ang susunod na screen pagkatapos mag-log in o magbukas, at wala kang makukuhang feedback habang naghihintay ka.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Mga Controller ng Xbox

I-install ang suporta para sa mga Bluetooth na controller ng Xbox sa pamamagitan ng pagpili sa _Install > Gaming > Xbox Controllers_ mula sa menu ng Omarchy (`Super + Space`). I-pair ang mga controller sa pamamagitan ng Bluetooth (`Super + Ctrl + B`) at gagana sila sa lahat ng laro mo. Hindi mo ito kailangan kung ikinakabit mo lang ang controller mo gamit ang isang USB-C cable.

## Moonlight (Pag-stream ng laro mula sa isang PC)

I-install ang [klienteng Moonlight](https://github.com/moonlight-stream/moonlight-qt) sa pamamagitan ng pagpili sa _Install > Gaming > Moonlight_ mula sa menu ng Omarchy (`Super + Space`), at makakapag-stream ka ng mga laro mula sa isang Windows PC na nagpapatakbo ng [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Kung naka-hardwire ang makina mong Omarchy at ang remote na gaming PC, walang pagkakaiba ang karanasan sa lokal na paglalaro. Itaas ang resolution hanggang native, itakda ang refresh sa 120Hz, at i-max ang bitrate — ito ang pinakamahusay na paraan para maglaro ng mga competitive shooter tulad ng Fortnite sa Linux.

Puwede mo ring gawing host ang isang makinang Omarchy sa pamamagitan ng pagpapatakbo ng `omarchy install service sunshine`, na nag-i-install ng Sunshine at nagbubukas ng mga Moonlight streaming port para sa iyong LAN at Tailscale.

## Battle.net

I-install ang [Battle.net](https://eu.shop.battle.net/en-us) sa pamamagitan ng pagpili sa _Install > Gaming > Battle.net_ mula sa menu ng Omarchy (`Super + Space`). Binibigyan ka nito ng mga larong tulad ng Diablo, Starcraft, at World of Warcraft bilang standalone na install na tumatakbo sa ilalim ng GE-Proton — hindi kailangan ng Steam, Lutris, o Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Mga larong Windows)

I-install ang [Lutris](https://lutris.net/) sa pamamagitan ng pagpili sa _Install > Gaming > Lutris_ mula sa menu ng Omarchy (`Super + Space`). Ang Lutris ang paraan para laruin ang mga larong Windows mula sa mga store tulad ng EA at Ubisoft Connect na walang sariling installer sa itaas.

Medyo magulo ang pag-install at mukhang walang nangyayari paminsan-minsan — matiyaga ka lang, gumagana ito sa background.

## Heroic Launcher (Epic Games)

I-install ang [Heroic Launcher](https://heroicgameslauncher.com/) sa pamamagitan ng pagpili sa _Install > Gaming > Heroic (Epic Games)_ mula sa menu ng Omarchy (`Super + Space`). Hinahayaan ka ng Heroic na patakbuhin ang mga laro ng Epic Games, tulad ng OddSparks, na hindi umaasa sa anti-cheat — at pati mga laro mula sa GOG at Amazon Prime Gaming. Sa kasamaang-palad, ibig sabihin niyan walang Fortnite at walang Rocket League — hanggang sa dumating si Tim Sweeney sa Linux, ito na ang pinakamalapit na makukuha mo.

Tulad ng Lutris, maaari itong maging mabagal at magulo habang nag-i-install ng mga laro. Bigyan mo ito ng oras.
