# Navigointi

Kaikki Omarchyssa tapahtuu näppäimistön kautta — _KAIKKI!_ Kun järjestelmä käynnistyy ensimmäisen kerran, et kirjaimellisesti voi tehdä mitään pelkällä hiirellä. Mutta voit painaa `Super + Space` paljastaaksesi Omarchy-valikon, ja täältä voit tehdä lähes kaiken.

Mutta Omarchy-valikon ei ole edes tarkoitus olla pääasiallinen tapa käyttää järjestelmää suurimman osan ajasta. Pääsemme sitä nopeammaksi! Kaikki tärkeimmät sovellukset on sidottu suoraan yksittäisiin pikanäppäimiin. Käynnistät päätteen näppäimillä `Super + Return` ja selaimen näppäimillä `Super + Shift + Return`. Kokeile tehdä toinen toisensa jälkeen, niin näet Hyprlandin laatoituksen taian toiminnassa:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Voit sitten painaa `Super + J` pinotaksesi ne päällekkäin vierekkäisyyden sijaan:

 ![navigation-stacked](images/navigation-stacked.webp)

Paina `Super + J` uudelleen palauttaaksesi ne vierekkäisiin asemiinsa. Kokeile sitten `Super + Shift + Arrow Right` selaimessa ollessasi vaihtaaksesi ikkunat keskenään.

Kokeile nyt `Super + Shift + T` käynnistääksesi Activity monitorin. Se ilmestyy kelluvana ikkunana. Voit laatoittaa sen käyttämällä `Super + T` (ja painaa sitä uudelleen tehdäksesi siitä taas kelluvan). Paina nyt `Super + Shift + F` avataksesi tiedostonhallinnan. Saat siistin neljän ikkunan kokoonpanon:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Siirryt sen ikkunan välillä, jonka haluat olevan aktiivinen, näppäimillä `Super + Arrow`. Tämä vaihtaa fokuksen ja siirtää kursorin uuden sovelluksen keskelle. Näytön reunalla se jatkaa sillä puolella olevalle monitorille.

Jos painat `Super + Shift + 2`, siirrät parhaillaan fokuksessa olevan sovelluksen toiselle työtilalle. `Super + Shift + 1` siirtää sen takaisin. (Ja `Super + Shift + Alt + 2` siirtää parhaillaan fokuksessa olevan sovelluksen toiselle työtilalle vaihtamatta siihen).

Useammalla kuin yhdellä monitorilla jokaisella monitorilla on omat työtilansa 1–10. `Super + 2` siirtyy sillä monitorilla, jolla olet, olevaan toiseen työtilaan, ja jokaisen monitorin yläpalkki näyttää sen omat työtilat ja sen, jota se parhaillaan näyttää. `Super + Tab` kierrättää sen monitorin työtilojen läpi, jolla olet. `Super + Shift + Ctrl + Arrows` siirtää ikkunan, jolla olet, siinä suunnassa olevalle monitorille, sen näyttämälle työtilalle, ja `Super + Shift + Alt + Arrows` siirtää työtilan, jolla olet, siinä suunnassa olevalle monitorille, jossa se saa saman numeron, jos se on vapaana. Monitori säilyttää työtilansa, kun irrotat sen: ne liittyvät toisen näytön työtiloihin, numeroituna sen jo olemassa olevien jälkeen, ja palaavat vanhoilla numeroillaan, kun monitori palaa.

Jos pidät `Super` pohjassa ja napsautat ikkunaa hiirellä, voit järjestellä uudelleen, missä se sijaitsee. Jos pidät `Super` pohjassa ja käytät hiiren oikeaa painiketta, voit vapaasti muuttaa ikkunan kokoa.

Suljet ikkunan näppäimillä `Super + W` tai `Super + Q` (ja suljet kaikki ikkunat näppäimillä `Ctrl + Alt + Delete`).

Voit myös siirtyä koko näytölle näppäimillä `Super + F` tai vaikka vain koko leveydelle (yläpalkki säilyttäen) näppäimillä `Super + Alt + F` tai koko näytölle ikkunan sisällä näppäimillä `Super + Ctrl + F` (hyvä YouTubelle!).

### Dwindle vs. vierivä asettelu

Omarchyn oletusasettelua kutsutaan nimellä dwindle. Se pitää kaikki yhdelle työtilalle avaamasi ikkunat näkyvissä kaikkina aikoina, vaikka sen täytyisi kutistaa niitä.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mutta voit myös valita muuttaa työtilan vieriväksi asetteluksi, jossa ikkunat on rivissä vierekkäin, näytön näkyvän reunan tuolle puolen. Muutat yksittäisen työtilan tähän asetteluun näppäimillä `Super + L`.

`Super + L` uudelleen painaminen tekee työtilasta kelluvan, jossa ikkunat menevät vapaasti päällekkäin ja sijoitat ne itse, ja kolmas painallus palauttaa sen dwindleen. `Super + Alt + L` käy ne läpi toiseen suuntaan. Ikkuna, joka kelluu joka tapauksessa — sellainen, jonka irrotit näppäimillä `Super + T`, tai sovellus, joka avautuu aina kelluvana — pysyy kelluvana, kun työtila palaa laatoitukseen. Yläpalkki merkitsee työtilan, jolla olet, sen asettelulla: neliö dwindlelle, ympyrä vierivälle ja kolmio kelluvalle. Sen merkin napsauttaminen kierrättää asettelua myös, ja samoin tekee näyttönäppäin kannettavissa, joissa sellainen on.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valinta on työtilakohtainen, ja se pysyy. Voit siis pitää työtilan 1 dwindlessä selaamista varten ja työtilan 2 vierivässä koodia varten, ja ne palaavat sellaisina uudelleenkäynnistyksen jälkeen.

Jos haluat käyttää vierivää asettelua oletuksena, voit asettaa sen tiedostossa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Kelluvat työtilat

Kelluva työtila toimii kuin perinteinen työpöytä: ikkunat menevät päällekkäin, ja siirrät ja mitoitat ne itse. Jokainen ikkuna saa otsikkopalkin teemasi väreissä, painikkeilla pienentämiseen, suurentamiseen ja sulkemiseen. `Super + M` pienentää myös fokuksessa olevan ikkunan. Pienennetty ikkuna odottaa telakassa; napsauta sen sovellusta tuodaksesi sen takaisin. Napsauta ikkunaa tuodaksesi sen eteen. Muuta sen kokoa mistä tahansa reunasta tai kulmasta. Kaksoisnapsauta otsikkopalkkia suurentaaksesi ikkunan pitäen samalla yläpalkin näkyvissä, ja uudelleen saadaksesi sen vanhan koon takaisin. Chrome ja muut Chromium-pohjaiset selaimet, Disks ja Document Viewer ohittavat otsikkopalkin ja käyttävät sen sijaan omaa otsakettaan; `Super + Alt + F` suurentaa ne, ja `Super + M` pienentää ne.

Kelluva työtila näyttää myös telakan, jossa ovat kiinnittämäsi sovellukset, kaikki käynnissä olevat, ja ruudukko jokaisesta sovelluksesta sovelluspainikkeen takana, jonka myös `Super + Alt + Space` ja Omarchy-valikon _Sovellukset_ avaavat. Napsauta sovellusta ruudukossa hiiren oikealla painikkeella, tai paina `Delete`, poistaaksesi sen asennuksen. Napsauta sovellusta avataksesi sen, tai tuodaksesi sen ikkunan eteen; napsauta uudelleen kierrättääksesi sen ikkunoiden läpi. Files tuo takaisin vain ikkunan työtilalta, jolla olet, ja avaa muuten uuden, ja Terminal ja Agent käynnistävät aina toisen, vaikka pienennetty ikkuna palaa ensin. Keskinapsautus avaa uuden ikkunan. Vedä kuvaketta telakkaa pitkin siirtääksesi sitä; käynnissä olevan sovelluksen vetäminen muiden joukkoon pitää sen siellä. Napsauta hiiren oikealla painikkeella pitääksesi sovelluksen telakassa, poistaaksesi sen sieltä tai lopettaaksesi sen. Telakka väistyy koko näytön ikkunan tieltä. Napsauta sovelluspainiketta hiiren oikealla painikkeella siirtääksesi telakan toiselle reunalle tai saadaksesi sen piiloutumaan, kunnes osoitin saavuttaa sen reunan. Sijainti on myös kohdassa _Ulkoasu > Dock > Dock Position_, ja `omarchy dock position left` ja `omarchy dock autohide on` asettavat molemmat päätteestä. Sovellukset, jotka pidät telakassa, ovat haalistuneita, kun ne eivät ole käynnissä.

Uudet työtilat, ja kaikki, joille et ole antanut omaa asetteluaan näppäimillä `Super + L`, käyttävät oletusasettelua. Oletuksen muuttaminen palauttaa jokaisen ikkunattoman työtilan siihen, kun taas sellainen, jolla on ikkunoita, säilyttää asettelun, joka sillä on. Telakkaan pienennetty ikkuna lasketaan edelleen ikkunaksi työtilalla, jolta se lähti. Valitse se kohdasta _Ulkoasu > Työtilan asettelu_: Laatoitus, Vierivä tai Kelluva. `omarchy hyprland workspace layout default scrolling` asettaa sen päätteestä.

### Ikkunoiden ryhmittely

Ikkunoita voidaan ryhmitellä käyttämällä `Super + G`. Kun olet ryhmässä, jokainen ikkuna, jonka käynnistät sen ollessa aktiivinen, kuuluu ryhmään. Voit siirtyä näiden ryhmiteltyjen ikkunoiden välillä käyttämällä `Super + Ctrl + Arrow Left/Right` tai `Super + Alt + 1/2/3/4` siirtyäksesi suoraan ryhmiteltyihin ikkunoihin järjestyksessä.

Voit siirtää ikkunan pois ryhmittelystä näppäimillä `Super + Alt + G` tai purkaa koko ryhmän painamalla `Super + G` uudelleen. Lopuksi voit siirtää ryhmän ulkopuolisia ikkunoita siihen näppäimillä `Super + Alt + Arrows`.

### Ikkunoiden irrottaminen

Voit irrottaa ikkunan sen työtilavarauksesta näppäimillä `Super + O`. Se kiinnittää sen kelluvaksi ikkunaksi, joka seuraa sinua mille tahansa työtilalle menetkin. Erinomainen videosoittimille ja vastaaville.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-työtila

On olemassa erityinen täysikokoinen scratchpad-työtila, joka asettuu sen työtilan päälle, jolla parhaillaan olet. Pääset sillä olevaan sisältöön käyttämällä `Super + S`, ja sijoitat ikkunoita sinne käyttämällä `Super + Alt + S`.

Se toimii hyvin säätimille tai päätteelle, jonka kanssa haluat toimia nopeasti poistumatta nykyiseltä työtilalta.

### Quake-konsoli

Lopuksi on puolikkaan korkeuden Quake-konsoli, joka putoaa alas sen työtilan päälle, jolla parhaillaan olet. Vaihda se päälle ja pois näppäimillä `Super + Grave`, ja sijoita ikkuna sinne käyttämällä `Super + Shift + Grave`.

Ensimmäisellä avauskerralla se käynnistää oletusagenttisi, tai pyytää sinua valitsemaan yhden, jos et ole vielä valinnut. Kun konsolissa on vain yksi ikkuna, se putoaa alas keskitettynä paneelina sen sijaan, että se ulottuisi näytön poikki. Laita sille toinen sovellus ja se palaa täyteen leveyteen, jotta kahdella on tilaa olla vierekkäin.

Siirtääksesi ikkunan pois joko scratchpadiltä tai konsolista, lähetä se suoraan toiselle työtilalle jollakin kuten `Super + Shift + 1`.

### Tähän tottuminen vie aikansa!

Kestää hetken tottua navigoimaan työpöydälläsi näin, mutta kun tottut, on vaikea palata perinteiseen hiirivetoiseen työpöytäkokemukseen!
