# Navigointi

Kaikki Omarchyssa tapahtuu näppäimistöllä — _KAIKKI!_ Kun järjestelmä käynnistyy ensimmäisen kerran, et kirjaimellisesti voi tehdä mitään pelkällä hiirellä. Mutta voit painaa `Super + Space` tuodaksesi esiin Omarchy-valikon, ja sieltä voit tehdä melkein kaiken.

Mutta Omarchy-valikkoa ei ole edes tarkoitettu järjestelmän pääasialliseksi käyttötavaksi suurimman osan ajasta. Pääsemme sitä nopeammaksi! Kaikki tärkeimmät sovellukset on sidottu suoraan yksittäisiin pikanäppäimiin. Käynnistät päätteen näppäimillä `Super + Return` ja selaimen näppäimillä `Super + Shift + Return`. Kokeile tehdä toinen toisensa jälkeen, niin näet Hyprlandin laatoituksen taian toiminnassa:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Voit sitten painaa `Super + J` pinotaksesi ne päällekkäin vierekkäisyyden sijaan:

 ![navigation-stacked](images/navigation-stacked.webp)

Paina `Super + J` uudelleen palauttaaksesi ne vierekkäisiin asentoihinsa. Kokeile sitten `Super + Shift + Arrow Right` selaimessa ollessasi vaihtaaksesi ikkunat keskenään.

Kokeile nyt `Super + Shift + T` käynnistääksesi Activity-valvonnan. Se ilmestyy kelluvana ikkunana. Voit laatoittaa sen käyttämällä `Super + T` (ja painaa sitä uudelleen tehdäksesi siitä taas kelluvan). Paina nyt `Super + Shift + F` avataksesi tiedostonhallinnan. Saat siistin neljän ikkunan asetelman:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navigoit sen ikkunan välillä, jonka haluat olevan aktiivinen, näppäimillä `Super + Arrow`. Tämä vaihtaa kohdistuksen ja siirtää kohdistimen uuden sovelluksen keskelle. Näytön reunalla se jatkaa sillä puolella olevalle näytölle.

Jos painat `Super + Shift + 2`, siirrät parhaillaan kohdistetun sovelluksen toiselle työtilalle. `Super + Shift + 1` siirtää sen takaisin. (Ja `Super + Shift + Alt + 2` siirtää parhaillaan kohdistetun sovelluksen toiselle työtilalle vaihtamatta siihen).

Kun näyttöjä on useampi kuin yksi, jokaisella näytöllä on omat työtilansa 1–10. `Super + 2` siirtyy sillä näytöllä, jolla olet, olevaan toiseen työtilaan, ja jokaisen näytön yläpalkki näyttää sen omat työtilat ja sen, jota se parhaillaan näyttää. `Super + Tab` selaa sillä näytöllä, jolla olet, olevia työtiloja. `Super + Shift + Ctrl + Arrows` siirtää ikkunan, jolla olet, siihen suuntaan olevalle näytölle, sen näyttämälle työtilalle, ja `Super + Shift + Alt + Arrows` siirtää työtilan, jolla olet, siihen suuntaan olevalle näytölle, jossa se saa saman numeron, jos se on vapaana. Näyttö pitää työtilansa, kun irrotat sen: ne liittyvät toisen näytön työtiloihin, numeroituina sen jo olemassa olevien jälkeen, ja palaavat vanhoilla numeroillaan, kun näyttö palaa.

Jos pidät `Super`-näppäintä painettuna ja napsautat ikkunaa hiirellä, voit järjestellä uudelleen, missä se sijaitsee. Jos pidät `Super`-näppäintä painettuna ja käytät hiiren oikeaa painiketta, voit vapaasti muuttaa ikkunan kokoa.

Suljet ikkunan näppäimillä `Super + W` tai `Super + Q` (ja suljet kaikki ikkunat näppäimillä `Ctrl + Alt + Delete`).

Voit myös siirtyä koko näytön tilaan näppäimillä `Super + F` tai jopa vain koko leveydelle (yläpalkki säilyttäen) näppäimillä `Super + Alt + F` tai koko näytön tilaan ikkunan sisällä näppäimillä `Super + Ctrl + F` (hyvä YouTubelle!).

### Dwindle- ja scrolling-asettelu

Omarchyn oletusasettelun nimi on dwindle. Se pitää kaikki yhdelle työtilalle avaamasi ikkunat näkyvissä koko ajan, vaikka sen pitäisi kutistaa niitä.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mutta voit myös valita muuttaa työtilan scrolling-asetteluksi, jossa ikkunat on rivitetty vierekkäin näytön näkyvän reunan ulkopuolelle. Muutat yksittäisen työtilan tähän asetteluun näppäimillä `Super + L`.

`Super + L` -näppäinten painaminen uudelleen muuttaa työtilan kelluvaksi, jossa ikkunat menevät vapaasti päällekkäin ja sijoitat ne itse, ja kolmas painallus palauttaa sen dwindle-asetteluun. `Super + Alt + L` käy ne läpi toiseen suuntaan. Ikkuna, joka kelluu muutenkin — sellainen, jonka irrotit näppäimillä `Super + T`, tai sovellus, joka avautuu aina kelluvana — pysyy kelluvana, kun työtila palaa laatoitukseen. Yläpalkki merkitsee työtilan, jolla olet, sen asettelulla: neliö dwindlelle, ympyrä scrollingille ja kolmio kelluvalle. Sen merkin napsauttaminen selaa myös asettelua.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valinta on työtilakohtainen, ja se säilyy. Voit siis pitää työtilan 1 dwindlessa selaamista varten ja työtilan 2 scrollingissa koodia varten, ja ne palaavat sellaisina uudelleenkäynnistyksen jälkeen.

Jos haluat käyttää scrolling-asettelua oletuksena, voit asettaa sen tiedostossa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Kelluvat työtilat

Kelluva työtila toimii kuin perinteinen työpöytä: ikkunat menevät päällekkäin, ja siirrät ja mitoitat ne itse. Jokainen ikkuna saa teemasi väreissä olevan otsikkopalkin, jossa on painikkeet pienentämiseen, suurentamiseen ja sulkemiseen. `Super + M` pienentää myös kohdistetun ikkunan. Pienennetty ikkuna odottaa telakassa; napsauta sen sovellusta tuodaksesi sen takaisin. Napsauta ikkunaa tuodaksesi sen eteen. Muuta sen kokoa mistä tahansa reunasta tai kulmasta. Kaksoisnapsauta otsikkopalkkia suurentaaksesi ikkunan pitäen samalla yläpalkin näkyvissä, ja uudelleen saadaksesi sen vanhan koon takaisin. Chrome ja muut Chromium-pohjaiset selaimet, Disks ja Document Viewer ohittavat otsikkopalkin ja käyttävät sen sijaan omaa otsikkoaan; `Super + Alt + F` suurentaa ne, ja `Super + M` pienentää ne.

Kelluva työtila näyttää myös telakan, jossa ovat kiinnittämäsi sovellukset, kaikki käynnissä olevat ja ruudukko kaikista sovelluksista sovelluspainikkeen takana, jonka myös `Super + Alt + Space` ja Omarchy-valikon _Apps_ avaavat. Napsauta sovellusta ruudukossa hiiren oikealla painikkeella tai paina `Delete` poistaaksesi sen asennuksen. Napsauta sovellusta avataksesi sen tai tuodaksesi sen ikkunan eteen; napsauta uudelleen selataksesi sen ikkunoita. Keskipainikkeen napsautus avaa uuden ikkunan. Vedä kuvaketta telakkaa pitkin siirtääksesi sitä; käynnissä olevan sovelluksen vetäminen muiden joukkoon pitää sen siellä. Napsauta hiiren oikealla painikkeella pitääksesi sovelluksen telakassa, poistaaksesi sen sieltä tai lopettaaksesi sen. Telakka väistyy koko näytön ikkunan tieltä. Napsauta sovelluspainiketta hiiren oikealla painikkeella siirtääksesi telakan toiseen reunaan tai laittaaksesi sen piiloutumaan, kunnes osoitin saavuttaa sen reunan. Sijainti on myös kohdassa _Appearance > Dock > Dock Position_, ja `omarchy dock position left` ja `omarchy dock autohide on` asettavat molemmat päätteestä. Sovellukset, jotka pidät telakassa, näkyvät haalistuneina, kun ne eivät ole käynnissä.

Uudet työtilat ja kaikki, joille et ole antanut omaa asetteluaan näppäimillä `Super + L`, käyttävät oletusasettelua. Oletuksen muuttaminen palauttaa jokaisen ikkunattoman työtilan siihen, kun taas työtila, jolla on ikkunoita, säilyttää asettelunsa. Telakkaan pienennetty ikkuna lasketaan edelleen ikkunaksi työtilalla, jolta se lähti. Valitse se kohdasta _Appearance > Workspace Layout_: Tiling, Scrolling tai Floating. `omarchy-hyprland-workspace-layout-default scrolling` asettaa sen päätteestä.

### Ikkunoiden ryhmittely

Ikkunoita voidaan ryhmitellä näppäimillä `Super + G`. Kun olet ryhmässä, jokainen ikkuna, jonka käynnistät sen ollessa aktiivinen, kuuluu ryhmään. Voit siirtyä näiden ryhmiteltyjen ikkunoiden välillä näppäimillä `Super + Ctrl + Arrow Left/Right` tai `Super + Alt + 1/2/3/4` siirtyäksesi suoraan ryhmiteltyihin ikkunoihin järjestyksessä.

Voit siirtää ikkunan ulos ryhmittelystä näppäimillä `Super + Alt + G` tai purkaa koko ryhmän painamalla `Super + G` uudelleen. Lopuksi voit siirtää ryhmän ulkopuolella olevia ikkunoita siihen näppäimillä `Super + Alt + Arrows`.

### Ikkunoiden irrottaminen

Voit irrottaa ikkunan sen työtilavarauksesta näppäimillä `Super + O`. Se kiinnittää sen kelluvana ikkunana, joka seuraa sinua mille tahansa työtilalle siirrytkin. Loistava videosoittimille ja vastaaville.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-työtila

On olemassa erityinen täysikokoinen scratchpad-työtila, joka asettuu päällekkäin sen työtilan kanssa, jolla parhaillaan olet. Pääset sen sisältöön näppäimillä `Super + S`, ja sijoitat ikkunoita sinne näppäimillä `Super + Alt + S`.

Se toimii hyvin säätimille tai päätteelle, jonka kanssa haluat toimia nopeasti poistumatta nykyiseltä työtilalta.

### Quake-konsoli

Lopuksi on puolen korkeuden Quake-konsoli, joka laskeutuu alas sen työtilan päälle, jolla parhaillaan olet. Vaihda sitä näppäimillä `Super + Grave`, ja sijoita ikkuna sinne näppäimillä `Super + Shift + Grave`.

Se avautuu oletusagenttisi käyttövalmiina. Kun konsolissa on yksi ikkuna, se laskeutuu keskitettynä paneelina sen sijaan, että ulottuisi koko näytön levyiseksi. Laita sille toinen sovellus, niin se palaa täyteen leveyteen, jotta niillä kahdella on tilaa olla vierekkäin.

Siirtääksesi ikkunan pois joko scratchpadista tai konsolista, lähetä se suoraan toiselle työtilalle esimerkiksi näppäimillä `Super + Shift + 1`.

### Siihen tottuminen vie aikansa!

Kestää hetken tottua työpöydälläsi navigointiin tällä tavalla, mutta kun tottut, on vaikea palata perinteiseen hiirivetoiseen työpöytäkokemukseen!
