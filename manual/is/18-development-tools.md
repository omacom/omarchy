# Þróunartól

## Aðrir ritlar

Omarchy kemur með Plain sem sjálfgefnum ritli í nýjum uppsetningum og [Neovim](https://neovim.io/) foruppsettu, en ef þú vilt eitthvað aðeins algengara og kunnuglegra geturðu keyrt Omarchy Menu (`Super + Space`) og skoðað valkostina undir _Install > Editor_. Þar eru VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs á listanum. Ef þú finnur ekki það sem þú leitar að skaltu kíkja á _Install > Package_ og sjá hvort það sé ekki í Arch-pakka (og ef ekki, prófaðu _Install > AUR_ til að athuga AUR).

Upprunalegi `vi`-ritillinn er líka fáanlegur beint úr kassanum. Keyrðu `vi filename` til að breyta skrá í útstöðinni.

Þemasamsvörun er í boði fyrir `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Þú getur stillt sjálfgefinn ritil fyrir allt kerfið undir `Setup > Defaults > Editor`.

## Umhverfi

Omarchy styður uppsetningu á heilum hellingi af þróunarumhverfum í gegnum _Install > Development_ hlutann í Omarchy Menu (`Super + Space`). Þar finnurðu auðvitað _Ruby on Rails_, en líka öll þrjú helstu keyrsluumhverfin fyrir JavaScript (Node.js, Bun, Deno), auk vinsælra PHP-ramma á borð við Laravel og Symfony. Ó, og þar eru líka Go, Rust, Python, Java, Elixir (með Phoenix), .NET, OCaml, Zig, Clojure og Scala. Úrvalið er mjög breitt!

Meirihluti þessara umhverfa er stýrt af [Mise](https://mise.jdx.dev/). Það er tól sem gerir þér kleift að setja upp og keyra margar útgáfur af forritunarmáli á sömu vélinni. Það er eins og rbenv eða rvm fyrir Ruby eða virtualenv fyrir Python, en það virkar fyrir fullt af mismunandi umhverfum.

Til að setja upp, segjum, Ruby keyrirðu `mise use -g ruby`, sem bæði setur upp Ruby og gerir það að almennu sjálfgefnu útgáfunni. Eða, ef verkefnið þitt er með .ruby-version skrá, geturðu bara keyrt `mise i` í rót þess verkefnis.

## Foruppsett CLI-tól

Omarchy gerir tól á borð við `gh`, `uv` og flesta [kóðunaraðila](17-ai.md) aðgengileg í gegnum [lata uppsetningu mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Í fyrsta skipti sem þú keyrir eitt þeirra setur mise það upp. Kóðunaraðilar athuga síðan hvort uppfærsla sé til staðar áður en þeir keyra, mest einu sinni á fjögurra tíma fresti; önnur tól, á borð við `gh` og `uv`, endurnota uppsettu útgáfuna þar til þú uppfærir.

Þú getur líka skoðað sjálfgefnu tólin eða sett þau upp fyrir fram:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Keyrðu `omarchy update` til að uppfæra uppsett tól ásamt restinni af Omarchy. Samnefnið `mup` uppfærir aðeins tól sem mise stýrir. Til að bæta öðru tóli við þína eigin stillingu skaltu nota `mise use -g <tool>`.

Uppsetning Python setur líka upp `uv` í gegnum mise. Ef Python-þróunarumhverfið er fjarlægt stendur `uv` eftir sem sjálfstætt tól.

### Að nota þína eigin uppsetningu

Skipanir mise koma á undan `~/.local/bin` í `PATH`, þannig að tól sem þú settir upp á eigin vegum, til dæmis með eigin uppsetningarforriti Claude Code eða Cursor, keyrir samt eintak mise. Forrit sem eru ræst af skjáborðinu finna líka skipanir mise á undan kerfispökkum, þannig að forrit sem keyrir `gh` fær eintak mise jafnvel þótt þú hafir sett upp `github-cli` með pacman, og mise setur það eintak upp í fyrsta skiptið. Til að nota þitt eigið í staðinn skaltu slökkva á eintaki mise í `~/.config/mise/config.toml`. Til dæmis, ef þú settir upp Cursor CLI á eigin vegum:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ef þú ert þegar með `[settings]` töflu skaltu bæta færslunni við þar; stækkaðu núverandi `disable_tools` lista í stað þess að skipta honum út. Gakktu úr skugga um að uppsetningin þín sé í `PATH`. Notaðu nafn mise-tólsins, sem getur verið annað en skipun þess: `oh-my-pi` veitir til dæmis `omp`. Sjálfgefni aðilaræsirinn kýs líka Cursor eða Muse sem notandi hefur sett upp í `~/.local/bin`.

### Að fjarlægja og endurheimta sjálfgefin gildi

_Remove > Preinstalls_ fjarlægir foruppsett vefforrit, TUI og forrit Omarchy og lætur mise sleppa yfirlýsingum Omarchy um tól fyrir notandann þinn með því að bæta þeim við `ignored_config_paths` í `~/.config/mise/miserc.toml`. _Install > Preinstalls_ kemur þeim aftur og fjarlægir þá línu aftur. Tól sem þú tilgreinir á eigin vegum, í þinni eigin stillingu eða í `mise.toml` verkefnis, halda áfram að virka hvort sem er. Ef þú velur sjálfgefinn aðila eða setur upp Python eftir að foruppsetningarnar hafa verið fjarlægðar er því tóli bætt við þína eigin stillingu. Mise-stillingin gildir aðeins fyrir notandann þinn og aðrir notendur halda sínu eigin vali; forritin eru hins vegar pakkar, þannig að það að fjarlægja þau eða endurheimta breytir þeim fyrir alla á vélinni.

## Docker

[Docker](https://www.docker.com/) þarf varla neina kynningu. Það gerir þér kleift að keyra einangraða gáma og Omarchy setur upp allt sem þarf til að keyra það vel, þar á meðal Docker sjálft og [Docker Compose](https://docs.docker.com/compose/).

Sjálfgefið er notandinn þinn *ekki* í `docker` hópnum. Sá hópur er í raun root án lykilorðs — allt í honum getur keyrt `docker run -v /:/host` og tekið yfir vélina — þannig að eitt svikaskript eða háður pakki sem keyrir undir þér væri annars aðeins einni skipun frá root. Í skipanalínunni keyrirðu því Docker með `sudo` (`sudo docker ps`, `sudo docker compose up`) og myndrænu tólin sem tala við púkann — Windows VM — biðja um heimild þegar þau þurfa á henni að halda. Ef þú vilt þægindin við uppsetningu án hóps aftur og skilur málamiðlunina skaltu virkja það í **Setup > Security > Sudoless Docker** (eða keyra `omarchy-setup-security-sudoless-docker`), sem bætir þér í `docker` hópinn eftir viðvörun; þá virka venjulegt `docker` og samnefnið `d` aftur án `sudo`.

Þú getur sett upp algengu gagnagrunnana fyrir staðbundna þróun í Docker með _Install > Development > Docker DB_ í Omarchy-valmyndinni.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er fáanlegt sem `gh` til að vinna með kóðageymslur, mál og pull request úr útstöðinni. Keyrðu `gh auth login` til að setja það upp við fyrstu notkun og auðkenna þig, síðan `gh repo clone org/repo` til að klóna kóðageymslu. Keyrðu `gh --help` til að skoða skipanir þess.

Fyrir útstöðvarviðmót fyrir pull request skaltu keyra `ghui`; mise setur það líka upp við fyrstu notkun. [Lazygit](https://github.com/jesseduffield/lazygit) er foruppsett til að vinna með Git sjálft.
