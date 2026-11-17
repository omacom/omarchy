# Näppäimistö, hiiri, kosketuslevy

Hyprland antaa määrittää kaikki syöttölaitteesi erittäin tarkasti. Voit tehdä näppäimistön toistosta yliäänennopean tai asettaa kosketuslevyn käyttämään luonnollista vieritystä. Muutat kaiken tämän tiedostossa `~/.config/hypr/input.lua`, johon pääset myös Omarchy-valikon kautta kohdasta _Setup > Input_ (`Super + Space`). Kaikki sinne asettamasi korvaa Omarchyn oletukset.

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

Voit [katsoa kaikki syöttöasetukset](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprlandin syöttöjä koskevasta wikistä.

CapsLock toimii tavallisena Caps Lock -näppäimenä, ja `Shift + CapsLock` on koostamisnäppäin [nopeille emojeille](07-hotkeys.md#quick-emojis) ja [muille täydennyksille](07-hotkeys.md#quick-completions). Jos haluat koostamisnäppäimen mieluummin muualle, korvaa `omarchy:shift_caps_compose` kohdassa `kb_options`. Tämä esimerkiksi siirtää koostamisnäppäimen Right Alt -näppäimeen:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Toimintonäppäimet

Kannettavan näppäimistön ylärivi lähettää oletuksena medianäppäimet (äänenvoimakkuus, kirkkaus ja niin edelleen), ja `Fn`-näppäimen pohjassa pitäminen antaa F1-F12; `Fn + Esc` lukitsee sen toisin päin, kunnes painat sitä uudelleen. Useimmat näppäimistöt muistavat lukituksen itse. ASUS-kannettavat ja Apple-tyyliset näppäimistöt jättävät sen Linuxille, joka käynnistää ne medianäppäimillä joka käynnistyksellä. Jos haluat niiden käynnistyvän sen sijaan F1-F12-näppäimillä, aja `omarchy keyboard toprow fnkeys` (ja `omarchy keyboard toprow mediakeys` palataksesi takaisin); joissakin kannettavissa muutos tulee voimaan uudelleenkäynnistyksen jälkeen. Apple Silicon -Macit säilyttävät oman asetuksensa.

### Kosketuslevyn eleet

Liiku työpöydällä pyyhkäisemällä kosketuslevyllä:

| Ele | Toiminto |
| --- | --- |
| Kolme sormea vasemmalle / oikealle | Edellinen / seuraava työtila, myös tyhjät |
| Kolme sormea ylös | AI-konsoli päälle/pois |
| Kolme sormea alas | Omarchy-valikon avaaminen |
| Neljä sormea vasemmalle / oikealle | Aktiivisen ikkunan siirtäminen edelliseen / seuraavaan työtilaan |
| Neljä sormea alas | Koko näyttö päälle/pois |

Muuttaaksesi yhtä, poista se käytöstä tiedostossa `~/.config/hypr/input.lua` ennen oman [kosketuslevyeleen](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) lisäämistä, koska Hyprland ei hyväksy kahta elettä samoille sormille ja samaan suuntaan:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Kytkeäksesi kaikki Omarchyn eleet pois päältä aseta `omarchy_default_gestures = false` lähelle tiedoston `~/.config/hypr/hyprland.lua` alkua, ennen kuin Omarchyn oletukset latautuvat.

Dell XPS -kannettavissa, joissa on haptinen kosketuslevy, voit myös asettaa napsautuksen voimakkuuden matalaksi, keskitasoiseksi tai korkeaksi kohdassa _Trigger > Hardware > Touchpad Haptics_.

### Kiinaksi, japaniksi ja muilla kielillä kirjoittaminen

Valitse japani, korea, kiina (yksinkertaistettu, Pinyin), Taiwan (Zhuyin) tai Hongkong (Cangjie), kun asentaja kysyy näppäimistöäsi. Omarchy määrittää näppäimistön ja vastaavan syöttömoottorin automaattisesti, myös offline-tilassa tehtävän ensimmäisen käynnistyksen asennuksen aikana. Japani käyttää Mozcia, korea tavallista kaksisarjaista Hangulia, yksinkertaistettu kiina Pinyiniä, Taiwan Chewingin tavallista Zhuyin-asettelua ja Hongkong Cangjieta Hongkongin merkkimuodoilla. Japani (US-näppäimistö) tarjoaa Mozcin US-näppäimistöasettelulla. Hangul-, Zhuyin- ja Cangjie-näppäimet pysyvät vakioasemissaan, vaikka kirjoittaisit latinalaisia kirjaimia Dvorakilla, Colemakilla tai AZERTYlla. Jos lisäsit Hangulin tai Chewingin ennen tätä, poista sen valinta ja valitse se uudelleen kohdassa _Setup > Keyboard > Input Methods_ siirtääksesi sen näppäimet sinne; Omarchy jättää moottorin, jolla jo kirjoitat, rauhaan.

Kirjoittaminen alkaa latinalaisessa tilassa. Paina `Super + I` selataksesi määritettyjä syöttömenetelmiä ja `Super + Shift + I` selataksesi takaisinpäin. Napauta pelkkää `Shift`-näppäintä astuaksesi ulos Pinyinin kaltaisesta syöttömenetelmästä latinalaisiin kirjaimiin, ja napauta sitä uudelleen palataksesi takaisin, kuten Sogou, Microsoft Pinyin ja macOS toimivat; `Shift` plus kirjain kirjoittaa silti ison kirjaimen. Japanilaisilla näppäimistöillä 全角/半角 vaihtaa syöttöä, 変換 kytkee sen päälle ja 無変換 kytkee sen pois. Korean kanssa 한/영 vaihtaa Hanguliin ja 한자 muuntaa Hanjaan, olipa näppäimistössäsi erilliset näppäimet niitä varten tai lähettääkö se niitä varten Right Alt ja Right Ctrl, kuten monet kannettavat tekevät, joten Right Alt ja Right Ctrl eivät ole siellä tavallisia muokkausnäppäimiä; sanelu vaihtuu sen sijaan näppäimillä Alt + Space. `Ctrl + Space` pysyy käytettävissä Tmuxille ja Herdrille; `Shift + CapsLock` pysyy koostamisnäppäimenä.

Näppäimistöilmaisin ilmestyy palkin oikealle puolelle, kun sinulla on useita näppäimistöasetteluja tai syöttömenetelmiä. Napsauta sitä vaihtaaksesi syöttökieliä; japani näyttää merkin あ hiraganana. Saat japanilaiset merkkivalinnat esiin vaihtamalla japaniin, kirjoittamalla sanan, kuten `nihongo`, ja painamalla sitten Space kahdesti. Hyväksy valintasi painamalla Enter. Jos sinulla on myös useita näppäimistöasetteluja, selaa niitä napsauttamalla ilmaisinta hiiren oikealla painikkeella.

Käytä kohtaa _Setup > Keyboard > Keyboard Inputs_ valitaksesi asetteluja, kuten englanti ja ranska, samoista vaihtoehdoista, joita tarjotaan asennuksen aikana. Käytä kohtaa _Setup > Keyboard > Input Methods_ valitaksesi, mitkä koostamisemoottorit ovat aktiivisia. Molemmat valitsimet avautuvat Omarchy-valikon sisällä nykyiset valintasi valittuina. Napsauta tai paina Enter vaihtaaksesi valintaa; jokainen muutos tulee voimaan välittömästi. Syöttömenetelmän valinnan poistaminen poistaa sen kierrosta asentamatta sitä uudelleen; näppäimistö pysyy käytettävissä.

Aja `omarchy setup keyboard` tai `omarchy setup input` avataksesi samat valitsimet. Lisää yksi kieli komentoriviltä komennolla `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` tai `cangjie5`. Quick, Boshiamy ja Array tulevat samassa paketissa kuin Cangjie ja näkyvät Input Methods -valitsimessa. Mukautetut vaihtamisnäppäimesi säilytetään. Jos haluat vaihtoehtoisia moottorin asetteluja tai näppäimiä, asenna `fcitx5-configtool` komennolla `omarchy pkg add fcitx5-configtool` ja käynnistä se päätteestä. Syöttökielen valitseminen ei muuta työpöydän kieltä. Japanin, korean tai kiinan valitseminen kohdassa _Setup > Language_ lisää sen syöttömenetelmän, kun sinulla ei vielä ole yhtään.

Käytä näppäimiä `Super + I` syöttömenetelmien tai näppäimistöasettelujen selaamiseen ja näppäimiä `Super + Shift + I` palataksesi toiseen suuntaan, joten kolmen määritetyn kanssa voit liikkua kahden naapurin välillä. Syöttöilmaisin ilmestyy palkin oikealle puolelle vain, kun määritettynä on useampi kuin yksi syöttömenetelmä tai asettelu. Tämä työpöytäsidonta toimii olemassa olevien Fcitx-vaihtamisnäppäintesi rinnalla; voit ohittaa sen tiedostossa `~/.config/hypr/bindings.lua`. Syöttömoottorit ja koostamisjaksot käyttävät [Fcitx5](https://fcitx-im.org/) -palvelua, joka on jo käynnissä jokaisessa istunnossa.

### Käytä ALT-näppäintä SUPER-näppäimenä

Joissakin näppäimistöissä ensisijaisen metanäppäimen (Windows/cmd-näppäin) käyttäminen SUPER-näppäimenä ei ole kätevää. Voit muuttaa tämän sen sijaan ALT-näppäimeksi tällä muutoksella:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
