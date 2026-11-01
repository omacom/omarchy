# Näppäimistö, hiiri, kosketuslevy

Hyprlandin avulla voit määrittää kaikki syöttölaitteesi yksityiskohtaisesti. Voit asettaa näppäimistön toiston yliääninopeaksi tai saada kosketuslevyn käyttämään luonnollista vieritystä. Muutat kaiken tämän tiedostossa `~/.config/hypr/input.lua`, johon pääset myös Omarchy-valikon kohdasta _Setup > Input_ (`Super + Space`). Kaikki, mitä asetat sinne, korvaa Omarchyn oletukset.

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

Näet [kaikki syöttöasetukset](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprlandin wikissä syöttölaitteista.

CapsLock toimii tavallisena Caps Lockina, ja `Shift + CapsLock` on compose-näppäin [pikaemojeille](07-hotkeys.md#quick-emojis) ja [muille täydennyksille](07-hotkeys.md#quick-completions). Jos haluat compose-näppäimen mieluummin muualle, korvaa `omarchy:shift_caps_compose` kohdassa `kb_options`. Tämä esimerkiksi siirtää compose-näppäimen Right Alt -näppäimeen:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Kosketuslevyn eleet

Liiku työpöydällä pyyhkäisemällä kosketuslevyä:

| Ele | Toiminto |
| --- | --- |
| Kolme sormea vasemmalle / oikealle | Edellinen / seuraava työtila, myös tyhjät |
| Kolme sormea ylös | AI-konsoli päälle/pois |
| Kolme sormea alas | Avaa Omarchy-valikko |
| Neljä sormea vasemmalle / oikealle | Siirrä aktiivinen ikkuna edelliseen / seuraavaan työtilaan |
| Neljä sormea alas | Koko näyttö päälle/pois |

Jos haluat muuttaa yhtä, poista se käytöstä tiedostossa `~/.config/hypr/input.lua` ennen kuin lisäät oman [kosketuslevyeleesi](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), sillä Hyprland ei hyväksy kahta elettä samoille sormille ja suunnalle:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Jos haluat poistaa kaikki Omarchyn eleet käytöstä, aseta `omarchy_default_gestures = false` tiedoston `~/.config/hypr/hyprland.lua` alkupuolelle, ennen kuin Omarchyn oletukset latautuvat.

Dell XPS -kannettavissa, joissa on haptinen kosketuslevy, voit myös asettaa napsautuksen voimakkuuden matalaksi, keskitasoiseksi tai korkeaksi kohdassa _Trigger > Hardware > Touchpad Haptics_.

### Kirjoittaminen kiinaksi, japaniksi ja muilla kielillä

Valitse japani, korea, kiina (yksinkertaistettu, Pinyin), Taiwan (Zhuyin) tai Hongkong (Cangjie), kun asennusohjelma kysyy näppäimistöäsi. Omarchy määrittää näppäimistön ja sitä vastaavan syöttömoottorin automaattisesti, myös offline-tilassa tapahtuvan ensimmäisen käynnistyksen asennuksen aikana. Japanissa käytetään Mozcia, koreassa vakiomuotoista kaksisarjaista Hangulia, yksinkertaistetussa kiinassa käytetään Pinyiniä, Taiwanissa Chewingin vakiomuotoista Zhuyin-asettelua ja Hongkongissa Cangjieta Hongkongin merkkimuodoilla. Japani (US-näppäimistö) tarjoaa Mozcin US-näppäimistöasettelulla. Hangul-, Zhuyin- ja Cangjie-näppäimet pysyvät vakioasemissaan, vaikka kirjoittaisit latinalaisia kirjaimia Dvorakilla, Colemakilla tai AZERTYllä. Jos lisäsit Hangulin tai Chewingin ennen tätä, poista sen valinta ja valitse se uudelleen kohdassa _Setup > Typing > Input Methods_, jotta sen näppäimet siirtyvät sinne; Omarchy jättää moottorin, jolla jo kirjoitat, rauhaan.

Kirjoittaminen alkaa latinalaisessa tilassa. Selaa määritettyjä syöttömenetelmiä painamalla `Super + I` ja selaa takaisinpäin painamalla `Super + Shift + I`. Napauta `Shift`-näppäintä yksinään poistuaksesi Pinyinin kaltaisesta syöttömenetelmästä latinalaisiin kirjaimiin ja napauta sitä uudelleen palataksesi takaisin, samalla tavalla kuin Sogou, Microsoft Pinyin ja macOS toimivat; `Shift` ja kirjain kirjoittavat silti ison kirjaimen. Japanilaisilla näppäimistöillä 全角/半角 vaihtaa syöttöä, 変換 ottaa sen käyttöön ja 無変換 poistaa sen käytöstä. Koreassa 한/영 vaihtaa Hanguliin ja 한자 muuntaa Hanjaksi riippumatta siitä, onko näppäimistössäsi niille omat näppäimet vai lähettääkö se niille Right Alt- ja Right Ctrl -näppäimiä, kuten monet kannettavat tekevät, joten Right Alt ja Right Ctrl eivät ole siellä tavallisia muokkausnäppäimiä; sanelu vaihdetaan sen sijaan näppäimillä Alt + Space. `Ctrl + Space` pysyy käytettävissä Tmuxille ja Herdrille; `Shift + CapsLock` pysyy compose-näppäimenä.

Näppäimistön ilmaisin näkyy palkin oikealla puolella, kun sinulla on useita näppäimistöasetteluja tai syöttömenetelmiä. Vaihda syöttökieltä napsauttamalla sitä; japani näyttää merkkiä あ hiraganalle. Japanilaisten merkkien vaihtoehtoja varten vaihda japaniin, kirjoita sana, kuten `nihongo`, ja paina sitten Space kahdesti. Hyväksy valintasi painamalla Enter. Jos sinulla on myös useita näppäimistöasetteluja, selaa niitä napsauttamalla ilmaisinta hiiren oikealla painikkeella.

Valitse asettelut, kuten englanti ja ranska, kohdassa _Setup > Typing > Keyboard Layouts_ samoista vaihtoehdoista, joita tarjottiin asennuksen aikana. Valitse aktiiviset koostamusmoottorit kohdassa _Setup > Typing > Input Methods_. Molemmat valitsimet avautuvat Omarchy-valikon sisällä niin, että nykyiset valintasi on merkitty valituiksi. Vaihda valinta napsauttamalla tai painamalla Enter; jokainen muutos tulee voimaan välittömästi. Syöttömenetelmän valinnan poistaminen poistaa sen kierrosta poistamatta sen asennusta; näppäimistö pysyy käytettävissä.

Avaa samat valitsimet suorittamalla `omarchy setup keyboard` tai `omarchy setup input`. Lisää yksi kieli komentoriviltä käyttämällä komentoa `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` tai `cangjie5`. Quick, Boshiamy ja Array tulevat samassa paketissa kuin Cangjie ja näkyvät Input Methods -valitsimessa. Mukautetut vaihtamisnäppäimesi säilytetään. Vaihtoehtoisia moottorin asetteluja tai näppäimiä varten asenna `fcitx5-configtool` komennolla `omarchy pkg add fcitx5-configtool` ja käynnistä se terminaalista. Syöttökielen valitseminen ei muuta työpöydän kieltä. Japanin, korean tai kiinan valitseminen kohdassa _Setup > Language_ lisää sen syöttömenetelmän, kun sinulla ei vielä ole sellaista.

Selaa syöttömenetelmiä tai näppäimistöasetteluja painamalla `Super + I` ja palaa toiseen suuntaan painamalla `Super + Shift + I`, joten kolmen määritetyn asetuksen kanssa voit liikkua kahden naapurin välillä. Syöttöilmaisin näkyy palkin oikealla puolella vain, kun määritettynä on useampi kuin yksi syöttömenetelmä tai asettelu. Tämä työpöytäsidos toimii olemassa olevien Fcitx-vaihtamisnäppäintesi rinnalla; voit ohittaa sen tiedostossa `~/.config/hypr/bindings.lua`. Syöttömoottorit ja compose-sekvenssit käyttävät [Fcitx5](https://fcitx-im.org/)-palvelua, joka on jo käynnissä jokaisessa istunnossa.

### Käytä ALTia SUPERina

Joillakin näppäimistöillä ensisijaista meta-näppäintä (Windows/cmd-näppäintä) ei ole kätevää käyttää SUPERina. Voit vaihtaa sen sijaan ALTiksi tällä muutoksella:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
