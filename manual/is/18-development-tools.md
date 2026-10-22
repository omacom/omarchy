# Þróunartól

## Aðrir ritlar

Omarchy kemur sjálfgefið með [Neovim](https://neovim.io/), en ef þú vilt eitthvað aðeins algengara og þekktara geturðu opnað Omarchy-valmyndina (`Super + Space`) og skoðað valmöguleikana undir _Setja upp > Ritill_. Þar höfum við VSCode, Cursor, Zed, Sublime Text, Helix, Vim og Emacs á listanum. Ef þú finnur ekki það sem þú leitar að skaltu skoða _Setja upp > Pakki_ og sjá hvort það sé ekki til sem Arch-pakki (og ef ekki skaltu prófa _Setja upp > AUR_ til að athuga AUR).

Upprunalegi `vi`-ritillinn er líka tiltækur beint úr kassanum. Keyrðu `vi filename` til að breyta skrá í terminalinu.

Þemasamsvörun er í boði fyrir `VSCode`, `Cursor`, `VSCodium` og `Helix`.

Þú getur stillt sjálfgefna ritilinn fyrir allt kerfið undir `Uppsetning > Sjálfgildi > Ritill`.

## Umhverfi

Omarchy styður uppsetningu á heilu úrvali þróunarumhverfa í gegnum hlutann _Setja upp > Þróun_ í Omarchy-valmyndinni (`Super + Space`). Þú finnur auðvitað _Ruby on Rails_, en líka öll þrjú helstu keyrsluumhverfin fyrir JavaScript (Node.js, Bun, Deno), auk vinsælla PHP-ramma á borð við Laravel og Symfony. Já, og þar eru líka Go, Rust, Python, Java, Elixir (með Phoenix), .NET, OCaml, Zig, Clojure og Scala. Þetta er mjög breitt úrval!

Meirihluti þessara umhverfa er stjórnað af [Mise](https://mise.jdx.dev/). Þetta er tól sem gerir þér kleift að setja upp og keyra margar útgáfur af forritunarmáli á sömu vél. Þetta er eins og rbenv eða rvm fyrir Ruby eða virtualenv fyrir Python, en það virkar fyrir fullt af mismunandi umhverfum.

Til að setja upp, segjum, Ruby, keyrirðu `mise use -g ruby`, sem bæði setur Ruby upp og gerir það að almennu sjálfgildi. Eða, ef verkefnið þitt er með .ruby-version-skrá, geturðu bara keyrt `mise i` í rót þess verkefnis.

## Docker

[Docker](https://www.docker.com/) þarfnast vart nokkurrar kynningar. Það gerir þér kleift að keyra einangraða gáma, og Omarchy setur upp allt sem þarf til að keyra það vel, þar á meðal Docker sjálft og [Docker Compose](https://docs.docker.com/compose/).

Sjálfgefið er notandinn þinn *ekki* í hópnum `docker`. Sá hópur er í reynd root án lykilorðs — allt í honum getur keyrt `docker run -v /:/host` og tekið yfir vélina — þannig að eitt villuskrift eða háð pakki sem keyrir sem þú væri annars einni skipun frá root. Þess vegna keyrirðu Docker á skipanalínunni með `sudo` (`sudo docker ps`, `sudo docker compose up`), og myndrænu tólin sem tala við þjóninn — Windows-sýndarvélin — biðja um heimild þegar þau þurfa á henni að halda. Ef þú vilt þægindin við uppsetningu án hóps aftur og skilur málamiðlunina skaltu virkja það í **Uppsetning > Öryggi > Docker án sudo** (eða keyra `omarchy-setup-security-sudoless-docker`), sem bætir þér í hópinn `docker` eftir viðvörun; þá virka venjuleg `docker` og aliasinn `d` aftur án `sudo`.

Þú getur sett upp algengu gagnagrunnana fyrir staðbundna þróun í Docker með _Setja upp > Þróun > Docker DB_ í Omarchy-valmyndinni.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) gerir þér kleift að auðkenna þig með GitHub-reikningnum þínum og klóna einkarepositoríur með því. Það er tengt sem einn af letihlaðandi mise-stubbum, þannig að í fyrsta skipti sem þú keyrir `gh` setur það sig sjálft upp. Til að auðkenna þig skaltu keyra `gh auth login`. Þá geturðu sótt einkarepositoríur með `gh repo clone org/repo`.

Þú getur líka framkvæmt fullt af öðrum GitHub-aðgerðum með þessari skipun. Keyrðu bara `gh` til að sjá allt sem er mögulegt.

Það er líka til leti-uppsetningarstubbur fyrir `ghui` til að stjórna pull request-um þínum í TUI. Og [lazygit](https://github.com/jesseduffield/lazygit) er foruppsett, ef þú vilt líka stýra git sjálfu úr TUI.
