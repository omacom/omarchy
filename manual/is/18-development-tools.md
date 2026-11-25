# Þróunarverkfæri

## Aðrir ritlar

Omarchy fylgir Plain sem sjálfgefinn ritill á nýjum uppsetningum og [Neovim](https://neovim.io/) er foruppsettur, en ef þú vilt eitthvað aðeins almennara og kunnuglegra geturðu keyrt Omarchy Menu (`Super + Space`) og séð valkostina undir _Install > Editor_. Þar eru VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs taldir upp. Ef þú finnur ekki það sem þú leitar að skaltu skoða _Install > Package_ og sjá hvort það er ekki í Arch-pakka (og ef ekki, prófaðu _Install > AUR_ til að athuga AUR).

Upprunalegi `vi` ritillinn er líka tiltækur beint úr kassanum. Keyrðu `vi filename` til að breyta skrá í útstöðinni.

Þemasamsvörun er í boði fyrir `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Þú getur stillt sjálfgefinn ritil fyrir allt kerfið undir `Setup > Defaults > Editor`.

## Umhverfi

Omarchy styður að setja upp heilan helling af þróunarumhverfum í gegnum _Install > Development_ hlutann í Omarchy Menu (`Super + Space`). Þú finnur auðvitað _Ruby on Rails_, en líka öll þrjú helstu keyrsluumhverfin fyrir JavaScript (Node.js, Bun, Deno), sem og vinsæla PHP-ramma eins og Laravel og Symfony. Ó, og það er líka Go, Rust, Python, Java, Elixir (með Phoenix), .NET, OCaml, Zig, Clojure og Scala. Þetta er mjög breitt úrval!

Meirihluta þessara umhverfa er stýrt af [Mise](https://mise.jdx.dev/). Það er verkfæri sem gerir þér kleift að setja upp og keyra margar útgáfur af forritunarmáli á sömu vélinni. Það er eins og rbenv eða rvm fyrir Ruby eða virtualenv fyrir Python, en það virkar fyrir fullt af mismunandi umhverfum.

Til að setja upp, segjum, Ruby, myndirðu keyra `mise use -g ruby`, sem bæði setur upp Ruby og setur það sem almennt sjálfgefið. Eða, ef verkefnið þitt er með .ruby-version skrá, geturðu bara keyrt `mise i` í rót þess verkefnis.

## Foruppsett CLI-verkfæri

`uv`, Node.js og `playwright-cli` (fyrir umboð til að stýra vafra, með því að nota uppsetta Chrome) koma uppsett sem pakkar, og `omarchy update` heldur þeim uppfærðum með restinni af kerfinu. `ghui`, [Hunk](https://github.com/modem-dev/hunk) og Basecamp, Cloudflare og HEY CLI eru bara einn valmöguleika í burtu undir _Install > CLI_, og [kóðunarumboð](17-ai.md) undir _Install > AI > CLI_.

mise stýrir aðeins keyrsluumhverfunum sem þú setur upp frá _Install > Development_; Omarchy setur ekkert upp í gegnum það sjálft. Keyrðu `omarchy update` til að uppfæra þau með restinni af Omarchy; `mup` aliasið uppfærir aðeins verkfæri sem mise stýrir. Til að bæta öðru verkfæri við þína eigin uppsetningu skaltu nota `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) þarf varla neina kynningu. Hann gerir þér kleift að keyra einangraða gáma, og Omarchy setur upp allt sem þarf til að keyra hann vel, þar á meðal Docker sjálfan og [Docker Compose](https://docs.docker.com/compose/).

Sjálfgefið er notandinn þinn *ekki* í `docker` hópnum. Sá hópur er í raun root án lykilorðs — allt í honum getur `docker run -v /:/host` og tekið yfir vélina — svo eitt svikull skript eða ósjálfstæði sem keyrir sem þú væri annars einni skipun frá root. Svo á skipanalínunni keyrirðu Docker með `sudo` (`sudo docker ps`, `sudo docker compose up`), og myndrænu verkfærin sem tala við púkann — Windows VM — biðja um heimild þegar þau þurfa á henni að halda. Ef þú vilt þægindin við uppsetningu án hóps aftur og skilur málamiðlunina skaltu virkja hana frá **Setup > Security > Sudoless Docker** (eða keyra `omarchy-setup-security-sudoless-docker`), sem bætir þér í `docker` hópinn eftir viðvörun; þá virka venjulegt `docker` og `d` aliasið aftur án `sudo`.

Þú getur sett upp algengu gagnagrunnana fyrir staðbundna þróun í Docker með því að nota _Install > Development > Docker DB_ í Omarchy valmyndinni.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er `gh`, til að vinna með geymslur, mál og pull requests úr útstöðinni. _Setup > Git_ setur það upp þegar þú velur að skrá þig inn á GitHub þar, síðan klónar `gh repo clone org/repo` geymslu. Keyrðu `gh --help` til að skoða skipanir þess.

_Install > CLI > GitHub_ setur upp GitHub CLI, `gh`, ásamt `ghui`, útstöðvarviðmóti fyrir pull requests. [Lazygit](https://github.com/jesseduffield/lazygit) er foruppsettur til að vinna með Git sjálft.
