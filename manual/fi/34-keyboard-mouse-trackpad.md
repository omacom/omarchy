# Näppäimistö, hiiri, kosketusalusta

Hyprland antaa sinun määrittää kaikki syöttölaitteesi yksityiskohtaisesti. Voit muuttaa näppäimistön toiston yliäänisen nopeaksi tai asettaa kosketusalustan käyttämään luonnollista vieritystä. Muutat kaiken tämän tiedostossa `~/.config/hypr/input.lua`, johon pääset myös Omarchy-valikon kohdan _Setup > Input_ kautta (`Super + Space`). Kaikki, mitä asetat sinne, korvaa Omarchyn oletukset.

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

Voit [katsoa kaikki syöttöasetukset](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprlandin wikistä.

CapsLock toimii normaalina Caps Lockina, ja `Shift + CapsLock` on compose-näppäin [nopeille emojeille](07-hotkeys.md#quick-emojis) ja [muille täydennyksille](07-hotkeys.md#quick-completions). Jos haluat compose-näppäimen mieluummin muualle, korvaa `omarchy:shift_caps_compose` kohdassa `kb_options`. Tämä esimerkiksi siirtää compose-näppäimen Right Alt -näppäimeen:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Toimintonäppäimet

Kannettavan näppäimistön ylärivi lähettää oletuksena medianäppäimet (äänenvoimakkuus, kirkkaus ja niin edelleen), ja `Fn`-näppäimen pitäminen pohjassa antaa F1-F12; `Fn + Esc` lukitsee sen toisin päin, kunnes painat sitä uudelleen. Useimmat näppäimistöt muistavat lukituksen itse. ASUS-kannettavat ja Apple-tyyliset näppäimistöt jättävät sen Linuxille, joka käynnistää ne medianäppäimillä joka käynnistyksellä. Jos haluat niiden käynnistyvän sen sijaan F1-F12-näppäimillä, suorita `omarchy device keyboard toprow fnkeys` (ja `omarchy device keyboard toprow mediakeys` palataksesi takaisin); joissain kannettavissa se tulee voimaan uudelleenkäynnistyksen jälkeen. Apple Silicon Macit säilyttävät oman asetuksensa.

### Kosketusalustan eleet

Pyyhkäise kosketusalustalla liikkuaksesi työpöydällä:

| Ele | Toiminto |
| --- | --- |
| Kolme sormea vasemmalle / oikealle | Edellinen / seuraava työtila, myös tyhjät |
| Kolme sormea ylös | AI-konsolin näyttäminen/piilottaminen |
| Kolme sormea alas | Avaa Omarchy-valikko |
| Neljä sormea vasemmalle / oikealle | Siirrä aktiivinen ikkuna edelliseen / seuraavaan työtilaan |
| Neljä sormea alas | Koko näytön tilan vaihtaminen |

Jos haluat muuttaa yhtä, poista se käytöstä tiedostossa `~/.config/hypr/input.lua` ennen kuin lisäät oman [kosketusalustaeleesi](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), koska Hyprland ei hyväksy kahta elettä samoilla sormilla ja samaan suuntaan:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Jos haluat poistaa kaikki Omarchyn eleet käytöstä, aseta `omarchy_default_gestures = false` tiedoston `~/.config/hypr/hyprland.lua` alkupuolelle, ennen kuin Omarchyn oletukset latautuvat.

Dell XPS -kannettavissa, joissa on haptinen kosketusalusta, voit myös asettaa napsautuksen voimakkuuden alhaiseksi, keskitasoiseksi tai korkeaksi kohdassa _Trigger > Hardware > Touchpad Haptics_.

### Kirjoittaminen kiinaksi, japaniksi ja muilla kielillä

Valitse Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) tai Hong Kong (Cangjie), kun asennusohjelma kysyy näppäimistöäsi. Omarchy määrittää näppäimistön ja sopivan syöttömoottorin automaattisesti, myös offline-tilassa tapahtuvan ensikäynnistyksen määrityksen aikana. Japanese käyttää Mozcia, Korean käyttää tavallista kaksisarjaista Hangulia, Simplified Chinese käyttää Pinyinia, Taiwan käyttää Chewingin tavallista Zhuyin-asettelua ja Hong Kong käyttää Cangjieta Hongkongin merkkimuodoilla. Japanese (US keyboard) tarjoaa Mozcin US-näppäimistöasettelulla. Hangul-, Zhuyin- ja Cangjie-näppäimet pysyvät vakioasemissaan, vaikka kirjoittaisit latinalaisia kirjaimia Dvorakilla, Colemakilla tai AZERTYlla. Jos lisäsit Hangulin tai Chewingin ennen tätä, poista sen valinta ja valitse se uudelleen kohdassa _Setup > Keyboard > Input Methods_ siirtääksesi sen näppäimet sinne; Omarchy jättää jo käyttämäsi moottorin rauhaan.

Kirjoittaminen alkaa Latin-tilassa. Paina `Super + I` selataksesi määritettyjä syöttömenetelmiä ja `Super + Shift + I` selataksesi takaisinpäin. Napauta `Shift`-näppäintä yksinään astuaksesi syöttömenetelmästä, kuten Pinyinista, latinalaisiin kirjaimiin, ja napauta sitä uudelleen palataksesi takaisin, samalla tavalla kuin Sogou, Microsoft Pinyin ja macOS toimivat; `Shift` plus kirjain kirjoittaa silti ison kirjaimen. Japanilaisilla näppäimistöillä 全角/半角 vaihtaa syötön, 変換 kytkee sen päälle ja 無変換 kytkee sen pois päältä. Korean kanssa 한/영 vaihtaa Hanguliin ja 한자 muuntaa Hanjaan, olipa näppäimistössäsi erilliset näppäimet tai lähettääkö se niille Right Alt ja Right Ctrl, kuten monet kannettavat tekevät, joten Right Alt ja Right Ctrl eivät ole siellä pelkkiä muokkausnäppäimiä; sanelu vaihtuu sen sijaan näppäimillä Alt + Space. `Ctrl + Space` pysyy käytettävissä Tmuxille ja Herdrille; `Shift + CapsLock` pysyy compose-näppäimenä.

Näppäimistöilmaisin ilmestyy palkin oikealle puolelle, kun sinulla on useita näppäimistöasetteluja tai syöttömenetelmiä. Napsauta sitä vaihtaaksesi syöttökieliä; Japanese näyttää merkin あ hiraganalle. Japanilaisten merkkien vaihtoehtoja varten vaihda Japaneseen, kirjoita sana kuten `nihongo` ja paina sitten Space kahdesti. Paina Enter hyväksyäksesi valintasi. Jos sinulla on myös useita näppäimistöasetteluja, napsauta ilmaisinta oikealla painikkeella selataksesi niitä.

Käytä kohtaa _Setup > Keyboard > Keyboard Inputs_ valitaksesi asetteluja, kuten English ja French, samoista vaihtoehdoista, joita tarjotaan asennuksen aikana. Käytä kohtaa _Setup > Keyboard > Input Methods_ valitaksesi, mitkä sommittelumoottorit ovat aktiivisia. Molemmat valitsimet avautuvat Omarchy-valikon sisällä nykyiset valintasi valittuina. Napsauta tai paina Enter vaihtaaksesi valinnan; jokainen muutos tulee voimaan välittömästi. Syöttömenetelmän valinnan poistaminen poistaa sen kierrosta poistamatta sitä; näppäimistö pysyy käytettävissä.

Suorita `omarchy setup keyboard` tai `omarchy setup input` avataksesi samat valitsimet. Jos haluat lisätä yhden kielen komentoriviltä, käytä vaihtoehtoja `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` tai `cangjie5`. Quick, Boshiamy ja Array tulevat samassa paketissa kuin Cangjie ja näkyvät Input Methods -valitsimessa. Mukautetut vaihtamisnäppäimesi säilytetään. Vaihtoehtoisia moottorin asetteluja tai näppäimiä varten asenna `fcitx5-configtool` komennolla `omarchy pkg add fcitx5-configtool` ja käynnistä se terminaalista. Syöttökielen valitseminen ei muuta työpöydän kieltä. Japanesen, Koreanin tai Chinesen valitseminen kohdassa _Setup > Region > Language_ lisää sen syöttömenetelmän, kun sinulla ei vielä ole yhtään.

Käytä näppäimiä `Super + I` selataksesi syöttömenetelmiä tai näppäimistöasetteluja ja `Super + Shift + I` mennäksesi toiseen suuntaan, joten kolmen määritetyn kanssa voit liikkua kahden naapurin välillä. Syöttöilmaisin ilmestyy palkin oikealle puolelle vain, kun useampi kuin yksi syöttömenetelmä tai asettelu on määritetty. Tämä työpöydän sidonta toimii olemassa olevien Fcitx-vaihtamisnäppäintesi rinnalla; voit ohittaa sen tiedostossa `~/.config/hypr/bindings.lua`. Syöttömoottorit ja compose-sarjat käyttävät [Fcitx5](https://fcitx-im.org/)-palvelua, joka on jo käynnissä jokaisessa istunnossa.

### Käytä ALT-näppäintä SUPERina

Joissain näppäimistöissä ensisijaista meta-näppäintä (Windows/cmd-näppäintä) ei ole kätevää käyttää SUPERina. Voit muuttaa tämän sen sijaan ALTiksi tällä muutoksella:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
