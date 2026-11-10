# Arendustööriistad

## Alternatiivsed redaktorid

Omarchy tuleb vaikimisi koos [Neovimiga](https://neovim.io/), aga kui soovid midagi tavapärasemat ja tuttavamat, saad käivitada Omarchy menüü (`Super + Space`) ja vaadata valikuid jaotises _Install > Editor_. Seal on loetletud VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Kui sa ei leia seda, mida otsid, vaata jaotist _Install > Package_ ja kontrolli, kas seda pole Arch paketina (ja kui ei ole, proovi jaotist _Install > AUR_, et kontrollida AURi).

Algne `vi` redaktor on samuti kohe karbist võttes saadaval. Faili terminalis muutmiseks käivita `vi filename`.

Teemade sobitamist pakutakse `VSCode`, `Cursor`, `VSCodium` ja `Helix` jaoks.

Süsteemiülese vaikimisi redaktori saad määrata jaotises `Setup > Defaults > Editor`.

## Keskkond

Omarchy toetab tervet hulka arenduskeskkondi Omarchy menüü (`Super + Space`) jaotise _Install > Development_ kaudu. Sealt leiad muidugi _Ruby on Railsi_, aga ka kõik kolm peamist JavaScripti käituskeskkonda (Node.js, Bun, Deno) ning populaarsed PHP raamistikud nagu Laravel ja Symfony. Ah jaa, seal on ka Go, Rust, Python, Java, Elixir (koos Phoenixiga), .NET, OCaml, Zig, Clojure ja Scala. See on väga lai valik!

Enamikku neist keskkondadest haldab [Mise](https://mise.jdx.dev/). See on tööriist, mis võimaldab sul samasse masinasse installida ja seal käitada programmeerimiskeele mitut versiooni. See on nagu rbenv või rvm Ruby jaoks või virtualenv Pythoni jaoks, aga see töötab paljude erinevate keskkondadega.

Näiteks Ruby installimiseks käivitaksid käsu `mise use -g ruby`, mis nii installib Ruby kui ka määrab selle globaalseks vaikeseadeks. Või kui sinu projektil on .ruby-version fail, saad selle projekti juurkaustas lihtsalt käivitada käsu `mise i`.

## Eelinstallitud CLI tööriistad

Omarchy teeb tööriistad nagu `gh`, `uv` ja enamiku [kodeerimisagentidest](17-ai.md) kättesaadavaks [mise laiska installimise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) kaudu. Esimesel korral, kui mõne neist käivitad, installib mise selle. Hilisemad käivitused kasutavad installitud versiooni uuesti; need ei kontrolli iga käivituse korral värskendust.

Saad vaikeväärtusi ka kontrollida või need ette ära installida:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Installitud tööriistade värskendamiseks koos ülejäänud Omarchyga käivita `omarchy update`. Alias `mup` värskendab ainult mise hallatavaid tööriistu. Teise tööriista lisamiseks oma konfiguratsiooni kasuta käsku `mise use -g <tool>`.

Pythoni seadistus installib mise kaudu ka tööriista `uv`. Pythoni arenduskeskkonna eemaldamine jätab tööriista `uv` sõltumatu tööriistana alles.

### Oma installatsiooni kasutamine

Mise käsud asuvad `PATH`is enne kausta `~/.local/bin`, nii et tööriist, mille oled ise installinud, näiteks Claude Code'i või Cursori enda installeriga, käivitab ikkagi mise koopia. Töölaualt käivitatud rakendused leiavad mise käsud samuti enne süsteemipakette, nii et rakendus, mis käivitab käsu `gh`, saab mise koopia isegi siis, kui installisid paketi `github-cli` pacmaniga, ja mise installib selle koopia esimesel korral. Oma koopia kasutamiseks keela selle asemel mise koopia failis `~/.config/mise/config.toml`. Näiteks kui installisid Cursor CLI ise:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Kui sul on juba tabel `[settings]`, lisa kirje sinna; laienda olemasolevat loendit `disable_tools`, selle asendamise asemel. Veendu, et sinu installatsioon on `PATH`is. Kasuta mise tööriista nime, mis võib selle käsust erineda: näiteks `oh-my-pi` pakub käsku `omp`. Vaikeagendi käivitaja eelistab samuti kasutaja installitud Cursori või Claude Code'i kaustas `~/.local/bin`.

### Vaikeväärtuste eemaldamine ja taastamine

_Remove Preinstalls_ paneb mise sinu kasutaja puhul Omarchy tööriistadeklaratsioonid vahele jätma, lisades need failis `~/.config/mise/miserc.toml` kirjele `ignored_config_paths`. _Restore Preinstalls_ eemaldab selle rea uuesti. Tööriistad, mille oled ise deklareerinud, oma konfiguratsioonis või projekti failis `mise.toml`, töötavad edasi mõlemal juhul. Kui valid pärast eelinstallide eemaldamist vaikeagendi või seadistad Pythoni, lisatakse see tööriist sinu enda konfiguratsiooni. Mõlemad kehtivad ainult sinu kasutajale; teised masina kasutajad säilitavad oma valiku.

## Docker

[Docker](https://www.docker.com/) ei vaja peaaegu mingit tutvustust. See võimaldab sul käitada isoleeritud konteinereid ja Omarchy installib kõik, mis on selle heaks toimimiseks vajalik, sealhulgas Dockeri enda ja [Docker Compose'i](https://docs.docker.com/compose/).

Vaikimisi sinu kasutaja *ei* kuulu gruppi `docker`. See grupp on sisuliselt paroolita root — igaüks selles saab käivitada käsu `docker run -v /:/host` ja masina üle võtta —, nii et üksainus sinu nimel töötav pahatahtlik skript või sõltuvus oleks muidu rootist vaid ühe käsu kaugusel. Nii et käsureal käitad Dockerit käsuga `sudo` (`sudo docker ps`, `sudo docker compose up`) ja graafilised tööriistad, mis deemoniga suhtlevad — Windows VM —, küsivad vajadusel autoriseerimist. Kui soovid grupita seadistuse mugavust tagasi ja mõistad kompromissi, luba see jaotisest **Setup > Security > Sudoless Docker** (või käivita `omarchy-setup-security-sudoless-docker`), mis lisab sind pärast hoiatust gruppi `docker`; siis töötavad tavaline `docker` ja alias `d` jälle ilma käsuta `sudo`.

Levinud andmebaasid kohalikuks arenduseks saad Dockeris seadistada Omarchy menüü jaotise _Install > Development > Docker DB_ kaudu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) on saadaval käsuna `gh` hoidlate, issue'de ja pull requestidega terminalist töötamiseks. Käivita `gh auth login`, et see esimesel kasutuskorral installida ja autentida, seejärel käivita hoidla kloonimiseks `gh repo clone org/repo`. Selle käskude uurimiseks käivita `gh --help`.

Pull requestide terminaliliidese jaoks käivita `ghui`; mise installib ka selle esimesel kasutuskorral. [Lazygit](https://github.com/jesseduffield/lazygit) on Giti endaga töötamiseks eelinstallitud.
