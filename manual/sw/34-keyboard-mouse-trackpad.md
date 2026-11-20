# Kibodi, Panya, Padi ya Mguso

Hyprland hukuruhusu kusanidi vifaa vyako vyote vya kuingiza kwa undani mkubwa. Unaweza kubadilisha kasi ya kurudia kibodi iwe ya haraka kupita kiasi au kufanya padi ya mguso itumie usogeaji asilia. Unabadilisha vyote hivyo katika `~/.config/hypr/input.lua`, ambayo unaweza pia kuifikia kupitia _Setup > Input_ katika menyu ya Omarchy (`Super + Space`). Chochote unachoweka hapo kinachukua nafasi ya chaguo-msingi za Omarchy.

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

Unaweza [kuona chaguo zote za uingizaji](https://wiki.hypr.land/Configuring/Basics/Variables/#input) kwenye wiki ya Hyprland kwa ajili ya vifaa vya kuingiza.

CapsLock hufanya kazi kama Caps Lock ya kawaida, na `Shift + CapsLock` ni kitufe cha kuunda kwa [emoji za haraka](07-hotkeys.md#quick-emojis) na [ukamilishaji mwingine](07-hotkeys.md#quick-completions). Ikiwa ungependa kitufe cha kuunda kiwe mahali pengine, badilisha `omarchy:shift_caps_compose` katika `kb_options`. Kwa mfano, hii huhamisha kitufe cha kuunda hadi Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Vitufe vya kazi

Safu ya juu ya kibodi ya kompyuta mpakato hutuma vitufe vya media (sauti, mwangaza na kadhalika) kwa chaguo-msingi, na kushikilia `Fn` hukupa F1-F12; `Fn + Esc` huifunga kwa mwelekeo wa kinyume hadi utakapokibonyeza tena. Kibodi nyingi hukumbuka ufungaji huo zenyewe. Kompyuta mpakato za ASUS na kibodi za mtindo wa Apple huachia Linux, ambayo huziwasha kwenye vitufe vya media kila inapoanza. Ili zianze kwenye F1-F12 badala yake, endesha `omarchy device keyboard toprow fnkeys` (na `omarchy device keyboard toprow mediakeys` ili kurudi nyuma); kwenye baadhi ya kompyuta mpakato huanza kufanya kazi baada ya kuwasha upya. Kompyuta za Apple Silicon Mac huhifadhi mpangilio wao wenyewe.

### Ishara za padi ya mguso

Telezesha kidole kwenye padi ya mguso ili kuzunguka kwenye eneo-kazi:

| Ishara | Kitendo |
| --- | --- |
| Vidole vitatu kushoto / kulia | Nafasi ya kazi iliyotangulia / inayofuata, ikiwa ni pamoja na zilizo tupu |
| Vidole vitatu juu | Washa/zima koni ya AI |
| Vidole vitatu chini | Fungua menyu ya Omarchy |
| Vidole vinne kushoto / kulia | Hamisha dirisha linalotumika hadi nafasi ya kazi iliyotangulia / inayofuata |
| Vidole vinne chini | Washa/zima skrini nzima |

Ili kubadilisha moja, iondoe katika `~/.config/hypr/input.lua` kabla ya kuongeza [ishara yako mwenyewe ya padi ya mguso](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), kwa kuwa Hyprland haitakubali ishara mbili zenye vidole na mwelekeo sawa:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ili kuzima ishara zote za Omarchy, weka `omarchy_default_gestures = false` karibu na juu ya `~/.config/hypr/hyprland.lua`, kabla ya chaguo-msingi za Omarchy kupakiwa.

Kwenye kompyuta mpakato za Dell XPS zenye padi ya mguso yenye mtetemo, unaweza pia kuweka nguvu ya kubofya kuwa ya chini, ya kati, au ya juu chini ya _Trigger > Hardware > Touchpad Haptics_.

### Kuandika kwa Kichina, Kijapani, na lugha nyingine

Chagua Kijapani, Kikorea, Kichina (Kilichorahisishwa, Pinyin), Taiwan (Zhuyin), au Hong Kong (Cangjie) kisakinishi kinapokuuliza kuhusu kibodi yako. Omarchy husanidi kibodi na injini ya uingizaji inayolingana kiotomatiki, ikiwa ni pamoja na wakati wa usanidi wa mara ya kwanza bila mtandao. Kijapani hutumia Mozc, Kikorea hutumia Hangul ya kawaida ya seti mbili, Kichina Kilichorahisishwa hutumia Pinyin, Taiwan hutumia mpangilio wa kawaida wa Zhuyin wa Chewing, na Hong Kong hutumia Cangjie yenye maumbo ya herufi za Hong Kong. Kijapani (kibodi ya US) hutoa Mozc yenye mpangilio wa kibodi ya US. Vitufe vya Hangul, Zhuyin, na Cangjie hubaki katika nafasi zao za kawaida hata unapoandika herufi za Kilatini kwa Dvorak, Colemak, au AZERTY. Ikiwa uliongeza Hangul au Chewing kabla ya hii, acha kuichagua na uichague tena chini ya _Setup > Keyboard > Input Methods_ ili kuhamisha vitufe vyake huko; Omarchy huacha injini ambayo tayari unatumia kuandika nayo.

Kuandika huanza katika hali ya Kilatini. Bonyeza `Super + I` ili kuzunguka katika mbinu za uingizaji zilizosanidiwa, na `Super + Shift + I` ili kuzunguka kurudi. Gusa `Shift` peke yake ili kutoka katika mbinu ya uingizaji kama Pinyin hadi kwenye herufi za Kilatini, na uiguse tena ili kurudi, jinsi Sogou, Microsoft Pinyin, na macOS zinavyofanya kazi; `Shift` pamoja na herufi bado huandika herufi kubwa. Kwenye kibodi za Kijapani, 全角/半角 huwasha na kuzima uingizaji, 変換 huuwasha, na 無変換 huuzima. Kwa Kikorea, 한/영 hubadilisha Hangul na 한자 hubadilisha kuwa Hanja, iwe kibodi yako ina vitufe maalum au hutuma Right Alt na Right Ctrl kwa ajili yao, kama kompyuta mpakato nyingi zinavyofanya, kwa hivyo Right Alt na Right Ctrl si vibadilishi vya kawaida huko; imla huwashwa na kuzimwa kwa Alt + Space badala yake. `Ctrl + Space` hubaki inapatikana kwa Tmux na Herdr; `Shift + CapsLock` hubaki kuwa kitufe cha kuunda.

Kiashiria cha kibodi huonekana upande wa kulia wa upau unapokuwa na mipangilio mingi ya kibodi au mbinu za uingizaji. Kibofye ili kubadilisha lugha za uingizaji; Kijapani huonyesha あ kwa hiragana. Kwa chaguo za herufi za Kijapani, badilisha hadi Kijapani, andika neno kama `nihongo`, kisha bonyeza Space mara mbili. Bonyeza Enter ili kukubali chaguo lako. Ikiwa pia una mipangilio mingi ya kibodi, bofya kulia kiashiria ili kuzunguka kati yazo.

Tumia _Setup > Keyboard > Keyboard Inputs_ kuchagua mipangilio kama Kiingereza na Kifaransa, kutoka chaguo sawa zinazotolewa wakati wa usakinishaji. Tumia _Setup > Keyboard > Input Methods_ kuchagua ni injini zipi za uundaji zinazotumika. Vichaguzi vyote viwili hufunguka ndani ya menyu ya Omarchy huku chaguo zako za sasa zikiwa zimealamishwa. Bofya au bonyeza Enter ili kuwasha au kuzima chaguo; kila mabadiliko hutumika mara moja. Kuacha kuchagua mbinu ya uingizaji huiondoa katika mzunguko bila kuisanidua; kibodi hubaki inapatikana.

Endesha `omarchy setup keyboard` au `omarchy setup input` ili kufungua vichaguzi sawa. Ili kuongeza lugha moja kutoka kwenye mstari wa amri, tumia `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, au `cangjie5`. Quick, Boshiamy, na Array huja katika kifurushi sawa na Cangjie na huonekana katika kichaguzi cha Input Methods. Vitufe vyako maalum vya kubadilisha huhifadhiwa. Kwa mipangilio au vitufe mbadala vya injini, sakinisha `fcitx5-configtool` kwa `omarchy pkg add fcitx5-configtool` na uizindue kutoka kwenye terminali. Kuchagua lugha ya uingizaji hakubadilishi lugha ya eneo-kazi. Kuchagua Kijapani, Kikorea, au Kichina chini ya _Setup > Language_ huongeza mbinu yake ya uingizaji unapokuwa huna yoyote bado.

Tumia `Super + I` kuzunguka katika mbinu za uingizaji au mipangilio ya kibodi, na `Super + Shift + I` kurudi upande wa kinyume, kwa hivyo ukiwa na tatu zilizosanidiwa unaweza kusonga kati ya majirani wawili. Kiashiria cha uingizaji huonekana upande wa kulia wa upau tu wakati zaidi ya mbinu moja ya uingizaji au mpangilio mmoja umesanidiwa. Ufungaji huu wa eneo-kazi hufanya kazi pamoja na vitufe vyako vilivyopo vya kubadilisha vya Fcitx; unaweza kuubatilisha katika `~/.config/hypr/bindings.lua`. Injini za uingizaji na mfuatano wa kuunda hutumia huduma ya [Fcitx5](https://fcitx-im.org/) ambayo tayari inaendeshwa katika kila kipindi.

### Tumia ALT kama SUPER

Kwenye baadhi ya kibodi, si rahisi kutumia kitufe kikuu cha meta (kitufe cha Windows/cmd) kama SUPER. Unaweza kubadilisha hii iwe ALT badala yake kwa kutumia mabadiliko haya:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
