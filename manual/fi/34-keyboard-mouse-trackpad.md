# Näppäimistö, hiiri, ohjauslevy

Hyprlandissa voit määrittää kaikki syöttölaitteesi erittäin yksityiskohtaisesti. Voit tehdä näppäimistön toistosta yliääninopean tai asettaa ohjauslevyn käyttämään luonnollista vieritystä. Muutat kaiken tämän tiedostossa `~/.config/hypr/input.lua`, johon pääset myös Omarchy-valikon kohdasta _Setup > Input_ (`Super + Space`). Kaikki siellä asettamasi asetukset korvaavat Omarchyn oletukset.

Tässä on esimerkki:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Näet [kaikki syöttöasetukset](https://wiki.hypr.land/Configuring/Basics/Variables/#input) syöttölaitteita koskevalla Hyprlandin wiki-sivulla.

CapsLock toimii normaalina Caps Lock -näppäimenä, ja `Shift + CapsLock` on yhdistelmänäppäin [nopeille emojeille](07-hotkeys.md#quick-emojis) ja [muille täydennyksille](07-hotkeys.md#quick-completions). Jos haluat yhdistelmänäppäimen mieluummin muualle, korvaa `omarchy:shift_caps_compose` asetuksessa `kb_options`. Tämä esimerkiksi siirtää yhdistelmänäppäimen Right Alt -näppäimeen:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Toimintonäppäimet

Kannettavan näppäimistön ylärivi lähettää oletuksena medianäppäimet (äänenvoimakkuus, kirkkaus ja niin edelleen), ja `Fn`-näppäintä pohjassa pitämällä saat F1-F12; `Fn + Esc` lukitsee asetuksen toisin päin, kunnes painat sitä uudelleen. Useimmat näppäimistöt muistavat lukituksen itse. ASUS-kannettavat ja Apple-tyyliset näppäimistöt jättävät sen Linuxille, joka käynnistää ne medianäppäimillä joka käynnistyksellä. Jos haluat niiden käynnistyvän sen sijaan F1-F12-näppäimillä, suorita `omarchy device keyboard toprow fnkeys` (ja `omarchy device keyboard toprow mediakeys`, jos haluat palata takaisin); joissain kannettavissa muutos tulee voimaan uudelleenkäynnistyksen jälkeen. Apple Silicon -Macit säilyttävät oman asetuksensa.

### Ohjauslevyn eleet

Liiku työpöydällä pyyhkäisemällä ohjauslevyä:

| Ele | Toiminto |
| --- | --- |
| Kolme sormea vasemmalle / oikealle | Edellinen / seuraava työtila, myös tyhjät |
| Kolme sormea ylös | Tekoälykonsoli päälle/pois |
| Kolme sormea alas | Avaa Omarchy-valikko |
| Neljä sormea vasemmalle / oikealle | Siirrä aktiivinen ikkuna edelliseen / seuraavaan työtilaan |
| Neljä sormea alas | Koko näyttö päälle/pois |

Jos haluat muuttaa jotakin niistä, poista se käytöstä tiedostossa `~/.config/hypr/input.lua` ennen kuin lisäät oman [ohjauslevyeleesi](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), koska Hyprland ei hyväksy kahta elettä samoille sormille ja suunnalle:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Jos haluat poistaa kaikki Omarchyn eleet käytöstä, aseta `omarchy_default_gestures = false` tiedoston `~/.config/hypr/hyprland.lua` alkuun, ennen kuin Omarchyn oletukset latautuvat.

Haptisella ohjauslevyllä varustetuissa Dell XPS -kannettavissa voit myös asettaa napsautuksen voimakkuuden matalaksi, keskitasoiseksi tai korkeaksi kohdassa _Trigger > Hardware > Touchpad Haptics_.

### Kirjoittaminen kiinaksi, japaniksi ja muilla kielillä

Valitse japani, korea, kiina (yksinkertaistettu, Pinyin), Taiwan (Zhuyin) tai Hongkong (Cangjie), kun asennusohjelma kysyy näppäimistöstäsi. Omarchy määrittää näppäimistön ja siihen sopivan syöttömoottorin automaattisesti, myös offline-tilassa tapahtuvan ensimmäisen käynnistyksen asennuksen aikana. Japanissa käytetään Mozcia, koreassa vakiomuotoista kaksisarjaista Hangulia, yksinkertaistetussa kiinassa Pinyinia, Taiwanissa Chewingin vakiomuotoista Zhuyin-asettelua ja Hongkongissa Cangjieta Hongkongin merkkimuodoilla. Japani (US-näppäimistö) tarjoaa Mozcin US-näppäimistöasettelulla. Hangul-, Zhuyin- ja Cangjie-näppäimet pysyvät vakioasemissaan myös silloin, kun kirjoitat latinalaisia kirjaimia Dvorak-, Colemak- tai AZERTY-asettelulla. Jos lisäsit Hangulin tai Chewingin ennen tätä, poista sen valinta ja valitse se uudelleen kohdassa _Setup > Keyboard > Input Methods_, jotta sen näppäimet siirtyvät sinne; Omarchy jättää jo käyttämäsi moottorin rauhaan.

Kirjoittaminen alkaa latinalaisessa tilassa. Paina `Super + I` selataksesi määritettyjä syöttömenetelmiä ja `Super + Shift + I` selataksesi taaksepäin. Napauta pelkkää `Shift`-näppäintä astuaksesi Pinyinin kaltaisesta syöttömenetelmästä latinalaisiin kirjaimiin ja napauta sitä uudelleen palataksesi takaisin, samalla tavalla kuin Sogou, Microsoft Pinyin ja macOS toimivat; `Shift` yhdessä kirjaimen kanssa kirjoittaa silti ison kirjaimen. Japanilaisissa näppäimistöissä 全角/半角 vaihtaa syöttöä, 変換 ottaa sen käyttöön ja 無変換 poistaa sen käytöstä. Koreassa 한/영 vaihtaa Hanguliin ja 한자 muuntaa Hanjaan riippumatta siitä, onko näppäimistössäsi niille omat näppäimet vai lähettääkö se niille Right Alt ja Right Ctrl, kuten monet kannettavat tekevät, joten Right Alt ja Right Ctrl eivät ole siellä pelkkiä muokkausnäppäimiä; sanelu vaihtuu sen sijaan yhdistelmällä Alt + Space. `Ctrl + Space` pysyy käytettävissä Tmuxille ja Herdrille; `Shift + CapsLock` pysyy yhdistelmänäppäimenä.

Näppäimistöilmaisin ilmestyy palkin oikealle puolelle, kun sinulla on useita näppäimistöasetteluja tai syöttömenetelmiä. Napsauta sitä vaihtaaksesi syöttökieliä; japani näyttää merkkiä あ hiraganalle. Jos haluat valita japanilaisia merkkejä, vaihda japaniin, kirjoita sana kuten `nihongo` ja paina sitten Space kahdesti. Hyväksy valintasi painamalla Enter. Jos sinulla on myös useita näppäimistöasetteluja, selaa niitä napsauttamalla ilmaisinta hiiren oikealla painikkeella.

Käytä kohtaa _Setup > Keyboard > Keyboard Inputs_ valitaksesi asetteluja, kuten englanti ja ranska, samoista vaihtoehdoista, joita asennuksen aikana tarjotaan. Käytä kohtaa _Setup > Keyboard > Input Methods_ valitaksesi, mitkä koostemoottorit ovat käytössä. Molemmat valitsimet avautuvat Omarchy-valikon sisällä, ja nykyiset valintasi on merkitty valituiksi. Vaihda valintaa napsauttamalla tai painamalla Enter; jokainen muutos tulee voimaan heti. Syöttömenetelmän valinnan poistaminen poistaa sen kierrosta poistamatta sen asennusta; näppäimistö pysyy käytettävissä.

Suorita `omarchy setup keyboard` tai `omarchy setup input` avataksesi samat valitsimet. Jos haluat lisätä yhden kielen komentoriviltä, käytä vaihtoehtoja `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` tai `cangjie5`. Quick, Boshiamy ja Array tulevat samassa paketissa Cangjien kanssa ja näkyvät Input Methods -valitsimessa. Mukautetut vaihtamisnäppäimesi säilytetään. Jos haluat vaihtoehtoisia moottorin asetteluja tai näppäimiä, asenna `fcitx5-configtool` komennolla `omarchy pkg add fcitx5-configtool` ja käynnistä se päätteestä. Syöttökielen valitseminen ei muuta työpöydän kieltä. Japanin, korean tai kiinan valitseminen kohdassa _Setup > Language_ lisää sen syöttömenetelmän, kun sinulla ei vielä ole sellaista.

Käytä `Super + I` selataksesi syöttömenetelmiä tai näppäimistöasetteluja ja `Super + Shift + I` liikkuaksesi toiseen suuntaan, joten kolmen määritetyn vaihtoehdon kanssa voit liikkua kahden naapurin välillä. Syöttöilmaisin näkyy palkin oikealla puolella vain, kun useampi kuin yksi syöttömenetelmä tai asettelu on määritetty. Tämä työpöytäsidos toimii olemassa olevien Fcitx-vaihtonäppäintesi rinnalla; voit ohittaa sen tiedostossa `~/.config/hypr/bindings.lua`. Syöttömoottorit ja yhdistelmäsarjat käyttävät [Fcitx5](https://fcitx-im.org/)-palvelua, joka on jo käynnissä jokaisessa istunnossa.

### ALT-näppäimen käyttö SUPER-näppäimenä

Joissakin näppäimistöissä ensisijaisen metanäppäimen (Windows/cmd-näppäin) käyttäminen SUPER-näppäimenä ei ole kätevää. Voit vaihtaa sen sijaan ALT-näppäimeen tällä muutoksella:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
