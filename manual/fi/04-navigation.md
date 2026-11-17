# Navigointi

Kaikki Omarchyssa tapahtuu näppäimistöllä — _KAIKKI!_ Kun järjestelmä käynnistyy ensimmäisen kerran, et kirjaimellisesti saa mitään aikaan pelkällä hiirellä. Mutta voit painaa `Super + Space` paljastaaksesi Omarchy-valikon, ja täältä voit tehdä lähes kaiken.

Mutta Omarchy-valikon ei ole edes tarkoitus olla pääasiallinen tapa käyttää järjestelmää suurimman osan ajasta. Pääsemme vielä sitäkin nopeammiksi! Kaikki tärkeimmät sovellukset on sidottu suoraan yksittäisiin pikanäppäimiin. Käynnistät päätteen näppäimillä `Super + Return` ja selaimen näppäimillä `Super + Shift + Return`. Kokeile tehdä toinen toisensa jälkeen, niin näet Hyprlandin laatoituksen taian toiminnassa:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Voit sitten painaa `Super + J` pinotaksesi ne päällekkäin vierekkäin asettamisen sijaan:

 ![navigation-stacked](images/navigation-stacked.webp)

Paina `Super + J` uudelleen palauttaaksesi ne vierekkäisiin asemiinsa. Kokeile sitten `Super + Shift + Arrow Right` selaimessa ollessasi vaihtaaksesi ikkunat keskenään.

Kokeile nyt `Super + Shift + T` käynnistääksesi Activity-valvonnan. Se näkyy kelluvana ikkunana. Voit laatoittaa sen käyttämällä näppäimiä `Super + T` (ja painaa sitä uudelleen tehdäksesi siitä taas kelluvan). Paina nyt `Super + Shift + F` avataksesi tiedostonhallinnan. Saat siistin neljän ikkunan kokoonpanon:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navigoit sen ikkunan välillä, jonka haluat olevan aktiivinen, näppäimillä `Super + Arrow`. Tämä vaihtaa kohdistuksen ja siirtää kohdistimen uuden sovelluksen keskelle. Näytön reunalla se jatkaa sillä puolella olevalle näytölle.

Jos painat `Super + Shift + 2`, siirrät parhaillaan kohdistetun sovelluksen toiselle työtilalle. `Super + Shift + 1` siirtää sen takaisin. (Ja `Super + Shift + Alt + 2` siirtää parhaillaan kohdistetun sovelluksen toiselle työtilalle vaihtamatta sille).

Useamman näytön kanssa jokaisella näytöllä on omat työtilansa 1–10. `Super + 2` siirtyy sillä näytöllä, jolla olet, olevalle toiselle työtilalle, ja jokaisen näytön yläpalkki näyttää sen omat työtilat ja sen, jota se parhaillaan näyttää. `Super + Tab` kiertää sillä näytöllä, jolla olet, olevien työtilojen läpi. `Super + Shift + Ctrl + Arrows` siirtää ikkunan, jolla olet, siihen suuntaan olevalle näytölle, sen näyttämälle työtilalle, ja `Super + Shift + Alt + Arrows` siirtää työtilan, jolla olet, siihen suuntaan olevalle näytölle, jossa se ottaa saman numeron, jos se on vapaana. Näyttö pitää työtilansa, kun irrotat sen: ne liittyvät toisen näytön työtiloihin, numeroituna sen jo olemassa olevien jälkeen, ja palaavat vanhojen numerojensa alle, kun näyttö palaa.

Jos pidät `Super`-näppäintä painettuna ja napsautat ikkunaa hiirellä, voit järjestellä uudelleen, missä se sijaitsee. Jos pidät `Super`-näppäintä painettuna ja käytät hiiren oikeaa painiketta, voit vapaasti muuttaa ikkunan kokoa.

Suljet ikkunan näppäimillä `Super + W` tai `Super + Q` (ja suljet kaikki ikkunat näppäimillä `Ctrl + Alt + Delete`).

Voit myös siirtyä koko näytön tilaan näppäimillä `Super + F` tai jopa vain koko leveydelle (yläpalkki säilyttäen) näppäimillä `Super + Alt + F` tai koko näytön tilaan ikkunan sisällä näppäimillä `Super + Ctrl + F` (hyvä YouTubelle!).

### Dwindle vs vieritysasettelu

Omarchyn oletusasettelu on nimeltään dwindle. Se pitää kaikki yhdelle työtilalle avaamasi ikkunat näkyvissä koko ajan, vaikka sen pitäisi kutistaa niitä.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mutta voit myös valita muuttaa työtilan vieritysasetteluksi, jossa ikkunat ovat rivissä vierekkäin, näytön näkyvän reunan ulkopuolelle asti. Muutat yksittäisen työtilan tähän asetteluun näppäimillä `Super + L`.

`Super + L` -näppäinten painaminen uudelleen muuttaa työtilan kelluvaksi, jossa ikkunat menevät vapaasti päällekkäin ja sijoitat ne itse, ja kolmas painallus palauttaa sen dwindleen. `Super + Alt + L` käy ne läpi toiseen suuntaan. Ikkuna, joka kelluu joka tapauksessa — sellainen, jonka ponnautit ulos näppäimillä `Super + T`, tai sovellus, joka avautuu aina kelluvana — pysyy kelluvana, kun työtila palaa laatoitukseen. Yläpalkki merkitsee työtilan, jolla olet, sen asettelulla: neliö dwindlelle, ympyrä vieritykselle ja kolmio kelluvalle. Sen merkin napsauttaminen kiertää myös asettelua.

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

Kelluva työtila toimii kuin perinteinen työpöytä: ikkunat menevät päällekkäin, ja siirrät ja koostat ne itse. Jokainen ikkuna saa otsikkopalkin teemasi väreissä, painikkeilla pienentämistä, suurentamista ja sulkemista varten. `Super + M` pienentää myös kohdistetun ikkunan. Pienennetty ikkuna odottaa telakassa; napsauta sen sovellusta tuodaksesi sen takaisin. Napsauta ikkunaa tuodaksesi sen eteen. Muuta sen kokoa mistä tahansa reunasta tai kulmasta. Kaksoisnapsauta otsikkopalkkia suurentaaksesi ikkunan pitäen yläpalkin näkyvissä, ja uudelleen saadaksesi sen vanhan koon takaisin. Chrome ja muut Chromium-pohjaiset selaimet, Disks ja Document Viewer ohittavat otsikkopalkin ja käyttävät sen sijaan omaa otsikko-osaansa; `Super + Alt + F` suurentaa ne, ja `Super + M` pienentää ne.

Kelluva työtila näyttää myös telakan, jossa ovat kiinnittämäsi sovellukset, kaikki käynnissä olevat, ja ruudukko jokaisesta sovelluksesta sovelluspainikkeen takana, jonka myös `Super + Alt + Space` ja Omarchy-valikon _Apps_ avaavat. Napsauta sovellusta ruudukossa hiiren oikealla painikkeella, tai paina `Delete`, poistaaksesi sen asennuksen. Napsauta sovellusta avataksesi sen tai tuodaksesi sen ikkunan eteen; napsauta uudelleen kiertääksesi sen ikkunoiden läpi. Files tuo takaisin ikkunan vain siltä työtilalta, jolla olet, ja muuten avaa uuden, ja Terminal ja Agent aloittavat aina uuden, vaikka pienennetty ikkuna palaa ensin. Keskinapsautus avaa uuden ikkunan. Vedä kuvaketta telakkaa pitkin siirtääksesi sitä; käynnissä olevan sovelluksen vetäminen muiden joukkoon pitää sen siellä. Napsauta hiiren oikealla painikkeella pitääksesi sovelluksen telakassa, ottaaksesi sen pois tai lopettaaksesi sen. Telakka väistyy koko näytön ikkunan tieltä. Napsauta sovelluspainiketta hiiren oikealla painikkeella siirtääksesi telakan toiselle reunalle tai saadaksesi sen piiloutumaan, kunnes osoitin saavuttaa sen reunan. Sijainti on myös kohdassa _Appearance > Dock > Dock Position_, ja `omarchy dock position left` ja `omarchy dock autohide on` asettavat molemmat päätteestä. Sovellukset, jotka pidät telakassa, ovat haalistuneita, kun ne eivät ole käynnissä.

Uudet työtilat, ja kaikki, joille et ole antanut omaa asetteluaan näppäimillä `Super + L`, käyttävät oletusasettelua. Oletuksen muuttaminen palauttaa jokaisen ikkunattoman työtilan siihen, kun taas työtila, jossa on ikkunoita, pitää asettelun, joka sillä on. Telakkaan pienennetty ikkuna lasketaan edelleen ikkunaksi työtilalla, jolta se lähti. Valitse se kohdasta _Appearance > Workspace Layout_: Tiling, Scrolling tai Floating. `omarchy-hyprland-workspace-layout-default scrolling` asettaa sen päätteestä.

### Ikkunoiden ryhmittely

Ikkunoita voi ryhmitellä näppäimillä `Super + G`. Kun olet ryhmässä, jokainen ikkuna, jonka käynnistät sen ollessa aktiivinen, kuuluu ryhmään. Voit siirtyä näiden ryhmiteltyjen ikkunoiden välillä näppäimillä `Super + Ctrl + Arrow Left/Right` tai `Super + Alt + 1/2/3/4` siirtyäksesi suoraan ryhmiteltyihin ikkunoihin järjestyksessä.

Voit siirtää ikkunan ulos ryhmittelystä näppäimillä `Super + Alt + G` tai purkaa koko ryhmän painamalla `Super + G` uudelleen. Lopuksi voit siirtää ryhmän ulkopuolella olevia ikkunoita siihen näppäimillä `Super + Alt + Arrows`.

### Ikkunoiden ponnauttaminen

Voit ponnauttaa ikkunan ulos työtilasijoituksestaan näppäimillä `Super + O`. Se kiinnittää sen kelluvaksi ikkunaksi, joka seuraa sinua mille tahansa työtilalle menetkin. Loistava videosoittimille ja vastaaville.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-työtila

On erityinen täysikokoinen scratchpad-työtila, joka asettuu päällekkäin sen työtilan kanssa, jolla parhaillaan olet. Pääset sen sisältöön näppäimillä `Super + S`, ja sijoitat ikkunoita sinne näppäimillä `Super + Alt + S`.

Se toimii hyvin säätimille tai päätteelle, jonka kanssa haluat toimia nopeasti poistumatta nykyiseltä työtilalta.

### Quake-konsoli

Lopuksi on puolen korkeuden Quake-konsoli, joka putoaa alas sen työtilan päälle, jolla parhaillaan olet. Vaihda sitä näppäimillä `Super + Grave`, ja sijoita ikkuna sinne näppäimillä `Super + Shift + Grave`.

Se avautuu oletusagenttisi valmiina käyttöön. Kun konsolissa on yksittäinen ikkuna, se putoaa alas keskitettyänä paneelina sen sijaan, että se ulottuisi koko näytön leveydelle. Laita sille toinen sovellus, niin se palaa täyteen leveyteen, jotta kahdella on tilaa istua vierekkäin.

Siirtääksesi ikkunan pois joko scratchpadista tai konsolista, lähetä se suoraan toiselle työtilalle esimerkiksi näppäimillä `Super + Shift + 1`.

### Siihen tottuminen vie aikansa!

Tähän työpöydällä navigointiin tottuminen vie vähän aikaa, mutta kun totut, on vaikea palata perinteiseen hiirivetoiseen työpöytäkokemukseen!
