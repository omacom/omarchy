# Méarchlár, Luch, Eochaircheap

Ligeann Hyprland duit d'ionchuir go léir a chumrú go mion. Is féidir leat an t-atriall méarchláir a athrú go thar a bheith tapa nó an t-eochaircheap a chur ag úsáid scrollú nádúrtha. Athraíonn tú é go léir in `~/.config/hypr/input.lua`, ar féidir leat rochtain a fháil air freisin trí _Socrú > Ionchur_ sa roghchlár Omarchy (`Super + Space`). Ionadaíonn aon rud a shocraíonn tú ann réamhshocruithe Omarchy.

Seo sampla:

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

Is féidir leat [na roghanna ionchuir go léir a fheiceáil](https://wiki.hypr.land/Configuring/Basics/Variables/#input) ar vicí Hyprland le haghaidh ionchur.

Oibríonn CapsLock mar Caps Lock gnáth, agus is é `Shift + CapsLock` an eochair chumadóireachta le haghaidh [emoji gasta](07-hotkeys.md#quick-emojis) agus [críochnuithe eile](07-hotkeys.md#quick-completions). Más fhearr leat an eochair chumadóireachta áit eile, ionadaigh `omarchy:shift_caps_compose` in `kb_options`. Mar shampla, bogann sé seo an eochair chumadóireachta go Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gníomhartha eochaircheapa

Is féidir leat [gníomhartha eochaircheapa](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) a chur air freisin, ar nós svaidhpeáil le trí mhéar chun spásanna oibre a athrú:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Ar ríomhairí glúine Dell XPS le heochaircheap haptach, is féidir leat neart an chliceáil a shocrú go híseal, meánach, nó ard faoi _Spreag > Crua-earraí > Haptaic Eochaircheapa_ freisin.

### Clóscríobh i Sínis, Seapáinis, agus teangacha eile

Roghnaigh Seapáinis, Cóiréis, Sínis (Simplithe, Pinyin), nó Sínis (Traidisiúnta, Zhuyin) nuair a iarrann an suiteálaí do mhéarchlár. Cumraíonn Omarchy an méarchlár agus an t-inneall ionchuir meaitseála go huathoibríoch, lena n-áirítear le linn chéadsocrú tosaithe as líne. Úsáideann Seapáinis Mozc, úsáideann Cóiréis Hangul dhá thacar chaighdeánach, úsáideann Sínis Shimplithe Pinyin, agus úsáideann Sínis Thraidisiúnta socrú caighdeánach Zhuyin Chewing. Soláthraíonn Seapáinis (méarchlár Meiriceánach) Mozc le leagan amach méarchláir Meiriceánach.

Tosaíonn clóscríobh i mód Laidineach. Brúigh `Super + I` chun timthriall trí mhodhanna ionchuir cumraithe, agus `Super + Shift + I` chun timthriall ar ais. Tapáil `Shift` leis féin chun céim amach as modh ionchuir ar nós Pinyin isteach i litreacha Laidineacha, agus tapáil arís é chun dul ar ais, ar an mbealach a oibríonn Sogou, Microsoft Pinyin, agus macOS; clóscríobhann `Shift` móide litir ceannlitir fós. Ar mhéarchláir Seapánacha, scoránann 全角/半角 an t-ionchur, casann 変換 air é, agus múchann 無変換 é. Ar leagan amach méarchláir Chóiréach, aistríonn eochracha tiomnaithe 한/영 agus 한자 Hangul agus tiontaíonn siad go Hanja. Fanann `Ctrl + Space` ar fáil do Tmux agus Herdr; fanann `Shift + CapsLock` mar an eochair chumadóireachta.

Taispeántar an táscaire méarchláir ar thaobh deas an bharra nuair atá illleagan amach méarchláir nó modhanna ionchuir agat. Cliceáil air chun teangacha ionchuir a athrú; taispeánann Seapáinis あ le haghaidh hiragana. Le haghaidh roghanna carachtar Seapánacha, aistrigh go Seapáinis, clóscríobh focal ar nós `nihongo`, ansin brúigh Space faoi dhó. Brúigh Enter chun do rogha a ghlacadh. Má tá illleagan amach méarchláir agat freisin, deaschliceáil ar an táscaire chun timthriall tríothu sin.

Úsáid _Socrú > Clóscríobh > Leaganacha Amach Méarchláir_ chun leaganacha amach ar nós Béarla agus Fraincis a roghnú, ó na roghanna céanna a ofráiltear le linn suiteála. Úsáid _Socrú > Clóscríobh > Modhanna Ionchuir_ chun a roghnú cé na hinnill cumadóireachta atá gníomhach. Osclaíonn an dá roghnóir taobh istigh de roghchlár Omarchy le do roghanna reatha seiceáilte. Cliceáil nó brúigh Enter chun rogha a scoránú; baineann gach athrú feidhm láithreach. Baineann díchroghnú modh ionchuir as an timthriall gan é a dhíshuiteáil; fanann an méarchlár ar fáil.

Rith `omarchy setup keyboard` nó `omarchy setup input` chun na roghnóirí céanna a oscailt. Chun teanga amháin a chur leis ón líne ordaithe, úsáid `omarchy setup input mozc`, `hangul`, `pinyin`, nó `chewing`. Caomhnaítear do heochracha aistrithe saincheaptha. Le haghaidh leaganacha amach nó eochracha malartacha inneall, suiteáil `fcitx5-configtool` le `omarchy pkg add fcitx5-configtool` agus lainseáil é ó theirminéal. Ní athraíonn roghnú teanga ionchuir teanga na deisce.

Úsáid `Super + I` chun timthriall trí mhodhanna ionchuir nó leaganacha amach méarchláir, agus `Super + Shift + I` chun dul an bealach eile, mar sin le trí cinn cumraithe is féidir leat bogadh idir beirt chomharsan. Ní thaispeántar an táscaire ionchuir ar thaobh deas an bharra ach nuair atá níos mó ná modh ionchuir nó leagan amach amháin cumraithe. Oibríonn an nasc deisce seo mar aon le do heochracha aistrithe Fcitx reatha; is féidir leat é a shárú in `~/.config/hypr/bindings.lua`. Úsáideann innill ionchuir agus na seichimh chumadóireachta an tseirbhís [Fcitx5](https://fcitx-im.org/) atá ag rith cheana i ngach seisiún.

### Úsáid ALT mar SUPER

Ar roinnt méarchláir, níl sé áisiúil an phríomh-eochair meta (eochair Windows/cmd) a úsáid mar SUPER. Is féidir leat é seo a athrú go ALT ina ionad tríd an athrú seo a úsáid:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
