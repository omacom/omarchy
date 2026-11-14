# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) ay isang kaaya-ayang alternatibo sa tulad ng GitHub Desktop application, at tumatakbo ito sa loob ng terminal.

Diretso mo itong mapapatakbo sa pamamagitan ng pagpunta sa anumang directory na pinamamahalaan ng git at pagpapatakbo ng `lazygit`. O mapapatakbo mo ito sa loob ng Neovim kung saan masisimulan ito gamit ang `Space G G`.

Lilipat-lipat ka sa iba't ibang pane gamit ang `Tab`. Sa pane ng Files, pipili ka ng mga file para sa staging gamit ang `Space`, at pagkatapos ay makakagawa ka ng bagong commit gamit ang `c`. Makikita mo ang lahat ng available na command gamit ang `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) ay isang magandang resource manager na nagpapakita ng paggamit ng memory, CPU, disk, at network. Inililista rin nito ang lahat ng aktibong proseso, at hinahayaan kang pamahalaan ang mga ito.

Tinatawag ito ng Omarchy na Activity Monitor, at sisimulan mo ito mula sa app launcher o sa pagpindot ng `Super + Shift + T`. Bubukas ito bilang isang floating window, na maaari mong i-tile gamit ang `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) ay isang terminal workspace manager na nagbibigay sa iyo ng mga workspace, tab, at pane, at pinapanatili ang lahat ng ito na tumatakbo sa isang persistent na session na maaari mong iwanan at balikan mamaya.

Sisimulan mo ito (o muling kokonekta sa iyong kasalukuyang session) gamit ang `Super + Ctrl + Return`. May kasamang configuration ng Herdr ang Omarchy na sumasalamin sa Tmux config nito, kaya `Ctrl + Space` din dito ang prefix key. Maaari mong tingnan ang lahat ng keybinding gamit ang `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) ay nagpapakita ng impormasyon ng system, tulad ng bersyon ng kernel, uptime, theme, CPU, memory, at iba pa. Kahalili ito ng sikat na neofetch tool.

Inilagay ito ng Omarchy bilang _Tungkol_ sa menu ng Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) ay isang retro na terminal music player na inspirado ng Winamp 2.x, kumpleto sa mga built-in na istasyon ng radyo para sa lo-fi beats. Ilunsad ito gamit ang `Super + Shift + Alt + M`, o mula sa menu ng Omarchy sa ilalim ng _Mga App_. Pindutin ang `?` para sa buong listahan ng keybinding.

## Paano naman ang Wi-Fi at Bluetooth?

Hindi ka makakahanap ng mga TUI para sa Wi-Fi at Bluetooth — para sa shell ng Omarchy ang mga trabahong iyon. I-click ang icon ng Wi-Fi sa top bar (o pindutin ang `Super + Ctrl + N`) upang makita ang mga network at kumonekta, at i-click ang icon ng Bluetooth (o pindutin ang `Super + Ctrl + B`) upang mag-pair at magkonekta ng mga device. Tingnan ang [networking](35-networking.md) para sa buong kuwento.

## Pagdaragdag ng sarili mo

Maaaring makuha ng anumang terminal program ang buong trato bilang app. Pumunta sa _I-install > TUI_ sa menu ng Omarchy (`Super + Space`), bigyan ito ng pangalan, launch command, estilo ng window, at icon, at lalabas ito sa app launcher tulad ng anumang ibang application. Maaari mo itong alisin ulit sa ilalim ng _Alisin > TUI_.
