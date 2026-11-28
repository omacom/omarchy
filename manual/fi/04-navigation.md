# Navigointi

Kaikki Omarchyssa tapahtuu näppäimistön kautta — _KAIKKI!_ Kun järjestelmä käynnistyy ensimmäisen kerran, et kirjaimellisesti saa mitään tehtyä pelkällä hiirellä. Mutta voit painaa `Super + Space` paljastaaksesi Omarchy-valikon, ja täältä voit tehdä lähes kaiken.

Mutta Omarchy-valikon ei ole edes tarkoitus olla pääasiallinen tapa käyttää järjestelmää suurimman osan ajasta. Pääsemme vielä sitäkin nopeammiksi! Kaikki tärkeimmät sovellukset on sidottu suoraan yksittäisiin pikanäppäimiin. Käynnistät päätteen näppäimillä `Super + Return` ja selaimen näppäimillä `Super + Shift + Return`. Kokeile tehdä toinen toisensa jälkeen, niin näet Hyprlandin laatoituksen taian toiminnassa:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Voit sitten painaa `Super + J` pinotaksesi ne päällekkäin vierekkäisyyden sijaan:

 ![navigation-stacked](images/navigation-stacked.webp)

Paina `Super + J` uudelleen palauttaaksesi ne vierekkäisiin asemiinsa. Kokeile sitten selaimessa ollessasi näppäimiä `Super + Shift + Arrow Right` vaihtaaksesi ikkunat keskenään.

Kokeile nyt näppäimiä `Super + Shift + T` käynnistääksesi Activity monitorin. Se ilmestyy kelluvana ikkunana, jossa on otsikkopalkki, josta sitä voi vetää, sekä painikkeet sen pienentämiseen, suurentamiseen ja sulkemiseen. Jokainen kelluva ikkuna saa sellaisen, missä tahansa se onkin. Voit laatoittaa sen näppäimillä `Super + T` (ja painaa sitä uudelleen tehdäksesi siitä taas kelluvan). Paina nyt `Super + Shift + F` avataksesi tiedostonhallinnan. Sinulla on siisti neljän ikkunan kokoonpano:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navigoit sen ikkunan välillä, jonka haluat aktiiviseksi, näppäimillä `Super + Arrow`. Tämä vaihtaa kohdistuksen ja siirtää kohdistimen uuden sovelluksen keskelle. Näytön reunalla se jatkaa sillä puolella olevalle näytölle.

Jos painat `Super + Shift + 2`, siirrät parhaillaan kohdistetun sovelluksen toiseen työtilaan. `Super + Shift + 1` siirtää sen takaisin. (Ja `Super + Shift + Alt + 2` siirtää parhaillaan kohdistetun sovelluksen toiseen työtilaan vaihtamatta siihen).

Kun näyttöjä on useampi kuin yksi, jokaisella näytöllä on omat työtilansa 1–10. `Super + 2` siirtyy sen näytön toiseen työtilaan, jossa olet, ja jokaisen näytön yläpalkki näyttää sen omat työtilat ja sen, jota se parhaillaan näyttää. `Super + Tab` kiertää sen näytön työtilojen läpi, jossa olet. `Super + Shift + Ctrl + Arrows` siirtää ikkunan, jossa olet, kyseisessä suunnassa olevalle näytölle, sen näyttämään työtilaan, ja `Super + Shift + Alt + Arrows` siirtää työtilan, jossa olet, kyseisessä suunnassa olevalle näytölle, jossa se saa saman numeron, jos se on vapaana. Näyttö säilyttää työtilansa, kun irrotat sen: ne liittyvät toisen näytön työtiloihin, numeroituna sen jo olemassa olevien jälkeen, ja palaavat vanhojen numerojensa alle, kun näyttö palaa.

Jos pidät `Super`-näppäintä pohjassa ja napsautat ikkunaa hiirellä, voit järjestellä uudelleen, missä se sijaitsee. Jos pidät `Super`-näppäintä pohjassa ja käytät hiiren oikeaa painiketta, voit muuttaa ikkunan kokoa vapaasti.

Suljet ikkunan näppäimillä `Super + W` tai `Super + Q` (ja suljet kaikki ikkunat näppäimillä `Ctrl + Alt + Delete`).

Voit myös siirtyä koko näyttöön näppäimillä `Super + F` tai vaikka vain koko leveyteen (yläpalkki säilyttäen) näppäimillä `Super + Alt + F` tai koko näyttöön ikkunan sisällä näppäimillä `Super + Ctrl + F` (hyvä YouTubelle!).

### Dwindle vs. vierivä asettelu

Omarchyn oletusasettelua kutsutaan nimellä dwindle. Se pitää kaikki yhdessä työtilassa avaamasi ikkunat näkyvissä kaikkina aikoina, vaikka sen täytyisi kutistaa niitä.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mutta voit myös valita muuttaa työtilan vieriväksi asetteluksi, jossa ikkunat ovat rivissä vierekkäin näytön näkyvän reunan tuolla puolen. Muutat yksittäisen työtilan tähän asetteluun näppäimillä `Super + L`.

`Super + L` -näppäinten painaminen uudelleen tekee työtilasta kelluvan, jossa ikkunat menevät vapaasti päällekkäin ja sijoitat ne itse, ja kolmas painallus palauttaa sen dwindleen. `Super + Alt + L` käy ne läpi toiseen suuntaan. Ikkuna, joka kelluu joka tapauksessa — sellainen, jonka nostit esiin näppäimillä `Super + T`, tai sovellus, joka avautuu aina kelluvana — pysyy kelluvana, kun työtila palaa laatoitukseen. Yläpalkki merkitsee työtilan, jossa olet, sen asettelulla: neliö dwindlelle, ympyrä vierivälle ja kolmio kelluvalle. Merkin napsauttaminen kiertää myös asettelua, samoin kuin näyttönäppäin kannettavissa, joissa sellainen on.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valinta on työtilakohtainen, ja se pysyy. Voit siis pitää työtilan 1 dwindlessa selailua varten ja työtilan 2 vierivässä koodia varten, ja ne palaavat sellaisina uudelleenkäynnistyksen jälkeen.

Jos haluat käyttää vierivää asettelua oletuksena, voit asettaa sen tiedostossa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Kelluvat työtilat

Kelluva työtila toimii kuin perinteinen työpöytä: ikkunat menevät päällekkäin, ja siirrät ja mitoitat ne itse. Jokainen ikkuna saa teemasi väreissä olevan otsikkopalkin, jossa on painikkeet pienentämiseen, suurentamiseen ja sulkemiseen. Myös `Super + M` pienentää kohdistetun ikkunan. Pienennetty ikkuna odottaa telakassa; napsauta sen sovellusta tuodaksesi sen takaisin. Napsauta ikkunaa tuodaksesi sen eteen. Muuta sen kokoa mistä tahansa reunasta tai kulmasta. Kaksoisnapsauta otsikkopalkkia suurentaaksesi ikkunan pitäen samalla yläpalkin näkyvissä, ja uudelleen saadaksesi sen vanhan koon takaisin. Chrome ja muut Chromium-pohjaiset selaimet, Disks ja Document Viewer ohittavat otsikkopalkin ja käyttävät sen sijaan omaa ylätunnistettaan; `Super + Alt + F` suurentaa ne, ja `Super + M` pienentää ne.

Jokaisella työtilalla on telakka, jossa ovat kiinnittämäsi sovellukset, kaikki käynnissä olevat sekä ruudukko kaikista sovelluksista sovelluspainikkeen takana, jonka myös `Super + Alt + Space` ja Omarchy-valikon _Apps_ avaavat. Napsauta sovellusta ruudukossa hiiren oikealla painikkeella tai paina `Delete` poistaaksesi sen asennuksen. Napsauta sovellusta avataksesi sen tai tuodaksesi sen ikkunan eteen; napsauta uudelleen kiertääksesi sen ikkunoiden läpi. Files tuo takaisin vain ikkunan työtilasta, jossa olet, ja avaa muussa tapauksessa uuden, ja Terminal ja Agent käynnistävät aina toisen, vaikka pienennetty ikkuna palaa ensin. Keskinapsautus avaa uuden ikkunan. Vedä kuvaketta telakkaa pitkin siirtääksesi sitä; käynnissä olevan sovelluksen vetäminen muiden joukkoon pitää sen siellä. Napsauta hiiren oikealla painikkeella pitääksesi sovelluksen telakassa, poistaaksesi sen sieltä tai lopettaaksesi sen. Telakka pysyy näkyvissä, kun työtila on tyhjä, ja kun työtilassa on ikkuna, se piiloutuu, kunnes osoitin saavuttaa sen reunan. Koko näytön ikkuna piilottaa sen kokonaan. Vedä sovelluspainiketta kohti näytön toista reunaa siirtääksesi telakan sinne. Napsauta sitä hiiren oikealla painikkeella saadaksesi vaihtoehdon _Position_ reunan valitsemiseen, vaihtoehdon _Layout_ oletusasettelun asettamiseen kuten _Appearance > Workspace Layout_ tekee, ja vaihtoehdon _Visibility_ pitääksesi telakan aina päällä, antaaksesi ensimmäisen sovelluksen piilottaa sen tai pitääksesi sen aina piilossa. `omarchy dock visibility always` asettaa sen päätteestä. Sijainti on myös kohdassa _Appearance > Dock > Dock Position_, ja `omarchy dock position left` asettaa sen päätteestä. Telakassa pitämäsi sovellukset näkyvät haalistuneina, kun ne eivät ole käynnissä. Jos haluat pitää telakan vain kelluvissa työtiloissa, käytä vaihtoehtoa _Appearance > Dock > Dock Only on Floating_ tai komentoa `omarchy dock tiling off`.

Uudet työtilat ja kaikki työtilat, joille et ole antanut omaa asetteluaan näppäimillä `Super + L`, käyttävät oletusasettelua. Oletuksen muuttaminen palauttaa jokaisen ikkunattoman työtilan siihen, kun taas ikkunoita sisältävä työtila säilyttää nykyisen asettelunsa. Telakkaan pienennetty ikkuna lasketaan edelleen ikkunaksi työtilassa, josta se lähti. Valitse se kohdasta _Appearance > Workspace Layout_: Tiling, Scrolling tai Floating. `omarchy hyprland workspace layout default scrolling` asettaa sen päätteestä.

### Ikkunoiden ryhmittely

Ikkunoita voi ryhmitellä näppäimillä `Super + G`. Kun olet ryhmässä, jokainen sen ollessa aktiivisena käynnistämäsi ikkuna kuuluu ryhmään. Voit siirtyä näiden ryhmiteltyjen ikkunoiden välillä näppäimillä `Super + Ctrl + Arrow Left/Right` tai näppäimillä `Super + Alt + 1/2/3/4` siirtyäksesi suoraan ryhmiteltyihin ikkunoihin järjestyksessä.

Voit siirtää ikkunan pois ryhmittelystä näppäimillä `Super + Alt + G` tai purkaa koko ryhmän painamalla `Super + G` uudelleen. Lopuksi voit siirtää ryhmän ulkopuolisia ikkunoita siihen näppäimillä `Super + Alt + Arrows`.

### Ikkunoiden nostaminen esiin

Voit nostaa ikkunan esiin sen työtilavarauksesta näppäimillä `Super + O`. Se kiinnittää sen kelluvaksi ikkunaksi, joka seuraa sinua mihin tahansa työtilaan siirrytkin. Loistava videosoittimille ja vastaaville.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-työtila

On olemassa erityinen täysikokoinen scratchpad-työtila, joka asettuu päällekkäin sen työtilan kanssa, jossa parhaillaan olet. Pääset sen sisältöön näppäimillä `Super + S`, ja sijoitat sinne ikkunoita näppäimillä `Super + Alt + S`.

Se sopii hyvin säätimille tai päätteelle, jota haluat käyttää nopeasti poistumatta nykyisestä työtilasta.

### Quake-konsoli

Lopuksi on olemassa puolikkaan korkeuden Quake-konsoli, joka putoaa alas sen työtilan päälle, jossa parhaillaan olet. Vaihda se näkyviin ja pois näppäimillä `Super + the key above Tab` (US-asetteluissa grave), ja sijoita sinne ikkuna näppäimillä `Super + Shift + the key above Tab`.

Ensimmäisellä avauskerralla se käynnistää oletusagenttisi tai pyytää sinua valitsemaan sellaisen, jos et ole vielä valinnut yhtä. Kun konsolissa on vain yksi ikkuna, se putoaa alas keskitettynä paneelina sen sijaan, että ulottuisi koko näytön levyiseksi. Laita siihen toinen sovellus, niin se palaa täyteen leveyteen, jotta molemmat mahtuvat vierekkäin.

Siirtääksesi ikkunan pois joko scratchpadista tai konsolista lähetä se suoraan toiseen työtilaan esimerkiksi näppäimillä `Super + Shift + 1`.

### Tähän tottuminen vie hetken!

Tällaisen työpöydällä navigoinnin oppiminen vie hieman aikaa, mutta kun siihen tottuu, perinteiseen hiirivetoiseen työpöytäkokemukseen palaaminen on vaikeaa!
