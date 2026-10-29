# Vianmääritys

### Riko järjestelmäni päivityksellä!

Kokeile ensin [palauttaa järjestelmäsi](47-system-snapshots.md) versioon ennen viimeisintä päivitystäsi. Jos se ei toimi, käytä `omarchy-debug`-komentoa jakaaksesi ongelmasi #omarchy-help-kanavalla Discordissa. Ja jos kaikki muu epäonnistuu, voit asentaa oletusasetukset ja -paketit uudelleen käyttämällä `omarchy-reinstall`-komentoa.

### Miksi jotkin sovellukset ovat niin suuria näytölläni?

Omarchy olettaa 2x korkean resoluution näytön, mikä edellyttää `GDK_SCALE`-arvon asettamista arvoon 2 tiedostossa `~/.config/hypr/monitors.lua`. Mutta jos käytät 1x-näyttöä, voit muuttaa `local omarchy_gdk_scale = 2` arvoon 1 (ja käynnistää sitten uudelleen kaikki liian suuret sovellukset). Katso [näyttöjä koskeva opas](33-monitors.md).

Spotifyssa voit käyttää `Ctrl + Minus` pienentääksesi käyttöliittymää (ja `Ctrl + Plus` suurentaaksesi sitä).

### Miksi kaikki Super-näppäinsidontani lakkasivat toimimasta?

Joissakin ASUS ROG- ja TUF-kannettavissa `Fn + Super` on helposti huomaamatta jäävä yhdistelmä, joka kytkee laiteohjelmiston Windows-näppäimen lukituksen (tarkoitettu pelaamiseen, jotta et poistu pelistä vahingossa). Mikään näytöllä ei kerro, että näin tapahtui. Kun lukitus on päällä, Super ei lähetä mitään — joten jokainen Superia käyttävä Omarchy-sidonta lakkaa toimimasta, ja näyttää siltä, että Hyprland meni rikki.

Paina `Fn + Super` kerran ennen kuin alat kaivella `~/.config/hypr/`-kansiota, ja jos se ei tuo Superia takaisin, paina sitä uudelleen, jotta et jätä lukitusta päälle. Tämä ei ole Fn-lukitus, joka muuttaa vain F-näppäinrivin toimintaa.

### Wi-Fi, Bluetooth, ääni tai ohjauslevyni lakkasi juuri toimimasta

Ennen kuin käynnistät koneen uudelleen, kokeile käynnistää viallinen alijärjestelmä uudelleen yksinään. Omarchy-valikon _Update > Hardware_ sisältää Wi-Fi, Bluetooth, Audio ja Trackpad, ja yhden niistä uudelleenlataaminen selvittää suurimman osan "se toimi viisi minuuttia sitten" -tilanteista — Bluetooth-kuulokkeet, jotka eivät yhdistä uudelleen, ohjauslevy, joka kuoli lepotilan jälkeen, ääni, joka katosi, kun irrotit näytön.

### Miksi ulkoiset kaiuttimeni eivät soi?

Todennäköisesti siksi, että niitä ei ole asetettu ensisijaiseksi ulostuloksi. Napsauta kaiutinkuvaketta palkin oikealla puolella, niin se avaa äänenvoimakkuuden ponnahdusikkunan, jossa voit valita ulostulolaitteen (ja miksata myös sovelluskohtaiset äänenvoimakkuudet).

### Kannettavani kaiuttimet kuulostavat oudoilta

Joissakin kannettavissa Omarchy ottaa automaattisesti käyttöön kaiutinvirityksen, joka korjaa sisäänrakennettujen kaiuttimien taajuusvasteen. `omarchy audio tuning status` kertoo, onko sellainen aktiivinen koneellasi, ja `omarchy audio tuning off` kytkee sen pois, jos haluat mieluummin kuulla kaiuttimet raakana.

### Miksi en voi kirjautua sisään tai käyttää sudoa salasanallani?

Kirjoitit sen luultavasti väärin liian monta kertaa ja jouduit lukituksi ulos. Jos tämä tapahtuu lukitusnäytöllä, voit painaa `CTRL + ALT + F2` käynnistääksesi uuden TTY:n, jossa voit kirjautua sisään root-käyttäjänä, ja ajaa sitten `faillock --reset --user [your-username]`. Se nollaa lukituksen, ja olet valmis jatkamaan.

### Miksi 1Passwordin valtuutuskehotteet 1Password SSH Agent / CLI:lle eivät näy?

Tämä voi tapahtua kahdesta syystä:

Jotta monipuolinen hyväksymiskehote näkyisi, Settings > Advanced > Use Hardware Acceleration on kytkettävä päälle. _Huomautus: Tämä vaatii uudelleenkäynnistyksen alkaakseen toimia._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Tai jos et ole käynnistänyt 1Passwordia käynnistyksen jälkeen, kehote ei näy.
