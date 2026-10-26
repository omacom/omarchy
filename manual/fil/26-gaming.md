# Paglalaro

Hindi lang para sa _pRoDUcTiVItY_ ang Omarchy, para rin ito sa kasiyahan, at ano pa bang mas masaya kaysa sa paglalaro? May kasamang buong suite ng mga pagpipilian sa paglalaro ang Omarchy — Steam at RetroArch para sa native at retro na paglalaro, Battle.net, Lutris, at Heroic para sa mga non-Steam store, Moonlight para sa PC streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW para sa cloud, pati na rin ang walang-kupas na Minecraft.

Salamat sa hindi kapani-paniwalang trabaho ng Valve sa [proton compatibility layer](https://en.wikipedia.org/wiki/Proton_(software)), mayroon na ngayong sampu-sampung libong puwedeng laruin na modernong laro sa Linux. Oh, at alam mo bang ang [Steam Deck](https://store.steampowered.com/steamdeck/) ay talagang nagpapatakbo ng Arch!

Nakatira ang lahat ng gaming installer sa ilalim ng _Install > Gaming_ sa Omarchy menu (`Super + Space`). Kung gusto mong bawiin ang isa, gamitin ang _Remove > Gaming_.

## Steam

I-install ang [Steam](https://store.steampowered.com/) sa pamamagitan ng pagpili ng _Install > Gaming > Steam_ mula sa Omarchy menu (`Super + Space`).

Pagkatapos mong i-install ito, magagawa mong ilunsad ang Steam gamit ang `Super + Space`.

Tandaan na maaaring tumagal ng 10-20 segundo ang Steam para magsimula, at hindi ito magbibigay ng anumang visual feedback na naglo-load ito.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

I-install ang [RetroArch](https://www.retroarch.com/) sa pamamagitan ng pagpili ng _Install > Gaming > RetroArch_ mula sa Omarchy menu (`Super + Space`). May kasama itong buong hanay ng libretro cores, kaya saklaw ang lahat ng klasikong sistema.

Ganap na naka-preconfigure ang RetroArch gamit ang magandang CRT Royale shader para sa perpektong retro look na iyon.

Para magsimula:

1. Ilagay ang iyong mga BIOS file sa `~/Games/bios` at ang iyong mga ROM sa `~/Games/roms`.
2. Ilunsad ang RetroArch gamit ang `Super + Space` at pag-type ng `retro`.
3. I-scan ang direktoryong `~/Games/roms` at handa ka nang maglaro.

Maaari mo ring bigyan ang isang paboritong laro ng sarili nitong entry sa app launcher gamit ang _Install > Gaming > RetroArch Game Launcher_, na nagbibigay-daan sa iyong pumili ng core at ROM, at dumiretso sa laro mula sa `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

I-install ang Xbox Cloud Gaming web app sa pamamagitan ng pagpili ng _Install > Gaming > Xbox Cloud Gaming_ mula sa Omarchy menu (`Super + Space`). Ito ay "lamang" isang web app para sa serbisyo, pero mabilis itong magsimula at tumatakbo nang mahusay sa 1080p.

Kung mayroon ka nang Xbox Game Pass, ito ay isang matatag na paraan para laruin ang Fortnite at iba pang titulo na hindi mo mapapatakbo nang native sa Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

I-install ang cloud-gaming service na [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) sa pamamagitan ng pagpili ng _Install > Gaming > NVIDIA GeForce NOW_ mula sa Omarchy menu (`Super + Space`). Isa pang mahusay na paraan para laruin ang mga titulo na hindi available nang native sa Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

I-install ang Minecraft sa pamamagitan ng pagpili ng _Install > Gaming > Minecraft_ mula sa Omarchy menu (`Super + Space`).

Tulad ng Steam, tandaan na maaaring tumagal ng ilang sandali pagkatapos mag-log in o magsimula bago lumabas ang susunod na screen, at hindi ka makakakuha ng anumang feedback habang naghihintay ka.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Mga Xbox Controller

I-install ang suporta para sa mga Bluetooth Xbox controller sa pamamagitan ng pagpili ng _Install > Gaming > Xbox Controllers_ mula sa Omarchy menu (`Super + Space`). I-pair ang mga controller sa pamamagitan ng Bluetooth (`Super + Ctrl + B`) at gagana sila sa lahat ng iyong laro. Hindi mo ito kailangan kung ikakabit mo lang ang controller mo gamit ang USB-C cable.

## Moonlight (Pag-stream ng laro mula sa isang PC)

Naka-preinstall ang [Moonlight client](https://github.com/moonlight-stream/moonlight-qt) sa Omarchy, kaya maaari kang mag-stream ng mga laro mula sa isang Windows PC na nagpapatakbo ng [Sunshine](https://app.lizardbyte.dev/Sunshine/) kaagad. Ilunsad ang Moonlight sa pamamagitan ng `Super + Space`.

Kung parehong naka-hardwire ang iyong Omarchy machine at ang remote gaming PC, ang karanasan ay hindi makikilala mula sa paglalaro nang lokal. Itaas ang resolution sa native, itakda ang refresh sa 120Hz, at i-max ang bitrate — ito ang pinakamahusay na paraan para laruin ang mga competitive shooter tulad ng Fortnite sa Linux.

Maaari mo ring gawing host ang isang Omarchy machine sa pamamagitan ng pagpapatakbo ng `omarchy install service sunshine`, na nag-i-install ng Sunshine at nagbubukas ng mga Moonlight streaming port para sa iyong LAN at Tailscale.

## Battle.net

I-install ang [Battle.net](https://eu.shop.battle.net/en-us) sa pamamagitan ng pagpili ng _Install > Gaming > Battle.net_ mula sa Omarchy menu (`Super + Space`). Binibigyan ka nito ng mga titulo tulad ng Diablo, Starcraft, at World of Warcraft bilang isang standalone install na tumatakbo sa ilalim ng GE-Proton — hindi kailangan ng Steam, Lutris, o Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Mga larong Windows)

I-install ang [Lutris](https://lutris.net/) sa pamamagitan ng pagpili ng _Install > Gaming > Lutris_ mula sa Omarchy menu (`Super + Space`). Ang Lutris ay ang paraan para laruin ang mga larong Windows mula sa mga store tulad ng EA at Ubisoft Connect na walang sariling installer sa itaas.

Medyo janky ang pag-install at mukhang walang nangyayari minsan — maging matiyaga lang, gumagana ito sa background.

## Heroic Launcher (Epic Games)

I-install ang [Heroic Launcher](https://heroicgameslauncher.com/) sa pamamagitan ng pagpili ng _Install > Gaming > Heroic (Epic Games)_ mula sa Omarchy menu (`Super + Space`). Nagbibigay-daan sa iyo ang Heroic na patakbuhin ang mga titulo ng Epic Games, tulad ng OddSparks, na hindi umaasa sa anti-cheat — pati na rin ang mga laro mula sa GOG at Amazon Prime Gaming. Sa kasamaang-palad, ibig sabihin niyon ay walang Fortnite at walang Rocket League — hanggang sa dumating si Tim Sweeney sa Linux, ito na ang pinakamalapit.

Tulad ng Lutris, maaaring maramdaman itong mabagal at janky habang nag-i-install ng mga laro. Bigyan ito ng oras.
