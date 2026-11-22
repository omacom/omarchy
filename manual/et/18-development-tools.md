# Arendustööriistad

## Alternatiivsed redaktorid

Omarchy tuleb uutel installidel vaikiredaktorina Plainiga ning [Neovim](https://neovim.io/) on eelinstallitud, aga kui tahaksid midagi veidi tavapärasemat ja tuttavamat, saad käivitada Omarchy Menu (`Super + Space`) ja vaadata valikuid jaotise _Install > Editor_ alt. Meil on seal loetletud VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Kui sa ei leia seda, mida otsid, vaata jaotist _Install > Package_ ja kontrolli, kas see ei ole mõnes Arch paketis (ja kui ei ole, proovi AUR-i kontrollimiseks jaotist _Install > AUR_).

Algne `vi` redaktor on samuti kohe karbist võttes saadaval. Käivita faili terminalis redigeerimiseks `vi filename`.

Teema sobitamist pakutakse `VSCode`, `Cursor`, `VSCodium` ja `Helix` puhul.

Süsteemiülese vaikiredaktori saad määrata jaotises `Setup > Defaults > Editor`.

## Keskkond

Omarchy toetab terve hulga arenduskeskkondade seadistamist Omarchy Menu (`Super + Space`) jaotise _Install > Development_ kaudu. Loomulikult leiad sealt _Ruby on Rails_, aga ka kõik kolm peamist JavaScripti käituskeskkonda (Node.js, Bun, Deno) ning populaarsed PHP raamistikud nagu Laravel ja Symfony. Oh, ja seal on ka Go, Rust, Python, Java, Elixir (koos Phoenixiga), .NET, OCaml, Zig, Clojure ja Scala. See on väga lai valik!

Suurt osa neist keskkondadest haldab [Mise](https://mise.jdx.dev/). See on tööriist, mis laseb sul samasse masinasse installida ja seal käitada programmeerimiskeele mitut versiooni. See on nagu rbenv või rvm Ruby jaoks või virtualenv Pythoni jaoks, aga see töötab paljude erinevate keskkondadega.

Näiteks Ruby installimiseks käivitaksid `mise use -g ruby`, mis nii installib Ruby kui ka määrab selle globaalseks vaikeseadeks. Või kui sinu projektil on .ruby-version fail, saad selle projekti juurkaustas lihtsalt käivitada `mise i`.

## Eelinstallitud CLI tööriistad

Omarchy teeb tööriistad nagu `gh`, `uv` ja enamiku [kodeerimisagentidest](17-ai.md) kättesaadavaks [mise laiska installimise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) kaudu. Esimesel korral, kui mõne neist käivitad, installib mise selle. Kodeerimisagendid kontrollivad seejärel enne käivitamist värskenduse olemasolu, kuid mitte sagedamini kui kord nelja tunni jooksul; teised tööriistad, nagu `gh` ja `uv`, kasutavad installitud versiooni uuesti, kuni sa seda värskendad.

Samuti saad vaikeseadeid vaadata või need ette ära installida:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Omarchy ülejäänud osaga koos installitud tööriistade värskendamiseks käivita `omarchy update`. Alias `mup` värskendab ainult mise hallatavaid tööriistu. Teise tööriista lisamiseks oma konfiguratsiooni kasuta käsku `mise use -g <tool>`.

Pythoni seadistus installib mise kaudu ka `uv`. Pythoni arenduskeskkonna eemaldamine jätab `uv` sõltumatu tööriistana alles.

### Oma installi kasutamine

mise käsud on `PATH`-is enne kausta `~/.local/bin`, nii et sinu enda installitud tööriist, näiteks Claude Code'i või Cursori oma installeriga, käivitab ikkagi mise koopia. Töölaualt käivitatud rakendused leiavad samuti mise käsud enne süsteemipakette, nii et rakendus, mis käivitab käsu `gh`, saab mise koopia isegi siis, kui installisid `github-cli` pacmaniga, ja mise installib selle koopia esimesel korral. Oma koopia kasutamiseks keela selle asemel mise koopia failis `~/.config/mise/config.toml`. Näiteks kui installisid Cursor CLI ise:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Kui sul on `[settings]` tabel juba olemas, lisa kirje sinna; laienda olemasolevat `disable_tools` loendit selle asendamise asemel. Veendu, et sinu install oleks `PATH`-is. Kasuta mise tööriista nime, mis võib selle käsust erineda: näiteks `oh-my-pi` pakub käsku `omp`. Vaikeagendi käivitaja eelistab samuti kasutaja installitud Cursorit või Muse'i kaustas `~/.local/bin`.

### Vaikeseadete eemaldamine ja taastamine

_Remove > Preinstalls_ eemaldab Omarchy eelinstallitud veebirakendused, TUIs ja rakendused ning paneb mise sinu kasutaja puhul Omarchy tööriistadeklaratsioone vahele jätma, lisades need failis `~/.config/mise/miserc.toml` sätte `ignored_config_paths` alla. _Install > Preinstalls_ toob need tagasi ja eemaldab selle rea uuesti. Tööriistad, mille deklareerid ise oma konfiguratsioonis või projekti failis `mise.toml`, töötavad edasi mõlemal juhul. Kui valid pärast eelinstallide eemaldamist vaikeagendi või seadistad Pythoni, lisatakse see tööriist sinu oma konfiguratsiooni. mise säte kehtib ainult sinu kasutajale ja teised kasutajad saavad oma valiku alles hoida; rakendused on aga paketid, nii et nende eemaldamine või taastamine muudab neid kõigi masina kasutajate jaoks.

## Docker

[Docker](https://www.docker.com/) ei vaja peaaegu mingit tutvustust. See laseb sul käitada isoleeritud konteinereid ja Omarchy installib kõik selle heaks käitamiseks vajaliku, sealhulgas Dockeri enda ja [Docker Compose](https://docs.docker.com/compose/).

Vaikimisi *ei* kuulu sinu kasutaja `docker` rühma. See rühm on sisuliselt paroolita root — igaüks selles saab käivitada `docker run -v /:/host` ja masina üle võtta — nii et üksainus sinu kasutajana töötav pahatahtlik skript või sõltuvus oleks muidu rootist vaid ühe käsu kaugusel. Nii et käsureal käivitad Dockerit `sudo`-ga (`sudo docker ps`, `sudo docker compose up`) ja graafilised tööriistad, mis deemoniga suhtlevad — Windows VM —, küsivad vajadusel autoriseerimist. Kui tahad rühmadeta seadistuse mugavuse tagasi ja mõistad kompromissi, luba see jaotisest **Setup > Security > Sudoless Docker** (või käivita `omarchy-setup-security-sudoless-docker`), mis lisab sind pärast hoiatust `docker` rühma; seejärel töötavad tavaline `docker` ja alias `d` uuesti ilma `sudo`-ta.

Omarchy menüü jaotise _Install > Development > Docker DB_ abil saad Dockeris seadistada kohalikuks arenduseks tavalised andmebaasid.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) on saadaval käsuna `gh` hoidlate, issue'de ja pull requestidega terminalist töötamiseks. Esmakordsel kasutamisel selle installimiseks ja autentimiseks käivita `gh auth login`, seejärel hoidla kloonimiseks `gh repo clone org/repo`. Selle käskude uurimiseks käivita `gh --help`.

Pull requestide terminaliliidese jaoks käivita `ghui`; ka mise installib selle esmakordsel kasutamisel. [Lazygit](https://github.com/jesseduffield/lazygit) on Giti endaga töötamiseks eelinstallitud.
