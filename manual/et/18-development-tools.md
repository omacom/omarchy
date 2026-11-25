# Arendustööriistad

## Alternatiivsed redaktorid

Omarchy tuleb uutel installidel vaikimisi redaktoriga Plain ja eelinstallitud [Neovim](https://neovim.io/), aga kui soovid midagi veidi tavapärasemat ja tuttavamat, saad käivitada Omarchy Menu (`Super + Space`) ja vaadata valikuid jaotises _Install > Editor_. Meil on seal loetletud VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Kui sa ei leia otsitavat, vaata jaotist _Install > Package_ ja kontrolli, kas see pole mõnes Archi paketis (ja kui ei ole, proovi jaotist _Install > AUR_, et kontrollida AUR-i).

Algne `vi` redaktor on samuti kohe karbist võtta saadaval. Faili terminalis muutmiseks käivita `vi filename`.

Teemade sobitamist pakutakse redaktoritele `VSCode`, `Cursor`, `VSCodium` ja `Helix`.

Süsteemiülese vaikiredaktori saad määrata jaotises `Setup > Defaults > Editor`.

## Keskkond

Omarchy toetab tervet hulka arenduskeskkondade seadistamist Omarchy Menu (`Super + Space`) jaotise _Install > Development_ kaudu. Leiate sealt muidugi _Ruby on Rails_-i, aga ka kõik kolm peamist JavaScripti käituskeskkonda (Node.js, Bun, Deno), samuti populaarsed PHP raamistikud nagu Laravel ja Symfony. Oh, ja seal on ka Go, Rust, Python, Java, Elixir (koos Phoenixiga), .NET, OCaml, Zig, Clojure ja Scala. See on väga lai valik!

Enamikku neist keskkondadest haldab [Mise](https://mise.jdx.dev/). See on tööriist, mis võimaldab installida ja käitada samal masinal programmeerimiskeele mitut versiooni. See on nagu rbenv või rvm Ruby jaoks või virtualenv Pythoni jaoks, aga see töötab paljude erinevate keskkondadega.

Näiteks Ruby installimiseks käivitaksid `mise use -g ruby`, mis nii installib Ruby kui ka määrab selle globaalseks vaikevalikuks. Või kui sinu projektil on .ruby-version fail, saad lihtsalt käivitada `mise i` selle projekti juurkaustas.

## Eelinstallitud CLI tööriistad

`uv`, Node.js ja `playwright-cli` (et agendid saaksid juhtida brauserit, kasutades installitud Chrome'i) on pakettidena installitud ja `omarchy update` hoiab neid koos ülejäänud süsteemiga ajakohasena. `ghui`, [Hunk](https://github.com/modem-dev/hunk) ning Basecampi, Cloudflare'i ja HEY CLI-d on ühe valiku kaugusel jaotises _Install > CLI_ ning [kodeerimisagendid](17-ai.md) jaotises _Install > AI > CLI_.

mise haldab ainult neid käituskeskkondi, mille seadistad jaotisest _Install > Development_; Omarchy ei installi selle kaudu omal käel midagi. Nende värskendamiseks koos ülejäänud Omarchyga käivita `omarchy update`; alias `mup` värskendab ainult mise hallatavaid tööriistu. Teise tööriista lisamiseks oma konfiguratsiooni kasuta käsku `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) vaevalt vajab tutvustamist. See võimaldab käitada isoleeritud konteinereid ja Omarchy installib kõik selle heaks käitamiseks vajaliku, sealhulgas Dockeri enda ja [Docker Compose](https://docs.docker.com/compose/).

Vaikimisi sinu kasutaja `docker` rühma *ei* kuulu. See rühm on sisuliselt paroolita root — igaüks selles saab käivitada `docker run -v /:/host` ja masina üle võtta — nii et üksainus sinu kasutajana töötav petturlik skript või sõltuvus oleks muidu root-õigustest vaid ühe käsu kaugusel. Nii et käsureal käivitad Dockerit `sudo`-ga (`sudo docker ps`, `sudo docker compose up`) ja graafilised tööriistad, mis deemoniga suhtlevad — Windows VM —, küsivad vajadusel autoriseerimist. Kui soovid rühmata seadistuse mugavust tagasi ja mõistad kompromissi, luba see jaotisest **Setup > Security > Sudoless Docker** (või käivita `omarchy-setup-security-sudoless-docker`), mis lisab sind pärast hoiatust `docker` rühma; siis töötavad tavaline `docker` ja alias `d` jälle ilma `sudo`-ta.

Levinud andmebaasid kohalikuks arenduseks Dockeris saad seadistada Omarchy menüü jaotise _Install > Development > Docker DB_ abil.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) on `gh`, et töötada terminalist hoidlate, issue'de ja pull request'idega. _Setup > Git_ installib selle, kui valid seal GitHubi sisse logida, seejärel kloonib `gh repo clone org/repo` hoidla. Selle käskude uurimiseks käivita `gh --help`.

_Install > CLI > GitHub_ installib GitHub CLI, `gh`, koos `ghui`-ga, terminaliliidesega pull request'ide jaoks. [Lazygit](https://github.com/jesseduffield/lazygit) on eelinstallitud Gitiga enda töötamiseks.
