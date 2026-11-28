# Järjestelmän lepotila

Omarchy ottaa valmiustilan käyttöön oletuksena ja horrostilan, kun se on määritetty, mutta jos sinulla on ongelmia kumman tahansa kanssa koneellasi, voit kytkeä ne pois päältä.

NVIDIA GB10 -koneilla, kuten DGX Spark ja ASUS Ascent GX10, valmiustila ja horrostila on kytketty pois päältä, kuten ne ovat myös NVIDIA:n DGX OS:ssä, koska lepotilan ei ole vielä osoitettu toimivan kyseisellä laitteistolla. Valmiustilan kytkin ja horrostilan määritys eivät koske niitä. Kytke lepotila takaisin päälle poistamalla `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` komennolla `sudo rm`; Suspend palaa sitten valikkoon, ja horrostila voidaan määrittää kuten muillakin koneilla. Komennon `sudo omarchy apply hardware --install-user "$USER"` suorittaminen palauttaa tiedoston.

### Virtaprofiiilit

Kannettavalla tietokoneella Omarchy muistaa virtaprofiilisi erikseen verkkovirtaan kytkettynä ja akulla käytettäessä ja vaihtaa näiden kahden välillä, kun kytket virran tai irrotat sen. Oletuksena se tarkoittaa suorituskykyä verkkovirralla ja tasapainotettua profiilia akulla.

Näet, mitä koneesi tarjoaa, komennolla `omarchy powerprofiles list`, ja voit asettaa haluamasi profiilin nykyiselle tilallesi komennolla `omarchy powerprofiles set autodetect power-saver`. Jos haluat asettaa toisen tilan irrottamatta mitään, nimeä se suoraan: `omarchy powerprofiles set battery power-saver`. Valitsemasi profiili on se, jonka saat takaisin seuraavan kerran, kun olet kyseisessä tilassa.

### Valmiustilan kytkeminen

Kytket valmiustilan päälle ja pois suorittamalla terminaalissa komennon `omarchy toggle suspend`. Se vain näyttää/piilottaa vaihtoehdon kohdassa _System_ (tai `Super + Esc`), ja sen jälkeen näet, toimiiko se järjestelmässäsi johdonmukaisesti. Jos ei toimi, voit piilottaa sen uudelleen samalla komennolla.

### Horrostilan kytkeminen

Määrität horrostilan suorittamalla terminaalissa komennon `omarchy hibernation setup` (se ei ole käytettävissä Apple Silicon -Maceilla). Horrostila luo käynnistysasemallesi /swap-alivolyymin, jonka koko vastaa fyysisen RAM-muistisi määrää, joten varmista, että sinulla on runsaasti tilaa vapaana. 32GB:n koneella tarvitset tälle volyymille aina 32GB+ vapaata tilaa. Horrostila vaatii myös oletusarvoisen Limine-käynnistyslataimen.

Kun se on määritetty, näet horrostilavaihtoehdon kohdassa _System_ (tai `Super + Esc`), ja sen jälkeen näet, toimiiko se järjestelmässäsi johdonmukaisesti. Jos ei toimi, voit poistaa sen uudelleen suorittamalla komennon `omarchy hibernation remove`.
