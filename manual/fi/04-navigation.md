# Navigointi

Kaikki Omarchyssa tapahtuu näppäimistön kautta — _KAIKKI!_ Kun järjestelmä käynnistyy ensimmäisen kerran, et kirjaimellisesti voi tehdä mitään pelkällä hiirellä. Mutta voit painaa `Super + Space` tuodaksesi Omarchy-valikon esiin, ja sieltä käsin voit tehdä lähes kaiken.

Mutta Omarchy-valikon ei ole edes tarkoitus olla pääasiallinen tapa käyttää järjestelmää suurimman osan ajasta. Pystymme nopeampaan! Kaikki tärkeimmät sovellukset on sidottu suoraan yksittäisiin pikanäppäimiin. Käynnistät päätteen näppäimillä `Super + Return` ja selaimen näppäimillä `Super + Shift + Return`. Kokeile tehdä ne peräkkäin, niin näet Hyprlandin laatoituksen taian toiminnassa:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Voit sitten painaa `Super + J` pinotaksesi ne päällekkäin sen sijaan, että ne olisivat vierekkäin:

 ![navigation-stacked](images/navigation-stacked.webp)

Paina `Super + J` uudelleen palauttaaksesi ne vierekkäisiin asentoihinsa. Kokeile sitten `Super + Shift + Arrow Right` ollessasi selaimella vaihtaaksesi ikkunat keskenään.

Kokeile nyt `Super + Ctrl + T` käynnistääksesi Activity-monitorin. Se ilmestyy kelluvana ikkunana. Voit laatoittaa sen näppäimillä `Super + T` (ja painaa sitä uudelleen tehdäksesi siitä taas kelluvan). Paina nyt `Super + Shift + F` avataksesi tiedostonhallinnan. Sinulla on siisti neljän ikkunan asetelma:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navigoit sen ikkunan välillä, jonka haluat olevan aktiivinen, näppäimillä `Super + Arrow`. Tämä vaihtaa fokuksen ja siirtää kursorin uuden sovelluksen keskelle.

Jos painat `Super + Shift + 2`, siirrät parhaillaan fokusoituna olevan sovelluksen toiselle työtilalle. `Super + Shift + 1` siirtää sen takaisin. (Ja `Super + Shift + Alt + 2` siirtää parhaillaan fokusoituna olevan sovelluksen toiselle työtilalle vaihtamatta siihen).

Jos pidät `Super`-näppäintä pohjassa ja klikkaat ikkunaa hiirellä, voit järjestellä uudelleen, missä se sijaitsee. Jos pidät `Super`-näppäintä pohjassa ja käytät hiiren oikeaa painiketta, voit muuttaa ikkunan kokoa vapaasti.

Suljet ikkunan näppäimillä `Super + W` tai `Super + Q` (ja suljet kaikki ikkunat näppäimillä `Ctrl + Alt + Delete`).

Voit myös siirtyä koko näyttöön näppäimillä `Super + F` tai jopa vain koko leveyteen (yläpalkin säilyttäen) näppäimillä `Super + Alt + F` tai koko näyttöön ikkunan sisällä näppäimillä `Super + Ctrl + F` (hyvä YouTubelle!).

### Dwindle vs vierittävä asettelu

Omarchyn oletusasettelun nimi on dwindle. Se pitää kaikki yhdellä työtilalla avaamasi ikkunat näkyvissä koko ajan, vaikka sen pitäisi kutistaa niitä.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mutta voit myös valita muuttavasi työtilan vierittäväksi asetteluksi, jossa ikkunat on aseteltu vierekkäin näytön näkyvän reunan ulkopuolelle. Muutat yksittäisen työtilan tähän asetteluun näppäimillä `Super + L`.

`Super + L` -näppäinten painaminen uudelleen muuttaa työtilan kelluvaksi, jossa ikkunat limittyvät vapaasti ja sijoitat ne itse, ja kolmas painallus palauttaa sen dwindleen. `Super + Alt + L` käy ne läpi toiseen suuntaan. Ikkuna, joka kelluu joka tapauksessa — sellainen, jonka ponnautit ulos näppäimillä `Super + T`, tai sovellus, joka aukeaa aina kelluvana — pysyy kelluvana, kun työtila palaa laatoitukseen. Yläpalkki merkitsee työtilan, jolla olet, sen asettelulla: neliö dwindlelle, ympyrä vierittävälle ja kolmio kelluvalle. Tuon merkin klikkaaminen kierrättää asettelua myös.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valinta on työtilakohtainen, ja se pysyy. Voit siis pitää työtilan 1 dwindlessa selaamista varten ja työtilan 2 vierittävässä koodia varten, ja ne palaavat sellaisina uudelleenkäynnistyksen jälkeen.

Jos haluat käyttää vierittävää asettelua oletuksena, voit asettaa sen tiedostossa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Kelluvat työtilat

Kelluva työtila toimii kuten perinteinen työpöytä: ikkunat limittyvät, ja siirrät ja mitoitat ne itse. Jokainen ikkuna saa otsikkopalkin teemasi väreissä, jossa on painikkeet pienentämistä, suurentamista ja sulkemista varten. `Super + M` pienentää myös fokusoituna olevan ikkunan. Pienennetty ikkuna odottaa dockissa; klikkaa sen sovellusta tuodaksesi sen takaisin. Klikkaa ikkunaa tuodaksesi sen etualalle. Muuta sen kokoa mistä tahansa reunasta tai kulmasta. Kaksoisklikkaa otsikkopalkkia suurentaaksesi ikkunan pitäen yläpalkin näkyvissä, ja uudelleen saadaksesi sen vanhan koon takaisin.

Kelluvassa työtilassa näkyy myös dock, jossa on kiinnitetyt sovelluksesi, kaikki käynnissä oleva, ja ruudukko kaikista sovelluksista sovelluspainikkeen takana, jonka myös `Super + Alt + Space` ja Omarchy-valikon _Apps_ avaavat. Klikkaa sovellusta ruudukossa hiiren oikealla painikkeella, tai paina `Delete`, poistaaksesi sen asennuksen. Klikkaa sovellusta avataksesi sen, tai tuodaksesi sen ikkunan etualalle; klikkaa uudelleen kierrättääksesi sen ikkunoita. Keskiklikkaus avaa uuden ikkunan. Vedä kuvaketta dockia pitkin siirtääksesi sitä; käynnissä olevan sovelluksen vetäminen muiden joukkoon pitää sen siellä. Klikkaa hiiren oikealla painikkeella pitääksesi sovelluksen dockissa, poistaaksesi sen sieltä tai lopettaaksesi sen. Dock väistyy koko näytön ikkunan tieltä. Klikkaa sovelluspainiketta hiiren oikealla painikkeella siirtääksesi dockin toiselle reunalle tai saadaksesi sen piiloutumaan, kunnes osoitin saavuttaa sen reunan. Sijainti on myös kohdassa _Trigger > Appearance > Dock > Dock Position_, ja `omarchy dock position left` ja `omarchy dock autohide on` asettavat molemmat päätteeltä. Sovellukset, jotka pidät dockissa, ovat haalistuneita, kun ne eivät ole käynnissä.

Uudet työtilat, ja kaikki, joille et ole antanut omaa asetteluaan näppäimillä `Super + L`, käyttävät oletusasettelua. Oletuksen vaihtaminen palauttaa jokaisen ikkunattoman työtilan siihen, kun taas työtila, jolla on ikkunoita, säilyttää nykyisen asettelunsa. Dockiin pienennetty ikkuna lasketaan edelleen ikkunaksi työtilalla, jolta se lähti. Valitse se kohdasta _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling tai Floating. `omarchy-hyprland-workspace-layout-default scrolling` asettaa sen päätteeltä.

### Ikkunoiden ryhmittely

Ikkunoita voidaan ryhmitellä näppäimillä `Super + G`. Kun olet ryhmässä, jokainen ikkuna, jonka käynnistät sen ollessa aktiivisena, kuuluu ryhmään. Voit liikkua näiden ryhmiteltyjen ikkunoiden välillä näppäimillä `Super + Ctrl + Arrow Left/Right` tai `Super + Alt + 1/2/3/4` siirtyäksesi suoraan ryhmiteltyyn ikkunaan järjestyksessä.

Voit siirtää ikkunan pois ryhmittelystä näppäimillä `Super + Alt + G` tai purkaa koko ryhmän painamalla `Super + G` uudelleen. Lopuksi voit siirtää ryhmän ulkopuolisia ikkunoita siihen näppäimillä `Super + Alt + Arrows`.

### Ikkunoiden ponnauttaminen

Voit ponnauttaa ikkunan ulos työtila-allokaatiostaan näppäimillä `Super + O`. Se kiinnittää sen kelluvana ikkunana, joka seuraa sinua mille tahansa työtilalle menetkin. Erinomainen videosoittimille ja vastaaville.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-työtila

Lopuksi on olemassa erityinen scratchpad-työtila, joka putoaa alas sen työtilan päälle, jolla parhaillaan olet, pitkälti kuten Quake-konsoli. Vaihda sitä näppäimillä `Super + Grave` tai `Super + S`, ja sijoita ikkuna sinne näppäimillä `Super + Shift + Grave` tai `Super + Alt + S`.

Se toimii erityisen hyvin päätteelle, jossa pyörii agentti, tai säätimille, joiden kanssa haluat toimia nopeasti poistumatta nykyiseltä työtilalta. Siirtääksesi ikkunan pois scratchpadilta, lähetä se suoraan toiselle työtilalle esimerkiksi näppäimillä `Super + Shift + 1`.

Kun scratchpadissa on yksi ikkuna, se putoaa alas keskitettynä paneelina sen sijaan, että se ulottuisi koko näytön poikki. Laita siihen toinen sovellus, ja se palaa täyteen leveyteen, jotta kahdella on tilaa istua vierekkäin.

### Se vaatii totuttelua!

Kestää hetken tottua työpöydällä navigointiin tällä tavalla, mutta kun tottuu, on vaikea palata perinteiseen hiiriohjattuun työpöytäkokemukseen!
