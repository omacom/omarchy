# Vianmääritys

### Rikoin järjestelmäni päivityksellä!

Yritä ensin [palauttaa järjestelmäsi](47-system-snapshots.md) siihen versioon, joka oli ennen viimeisintä päivitystäsi. Jos se ei toimi, käytä `omarchy-debug`-komentoa ja jaa ongelmasi #omarchy-help-kanavalla Discordissa. Ja jos kaikki muu epäonnistuu, voit asentaa oletusasetukset ja -paketit uudelleen komennolla `omarchy-reinstall`.

### Miksi jotkut sovellukset ovat niin suuria näytölläni?

Omarchy olettaa 2x korkean resoluution näytön, joten se asettaa `GDK_SCALE`-arvoksi 2, kunnes valitset skaalauksen näyttöpaneelista. Jos käytät 1x-näyttöä ja GTK- tai X11-sovellukset näkyvät ylisuurina, valitse sille 1x näyttöpaneelista tai lisää `hl.env("GDK_SCALE", "1")` tiedostoon `~/.config/hypr/monitors.lua` (ja käynnistä sitten uudelleen kaikki ylisuurena näkyvät sovellukset). Katso [näyttöjä koskeva opas](33-monitors.md).

Spotifyssa voit pienentää käyttöliittymää näppäimillä `Ctrl + Minus` (ja suurentaa sitä näppäimillä `Ctrl + Plus`).

### Miksi kaikki Super-näppäinsidontani lakkasivat toimimasta?

Joissakin ASUS ROG- ja TUF-kannettavissa `Fn + Super` on helposti huomaamatta jäävä yhdistelmä, joka kytkee päälle tai pois laiteohjelmiston Windows-näppäimen lukituksen (tarkoitettu pelaamiseen, jotta et poistu pelistä vahingossa). Mikään näytöllä ei kerro, että näin tapahtui. Lukituksen ollessa päällä Super ei lähetä mitään ollenkaan — joten jokainen Superia käyttävä Omarchy-sidonta vain lakkaa toimimasta, ja näyttää siltä, että Hyprland meni rikki.

Paina `Fn + Super` kerran, ennen kuin alat kaivella `~/.config/hypr/`-kansiota, ja jos se ei tuo Superia takaisin, paina sitä uudelleen, jotta et jätä lukitusta päälle. Tämä ei ole Fn-lock, joka muuttaa vain sitä, mitä F-näppäinrivi tekee.

### Wi-Fi, Bluetooth, ääni tai kosketuslevyni lakkasi juuri toimimasta

Ennen kuin käynnistät koneen uudelleen, yritä käynnistää ongelmallinen osajärjestelmä uudelleen erikseen. Omarchy-valikon _Update > Hardware_ -kohdassa ovat Wi-Fi, Bluetooth, Audio ja Trackpad, ja yhden niistä uudelleenlataaminen selvittää suurimman osan "se toimi viisi minuuttia sitten" -tilanteista — Bluetooth-kuulokkeet, jotka eivät yhdistä uudelleen, kosketuslevy, joka lakkasi toimimasta lepotilan jälkeen, ääni, joka katosi, kun irrotit näytön.

### Miksi ulkoiset kaiuttimeni eivät soi?

Todennäköisesti siksi, että niitä ei ole asetettu ensisijaiseksi ulostuloksi. Napsauta kaiutinkuvaketta palkin oikealla puolella, niin se avaa äänenvoimakkuuden ponnahdusikkunan, jossa voit valita ulostulolaitteen (ja säätää myös sovelluskohtaisia äänenvoimakkuuksia).

### Kannettavani kaiuttimet kuulostavat oudoilta

Joissakin kannettavissa Omarchy ottaa automaattisesti käyttöön kaiuttimien virityksen, joka korjaa sisäänrakennettujen kaiuttimien taajuusvasteen. `omarchy audio tuning status` kertoo, onko sellainen käytössä koneellasi, ja `omarchy audio tuning off` poistaa sen käytöstä, jos haluat mieluummin kuulla kaiuttimet sellaisinaan.

### Miksi en voi kirjautua sisään tai käyttää sudoa salasanallani?

Kirjoitit sen todennäköisesti väärin liian monta kertaa ja jouduit lukituksi ulos. Jos näin tapahtuu lukitusnäytöllä, voit painaa `CTRL + ALT + F2` käynnistääksesi uuden TTY:n, jossa voit kirjautua sisään root-käyttäjänä, ja suorittaa sitten komennon `faillock --reset --user [your-username]`. Se nollaa lukituksen, ja voit jatkaa.

### Miksi 1Passwordin valtuutuskehotteeni 1Password SSH Agentille / CLI:lle eivät tule näkyviin?

Tämä voi johtua kahdesta syystä:

Jotta monipuolinen hyväksyntäkehote tulisi näkyviin, kohdan Settings > Advanced > Use Hardware Acceleration on oltava päällä. _Huomautus: Tämä vaatii uudelleenkäynnistyksen alkaakseen toimia._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Tai jos et ole käynnistänyt 1Passwordia käynnistyksen jälkeen, kehote ei tule näkyviin.
