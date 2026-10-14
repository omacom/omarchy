# Mga Tool para sa Development

## Mga Alternatibong Editor

May kasamang [Neovim](https://neovim.io/) ang Omarchy bilang default, pero kung gusto mo ng medyo mas mainstream at pamilyar, patakbuhin mo ang Omarchy Menu (`Super + Space`) at tingnan ang mga pagpipilian sa ilalim ng _Install > Editor_. Mayroon kaming VSCode, Cursor, Zed, Sublime Text, Helix, Vim, at Emacs na nakalista roon. Kung hindi mo makita ang hinahanap mo, tingnan ang _Install > Package_, at tingnan kung wala ito sa isang Arch package (at kung wala, subukan ang _Install > AUR_ para tingnan ang AUR).

Magagamit din agad ang orihinal na `vi` editor. Patakbuhin ang `vi filename` para mag-edit ng file sa terminal.

Inaalok ang pagtutugma ng tema para sa `VSCode`, `Cursor`, `VSCodium`, at `Helix`.

Maaari mong itakda ang default na editor sa buong sistema sa ilalim ng `Setup > Defaults > Editor`.

## Kapaligiran

Sinusuportahan ng Omarchy ang pag-setup ng napakaraming kapaligiran para sa development sa pamamagitan ng seksyong _Install > Development_ ng Omarchy Menu (`Super + Space`). Makikita mo siyempre ang _Ruby on Rails_, pero pati na rin ang tatlong pangunahing runtime para sa JavaScript (Node.js, Bun, Deno), pati na rin ang mga sikat na PHP framework tulad ng Laravel at Symfony. Oh, at mayroon ding Go, Rust, Python, Java, Elixir (may Phoenix), .NET, OCaml, Zig, Clojure, at Scala. Napakalawak ng pagpipilian!

Ang karamihan sa mga kapaligirang ito ay pinamamahalaan ng [Mise](https://mise.jdx.dev/). Tool ito na nagbibigay-daan sa iyong mag-install at magpatakbo ng maraming bersyon ng isang programming language sa iisang makina. Parang rbenv o rvm para sa Ruby o virtualenv para sa Python, pero gumagana ito para sa maraming iba't ibang kapaligiran.

Para mag-install, halimbawa, ng Ruby, patatakbuhin mo ang `mise use -g ruby`, na i-i-install ang Ruby at itatakda ito bilang global default. O, kung may .ruby-version file ang proyekto mo, maaari mo na lang patakbuhin ang `mise i` sa root ng proyektong iyon.

## Docker

Halos hindi na kailangang ipakilala ang [Docker](https://www.docker.com/). Nagbibigay-daan ito sa iyong magpatakbo ng mga isolated container, at ini-install ng Omarchy ang lahat ng kailangan para patakbuhin ito nang maayos, kasama ang Docker mismo at ang [Docker Compose](https://docs.docker.com/compose/).

Bilang default, ang user mo ay *hindi* nasa grupong `docker`. Ang grupong iyon ay epektibong root na walang password — anumang nasa loob nito ay maaaring magpatakbo ng `docker run -v /:/host` at sakupin ang makina — kaya ang isang rogue script o dependency na tumatakbo bilang ikaw ay isang command na lang ang layo mula sa root kung hindi. Kaya sa command line ay pinapatakbo mo ang Docker gamit ang `sudo` (`sudo docker ps`, `sudo docker compose up`), at ang mga graphical tool na nakikipag-usap sa daemon — ang Windows VM — ay humihingi ng awtorisasyon kapag kailangan nila. Kung gusto mong ibalik ang kaginhawahan ng groupless setup at nauunawaan mo ang kapalit, paganahin ito mula sa **Setup > Security > Sudoless Docker** (o patakbuhin ang `omarchy-setup-security-sudoless-docker`), na nagdadagdag sa iyo sa grupong `docker` pagkatapos ng isang babala; pagkatapos ay gagana na ulit ang plain na `docker` at ang `d` alias nang walang `sudo`.

Maaari mong i-setup ang mga karaniwang database para sa lokal na development sa Docker gamit ang _Install > Development > Docker DB_ sa Omarchy menu.

## GitHub CLI

Nagbibigay-daan sa iyo ang [GitHub CLI](https://cli.github.com/) na mag-authenticate gamit ang GitHub account mo at mag-clone ng mga pribadong repository gamit ito. Naka-wire ito bilang isa sa mga lazy-loading mise stub, kaya sa unang pagkakataong patakbuhin mo ang `gh`, ini-install nito ang sarili. Para mag-authenticate, patakbuhin ang `gh auth login`. Pagkatapos ay maaari kang mag-checkout ng mga pribadong repository gamit ang `gh repo clone org/repo`.

Maaari ka ring magsagawa ng maraming iba pang operasyon sa GitHub gamit ang command na ito. Patakbuhin lang ang `gh` para makita ang lahat ng posible.

Mayroon ding lazy-installing stub para sa `ghui` para pamahalaan ang iyong mga pull request sa isang TUI. At naka-preinstall ang [lazygit](https://github.com/jesseduffield/lazygit), kung gusto mo ring patakbuhin ang git mismo mula sa isang TUI.
