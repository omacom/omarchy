# Méarchlár, Luch, Painéal Tadhaill

Ceadaíonn Hyprland duit d’ionchuir uile a chumrú go han-mhion. Is féidir leat athrá an mhéarchláir a dhéanamh sárthapa nó scrollú nádúrtha a chur in úsáid ar an bpainéal tadhaill. Athraíonn tú é sin uile i `~/.config/hypr/input.lua`, ar féidir leat teacht air freisin trí _Setup > Input_ i roghchlár Omarchy (`Super + Space`). Tagann aon rud a shocraíonn tú ansin in áit réamhshocruithe Omarchy.

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

Oibríonn CapsLock mar Caps Lock gnáth, agus is é `Shift + CapsLock` an eochair cumadóireachta le haghaidh [emoji tapa](07-hotkeys.md#quick-emojis) agus [comhlánuithe eile](07-hotkeys.md#quick-completions). Más fearr leat an eochair cumadóireachta in áit eile, cuir i gceist `omarchy:shift_caps_compose` i `kb_options`. Mar shampla, bogann sé seo an eochair cumadóireachta go Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Eochracha feidhme

Seolann an tsraith uachtarach ar mhéarchlár ríomhaire glúine na heochracha meán (toirt, gile agus mar sin de) de réir réamhshocruithe, agus tugann `Fn` a choinneáil síos F1-F12 duit; glasálann `Fn + Esc` é an treo eile timpeall go dtí go mbrúnn tú arís é. Cuimhníonn formhór na méarchlár ar an nglas sin iad féin. Fágann ríomhairí glúine ASUS agus méarchláir ar stíl Apple faoi Linux é, a thosaíonn iad ar na heochracha meán ag gach tosú. Chun go dtosóidh siad ar F1-F12 ina ionad sin, rith `omarchy device keyboard toprow fnkeys` (agus `omarchy device keyboard toprow mediakeys` chun dul ar ais); ar roinnt ríomhairí glúine ní thagann sé i bhfeidhm go dtí tar éis atosaithe. Coinníonn Macs Apple Silicon a socrú féin.

### Gothaí painéil tadhaill

Svaidhpeáil ar an bpainéal tadhaill chun bogadh timpeall na deisce:

| Gotha | Gníomh |
| --- | --- |
| Trí mhéar ar chlé / ar dheis | An spás oibre roimhe / an chéad spás oibre eile, cinn fholmha san áireamh |
| Trí mhéar suas | Scoránaigh an consól AI |
| Trí mhéar síos | Oscail roghchlár Omarchy |
| Ceithre mhéar ar chlé / ar dheis | Bog an fhuinneog ghníomhach chuig an spás oibre roimhe / an chéad spás oibre eile |
| Ceithre mhéar síos | Scoránaigh lánscáileán |

Chun ceann a athrú, díchumraigh é i `~/.config/hypr/input.lua` sula gcuireann tú do [ghotha painéil tadhaill](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) féin leis, mar ní ghlacfaidh Hyprland le dhá ghotha ar na méara céanna agus sa treo céanna:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Chun gothaí uile Omarchy a mhúchadh, socraigh `omarchy_default_gestures = false` gar do bharr `~/.config/hypr/hyprland.lua`, sula luchtóidh réamhshocruithe Omarchy.

Ar ríomhairí glúine Dell XPS a bhfuil painéal tadhaill haptach acu, is féidir leat neart an chliceáil a shocrú go híseal, meánach nó ard faoi _Trigger > Hardware > Touchpad Haptics_ freisin.

### Clóscríobh i Sínis, i Seapáinis agus i dteangacha eile

Roghnaigh Seapáinis, Cóiréis, Sínis (Simplithe, Pinyin), an Téaváin (Zhuyin) nó Hong Kong (Cangjie) nuair a iarrann an suiteálaí do mhéarchlár ort. Cumraíonn Omarchy an méarchlár agus an t-inneall ionchuir comhoiriúnach go huathoibríoch, le linn socrú céad-tosaithe as líne san áireamh. Úsáideann an tSeapáinis Mozc, úsáideann an Chóiréis Hangul caighdeánach dhá thacar, úsáideann Sínis Shimplí Pinyin, úsáideann an Téaváin leagan amach caighdeánach Zhuyin Chewing, agus úsáideann Hong Kong Cangjie le foirmeacha carachtar Hong Kong. Soláthraíonn Seapáinis (méarchlár US) Mozc le leagan amach méarchláir US. Fanann eochracha Hangul, Zhuyin agus Cangjie ina suíomhanna caighdeánacha fiú nuair a chlóscríobhann tú litreacha Laidineacha le Dvorak, Colemak nó AZERTY. Más rud é gur chuir tú Hangul nó Chewing leis roimhe seo, díchumasaigh agus roghnaigh arís é faoi _Setup > Keyboard > Input Methods_ chun a eochracha a bhogadh ansin; fágann Omarchy inneall a bhfuil tú ag clóscríobh leis cheana féin mar atá sé.

Tosaíonn an clóscríobh i mód Laidineach. Brúigh `Super + I` chun dul tríd na modhanna ionchuir cumraithe, agus `Super + Shift + I` chun dul tríd ar gcúl. Tapáil `Shift` leis féin chun céim amach as modh ionchuir ar nós Pinyin go litreacha Laidineacha, agus tapáil arís é chun dul ar ais, ar an mbealach a n-oibríonn Sogou, Microsoft Pinyin agus macOS; clóscríobhann `Shift` móide litir ceannlitir fós. Ar mhéarchláir Seapánacha, scoránaíonn 全角/半角 an t-ionchur, casann 変換 air é, agus casann 無変換 as é. Le Cóiréis, malartaíonn 한/영 Hangul agus athraíonn 한자 go Hanja, cibé acu an bhfuil eochracha tiomnaithe ag do mhéarchlár nó an seolann sé Right Alt agus Right Ctrl dóibh, mar a dhéanann go leor ríomhairí glúine, agus mar sin ní gnáthmholartóirí iad Right Alt agus Right Ctrl ansin; scoránaíonn deachtú le Alt + Space ina ionad sin. Fanann `Ctrl + Space` ar fáil do Tmux agus Herdr; fanann `Shift + CapsLock` mar an eochair cumadóireachta.

Feictear an táscaire méarchláir ar dheis an bharra nuair a bhíonn leagan amach méarchláir nó modhanna ionchuir iolracha agat. Cliceáil air chun teangacha ionchuir a mhalartú; taispeánann an tSeapáinis あ do hiragana. Le haghaidh roghanna carachtar Seapánacha, malartaigh go Seapáinis, clóscríobh focal ar nós `nihongo`, ansin brúigh Space faoi dhó. Brúigh Enter chun do rogha a ghlacadh. Má tá leagan amach méarchláir iolracha agat freisin, deaschliceáil ar an táscaire chun dul tríothu.

Úsáid _Setup > Keyboard > Keyboard Inputs_ chun leagan amach ar nós Béarla agus Fraincis a roghnú, ó na roghanna céanna a thairgtear le linn na suiteála. Úsáid _Setup > Keyboard > Input Methods_ chun a roghnú cé na hinnill cumadóireachta atá gníomhach. Osclaíonn an dá roghnóir taobh istigh de roghchlár Omarchy agus do roghanna reatha seiceáilte. Cliceáil nó brúigh Enter chun rogha a scoránú; baineann gach athrú i bhfeidhm láithreach. Má dhíroghnaíonn tú modh ionchuir, bainfidh sé as an timthriall é gan é a dhíshuiteáil; fanann an méarchlár ar fáil.

Rith `omarchy setup keyboard` nó `omarchy setup input` chun na roghnóirí céanna a oscailt. Chun teanga amháin a chur leis ón líne ordaithe, úsáid `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, nó `cangjie5`. Tagann Quick, Boshiamy agus Array sa phacáiste céanna le Cangjie agus feictear iad sa roghnóir Input Methods. Caomhnaítear do eochracha malartaithe saincheaptha. Le haghaidh leagan amach nó eochracha innill mhalartacha, suiteáil `fcitx5-configtool` le `omarchy pkg add fcitx5-configtool` agus lainseáil ó theirminéal é. Ní athraíonn teanga ionchuir a roghnú teanga na deisce. Má roghnaíonn tú Seapáinis, Cóiréis nó Sínis faoi _Setup > Language_ cuirfidh sé a modh ionchuir leis nuair nach bhfuil ceann agat fós.

Úsáid `Super + I` chun dul trí mhodhanna ionchuir nó leagan amach méarchláir, agus `Super + Shift + I` chun dul ar ais an treo eile, agus mar sin le trí cinn cumraithe is féidir leat bogadh idir dhá chomharsa. Ní fheictear an táscaire ionchuir ar dheis an bharra ach amháin nuair a bhíonn níos mó ná modh ionchuir nó leagan amach amháin cumraithe. Oibríonn an ceangal deisce seo in éineacht le d’eochracha malartaithe Fcitx atá ann cheana; is féidir leat é a shárú i `~/.config/hypr/bindings.lua`. Úsáideann na hinnill ionchuir agus na seichimh cumadóireachta an tseirbhís [Fcitx5](https://fcitx-im.org/) atá ar siúl cheana féin i ngach seisiún.

### Úsáid ALT mar SUPER

Ar roinnt méarchlár, níl sé áisiúil an phríomh-eochair meta (eochair Windows/cmd) a úsáid mar SUPER. Is féidir leat é seo a athrú go ALT ina ionad sin leis an athrú seo:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
