# Mga Tool sa Pag-develop

## Mga Alternatibong Editor

Ang Omarchy ay may Plain bilang default na editor sa mga bagong install at naka-preinstall ang [Neovim](https://neovim.io/), ngunit kung gusto mo ng medyo mas mainstream at pamilyar, maaari mong patakbuhin ang Omarchy Menu (`Super + Space`) at tingnan ang mga opsyon sa ilalim ng _Install > Editor_. May nakalista roon na VSCode, Cursor, Zed, Sublime Text, Helix, Vim, at Emacs. Kung hindi mo makita ang hinahanap mo, tingnan ang _Install > Package_, at tingnan kung wala ito sa isang Arch package (at kung wala, subukan ang _Install > AUR_ para tingnan ang AUR).

Available din agad ang orihinal na editor na `vi`. Patakbuhin ang `vi filename` para mag-edit ng file sa terminal.

Inaalok ang pagtutugma ng tema para sa `VSCode`, `Cursor`, `VSCodium`, at `Helix`.

Maaari mong itakda ang default na editor para sa buong sistema sa ilalim ng `Setup > Defaults > Editor`.

## Environment

Sinusuportahan ng Omarchy ang pag-setup ng napakaraming environment sa pag-develop sa pamamagitan ng seksyong _Install > Development_ ng Omarchy Menu (`Super + Space`). Makikita mo siyempre ang _Ruby on Rails_, ngunit pati ang tatlong pangunahing runtime para sa JavaScript (Node.js, Bun, Deno), pati na rin ang mga sikat na PHP framework tulad ng Laravel at Symfony. Oh, at mayroon ding Go, Rust, Python, Java, Elixir (kasama ang Phoenix), .NET, OCaml, Zig, Clojure, at Scala. Napakalawak ng pagpipilian!

Karamihan sa mga environment na ito ay pinamamahalaan ng [Mise](https://mise.jdx.dev/). Ito ay isang tool na nagbibigay-daan sa iyong mag-install at magpatakbo ng maraming bersyon ng isang programming language sa iisang machine. Para itong rbenv o rvm para sa Ruby o virtualenv para sa Python, ngunit gumagana ito para sa napakaraming iba't ibang environment.

Para mag-install, halimbawa, ng Ruby, patakbuhin mo ang `mise use -g ruby`, na mag-i-install sa Ruby at magtatakda nito bilang global na default. O, kung may .ruby-version file ang proyekto mo, maaari mo lang patakbuhin ang `mise i` sa root ng proyektong iyon.

## Mga Naka-preinstall na CLI Tool

Ang `uv`, Node.js, at `playwright-cli` (para mapatakbo ng mga agent ang isang browser, gamit ang naka-install na Chrome) ay naka-install bilang mga package, at pinapanatili silang napapanahon ng `omarchy update` kasama ng iba pang bahagi ng sistema. Ang `ghui`, [Hunk](https://github.com/modem-dev/hunk), at ang mga CLI ng Basecamp, Cloudflare at HEY ay isang pagpili lang ang layo sa ilalim ng _Install > CLI_, at ang [mga coding agent](17-ai.md) ay nasa ilalim ng _Install > AI > CLI_.

Pinamamahalaan lang ng mise ang mga runtime na ise-setup mo mula sa _Install > Development_; walang ini-install ang Omarchy sa pamamagitan nito nang mag-isa. Patakbuhin ang `omarchy update` para i-update ang mga ito kasama ng iba pang bahagi ng Omarchy; ang alias na `mup` ay nag-a-update lang ng mga tool na pinamamahalaan ng mise. Para magdagdag ng isa pang tool sa sarili mong configuration, gamitin ang `mise use -g <tool>`.

## Docker

Halos hindi na kailangan ng pagpapakilala ang [Docker](https://www.docker.com/). Nagbibigay-daan ito sa iyong magpatakbo ng mga isolated na container, at ini-install ng Omarchy ang lahat ng kailangan para mapatakbo ito nang maayos, kabilang ang Docker mismo at ang [Docker Compose](https://docs.docker.com/compose/).

Bilang default, ang user mo ay *hindi* kabilang sa grupong `docker`. Ang grupong iyon ay epektibong passwordless root — anumang nasa loob nito ay maaaring magpatakbo ng `docker run -v /:/host` at sakupin ang machine — kaya ang isang rogue script o dependency na tumatakbo bilang ikaw ay magiging isang command lang ang layo mula sa root. Kaya sa command line, pinapatakbo mo ang Docker gamit ang `sudo` (`sudo docker ps`, `sudo docker compose up`), at ang mga graphical tool na nakikipag-usap sa daemon — ang Windows VM — ay humihingi ng authorization kapag kailangan nila ito. Kung gusto mo ulit ang kaginhawahan ng setup na walang grupo at nauunawaan mo ang tradeoff, paganahin ito mula sa **Setup > Security > Sudoless Docker** (o patakbuhin ang `omarchy-setup-security-sudoless-docker`), na nagdaragdag sa iyo sa grupong `docker` pagkatapos ng isang babala; pagkatapos ay gumagana ulit ang simpleng `docker` at ang alias na `d` nang walang `sudo`.

Maaari mong i-setup ang mga karaniwang database para sa local development sa Docker gamit ang _Install > Development > Docker DB_ sa menu ng Omarchy.

## GitHub CLI

Ang [GitHub CLI](https://cli.github.com/) ay ang `gh`, para sa pagtatrabaho sa mga repository, issue, at pull request mula sa terminal. Ini-install ito ng _Setup > Git_ kapag pinili mong mag-sign in sa GitHub roon, pagkatapos ay kini-clone ng `gh repo clone org/repo` ang isang repository. Patakbuhin ang `gh --help` para tuklasin ang mga command nito.

Ini-install ng _Install > CLI > GitHub_ ang GitHub CLI, `gh`, kasama ang `ghui`, isang terminal interface para sa mga pull request. Naka-preinstall ang [Lazygit](https://github.com/jesseduffield/lazygit) para sa pagtatrabaho sa Git mismo.
