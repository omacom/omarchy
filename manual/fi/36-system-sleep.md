# Järjestelmän lepotila

Omarchy ottaa valmiustilan ja horrostilan käyttöön oletuksena, mutta jos sinulla on ongelmia kumman tahansa kanssa koneellasi, voit kytkeä ne pois päältä.

NVIDIA GB10 -koneissa, kuten DGX Sparkissa ja ASUS Ascent GX10:ssä, valmiustila ja horrostila on kytketty pois päältä, samoin kuin NVIDIA:n DGX OS:ssä, koska lepotilan ei ole vielä osoitettu toimivan sillä laitteistolla. Sama koskee ASUS Zenbook A16 (UX3607OA) -konetta, jossa valmiustila ei vielä saa sirua täysin lepotilaan ja se voi jumiutua yön aikana. Valmiustilan kytkin ja horrostilan määritys eivät koske niitä. Kytke lepotila takaisin päälle poistamalla `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` komennolla `sudo rm`; Valmiustila palaa tämän jälkeen valikkoon, ja horrostilan voi määrittää kuten muissakin koneissa. Komennon `sudo omarchy apply hardware --install-user "$USER"` suorittaminen palauttaa tiedoston.

### Virtaprofiilit

Kannettavalla Omarchy muistaa virtaprofiilisi erikseen verkkovirralla käytettäessä ja akulla käytettäessä, ja vaihtaa näiden kahden välillä, kun kytket johdon ja irrotat sen. Suoraan käytössä se tarkoittaa suorituskykyä verkkovirralla ja tasapainotettua akulla.

Näet, mitä koneesi tarjoaa, komennolla `omarchy powerprofiles list`, ja asetat haluamasi nykyiselle tilallesi komennolla `omarchy powerprofiles set autodetect power-saver`. Aseta toinen tila irrottamatta mitään nimeämällä se suoraan: `omarchy powerprofiles set battery power-saver`. Minkä tahansa valitsetkin, saat sen takaisin seuraavalla kerralla, kun olet siinä tilassa.

### Kytke valmiustila

Kytket valmiustilan suorittamalla `omarchy toggle suspend` terminaalista. Se vain näyttää/piilottaa vaihtoehdon kohdassa _Järjestelmä_ (tai `Super + Esc`), ja sitten näet, toimiiko se luotettavasti järjestelmässäsi. Jos ei, voit piilottaa sen uudelleen samalla komennolla.

### Kytke horrostila

Määrität horrostilan suorittamalla `omarchy hibernation setup` terminaalista. Horrostila luo käynnistyslevyllesi /swap-alivolyymin, joka on fyysisen RAM-muistisi kokoinen, joten varmista, että sinulla on runsaasti tilaa jäljellä. 32GB:n koneessa tarvitset aina 32GB+ vapaata tilaa tälle volyymille. Horrostila vaatii myös oletusarvoisen Limine-käynnistyslataimen.

Kun se on määritetty, näet horrostilavaihtoehdon kohdassa _Järjestelmä_ (tai `Super + Esc`), ja sitten näet, toimiiko se luotettavasti järjestelmässäsi. Jos ei, voit poistaa sen uudelleen suorittamalla `omarchy hibernation remove`.
