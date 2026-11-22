# Järjestelmän lepotila

Omarchy ottaa keskeytystilan käyttöön oletusarvoisesti ja horrostilan, kun se on määritetty, mutta jos sinulla on koneellasi ongelmia jommankumman kanssa, voit poistaa ne käytöstä.

NVIDIA GB10 -koneilla, kuten DGX Sparkilla ja ASUS Ascent GX10:llä, keskeytystila ja horrostila ovat pois käytöstä, kuten ne ovat NVIDIAn DGX OS:ssä, koska lepotilan ei ole vielä osoitettu toimivan kyseisellä laitteistolla. Sama koskee ASUS Zenbook A16:ta (UX3607OA), jossa keskeytystila ei vielä aseta sirua täysin lepotilaan ja voi jumiutua yön aikana. Keskeytystilan kytkin ja horrostilan määritys eivät koske niitä. Saadaksesi lepotilan takaisin käyttöön poista `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` komennolla `sudo rm`; Keskeytystila palaa sitten valikkoon, ja horrostila voidaan määrittää kuten muilla koneilla. Komennon `sudo omarchy apply hardware --install-user "$USER"` suorittaminen palauttaa tiedoston.

### Virtap profiilit

Kannettavalla tietokoneella Omarchy muistaa virtaprofiilisi erikseen verkkovirtaan kytkettynä ja akulla käytettäessä ja vaihtaa näiden kahden välillä, kun kytket laitteen verkkovirtaan ja irrotat sen. Valmiiksi se tarkoittaa suorituskykyä verkkovirralla ja tasapainotettua tilaa akulla.

Näet, mitä koneesi tarjoaa, komennolla `omarchy powerprofiles list`, ja voit asettaa haluamasi profiilin tilalle, jossa parhaillaan olet, komennolla `omarchy powerprofiles set autodetect power-saver`. Asettaaksesi toisen tilan irrottamatta mitään, nimeä se suoraan: `omarchy powerprofiles set battery power-saver`. Minkä tahansa valitsetkin, saat saman takaisin seuraavan kerran, kun olet kyseisessä tilassa.

### Keskeytystilan kytkeminen päälle ja pois

Kytket keskeytystilan päälle ja pois suorittamalla terminaalista `omarchy toggle suspend`. Se vain näyttää/piilottaa vaihtoehdon kohdan _Järjestelmä_ alla (tai `Super + Esc`), minkä jälkeen näet, toimiiko se järjestelmässäsi johdonmukaisesti. Jos ei toimi, voit piilottaa sen uudelleen samalla komennolla.

### Horrostilan kytkeminen päälle ja pois

Määrität horrostilan suorittamalla terminaalista `omarchy hibernation setup` (se ei ole saatavilla Apple Silicon -Maceilla). Horrostila luo käynnistysasemallesi fyysisen RAM-muistisi määrän kokoisen /swap-alitaltion, joten varmista, että sinulla on runsaasti vapaata tilaa. 32GB:n koneella tarvitset tälle taltiolle aina yli 32GB vapaata tilaa. Horrostila vaatii myös oletusarvoisen Limine-käynnistyslataimen.

Kun määritys on tehty, näet horrostilavaihtoehdon kohdan _Järjestelmä_ alla (tai `Super + Esc`), minkä jälkeen näet, toimiiko se järjestelmässäsi johdonmukaisesti. Jos ei toimi, voit poistaa sen uudelleen suorittamalla `omarchy hibernation remove`.
