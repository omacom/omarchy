# Navigointi

Kaikki Omarchyssa tapahtuu näppäimistöllä — _KAIKKI!_ Kun järjestelmä käynnistyy ensimmäisen kerran, et kirjaimellisesti voi tehdä yhtään mitään pelkällä hiirellä. Mutta voit painaa `Super + Space` tuodaksesi esiin Omarchy-valikon, ja täältä voit tehdä melkein kaiken.

Mutta Omarchy-valikkoa ei ole edes tarkoitettu olemaan pääasiallinen tapa käyttää järjestelmää suurimman osan ajasta. Pystymme nopeampaan kuin se! Kaikki tärkeimmät sovellukset on sidottu suoraan yksittäisiin pikanäppäimiin. Käynnistät päätteen näppäimillä `Super + Return` ja selaimen näppäimillä `Super + Shift + Return`. Kokeile tehdä se peräkkäin, niin näet Hyprlandin laatoituksen taian toiminnassa:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Voit sitten painaa `Super + J` pinotaksesi ne päällekkäin vierekkäisyyden sijaan:

 ![navigation-stacked](images/navigation-stacked.webp)

Paina `Super + J` uudelleen palauttaaksesi ne vierekkäisiin asentoihinsa. Kokeile sitten `Super + Shift + Arrow Right`, kun selain on aktiivinen, vaihtaaksesi ikkunat keskenään.

Kokeile nyt `Super + Shift + T` käynnistääksesi Toimintamonitorin. Se ilmestyy kelluvana ikkunana. Voit laatoittaa sen käyttämällä `Super + T` (ja painaa sitä uudelleen tehdäksesi siitä taas kelluvan). Paina nyt `Super + Shift + F` avataksesi tiedostonhallinnan. Sinulla on siisti neljän ikkunan asettelu:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navigoit aktiiviseksi haluamasi ikkunan välillä näppäimillä `Super + Arrow`. Tämä vaihtaa fokuksen ja siirtää kohdistimen uuden sovelluksen keskelle. Näytön reunalla se jatkaa sillä puolella olevalle näytölle.

Jos painat `Super + Shift + 2`, siirrät parhaillaan fokuksessa olevan sovelluksen toiselle työtilalle. `Super + Shift + 1` siirtää sen takaisin. (Ja `Super + Shift + Alt + 2` siirtää parhaillaan fokuksessa olevan sovelluksen toiselle työtilalle vaihtamatta sille.)

Useamman kuin yhden näytön kanssa jokaisella näytöllä on omat työtilansa 1–10. `Super + 2` siirtyy käyttämäsi näytön toiselle työtilalle, ja jokaisen näytön yläpalkki näyttää sen omat työtilat ja sen, jota se parhaillaan näyttää. `Super + Tab` selaa käyttämäsi näytön työtiloja. `Super + Shift + Ctrl + Arrows` siirtää käyttämäsi ikkunan kyseisessä suunnassa olevalle näytölle, sen näyttämälle työtilalle, ja `Super + Shift + Alt + Arrows` siirtää käyttämäsi työtilan kyseisessä suunnassa olevalle näytölle, jossa se saa saman numeron, jos se on vapaana. Näyttö pitää työtilansa, kun irrotat sen: ne liittyvät toisen näytön työtiloihin numeroituna sen jo olemassa olevien jälkeen ja palaavat vanhojen numeroidensa alle, kun näyttö palaa.

Jos pidät `Super`-näppäintä painettuna ja napsautat ikkunaa hiirellä, voit järjestää uudelleen, missä se sijaitsee. Jos pidät `Super`-näppäintä painettuna ja käytät hiiren oikeaa painiketta, voit vapaasti muuttaa ikkunan kokoa.

Suljet ikkunan näppäimillä `Super + W` tai `Super + Q` (ja suljet kaikki ikkunat näppäimillä `Ctrl + Alt + Delete`).

Voit myös siirtyä koko näytön tilaan näppäimillä `Super + F` tai jopa vain koko leveydelle (yläpalkki säilyttäen) näppäimillä `Super + Alt + F` tai koko näytön tilaan ikkunan sisällä näppäimillä `Super + Ctrl + F` (hyvä YouTubelle!).

### Dwindle vs. vieritysasettelu

Omarchyn oletusasettelu on nimeltään dwindle. Se pitää kaikki yhdelle työtilalle avaamasi ikkunat näkyvissä kaiken aikaa, vaikka se joutuisi kutistamaan ne pieniksi.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mutta voit myös päättää muuttaa työtilan vieritysasetteluksi, jossa ikkunat on aseteltu vierekkäin näytön näkyvän reunan ulkopuolelle. Muutat yksittäisen työtilan tähän asetteluun näppäimillä `Super + L`.

`Super + L` -näppäinten painaminen uudelleen muuttaa työtilan kelluvaksi, jossa ikkunat limittyvät vapaasti ja sijoitat ne itse, ja kolmas painallus palauttaa sen dwindleen. `Super + Alt + L` käy ne läpi toiseen suuntaan. Ikkuna, joka kelluu joka tapauksessa — sellainen, jonka irrotit näppäimillä `Super + T`, tai sovellus, joka avautuu aina kelluvana — pysyy kelluvana, kun työtila palaa laatoitukseen. Yläpalkki merkitsee käyttämäsi työtilan sen asettelulla: neliö dwindlelle, ympyrä vieritykselle ja kolmio kelluvalle. Myös kyseisen merkin napsauttaminen selaa asettelua.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valinta on työtilakohtainen, ja se pysyy. Voit siis pitää työtilan 1 dwindlessä selaamista varten ja työtilan 2 vierityksessä koodia varten, ja ne palaavat sellaisina uudelleenkäynnistyksen jälkeen.

Jos haluat käyttää vieritysasettelua oletuksena, voit asettaa sen tiedostossa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Kelluvat työtilat

Kelluva työtila toimii kuin perinteinen työpöytä: ikkunat limittyvät, ja siirrät niitä ja muutat niiden kokoa itse. Jokainen ikkuna saa otsikkopalkin teemasi väreissä, painikkeilla pienentämistä, suurentamista ja sulkemista varten. `Super + M` pienentää myös fokuksessa olevan ikkunan. Pienennetty ikkuna odottaa telakassa; napsauta sen sovellusta tuodaksesi sen takaisin. Napsauta ikkunaa tuodaksesi sen eteen. Muuta sen kokoa mistä tahansa reunasta tai kulmasta. Kaksoisnapsauta otsikkopalkkia suurentaaksesi ikkunan pitäen samalla yläpalkin näkyvissä, ja uudelleen saadaksesi sen vanhan koon takaisin.

Kelluva työtila näyttää myös telakan, jossa ovat kiinnittämäsi sovellukset, kaikki käynnissä olevat sekä ruudukko jokaisesta sovelluksesta sovelluspainikkeen takana, jonka myös `Super + Alt + Space` ja _Apps_ Omarchy-valikossa avaavat. Napsauta sovellusta ruudukossa hiiren oikealla painikkeella tai paina `Delete` poistaaksesi sen asennuksen. Napsauta sovellusta avataksesi sen tai tuodaksesi sen ikkunan eteen; napsauta uudelleen selataksesi sen ikkunoita. Keskinapsautus avaa uuden ikkunan. Vedä kuvaketta telakkaa pitkin siirtääksesi sitä; käynnissä olevan sovelluksen vetäminen muiden joukkoon pitää sen siellä. Napsauta hiiren oikealla painikkeella pitääksesi sovelluksen telakassa, ottaaksesi sen pois tai lopettaaksesi sen. Telakka väistyy koko näytön ikkunan tieltä. Napsauta sovelluspainiketta hiiren oikealla painikkeella siirtääksesi telakan toiselle reunalle tai saadaksesi sen piiloutumaan, kunnes osoitin saavuttaa sen reunan. Sijainti on myös kohdassa _Appearance > Dock > Dock Position_, ja `omarchy dock position left` ja `omarchy dock autohide on` asettavat molemmat päätteestä. Sovellukset, jotka pidät telakassa, näkyvät haalistuneina, kun ne eivät ole käynnissä.

Uudet työtilat, ja kaikki, joille et ole antanut omaa asetteluaan näppäimillä `Super + L`, käyttävät oletusasettelua. Oletuksen muuttaminen palauttaa jokaisen ikkunattoman työtilan siihen, kun taas työtila, jossa on ikkunoita, säilyttää asettelunsa. Ikkuna, joka on pienennetty telakkaan, lasketaan edelleen ikkunaksi työtilalla, jolta se lähti. Valitse se kohdasta _Appearance > Workspace Layout_: Tiling, Scrolling tai Floating. `omarchy-hyprland-workspace-layout-default scrolling` asettaa sen päätteestä.

### Ikkunoiden ryhmittely

Ikkunoita voidaan ryhmitellä näppäimillä `Super + G`. Kun olet ryhmässä, jokainen ikkuna, jonka käynnistät sen ollessa aktiivinen, kuuluu ryhmään. Voit liikkua näiden ryhmiteltyjen ikkunoiden välillä näppäimillä `Super + Ctrl + Arrow Left/Right` tai `Super + Alt + 1/2/3/4` siirtyäksesi suoraan ryhmiteltyyn ikkunaan järjestyksessä.

Voit siirtää ikkunan pois ryhmittelystä näppäimillä `Super + Alt + G` tai purkaa koko ryhmän painamalla `Super + G` uudelleen. Lopuksi voit siirtää ryhmän ulkopuolisia ikkunoita siihen näppäimillä `Super + Alt + Arrows`.

### Ikkunoiden irrottaminen

Voit irrottaa ikkunan sen työtilavarauksesta näppäimillä `Super + O`. Se kiinnittää sen kelluvaksi ikkunaksi, joka seuraa sinua mille tahansa työtilalle siirrytkin. Loistava videosoittimille ja vastaaville.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-työtila

On olemassa erityinen täysikokoinen scratchpad-työtila, joka asettuu päällekkäin parhaillaan käyttämäsi työtilan kanssa. Pääset sen sisältöön näppäimillä `Super + S`, ja sijoitat ikkunoita sinne näppäimillä `Super + Alt + S`.

Se toimii hyvin säätimille tai päätteelle, jonka kanssa haluat toimia nopeasti poistumatta nykyiseltä työtilalta.

### Quake-konsoli

Lopuksi on puolen korkeuden Quake-konsoli, joka putoaa alas parhaillaan käyttämäsi työtilan päälle. Kytke se päälle ja pois näppäimillä `Super + Grave`, ja sijoita ikkuna sinne näppäimillä `Super + Shift + Grave`.

Se avautuu oletusagenttisi ollessa valmiina käyttöön. Kun konsolissa on yksi ainoa ikkuna, se putoaa alas keskitettynä paneelina sen sijaan, että se ulottuisi näytön poikki. Laita sille toinen sovellus, niin se palaa täyteen leveyteen, jotta kahdella on tilaa olla vierekkäin.

Siirtääksesi ikkunan pois joko scratchpadista tai konsolista, lähetä se suoraan toiselle työtilalle esimerkiksi näppäimillä `Super + Shift + 1`.

### Siihen tottuminen vie aikansa!

Tämänkalaiseen työpöydällä navigointiin tottuminen vie vähän aikaa, mutta kun totut, on vaikea palata perinteiseen hiirivetoiseen työpöytäkokemukseen!
