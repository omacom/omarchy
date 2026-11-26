# Navigointi

Kaikki Omarchyssa tapahtuu näppäimistöllä — _KAIKKI!_ Kun järjestelmä käynnistyy ensimmäisen kerran, et kirjaimellisesti saa mitään tehtyä pelkällä hiirellä. Mutta voit painaa `Super + Space` paljastaaksesi Omarchy-valikon, ja täältä voit tehdä lähes kaiken.

Omarchy-valikkoa ei kuitenkaan ole edes tarkoitettu järjestelmän pääasialliseksi käyttötavaksi suurimman osan ajasta. Pääsemme sitä nopeammaksi! Kaikki tärkeimmät sovellukset on sidottu suoraan yksittäisiin pikanäppäimiin. Käynnistät päätteen näppäimillä `Super + Return` ja selaimen näppäimillä `Super + Shift + Return`. Kokeile tehdä toinen toisensa jälkeen, niin näet Hyprlandin laatoituksen taian toiminnassa:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Sitten voit painaa `Super + J` pinotaksesi ne päällekkäin vierekkäisyyden sijaan:

 ![navigation-stacked](images/navigation-stacked.webp)

Paina `Super + J` uudelleen palauttaaksesi ne vierekkäisiin asemiinsa. Kokeile sitten selaimessa ollessasi `Super + Shift + Arrow Right` vaihtaaksesi ikkunat keskenään.

Kokeile nyt `Super + Shift + T` käynnistääksesi Activity-monitorin. Se ilmestyy kelluvana ikkunana. Voit laatoittaa sen näppäimillä `Super + T` (ja painaa sitä uudelleen tehdäksesi siitä taas kelluvan). Paina nyt `Super + Shift + F` avataksesi tiedostonhallinnan. Saat siistin neljän ikkunan kokoonpanon:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navigoit aktiiviseksi haluamasi ikkunan välillä näppäimillä `Super + Arrow`. Tämä vaihtaa kohdistuksen ja siirtää kohdistimen uuden sovelluksen keskelle. Näytön reunalla se jatkaa sillä puolella olevalle näytölle.

Jos painat `Super + Shift + 2`, siirrät parhaillaan kohdistetun sovelluksen toiselle työtilalle. `Super + Shift + 1` siirtää sen takaisin. (Ja `Super + Shift + Alt + 2` siirtää parhaillaan kohdistetun sovelluksen toiselle työtilalle vaihtamatta sille).

Useammalla kuin yhdellä näytöllä jokaisella näytöllä on omat työtilansa 1–10. `Super + 2` siirtyy käyttämäsi näytön toiselle työtilalle, ja jokaisen näytön yläpalkki näyttää sen omat työtilat ja sen, jota se parhaillaan näyttää. `Super + Tab` kierrättää käyttämäsi näytön työtiloja. `Super + Shift + Ctrl + Arrows` siirtää käyttämäsi ikkunan siihen suuntaan olevalle näytölle, sen näyttämälle työtilalle, ja `Super + Shift + Alt + Arrows` siirtää käyttämäsi työtilan siihen suuntaan olevalle näytölle, jossa se saa saman numeron, jos se on vapaana. Näyttö säilyttää työtilansa, kun irrotat sen: ne liittyvät toisen näytön työtiloihin numeroituina sen jo olemassa olevien työtilojen jälkeen ja palaavat vanhojen numerojensa alle, kun näyttö palaa.

Jos pidät `Super`-näppäintä painettuna ja napsautat ikkunaa hiirellä, voit järjestellä sen sijainnin uudelleen. Jos pidät `Super`-näppäintä painettuna ja käytät hiiren oikeaa painiketta, voit muuttaa ikkunan kokoa vapaasti.

Suljet ikkunan näppäimillä `Super + W` tai `Super + Q` (ja suljet kaikki ikkunat näppäimillä `Ctrl + Alt + Delete`).

Voit myös siirtyä koko näytölle näppäimillä `Super + F`, pelkkään täyteen leveyteen (yläpalkki säilyttäen) näppäimillä `Super + Alt + F` tai koko näytölle ikkunan sisällä näppäimillä `Super + Ctrl + F` (hyvä YouTubelle!).

### Dwindle vastaan vieritysasettelu

Omarchyn oletusasettelua kutsutaan nimellä dwindle. Se pitää kaikki yhdelle työtilalle avaamasi ikkunat näkyvissä koko ajan, vaikka sen pitäisi kutistaa niitä.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mutta voit myös valita työtilan muuttamisen vieritysasetteluksi, jossa ikkunat rivittyvät vierekkäin näytön näkyvän reunan ulkopuolelle. Muutat yksittäisen työtilan tähän asetteluun näppäimillä `Super + L`.

`Super + L` -näppäinten painaminen uudelleen muuttaa työtilan kelluvaksi, jossa ikkunat menevät vapaasti päällekkäin ja sijoitat ne itse, ja kolmas painallus palauttaa sen dwindleen. `Super + Alt + L` käy ne läpi toiseen suuntaan. Ikkuna, joka kelluu muutenkin — sellainen, jonka irrotit näppäimillä `Super + T`, tai sovellus, joka avautuu aina kelluvana — pysyy kelluvana, kun työtila palaa laatoitukseen. Yläpalkki merkitsee käyttämäsi työtilan sen asettelulla: neliö dwindlelle, ympyrä vieritykselle ja kolmio kelluvalle. Myös tuon merkin napsauttaminen kierrättää asettelua, ja niin tekee myös näyttönäppäin kannettavissa, joissa sellainen on.

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

Kelluva työtila toimii kuin perinteinen työpöytä: ikkunat menevät päällekkäin, ja siirrät ja kokoat ne itse. Jokainen ikkuna saa teemasi väreissä olevan otsikkopalkin, jossa on painikkeet pienentämiseen, suurentamiseen ja sulkemiseen. Myös `Super + M` pienentää kohdistetun ikkunan. Pienennetty ikkuna odottaa telakassa; napsauta sen sovellusta tuodaksesi sen takaisin. Napsauta ikkunaa tuodaksesi sen eteen. Muuta sen kokoa mistä tahansa reunasta tai kulmasta. Kaksoisnapsauta otsikkopalkkia suurentaaksesi ikkunan pitäen yläpalkin näkyvissä, ja uudelleen saadaksesi sen vanhan koon takaisin. Chrome ja muut Chromium-pohjaiset selaimet, Disks ja Document Viewer ohittavat otsikkopalkin ja käyttävät sen sijaan omaa ylätunnistettaan; `Super + Alt + F` suurentaa ne, ja `Super + M` pienentää ne.

Kelluva työtila näyttää myös telakan, jossa ovat kiinnittämäsi sovellukset, kaikki käynnissä oleva ja ruudukko jokaisesta sovelluksesta sovelluspainikkeen takana, jonka myös `Super + Alt + Space` ja Omarchy-valikon _Apps_ avaavat. Napsauta sovellusta ruudukossa hiiren oikealla painikkeella tai paina `Delete` poistaaksesi sen asennuksen. Napsauta sovellusta avataksesi sen tai tuodaksesi sen ikkunan eteen; napsauta uudelleen kierrättääksesi sen ikkunoiden läpi. Files tuo takaisin ikkunan vain käyttämältäsi työtilalta ja avaa muuten uuden, ja Terminal ja Agent käynnistävät aina uuden, vaikka pienennetty ikkuna palaa ensin. Keskipainikkeen napsautus avaa uuden ikkunan. Vedä kuvaketta telakkaa pitkin siirtääksesi sitä; käynnissä olevan sovelluksen vetäminen muiden joukkoon pitää sen siellä. Napsauta hiiren oikealla painikkeella pitääksesi sovelluksen telakassa, poistaaksesi sen sieltä tai lopettaaksesi sen. Telakka väistyy koko näytön ikkunan tieltä. Napsauta sovelluspainiketta hiiren oikealla painikkeella siirtääksesi telakan toiselle reunalle tai piilottaaksesi sen, kunnes osoitin saavuttaa sen reunan. Sijainti on myös kohdassa _Appearance > Dock > Dock Position_, ja `omarchy dock position left` ja `omarchy dock autohide on` asettavat molemmat päätteestä. Telakassa pitämäsi sovellukset ovat haalistuneita, kun ne eivät ole käynnissä.

Uudet työtilat ja kaikki, joille et ole antanut omaa asetteluaan näppäimillä `Super + L`, käyttävät oletusasettelua. Oletuksen muuttaminen palauttaa jokaisen ikkunattoman työtilan siihen, kun taas työtila, jossa on ikkunoita, säilyttää nykyisen asettelunsa. Telakkaan pienennetty ikkuna lasketaan edelleen ikkunaksi työtilalla, jolta se lähti. Valitse se kohdassa _Appearance > Workspace Layout_: Tiling, Scrolling tai Floating. `omarchy hyprland workspace layout default scrolling` asettaa sen päätteestä.

### Ikkunoiden ryhmittely

Ikkunoita voidaan ryhmitellä näppäimillä `Super + G`. Kun olet ryhmässä, jokainen sen ollessa aktiivisena käynnistämäsi ikkuna kuuluu ryhmään. Voit siirtyä näiden ryhmiteltyjen ikkunoiden välillä näppäimillä `Super + Ctrl + Arrow Left/Right` tai `Super + Alt + 1/2/3/4` siirtyäksesi suoraan ryhmiteltyihin ikkunoihin järjestyksessä.

Voit siirtää ikkunan pois ryhmittelystä näppäimillä `Super + Alt + G` tai purkaa koko ryhmän painamalla `Super + G` uudelleen. Lopuksi voit siirtää ryhmän ulkopuolisia ikkunoita siihen näppäimillä `Super + Alt + Arrows`.

### Ikkunoiden irrottaminen

Voit irrottaa ikkunan sen työtila-allokaatiosta näppäimillä `Super + O`. Se kiinnittää sen kelluvaksi ikkunaksi, joka seuraa sinua mille tahansa työtilalle siirrytkin. Loistavaa videosoittimille ja vastaaville.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-työtila

On erityinen täysikokoinen scratchpad-työtila, joka asettuu päällekkäin parhaillaan käyttämäsi työtilan kanssa. Pääset sen sisältöön näppäimillä `Super + S`, ja sijoitat sinne ikkunoita näppäimillä `Super + Alt + S`.

Se toimii hyvin säätimille tai päätteelle, jonka kanssa haluat toimia nopeasti poistumatta nykyiseltä työtilalta.

### Quake-konsoli

Lopuksi on puolikkaan korkeuden Quake-konsoli, joka putoaa alas parhaillaan käyttämäsi työtilan päälle. Vaihda se näppäimillä `Super + the key above Tab` (aksenttinäppäin yhdysvaltalaisissa asetteluissa) ja sijoita sinne ikkuna näppäimillä `Super + Shift + the key above Tab`.

Ensimmäisellä avauskerralla se käynnistää oletusagenttisi tai pyytää sinua valitsemaan sellaisen, jos et ole vielä valinnut. Kun konsolissa on yksi ikkuna, se putoaa alas keskitettynä paneelina sen sijaan, että se ulottuisi koko näytölle. Laita sille toinen sovellus, niin se palaa täyteen leveyteen, jotta kahdella on tilaa istua vierekkäin.

Siirtääksesi ikkunan pois joko scratchpadista tai konsolista, lähetä se suoraan toiselle työtilalle esimerkiksi näppäimillä `Super + Shift + 1`.

### Tähän totuttelu vie aikansa!

Kestää jonkin aikaa tottua navigoimaan työpöydälläsi näin, mutta kun tottut, on vaikea palata perinteiseen hiirivetoiseen työpöytäkokemukseen!
