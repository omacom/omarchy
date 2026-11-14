# TUIs

## Lazygit

Ang [Lazygit](https://github.com/jesseduffield/lazygit) ay isang nakakatuwang alternatibo sa mga katulad ng GitHub Desktop application, at tumatakbo ito sa loob ng terminal.

Maaari mo itong patakbuhin nang direkta, sa pamamagitan ng pagpunta sa anumang directory na pinamamahalaan ng git at pagpapatakbo ng `lazygit`. O maaari mo itong patakbuhin sa loob ng Neovim kung saan maaari itong simulan gamit ang `Space G G`.

Lilipat-lipat ka sa iba't ibang pane gamit ang `Tab`. Sa Files pane, pipili ka ng mga file para sa staging gamit ang `Space`, at pagkatapos ay maaari kang gumawa ng bagong commit gamit ang `c`. Makikita mo ang lahat ng available na command gamit ang `?`.

## Btop

Ang [Btop](https://github.com/aristocratos/btop) ay isang magandang resource manager na nagpapakita ng paggamit ng memory, CPU, disk, at network. Inililista rin nito ang lahat ng aktibong process, at hinahayaan kang pamahalaan ang mga ito.

Tinatawag itong Activity ng Omarchy, at sinisimulan mo ito sa pamamagitan ng pagpindot sa `Super + Shift + T`. Bumubukas ito bilang isang floating window, na maaari mong i-tile gamit ang `Super + T`.

## Herdr

Ang [Herdr](https://github.com/omacom-io/herdr) ay isang terminal workspace manager na nagbibigay sa iyo ng mga workspace, tab, at pane, at pinapanatiling tumatakbo ang lahat ng ito sa isang persistent session na maaari mong iwanan at balikan sa ibang pagkakataon.

Sinisimulan mo ito (o muling kumokonekta sa kasalukuyan mong session) gamit ang `Super + Ctrl + Return`. May kasamang Herdr configuration ang Omarchy na sumasalamin sa Tmux config nito, kaya `Ctrl + Space` din ang prefix key dito. Maaari mong tingnan ang lahat ng keybinding gamit ang `Super + Ctrl + K`.

## Fastfetch

Ipinapakita ng [Fastfetch](https://github.com/fastfetch-cli/fastfetch) ang impormasyon ng system, tulad ng bersyon ng kernel, uptime, theme, CPU, memory, at marami pang iba. Ito ang kahalili ng sikat na neofetch tool.

Inilagay ito ng Omarchy bilang _About_ sa Omarchy menu (`Super + Space`).

## Cliamp

Ang [Cliamp](https://www.cliamp.stream/) ay isang retro terminal music player na hango sa Winamp 2.x, kumpleto sa mga built-in na radio station para sa lo-fi beats. Ilunsad ito gamit ang `Super + Shift + Alt + M`, o mula sa Omarchy menu sa ilalim ng _Apps_. Pindutin ang `?` para sa buong listahan ng mga keybinding.

## Paano naman ang Wi-Fi at Bluetooth?

Hindi ka makakakita ng mga TUI para sa Wi-Fi at Bluetooth — ang mga trabahong iyon ay para sa Omarchy shell. I-click ang Wi-Fi icon sa top bar (o pindutin ang `Super + Ctrl + N`) para makita ang mga network at kumonekta, at i-click ang Bluetooth icon (o pindutin ang `Super + Ctrl + B`) para mag-pair at magkonekta ng mga device. Tingnan ang [networking](35-networking.md) para sa buong kuwento.

## Pagdaragdag ng sarili mo

Kahit anong terminal program ay maaaring bigyan ng buong pagtrato bilang app. Pumunta sa _Install > TUI_ sa Omarchy menu (`Super + Space`), bigyan ito ng pangalan, launch command, estilo ng window, at icon, at lalabas ito sa app launcher tulad ng anumang iba pang application. Maaari mo itong alisin ulit sa ilalim ng _Remove > TUI_.
