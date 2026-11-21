# Kibodi, Kipanya, Trackpad

Hyprland hukuruhusu kusanidi pembejeo zako zote kwa undani mkubwa. Unaweza kubadilisha marudio ya kibodi yawe ya haraka kupita kiasi au kufanya trackpad itumie usogeaji wa asili. Unabadilisha yote hayo katika `~/.config/hypr/input.lua`, ambayo unaweza pia kuifikia kupitia _Setup > Input_ katika menyu ya Omarchy (`Super + Space`). Chochote unachokiweka hapo hubadilisha mipangilio chaguo-msingi ya Omarchy.

Hapa kuna mfano:

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

Unaweza [kuona chaguo zote za pembejeo](https://wiki.hypr.land/Configuring/Basics/Variables/#input) kwenye wiki ya Hyprland kuhusu pembejeo.

CapsLock hufanya kazi kama Caps Lock ya kawaida, na `Shift + CapsLock` ni kitufe cha compose kwa [emojis za haraka](07-hotkeys.md#quick-emojis) na [ukamilishaji mwingine](07-hotkeys.md#quick-completions). Ikiwa ungependa zaidi kitufe cha compose kiwe mahali pengine, badilisha `omarchy:shift_caps_compose` katika `kb_options`. Kwa mfano, hii huhamisha kitufe cha compose hadi Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Vitufe vya vitendakazi

Mstari wa juu wa kibodi ya laptop hutuma vitufe vya media (sauti, mwangaza na kadhalika) kwa chaguo-msingi, na kushikilia `Fn` hutoa F1-F12; `Fn + Esc` huifunga kwa njia nyingine hadi utakapokibonyeza tena. Kibodi nyingi hukumbuka ufungaji huo zenyewe. Laptop za ASUS na kibodi za mtindo wa Apple huachia Linux, ambayo huziwasha kwenye vitufe vya media kila inapoanza. Ili ziianze kwenye F1-F12 badala yake, endesha `omarchy device keyboard toprow fnkeys` (na `omarchy device keyboard toprow mediakeys` kurudi nyuma); kwenye baadhi ya laptop huanza kutumika baada ya kuwasha upya. Apple Silicon Macs huhifadhi mpangilio wao wenyewe.

### Ishara za Trackpad

Telezesha kwenye trackpad ili kuzunguka kwenye eneo kazi:

| Ishara | Kitendo |
| --- | --- |
| Vidole vitatu kushoto / kulia | Eneo kazi lililotangulia / linalofuata, ikiwa ni pamoja na tupu |
| Vidole vitatu juu | Washa/zima koni ya AI |
| Vidole vitatu chini | Fungua menyu ya Omarchy |
| Vidole vinne kushoto / kulia | Hamisha dirisha linalotumika hadi eneo kazi lililotangulia / linalofuata |
| Vidole vinne chini | Washa/zima skrini nzima |

Ili kubadilisha moja, iondoe katika `~/.config/hypr/input.lua` kabla ya kuongeza [ishara yako mwenyewe ya touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), kwa kuwa Hyprland haitachukua ishara mbili kwa vidole na mwelekeo ule ule:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ili kuzima ishara zote za Omarchy, weka `omarchy_default_gestures = false` karibu na juu ya `~/.config/hypr/hyprland.lua`, kabla ya mipangilio chaguo-msingi ya Omarchy kupakiwa.

Kwenye laptop za Dell XPS zenye touchpad ya haptic, unaweza pia kuweka nguvu ya kubofya kuwa ya chini, ya kati, au ya juu chini ya _Trigger > Hardware > Touchpad Haptics_.

### Kuandika kwa Kichina, Kijapani, na lugha nyingine

Chagua Kijapani, Kikorea, Kichina (Kilichorahisishwa, Pinyin), Taiwan (Zhuyin), au Hong Kong (Cangjie) kisakinishi kinapokuuliza kuhusu kibodi yako. Omarchy husanidi kibodi na injini ya pembejeo inayolingana kiotomatiki, ikiwa ni pamoja na wakati wa usanidi wa mara ya kwanza wa kuwasha bila mtandao. Kijapani hutumia Mozc, Kikorea hutumia Hangul ya kawaida ya seti mbili, Kichina Kilichorahisishwa hutumia Pinyin, Taiwan hutumia mpangilio wa kawaida wa Zhuyin wa Chewing, na Hong Kong hutumia Cangjie yenye maumbo ya herufi za Hong Kong. Kijapani (kibodi ya US) hutoa Mozc yenye mpangilio wa kibodi ya US. Vitufe vya Hangul, Zhuyin, na Cangjie hubaki katika nafasi zao za kawaida hata unapoandika herufi za Kilatini kwa Dvorak, Colemak, au AZERTY. Ikiwa uliongeza Hangul au Chewing kabla ya hili, iondoe chaguo kisha uichague tena chini ya _Setup > Keyboard > Input Methods_ ili kuhamisha vitufe vyake huko; Omarchy huacha injini ambayo tayari unaandika nayo kama ilivyo.

Kuandika huanza katika hali ya Kilatini. Bonyeza `Super + I` ili kuzunguka kupitia mbinu za pembejeo zilizosanidiwa, na `Super + Shift + I` ili kuzunguka kurudi nyuma. Gusa `Shift` peke yake ili kutoka katika mbinu ya pembejeo kama Pinyin hadi herufi za Kilatini, na uiguse tena kurudi nyuma, jinsi Sogou, Microsoft Pinyin, na macOS zinavyofanya kazi; `Shift` pamoja na herufi bado huandika herufi kubwa. Kwenye kibodi za Kijapani, 全角/半角 hubadilisha pembejeo, 変換 huiwasha, na 無変換 huizima. Ukiwa na Kikorea, 한/영 hubadilisha Hangul na 한자 hubadilisha hadi Hanja, iwe kibodi yako ina vitufe maalum au hutuma Right Alt na Right Ctrl kwa ajili yao, kama laptop nyingi zinavyofanya, kwa hivyo Right Alt na Right Ctrl si vibadilishaji vya kawaida hapo; utamkaji hubadilishwa kwa Alt + Space badala yake. `Ctrl + Space` hubaki inapatikana kwa Tmux na Herdr; `Shift + CapsLock` hubaki kitufe cha compose.

Kiashiria cha kibodi huonekana upande wa kulia wa upau unapokuwa na mipangilio mingi ya kibodi au mbinu za pembejeo. Kibofye ili kubadilisha lugha za pembejeo; Kijapani huonyesha あ kwa hiragana. Kwa chaguo za herufi za Kijapani, badilisha hadi Kijapani, andika neno kama `nihongo`, kisha bonyeza Space mara mbili. Bonyeza Enter kukubali chaguo lako. Ikiwa pia una mipangilio mingi ya kibodi, bofya kulia kiashiria ili kuzunguka kupitia hiyo.

Tumia _Setup > Keyboard > Keyboard Inputs_ kuchagua mipangilio kama Kiingereza na Kifaransa, kutoka chaguo zile zile zinazotolewa wakati wa usakinishaji. Tumia _Setup > Keyboard > Input Methods_ kuchagua ni injini zipi za utungaji zinazotumika. Vichaguzi vyote viwili hufunguka ndani ya menyu ya Omarchy huku chaguo zako za sasa zikiwa zimechaguliwa. Bofya au bonyeza Enter ili kuwasha/zima chaguo; kila badiliko huanza kutumika mara moja. Kuondoa chaguo la mbinu ya pembejeo huiondoa kutoka mzunguko bila kuisanidua; kibodi hubaki inapatikana.

Endesha `omarchy setup keyboard` au `omarchy setup input` kufungua vichaguzi vile vile. Ili kuongeza lugha moja kutoka mstari wa amri, tumia `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, au `cangjie5`. Quick, Boshiamy, na Array huja katika kifurushi kile kile kama Cangjie na huonekana katika kichaguzi cha Input Methods. Vitufe vyako maalum vya kubadilisha huhifadhiwa. Kwa mipangilio au vitufe mbadala vya injini, sakinisha `fcitx5-configtool` kwa `omarchy pkg add fcitx5-configtool` na uizindue kutoka terminal. Kuchagua lugha ya pembejeo hakubadilishi lugha ya eneo kazi. Kuchagua Kijapani, Kikorea, au Kichina chini ya _Setup > Region > Language_ huongeza mbinu yake ya pembejeo unapokuwa huna yoyote bado.

Tumia `Super + I` kuzunguka kupitia mbinu za pembejeo au mipangilio ya kibodi, na `Super + Shift + I` kurudi nyuma kwa njia nyingine, kwa hivyo ukiwa na tatu zilizosanidiwa unaweza kusonga kati ya majirani wawili. Kiashiria cha pembejeo huonekana upande wa kulia wa upau tu wakati mbinu zaidi ya moja ya pembejeo au mpangilio umesanidiwa. Ufungaji huu wa eneo kazi hufanya kazi pamoja na vitufe vyako vilivyopo vya kubadilisha vya Fcitx; unaweza kuubatilisha katika `~/.config/hypr/bindings.lua`. Injini za pembejeo na mfuatano wa compose hutumia huduma ya [Fcitx5](https://fcitx-im.org/) ambayo tayari inaendeshwa katika kila kipindi.

### Tumia ALT kama SUPER

Kwenye baadhi ya kibodi, si rahisi kutumia kitufe kikuu cha meta (kitufe cha Windows/cmd) kama SUPER. Unaweza kubadilisha hiki kiwe ALT badala yake kwa kutumia badiliko hili:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
