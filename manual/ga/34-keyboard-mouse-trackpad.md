# Méarchlár, Luch, Trackpad

Ligeann Hyprland duit do chuid ionchur go léir a chumrú go mion. Is féidir leat athdhéanamh an mhéarchláir a dhéanamh thar a bheith gasta nó a chur faoi deara don trackpad scrollú nádúrtha a úsáid. Athraíonn tú é go léir in `~/.config/hypr/input.lua`, ar féidir leat teacht air freisin trí _Socrú > Ionchur_ i roghchlár Omarchy (`Super + Space`). Tagann aon rud a shocraíonn tú ansin in ionad réamhshocruithe Omarchy.

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

Is féidir leat [féach ar na roghanna ionchuir go léir](https://wiki.hypr.land/Configuring/Basics/Variables/#input) ar wiki Hyprland le haghaidh ionchur.

Oibríonn CapsLock mar Caps Lock gnáth, agus is í `Shift + CapsLock` an eochair chumadóireachta le haghaidh [emojianna gasta](07-hotkeys.md#quick-emojis) agus [comhlánaithe eile](07-hotkeys.md#quick-completions). Más fearr leat an eochair chumadóireachta in áit eile, cuir in ionad `omarchy:shift_caps_compose` in `kb_options`. Mar shampla, bogann sé seo an eochair chumadóireachta go Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gothaí trackpad

Svaidhpeáil ar an trackpad chun bogadh timpeall na deisce:

| Gotha | Gníomh |
| --- | --- |
| Trí mhéar ar chlé / ar dheis | An spás oibre roimhe / an chéad spás oibre eile, na cinn fholmha san áireamh |
| Trí mhéar suas | Scoránaigh an consól AI |
| Trí mhéar síos | Oscail roghchlár Omarchy |
| Ceithre mhéar ar chlé / ar dheis | Bog an fhuinneog ghníomhach go dtí an spás oibre roimhe / an chéad spás oibre eile |
| Ceithre mhéar síos | Scoránaigh lánscáileán |

Chun ceann a athrú, díshocraigh in `~/.config/hypr/input.lua` é sula gcuireann tú do [ghotha touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) féin leis, mar ní ghlacfaidh Hyprland le dhá ghotha ar na méara céanna agus sa treo céanna:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Chun gothaí Omarchy go léir a mhúchadh, socraigh `omarchy_default_gestures = false` gar do bharr `~/.config/hypr/hyprland.lua`, sula luchtóidh réamhshocruithe Omarchy.

Ar ríomhairí glúine Dell XPS a bhfuil trackpad haptach acu, is féidir leat neart an chliceála a shocrú go híseal, meánach, nó ard faoi _Truicear > Crua-earraí > Touchpad Haptics_ freisin.

### Clóscríobh i Sínis, i Seapáinis, agus i dteangacha eile

Roghnaigh Seapáinis, Cóiréis, Sínis (Simplithe, Pinyin), Taiwan (Zhuyin), nó Hong Cong (Cangjie) nuair a iarrann an suiteálaí do mhéarchlár ort. Cumraíonn Omarchy an méarchlár agus an t-inneall ionchuir comhfhreagrach go huathoibríoch, le linn socrú chéad-tosaithe as líne freisin. Úsáideann an tSeapáinis Mozc, úsáideann an Chóiréis Hangul caighdeánach dhá thacar, úsáideann Sínis Simplithe Pinyin, úsáideann Taiwan leagan amach caighdeánach Zhuyin Chewing, agus úsáideann Hong Cong Cangjie le foirmeacha carachtar Hong Cong. Soláthraíonn Seapáinis (méarchlár US) Mozc le leagan amach méarchláir US. Fanann eochracha Hangul, Zhuyin, agus Cangjie ina suíomhanna caighdeánacha fiú nuair a chlóscríobhann tú litreacha Laidineacha le Dvorak, Colemak, nó AZERTY. Má chuir tú Hangul nó Chewing leis roimhe seo, díroghnaigh agus athroghnaigh faoi _Socrú > Clóscríobh > Modhanna Ionchuir_ é chun a eochracha a bhogadh ann; ní dhéanann Omarchy aon rud le hinneall a úsáideann tú cheana chun clóscríobh.

Tosaíonn an clóscríobh i mód Laidine. Brúigh `Super + I` chun dul trí na modhanna ionchuir cumraithe, agus `Super + Shift + I` chun dul ar ais. Tapáil `Shift` leis féin chun céim amach as modh ionchuir mar Pinyin isteach i litreacha Laidineacha, agus tapáil arís é chun dul ar ais, ar an mbealach a oibríonn Sogou, Microsoft Pinyin, agus macOS; clóscríobhann `Shift` móide litir ceannlitir fós. Ar mhéarchláir Seapánacha, scoránaíonn 全角/半角 an t-ionchur, casann 変換 air é, agus casann 無変換 as é. Leis an gCóiréis, malartaíonn 한/영 Hangul agus athraíonn 한자 go Hanja é, cibé acu an bhfuil eochracha tiomnaithe ag do mhéarchlár nó an seolann sé Right Alt agus Right Ctrl dóibh, mar a dhéanann go leor ríomhairí glúine, mar sin ní gnáthmhodhnóirí iad Right Alt agus Right Ctrl ansin; fanann deachtú brú-chun-caint ar F9. Fanann `Ctrl + Space` ar fáil do Tmux agus Herdr; fanann `Shift + CapsLock` ina eochair chumadóireachta.

Feictear táscaire an mhéarchláir ar dheis an bharra nuair a bhíonn leaganacha amach méarchláir nó modhanna ionchuir iolracha agat. Cliceáil é chun teangacha ionchuir a mhalartú; taispeánann an tSeapáinis あ le haghaidh hiragana. Le haghaidh roghanna carachtar Seapánacha, malartaigh go Seapáinis, clóscríobh focal mar `nihongo`, ansin brúigh Space faoi dhó. Brúigh Enter chun do rogha a ghlacadh. Má bhíonn leaganacha amach méarchláir iolracha agat freisin, deaschliceáil ar an táscaire chun dul tríothu sin.

Úsáid _Socrú > Clóscríobh > Leaganacha Amach Méarchláir_ chun leaganacha amach mar Béarla agus Fraincis a roghnú, ó na roghanna céanna a thairgtear le linn na suiteála. Úsáid _Socrú > Clóscríobh > Modhanna Ionchuir_ chun a roghnú cé na hinnill chumadóireachta atá gníomhach. Osclaíonn an dá roghnóir taobh istigh de roghchlár Omarchy agus do roghanna reatha marcáilte. Cliceáil nó brúigh Enter chun rogha a scoránú; tagann gach athrú i bhfeidhm láithreach. Má dhíroghnaíonn tú modh ionchuir, bainfear den timthriall é gan é a dhíshuiteáil; fanann an méarchlár ar fáil.

Rith `omarchy setup keyboard` nó `omarchy setup input` chun na roghnóirí céanna a oscailt. Chun teanga amháin a chur leis ón líne ordaithe, úsáid `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, nó `cangjie5`. Tagann Quick, Boshiamy, agus Array sa phacáiste céanna le Cangjie agus feictear iad i roghnóir na Modhanna Ionchuir. Caomhnaítear d'eochracha malartaithe saincheaptha. Le haghaidh leaganacha amach nó eochracha innill malartacha, suiteáil `fcitx5-configtool` le `omarchy pkg add fcitx5-configtool` agus lainseáil ó theirminéal é. Ní athraíonn roghnú teanga ionchuir teanga na deisce. Má roghnaíonn tú Seapáinis, Cóiréis, nó Sínis faoi _Socrú > Teanga_, cuirfear a modh ionchuir leis nuair nach bhfuil ceann ar bith agat fós.

Úsáid `Super + I` chun dul trí mhodhanna ionchuir nó leaganacha amach méarchláir, agus `Super + Shift + I` chun dul ar ais an bealach eile, mar sin le trí cinn cumraithe is féidir leat bogadh idir dhá chomharsa. Ní fheictear táscaire an ionchuir ar dheis an bharra ach amháin nuair atá níos mó ná modh ionchuir nó leagan amach amháin cumraithe. Oibríonn an ceangal deisce seo taobh le d'eochracha malartaithe Fcitx atá ann cheana; is féidir leat é a shárú in `~/.config/hypr/bindings.lua`. Úsáideann na hinnill ionchuir agus na seichimh chumadóireachta seirbhís [Fcitx5](https://fcitx-im.org/) atá ar siúl cheana i ngach seisiún.

### Úsáid ALT mar SUPER

Ar mhéarchláir áirithe, níl sé áisiúil an phríomheochair meta (eochair Windows/cmd) a úsáid mar SUPER. Is féidir leat ALT a chur ina hionad leis an athrú seo:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
