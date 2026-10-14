# Vianmääritys

### Rikoin järjestelmäni päivityksellä!

Yritä ensin [palauttaa järjestelmäsi](47-system-snapshots.md) versioon ennen viimeistä päivitystäsi. Jos se ei toimi, käytä komentoa `omarchy-debug` jakaaksesi ongelmasi kanavalla #omarchy-help Discordissa. Ja jos kaikki se epäonnistuu, voit asentaa oletusmääritykset ja -paketit uudelleen komennolla `omarchy-reinstall`.

### Miksi jotkut sovellukset ovat niin suuria näytölläni?

Omarchy olettaa 2x-korkearesoluutioisen näytön, mikä vaatii asetuksen `GDK_SCALE` arvoon 2 tiedostossa `~/.config/hypr/monitors.lua`. Mutta jos olet 1x-näytöllä, voit vaihtaa kohdan `local omarchy_gdk_scale = 2` arvoon 1 (ja käynnistää sitten uudelleen kaikki ylisuuret sovellukset). Katso [käyttöopasta näytöistä](33-monitors.md).

Spotifyssa voit käyttää näppäimiä `Ctrl + Minus` käyttöliittymän pienentämiseen (ja `Ctrl + Plus` sen suurentamiseen).

### Wi-Fini, Bluetoothini, ääneni tai kosketuslevyni lakkasivat juuri toimimasta

Ennen kuin käynnistät uudelleen, yritä käynnistää syyllinen osajärjestelmä uudelleen yksinään. Omarchy-valikon kohdassa _Päivitä > Laitteisto_ ovat Wi-Fi, Bluetooth, Audio ja Trackpad, ja yhden niistä uudelleenlataaminen selvittää suurimman osan ”toimi viisi minuuttia sitten” -tilanteista — Bluetooth-kuulokkeet, jotka eivät yhdisty uudelleen, kosketuslevy, joka kuoli lepotilan jälkeen, ääni, joka katosi, kun irrotit näytön.

### Miksi ulkoiset kaiuttimeni eivät soi?

Luultavasti siksi, että niitä ei ole asetettu ensisijaiseksi lähdöksi. Napsauta palkin oikealla puolella olevaa kaiutinkuvaketta, niin äänenvoimakkuuden ponnahdusikkuna avautuu ja voit valita lähtölaitteen (ja miksata myös sovelluskohtaisia äänenvoimakkuuksia).

### Kannettavan kaiuttimet kuulostavat oudolta

Joissakin kannettavissa Omarchy soveltaa automaattisesti kaiutinviritystä, joka korjaa sisäänrakennettujen kaiuttimien taajuusvasteen. `omarchy audio tuning status` kertoo, onko sellainen käytössä koneellasi, ja `omarchy audio tuning off` poistaa sen käytöstä, jos haluat mieluummin kuulla kaiuttimet raakana.

### Miksi en voi kirjautua sisään tai käyttää sudoa salasanallani?

Kirjoitit sen luultavasti väärin liian monta kertaa ja lukkiuduit ulos. Jos näin tapahtuu lukitusruudulla, voit painaa `CTRL + ALT + F2` käynnistääksesi uuden TTY:n, jossa voit kirjautua rootina, ja aja sitten komento `faillock --reset --user [your-username]`. Se nollaa lukituksen, ja olet valmis.

### Miksi 1Passwordin valtuutuskehotteeni 1Password SSH Agentille / CLI:lle eivät ilmesty?

Tätä voi tapahtua kahdesta syystä:

Jotta monipuolinen hyväksyntäkehote ilmestyy, Settings > Advanced > Use Hardware Acceleration täytyy olla päällä. _Huomautus: Tämä vaatii uudelleenkäynnistyksen toimiakseen._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Tai jos et ole käynnistänyt 1Passwordia käynnistyksen jälkeen, kehote ei ilmesty.
