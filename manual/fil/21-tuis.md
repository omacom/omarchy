# TUIs

## Lazygit

Ang [Lazygit](https://github.com/jesseduffield/lazygit) ay isang nakakatuwang alternatibo sa isang bagay tulad ng GitHub Desktop application, at tumatakbo ito sa loob ng terminal.

Maaari mo itong patakbuhin nang direkta, sa pamamagitan ng pagpunta sa anumang directory na pinamamahalaan ng git at pagpapatakbo ng `lazygit`. O maaari mo itong patakbuhin sa loob ng Neovim kung saan maaari itong simulan gamit ang `Space G G`.

Lumilipat ka sa pagitan ng iba't ibang pane gamit ang `Tab`. Sa Files pane, pipili ka ng mga file para sa staging gamit ang `Space`, at pagkatapos ay maaari kang gumawa ng bagong commit gamit ang `c`. Makikita mo ang lahat ng available na command gamit ang `?`.

## Btop

Ang [Btop](https://github.com/aristocratos/btop) ay isang magandang resource manager na nagpapakita ng memory, CPU, disk, at network usage. Inililista rin nito ang lahat ng aktibong process, at hinahayaan kang pamahalaan ang mga ito.

Tinatawag ito ng Omarchy na Activity Monitor, at sinisimulan mo ito mula sa app launcher o sa pamamagitan ng pagpindot ng `Super + Shift + T`. Bumubukas ito bilang isang floating window, na maaari mong i-tile gamit ang `Super + T`.

## Herdr

Ang [Herdr](https://herdr.dev) ay isang terminal workspace manager na nagbibigay sa iyo ng mga workspace, tab, at pane, at pinapanatili ang lahat ng ito na tumatakbo sa isang persistent session na maaari mong iwanan at balikan sa ibang pagkakataon.

Sinisimulan mo ito (o muling kumokonekta sa iyong umiiral na session) mula sa app launcher o gamit ang `Super + Ctrl + Return`. Nagpapadala ang Omarchy ng isang Herdr configuration na sumasalamin sa Tmux config nito, kaya ang prefix key dito ay `Ctrl + Space` din. Maaari mong i-browse ang lahat ng keybinding gamit ang `Super + Ctrl + K`.

## Fastfetch

Ipinapakita ng [Fastfetch](https://github.com/fastfetch-cli/fastfetch) ang impormasyon ng system, tulad ng kernel version, uptime, theme, CPU, memory, at higit pa. Ito ay isang kahalili ng sikat na neofetch tool.

Ipinakete ito ng Omarchy bilang _System > About_ sa Omarchy menu (`Super + Space`).

## Cliamp

Ang [Cliamp](https://www.cliamp.stream/) ay isang retro terminal music player na hango sa Winamp 2.x, kumpleto sa mga built-in na radio station para sa lo-fi beats. Ilunsad ito gamit ang `Super + Shift + Alt + M`, o mula sa Omarchy menu sa ilalim ng _Apps_. Pindutin ang `?` para sa buong listahan ng keybinding.

## Ano ang tungkol sa Wi-Fi at Bluetooth?

Hindi ka makakahanap ng mga TUI para sa Wi-Fi at Bluetooth — ang mga trabahong iyon ay para sa Omarchy shell. I-click ang Wi-Fi icon sa top bar (o pindutin ang `Super + Ctrl + N`) upang makita ang mga network at kumonekta, at i-click ang Bluetooth icon (o pindutin ang `Super + Ctrl + B`) upang i-pair at ikonekta ang mga device. Tingnan ang [networking](35-networking.md) para sa buong kuwento.

## Pagdaragdag ng sarili mo

Maaaring makuha ng anumang terminal program ang buong pagtrato bilang app. Pumunta sa _Install > TUI_ sa Omarchy menu (`Super + Space`), bigyan ito ng pangalan, launch command, window style, at icon, at lalabas ito sa app launcher tulad ng anumang iba pang application. Maaari mo itong alisin muli sa ilalim ng _Remove > TUI_.
