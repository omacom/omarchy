# Kehitystyökalut

## Vaihtoehtoiset editorit

Omarchyssa on oletuksena [Neovim](https://neovim.io/), mutta jos haluat jotain valtavirtaisempaa ja tutumpaa, voit ajaa Omarchy-valikon (`Super + Space`) ja katsoa vaihtoehdot kohdasta _Asenna > Editori_. Siellä on VSCode, Cursor, Zed, Sublime Text, Helix, Vim ja Emacs. Jos et löydä etsimääsi, katso _Asenna > Paketti_ ja tarkista, löytyisikö se Arch-paketista (ja jos ei, kokeile _Asenna > AUR_ ja tarkista AUR).

Alkuperäinen `vi`-editori on myös saatavilla heti käytössä. Aja `vi filename` muokataksesi tiedostoa päätteessä.

Teeman sovitus tarjotaan editoreille `VSCode`, `Cursor`, `VSCodium` ja `Helix`.

Voit asettaa järjestelmän laajuisen oletuseditorin kohdassa `Asetukset > Oletukset > Editori`.

## Ympäristö

Omarchy tukee kokonaisen joukon kehitysympäristöjen käyttöönottoa Omarchy-valikon (`Super + Space`) kohdan _Asenna > Kehitys_ kautta. Löydät sieltä tietenkin _Ruby on Railsin_, mutta myös kaikki kolme suurta JavaScript-ajoympäristöä (Node.js, Bun, Deno) sekä suosittuja PHP-kehyksiä, kuten Laravelin ja Symfonyn. Niin, ja mukana ovat myös Go, Rust, Python, Java, Elixir (Phoenixineen), .NET, OCaml, Zig, Clojure ja Scala. Valikoima on todella laaja!

Suurinta osaa näistä ympäristöistä hallinnoi [Mise](https://mise.jdx.dev/). Se on työkalu, jonka avulla voit asentaa ja ajaa ohjelmointikielen useita versioita samalla koneella. Se on kuin rbenv tai rvm Rubylle tai virtualenv Pythonille, mutta se toimii monissa eri ympäristöissä.

Asentaaksesi esimerkiksi Rubyn ajaisit `mise use -g ruby`, joka sekä asentaa Rubyn että asettaa sen globaaliksi oletukseksi. Tai jos projektissasi on tiedosto .ruby-version, voit vain ajaa `mise i` kyseisen projektin juuressa.

## Docker

[Docker](https://www.docker.com/) tuskin tarvitsee esittelyä. Sen avulla voit ajaa eristettyjä kontteja, ja Omarchy asentaa kaiken, mitä sen hyvään ajamiseen tarvitaan, mukaan lukien itse Dockerin ja [Docker Composen](https://docs.docker.com/compose/).

Oletuksena käyttäjäsi *ei* kuulu ryhmään `docker`. Tuo ryhmä on käytännössä salasanaton root — mikä tahansa siihen kuuluva voi ajaa `docker run -v /:/host` ja ottaa koneen haltuunsa — joten yksikin käyttäjänäsi ajettava kelvoton skripti tai riippuvuus olisi muuten yhden komennon päässä rootista. Komentorivillä ajat siis Dockeria `sudo`lla (`sudo docker ps`, `sudo docker compose up`), ja daemonin kanssa keskustelevat graafiset työkalut — Windows VM — pyytävät valtuutuksen sitä tarvitessaan. Jos haluat ryhmättömän asetuksen mukavuuden takaisin ja ymmärrät kompromissin, ota se käyttöön kohdassa **Asetukset > Turvallisuus > Docker ilman sudoa** (tai aja `omarchy-setup-security-sudoless-docker`), joka lisää sinut varoituksen jälkeen ryhmään `docker`; sen jälkeen pelkkä `docker` ja alias `d` toimivat jälleen ilman `sudo`a.

Voit ottaa yleisimmät tietokannat paikalliseen kehitykseen Dockerissa Omarchy-valikon kohdassa _Asenna > Kehitys > Docker DB_.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) antaa sinun todentautua GitHub-tililläsi ja kloonata yksityisiä repositorioita sen avulla. Se on kytketty yhdeksi laiskasti latautuvista mise-tyngistä, joten ensimmäisellä kerralla, kun ajat `gh`, se asentaa itsensä. Todentaudu ajamalla `gh auth login`. Sitten voit noutaa yksityisiä repositorioita komennolla `gh repo clone org/repo`.

Voit suorittaa tällä komennolla myös joukon muita GitHub-toimintoja. Aja vain `gh`, niin näet kaiken mahdollisen.

Mukana on myös laiskasti asentautuva tynkä komennolle `ghui` pull requestiesi hallintaan TUI:ssa. Ja [lazygit](https://github.com/jesseduffield/lazygit) on esiasennettuna, jos haluat ajaa itse gitiäkin TUI:sta.
