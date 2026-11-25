# Kehitystyökalut

## Vaihtoehtoiset editorit

Omarchy toimitetaan Plain oletuseditorina uusissa asennuksissa ja [Neovim](https://neovim.io/) esiasennettuna, mutta jos haluat jotain hieman valtavirtaisempaa ja tutumpaa, voit avata Omarchy Menun (`Super + Space`) ja katsoa vaihtoehdot kohdasta _Install > Editor_. Siellä on listattuna VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Jos et löydä etsimääsi, vilkaise kohtaa _Install > Package_ ja katso, eikö se löydy Arch-paketista (ja jos ei löydy, kokeile kohtaa _Install > AUR_ tarkistaaksesi AUR:n).

Alkuperäinen `vi`-editori on myös saatavilla suoraan pakasta vedettynä. Muokkaa tiedostoa terminaalissa suorittamalla `vi filename`.

Teeman täsmäytystä tarjotaan editoreille `VSCode`, `Cursor`, `VSCodium` ja `Helix`.

Voit asettaa järjestelmänlaajuisen oletuseditorin kohdassa `Setup > Defaults > Editor`.

## Ympäristö

Omarchy tukee kokonaisen liudan kehitysympäristöjen käyttöönottoa Omarchy Menun (`Super + Space`) osion _Install > Development_ kautta. Löydät sieltä tietenkin _Ruby on Railsin_, mutta myös kaikki kolme suurta JavaScript-ajoympäristöä (Node.js, Bun, Deno) sekä suositut PHP-kehykset, kuten Laravelin ja Symfonyn. Ai niin, ja tarjolla on myös Go, Rust, Python, Java, Elixir (sekä Phoenix), .NET, OCaml, Zig, Clojure ja Scala. Valikoima on todella laaja!

Suurinta osaa näistä ympäristöistä hallinnoi [Mise](https://mise.jdx.dev/). Se on työkalu, jolla voit asentaa ja ajaa samalla koneella useita versioita ohjelmointikielestä. Se on kuin Rubyn rbenv tai rvm tai Pythonin virtualenv, mutta se toimii monille eri ympäristöille.

Asentaaksesi esimerkiksi Rubyn suoritat komennon `mise use -g ruby`, joka sekä asentaa Rubyn että asettaa sen globaaliksi oletukseksi. Tai jos projektissasi on .ruby-version-tiedosto, voit vain suorittaa komennon `mise i` kyseisen projektin juuressa.

## Esiasennetut CLI-työkalut

`uv`, Node.js ja `playwright-cli` (jotta agentit voivat ohjata selainta asennettua Chromea käyttäen) tulevat asennettuina paketteina, ja `omarchy update` pitää ne ajan tasalla muun järjestelmän kanssa. `ghui`, [Hunk](https://github.com/modem-dev/hunk) sekä Basecamp-, Cloudflare- ja HEY-CLI:t ovat yhden valinnan päässä kohdassa _Install > CLI_, ja [koodausagentit](17-ai.md) kohdassa _Install > AI > CLI_.

mise hallinnoi vain niitä ajoympäristöjä, jotka otat käyttöön kohdasta _Install > Development_; Omarchy ei asenna sen kautta mitään oma-aloitteisesti. Päivitä ne muun Omarchyn mukana suorittamalla `omarchy update`; `mup`-alias päivittää vain misen hallinnoimat työkalut. Lisää toinen työkalu omaan määritykseesi komennolla `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) tuskin kaipaa esittelyä. Sen avulla voit ajaa eristettyjä kontteja, ja Omarchy asentaa kaiken sen hyvään ajamiseen tarvittavan, mukaan lukien itse Dockerin ja [Docker Composen](https://docs.docker.com/compose/).

Oletuksena käyttäjäsi *ei* kuulu `docker`-ryhmään. Ryhmä on käytännössä salasanaton root — mikä tahansa siihen kuuluva voi suorittaa komennon `docker run -v /:/host` ja ottaa koneen haltuunsa — joten yksi ainoa tunnuksellasi ajettava roistoskripti tai riippuvuus olisi muuten yhden komennon päässä rootista. Niinpä ajat Dockeria komentorivillä `sudo`n kanssa (`sudo docker ps`, `sudo docker compose up`), ja daemonin kanssa keskustelevat graafiset työkalut — Windows VM — pyytävät valtuutusta tarvittaessa. Jos haluat ryhmättömän käyttöönoton mukavuuden takaisin ja ymmärrät kompromissin, ota se käyttöön kohdasta **Setup > Security > Sudoless Docker** (tai suorita `omarchy-setup-security-sudoless-docker`), mikä lisää sinut `docker`-ryhmään varoituksen jälkeen; silloin pelkkä `docker` ja `d`-alias toimivat taas ilman `sudo`a.

Voit ottaa yleiset tietokannat paikallista kehitystä varten käyttöön Dockerissa Omarchy-valikon kohdasta _Install > Development > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) on `gh`, jolla työskentelet repojen, issueiden ja pull requestien kanssa terminaalista. _Setup > Git_ asentaa sen, kun valitset siellä kirjautumisen GitHubiin, ja sen jälkeen `gh repo clone org/repo` kloonaa repon. Tutustu sen komentoihin suorittamalla `gh --help`.

_Install > CLI > GitHub_ asentaa GitHub CLI:n, `gh`:n, sekä `ghui`n, terminaalikäyttöliittymän pull requesteihin. [Lazygit](https://github.com/jesseduffield/lazygit) on esiasennettu itse Gitin kanssa työskentelyyn.
