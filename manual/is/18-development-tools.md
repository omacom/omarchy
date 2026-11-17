# Þróunartól

## Aðrir ritlar

Omarchy kemur með [Neovim](https://neovim.io/) sjálfgefið, en ef þú vilt eitthvað aðeins almennara og kunnuglegra geturðu opnað Omarchy-valmyndina (`Super + Space`) og skoðað valkostina undir _Setja upp > Ritill_. Þar höfum við VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs á listanum. Ef þú finnur ekki það sem þú leitar að skaltu kíkja á _Setja upp > Pakki_ og sjá hvort það sé ekki til sem Arch-pakki (og ef ekki skaltu prófa _Setja upp > AUR_ til að athuga AUR).

Upprunalegi `vi`-ritillinn fylgir líka með frá upphafi. Keyrðu `vi filename` til að breyta skrá í útstöðinni.

Þemasamsvörun er í boði fyrir `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Þú getur stillt sjálfgefinn ritil fyrir allt kerfið undir `Uppsetning > Sjálfgefið > Ritill`.

## Umhverfi

Omarchy styður uppsetningu á heilum hellingi þróunarumhverfa í gegnum _Setja upp > Þróun_ hlutann í Omarchy-valmyndinni (`Super + Space`). Þar finnurðu auðvitað _Ruby on Rails_, en líka öll þrjú helstu keyrsluumhverfin fyrir JavaScript (Node.js, Bun, Deno), ásamt vinsælum PHP-rammaverkum á borð við Laravel og Symfony. Ó, og þar er líka Go, Rust, Python, Java, Elixir (með Phoenix), .NET, OCaml, Zig, Clojure og Scala. Úrvalið er mjög breitt!

Flest þessara umhverfa eru undir stjórn [Mise](https://mise.jdx.dev/). Það er tól sem gerir þér kleift að setja upp og keyra margar útgáfur af forritunarmáli á sömu vélinni. Það er eins og rbenv eða rvm fyrir Ruby eða virtualenv fyrir Python, en virkar fyrir fullt af mismunandi umhverfum.

Til að setja upp, segjum, Ruby keyrirðu `mise use -g ruby`, sem bæði setur Ruby upp og gerir það að almennu sjálfgefnu útgáfunni. Eða, ef verkefnið þitt er með .ruby-version skrá, geturðu bara keyrt `mise i` í rót þess verkefnis.

## Foruppsett CLI-tól

Omarchy gerir tól á borð við `gh`, `uv` og flesta [kóðunarumboðsmenn](17-ai.md) aðgengileg í gegnum [seinni uppsetningu mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Fyrsta skiptið sem þú keyrir eitt þeirra setur mise það upp. Síðari keyrslur endurnota uppsettu útgáfuna; þær athuga ekki hvort uppfærsla sé til í boði í hvert sinn sem þau eru ræst.

Þú getur líka skoðað sjálfgefnu tólin eða sett þau upp fyrirfram:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Keyrðu `omarchy update` til að uppfæra uppsett tól ásamt restinni af Omarchy. Styttingin `mup` uppfærir aðeins tól undir stjórn mise. Til að bæta öðru tóli við þína eigin stillingu skaltu nota `mise use -g <tool>`.

Uppsetning Python setur einnig upp `uv` í gegnum mise. Ef þróunarumhverfi Python er fjarlægt verður `uv` áfram tiltækt sem sjálfstætt tól.

### Að nota þína eigin uppsetningu

Skipanir mise koma á undan `~/.local/bin` í `PATH`, svo tól sem þú settir upp sjálfur, til dæmis með eigin uppsetningarforriti Claude Code eða Cursor, keyrir samt eintak mise. Forrit sem ræst eru af skjáborðinu finna líka skipanir mise á undan kerfispökkum, svo forrit sem keyrir `gh` fær eintak mise jafnvel þótt þú hafir sett upp `github-cli` með pacman, og mise setur það eintak upp í fyrsta skiptið. Til að nota þitt eigið í staðinn skaltu slökkva á eintaki mise í `~/.config/mise/config.toml`. Til dæmis, ef þú settir upp Cursor CLI sjálfur:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ef þú ert þegar með `[settings]` töflu skaltu bæta færslunni við þar; stækkaðu núverandi `disable_tools` lista frekar en að skipta honum út. Gakktu úr skugga um að uppsetningin þín sé í `PATH`. Notaðu heiti mise-tólsins, sem getur verið annað en skipun þess: `oh-my-pi` býður upp á `omp`, til dæmis. Sjálfgefni umboðsræsirinn kýs líka Cursor eða Claude sem notandi hefur sett upp í `~/.local/bin`.

### Að fjarlægja og endurheimta sjálfgefin gildi

_Fjarlægja foruppsetningar_ lætur mise sleppa verkfærayfirlýsingum Omarchy fyrir notandann þinn með því að bæta þeim við `ignored_config_paths` í `~/.config/mise/miserc.toml`. _Endurheimta foruppsetningar_ fjarlægir þá línu aftur. Tól sem þú tilgreinir sjálfur, í þinni eigin stillingu eða í `mise.toml` verkefnis, halda áfram að virka hvort sem er. Ef þú velur sjálfgefinn umboðsmann eða setur upp Python eftir að hafa fjarlægt foruppsetningarnar er því tóli bætt við þína eigin stillingu. Bæði gilda aðeins um notandann þinn; aðrir notendur á vélinni halda sínu eigin vali.

## Docker

[Docker](https://www.docker.com/) þarf varla neina kynningu. Það gerir þér kleift að keyra einangraða gáma, og Omarchy setur upp allt sem þarf til að keyra það vel, þar á meðal Docker sjálft og [Docker Compose](https://docs.docker.com/compose/).

Sjálfgefið er notandinn þinn *ekki* í `docker` hópnum. Sá hópur er í raun rótaraðgangur án lykilorðs — allt í honum getur keyrt `docker run -v /:/host` og tekið yfir vélina — svo eitt svikaskript eða ósjálfstæði sem keyrir sem þú væri annars einni skipun frá rótaraðgangi. Svo á skipanalínunni keyrirðu Docker með `sudo` (`sudo docker ps`, `sudo docker compose up`), og myndrænu tólin sem tala við bakvinnsluna — Windows VM — biðja um heimild þegar þau þurfa á henni að halda. Ef þú vilt þægindin við uppsetningu án hóps aftur og skilur málamiðlunina skaltu virkja hana í **Uppsetning > Öryggi > Docker án sudo** (eða keyra `omarchy-setup-security-sudoless-docker`), sem bætir þér við `docker` hópinn eftir viðvörun; þá virka einfalt `docker` og styttingin `d` aftur án `sudo`.

Þú getur sett upp algenga gagnagrunna fyrir staðbundna þróun í Docker með _Setja upp > Þróun > Docker DB_ í Omarchy-valmyndinni.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er tiltækt sem `gh` til að vinna með kóðageymslur, mál og sameiningarbeiðnir úr útstöðinni. Keyrðu `gh auth login` til að setja það upp við fyrstu notkun og auðkenna þig, síðan `gh repo clone org/repo` til að klóna kóðageymslu. Keyrðu `gh --help` til að kanna skipanir þess.

Fyrir útstöðvarviðmót fyrir sameiningarbeiðnir skaltu keyra `ghui`; mise setur það líka upp við fyrstu notkun. [Lazygit](https://github.com/jesseduffield/lazygit) er foruppsett til að vinna með Git sjálft.
