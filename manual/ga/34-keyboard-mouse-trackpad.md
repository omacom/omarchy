# Méarchlár, Luch, Ceap Tadhaill

Ligeann Hyprland duit d'ionchuir go léir a chumrú go mion. Is féidir leat athdhéanamh an mhéarchláir a dhéanamh thar a bheith gasta nó scrolláil nádúrtha a chur ar an gceap tadhaill. Athraíonn tú é go léir i `~/.config/hypr/input.lua`, ar féidir leat teacht air freisin trí _Setup > Input_ sa roghchlár Omarchy (`Super + Space`). Tagann aon rud a shocraíonn tú ansin in ionad réamhshocruithe Omarchy.

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

Is féidir leat [gach rogha ionchuir a fheiceáil](https://wiki.hypr.land/Configuring/Basics/Variables/#input) ar wiki Hyprland le haghaidh ionchur.

Oibríonn CapsLock mar Caps Lock gnáth, agus is é `Shift + CapsLock` an eochair chumadóireachta le haghaidh [emoji gasta](07-hotkeys.md#quick-emojis) agus [comhlánaithe eile](07-hotkeys.md#quick-completions). Más fearr leat an eochair chumadóireachta in áit eile, cuir in ionad `omarchy:shift_caps_compose` in `kb_options`. Mar shampla, bogann sé seo an eochair chumadóireachta go Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Eochracha feidhme

Seolann sraith uachtarach mhéarchlár ríomhaire glúine na heochracha meán (toirt, gile agus mar sin de) de réir réamhshocraithe, agus tugann `Fn` a choinneáil síos F1-F12 duit; glasálann `Fn + Esc` é sa treo eile go dtí go mbrúnn tú arís é. Cuimhníonn formhór na méarchlár ar an nglas sin iad féin. Fágann ríomhairí glúine ASUS agus méarchláir ar stíl Apple faoi Linux é, a thosaíonn ar na heochracha meán iad ag gach tosú. Chun go dtosóidh siad ar F1-F12 ina ionad sin, rith `omarchy keyboard toprow fnkeys` (agus `omarchy keyboard toprow mediakeys` chun dul ar ais); ar roinnt ríomhairí glúine, tagann sé i bhfeidhm tar éis atosaigh. Coinníonn Apple Silicon Macs a socrú féin.

### Gothaí an cheap tadhaill

Svaidhpeáil ar an gceap tadhaill chun bogadh timpeall na deisce:

| Gotha | Gníomh |
| --- | --- |
| Trí mhéar ar chlé / ar dheis | An spás oibre roimhe / an chéad spás oibre eile, cinn fholmha san áireamh |
| Trí mhéar suas | Scoránaigh an consól AI |
| Trí mhéar síos | Oscail roghchlár Omarchy |
| Ceithre mhéar ar chlé / ar dheis | Bog an fhuinneog ghníomhach chuig an spás oibre roimhe / an chéad spás oibre eile |
| Ceithre mhéar síos | Scoránaigh lánscáileán |

Chun ceann a athrú, díshocraigh é i `~/.config/hypr/input.lua` sula gcuireann tú do [ghotha ceap tadhaill](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) féin leis, mar ní ghlacfaidh Hyprland le dhá ghotha ar na méara céanna agus sa treo céanna:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Chun gach gotha de chuid Omarchy a mhúchadh, socraigh `omarchy_default_gestures = false` gar do bharr `~/.config/hypr/hyprland.lua`, sula luchtóidh réamhshocruithe Omarchy.

Ar ríomhairí glúine Dell XPS a bhfuil ceap tadhaill haptach acu, is féidir leat neart an chlic a shocrú go híseal, meánach, nó ard faoi _Trigger > Hardware > Touchpad Haptics_ freisin.

### Clóscríobh i Sínis, i Seapáinis, agus i dteangacha eile

Roghnaigh Seapáinis, Cóiréis, Sínis (Simplí, Pinyin), Taiwan (Zhuyin), nó Hong Cong (Cangjie) nuair a fhiafraíonn an suiteálaí díot faoi do mhéarchlár. Cumraíonn Omarchy an méarchlár agus an t-inneall ionchuir comhoiriúnach go huathoibríoch, le linn socrú an chéad tosaithe as líne san áireamh. Úsáideann an tSeapáinis Mozc, úsáideann an Chóiréis Hangul caighdeánach dhá thacar, úsáideann Sínis Shimplithe Pinyin, úsáideann Taiwan leagan amach caighdeánach Zhuyin de chuid Chewing, agus úsáideann Hong Cong Cangjie le foirmeacha carachtar Hong Cong. Soláthraíonn Seapáinis (méarchlár US) Mozc le leagan amach méarchláir US. Fanann eochracha Hangul, Zhuyin, agus Cangjie ina suíomhanna caighdeánacha fiú nuair a chlóscríobhann tú litreacha Laidineacha le Dvorak, Colemak, nó AZERTY. Má chuir tú Hangul nó Chewing leis roimhe seo, díroghnaigh agus athroghnaigh é faoi _Setup > Keyboard > Input Methods_ chun a eochracha a bhogadh ann; fágann Omarchy inneall a bhfuil tú ag clóscríobh leis cheana féin mar atá sé.

Cuirtear tús leis an gclóscríobh i mód Laidineach. Brúigh `Super + I` chun rothaíocht trí na modhanna ionchuir cumraithe, agus `Super + Shift + I` chun rothaíocht ar ais. Tapáil `Shift` leis féin chun céim amach as modh ionchuir ar nós Pinyin go litreacha Laidineacha, agus tapáil arís é chun dul ar ais, mar a oibríonn Sogou, Microsoft Pinyin, agus macOS; clóscríobhann `Shift` móide litir ceannlitir fós. Ar mhéarchláir Sheapánacha, scoránaíonn 全角/半角 an t-ionchur, casann 変換 air é, agus casann 無変換 as é. Le Cóiréis, aistríonn 한/영 Hangul agus athraíonn 한자 go Hanja, cibé acu an bhfuil eochracha tiomnaithe ag do mhéarchlár nó an seolann sé Right Alt agus Right Ctrl dóibh, mar a dhéanann go leor ríomhairí glúine, mar sin ní modhnóirí simplí iad Right Alt agus Right Ctrl ansin; scoránaíonn deachtú le Alt + Space ina ionad sin. Fanann `Ctrl + Space` ar fáil do Tmux agus Herdr; fanann `Shift + CapsLock` mar an eochair chumadóireachta.

Feictear táscaire an mhéarchláir ar dheis an bharra nuair a bhíonn leaganacha amach méarchláir nó modhanna ionchuir iolracha agat. Cliceáil é chun teangacha ionchuir a aistriú; taispeánann an tSeapáinis あ le haghaidh hiragana. Le haghaidh roghanna carachtar Seapánacha, aistrigh go Seapáinis, clóscríobh focal ar nós `nihongo`, ansin brúigh Space faoi dhó. Brúigh Enter chun do rogha a ghlacadh. Má tá leaganacha amach méarchláir iolracha agat freisin, deaschliceáil an táscaire chun rothaíocht tríothu sin.

Úsáid _Setup > Keyboard > Keyboard Inputs_ chun leaganacha amach ar nós Béarla agus Fraincis a roghnú, ó na roghanna céanna a thairgtear le linn na suiteála. Úsáid _Setup > Keyboard > Input Methods_ chun a roghnú cé na hinnill cumadóireachta atá gníomhach. Osclaíonn an dá roghnóir taobh istigh de roghchlár Omarchy agus do roghanna reatha marcáilte. Cliceáil nó brúigh Enter chun rogha a scoránú; tagann gach athrú i bhfeidhm láithreach. Má dhíroghnaíonn tú modh ionchuir, baintear as an rothlú é gan é a dhíshuiteáil; fanann an méarchlár ar fáil.

Rith `omarchy setup keyboard` nó `omarchy setup input` chun na roghnóirí céanna a oscailt. Chun teanga amháin a chur leis ón líne ordaithe, úsáid `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, nó `cangjie5`. Tagann Quick, Boshiamy, agus Array sa phacáiste céanna le Cangjie agus feictear iad sa roghnóir Input Methods. Caomhnaítear d'eochracha aistrithe saincheaptha. Le haghaidh leaganacha amach nó eochracha innill malartacha, suiteáil `fcitx5-configtool` le `omarchy pkg add fcitx5-configtool` agus lainseáil ó theirminéal é. Ní athraíonn roghnú teanga ionchuir teanga na deisce. Má roghnaíonn tú Seapáinis, Cóiréis, nó Sínis faoi _Setup > Language_, cuirtear a modh ionchuir leis nuair nach bhfuil ceann agat fós.

Úsáid `Super + I` chun rothaíocht trí mhodhanna ionchuir nó leaganacha amach méarchláir, agus `Super + Shift + I` chun dul ar ais an bealach eile, mar sin le trí cinn cumraithe is féidir leat bogadh idir dhá chomharsa. Ní fheictear táscaire an ionchuir ar dheis an bharra ach amháin nuair a bhíonn níos mó ná modh ionchuir nó leagan amach amháin cumraithe. Oibríonn an ceangal deisce seo in éineacht le d'eochracha aistrithe Fcitx atá ann cheana; is féidir leat é a shárú i `~/.config/hypr/bindings.lua`. Úsáideann na hinnill ionchuir agus na seichimh chumadóireachta an tseirbhís [Fcitx5](https://fcitx-im.org/) atá ar siúl cheana i ngach seisiún.

### Úsáid ALT mar SUPER

Ar roinnt méarchlár, níl sé áisiúil an phríomheochair meta (eochair Windows/cmd) a úsáid mar SUPER. Is féidir leat é seo a athrú go ALT ina ionad sin leis an athrú seo:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
