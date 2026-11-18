# Paglalaro

Ang Omarchy ay hindi lang para sa _pRoDUcTiVItY_, para rin ito sa kasiyahan, at ano pa bang mas masaya kaysa sa paglalaro? May kasamang buong suite ng mga opsyon sa paglalaro ang Omarchy — Steam at RetroArch para sa native at retro na paglalaro, Battle.net, Lutris, at Heroic para sa mga store na hindi Steam, Moonlight para sa PC streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW para sa cloud, at ang hindi nalalaos na Minecraft.

Salamat sa napakagaling na trabaho ng Valve sa [Proton compatibility layer](https://en.wikipedia.org/wiki/Proton_(software)), mayroon na ngayong sampu-sampung libong modernong laro na puwedeng laruin sa Linux. Oh, at alam mo bang Arch talaga ang tumatakbo sa [Steam Deck](https://store.steampowered.com/steamdeck/)?

Nasa ilalim ng _Install > Gaming_ sa menu ng Omarchy (`Super + Space`) ang lahat ng gaming installer. Kung gusto mong bawiin ang isa, gamitin ang _Remove > Gaming_.

## Steam

I-install ang [Steam](https://store.steampowered.com/) sa pamamagitan ng pagpili sa _Install > Gaming > Steam_ mula sa menu ng Omarchy (`Super + Space`).

Pagkatapos mong i-install ito, mailulunsad mo ang Steam gamit ang `Super + Space`.

Tandaan na maaaring tumagal ng 10-20 segundo ang pagsisimula ng Steam, at hindi ito magbibigay ng anumang visual feedback na naglo-load ito.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

I-install ang [RetroArch](https://www.retroarch.com/) sa pamamagitan ng pagpili sa _Install > Gaming > RetroArch_ mula sa menu ng Omarchy (`Super + Space`). Kasama nito ang buong set ng libretro cores, kaya sakop ang lahat ng klasikong system.

Ganap na preconfigured ang RetroArch gamit ang magandang CRT Royale shader para sa perpektong retro look na iyon.

Para magsimula:

1. Ilagay ang iyong BIOS files sa `~/Games/bios` at ang iyong ROMs sa `~/Games/roms`.
2. Ilunsad ang RetroArch gamit ang `Super + Space` at pag-type ng `retro`.
3. I-scan ang `~/Games/roms` directory at handa ka nang maglaro.

Maaari mo ring bigyan ang isang paboritong laro ng sarili nitong entry sa app launcher gamit ang _Install > Gaming > RetroArch Game Launcher_, na hinahayaan kang pumili ng core at ROM, at dumiretso sa laro mula sa `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

I-install ang Xbox Cloud Gaming web app sa pamamagitan ng pagpili sa _Install > Gaming > Xbox Cloud Gaming_ mula sa menu ng Omarchy (`Super + Space`). "Lang" itong web app para sa serbisyo, pero mabilis itong magsimula at mahusay na tumatakbo sa 1080p.

Kung mayroon ka nang Xbox Game Pass, matatag itong paraan para maglaro ng Fortnite at iba pang titulong hindi mo mapapatakbo nang native sa Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

I-install ang cloud-gaming service na [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) sa pamamagitan ng pagpili sa _Install > Gaming > NVIDIA GeForce NOW_ mula sa menu ng Omarchy (`Super + Space`). Isa pang mahusay na paraan para maglaro ng mga titulong hindi available nang native sa Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

I-install ang Minecraft sa pamamagitan ng pagpili sa _Install > Gaming > Minecraft_ mula sa menu ng Omarchy (`Super + Space`).

Tulad ng Steam, tandaan na maaaring magtagal pagkatapos mag-log in o magsimula bago lumabas ang susunod na screen, at wala kang makukuhang feedback habang naghihintay ka.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Mga Controller ng Xbox

I-install ang suporta para sa mga Bluetooth Xbox controller sa pamamagitan ng pagpili sa _Install > Gaming > Xbox Controllers_ mula sa menu ng Omarchy (`Super + Space`). Ipares ang mga controller sa pamamagitan ng Bluetooth (`Super + Ctrl + B`) at gagana ang mga ito sa lahat ng laro mo. Hindi mo ito kailangan kung ikakabit mo lang ang controller mo gamit ang USB-C cable.

## Moonlight (Pag-stream ng laro mula sa PC)

I-install ang [Moonlight client](https://github.com/moonlight-stream/moonlight-qt) sa pamamagitan ng pagpili sa _Install > Gaming > Moonlight_ mula sa menu ng Omarchy (`Super + Space`), at maaari kang mag-stream ng mga laro mula sa Windows PC na nagpapatakbo ng [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Kung naka-hardwire ang parehong Omarchy machine mo at remote gaming PC, walang pagkakaiba ang karanasan sa lokal na paglalaro. Itaas ang resolution hanggang native, itakda ang refresh sa 120Hz, at i-max ang bitrate — ito ang pinakamahusay na paraan para maglaro ng mga competitive shooter tulad ng Fortnite sa Linux.

Maaari mo ring gawing host ang isang Omarchy machine sa pamamagitan ng pagpapatakbo ng `omarchy install service sunshine`, na nag-i-install ng Sunshine at nagbubukas ng Moonlight streaming ports para sa LAN at Tailscale mo.

## Battle.net

I-install ang [Battle.net](https://eu.shop.battle.net/en-us) sa pamamagitan ng pagpili sa _Install > Gaming > Battle.net_ mula sa menu ng Omarchy (`Super + Space`). Nagbibigay ito sa iyo ng mga titulong tulad ng Diablo, Starcraft, at World of Warcraft bilang standalone install na tumatakbo sa ilalim ng GE-Proton — hindi kailangan ang Steam, Lutris, o Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Mga laro sa Windows)

I-install ang [Lutris](https://lutris.net/) sa pamamagitan ng pagpili sa _Install > Gaming > Lutris_ mula sa menu ng Omarchy (`Super + Space`). Ang Lutris ang paraan para maglaro ng mga Windows game mula sa mga store tulad ng EA at Ubisoft Connect na walang sariling installer sa itaas.

Medyo janky ang pag-install at minsan ay mukhang walang nangyayari — maging matiyaga lang, gumagana ito sa background.

## Heroic Launcher (Epic Games)

I-install ang [Heroic Launcher](https://heroicgameslauncher.com/) sa pamamagitan ng pagpili sa _Install > Gaming > Heroic (Epic Games)_ mula sa menu ng Omarchy (`Super + Space`). Hinahayaan ka ng Heroic na patakbuhin ang mga titulo ng Epic Games, tulad ng OddSparks, na hindi umaasa sa anti-cheat — pati mga laro mula sa GOG at Amazon Prime Gaming. Nakakalungkot, ibig sabihin ay walang Fortnite at walang Rocket League — hanggang sa dumating si Tim Sweeney sa Linux, ito na ang pinakamalapit na makukuha mo.

Tulad ng Lutris, maaari itong makaramdam na mabagal at janky habang nag-i-install ng mga laro. Bigyan ito ng oras.
