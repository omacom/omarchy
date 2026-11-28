# Mga Tool sa Development

## Mga Alternatibong Editor

Kasama ng Omarchy ang Plain bilang default na editor sa mga bagong install at naka-preinstall ang [Neovim](https://neovim.io/), pero kung gusto mo ng medyo mas mainstream at pamilyar, maaari mong patakbuhin ang Omarchy Menu (`Super + Space`) at tingnan ang mga opsyon sa ilalim ng _Install > Editor_. Nandoon ang VSCode, Cursor, Zed, Sublime Text, Helix, Vim, at Emacs. Kung hindi mo makita ang hinahanap mo, tingnan ang _Install > Package_, at alamin kung wala ito sa isang Arch package (at kung wala, subukan ang _Install > AUR_ para tingnan ang AUR).

Magagamit din agad ang orihinal na `vi` editor. Patakbuhin ang `vi filename` para mag-edit ng file sa terminal.

Inaalok ang pagtutugma ng tema para sa `VSCode`, `Cursor`, `VSCodium`, at `Helix`.

Maaari mong itakda ang default na editor para sa buong sistema sa ilalim ng `Setup > Defaults > Editor`.

## Environment

Sinusuportahan ng Omarchy ang pag-set up ng napakaraming development environment sa pamamagitan ng seksyong _Install > Development_ ng Omarchy Menu (`Super + Space`). Siyempre, makikita mo roon ang _Ruby on Rails_, pati na rin ang tatlong pangunahing runtime para sa JavaScript (Node.js, Bun, Deno), at mga sikat na PHP framework tulad ng Laravel at Symfony. Ah, at may Go, Rust, Python, Java, Elixir (kasama ang Phoenix), .NET, OCaml, Zig, Clojure, at Scala rin. Napakalawak talaga ng pagpipilian!

Karamihan sa mga environment na ito ay pinamamahalaan ng [Mise](https://mise.jdx.dev/). Isa itong tool na hinahayaan kang mag-install at magpatakbo ng maraming bersyon ng isang programming language sa iisang makina. Para itong rbenv o rvm para sa Ruby o virtualenv para sa Python, pero gumagana ito para sa napakaraming iba't ibang environment.

Halimbawa, para mag-install ng Ruby, patatakbuhin mo ang `mise use -g ruby`, na parehong mag-i-install ng Ruby at magtatakda nito bilang global default. O, kung may .ruby-version file ang proyekto mo, maaari mo na lang patakbuhin ang `mise i` sa root ng proyektong iyon.

## Mga Naka-preinstall na CLI Tool

Kasamang naka-install bilang mga package ang `uv`, Node.js, at `playwright-cli` (para mapatakbo ng mga agent ang isang browser, gamit ang naka-install na Chrome), at pinapanatili silang napapanahon ng `omarchy update` kasama ng iba pang bahagi ng sistema. Isang pili na lang ang layo ng [Hunk](https://github.com/modem-dev/hunk) at ng mga CLI ng GitHub, Basecamp, Cloudflare at HEY sa ilalim ng _Install > CLI_, at ng [mga coding agent](17-ai.md) sa ilalim ng _Install > AI > CLI_.

Pinamamahalaan lang ng mise ang mga runtime na ise-set up mo mula sa _Install > Development_; wala mismong ini-install ang Omarchy sa pamamagitan nito nang mag-isa. Patakbuhin ang `omarchy update` para i-update ang mga ito kasama ng iba pang bahagi ng Omarchy; ina-update lang ng alias na `mup` ang mga tool na pinamamahalaan ng mise. Para magdagdag ng isa pang tool sa sarili mong configuration, gamitin ang `mise use -g <tool>`.

## Docker

Halos hindi na kailangan ng pagpapakilala ang [Docker](https://www.docker.com/). Hinahayaan ka nitong magpatakbo ng mga nakahiwalay na container, at ini-install ng Omarchy ang lahat ng kailangan para mapatakbo ito nang maayos, kasama ang Docker mismo at ang [Docker Compose](https://docs.docker.com/compose/).

Bilang default, *hindi* kabilang ang user mo sa grupong `docker`. Ang grupong iyon ay epektibong root na walang password — anumang nasa loob nito ay maaaring magpatakbo ng `docker run -v /:/host` at sakupin ang makina — kaya ang isang rogue na script o dependency na tumatakbo bilang ikaw ay isang command na lang ang layo mula sa pagiging root kung hindi ganoon. Kaya sa command line, pinapatakbo mo ang Docker gamit ang `sudo` (`sudo docker ps`, `sudo docker compose up`), at ang mga graphical na tool na kumakausap sa daemon — ang Windows VM — ay humihingi ng awtorisasyon kapag kailangan nila ito. Kung gusto mong maibalik ang kaginhawahan ng setup na walang grupo at naiintindihan mo ang kapalit nito, i-enable ito mula sa **Setup > Security > Sudoless Docker** (o patakbuhin ang `omarchy-setup-security-sudoless-docker`), na magdaragdag sa iyo sa grupong `docker` pagkatapos ng isang babala; pagkatapos ay gagana na ulit nang walang `sudo` ang simpleng `docker` at ang alias na `d`.

Maaari mong i-set up ang mga karaniwang database para sa lokal na development sa Docker gamit ang _Install > Development > Docker DB_ sa menu ng Omarchy.

## GitHub CLI

Ang [GitHub CLI](https://cli.github.com/) ay `gh`, para sa pagtatrabaho sa mga repository, issue, at pull request mula sa terminal. Ini-install ito ng _Setup > Git_ kapag pinili mong mag-sign in sa GitHub doon, o i-install ito nang mag-isa mula sa _Install > CLI > GitHub_. Pagkatapos, iko-clone ng `gh repo clone org/repo` ang isang repository; patakbuhin ang `gh --help` para tuklasin ang mga command nito.

Naka-preinstall ang [Lazygit](https://github.com/jesseduffield/lazygit) para sa pagtatrabaho sa Git mismo.
