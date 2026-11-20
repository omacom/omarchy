# Mga Tool sa Development

## Mga Alternatibong Editor

Kasama ng Omarchy ang Plain bilang default na editor sa mga bagong install at naka-preinstall ang [Neovim](https://neovim.io/), pero kung gusto mo ng medyo mas mainstream at pamilyar, maaari mong patakbuhin ang Omarchy Menu (`Super + Space`) at tingnan ang mga pagpipilian sa ilalim ng _Install > Editor_. Nakalista roon ang VSCode, Cursor, Zed, Sublime Text, Helix, Vim, at Emacs. Kung hindi mo makita ang hinahanap mo, pumunta sa _Install > Package_, at tingnan kung wala ito sa isang Arch package (at kung wala, subukan ang _Install > AUR_ para tingnan ang AUR).

Available din agad ang orihinal na `vi` editor. Patakbuhin ang `vi filename` para mag-edit ng file sa terminal.

May iniaalok na pagtutugma ng theme para sa `VSCode`, `Cursor`, `VSCodium`, at `Helix`.

Maaari mong itakda ang default na editor para sa buong sistema sa ilalim ng `Setup > Defaults > Editor`.

## Mga Environment

Sinusuportahan ng Omarchy ang pag-set up ng napakaraming development environment sa pamamagitan ng seksyong _Install > Development_ ng Omarchy Menu (`Super + Space`). Siyempre, makikita mo roon ang _Ruby on Rails_, pero pati ang lahat ng tatlong pangunahing runtime para sa JavaScript (Node.js, Bun, Deno), pati ang mga sikat na PHP framework tulad ng Laravel at Symfony. Naku, at nariyan din ang Go, Rust, Python, Java, Elixir (kasama ang Phoenix), .NET, OCaml, Zig, Clojure, at Scala. Napakalawak talaga ng pagpipilian!

Karamihan sa mga environment na ito ay pinamamahalaan ng [Mise](https://mise.jdx.dev/). Isang tool ito na nagbibigay-daan sa iyong mag-install at magpatakbo ng maraming bersyon ng isang programming language sa iisang machine. Parang rbenv o rvm para sa Ruby o virtualenv para sa Python, pero gumagana ito para sa napakaraming iba't ibang environment.

Para mag-install, halimbawa, ng Ruby, patakbuhin mo ang `mise use -g ruby`, na mag-i-install sa Ruby at magtatakda rin nito bilang global na default. O, kung may .ruby-version file ang proyekto mo, maaari mo na lang patakbuhin ang `mise i` sa root ng proyektong iyon.

## Mga naka-preinstall na CLI tool

Ginagawang available ng Omarchy ang mga tool tulad ng `gh`, `uv`, at karamihan sa [mga coding agent](17-ai.md) sa pamamagitan ng [lazy installation ng mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Sa unang beses na patakbuhin mo ang isa, i-i-install ito ng mise. Pagkatapos ay maghahanap ang mga coding agent ng update bago sila tumakbo, nang hindi hihigit sa isang beses kada apat na oras; ang ibang tool, tulad ng `gh` at `uv`, ay muling ginagamit ang naka-install na bersyon hanggang mag-update ka.

Maaari mo ring siyasatin ang mga default o i-install ang mga ito nang maaga:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Patakbuhin ang `omarchy update` para i-update ang mga naka-install na tool kasama ang iba pang bahagi ng Omarchy. Ang alias na `mup` ay nag-a-update lamang ng mga tool na pinamamahalaan ng mise. Para magdagdag ng isa pang tool sa sarili mong configuration, gamitin ang `mise use -g <tool>`.

Nag-i-install din ang setup ng Python ng `uv` sa pamamagitan ng mise. Ang pag-alis sa Python development environment ay nag-iiwan sa `uv` na available bilang isang independiyenteng tool.

### Paggamit ng sarili mong installation

Nauna ang mga command ng mise bago ang `~/.local/bin` sa `PATH`, kaya ang isang tool na ikaw mismo ang nag-install, halimbawa gamit ang sariling installer ng Claude Code o ng Cursor, ay kopya pa rin ng mise ang patatakbuhin. Ang mga app na inilulunsad mula sa desktop ay nakikita rin ang mga command ng mise bago ang mga system package, kaya ang isang app na nagpapatakbo ng `gh` ay makukuha ang kopya ng mise kahit nag-install ka ng `github-cli` gamit ang pacman, at i-i-install ng mise ang kopyang iyon sa unang beses. Para gamitin sa halip ang sa iyo, i-disable ang kopya ng mise sa `~/.config/mise/config.toml`. Halimbawa, kung ikaw mismo ang nag-install ng Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Kung mayroon ka nang talahanayan ng `[settings]`, idagdag ang entry doon; palawigin ang umiiral na listahan ng `disable_tools` sa halip na palitan ito. Tiyaking nasa `PATH` ang installation mo. Gamitin ang pangalan ng mise tool, na maaaring iba sa command nito: ibinibigay ng `oh-my-pi` ang `omp`, halimbawa. Mas pinipili rin ng default-agent launcher ang Cursor o Muse na in-install ng user sa `~/.local/bin`.

### Pag-alis at pagbabalik ng mga default

Inaalis ng _Remove > Preinstalls_ ang mga naka-preinstall na web app, TUI at app ng Omarchy, at pinababayaan nitong laktawan ng mise ang mga deklarasyon ng tool ng Omarchy para sa user mo, sa pamamagitan ng pagdaragdag sa mga ito sa `ignored_config_paths` sa `~/.config/mise/miserc.toml`. Ibinabalik sila ng _Install > Preinstalls_ at inaalis muli ang linyang iyon. Ang mga tool na ikaw mismo ang nagdeklara, sa sarili mong config o sa `mise.toml` ng isang proyekto, ay patuloy na gumagana alinman ang mangyari. Kung pipili ka ng default na agent o magse-set up ng Python pagkatapos alisin ang mga preinstall, idaragdag ang tool na iyon sa sarili mong config. Nalalapat lamang ang setting ng mise sa user mo, at pinapanatili ng ibang mga user ang sarili nilang pagpipilian; ang mga app ay mga package, gayunpaman, kaya ang pag-alis o pagbabalik sa mga ito ay nagpapabago sa mga ito para sa lahat ng nasa machine.

## Docker

Halos hindi na kailangan ng [Docker](https://www.docker.com/) ng anumang pagpapakilala. Nagbibigay-daan ito sa iyong magpatakbo ng mga nakahiwalay na container, at ini-install ng Omarchy ang lahat ng kailangan para mapatakbo ito nang maayos, kabilang ang Docker mismo at ang [Docker Compose](https://docs.docker.com/compose/).

Bilang default, ang user mo ay *hindi* kabilang sa `docker` group. Ang group na iyon ay epektibong root na walang password — anumang nasa loob nito ay maaaring magpatakbo ng `docker run -v /:/host` at agawin ang machine — kaya ang isang rogue na script o dependency na tumatakbo bilang ikaw ay kung hindi man ay isang command na lang ang layo mula sa root. Kaya sa command line, patakbuhin mo ang Docker gamit ang `sudo` (`sudo docker ps`, `sudo docker compose up`), at ang mga grapikal na tool na nakikipag-usap sa daemon — ang Windows VM — ay humihingi ng awtorisasyon kapag kailangan nila ito. Kung gusto mong maibalik ang kaginhawahan ng setup na walang group at naiintindihan mo ang kapalit nito, i-enable ito mula sa **Setup > Security > Sudoless Docker** (o patakbuhin ang `omarchy-setup-security-sudoless-docker`), na magdaragdag sa iyo sa `docker` group pagkatapos ng isang babala; pagkatapos ay gagana muli ang simpleng `docker` at ang alias na `d` nang walang `sudo`.

Maaari mong i-setup ang mga karaniwang database para sa lokal na development sa Docker gamit ang _Install > Development > Docker DB_ sa menu ng Omarchy.

## GitHub CLI

Available ang [GitHub CLI](https://cli.github.com/) bilang `gh` para sa pagtatrabaho sa mga repository, issue, at pull request mula sa terminal. Patakbuhin ang `gh auth login` para i-install ito sa unang paggamit at mag-authenticate, pagkatapos ay `gh repo clone org/repo` para mag-clone ng isang repository. Patakbuhin ang `gh --help` para tuklasin ang mga command nito.

Para sa isang terminal interface para sa mga pull request, patakbuhin ang `ghui`; ini-install din ito ng mise sa unang paggamit. Naka-preinstall ang [Lazygit](https://github.com/jesseduffield/lazygit) para sa pagtatrabaho sa Git mismo.
