# Kehitystyökalut

## Vaihtoehtoiset editorit

Omarchy toimitetaan oletuksena [Neovim](https://neovim.io/) mukana, mutta jos haluat jotain hieman valtavirtaisempaa ja tutumpaa, voit avata Omarchy Menu (`Super + Space`) ja katsoa vaihtoehdot kohdasta _Install > Editor_. Siellä on lueteltu VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Jos et löydä etsimääsi, katso _Install > Package_ ja tarkista, eikö se löytyisi Arch-paketista (ja jos ei löydy, kokeile _Install > AUR_ ja tarkista AUR).

Alkuperäinen `vi`-editori on myös käytettävissä suoraan. Muokkaa tiedostoa päätteessä komennolla `vi filename`.

Teeman sovitus on tarjolla editoreille `VSCode`, `Cursor`, `VSCodium` ja `Helix`.

Voit asettaa koko järjestelmän oletuseditorin kohdassa `Setup > Defaults > Editor`.

## Ympäristö

Omarchy tukee kokonaisen joukon kehitysympäristöjen käyttöönottoa Omarchy Menun (`Super + Space`) osiossa _Install > Development_. Sieltä löydät tietenkin _Ruby on Rails_, mutta myös kaikki kolme tärkeintä JavaScript-ajoympäristöä (Node.js, Bun, Deno) sekä suositut PHP-kehykset, kuten Laravel ja Symfony. Ai niin, ja mukana ovat myös Go, Rust, Python, Java, Elixir (ja Phoenix), .NET, OCaml, Zig, Clojure ja Scala. Valikoima on todella laaja!

Suurinta osaa näistä ympäristöistä hallitaan [Mise](https://mise.jdx.dev/)-työkalulla. Sen avulla voit asentaa ja käyttää samalla koneella useita ohjelmointikielen versioita. Se on kuin rbenv tai rvm Rubylle tai virtualenv Pythonille, mutta se toimii monissa eri ympäristöissä.

Asentaaksesi esimerkiksi Rubyn ajaisit komennon `mise use -g ruby`, joka sekä asentaa Rubyn että asettaa sen yleiseksi oletukseksi. Tai jos projektissasi on .ruby-version-tiedosto, voit vain ajaa komennon `mise i` kyseisen projektin juuressa.

## Esiasennetut CLI-työkalut

Omarchy tarjoaa työkalut, kuten `gh`, `uv`, ja useimmat [koodausagentit](17-ai.md) käyttöön [misen laiskan asennuksen](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) kautta. Ensimmäisellä käyttökerralla mise asentaa sen. Myöhemmät ajot käyttävät asennettua versiota uudelleen; ne eivät tarkista päivitystä jokaisella käynnistyksellä.

Voit myös tarkastella oletuksia tai asentaa ne etukäteen:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Aja `omarchy update` päivittääksesi asennetut työkalut muun Omarchyn mukana. `mup`-alias päivittää vain mise-hallitut työkalut. Lisää toinen työkalu omaan määritykseesi komennolla `mise use -g <tool>`.

Pythonin käyttöönotto asentaa myös `uv`:n misen kautta. Python-kehitysympäristön poistaminen jättää `uv`:n käytettäväksi itsenäisenä työkaluna.

### Oman asennuksesi käyttäminen

misen komennot tulevat `PATH`:ssa ennen `~/.local/bin`, joten itse asentamasi työkalu, esimerkiksi Claude Coden tai Cursorin omalla asennusohjelmalla asennettu, ajaa silti misen kopiota. Työpöydältä käynnistetyt sovellukset löytävät myös misen komennot ennen järjestelmäpaketteja, joten sovellus, joka ajaa `gh`, saa misen kopion, vaikka olisit asentanut `github-cli` pacmanilla, ja mise asentaa kyseisen kopion ensimmäisellä kerralla. Jos haluat käyttää sen sijaan omaasi, poista misen kopio käytöstä tiedostossa `~/.config/mise/config.toml`. Esimerkiksi, jos asensit Cursor CLI:n itse:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Jos sinulla on jo `[settings]`-taulukko, lisää merkintä sinne; laajenna olemassa olevaa `disable_tools`-luetteloa sen korvaamisen sijaan. Varmista, että asennuksesi on `PATH`:ssa. Käytä mise-työkalun nimeä, joka voi poiketa sen komennosta: `oh-my-pi` tarjoaa esimerkiksi komennon `omp`. Oletusagentin käynnistin suosii myös käyttäjän asentamaa Cursor- tai Claude-asennusta hakemistossa `~/.local/bin`.

### Oletusten poistaminen ja palauttaminen

_Remove Preinstalls_ saa misen ohittamaan Omarchyn työkalumäärittelyt käyttäjältäsi lisäämällä ne `ignored_config_paths`-kohtaan tiedostossa `~/.config/mise/miserc.toml`. _Restore Preinstalls_ poistaa kyseisen rivin uudelleen. Itse määrittelemäsi työkalut, omassa määrityksessäsi tai projektin `mise.toml`-tiedostossa, toimivat edelleen kummassakin tapauksessa. Jos valitset oletusagentin tai otat Pythonin käyttöön esiasennusten poistamisen jälkeen, kyseinen työkalu lisätään omaan määritykseesi. Molemmat koskevat vain sinun käyttäjääsi; koneen muut käyttäjät säilyttävät oman valintansa.

## Docker

[Docker](https://www.docker.com/) tuskin tarvitsee esittelyä. Sen avulla voit ajaa eristettyjä kontteja, ja Omarchy asentaa kaiken tarvittavan sen hyvään käyttöön, mukaan lukien itse Dockerin ja [Docker Compose](https://docs.docker.com/compose/).

Oletuksena käyttäjäsi *ei* ole `docker`-ryhmässä. Ryhmä on käytännössä salasanaton root — mikä tahansa siinä oleva voi ajaa `docker run -v /:/host` ja ottaa koneen haltuun — joten yksi ainoana käyttäjänäsi ajettava roistoskripti tai riippuvuus olisi muuten yhden komennon päässä rootista. Joten komentorivillä ajat Dockeria `sudo`lla (`sudo docker ps`, `sudo docker compose up`), ja graafiset työkalut, jotka puhuvat daemonille — Windows VM — pyytävät valtuutusta tarvittaessa. Jos haluat takaisin ilman `sudo`a toimivan käyttöönoton mukavuuden ja ymmärrät kompromissin, ota se käyttöön kohdasta **Setup > Security > Sudoless Docker** (tai aja `omarchy-setup-security-sudoless-docker`), joka lisää sinut `docker`-ryhmään varoituksen jälkeen; sitten tavallinen `docker` ja `d`-alias toimivat taas ilman `sudo`a.

Voit ottaa yleiset tietokannat paikalliseen kehitykseen Dockerissa käyttöön Omarchy-valikon kohdasta _Install > Development > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) on käytettävissä komennolla `gh` repositorioiden, issueiden ja pull requestien kanssa työskentelyyn päätteestä. Aja `gh auth login` asentaaksesi sen ensimmäisellä käyttökerralla ja kirjautuaksesi, sitten `gh repo clone org/repo` kloonataksesi repositorion. Tutustu sen komentoihin komennolla `gh --help`.

Pull requestien päätekäyttöliittymää varten aja `ghui`; mise asentaa senkin ensimmäisellä käyttökerralla. [Lazygit](https://github.com/jesseduffield/lazygit) on esiasennettu itse Gitin kanssa työskentelyyn.
