# Navigointi

Kaikki Omarchyssa tapahtuu näppäimistöllä — _KAIKKI!_ Kun järjestelmä käynnistyy ensimmäisen kerran, et kirjaimellisesti saa mitään tehtyä pelkällä hiirellä. Mutta voit painaa `Super + Space` paljastaaksesi Omarchy-valikon, ja täältä voit tehdä melkein kaiken.

Mutta Omarchy-valikkoa ei ole edes tarkoitettu järjestelmän pääasialliseksi käyttötavaksi suurimman osan ajasta. Pääsemme vieläkin nopeammaksi! Kaikki tärkeimmät sovellukset on sidottu suoraan yksittäisiin pikanäppäimiin. Käynnistät päätteen näppäinyhdistelmällä `Super + Return` ja selaimen näppäinyhdistelmällä `Super + Shift + Return`. Kokeile tehdä toinen toisensa jälkeen, niin näet Hyprlandin laatoituksen taian toiminnassa:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Sen jälkeen voit painaa `Super + J` pinotaksesi ne päällekkäin vierekkäisyyden sijaan:

 ![navigation-stacked](images/navigation-stacked.webp)

Paina `Super + J` uudelleen palauttaaksesi ne vierekkäisiin asentoihinsa. Kokeile sitten näppäinyhdistelmää `Super + Shift + Arrow Right` selaimessa ollessasi vaihtaaksesi ikkunat keskenään.

Kokeile nyt näppäinyhdistelmää `Super + Shift + T` käynnistääksesi Activity monitorin. Se ilmestyy kelluvana ikkunana, jossa on otsikkopalkki, josta sitä voi vetää, ja painikkeet sen pienentämiseen, suurentamiseen ja sulkemiseen. Jokainen kelluva ikkuna saa sellaisen, missä tahansa se onkin. Voit laatoittaa sen näppäinyhdistelmällä `Super + T` (ja painaa sitä uudelleen tehdäksesi siitä taas kelluvan). Paina nyt `Super + Shift + F` avataksesi tiedostonhallinnan. Sinulla on siisti neljän ikkunan kokoonpano:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Siirryt aktivoitavaksi haluamasi ikkunan välillä näppäinyhdistelmällä `Super + Arrow`. Tämä vaihtaa fokuksen ja siirtää kohdistimen uuden sovelluksen keskelle. Näytön reunalla se jatkaa sillä puolella olevalle näytölle.

Jos painat `Super + Shift + 2`, siirrät parhaillaan fokuksessa olevan sovelluksen toiselle työtilalle. `Super + Shift + 1` siirtää sen takaisin. (Ja `Super + Shift + Alt + 2` siirtää parhaillaan fokuksessa olevan sovelluksen toiselle työtilalle vaihtamatta siihen).

Useamman kuin yhden näytön kanssa jokaisella näytöllä on omat työtilansa 1–10. `Super + 2` siirtyy sillä näytöllä, jolla olet, olevaan toiseen työtilaan, ja jokaisen näytön yläpalkki näyttää sen omat työtilat ja sen, jota se parhaillaan näyttää. `Super + Tab` kiertää sillä näytöllä, jolla olet, olevien työtilojen läpi. `Super + Shift + Ctrl + Arrows` siirtää ikkunan, jolla olet, kyseisessä suunnassa olevalle näytölle, sen näyttämälle työtilalle, ja `Super + Shift + Alt + Arrows` siirtää työtilan, jolla olet, kyseisessä suunnassa olevalle näytölle, jossa se saa saman numeron, jos se on vapaa. Näyttö pitää työtilansa, kun irrotat sen: ne liittyvät toisen näytön työtiloihin, numeroituna sen jo olemassa olevien jälkeen, ja palaavat vanhojen numerojensa alle, kun näyttö palaa.

Jos pidät `Super`-näppäintä painettuna ja käytät hiirtä napsauttaaksesi ikkunaa, voit järjestellä uudelleen, missä se sijaitsee. Jos pidät `Super`-näppäintä painettuna ja käytät hiiren oikeaa painiketta, voit muuttaa ikkunan kokoa vapaasti.

Suljet ikkunan näppäinyhdistelmällä `Super + W` tai `Super + Q` (ja suljet kaikki ikkunat näppäinyhdistelmällä `Ctrl + Alt + Delete`).

Voit myös siirtyä koko näytölle näppäinyhdistelmällä `Super + F` tai jopa vain koko leveydelle (säilyttäen yläpalkin) näppäinyhdistelmällä `Super + Alt + F` tai koko näytölle ikkunan sisällä näppäinyhdistelmällä `Super + Ctrl + F` (hyvä YouTubelle!).

### Dwindle vs. vierivä asettelu

Omarchyn oletusasettelu on nimeltään dwindle. Se pitää kaikki yhdellä työtilalla avaamasi ikkunat näkyvissä koko ajan, vaikka sen täytyisi pienentää niitä.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mutta voit myös valita muuttaa työtilan vieriväksi asetteluksi, jossa ikkunat ovat rivissä vierekkäin, näytön näkyvän reunan ulkopuolella. Muutat yksittäisen työtilan tähän asetteluun näppäinyhdistelmällä `Super + L`.

Näppäinyhdistelmän `Super + L` painaminen uudelleen tekee työtilasta kelluvan, jossa ikkunat menevät vapaasti päällekkäin ja sijoitat ne itse, ja kolmas painallus palauttaa sen dwindleen. `Super + Alt + L` käy ne läpi toiseen suuntaan. Ikkuna, joka kelluu joka tapauksessa — sellainen, jonka ponnautit ulos näppäinyhdistelmällä `Super + T`, tai sovellus, joka avautuu aina kelluvana — pysyy kelluvana, kun työtila palaa laatoitukseen. Yläpalkki merkitsee työtilan, jolla olet, sen asettelulla: neliö dwindlelle, ympyrä vierivälle ja kolmio kelluvalle. Sen merkin napsauttaminen kiertää myös asettelua, ja samoin tekee näyttönäppäin kannettavissa, joissa sellainen on.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valinta on työtilakohtainen, ja se pysyy. Voit siis pitää työtilan 1 dwindlessa selaamista varten ja työtilan 2 vierivässä koodia varten, ja ne palaavat sellaisina uudelleenkäynnistyksen jälkeen.

Jos haluat käyttää vierivää asettelua oletuksena, voit asettaa sen tiedostossa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Kelluvat työtilat

Kelluva työtila toimii kuin perinteinen työpöytä: ikkunat menevät päällekkäin, ja siirrät ja kokoat ne itse. Jokainen ikkuna saa teemasi väreissä olevan otsikkopalkin, jossa on painikkeet pienentämiseen, suurentamiseen ja sulkemiseen. `Super + M` pienentää myös fokuksessa olevan ikkunan. Pienennetty ikkuna odottaa telakassa; napsauta sen sovellusta tuodaksesi sen takaisin. Napsauta ikkunaa tuodaksesi sen eteen. Muuta sen kokoa mistä tahansa reunasta tai kulmasta. Kaksoisnapsauta otsikkopalkkia suurentaaksesi ikkunan pitäen yläpalkin näkyvissä, ja uudelleen saadaksesi sen vanhan koon takaisin. Chrome ja muut Chromium-pohjaiset selaimet, Disks ja Document Viewer ohittavat otsikkopalkin ja käyttävät sen sijaan omaa ylätunnistettaan; `Super + Alt + F` suurentaa ne, ja `Super + M` pienentää ne.

Jokaisella työtilalla on telakka, jossa ovat kiinnittämäsi sovellukset, kaikki käynnissä oleva ja ruudukko kaikista sovelluksista sovelluspainikkeen takana, jonka myös `Super + Alt + Space` ja Omarchy-valikon _Sovellukset_ avaavat. Napsauta sovellusta ruudukossa hiiren kakkospainikkeella tai paina `Delete` poistaaksesi sen asennuksen. Napsauta sovellusta avataksesi sen tai tuodaksesi sen ikkunan eteen; napsauta uudelleen kiertääksesi sen ikkunoiden läpi. Files tuo takaisin vain ikkunan työtilalta, jolla olet, ja muuten avaa uuden, ja Terminal ja Agent käynnistävät aina uuden, vaikka pienennetty ikkuna tulee takaisin ensin. Keskipainikkeen napsautus avaa uuden ikkunan. Vedä kuvaketta telakkaa pitkin siirtääksesi sitä; käynnissä olevan sovelluksen vetäminen muiden joukkoon pitää sen siellä. Napsauta hiiren kakkospainikkeella pitääksesi sovelluksen telakassa, poistaaksesi sen sieltä tai lopettaaksesi sen. Telakka pysyy esillä työtilan ollessa tyhjä, ja kun työtilalla on ikkuna, se piiloutuu, kunnes osoitin saavuttaa sen reunan. Koko näytön ikkuna piilottaa sen kokonaan. Vedä sovelluspainiketta kohti näytön toista reunaa siirtääksesi telakan sinne. Napsauta sitä hiiren kakkospainikkeella saadaksesi _Sijainti_-vaihtoehdon reunan valitsemiseen ja _Asettelu_-vaihtoehdon oletusasettelun asettamiseen samoin kuin _Ulkoasu > Työtilan asettelu_ tekee. Sijainti on myös kohdassa _Ulkoasu > Telakka > Telakan sijainti_, ja `omarchy dock position left` asettaa sen päätteestä. Telakassa pitämäsi sovellukset ovat haalenneita, kun ne eivät ole käynnissä. Pitääksesi telakan vain kelluvissa työtiloissa käytä kohtaa _Ulkoasu > Telakka > Telakka vain kelluvissa_ tai komentoa `omarchy dock tiling off`.

Uudet työtilat, ja kaikki, joille et ole antanut omaa asetteluaan näppäinyhdistelmällä `Super + L`, käyttävät oletusasettelua. Oletuksen muuttaminen palauttaa jokaisen ikkunattoman työtilan siihen, kun taas ikkunoita sisältävä työtila säilyttää nykyisen asettelunsa. Telakkaan pienennetty ikkuna lasketaan edelleen ikkunaksi työtilalla, jolta se lähti. Valitse se kohdasta _Ulkoasu > Työtilan asettelu_: Laatoitus, Vierivä tai Kelluva. `omarchy hyprland workspace layout default scrolling` asettaa sen päätteestä.

### Ikkunoiden ryhmittely

Ikkunoita voi ryhmitellä näppäinyhdistelmällä `Super + G`. Kun olet ryhmässä, jokainen sen ollessa aktiivisena käynnistämäsi ikkuna kuuluu ryhmään. Voit siirtyä näiden ryhmiteltyjen ikkunoiden välillä näppäinyhdistelmällä `Super + Ctrl + Arrow Left/Right` tai näppäinyhdistelmällä `Super + Alt + 1/2/3/4` siirtyäksesi suoraan ryhmiteltyihin ikkunoihin järjestyksessä.

Voit siirtää ikkunan pois ryhmittelystä näppäinyhdistelmällä `Super + Alt + G` tai purkaa koko ryhmän painamalla `Super + G` uudelleen. Lopuksi voit siirtää ryhmän ulkopuolisia ikkunoita siihen näppäinyhdistelmällä `Super + Alt + Arrows`.

### Ikkunoiden ponnauttaminen ulos

Voit ponnauttaa ikkunan ulos työtilavarauksestaan näppäinyhdistelmällä `Super + O`. Se kiinnittää sen kelluvaksi ikkunaksi, joka seuraa sinua mille tahansa työtilalle siirrytkin. Loistava videosoittimille ja vastaaville.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-työtila

On olemassa erityinen täysikokoinen scratchpad-työtila, joka asettuu päällekkäin minkä tahansa työtilan kanssa, jolla parhaillaan olet. Pääset sen sisältöön näppäinyhdistelmällä `Super + S`, ja sijoitat ikkunoita sinne näppäinyhdistelmällä `Super + Alt + S`.

Se toimii hyvin säätimille tai päätteelle, jonka kanssa haluat toimia nopeasti poistumatta nykyiseltä työtilalta.

### Quake-konsoli

Lopuksi on olemassa puolikkaan korkeuden Quake-konsoli, joka putoaa alas minkä tahansa työtilan päälle, jolla parhaillaan olet. Vaihda se näppäinyhdistelmällä `Super + the key above Tab` (US-asetteluissa grave), ja sijoita ikkuna sinne näppäinyhdistelmällä `Super + Shift + the key above Tab`.

Ensimmäisellä avauskerralla se käynnistää oletusagenttisi tai pyytää sinua valitsemaan sellaisen, jos et ole vielä valinnut. Kun konsolissa on vain yksi ikkuna, se putoaa alas keskitettynä paneelina sen sijaan, että se ulottuisi koko näytön leveydelle. Laita sinne toinen sovellus, niin se palaa täyteen leveyteen, jotta niillä kahdella on tilaa olla vierekkäin.

Siirtääksesi ikkunan pois joko scratchpadista tai konsolista, lähetä se suoraan toiselle työtilalle esimerkiksi näppäinyhdistelmällä `Super + Shift + 1`.

### Tähän tottuminen vie hetken!

Kestää hetken tottua työpöydälläsi navigointiin tällä tavalla, mutta kun tottut, on vaikea palata perinteiseen hiirivetoiseen työpöytäkokemukseen!
