# Kibodi, Kipanya, Padi ya Mguso

Hyprland inakuruhusu kusanidi pembejeo zako zote kwa undani mkubwa. Unaweza kubadilisha marudio ya kibodi yawe ya kasi ya ajabu au kufanya padi ya mguso itumie usogezi asilia. Unabadilisha yote hayo katika `~/.config/hypr/input.lua`, ambayo unaweza pia kuifikia kupitia _Setup > Input_ katika menyu ya Omarchy (`Super + Space`). Chochote unachoweka hapo kinachukua nafasi ya chaguo-msingi za Omarchy.

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

Unaweza [kuona chaguo zote za pembejeo](https://wiki.hypr.land/Configuring/Basics/Variables/#input) kwenye wiki ya Hyprland kwa ajili ya pembejeo.

CapsLock hufanya kazi kama Caps Lock ya kawaida, na `Shift + CapsLock` ni kitufe cha kutunga kwa [emoji za haraka](07-hotkeys.md#quick-emojis) na [ukamilishaji mwingine](07-hotkeys.md#quick-completions). Ikiwa ungependa kitufe cha kutunga kiwe mahali pengine, badilisha `omarchy:shift_caps_compose` katika `kb_options`. Kwa mfano, hii huhamisha kitufe cha kutunga kwenda Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Ishara za padi ya mguso

Telezesha vidole kwenye padi ya mguso ili kuzunguka eneo-kazi:

| Ishara | Kitendo |
| --- | --- |
| Vidole vitatu kushoto / kulia | Nafasi ya kazi iliyotangulia / inayofuata, ikiwa ni pamoja na zilizo tupu |
| Vidole vitatu juu | Geuza dashibodi ya AI |
| Vidole vitatu chini | Fungua menyu ya Omarchy |
| Vidole vinne kushoto / kulia | Hamisha dirisha linalotumika kwenda nafasi ya kazi iliyotangulia / inayofuata |
| Vidole vinne chini | Geuza skrini nzima |

Ili kubadilisha moja, iondoe katika `~/.config/hypr/input.lua` kabla ya kuongeza [ishara yako mwenyewe ya padi ya mguso](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), kwa kuwa Hyprland haitakubali ishara mbili kwa vidole na mwelekeo ule ule:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Ili kuzima ishara zote za Omarchy, weka `omarchy_default_gestures = false` karibu na juu ya `~/.config/hypr/hyprland.lua`, kabla ya chaguo-msingi za Omarchy kupakiwa.

Kwenye laptopu za Dell XPS zenye padi ya mguso ya haptic, unaweza pia kuweka nguvu ya kubofya kuwa ya chini, ya kati, au ya juu chini ya _Trigger > Hardware > Touchpad Haptics_.

### Kuandika kwa Kichina, Kijapani, na lugha nyingine

Chagua Kijapani, Kikorea, Kichina (Kilichorahisishwa, Pinyin), Taiwan (Zhuyin), au Hong Kong (Cangjie) wakati kisakinishi kinakuuliza kuhusu kibodi yako. Omarchy husanidi kibodi na injini ya pembejeo inayolingana kiotomatiki, ikiwa ni pamoja na wakati wa usanidi wa kwanza wa kuwasha bila mtandao. Kijapani hutumia Mozc, Kikorea hutumia Hangul ya seti mbili ya kawaida, Kichina Kilichorahisishwa hutumia Pinyin, Taiwan hutumia mpangilio wa kawaida wa Zhuyin wa Chewing, na Hong Kong hutumia Cangjie yenye maumbo ya herufi za Hong Kong. Kijapani (kibodi ya US) hutoa Mozc yenye mpangilio wa kibodi wa US. Vifunguo vya Hangul, Zhuyin, na Cangjie hubaki katika nafasi zao za kawaida hata unapoandika herufi za Kilatini kwa Dvorak, Colemak, au AZERTY. Ikiwa uliongeza Hangul au Chewing kabla ya hapo, iondoe chaguo kisha uichague tena chini ya _Setup > Typing > Input Methods_ ili kuhamisha vifunguo vyake huko; Omarchy huacha injini ambayo tayari unaandika nayo kama ilivyo.

Kuandika huanza katika hali ya Kilatini. Bonyeza `Super + I` ili kuzunguka kati ya mbinu za pembejeo zilizosanidiwa, na `Super + Shift + I` ili kuzunguka kinyume. Gusa `Shift` peke yake ili kutoka katika mbinu ya pembejeo kama Pinyin na kuingia herufi za Kilatini, na uiguse tena ili kurudi, kama Sogou, Microsoft Pinyin, na macOS zinavyofanya; `Shift` pamoja na herufi bado huandika herufi kubwa. Kwenye kibodi za Kijapani, 全角/半角 hugeuza pembejeo, 変換 huiwasha, na 無変換 huizima. Kwa Kikorea, 한/영 hubadilisha Hangul na 한자 hubadilisha kuwa Hanja, iwe kibodi yako ina vifunguo maalum au inatuma Right Alt na Right Ctrl kwa ajili yake, kama laptopu nyingi zinavyofanya, kwa hivyo Right Alt na Right Ctrl si vibadilishaji vya kawaida huko; kitendakazi cha kuamuru kwa sauti kwa kubonyeza-na-kuzungumza hubaki kwenye F9. `Ctrl + Space` hubaki inapatikana kwa Tmux na Herdr; `Shift + CapsLock` hubaki kitufe cha kutunga.

Kiashiria cha kibodi huonekana upande wa kulia wa upau wakati una mipangilio mingi ya kibodi au mbinu za pembejeo. Kibofye ili kubadilisha lugha za pembejeo; Kijapani huonyesha あ kwa hiragana. Kwa chaguo za herufi za Kijapani, badilisha kwenda Kijapani, andika neno kama `nihongo`, kisha bonyeza Space mara mbili. Bonyeza Enter ili kukubali chaguo lako. Ikiwa pia una mipangilio mingi ya kibodi, bofya kulia kiashiria ili kuzunguka kati yake.

Tumia _Setup > Typing > Keyboard Layouts_ kuchagua mipangilio kama Kiingereza na Kifaransa, kutoka chaguo zile zile zinazotolewa wakati wa usakinishaji. Tumia _Setup > Typing > Input Methods_ kuchagua injini za utungaji zinazotumika. Vichaguzi vyote viwili hufunguka ndani ya menyu ya Omarchy huku chaguo zako za sasa zikiwa zimealamishwa. Bofya au bonyeza Enter ili kugeuza chaguo; kila badiliko hutumika mara moja. Kuondoa chaguo la mbinu ya pembejeo huiondoa kwenye mzunguko bila kuisanidua; kibodi hubaki inapatikana.

Endesha `omarchy setup keyboard` au `omarchy setup input` ili kufungua vichaguzi vile vile. Ili kuongeza lugha moja kutoka kwenye mstari wa amri, tumia `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, au `cangjie5`. Quick, Boshiamy, na Array huja katika kifurushi kile kile kama Cangjie na huonekana katika kichaguzi cha Input Methods. Vifunguo vyako maalum vya kubadilisha huhifadhiwa. Kwa mipangilio au vifunguo mbadala vya injini, sakinisha `fcitx5-configtool` kwa `omarchy pkg add fcitx5-configtool` na uizindue kutoka kwenye terminali. Kuchagua lugha ya pembejeo hakubadilishi lugha ya eneo-kazi. Kuchagua Kijapani, Kikorea, au Kichina chini ya _Setup > Language_ huongeza mbinu yake ya pembejeo wakati bado huna yoyote.

Tumia `Super + I` kuzunguka kati ya mbinu za pembejeo au mipangilio ya kibodi, na `Super + Shift + I` kurudi kinyume, kwa hivyo ukiwa na tatu zilizosanidiwa unaweza kusonga kati ya majirani wawili. Kiashiria cha pembejeo huonekana upande wa kulia wa upau tu wakati mbinu zaidi ya moja ya pembejeo au mpangilio umesanidiwa. Ufungaji huu wa eneo-kazi hufanya kazi pamoja na vifunguo vyako vilivyopo vya kubadilisha vya Fcitx; unaweza kuubatilisha katika `~/.config/hypr/bindings.lua`. Injini za pembejeo na mfuatano wa utungaji hutumia huduma ya [Fcitx5](https://fcitx-im.org/) ambayo tayari inaendeshwa katika kila kipindi.

### Tumia ALT kama SUPER

Kwenye baadhi ya kibodi, si rahisi kutumia kitufe kikuu cha meta (kitufe cha Windows/cmd) kama SUPER. Unaweza kubadilisha hii kuwa ALT badala yake kwa kutumia badiliko hili:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
