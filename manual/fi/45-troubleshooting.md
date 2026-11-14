# Vianmääritys

### Rikoin järjestelmäni päivityksellä!

Yritä ensin [palauttaa järjestelmäsi](47-system-snapshots.md) viimeisintä päivitystäsi edeltävään versioon. Jos se ei toimi, jaa ongelmasi komennon `omarchy-debug` avulla Discordin #omarchy-help-kanavalla. Ja jos kaikki muu epäonnistuu, voit asentaa oletusmääritykset ja -paketit uudelleen komennolla `omarchy-reinstall`.

### Miksi jotkin sovellukset ovat niin suuria näytölläni?

Omarchy olettaa, että käytössä on korkean tarkkuuden 2x-näyttö, joten se asettaa `GDK_SCALE`-arvon 2:ksi, kunnes valitset skaalauksen näyttöpaneelissa. Jos käytät 1x-näyttöä ja GTK- tai X11-sovellukset näkyvät ylisuurina, valitse sille 1x näyttöpaneelissa tai lisää `hl.env("GDK_SCALE", "1")` tiedostoon `~/.config/hypr/monitors.lua` (ja käynnistä sitten uudelleen kaikki ylisuuret sovellukset). Katso [näyttöjä käsittelevä opas](33-monitors.md).

Spotifyssa voit pienentää käyttöliittymää painamalla `Ctrl + Minus` (ja suurentaa sitä painamalla `Ctrl + Plus`).

### Miksi kaikki Super-näppäinsidontani lakkasivat toimimasta?

Joissakin ASUS ROG- ja TUF-kannettavissa `Fn + Super` on helposti huomaamatta jäävä näppäinyhdistelmä, joka kytkee laiteohjelmiston Windows-näppäinlukon päälle ja pois päältä (se on tarkoitettu pelaamiseen, jotta et poistuisi pelistä vahingossa). Mitään ilmoitusta asiasta ei näy näytöllä. Kun lukko on päällä, Super ei lähetä yhtään mitään — joten jokainen Super-näppäintä käyttävä Omarchy-sidonta lakkaa toimimasta, ja näyttää siltä, että Hyprland meni rikki.

Paina `Fn + Super` kerran, ennen kuin ryhdyt tutkimaan `~/.config/hypr/`-hakemistoa, ja jos se ei palauta Super-näppäintä, paina sitä uudelleen, jotta et jättäisi lukkoa päälle. Kyseessä ei ole Fn-lukko, joka muuttaa vain F-näppäinrivin toimintaa.

### Wi-Fi, Bluetooth, ääni tai kosketuslevyni lakkasi juuri toimimasta

Ennen kuin käynnistät tietokoneen uudelleen, yritä käynnistää ongelman aiheuttava osajärjestelmä uudelleen erikseen. Omarchy-valikon _Update > Hardware_ sisältää vaihtoehdot Wi-Fi, Bluetooth, Audio ja Trackpad, ja yhden niistä lataaminen uudelleen korjaa valtaosan "toimi vielä viisi minuuttia sitten" -tilanteista — Bluetooth-kuulokkeet, jotka eivät muodosta yhteyttä uudelleen, lepotilan jälkeen lakannut kosketuslevy tai ääni, joka katosi, kun irrotit näytön.

### Miksi ulkoiset kaiuttimeni eivät soi?

Todennäköisesti siksi, ettei niitä ole asetettu ensisijaiseksi äänilähdöksi. Napsauta palkin oikealla puolella olevaa kaiutinkuvaketta, niin äänenvoimakkuusikkuna avautuu. Siellä voit valita äänilähtölaitteen (ja säätää myös sovelluskohtaisia äänenvoimakkuuksia).

### Kannettavani kaiuttimet kuulostavat oudoilta

Joissakin kannettavissa Omarchy ottaa automaattisesti käyttöön kaiutinsäätöjä, jotka korjaavat sisäänrakennettujen kaiuttimien taajuusvastetta. `omarchy audio tuning status` kertoo, onko tällainen säätö käytössä koneessasi, ja `omarchy audio tuning off` poistaa sen käytöstä, jos haluat mieluummin kuulla kaiuttimet sellaisinaan.

### Miksi en voi kirjautua sisään tai käyttää sudoa salasanallani?

Kirjoitit sen todennäköisesti väärin liian monta kertaa ja tilisi lukittiin. Jos tämä tapahtuu lukitusnäytöllä, voit painaa `CTRL + ALT + F2` avataksesi uuden TTY:n, jossa voit kirjautua root-käyttäjänä, ja ajaa sitten komennon `faillock --reset --user [your-username]`. Se nollaa lukituksen, ja voit jatkaa.

### Salasanani hyväksytään, mutta palaan kirjautumisnäyttöön

Rikkinäinen istunnon ympäristötiedosto voi estää työpöytää käynnistymästä, vaikka salasanasi olisi oikein. Tämä kannattaa tarkistaa erityisesti, jos olet muokannut hakemistoa `~/.config/uwsm/env.d/`.

Paina `Ctrl + Alt + F2`, kirjaudu sisään tavallisella käyttäjätunnuksellasi ja salasanallasi ja tarkista nykyisen käynnistyksen käyttäjäloki:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Etsi virhettä, jossa mainitaan jokin ympäristötiedostoistasi, kuten `bad substitution`, juuri ennen viestiä siitä, että env-tulosteen merkkiä ei löytynyt. Siirrä kyseinen tiedosto pois `env.d`-hakemistosta, ennen kuin yrität kirjautua uudelleen. Jos virhe mainitsee esimerkiksi tiedoston `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM ohittaa tiedoston, jossa on syntaksivirhe, mutta kohtalokas virhe, joka ilmenee vasta tiedoston suorittamisen aikana, kuten `bad substitution`, voi silti estää työpöytää käynnistymästä. Järjestelmän tilannekuvan palautus ei korjaa näitä tiedostoja, koska `/home` ei sisälly palautukseen.

Kun pääset taas kirjautumaan sisään, korjaa tallennettu kopio, ennen kuin siirrät sen takaisin. `sh -n` havaitsee syntaksivirheet suorittamatta tiedostoa, mutta se ei pysty havaitsemaan kaikkia virheitä, jotka tapahtuvat, kun tiedosto luetaan ympäristöön. Pidä toimintakunnossa oleva pääte auki, kun testaat muutoksia.

### Miksi 1Passwordin valtuutuskehotteet 1Password SSH Agentia / CLI:tä varten eivät näy?

Tähän voi olla kaksi syytä:

Jotta monipuolinen hyväksymiskehote näkyisi, Settings > Advanced > Use Hardware Acceleration on otettava käyttöön. _Huomautus: Tämä alkaa toimia vasta uudelleenkäynnistyksen jälkeen._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Tai jos et ole käynnistänyt 1Passwordia tietokoneen käynnistämisen jälkeen, kehote ei näy.
