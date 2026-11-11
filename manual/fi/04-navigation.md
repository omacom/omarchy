# Navigointi

Kaikki Omarchyssa tapahtuu näppäimistöllä — _KAIKKI!_ Kun järjestelmä käynnistyy ensimmäisen kerran, et kirjaimellisesti pysty tekemään mitään pelkällä hiirellä. Mutta voit painaa `Super + Space` paljastaaksesi Omarchy-valikon, ja täältä voit tehdä melkein kaiken.

Mutta Omarchy-valikon ei ole edes tarkoitus olla pääasiallinen tapa käyttää järjestelmää suurimman osan ajasta. Pystymme nopeampaankin! Kaikki tärkeimmät sovellukset on sidottu suoraan yksittäisiin pikanäppäimiin. Käynnistät päätteen näppäimillä `Super + Return` ja selaimen näppäimillä `Super + Shift + Return`. Kokeile tehdä toinen toisensa jälkeen, niin näet Hyprlandin laatoituksen taikuuden toiminnassa:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Voit sitten painaa `Super + J` pinotaksesi ne päällekkäin sen sijaan, että ne olisivat vierekkäin:

 ![navigation-stacked](images/navigation-stacked.webp)

Paina `Super + J` uudelleen palauttaaksesi ne vierekkäisiin asemiinsa. Kokeile sitten näppäimiä `Super + Shift + Arrow Right` selaimessa ollessasi vaihtaaksesi ikkunat keskenään.

Kokeile nyt näppäimiä `Super + Shift + T` käynnistääksesi Aktiivisuusmonitorin. Se ilmestyy kelluvana ikkunana. Voit laatoittaa sen käyttämällä näppäimiä `Super + T` (ja painaa sitä uudelleen tehdäksesi siitä taas kelluvan). Paina nyt `Super + Shift + F` avataksesi tiedostonhallinnan. Sinulla on siisti neljän ikkunan asetelma:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navigoit sen ikkunan luo, jonka haluat olevan aktiivinen, näppäimillä `Super + Arrow`. Tämä vaihtaa fokuksen ja siirtää kohdistimen uuden sovelluksen keskelle. Näytön reunalla se jatkaa sillä puolella olevalle näytölle.

Jos painat `Super + Shift + 2`, siirrät parhaillaan kohdistetun sovelluksen toiseen työtilaan. `Super + Shift + 1` siirtää sen takaisin. (Ja `Super + Shift + Alt + 2` siirtää parhaillaan kohdistetun sovelluksen toiseen työtilaan vaihtamatta siihen).

Kun näyttöjä on useampi kuin yksi, jokaisella näytöllä on omat työtilansa 1–10. `Super + 2` siirtyy sillä näytöllä, jolla olet, olevaan toiseen työtilaan, ja jokaisen näytön yläpalkki näyttää sen omat työtilat ja sen, jota se parhaillaan näyttää. `Super + Tab` selaa sillä näytöllä, jolla olet, olevia työtiloja. `Super + Shift + Ctrl + Arrows` siirtää ikkunan, jolla olet, siihen suuntaan olevalle näytölle, sen näyttämään työtilaan, ja `Super + Shift + Alt + Arrows` siirtää työtilan, jolla olet, siihen suuntaan olevalle näytölle, jossa se saa saman numeron, jos se on vapaana. Näyttö säilyttää työtilansa, kun irrotat sen: ne liittyvät toisen näytön työtiloihin numeroituina sen jo olemassa olevien työtilojen jälkeen ja palaavat vanhojen numeroidensa alle, kun näyttö palaa.

Jos pidät `Super`-näppäintä painettuna ja napsautat ikkunaa hiirellä, voit järjestellä uudelleen, missä se sijaitsee. Jos pidät `Super`-näppäintä painettuna ja käytät hiiren oikeaa painiketta, voit muuttaa ikkunan kokoa vapaasti.

Suljet ikkunan näppäimillä `Super + W` tai `Super + Q` (ja suljet kaikki ikkunat näppäimillä `Ctrl + Alt + Delete`).

Voit myös siirtyä koko näytön tilaan näppäimillä `Super + F` tai jopa vain koko leveydelle (yläpalkin säilyttäen) näppäimillä `Super + Alt + F` tai koko näytön tilaan ikkunan sisällä näppäimillä `Super + Ctrl + F` (hyvä YouTubelle!).

### Dwindle vastaan vierivä asettelu

Omarchyn oletusasettelua kutsutaan nimellä dwindle. Se pitää kaikki yhdessä työtilassa avaamasi ikkunat näkyvissä koko ajan, vaikka sen täytyisi kutistaa niitä.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Mutta voit myös valita muuttaa työtilan vieriväksi asetteluksi, jossa ikkunat on rivitetty vierekkäin näytön näkyvän reunan ulkopuolelle. Muutat yksittäisen työtilan tähän asetteluun näppäimillä `Super + L`.

Näppäinten `Super + L` painaminen uudelleen muuttaa työtilan kelluvaksi, jossa ikkunat menevät vapaasti päällekkäin ja asetat ne itse, ja kolmas painallus palauttaa sen dwindleen. `Super + Alt + L` käy ne läpi toiseen suuntaan. Ikkuna, joka kelluu joka tapauksessa — sellainen, jonka irrotit näppäimillä `Super + T`, tai sovellus, joka avautuu aina kelluvana — pysyy kelluvana, kun työtila palaa laatoitukseen. Yläpalkki merkitsee työtilan, jolla olet, sen asettelulla: neliö dwindlelle, ympyrä vierivälle ja kolmio kelluvalle. Sen merkin napsauttaminen vaihtaa myös asettelua vuorotellen.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valinta on työtilakohtainen, ja se pysyy. Voit siis pitää työtila 1:n dwindlessä selailua varten ja työtila 2:n vierivässä koodia varten, ja ne palaavat sellaisina uudelleenkäynnistyksen jälkeen.

Jos haluat käyttää vierivää asettelua oletuksena, voit asettaa sen tiedostossa `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Kelluvat työtilat

Kelluva työtila toimii kuten perinteinen työpöytä: ikkunat menevät päällekkäin, ja siirrät ja mitoitat ne itse. Jokainen ikkuna saa otsikkopalkin teemasi väreissä, jossa on painikkeet pienentämiseen, suurentamiseen ja sulkemiseen. `Super + M` pienentää myös kohdistetun ikkunan. Pienennetty ikkuna odottaa dockissa; napsauta sen sovellusta tuodaksesi sen takaisin. Napsauta ikkunaa tuodaksesi sen eteen. Muuta sen kokoa mistä tahansa reunasta tai kulmasta. Kaksoisnapsauta otsikkopalkkia suurentaaksesi ikkunan säilyttäen samalla yläpalkin näkyvissä, ja uudelleen saadaksesi sen vanhan koon takaisin.

Kelluva työtila näyttää myös dockin, jossa ovat kiinnittämäsi sovellukset, kaikki käynnissä olevat sovellukset ja ruudukko jokaisesta sovelluksesta sovelluspainikkeen takana, jonka myös `Super + Alt + Space` ja Omarchy-valikon _Sovellukset_ avaavat. Napsauta sovellusta ruudukossa hiiren oikealla painikkeella tai paina `Delete` poistaaksesi sen asennuksen. Napsauta sovellusta avataksesi sen tai tuodaksesi sen ikkunan eteen; napsauta uudelleen selataksesi sen ikkunoita. Keskipainikkeen napsautus avaa uuden ikkunan. Vedä kuvaketta dockia pitkin siirtääksesi sitä; käynnissä olevan sovelluksen vetäminen muiden joukkoon pitää sen siellä. Napsauta hiiren oikealla painikkeella pitääksesi sovelluksen dockissa, poistaaksesi sen sieltä tai lopettaaksesi sen. Dock väistyy koko näytön ikkunan tieltä. Napsauta sovelluspainiketta hiiren oikealla painikkeella siirtääksesi dockin toiseen reunaan tai saadaksesi sen piiloutumaan, kunnes osoitin saavuttaa sen reunan. Sijainti on myös kohdassa _Ulkoasu > Dock > Dockin sijainti_, ja `omarchy dock position left` ja `omarchy dock autohide on` asettavat molemmat päätteestä. Sovellukset, jotka pidät dockissa, ovat haalistuneita, kun ne eivät ole käynnissä.

Uudet työtilat ja kaikki, joille et ole antanut omaa asetteluaan näppäimillä `Super + L`, käyttävät oletusasettelua. Oletuksen muuttaminen palauttaa jokaisen ikkunattoman työtilan siihen, kun taas työtila, jossa on ikkunoita, säilyttää asettelun, joka sillä on. Ikkuna, joka on pienennetty dockiin, lasketaan edelleen ikkunaksi työtilassa, josta se lähti. Valitse se kohdasta _Ulkoasu > Työtilan asettelu_: Laatoitus, Vierivä tai Kelluva. `omarchy-hyprland-workspace-layout-default scrolling` asettaa sen päätteestä.

### Ikkunoiden ryhmittely

Ikkunoita voidaan ryhmitellä käyttämällä näppäimiä `Super + G`. Kun olet ryhmässä, jokainen ikkuna, jonka käynnistät sen ollessa aktiivinen, kuuluu ryhmään. Voit siirtyä näiden ryhmiteltyjen ikkunoiden välillä käyttämällä näppäimiä `Super + Ctrl + Arrow Left/Right` tai `Super + Alt + 1/2/3/4` siirtyäksesi suoraan ryhmiteltyihin ikkunoihin järjestyksessä.

Voit siirtää ikkunan pois ryhmittelystä näppäimillä `Super + Alt + G` tai purkaa koko ryhmän painamalla `Super + G` uudelleen. Lopuksi voit siirtää ryhmän ulkopuolella olevia ikkunoita siihen näppäimillä `Super + Alt + Arrows`.

### Ikkunoiden irrottaminen

Voit irrottaa ikkunan sen työtilavarauksesta näppäimillä `Super + O`. Se kiinnittää sen kelluvaksi ikkunaksi, joka seuraa sinua mihin tahansa työtilaan siirrytkin. Mahtavaa videosoittimille ja vastaaville.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-työtila

On olemassa erityinen täysikokoinen scratchpad-työtila, joka asettuu sen työtilan päälle, jolla parhaillaan olet. Pääset käsiksi siihen, mikä siellä on, käyttämällä näppäimiä `Super + S`, ja asetat ikkunoita sinne käyttämällä näppäimiä `Super + Alt + S`.

Se toimii hyvin säätimille tai päätteelle, jonka kanssa haluat toimia nopeasti poistumatta nykyisestä työtilasta.

### Quake-konsoli

Lopuksi on olemassa puolikorkea Quake-konsoli, joka putoaa alas sen työtilan päälle, jolla parhaillaan olet. Vaihda se päälle ja pois näppäimillä `Super + Grave`, ja aseta ikkuna sinne käyttämällä näppäimiä `Super + Shift + Grave`.

Se avautuu oletusagenttisi käyttövalmiina. Kun konsolissa on yksi ikkuna, se putoaa alas keskitettynä paneelina sen sijaan, että se ulottuisi näytön poikki. Aseta siihen toinen sovellus, ja se palaa täyteen leveyteen, jotta niillä kahdella on tilaa olla vierekkäin.

Siirtääksesi ikkunan pois joko scratchpadista tai konsolista, lähetä se suoraan toiseen työtilaan esimerkiksi näppäimillä `Super + Shift + 1`.

### Tähän tottuminen vie hetken!

Kestää hetken tottua työpöydälläsi navigointiin tällä tavalla, mutta kun totut, on vaikea palata perinteiseen hiirivetoiseen työpöytäkokemukseen!
