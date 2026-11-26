# Kehitystyökalut

## Vaihtoehtoiset editorit

Omarchyssa on uusissa asennuksissa oletuseditorina Plain ja [Neovim](https://neovim.io/) esiasennettuna, mutta jos haluaisit jotain hieman valtavirtavampaa ja tutumpaa, voit avata Omarchy Menun (`Super + Space`) ja katsoa vaihtoehdot kohdasta _Install > Editor_. Siellä on listattuna VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Jos et löydä etsimääsi, vilkaise kohtaa _Install > Package_ ja katso, onko se Arch-paketissa (ja jos ei ole, kokeile kohtaa _Install > AUR_ ja tarkista AUR).

Alkuperäinen `vi`-editori on myös heti käytettävissä. Aja `vi filename` muokataksesi tiedostoa terminaalissa.

Teeman sovitus tarjotaan ohjelmille `VSCode`, `Cursor`, `VSCodium` ja `Helix`.

Voit asettaa järjestelmän laajuisen oletuseditorin kohdassa `Setup > Defaults > Editor`.

## Ympäristö

Omarchy tukee kokonaisen liudan kehitysympäristöjen käyttöönottoa Omarchy Menun (`Super + Space`) kohdassa _Install > Development_. Löydät sieltä tietenkin _Ruby on Rails_:in, mutta myös kaikki kolme merkittävää JavaScript-ajoympäristöä (Node.js, Bun, Deno) sekä suositut PHP-kehykset, kuten Laravel ja Symfony. Ai niin, ja siellä on myös Go, Rust, Python, Java, Elixir (Phoenixin kanssa), .NET, OCaml, Zig, Clojure ja Scala. Valikoima on todella laaja!

Useimpia näistä ympäristöistä hallinnoi [Mise](https://mise.jdx.dev/). Se on työkalu, jolla voit asentaa ja ajaa ohjelmointikielen useita versiota samalla koneella. Se on kuin rbenv tai rvm Rubylle tai virtualenv Pythonille, mutta se toimii koko joukolle eri ympäristöjä.

Jos haluaisit asentaa esimerkiksi Rubyn, ajaisit `mise use -g ruby`, joka sekä asentaa Rubyn että asettaa sen globaaliksi oletukseksi. Tai jos projektillasi on .ruby-version-tiedosto, voit vain ajaa `mise i` kyseisen projektin juuressa.

## Esiasennetut CLI-työkalut

`uv`, Node.js ja `playwright-cli` (agenteille selaimen ajamiseen, käyttäen asennettua Chromea) tulevat asennettuina paketteina, ja `omarchy update` pitää ne ajan tasalla muun järjestelmän kanssa. [Hunk](https://github.com/modem-dev/hunk) ja GitHubin, Basecampin, Cloudflaren ja HEYn CLI:t ovat yhden valinnan päässä kohdassa _Install > CLI_ ja [kodausagentit](17-ai.md) kohdassa _Install > AI > CLI_.

mise hallinnoi vain ajoympäristöjä, jotka otat käyttöön kohdassa _Install > Development_; Omarchy ei asenna sen kautta omin päin mitään. Aja `omarchy update` päivittääksesi ne muun Omarchyn kanssa; `mup`-alias päivittää vain misellä hallitut työkalut. Jos haluat lisätä toisen työkalun omaan konfiguraatioosi, käytä komentoa `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) ei juuri esittelyjä kaipaa. Se mahdollistaa eristettyjen konttien ajamisen, ja Omarchy asentaa kaiken sen hyvään ajamiseen tarvittavan, mukaan lukien itse Dockerin ja [Docker Composen](https://docs.docker.com/compose/).

Oletuksena käyttäjäsi *ei* ole `docker`-ryhmässä. Tuo ryhmä on käytännössä salasanaton root — kaikki siihen kuuluvat voivat ajaa `docker run -v /:/host` ja ottaa koneen haltuunsa — joten yksi rogue-skripti tai käyttäjänäsi ajettava riippuvuus olisi muuten yhden komennon päässä rootista. Siksi komentorivillä ajat Dockeria `sudo`:lla (`sudo docker ps`, `sudo docker compose up`), ja daemonin kanssa juttelevat graafiset työkalut — Windows VM — pyytävät valtuutuksen sitä tarvittaessa. Jos haluat takaisin ryhmättömän käyttöönoton mukavuuden ja ymmärrät kompromissin, ota se käyttöön kohdasta **Setup > Security > Sudoless Docker** (tai aja `omarchy-setup-security-sudoless-docker`), joka lisää sinut varoituksen jälkeen `docker`-ryhmään; sitten tavallinen `docker` ja `d`-alias toimivat taas ilman `sudo`:a.

Voit ottaa paikalliseen kehitykseen yleiset tietokannat käyttöön Dockerissa Omarchy-menun kohdasta _Install > Development > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) on `gh`, jolla työskennellään repositorioiden, issueiden ja pull requestien kanssa terminaalista. _Setup > Git_ asentaa sen, kun valitset kirjautumisesi GitHubiin siellä, tai voit asentaa sen erikseen kohdasta _Install > CLI > GitHub_. Sitten `gh repo clone org/repo` kloonaa repositorion; aja `gh --help` tutkiaksesi sen komentoja.

[Lazygit](https://github.com/jesseduffield/lazygit) on esiasennettu itse Gitin kanssa työskentelyä varten.
