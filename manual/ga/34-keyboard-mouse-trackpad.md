# Méarchlár, Luch, Ceap Tadhaill

Ligeann Hyprland duit d’ionchuir go léir a chumrú go mion. Is féidir leat athrá an mhéarchláir a dhéanamh thar a bheith gasta nó a chur ar an gceap tadhaill scrollú nádúrtha a úsáid. Athraíonn tú é go léir in `~/.config/hypr/input.lua`, ar féidir leat teacht air freisin trí _Socrú > Ionchur_ sa roghchlár Omarchy (`Super + Space`). Tagann aon rud a shocraíonn tú ansin in ionad réamhshocruithe Omarchy.

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

Oibríonn CapsLock mar ghnáth-Caps Lock, agus is é `Shift + CapsLock` an eochair chumadóireachta le haghaidh [emoji gasta](07-hotkeys.md#quick-emojis) agus [comhlánuithe eile](07-hotkeys.md#quick-completions). Más fearr leat an eochair chumadóireachta in áit eile, cuir in ionad `omarchy:shift_caps_compose` in `kb_options`. Mar shampla, bogann sé seo an eochair chumadóireachta go Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gothaí an cheap tadhaill

Svaidhpeáil ar an gceap tadhaill chun bogadh timpeall na deisce:

| Gotha | Gníomh |
| --- | --- |
| Trí mhéar ar chlé / ar dheis | An spás oibre roimhe seo / an chéad spás oibre eile, na cinn fholmha san áireamh |
| Trí mhéar suas | Scoránaigh consól AI |
| Trí mhéar síos | Oscail roghchlár Omarchy |
| Ceithre mhéar ar chlé / ar dheis | Bog an fhuinneog ghníomhach go dtí an spás oibre roimhe seo / an chéad spás oibre eile |
| Ceithre mhéar síos | Scoránaigh lánscáileán |

Chun ceann a athrú, bain a shocrú in `~/.config/hypr/input.lua` sula gcuireann tú do [ghotha ceap tadhaill](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) féin leis, mar ní ghlacfaidh Hyprland le dhá ghotha ar na méara céanna agus sa treo céanna:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Chun gothaí Omarchy go léir a mhúchadh, socraigh `omarchy_default_gestures = false` gar do bharr `~/.config/hypr/hyprland.lua`, sula lódálann réamhshocruithe Omarchy.

Ar ríomhairí glúine Dell XPS a bhfuil ceap tadhaill haptach acu, is féidir leat neart an chliceáil a shocrú go híseal, meánach nó ard faoi _Truicear > Crua-earraí > Haptaic an Cheap Tadhaill_ freisin.

### Clóscríobh sa tSínis, sa tSeapáinis agus i dteangacha eile

Roghnaigh Seapáinis, Cóiréis, Sínis (Simplithe, Pinyin), Taiwan (Zhuyin), nó Hong Kong (Cangjie) nuair a iarrann an suiteálaí ort do mhéarchlár a roghnú. Cumraíonn Omarchy an méarchlár agus an t-inneall ionchuir comhoiriúnach go huathoibríoch, le linn na chéad socraithe tosaithe as líne san áireamh. Úsáideann an tSeapáinis Mozc, úsáideann an Chóiréis Hangul dhá thacar caighdeánach, úsáideann Sínis Simplithe Pinyin, úsáideann Taiwan leagan amach caighdeánach Zhuyin de chuid Chewing, agus úsáideann Hong Kong Cangjie le foirmeacha carachtar Hong Kong. Soláthraíonn Seapáinis (méarchlár US) Mozc le leagan amach méarchláir US. Fanann eochracha Hangul, Zhuyin agus Cangjie ina suíomhanna caighdeánacha fiú nuair a chlóscríobhann tú litreacha Laidineacha le Dvorak, Colemak nó AZERTY. Má chuir tú Hangul nó Chewing leis roimhe seo, díroghnaigh agus athroghnaigh é faoi _Socrú > Clóscríobh > Modhanna Ionchuir_ chun a eochracha a bhogadh ann; fágann Omarchy inneall a chlóscríobhann tú leis cheana féin mar atá sé.

Tosaíonn clóscríobh i mód Laidineach. Brúigh `Super + I` chun dul tríd na modhanna ionchuir cumraithe, agus `Super + Shift + I` chun dul ar ais. Tapaigh `Shift` leis féin chun céim a thógáil amach as modh ionchuir cosúil le Pinyin isteach i litreacha Laidineacha, agus tapaigh arís é chun dul ar ais, an chaoi a n-oibríonn Sogou, Microsoft Pinyin agus macOS; clóscríobhann `Shift` móide litir ceannlitir fós. Ar mhéarchláir Seapánacha, scoránaíonn 全角/半角 an t-ionchur, casann 変換 air é, agus casann 無変換 as é. Leis an gCóiréis, malartaíonn 한/영 Hangul agus tiontaíonn 한자 go Hanja, cibé acu an bhfuil eochracha tiomnaithe ag do mhéarchlár nó an seolann sé Right Alt agus Right Ctrl ar a son, mar a dhéanann go leor ríomhairí glúine, mar sin ní gnáth-mholartóirí iad Right Alt agus Right Ctrl ansin; scoránaíonn deachtú le Alt + Space ina ionad. Fanann `Ctrl + Space` ar fáil do Tmux agus Herdr; fanann `Shift + CapsLock` mar an eochair chumadóireachta.

Tá an táscaire méarchláir le feiceáil ar dheis an bharra nuair a bhíonn leagan amach méarchláir nó modhanna ionchuir iolracha agat. Cliceáil é chun teangacha ionchuir a mhalartú; taispeánann an tSeapáinis あ le haghaidh hiragana. Le haghaidh roghanna carachtar Seapánacha, malartaigh go Seapáinis, clóscríobh focal cosúil le `nihongo`, ansin brúigh Space faoi dhó. Brúigh Enter chun do rogha a ghlacadh. Má tá leagan amach méarchláir iolracha agat freisin, deaschliceáil an táscaire chun dul tríothu.

Úsáid _Socrú > Clóscríobh > Leagan Amach Méarchláir_ chun leagan amach cosúil le Béarla agus Fraincis a roghnú, ó na roghanna céanna a thairgtear le linn na suiteála. Úsáid _Socrú > Clóscríobh > Modhanna Ionchuir_ chun a roghnú cé na hinnill chumadóireachta atá gníomhach. Osclaíonn an dá roghnóir taobh istigh de roghchlár Omarchy agus do roghanna reatha marcáilte. Cliceáil nó brúigh Enter chun rogha a scoránú; tagann gach athrú i bhfeidhm láithreach. Má dhíroghnaíonn tú modh ionchuir, bainfear den timthriall é gan é a dhíshuiteáil; fanann an méarchlár ar fáil.

Rith `omarchy setup keyboard` nó `omarchy setup input` chun na roghnóirí céanna a oscailt. Chun teanga amháin a chur leis ón líne ordaithe, úsáid `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, nó `cangjie5`. Tagann Quick, Boshiamy agus Array sa phacáiste céanna le Cangjie agus tá siad le feiceáil sa roghnóir Modhanna Ionchuir. Coimeádtar do chuid eochracha malartaithe saincheaptha. Le haghaidh leagan amach nó eochracha innill eile, suiteáil `fcitx5-configtool` le `omarchy pkg add fcitx5-configtool` agus lainseáil ó theirminéal é. Ní athraíonn roghnú teanga ionchuir teanga na deisce. Má roghnaíonn tú Seapáinis, Cóiréis nó Sínis faoi _Socrú > Teanga_, cuirfear a modh ionchuir leis nuair nach bhfuil ceann ar bith agat fós.

Úsáid `Super + I` chun dul trí mhodhanna ionchuir nó leagan amach méarchláir, agus `Super + Shift + I` chun dul ar ais an bealach eile, mar sin le trí cinn cumraithe is féidir leat bogadh idir dhá chomharsa. Ní thaispeántar an táscaire ionchuir ar dheis an bharra ach amháin nuair a bhíonn níos mó ná modh ionchuir nó leagan amach amháin cumraithe. Oibríonn an ceangal deisce seo in éineacht le d’eochracha malartaithe Fcitx atá ann cheana; is féidir leat é a shárú in `~/.config/hypr/bindings.lua`. Úsáideann na hinnill ionchuir agus na seichimh chumadóireachta an tseirbhís [Fcitx5](https://fcitx-im.org/) atá ar siúl cheana féin i ngach seisiún.

### Úsáid ALT mar SUPER

Ar roinnt méarchlár, níl sé áisiúil an phríomheochair mheata (eochair Windows/cmd) a úsáid mar SUPER. Is féidir leat é seo a athrú go ALT ina ionad leis an athrú seo:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
