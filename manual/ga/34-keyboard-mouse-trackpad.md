# Méarchlár, Luch, Ceap Tadhaill

Ligeann Hyprland duit d'ionchuir go léir a chumrú go mion. Is féidir leat athrá an mhéarchláir a dhéanamh thar a bheith gasta nó a chur ar an gceap tadhaill scrolláil nádúrtha a úsáid. Athraíonn tú é go léir in `~/.config/hypr/input.lua`, ar féidir leat teacht air freisin trí _Socrú > Ionchur_ sa roghchlár Omarchy (`Super + Space`). Tagann aon rud a shocraíonn tú ann in ionad réamhshocruithe Omarchy.

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

Is féidir leat [na roghanna ionchuir go léir a fheiceáil](https://wiki.hypr.land/Configuring/Basics/Variables/#input) ar wiki Hyprland le haghaidh ionchur.

Oibríonn CapsLock mar ghnáth-Ghlas Caps, agus is é `Shift + CapsLock` an eochair cumadóireachta le haghaidh [emoji gasta](07-hotkeys.md#quick-emojis) agus [comhlánuithe gasta eile](07-hotkeys.md#quick-completions). Más fearr leat an eochair cumadóireachta áit éigin eile, cuir in ionad `omarchy:shift_caps_compose` in `kb_options`. Mar shampla, bogann sé seo an eochair cumadóireachta go Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gothaí ceap tadhaill

Is féidir leat [gothaí ceap tadhaill](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) a chasadh air freisin, amhail svaidhpeáil le trí mhéar chun spásanna oibre a athrú:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Ar ríomhairí glúine Dell XPS a bhfuil ceap tadhaill haptach acu, is féidir leat neart an chlic a shocrú go híseal, meánach, nó ard faoi _Truicear > Crua-earraí > Haptaic an Cheap Tadhaill_.

### Clóscríobh sa tSínis, sa tSeapáinis, agus i dteangacha eile

Roghnaigh Seapáinis, Cóiréis, Sínis (Simplithe, Pinyin), An Téaván (Zhuyin), nó Hong Cong (Cangjie) nuair a fhiafraíonn an suiteálaí díot faoi do mhéarchlár. Cumraíonn Omarchy an méarchlár agus an t-inneall ionchuir meaitseála go huathoibríoch, lena n-áirítear le linn socrú céad-thosaithe as líne. Úsáideann an tSeapáinis Mozc, úsáideann an Chóiréis Hangul caighdeánach dhá thacar, úsáideann Sínis Shimplí Pinyin, úsáideann An Téaván leagan amach caighdeánach Zhuyin Chewing, agus úsáideann Hong Cong Cangjie le foirmeacha carachtar Hong Cong. Soláthraíonn Seapáinis (méarchlár US) Mozc le leagan amach méarchláir US. Fanann eochracha Hangul, Zhuyin, agus Cangjie ina suíomhanna caighdeánacha fiú nuair a chlóscríobhann tú litreacha Laidineacha le Dvorak, Colemak, nó AZERTY. Más rud é gur chuir tú Hangul nó Chewing leis roimhe seo, díroghnaigh agus athroghnaigh é faoi _Socrú > Clóscríobh > Modhanna Ionchuir_ chun a eochracha a bhogadh ann; fágann Omarchy inneall a bhfuil tú ag clóscríobh leis cheana mar atá sé.

Tosaíonn an clóscríobh i mód Laidineach. Brúigh `Super + I` chun rothaíocht a dhéanamh trí mhodhanna ionchuir cumraithe, agus `Super + Shift + I` chun rothaíocht a dhéanamh ar ais. Tapáil `Shift` leis féin chun céim a thógáil amach as modh ionchuir ar nós Pinyin isteach i litreacha Laidineacha, agus tapáil arís é chun dul ar ais, mar a oibríonn Sogou, Microsoft Pinyin, agus macOS; clóscríobhann `Shift` móide litir ceannlitir fós. Ar mhéarchláir Sheapánacha, athraíonn 全角/半角 an t-ionchur, casann 変換 air é, agus casann 無変換 as é. Leis an gCóiréis, athraíonn 한/영 Hangul agus tiontaíonn 한자 go Hanja, cibé acu an bhfuil eochracha tiomnaithe ag do mhéarchlár nó an seolann sé Right Alt agus Right Ctrl dóibh, mar a dhéanann go leor ríomhairí glúine, mar sin ní gnáthmhodhnóirí iad Right Alt agus Right Ctrl ansin; fanann brú-agus-labhair don deachtú ar F9. Fanann `Ctrl + Space` ar fáil do Tmux agus Herdr; fanann `Shift + CapsLock` mar an eochair cumadóireachta.

Taispeántar táscaire an mhéarchláir ar dheis an bharra nuair atá leaganacha amach méarchláir nó modhanna ionchuir iolracha agat. Cliceáil é chun teangacha ionchuir a athrú; taispeánann an tSeapáinis あ do hiragana. Le haghaidh roghanna carachtar Seapánacha, aistrigh go Seapáinis, clóscríobh focal ar nós `nihongo`, ansin brúigh Space faoi dhó. Brúigh Enter chun do rogha a ghlacadh. Má tá leaganacha amach méarchláir iolracha agat freisin, deaschliceáil an táscaire chun rothaíocht a dhéanamh tríothu.

Úsáid _Socrú > Clóscríobh > Leaganacha Amach an Mhéarchláir_ chun leaganacha amach ar nós Béarla agus Fraincis a roghnú, ó na roghanna céanna a thairgtear le linn na suiteála. Úsáid _Socrú > Clóscríobh > Modhanna Ionchuir_ chun a roghnú cé na hinnill cumadóireachta atá gníomhach. Osclaíonn an dá roghnóir taobh istigh de roghchlár Omarchy agus do roghanna reatha marcáilte. Cliceáil nó brúigh Enter chun rogha a scoránú; baineann gach athrú i bhfeidhm láithreach. Má dhíroghnaíonn tú modh ionchuir, baintear den timthriall é gan é a dhíshuiteáil; fanann an méarchlár ar fáil.

Rith `omarchy setup keyboard` nó `omarchy setup input` chun na roghnóirí céanna a oscailt. Chun teanga amháin a chur leis ón líne ordaithe, úsáid `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, nó `cangjie5`. Tagann Quick, Boshiamy, agus Array sa phacáiste céanna le Cangjie agus taispeántar iad sa roghnóir Modhanna Ionchuir. Caomhnaítear d'eochracha malartaithe saincheaptha. Le haghaidh leaganacha amach nó eochracha innill eile, suiteáil `fcitx5-configtool` le `omarchy pkg add fcitx5-configtool` agus lainseáil ó theirminéal é. Ní athraíonn roghnú teanga ionchuir teanga an deisce. Má roghnaíonn tú Seapáinis, Cóiréis, nó Sínis faoi _Socrú > Teanga_, cuireann sí a modh ionchuir leis nuair nach bhfuil ceann agat fós.

Úsáid `Super + I` chun rothaíocht a dhéanamh trí mhodhanna ionchuir nó leaganacha amach méarchláir, agus `Super + Shift + I` chun dul ar ais an bealach eile, mar sin le trí cinn cumraithe is féidir leat bogadh idir dhá chomharsa. Taispeántar táscaire an ionchuir ar dheis an bharra ach amháin nuair atá níos mó ná modh ionchuir nó leagan amach amháin cumraithe. Oibríonn an ceangal deisce seo taobh le d'eochracha malartaithe Fcitx atá ann cheana; is féidir leat é a shárú in `~/.config/hypr/bindings.lua`. Úsáideann na hinnill ionchuir agus na seichimh cumadóireachta an tseirbhís [Fcitx5](https://fcitx-im.org/) atá ag rith cheana i ngach seisiún.

### Úsáid ALT mar SUPER

Ar roinnt méarchlár, níl sé áisiúil an phríomheochair mheata (eochair Windows/cmd) a úsáid mar SUPER. Is féidir leat é seo a athrú go ALT ina ionad leis an athrú seo:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
