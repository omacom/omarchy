# Näppäimistö, hiiri, kosketuslevy

Hyprland antaa sinun määrittää kaikki syöttölaitteesi erittäin yksityiskohtaisesti. Voit asettaa näppäimistön toiston yliääninopeaksi tai saada kosketuslevyn käyttämään luonnollista vieritystä. Muutat kaiken tämän tiedostossa `~/.config/hypr/input.lua`, johon pääset myös Omarchy-valikon kautta kohdasta _Setup > Input_ (`Super + Space`). Kaikki, mitä asetat sinne, korvaa Omarchyn oletusarvot.

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

Voit [nähdä kaikki syöttöasetukset](https://wiki.hypr.land/Configuring/Basics/Variables/#input) syöttölaitteita koskevassa Hyprland-wikissä.

CapsLock toimii tavallisena Caps Lockina, ja `Shift + CapsLock` on compose-näppäin [pikaemojeille](07-hotkeys.md#quick-emojis) ja [muille täydennyksille](07-hotkeys.md#quick-completions). Jos haluat compose-näppäimen mieluummin muualle, korvaa `omarchy:shift_caps_compose` kohdassa `kb_options`. Tämä esimerkiksi siirtää compose-näppäimen Right Alt -näppäimeen:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Kosketuslevyn eleet

Voit ottaa käyttöön myös [kosketuslevyn eleet](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), kuten pyyhkäisyn kolmella sormella työtilojen vaihtamiseksi:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Dell XPS -kannettavissa, joissa on haptinen kosketuslevy, voit myös asettaa napsautuksen voimakkuuden matalaksi, keskitasoiseksi tai korkeaksi kohdassa _Trigger > Hardware > Touchpad Haptics_.

### Kirjoittaminen kiinaksi, japaniksi ja muilla kielillä

Valitse japani, korea, kiina (yksinkertaistettu, Pinyin), Taiwan (Zhuyin) tai Hongkong (Cangjie), kun asennusohjelma kysyy näppäimistöäsi. Omarchy määrittää näppäimistön ja sitä vastaavan syöttömoottorin automaattisesti, myös offline-tilassa tapahtuvan ensimmäisen käynnistyksen asennuksen aikana. Japani käyttää Mozcia, korea tavallista kaksijakoista Hangulia, yksinkertaistettu kiina Pinyiniä, Taiwan Chewingin tavallista Zhuyin-asettelua ja Hongkong Cangjieta Hongkongin merkkimuodoilla. Japani (US-näppäimistö) tarjoaa Mozcin US-näppäimistöasettelulla. Hangul-, Zhuyin- ja Cangjie-näppäimet pysyvät vakioasemissaan, vaikka kirjoittaisit latinalaisia kirjaimia Dvorakilla, Colemakilla tai AZERTYllä. Jos lisäsit Hangulin tai Chewingin ennen tätä, poista sen valinta ja valitse se uudelleen kohdassa _Setup > Typing > Input Methods_ siirtääksesi sen näppäimet sinne; Omarchy jättää rauhaan moottorin, jolla jo kirjoitat.

Kirjoittaminen alkaa latinalaisessa tilassa. Paina `Super + I` selataksesi määritettyjä syöttötapoja ja `Super + Shift + I` selataksesi taaksepäin. Napauta pelkkää `Shift`-näppäintä astuaksesi ulos syöttötavasta, kuten Pinyinistä, latinalaisiin kirjaimiin, ja napauta sitä uudelleen palataksesi takaisin samalla tavalla kuin Sogou, Microsoft Pinyin ja macOS toimivat; `Shift` yhdessä kirjaimen kanssa kirjoittaa silti ison kirjaimen. Japanilaisilla näppäimistöillä 全角/半角 vaihtaa syöttöä, 変換 kytkee sen päälle ja 無変換 kytkee sen pois. Korean kanssa 한/영 vaihtaa Hangulin ja 한자 muuntaa Hanjaksi riippumatta siitä, onko näppäimistössäsi omat näppäimet niille tai lähettääkö se niitä varten Right Alt- ja Right Ctrl -näppäimiä, kuten monet kannettavat tekevät, joten Right Alt ja Right Ctrl eivät ole siellä tavallisia muokkausnäppäimiä; sanelun push-to-talk pysyy F9-näppäimessä. `Ctrl + Space` pysyy käytettävissä Tmuxille ja Herdrille; `Shift + CapsLock` pysyy compose-näppäimenä.

Näppäimistön ilmaisin ilmestyy palkin oikealle puolelle, kun sinulla on useita näppäimistöasetteluja tai syöttötapoja. Napsauta sitä vaihtaaksesi syöttökieliä; japani näyttää merkin あ hiraganalle. Japanilaisten merkkien valintoja varten vaihda japaniin, kirjoita sana, kuten `nihongo`, ja paina sitten Space kahdesti. Paina Enter hyväksyäksesi valintasi. Jos sinulla on myös useita näppäimistöasetteluja, napsauta ilmaisinta hiiren oikealla painikkeella selataksesi niitä.

Käytä kohtaa _Setup > Typing > Keyboard Layouts_ valitaksesi asetteluja, kuten englanti ja ranska, samoista vaihtoehdoista, joita tarjotaan asennuksen aikana. Käytä kohtaa _Setup > Typing > Input Methods_ valitaksesi, mitkä syöttömoottorit ovat aktiivisia. Molemmat valitsimet avautuvat Omarchy-valikon sisällä niin, että nykyiset valintasi on merkitty valituiksi. Napsauta tai paina Enter vaihtaaksesi valinnan; jokainen muutos tulee voimaan välittömästi. Syöttötavan valinnan poistaminen poistaa sen kierrosta poistamatta sitä; näppäimistö pysyy käytettävissä.

Aja `omarchy setup keyboard` tai `omarchy setup input` avataksesi samat valitsimet. Lisätäksesi yhden kielen komentoriviltä käytä komentoa `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` tai `cangjie5`. Quick, Boshiamy ja Array tulevat samassa paketissa Cangjien kanssa ja näkyvät Input Methods -valitsimessa. Mukautetut vaihtonäppäimesi säilytetään. Vaihtoehtoisia moottorin asetteluja tai näppäimiä varten asenna `fcitx5-configtool` komennolla `omarchy pkg add fcitx5-configtool` ja käynnistä se terminaalista. Syöttökielen valitseminen ei muuta työpöydän kieltä. Japanin, korean tai kiinan valitseminen kohdassa _Setup > Language_ lisää sen syöttötavan, kun sinulla ei vielä ole sellaista.

Käytä `Super + I` selataksesi syöttötapoja tai näppäimistöasetteluja ja `Super + Shift + I` mennäksesi takaisin toiseen suuntaan, joten kolmen määritetyn kanssa voit liikkua kahden naapurin välillä. Syöttöilmaisin ilmestyy palkin oikealle puolelle vain, kun määritettynä on useampi kuin yksi syöttötapa tai asettelu. Tämä työpöydän pikanäppäin toimii olemassa olevien Fcitx-vaihtonäppäintesi rinnalla; voit ohittaa sen tiedostossa `~/.config/hypr/bindings.lua`. Syöttömoottorit ja compose-sekvenssit käyttävät [Fcitx5](https://fcitx-im.org/) -palvelua, joka on jo käynnissä jokaisessa istunnossa.

### Käytä ALT-näppäintä SUPER-näppäimenä

Joillakin näppäimistöillä ensisijaisen meta-näppäimen (Windows/cmd-näppäimen) käyttäminen SUPER-näppäimenä ei ole kätevää. Voit vaihtaa tämän sen sijaan ALT-näppäimeksi tällä muutoksella:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
