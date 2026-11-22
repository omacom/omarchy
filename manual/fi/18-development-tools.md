# Kehitystyökalut

## Vaihtoehtoiset editorit

Omarchy toimitetaan niin, että Plain on uusissa asennuksissa oletuseditori ja [Neovim](https://neovim.io/) on esiasennettuna, mutta jos haluat jotain hieman valtavirtaisempaa ja tutumpaa, voit avata Omarchy Menun (`Super + Space`) ja katsoa vaihtoehdot kohdasta _Install > Editor_. Siellä on lueteltuna VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Jos et löydä etsimääsi, käy kohdassa _Install > Package_ ja katso, eikö se löydy Arch-paketista (ja jos ei, kokeile kohtaa _Install > AUR_ tarkistaaksesi AUR:n).

Alkuperäinen `vi`-editori on myös saatavilla suoraan. Muokkaa tiedostoa päätteessä ajamalla `vi filename`.

Teeman sovitus on tarjolla editoreille `VSCode`, `Cursor`, `VSCodium` ja `Helix`.

Järjestelmänlaajuisen oletuseditorin voit asettaa kohdassa `Setup > Defaults > Editor`.

## Ympäristö

Omarchy tukee kokonaisen joukon kehitysympäristöjen käyttöönottoa Omarchy Menun (`Super + Space`) osion _Install > Development_ kautta. Sieltä löydät tietenkin _Ruby on Rails_ -kehyksen, mutta myös kaikki kolme merkittävää JavaScript-ajonaikaista ympäristöä (Node.js, Bun, Deno) sekä suosittuja PHP-kehyksiä, kuten Laravel ja Symfony. Ai niin, ja tarjolla ovat myös Go, Rust, Python, Java, Elixir (Phoenixin kanssa), .NET, OCaml, Zig, Clojure ja Scala. Valikoima on todella laaja!

Suurinta osaa näistä ympäristöistä hallinnoi [Mise](https://mise.jdx.dev/). Se on työkalu, jonka avulla voit asentaa ja ajaa saman ohjelmointikielen useita versioita samalla koneella. Se on kuin rbenv tai rvm Rubylle tai virtualenv Pythonille, mutta se toimii monissa eri ympäristöissä.

Asentaaksesi esimerkiksi Rubyn ajaisit komennon `mise use -g ruby`, joka sekä asentaa Rubyn että asettaa sen yleiseksi oletukseksi. Tai jos projektissasi on .ruby-version-tiedosto, voit vain ajaa komennon `mise i` kyseisen projektin juuressa.

## Esiasennetut CLI-työkalut

Omarchy tuo työkalut, kuten `gh` ja `uv`, sekä useimmat [koodausagentit](17-ai.md) saataville [misen laiskan asennuksen](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) kautta. Kun ajat jonkin niistä ensimmäisen kerran, mise asentaa sen. Koodausagentit tarkistavat sitten päivityksen ennen ajoaan, enintään kerran neljässä tunnissa; muut työkalut, kuten `gh` ja `uv`, käyttävät asennettua versiota uudelleen, kunnes päivität.

Voit myös tarkastella oletuksia tai asentaa ne etukäteen:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Päivitä asennetut työkalut muun Omarchyn mukana ajamalla `omarchy update`. `mup`-alias päivittää vain misen hallinnoimat työkalut. Lisää toinen työkalu omaan määritykseesi komennolla `mise use -g <tool>`.

Pythonin käyttöönotto asentaa myös työkalun `uv` misen kautta. Python-kehitysympäristön poistaminen jättää työkalun `uv` saataville itsenäisenä työkaluna.

### Oman asennuksen käyttäminen

misen komennot tulevat `PATH`:ssa ennen hakemistoa `~/.local/bin`, joten itse asentamasi työkalu, esimerkiksi Claude Coden tai Cursorin omalla asennusohjelmalla asennettu, ajaa silti misen kopion. Myös työpöydältä käynnistetyt sovellukset löytävät misen komennot ennen järjestelmäpaketteja, joten sovellus, joka ajaa komennon `gh`, saa misen kopion, vaikka olisit asentanut paketin `github-cli` pacmanilla, ja mise asentaa kyseisen kopion ensimmäisellä kerralla. Jos haluat käyttää sen sijaan omaasi, poista misen kopio käytöstä tiedostossa `~/.config/mise/config.toml`. Jos esimerkiksi asensit Cursor CLI:n itse:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Jos sinulla on jo `[settings]`-taulukko, lisää merkintä sinne; laajenna olemassa olevaa `disable_tools`-luetteloa sen korvaamisen sijaan. Varmista, että asennuksesi on `PATH`:ssa. Käytä misen työkalun nimeä, joka voi poiketa sen komennosta: esimerkiksi `oh-my-pi` tarjoaa komennon `omp`. Oletusagentin käynnistin suosii myös käyttäjän asentamaa Cursor- tai Claude Code -asennusta hakemistossa `~/.local/bin`.

### Oletusten poistaminen ja palauttaminen

_Remove > Preinstalls_ poistaa Omarchyn esiasennetut verkkosovellukset, TUI:t ja sovellukset ja saa misen ohittamaan Omarchyn työkalumääritykset käyttäjäsi osalta lisäämällä ne kohtaan `ignored_config_paths` tiedostossa `~/.config/mise/miserc.toml`. _Install > Preinstalls_ tuo ne takaisin ja poistaa kyseisen rivin uudelleen. Itse määrittämäsi työkalut, omassa määrityksessäsi tai projektin `mise.toml`-tiedostossa, toimivat edelleen kummassakin tapauksessa. Jos valitset oletusagentin tai otat Pythonin käyttöön esiasennusten poistamisen jälkeen, kyseinen työkalu lisätään omaan määritykseesi. mise-asetus koskee vain käyttäjääsi, ja muut käyttäjät säilyttävät oman valintansa; sovellukset ovat kuitenkin paketteja, joten niiden poistaminen tai palauttaminen muuttaa niitä kaikille koneen käyttäjille.

## Docker

[Docker](https://www.docker.com/) tuskin kaipaa esittelyä. Sen avulla voit ajaa eristettyjä kontteja, ja Omarchy asentaa kaiken sen hyvään ajamiseen tarvittavan, mukaan lukien itse Dockerin ja [Docker Composen](https://docs.docker.com/compose/).

Oletuksena käyttäjäsi *ei* kuulu `docker`-ryhmään. Kyseinen ryhmä on käytännössä salasanaa vaatimaton root — mikä tahansa siihen kuuluva voi ajaa komennon `docker run -v /:/host` ja ottaa koneen haltuunsa — joten yksi sinun käyttäjänäsi ajettava kelvoton skripti tai riippuvuus olisi muuten yhden komennon päässä root-oikeuksista. Niinpä ajat Dockeria komentorivillä komennolla `sudo` (`sudo docker ps`, `sudo docker compose up`), ja daemonin kanssa keskustelevat graafiset työkalut — Windows VM — pyytävät valtuutusta tarvittaessa. Jos haluat takaisin `sudo`a vaatimattoman käytön mukavuuden ja ymmärrät kompromissin, ota se käyttöön kohdasta **Setup > Security > Sudoless Docker** (tai aja `omarchy-setup-security-sudoless-docker`), joka lisää sinut `docker`-ryhmään varoituksen jälkeen; sen jälkeen tavallinen `docker` ja `d`-alias toimivat taas ilman `sudo`-komentoa.

Voit ottaa Dockerissa käyttöön yleiset tietokannat paikallista kehitystä varten Omarchy-valikon kohdasta _Install > Development > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) on saatavilla komennolla `gh`, jolla voit työskennellä repositorioiden, issueiden ja pull requestien parissa päätteestä. Aja `gh auth login` asentaaksesi sen ensimmäisellä käyttökerralla ja tunnistaaksesi itsesi, ja kloonaa sitten repositorio komennolla `gh repo clone org/repo`. Tutustu sen komentoihin ajamalla `gh --help`.

Pull requestien päätekäyttöliittymää varten aja `ghui`; myös mise asentaa sen ensimmäisellä käyttökerralla. [Lazygit](https://github.com/jesseduffield/lazygit) on esiasennettu itse Gitin kanssa työskentelyyn.
