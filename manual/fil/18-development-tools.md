# Mga Tool sa Pag-develop

## Mga Alternatibong Editor

Sa Omarchy, [Neovim](https://neovim.io/) ang default, pero kung gusto mo ng medyo mas mainstream at pamilyar, puwede mong buksan ang Omarchy Menu (`Super + Space`) at tingnan ang mga opsyon sa ilalim ng _Install > Editor_. Nandoon ang VSCode, Cursor, Zed, Sublime Text, Helix, Vim, at Emacs. Kung hindi mo makita ang hinahanap mo, tingnan ang _Install > Package_, at tingnan kung nasa isang Arch package ito (at kung wala, subukan ang _Install > AUR_ para tingnan ang AUR).

Available din agad ang orihinal na `vi` editor. Patakbuhin ang `vi filename` para mag-edit ng file sa terminal.

Inaalok ang pagtutugma ng tema para sa `VSCode`, `Cursor`, `VSCodium`, at `Helix`.

Puwede mong itakda ang default na editor para sa buong sistema sa ilalim ng `Setup > Defaults > Editor`.

## Mga Environment

Sinusuportahan ng Omarchy ang pag-set up ng napakaraming development environment sa pamamagitan ng seksyong _Install > Development_ ng Omarchy Menu (`Super + Space`). Siyempre, makikita mo roon ang _Ruby on Rails_, pero pati ang tatlong pangunahing runtime para sa JavaScript (Node.js, Bun, Deno), pati na ang mga sikat na PHP framework tulad ng Laravel at Symfony. Ay, at nandoon din ang Go, Rust, Python, Java, Elixir (kasama ang Phoenix), .NET, OCaml, Zig, Clojure, at Scala. Napakalawak ng pagpipilian!

Karamihan sa mga environment na ito ay pinamamahalaan ng [Mise](https://mise.jdx.dev/). Isa itong tool na hinahayaan kang mag-install at magpatakbo ng maraming bersyon ng isang programming language sa iisang machine. Para itong rbenv o rvm para sa Ruby o virtualenv para sa Python, pero gumagana ito para sa napakaraming iba't ibang environment.

Para mag-install, halimbawa, ng Ruby, patakbuhin mo ang `mise use -g ruby`, na mag-i-install ng Ruby at magtatakda nito bilang global default. O, kung may .ruby-version file ang proyekto mo, puwede mo na lang patakbuhin ang `mise i` sa root ng proyektong iyon.

## Mga Preinstalled na CLI tool

Ginagawang available ng Omarchy ang mga tool tulad ng `gh`, `uv`, at karamihan sa [mga coding agent](17-ai.md) sa pamamagitan ng [lazy installation ng mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Sa unang beses na patakbuhin mo ang isa, i-install ito ng mise. Sa mga susunod na pagtakbo, gagamitin ulit ang naka-install na bersyon; hindi ito naghahanap ng update sa bawat pagbukas.

Puwede mo ring tingnan ang mga default o i-install ang mga ito nang maaga:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Patakbuhin ang `omarchy update` para i-update ang mga naka-install na tool kasama ng iba pang bahagi ng Omarchy. Ang `mup` alias ay nag-a-update lamang ng mga tool na pinamamahalaan ng mise. Para magdagdag ng isa pang tool sa sarili mong configuration, gamitin ang `mise use -g <tool>`.

Kasama rin sa pag-set up ng Python ang pag-install ng `uv` sa pamamagitan ng mise. Ang pag-alis ng Python development environment ay mag-iiwan sa `uv` na available bilang isang hiwalay na tool.

### Paggamit ng sarili mong installation

Ang mga command ng mise ay nauuna bago ang `~/.local/bin` sa `PATH`, kaya ang isang tool na ikaw mismo ang nag-install, halimbawa gamit ang sariling installer ng Claude Code o Cursor, ay patatakbuhin pa rin ang kopya ng mise. Ang mga app na binuksan mula sa desktop ay nakakakita rin ng mga command ng mise bago ang mga system package, kaya ang isang app na nagpapatakbo ng `gh` ay makukuha ang kopya ng mise kahit nag-install ka ng `github-cli` gamit ang pacman, at i-install ng mise ang kopyang iyon sa unang beses. Para sa halip ay gamitin ang sa iyo, i-disable ang kopya ng mise sa `~/.config/mise/config.toml`. Halimbawa, kung ikaw mismo ang nag-install ng Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Kung mayroon ka nang `[settings]` table, idagdag doon ang entry; palawigin ang kasalukuyang `disable_tools` list sa halip na palitan ito. Siguraduhing nasa `PATH` ang installation mo. Gamitin ang pangalan ng tool sa mise, na puwedeng iba sa command nito: ang `oh-my-pi` ay nagbibigay ng `omp`, halimbawa. Mas pinipili rin ng default-agent launcher ang Cursor o Muse na in-install ng user sa `~/.local/bin`.

### Pag-alis at pagbalik ng mga default

Ang _Remove Preinstalls_ ay nagpapalaktaw sa mise sa mga deklarasyon ng tool ng Omarchy para sa user mo, sa pamamagitan ng pagdaragdag ng mga ito sa `ignored_config_paths` sa `~/.config/mise/miserc.toml`. Ang _Restore Preinstalls_ ay nag-aalis ulit ng linyang iyon. Ang mga tool na ikaw mismo ang nagdeklara, sa sarili mong config o sa `mise.toml` ng isang proyekto, ay patuloy na gagana alinman ang piliin. Kung pipili ka ng default agent o magse-set up ng Python pagkatapos alisin ang mga preinstall, idaragdag ang tool na iyon sa sarili mong config. Parehong nalalapat lamang sa user mo; ang ibang mga user sa machine ay mananatili sa sarili nilang pinili.

## Docker

Ang [Docker](https://www.docker.com/) ay halos hindi na kailangan ng pagpapakilala. Hinahayaan ka nitong magpatakbo ng mga isolated container, at ini-install ng Omarchy ang lahat ng kailangan para mapatakbo ito nang maayos, kasama ang Docker mismo at ang [Docker Compose](https://docs.docker.com/compose/).

Bilang default, ang user mo ay *hindi* kabilang sa `docker` group. Ang group na iyon ay epektibong passwordless root — ang sinumang kabilang dito ay puwedeng magpatakbo ng `docker run -v /:/host` at sakupin ang machine — kaya ang isang rogue script o dependency na tumatakbo bilang ikaw ay isang command na lang ang layo mula sa root. Kaya sa command line, pinapatakbo mo ang Docker gamit ang `sudo` (`sudo docker ps`, `sudo docker compose up`), at ang mga graphical tool na nakikipag-usap sa daemon — ang Windows VM — ay humihingi ng authorization kapag kailangan nila ito. Kung gusto mong ibalik ang kaginhawahan ng setup na walang group at naiintindihan mo ang kapalit, i-enable ito mula sa **Setup > Security > Sudoless Docker** (o patakbuhin ang `omarchy-setup-security-sudoless-docker`), na magdaragdag sa iyo sa `docker` group pagkatapos ng isang babala; pagkatapos ay gagana ulit ang simpleng `docker` at ang `d` alias nang walang `sudo`.

Puwede mong i-set up ang mga karaniwang database para sa local development sa Docker gamit ang _Install > Development > Docker DB_ sa Omarchy menu.

## GitHub CLI

Ang [GitHub CLI](https://cli.github.com/) ay available bilang `gh` para sa pagtrabaho sa mga repository, issue, at pull request mula sa terminal. Patakbuhin ang `gh auth login` para i-install ito sa unang paggamit at mag-authenticate, pagkatapos ay `gh repo clone org/repo` para mag-clone ng isang repository. Patakbuhin ang `gh --help` para tuklasin ang mga command nito.

Para sa isang terminal interface para sa mga pull request, patakbuhin ang `ghui`; ini-install din ito ng mise sa unang paggamit. Ang [Lazygit](https://github.com/jesseduffield/lazygit) ay naka-preinstall para sa pagtrabaho sa Git mismo.
