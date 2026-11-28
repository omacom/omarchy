# Vianmääritys

### Rikoin järjestelmäni päivityksellä!

Yritä ensin [palauttaa järjestelmäsi](47-system-snapshots.md) versioon ennen viimeisintä päivitystäsi. Jos se ei toimi, käytä `omarchy-debug`-komentoa ja jaa ongelmasi #omarchy-help-kanavalla Discordissa. Ja jos kaikki muu epäonnistuu, voit asentaa oletusasetukset ja -paketit uudelleen komennolla `omarchy-reinstall`.

### Miksi jotkut sovellukset ovat niin suuria näytölläni?

Omarchy olettaa, että käytössä on 2x korkean resoluution näyttö, joten se asettaa `GDK_SCALE`-arvoksi 2, kunnes valitset skaalauksen näyttöpaneelissa. Jos käytät 1x-näyttöä ja GTK- tai X11-sovellukset näkyvät ylisuurina, valitse sille 1x näyttöpaneelissa tai lisää `hl.env("GDK_SCALE", "1")` tiedostoon `~/.config/hypr/monitors.lua` (ja käynnistä sitten uudelleen kaikki ylisuurina näkyvät sovellukset). Katso [näyttöjä käsittelevä opas](33-monitors.md).

Spotifyssa voit pienentää käyttöliittymää näppäinyhdistelmällä `Ctrl + Minus` (ja suurentaa sitä näppäinyhdistelmällä `Ctrl + Plus`).

### Miksi kaikki Super-näppäinsidontani lakkasivat toimimasta?

Joissakin ASUS ROG- ja TUF-kannettavissa `Fn + Super` on helposti huomaamatta jäävä näppäinyhdistelmä, joka kytkee päälle tai pois laiteohjelmiston Windows-näppäimen lukituksen (tarkoitettu pelaamiseen, jotta et poistu pelistä vahingossa). Mikään näytöllä ei kerro, että näin tapahtui. Kun lukitus on päällä, Super ei lähetä yhtään mitään — joten jokainen Superia käyttävä Omarchy-sidonta vain lakkaa toimimasta, ja näyttää siltä, että Hyprland meni rikki.

Paina `Fn + Super` kerran, ennen kuin alat kaivella `~/.config/hypr/`-kansiota, ja jos se ei palauta Superia, paina sitä uudelleen, jotta et jätä lukitusta päälle. Tämä ei ole Fn-lock, joka muuttaa vain sitä, mitä F-näppäinrivi tekee.

### Wi-Fi, Bluetooth, ääni tai kosketuslevy lakkasi juuri toimimasta

Ennen kuin käynnistät koneen uudelleen, yritä käynnistää ongelman aiheuttava alijärjestelmä uudelleen erikseen. Omarchy-valikon _Update > Hardware_ -kohdassa on Wi-Fi, Bluetooth, Audio ja Trackpad, ja yhden niistä uudelleenlataaminen selvittää suurimman osan "se toimi viisi minuuttia sitten" -tilanteista — Bluetooth-kuulokkeet, jotka eivät yhdistä uudelleen, kosketuslevy, joka pimeni lepotilan jälkeen, ääni, joka katosi, kun irrotit näytön.

### Miksi ulkoiset kaiuttimeni eivät soi?

Todennäköisesti siksi, että niitä ei ole asetettu ensisijaiseksi ulostuloksi. Napsauta palkin oikealla puolella olevaa kaiutinkuvaketta, niin se avaa äänenvoimakkuuden ponnahdusikkunan, jossa voit valita ulostulolaitteen (ja miksata myös sovelluskohtaiset äänenvoimakkuudet).

### Kannettavani kaiuttimet kuulostavat oudolta

Joissakin kannettavissa Omarchy ottaa automaattisesti käyttöön kaiuttimien säädön, joka korjaa sisäänrakennettujen kaiuttimien taajuusvasteen. `omarchy audio tuning status` kertoo, onko sellainen käytössä koneellasi, ja `omarchy audio tuning off` kytkee sen pois, jos haluat mieluummin kuulla kaiuttimet raakana.

### Miksi en voi kirjautua sisään tai käyttää sudoa salasanallani?

Kirjoitit sen todennäköisesti väärin kymmenen kertaa ja jouduit lukituksi ulos. Lukitus poistuu itsestään kahden minuutin kuluttua. Jos et malta odottaa ja tämä tapahtuu lukitusnäytöllä, voit painaa `CTRL + ALT + F2` käynnistääksesi uuden TTY:n, jossa voit kirjautua sisään root-käyttäjänä, ja suorittaa sitten `faillock --reset --user [your-username]`. Se nollaa lukituksen, ja voit jatkaa.

### Salasanani hyväksytään, mutta palaan kirjautumisnäyttöön

Rikkinäinen istunnon ympäristötiedosto voi estää työpöytää käynnistymästä, vaikka salasanasi olisi oikein. Tämä kannattaa tarkistaa erityisesti `~/.config/uwsm/env.d/`-kansion muokkaamisen jälkeen.

Paina `Ctrl + Alt + F2`, kirjaudu sisään normaalilla käyttäjätunnuksellasi ja salasanallasi ja tutki nykyisen käynnistyksen käyttäjäjournalia:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Etsi virhe, joka nimeää jonkin ympäristötiedostoistasi, kuten `bad substitution`, juuri ennen viestiä, jonka mukaan env-ulostulon merkkiä ei löytynyt. Siirrä kyseinen tiedosto pois `env.d`-kansiosta, ennen kuin yrität kirjautua uudelleen. Jos virhe nimeää esimerkiksi tiedoston `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM ohittaa tiedoston, jossa on syntaksivirhe, mutta kohtalokas virhe, joka ilmenee vasta tiedoston suorituksen aikana, kuten `bad substitution`, voi silti estää työpöytää käynnistymästä. Järjestelmän tilannekuvan palautus ei korjaa näitä tiedostoja, koska `/home`-kansiota ei palauteta.

Kun pääset kirjautumaan sisään, korjaa tallennettu kopio, ennen kuin siirrät sen takaisin. `sh -n` havaitsee syntaksivirheet suorittamatta tiedostoa, mutta ei voi havaita kaikkia virheitä, jotka tapahtuvat, kun tiedosto ladataan lähteenä. Pidä toimiva pääte auki, kun testaat muutoksia.

### Miksi 1Passwordin valtuutuskehotteet 1Password SSH Agentille / CLI:lle eivät näy?

Tämä voi johtua kahdesta syystä:

Jotta monipuolinen hyväksyntäkehote ilmestyisi, Settings > Advanced > Use Hardware Acceleration on kytkettävä päälle. _Huomautus: Tämä vaatii uudelleenkäynnistyksen, jotta se alkaa toimia._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Tai jos et ole käynnistänyt 1Passwordia käynnistyksen jälkeen, kehote ei ilmesty.
