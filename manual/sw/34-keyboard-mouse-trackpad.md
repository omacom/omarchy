# Kibodi, Kipanya, Trackpad

Hyprland inakuruhusu kusanidi vifaa vyako vyote vya kuingiza kwa undani mkubwa. Unaweza kubadilisha marudio ya kibodi yawe ya kasi ya ajabu au kufanya trackpad itumie usogeaji wa asili. Unabadilisha yote hayo katika `~/.config/hypr/input.lua`, ambayo unaweza pia kuifikia kupitia _Setup > Input_ katika menyu ya Omarchy (`Super + Space`). Chochote unachoweka hapo kinachukua nafasi ya chaguo-msingi za Omarchy.

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

Unaweza [kuona chaguo zote za uingizaji](https://wiki.hypr.land/Configuring/Basics/Variables/#input) kwenye wiki ya Hyprland kuhusu uingizaji.

CapsLock hufanya kazi kama Caps Lock ya kawaida, na `Shift + CapsLock` ni kitufe cha compose kwa [emoji za haraka](07-hotkeys.md#quick-emojis) na [ukamilishaji mwingine](07-hotkeys.md#quick-completions). Ikiwa unapendelea kitufe cha compose kiwe mahali pengine, badilisha `omarchy:shift_caps_compose` katika `kb_options`. Kwa mfano, hii huhamisha kitufe cha compose hadi Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Ishara za trackpad

Unaweza pia kuwasha [ishara za touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), kama kutelezesha vidole vitatu kubadilisha workspaces:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Kwenye kompyuta mpakato za Dell XPS zenye touchpad ya haptic, unaweza pia kuweka nguvu ya kubofya kuwa low, mid, au high chini ya _Trigger > Hardware > Touchpad Haptics_.

### Kuandika kwa Kichina, Kijapani, na lugha nyingine

Chagua Kijapani, Kikorea, Kichina (Kilichorahisishwa, Pinyin), Taiwan (Zhuyin), au Hong Kong (Cangjie) kisakinishi kinapokuuliza kuhusu kibodi yako. Omarchy husanidi kibodi na injini ya uingizaji inayolingana kiotomatiki, ikiwa ni pamoja na wakati wa usanidi wa kwanza wa kuwasha bila mtandao. Kijapani hutumia Mozc, Kikorea hutumia Hangul ya seti mbili ya kawaida, Kichina Kilichorahisishwa hutumia Pinyin, Taiwan hutumia mpangilio wa kawaida wa Zhuyin wa Chewing, na Hong Kong hutumia Cangjie yenye maumbo ya herufi za Hong Kong. Kijapani (kibodi ya US) hutoa Mozc yenye mpangilio wa kibodi wa US. Vitufe vya Hangul, Zhuyin, na Cangjie hubaki katika nafasi zao za kawaida hata unapoandika herufi za Kilatini kwa Dvorak, Colemak, au AZERTY. Ikiwa uliongeza Hangul au Chewing kabla ya hili, acha kuichagua na uichague tena chini ya _Setup > Typing > Input Methods_ ili kuhamisha vitufe vyake huko; Omarchy huacha injini ambayo tayari unaandika nayo kama ilivyo.

Kuandika huanza katika hali ya Kilatini. Bonyeza `Super + I` kuzunguka kupitia mbinu za uingizaji zilizosanidiwa, na `Super + Shift + I` kurudi nyuma. Gusa `Shift` pekee ili kutoka katika mbinu ya uingizaji kama Pinyin hadi herufi za Kilatini, na uiguse tena kurudi, jinsi Sogou, Microsoft Pinyin, na macOS zinavyofanya kazi; `Shift` pamoja na herufi bado huandika herufi kubwa. Kwenye kibodi za Kijapani, 全角/半角 hubadilisha uingizaji, 変換 huuwasha, na 無変換 huuzima. Kwa Kikorea, 한/영 hubadilisha Hangul na 한자 hubadilisha kuwa Hanja, iwe kibodi yako ina vitufe maalum au hutuma Right Alt na Right Ctrl kwa ajili yake, kama kompyuta mpakato nyingi zinavyofanya, kwa hivyo Right Alt na Right Ctrl si vibadilishaji vya kawaida huko; kushinikiza-kuzungumza kwa kuamuru sauti hubaki kwenye F9. `Ctrl + Space` hubaki inapatikana kwa Tmux na Herdr; `Shift + CapsLock` hubaki kitufe cha compose.

Kiashirio cha kibodi huonekana upande wa kulia wa upau unapokuwa na mipangilio mingi ya kibodi au mbinu za uingizaji. Kibofye kubadilisha lugha za uingizaji; Kijapani huonyesha あ kwa hiragana. Kwa chaguo za herufi za Kijapani, badilisha hadi Kijapani, andika neno kama `nihongo`, kisha bonyeza Space mara mbili. Bonyeza Enter kukubali chaguo lako. Ikiwa pia una mipangilio mingi ya kibodi, bofya kulia kiashirio kuzunguka kupitia hiyo.

Tumia _Setup > Typing > Keyboard Layouts_ kuchagua mipangilio kama Kiingereza na Kifaransa, kutoka chaguo zile zile zinazotolewa wakati wa usakinishaji. Tumia _Setup > Typing > Input Methods_ kuchagua ni injini zipi za utungaji zinazotumika. Vichaguzi vyote viwili hufunguka ndani ya menyu ya Omarchy huku chaguo zako za sasa zikiwa zimealamishwa. Bofya au bonyeza Enter kubadilisha chaguo; kila badiliko hutumika mara moja. Kuacha kuchagua mbinu ya uingizaji huiondoa kwenye mzunguko bila kuiondoa kabisa; kibodi hubaki inapatikana.

Endesha `omarchy setup keyboard` au `omarchy setup input` kufungua vichaguzi vile vile. Kuongeza lugha moja kutoka kwenye mstari wa amri, tumia `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, au `cangjie5`. Quick, Boshiamy, na Array huja katika kifurushi kimoja na Cangjie na huonekana katika kichaguzi cha Input Methods. Vitufe vyako maalum vya kubadilisha huhifadhiwa. Kwa mipangilio au vitufe mbadala vya injini, sakinisha `fcitx5-configtool` kwa `omarchy pkg add fcitx5-configtool` na uizindue kutoka kwenye terminal. Kuchagua lugha ya uingizaji hakubadilishi lugha ya eneo-kazi. Kuchagua Kijapani, Kikorea, au Kichina chini ya _Setup > Language_ huongeza mbinu yake ya uingizaji unapokuwa bado huna yoyote.

Tumia `Super + I` kuzunguka kupitia mbinu za uingizaji au mipangilio ya kibodi, na `Super + Shift + I` kurudi upande mwingine, kwa hivyo ukiwa na tatu zilizosanidiwa unaweza kusonga kati ya majirani wawili. Kiashirio cha uingizaji huonekana upande wa kulia wa upau tu wakati mbinu au mpangilio zaidi ya mmoja umesanidiwa. Ufungaji huu wa eneo-kazi hufanya kazi pamoja na vitufe vyako vilivyopo vya kubadilisha vya Fcitx; unaweza kuubatilisha katika `~/.config/hypr/bindings.lua`. Injini za uingizaji na mfuatano wa compose hutumia huduma ya [Fcitx5](https://fcitx-im.org/) ambayo tayari inaendeshwa katika kila kipindi.

### Tumia ALT kama SUPER

Kwenye kibodi fulani, si rahisi kutumia kitufe kikuu cha meta (kitufe cha Windows/cmd) kama SUPER. Unaweza kubadilisha hii iwe ALT badala yake kwa kutumia badiliko hili:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
