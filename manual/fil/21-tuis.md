# Mga TUI

## Lazygit

Ang [Lazygit](https://github.com/jesseduffield/lazygit) ay isang kaaya-ayang alternatibo sa isang bagay tulad ng GitHub Desktop application, at tumatakbo ito sa loob ng terminal.

Maaari mo itong patakbuhin nang direkta, sa pamamagitan ng pagpunta sa anumang direktoryong pinamamahalaan ng git at pagpapatakbo ng `lazygit`. O maaari mo itong patakbuhin sa loob ng Neovim kung saan maaari itong simulan gamit ang `Space G G`.

Lumulukso ka sa pagitan ng iba't ibang pane gamit ang `Tab`. Sa Files pane, pumipili ka ng mga file para sa staging gamit ang `Space`, at pagkatapos ay maaari kang gumawa ng bagong commit gamit ang `c`. Makikita mo ang lahat ng available na command gamit ang `?`.

## Btop

Ang [Btop](https://github.com/aristocratos/btop) ay isang magandang resource manager na nagpapakita ng paggamit ng memory, CPU, disk, at network. Inililista rin nito ang lahat ng aktibong proseso, at nagbibigay-daan sa iyong pamahalaan ang mga ito.

Tinatawag itong Activity ng Omarchy, at sinisimulan mo ito sa pamamagitan ng pagpindot ng `Super + Ctrl + T`. Bumubukas ito bilang isang floating window, na maaari mong i-tile gamit ang `Super + T`.

## Herdr

Ang [Herdr](https://github.com/omacom-io/herdr) ay isang terminal workspace manager na nagbibigay sa iyo ng mga workspace, tab, at pane, at pinapanatili ang lahat ng mga ito na tumatakbo sa isang persistent session na maaari mong i-detach at balikan mamaya.

Sinisimulan mo ito (o muli kang kumakabit sa iyong kasalukuyang session) gamit ang `Super + Ctrl + Return`. May kasamang Herdr configuration ang Omarchy na sumasalamin sa Tmux config nito, kaya ang prefix key dito ay `Ctrl + Space` din. Maaari mong i-browse ang lahat ng keybinding gamit ang `Super + Ctrl + K`.

## Fastfetch

Nagpapakita ang [Fastfetch](https://github.com/fastfetch-cli/fastfetch) ng impormasyon ng sistema, tulad ng bersyon ng kernel, uptime, tema, CPU, memory, at marami pa. Ito ang kahalili ng sikat na neofetch tool.

Inimpake ito ng Omarchy bilang _About_ sa Omarchy menu (`Super + Space`).

## Cliamp

Ang [Cliamp](https://www.cliamp.stream/) ay isang retro terminal music player na inspired ng Winamp 2.x, kumpleto sa mga built-in na istasyon ng radyo para sa lo-fi beats. Ilunsad ito gamit ang `Super + Shift + Alt + M`, o mula sa Omarchy menu sa ilalim ng _Apps_. Pindutin ang `?` para sa buong listahan ng keybinding.

## Paano naman ang Wi-Fi at Bluetooth?

Hindi ka makakakita ng mga TUI para sa Wi-Fi at Bluetooth — ang mga trabahong iyon ay para sa Omarchy shell. I-click ang Wi-Fi icon sa top bar (o pindutin ang `Super + Ctrl + W`) para makita ang mga network at kumonekta, at i-click ang Bluetooth icon (o pindutin ang `Super + Ctrl + B`) para mag-pair at kumonekta ng mga device. Tingnan ang [networking](35-networking.md) para sa buong kuwento.

## Pagdaragdag ng sarili mo

Anumang terminal program ay maaaring makakuha ng buong app treatment. Pumunta sa _Install > TUI_ sa Omarchy menu (`Super + Space`), bigyan ito ng pangalan, isang launch command, isang window style, at isang icon, at lalabas ito sa app launcher tulad ng anumang ibang application. Maaari mo itong alisin ulit sa ilalim ng _Remove > TUI_.
