# Þróunartól

## Aðrir ritlar

Omarchy kemur með Plain sem sjálfgefinn ritil á nýjum uppsetningum og [Neovim](https://neovim.io/) foruppsett, en ef þú vilt eitthvað aðeins meira almennt og kunnuglegt geturðu keyrt Omarchy Menu (`Super + Space`) og séð valkostina undir _Install > Editor_. Þar höfum við VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs á listanum. Ef þú finnur ekki það sem þú leitar að skaltu kíkja á _Install > Package_ og sjá hvort það sé ekki í Arch-pakka (og ef ekki, prófaðu _Install > AUR_ til að athuga AUR).

Upprunalegi `vi` ritillinn er líka tiltækur beint úr kassanum. Keyrðu `vi filename` til að breyta skrá í útstöðinni.

Þemasamræming er í boði fyrir `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Þú getur stillt sjálfgefinn ritil fyrir allt kerfið undir `Setup > Defaults > Editor`.

## Umhverfi

Omarchy styður að setja upp heilan helling af þróunarumhverfum í gegnum _Install > Development_ hlutann í Omarchy Menu (`Super + Space`). Þú finnur auðvitað _Ruby on Rails_, en líka öll þrjú helstu keyrsluumhverfin fyrir JavaScript (Node.js, Bun, Deno), auk vinsælla PHP-ramma á borð við Laravel og Symfony. Ó, og þar er líka Go, Rust, Python, Java, Elixir (með Phoenix), .NET, OCaml, Zig, Clojure og Scala. Úrvalið er virkilega breitt!

Meirihluti þessara umhverfa er stýrt af [Mise](https://mise.jdx.dev/). Það er tól sem gerir þér kleift að setja upp og keyra margar útgáfur af forritunarmáli á sömu vél. Það er eins og rbenv eða rvm fyrir Ruby eða virtualenv fyrir Python, en það virkar fyrir fullt af mismunandi umhverfum.

Til að setja upp, segjum, Ruby keyrirðu `mise use -g ruby`, sem bæði setur upp Ruby og stillir það sem altækt sjálfgefið. Eða, ef verkefnið þitt er með .ruby-version skrá, geturðu bara keyrt `mise i` í rót þess verkefnis.

## Foruppsett CLI-tól

`uv`, Node.js og `playwright-cli` (til að agentar geti stýrt vafra með uppsetta Chrome) koma uppsett sem pakkar, og `omarchy update` heldur þeim uppfærðum með restinni af kerfinu. [Hunk](https://github.com/modem-dev/hunk) og GitHub, Basecamp, Cloudflare og HEY CLI-tólin eru aðeins eitt val í burtu undir _Install > CLI_, og [kóðunaragentar](17-ai.md) undir _Install > AI > CLI_.

mise stýrir aðeins keyrsluumhverfunum sem þú setur upp frá _Install > Development_; Omarchy setur ekkert upp í gegnum það sjálft. Keyrðu `omarchy update` til að uppfæra þau með restinni af Omarchy; `mup` samnefnið uppfærir aðeins tól sem mise stýrir. Til að bæta öðru tóli við þína eigin stillingu skaltu nota `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) þarf varla neina kynningu. Það gerir þér kleift að keyra einangraða gáma, og Omarchy setur upp allt sem þarf til að keyra það vel, þar með talið Docker sjálft og [Docker Compose](https://docs.docker.com/compose/).

Sjálfgefið er notandinn þinn *ekki* í `docker` hópnum. Sá hópur er í raun root án lykilorðs — allt í honum getur keyrt `docker run -v /:/host` og tekið yfir vélina — þannig að ein svikaskripta eða háð eining sem keyrir sem þú væri annars aðeins einni skipun frá root. Á skipanalínunni keyrirðu því Docker með `sudo` (`sudo docker ps`, `sudo docker compose up`), og myndrænu tólin sem tala við þjónustuna — Windows VM — biðja um heimild þegar þau þurfa á henni að halda. Ef þú vilt þægindin við hóplaust fyrirkomulag aftur og skilur málamiðlunina skaltu virkja það í **Setup > Security > Sudoless Docker** (eða keyra `omarchy-setup-security-sudoless-docker`), sem bætir þér í `docker` hópinn eftir viðvörun; þá virka venjulegt `docker` og `d` samnefnið án `sudo` aftur.

Þú getur sett upp algengu gagnagrunnana fyrir staðbundna þróun í Docker með _Install > Development > Docker DB_ í Omarchy-valmyndinni.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) er `gh`, til að vinna með kóðageymslur, mál og pull requests frá útstöðinni. _Setup > Git_ setur það upp þegar þú velur að skrá þig inn á GitHub þar, eða settu það upp sérstaklega frá _Install > CLI > GitHub_. Þá klónar `gh repo clone org/repo` kóðageymslu; keyrðu `gh --help` til að skoða skipanir þess.

[Lazygit](https://github.com/jesseduffield/lazygit) er foruppsett til að vinna með Git sjálft.
