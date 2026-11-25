# Arendustööriistad

## Alternatiivsed redaktorid

Omarchy tuleb uutel installidel vaikimisi redaktoriga Plain ja eelinstallitud [Neovim](https://neovim.io/), aga kui tahad midagi peavoolulisemat ja tuttavamat, võid käivitada Omarchy Menu (`Super + Space`) ja vaadata valikuid jaotises _Install > Editor_. Seal on loetletud VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Kui sa ei leia seda, mida otsid, vaata jaotist _Install > Package_ ja kontrolli, kas see pole mõnes Archi paketis (ja kui ei ole, proovi AURi kontrollimiseks jaotist _Install > AUR_).

Originaalne `vi` redaktor on samuti kohe olemas. Faili terminalis redigeerimiseks käivita `vi filename`.

Teemade sobitamist pakutakse redaktoritele `VSCode`, `Cursor`, `VSCodium` ja `Helix`.

Süsteemiülese vaikimisi redaktori saad määrata jaotises `Setup > Defaults > Editor`.

## Keskkond

Omarchy toetab tervet hulka arenduskeskkondade seadistamist Omarchy Menu (`Super + Space`) jaotise _Install > Development_ kaudu. Sealt leiad muidugi _Ruby on Rails_, aga ka kõik kolm peamist JavaScripti käituskeskkonda (Node.js, Bun, Deno), samuti populaarsed PHP raamistikud nagu Laravel ja Symfony. Ah ja, seal on ka Go, Rust, Python, Java, Elixir (koos Phoenixiga), .NET, OCaml, Zig, Clojure ja Scala. See on väga lai valik!

Enamikku neist keskkondadest haldab [Mise](https://mise.jdx.dev/). See on tööriist, mis võimaldab sul samasse masinasse installida ja seal käitada programmeerimiskeele mitut versiooni. See on nagu rbenv või rvm Ruby jaoks või virtualenv Pythoni jaoks, aga see töötab paljude erinevate keskkondadega.

Näiteks Ruby installimiseks käivitaksid `mise use -g ruby`, mis nii installib Ruby kui ka määrab selle globaalseks vaikeseadeks. Või kui sinu projektil on .ruby-version fail, võid lihtsalt käivitada `mise i` selle projekti juurkaustas.

## Eelinstallitud CLI tööriistad

`uv`, Node.js ja `playwright-cli` (et agendid saaksid juhtida brauserit, kasutades installitud Chrome'i) on pakettidena installitud ning `omarchy update` hoiab neid koos ülejäänud süsteemiga ajakohasena. [Hunk](https://github.com/modem-dev/hunk) ning GitHubi, Basecampi, Cloudflare'i ja HEY CLI-d on ühe valiku kaugusel jaotises _Install > CLI_ ning [kodeerimisagendid](17-ai.md) jaotises _Install > AI > CLI_.

mise haldab ainult neid käituskeskkondi, mille seadistad jaotisest _Install > Development_; Omarchy ei installi selle kaudu omal käel midagi. Nende värskendamiseks koos ülejäänud Omarchyga käivita `omarchy update`; alias `mup` värskendab ainult mise hallatavaid tööriistu. Teise tööriista lisamiseks oma konfiguratsiooni kasuta käsku `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) ei vaja peaaegu mingit tutvustust. See võimaldab sul käitada isoleeritud konteinereid ja Omarchy installib kõik, mis on vajalik selle heaks käitamiseks, sealhulgas Dockeri enda ja [Docker Compose](https://docs.docker.com/compose/).

Vaikimisi *ei* ole sinu kasutaja `docker` grupis. See grupp on sisuliselt paroolita root — kõik selles grupis saavad käivitada `docker run -v /:/host` ja masina üle võtta — nii et üksainus sinu kasutaja all töötav petturlik skript või sõltuvus oleks muidu rootist ühe käsu kaugusel. Nii et käsureal käitad Dockerit `sudo` abil (`sudo docker ps`, `sudo docker compose up`) ja graafilised tööriistad, mis räägivad deemoniga — Windows VM —, küsivad vajadusel autoriseerimist. Kui tahad grupivaba seadistuse mugavuse tagasi ja mõistad kompromissi, luba see jaotisest **Setup > Security > Sudoless Docker** (või käivita `omarchy-setup-security-sudoless-docker`), mis lisab sind pärast hoiatust `docker` gruppi; seejärel töötavad tavaline `docker` ja alias `d` jälle ilma `sudo`ta.

Kohaliku arenduse levinud andmebaasid saad Dockeris seadistada Omarchy menüü jaotise _Install > Development > Docker DB_ kaudu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) on `gh` repositooriumide, issue'de ja pull requestidega töötamiseks terminalist. _Setup > Git_ installib selle, kui otsustad seal GitHubi sisse logida, või installi see eraldi jaotisest _Install > CLI > GitHub_. Seejärel kloonib `gh repo clone org/repo` repositooriumi; selle käskude uurimiseks käivita `gh --help`.

[Lazygit](https://github.com/jesseduffield/lazygit) on eelinstallitud Giti endaga töötamiseks.
