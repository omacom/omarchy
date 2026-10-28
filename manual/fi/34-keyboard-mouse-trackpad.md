# Näppäimistö, hiiri, kosketuslevy

Hyprlandissa voit määrittää kaikki syöttölaitteesi erittäin yksityiskohtaisesti. Voit tehdä näppäimistön toistosta yliäänennopeaa tai saada kosketuslevyn käyttämään luonnollista vieritystä. Muutat kaiken tiedostossa `~/.config/hypr/input.lua`, johon pääset myös Omarchy-valikosta (`Super + Space`) kohdasta _Setup > Input_. Kaikki sinne asettamasi korvaa Omarchyn oletukset.

Tässä esimerkki:

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

Voit [katsoa kaikki syöttöasetukset](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprlandin wikin syöttöjä käsittelevältä sivulta.

CapsLock toimii tavallisena Caps Lockina, ja `Shift + CapsLock` on compose-näppäin [pikaemojeille](07-hotkeys.md#quick-emojis) ja [muille täydennyksille](07-hotkeys.md#quick-completions). Jos haluat compose-näppäimen mieluummin muualle, korvaa `omarchy:shift_caps_compose` kohdassa `kb_options`. Tämä esimerkiksi siirtää compose-näppäimen Right Alt -näppäimeen:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Kosketuslevyn eleet

Pyyhkäise kosketuslevyä liikkuaksesi työpöydällä:

| Ele | Toiminto |
| --- | --- |
| Kolme sormea vasemmalle / oikealle | Edellinen / seuraava työtila, myös tyhjät |
| Kolme sormea ylös | Avaa tai sulje tekoälykonsoli |
| Kolme sormea alas | Avaa Omarchy-valikko |
| Neljä sormea vasemmalle / oikealle | Siirrä aktiivinen ikkuna edelliseen / seuraavaan työtilaan |
| Neljä sormea alas | Vaihda koko näytön tila |

Jos haluat muuttaa yhtä, poista se käytöstä tiedostossa `~/.config/hypr/input.lua` ennen kuin lisäät oman [kosketuslevyeleesi](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), koska Hyprland ei hyväksy kahta elettä samoille sormille ja samalle suunnalle:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Sammuta kaikki Omarchyn eleet asettamalla `omarchy_default_gestures = false` tiedoston `~/.config/hypr/hyprland.lua` yläosan lähelle, ennen kuin Omarchyn oletukset latautuvat.

Dell XPS -kannettavissa, joissa on haptinen kosketuslevy, voit asettaa myös napsautuksen voimakkuuden matalaksi, keskitasoiseksi tai korkeaksi kohdassa _Trigger > Hardware > Touchpad Haptics_.

### Kiinaksi, japaniksi ja muilla kielillä kirjoittaminen

Valitse japani, korea, kiina (yksinkertaistettu, Pinyin), Taiwan (Zhuyin) tai Hongkong (Cangjie), kun asennusohjelma kysyy näppäimistöäsi. Omarchy määrittää näppäimistön ja siihen sopivan syöttömoottorin automaattisesti, myös offline-tilassa tehtävän ensimmäisen käynnistyksen asennuksen aikana. Japani käyttää Mozcia, korea tavallista kaksipaikkaista Hangul-asettelua, yksinkertaistettu kiina Pinyiniä, Taiwan Chewingin tavallista Zhuyin-asettelua ja Hongkong Cangjieta Hongkongin merkkimuodoilla. Japanese (US keyboard) tarjoaa Mozcin yhdysvaltalaisella näppäimistöasettelulla. Hangul-, Zhuyin- ja Cangjie-näppäimet pysyvät vakioasemissaan silloinkin, kun kirjoitat latinalaisia kirjaimia Dvorakilla, Colemakilla tai AZERTYllä. Jos lisäsit Hangulin tai Chewingin ennen tätä, poista sen valinta ja valitse se uudelleen kohdassa _Setup > Typing > Input Methods_, jotta sen näppäimet siirtyvät sinne; Omarchy jättää jo käyttämäsi moottorin rauhaan.

Kirjoittaminen alkaa latinalaisessa tilassa. Paina `Super + I` selataksesi määritettyjä syöttömenetelmiä ja `Super + Shift + I` selataksesi takaisin. Napauta pelkkää `Shift`-näppäintä astuaksesi ulos Pinyinin kaltaisesta syöttömenetelmästä latinalaisiin kirjaimiin ja napauta sitä uudelleen palataksesi takaisin, samalla tavalla kuin Sogou, Microsoft Pinyin ja macOS toimivat; `Shift` yhdessä kirjaimen kanssa kirjoittaa silti ison kirjaimen. Japanilaisilla näppäimistöillä 全角/半角 vaihtaa syötön, 変換 ottaa sen käyttöön ja 無変換 sammuttaa sen. Koreassa 한/영 vaihtaa Hangulin ja 한자 muuntaa Hanjoiksi riippumatta siitä, onko näppäimistössäsi niille omat näppäimensä vai lähettääkö se niiden sijaan Right Alt- ja Right Ctrl -näppäimet, kuten monet kannettavat tekevät, joten Right Alt ja Right Ctrl eivät ole siellä tavallisia muokkausnäppäimiä; sanelun push-to-talk pysyy F9-näppäimessä. `Ctrl + Space` pysyy käytettävissä Tmuxille ja Herdrille; `Shift + CapsLock` pysyy compose-näppäimenä.

Näppäimistön ilmaisin ilmestyy palkin oikeaan reunaan, kun sinulla on useita näppäimistöasetteluja tai syöttömenetelmiä. Napsauta sitä vaihtaaksesi syöttökieliä; japani näyttää merkin あ hiraganalle. Japanilaisia merkkejä valitaksesi vaihda japaniin, kirjoita sana kuten `nihongo` ja paina sitten Space kahdesti. Hyväksy valintasi painamalla Enter. Jos sinulla on myös useita näppäimistöasetteluja, selaa niitä napsauttamalla ilmaisinta oikealla painikkeella.

Käytä kohtaa _Setup > Typing > Keyboard Layouts_ valitaksesi asetteluja, kuten englanti ja ranska, samoista vaihtoehdoista, joita asennuksen aikana tarjotaan. Käytä kohtaa _Setup > Typing > Input Methods_ valitaksesi, mitkä koostemoottorit ovat käytössä. Molemmat valitsimet avautuvat Omarchy-valikon sisällä niin, että nykyiset valintasi on rastitettu. Napsauta tai paina Enter vaihtaaksesi valintaa; jokainen muutos tulee voimaan välittömästi. Syöttömenetelmän valinnan poistaminen poistaa sen kierrosta poistamatta sen asennusta; näppäimistö pysyy käytettävissä.

Avaa samat valitsimet suorittamalla `omarchy setup keyboard` tai `omarchy setup input`. Lisää yksi kieli komentoriviltä komennolla `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` tai `cangjie5`. Quick, Boshiamy ja Array tulevat samassa paketissa kuin Cangjie ja näkyvät Input Methods -valitsimessa. Omat vaihtamisnäppäimesi säilytetään. Vaihtoehtoisia moottorin asetteluja tai näppäimiä varten asenna `fcitx5-configtool` komennolla `omarchy pkg add fcitx5-configtool` ja käynnistä se terminaalista. Syöttökielen valitseminen ei muuta työpöydän kieltä. Japanin, korean tai kiinan valitseminen kohdassa _Setup > Language_ lisää sen syöttömenetelmän, jos sinulla ei vielä ole yhtään.

Käytä `Super + I` selataksesi syöttömenetelmiä tai näppäimistöasetteluja ja `Super + Shift + I` mennäksesi toiseen suuntaan takaisin, joten kolmen määritetyn kanssa voit liikkua kahden naapurin välillä. Syötön ilmaisin ilmestyy palkin oikeaan reunaan vain, kun määritettynä on useampi kuin yksi syöttömenetelmä tai asettelu. Tämä työpöydän sidonta toimii rinnakkain olemassa olevien Fcitx-vaihtamisnäppäintesi kanssa; voit ohittaa sen tiedostossa `~/.config/hypr/bindings.lua`. Syöttömoottorit ja compose-sekvenssit käyttävät [Fcitx5](https://fcitx-im.org/) -palvelua, joka on jo käynnissä jokaisessa istunnossa.

### Käytä ALTia SUPERina

Joillakin näppäimistöillä ensisijaista meta-näppäintä (Windows/cmd-näppäintä) ei ole kätevää käyttää SUPERina. Voit vaihtaa sen tilalle ALTin tällä muutoksella:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
