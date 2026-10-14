# Näppäimistö, hiiri, kosketuslevy

Hyprland antaa sinun määrätä kaikki syöttölaitteesi suuressa yksityiskohtaisuudessa. Voit muuttaa näppäimistön toiston yliäänisen nopeaksi tai saada kosketuslevyn käyttämään luonnollista vieritystä. Muutat kaiken sen tiedostossa `~/.config/hypr/input.lua`, johon pääset myös Omarchy-valikon (`Super + Space`) kohdan _Asetukset > Syöttö_ kautta. Kaikki, minkä asetat sinne, korvaa Omarchyn oletukset.

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

Voit [nähdä kaikki syöttövaihtoehdot](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprlandin syöttöjen wikissä.

CapsLock toimii tavallisena Caps Lockina, ja `Shift + CapsLock` on compose-näppäin [pika-emojeille](07-hotkeys.md#quick-emojis) ja [muille täydennyksille](07-hotkeys.md#quick-completions). Jos haluat compose-näppäimen mieluummin muualle, korvaa `omarchy:shift_caps_compose` kentässä `kb_options`. Esimerkiksi tämä siirtää compose-näppäimen oikealle Alt-näppäimelle:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Kosketuslevyn eleet

Voit myös kytkeä päälle [kosketuslevyn eleitä](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), kuten kolmen sormen pyyhkimisen työtilojen vaihtamiseksi:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Dell XPS -kannettavissa, joissa on haptinen kosketuslevy, voit myös asettaa napsautusvoiman matalaksi, keskitason tai korkeaksi kohdassa _Käynnistä > Laitteisto > Kosketuslevyn haptiikka_.

### Kirjoittaminen kiinaksi, japaniksi ja muilla kielillä

Valitse japani, korea, kiina (yksinkertaistettu, Pinyin) tai kiina (perinteinen, Zhuyin), kun asentaja kysyy näppäimistöäsi. Omarchy määrää näppäimistön ja vastaavan syöttömoottorin automaattisesti, myös offline-ensikäynnistyksen käyttöönoton aikana. Japani käyttää Mozcia, korea käyttää tavallista kaksisarjaista Hangulia, yksinkertaistettu kiina käyttää Pinyiniä ja perinteinen kiina käyttää Chewingin vakio-Zhuyin-asettelua. Japanese (US keyboard) tarjoaa Mozcin yhdessä US-näppäinasettelun kanssa.

Kirjoittaminen alkaa latinalaisessa tilassa. Paina `Super + I` käydäksesi läpi määrätyt syöttömenetelmät ja `Super + Shift + I` käydäksesi takaisin. Napauta `Shift`iä yksinään astuaksesi ulos syöttömenetelmästä, kuten Pinyinistä, latinalaisiin kirjaimiin, ja napauta sitä uudelleen palataksesi, sillä tavalla kuin Sogou, Microsoft Pinyin ja macOS toimivat; `Shift` plus kirjain kirjoittaa silti suuren alkukirjaimen. Japanilaisissa näppäimistöissä 全角/半角 kytkee syötteen, 変換 kytkee sen päälle ja 無変換 kytkee sen pois. Korealaisessa näppäinasettelussa omistetut näppäimet 한/영 ja 한자 vaihtavat Hangulin ja muuntavat Hanjaksi. `Ctrl + Space` pysyy saatavilla Tmuxille ja Herdrille; `Shift + CapsLock` pysyy compose-näppäimenä.

Näppäimistöilmaisin ilmestyy palkin oikealle puolelle, kun sinulla on useita näppäinasetteluja tai syöttömenetelmiä. Napsauta sitä vaihtaaksesi syöttökieliä; japani näyttää merkin あ hiraganaa varten. Japanilaisia merkkivalintoja varten vaihda japaniin, kirjoita sana, kuten `nihongo`, ja paina sitten Spacea kahdesti. Paina Enter hyväksyäksesi valintasi. Jos sinulla on myös useita näppäinasetteluja, napsauta ilmaisintä hiiren kakkospainikkeella käydäksesi ne läpi.

Käytä kohtaa _Asetukset > Kirjoittaminen > Näppäinasettelut_ valitaksesi asetteluja, kuten englannin ja ranskan, samoista vaihtoehdoista, joita tarjotaan asennuksen aikana. Käytä kohtaa _Asetukset > Kirjoittaminen > Syöttömenetelmät_ valitaksesi, mitkä koostusmoottorit ovat aktiivisia. Molemmat valitsimet avautuvat Omarchy-valikon sisällä nykyisten valintojesi ollessa valittuina. Napsauta tai paina Enter kytkeäksesi vaihtoehdon; jokainen muutos tulee voimaan heti. Syöttömenetelmän valinnan poistaminen poistaa sen kierrosta poistamatta sitä; näppäimistö pysyy saatavilla.

Aja `omarchy setup keyboard` tai `omarchy setup input` avataksesi samat valitsimet. Liittääksesi yhden kielen komentoriviltä käytä komentoja `omarchy setup input mozc`, `hangul`, `pinyin` tai `chewing`. Mukautetut vaihtamisnäppäimesi säilytetään. Vaihtoehtoisia moottoriasetteluja tai näppäimiä varten asenna `fcitx5-configtool` komennolla `omarchy pkg add fcitx5-configtool` ja käynnistä se päätteestä. Syöttökielen valitseminen ei muuta työpöydän kieltä.

Käytä näppäimiä `Super + I` käydäksesi läpi syöttömenetelmiä tai näppäinasetteluja ja `Super + Shift + I` mennäksesi toisin päin, joten kolmen ollessa määrättyinä voit liikkua kahden naapurin välillä. Syöttöilmaisin ilmestyy palkin oikealle puolelle vain, kun on määrätty useampia kuin yksi syöttömenetelmä tai asettelu. Tämä työpöytäsidonta toimii olemassa olevien Fcitx-vaihtamisnäppäintesi rinnalla; voit ohittaa sen tiedostossa `~/.config/hypr/bindings.lua`. Syöttömoottorit ja compose-sekvenssit käyttävät [Fcitx5](https://fcitx-im.org/) -palvelua, joka on jo käynnissä jokaisessa istunnossa.

### ALTin käyttäminen SUPERinä

Joissakin näppäimistöissä ei ole kätevää käyttää ensisijaista meta-näppäintä (Windows/cmd-näppäin) SUPERinä. Voit muuttaa sen sen sijaan ALTiksi tällä muutoksella:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
