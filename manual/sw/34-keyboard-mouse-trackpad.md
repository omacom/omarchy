# Kibodi, Kipanya, Padi ya Mguso

Hyprland inakuruhusu kusanidi ingizo zako zote kwa undani mkubwa. Unaweza kufanya marudio ya kibodi yawe ya haraka kupita kiasi au kufanya padi ya mguso itumie usogeaji wa asili. Unabadilisha yote hayo katika `~/.config/hypr/input.lua`, ambayo unaweza pia kuifikia kupitia _Setup > Input_ katika menyu ya Omarchy (`Super + Space`). Chochote unachokiweka hapo hubadilisha chaguo-msingi za Omarchy.

Huu ni mfano:

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

Unaweza [kuona chaguo zote za ingizo](https://wiki.hypr.land/Configuring/Basics/Variables/#input) kwenye wiki ya Hyprland kwa ajili ya ingizo.

CapsLock hufanya kazi kama Caps Lock ya kawaida, na `Shift + CapsLock` ndicho kitufe cha kutungia kwa ajili ya [emoji za haraka](07-hotkeys.md#quick-emojis) na [ukamilishaji mwingine](07-hotkeys.md#quick-completions). Ikiwa ungependelea kitufe cha kutungia kiwe mahali pengine, badilisha `omarchy:shift_caps_compose` katika `kb_options`. Kwa mfano, hii huhamisha kitufe cha kutungia hadi Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Vitufe vya kazi

Safu ya juu ya kibodi ya laptop hutuma vitufe vya midia (sauti, mwangaza na kadhalika) kwa chaguo-msingi, na kushikilia `Fn` hukupa F1-F12; `Fn + Esc` huifunga kwa mpangilio wa kinyume hadi utakapokibonyeza tena. Kibodi nyingi hukumbuka ufungaji huo zenyewe. Laptop za ASUS na kibodi za mtindo wa Apple huiachia Linux, ambayo huziwasha kwenye vitufe vya midia kila inapowashwa. Ili ziianze kwenye F1-F12 badala yake, endesha `omarchy keyboard toprow fnkeys` (na `omarchy keyboard toprow mediakeys` ili kurudi nyuma); kwenye laptop nyingine hufanya kazi baada ya kuwasha upya. Mac za Apple Silicon huhifadhi mpangilio wao wenyewe.

### Ishara za padi ya mguso

Telezesha kwenye padi ya mguso ili kutembea kwenye eneo-kazi:

| Ishara | Kitendo |
| --- | --- |
| Vidole vitatu kushoto / kulia | Eneo la kazi lililotangulia / linalofuata, ikiwa ni pamoja na yaliyo tupu |
| Vidole vitatu juu | Washa/zima dashibodi ya AI |
| Vidole vitatu chini | Fungua menyu ya Omarchy |
| Vidole vinne kushoto / kulia | Hamisha dirisha linalotumika hadi eneo la kazi lililotangulia / linalofuata |
| Vidole vinne chini | Washa/zima skrini nzima |

Ili kubadilisha moja, iondoe katika `~/.config/hypr/input.lua` kabla ya kuongeza [ishara yako mwenyewe ya padi ya mguso](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), kwa kuwa Hyprland haitakubali ishara mbili kwenye vidole na mwelekeo uleule:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ili kuzima ishara zote za Omarchy, weka `omarchy_default_gestures = false` karibu na sehemu ya juu ya `~/.config/hypr/hyprland.lua`, kabla ya chaguo-msingi za Omarchy kupakiwa.

Kwenye laptop za Dell XPS zenye padi ya mguso ya haptic, unaweza pia kuweka nguvu ya kubofya kuwa low, mid, au high chini ya _Trigger > Hardware > Touchpad Haptics_.

### Kuandika kwa Kichina, Kijapani, na lugha nyingine

Chagua Kijapani, Kikorea, Kichina (Kilichorahisishwa, Pinyin), Taiwan (Zhuyin), au Hong Kong (Cangjie) kisakinishi kinapokuuliza kuhusu kibodi yako. Omarchy husanidi kibodi na injini ya ingizo inayolingana kiotomatiki, ikiwa ni pamoja na wakati wa usanidi wa kwanza wa kuwasha bila mtandao. Kijapani hutumia Mozc, Kikorea hutumia Hangul ya kawaida ya seti mbili, Kichina Kilichorahisishwa hutumia Pinyin, Taiwan hutumia mpangilio wa kawaida wa Zhuyin wa Chewing, na Hong Kong hutumia Cangjie yenye maumbo ya herufi za Hong Kong. Kijapani (kibodi ya US) hutoa Mozc yenye mpangilio wa kibodi ya US. Vitufe vya Hangul, Zhuyin, na Cangjie hubaki katika nafasi zao za kawaida hata unapoandika herufi za Kilatini kwa Dvorak, Colemak, au AZERTY. Ikiwa uliongeza Hangul au Chewing kabla ya hii, iondoe kisha uichague tena chini ya _Setup > Keyboard > Input Methods_ ili kuhamisha vitufe vyake huko; Omarchy huiacha injini ambayo tayari unaitumia kuandika iwe hivyo ilivyo.

Kuandika huanza katika hali ya Kilatini. Bonyeza `Super + I` ili kuzunguka kupitia mbinu za ingizo zilizosanidiwa, na `Super + Shift + I` ili kurudi nyuma. Gusa `Shift` peke yake ili kutoka katika mbinu ya ingizo kama Pinyin na kuingia kwenye herufi za Kilatini, na uiguse tena ili kurudi, jinsi Sogou, Microsoft Pinyin, na macOS zinavyofanya; `Shift` pamoja na herufi bado huandika herufi kubwa. Kwenye kibodi za Kijapani, 全角/半角 huwasha/kuzima ingizo, 変換 huiwasha, na 無変換 huizima. Kwa Kikorea, 한/영 hubadilisha Hangul na 한자 hubadilisha kuwa Hanja, iwe kibodi yako ina vitufe maalum au hutuma Right Alt na Right Ctrl kwa ajili yao, kama laptop nyingi zinavyofanya, kwa hiyo Right Alt na Right Ctrl si vibadilishaji vya kawaida hapo; uandikaji wa sauti huwashwa/kuzimwa kwa Alt + Space badala yake. `Ctrl + Space` hubaki inapatikana kwa ajili ya Tmux na Herdr; `Shift + CapsLock` hubaki kitufe cha kutungia.

Kiashirio cha kibodi huonekana upande wa kulia wa upau unapokuwa na mipangilio mingi ya kibodi au mbinu za ingizo. Kibofye ili kubadilisha lugha za ingizo; Kijapani huonyesha あ kwa ajili ya hiragana. Kwa chaguo za herufi za Kijapani, badilisha hadi Kijapani, andika neno kama `nihongo`, kisha bonyeza Space mara mbili. Bonyeza Enter ili kukubali chaguo lako. Ikiwa pia una mipangilio mingi ya kibodi, bofya kulia kiashirio ili kuzunguka kupitia hizo.

Tumia _Setup > Keyboard > Keyboard Inputs_ kuchagua mipangilio kama Kiingereza na Kifaransa, kutoka chaguo zilezile zinazotolewa wakati wa usakinishaji. Tumia _Setup > Keyboard > Input Methods_ kuchagua ni injini zipi za utungaji zinazotumika. Vichaguzi vyote viwili hufunguka ndani ya menyu ya Omarchy huku chaguo zako za sasa zikiwa zimechaguliwa. Bofya au bonyeza Enter ili kuwasha/kuzima chaguo; kila mabadiliko hutumika mara moja. Kuondoa chaguo la mbinu ya ingizo huiondoa kwenye mzunguko bila kuiondoa kwenye mfumo; kibodi hubaki inapatikana.

Endesha `omarchy setup keyboard` au `omarchy setup input` ili kufungua vichaguzi vilevile. Ili kuongeza lugha moja kutoka kwenye mstari wa amri, tumia `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, au `cangjie5`. Quick, Boshiamy, na Array huja katika kifurushi kilekile kama Cangjie na huonekana katika kichaguzi cha Input Methods. Vitufe vyako maalum vya kubadilisha huhifadhiwa. Kwa mipangilio au vitufe mbadala vya injini, sakinisha `fcitx5-configtool` kwa `omarchy pkg add fcitx5-configtool` na uizindue kutoka kwenye terminal. Kuchagua lugha ya ingizo hakubadilishi lugha ya eneo-kazi. Kuchagua Kijapani, Kikorea, au Kichina chini ya _Setup > Language_ huongeza mbinu yake ya ingizo unapokuwa huna yoyote bado.

Tumia `Super + I` kuzunguka kupitia mbinu za ingizo au mipangilio ya kibodi, na `Super + Shift + I` kurudi upande wa kinyume, kwa hiyo ukiwa na tatu zilizosanidiwa unaweza kusonga kati ya majirani wawili. Kiashirio cha ingizo huonekana upande wa kulia wa upau tu wakati mbinu zaidi ya moja ya ingizo au mpangilio umesanidiwa. Kifungo hiki cha eneo-kazi hufanya kazi pamoja na vitufe vyako vilivyopo vya kubadilisha vya Fcitx; unaweza kukibadilisha katika `~/.config/hypr/bindings.lua`. Injini za ingizo na mfuatano wa utungaji hutumia huduma ya [Fcitx5](https://fcitx-im.org/) ambayo tayari inaendeshwa katika kila kipindi.

### Tumia ALT kama SUPER

Kwenye kibodi nyingine, si rahisi kutumia kitufe kikuu cha meta (kitufe cha Windows/cmd) kama SUPER. Unaweza kubadilisha hii iwe ALT badala yake kwa kutumia mabadiliko haya:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
