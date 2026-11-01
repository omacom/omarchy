# යතුරුපුවරුව, මූසිකය, ට්‍රැක්පෑඩය

Hyprland මඟින් ඔබේ සියලු ආදාන ඉතා සවිස්තරාත්මකව වින්‍යාස කිරීමට ඔබට ඉඩ ලැබේ. ඔබට යතුරුපුවරු පුනරාවර්තනය අතිශය වේගවත් කළ හැකිය, නැතහොත් ට්‍රැක්පෑඩය ස්වාභාවික අනුචලනය භාවිත කරන ලෙස සැකසිය හැකිය. ඔබ මේ සියල්ල වෙනස් කරන්නේ `~/.config/hypr/input.lua` තුළිනි. එයට Omarchy මෙනුව (`Super + Space`) හරහා _Setup > Input_ වෙතින් ද ළඟා විය හැකිය. ඔබ එහි සකසන ඕනෑම දෙයක් Omarchy හි පෙරනිමි වෙනුවට පැමිණේ.

මෙන්න උදාහරණයක්:

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

ආදාන සඳහා වූ Hyprland විකියේ [ආදාන විකල්ප සියල්ල ඔබට දැක ගත හැකිය](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock සාමාන්‍ය Caps Lock එකක් ලෙස ක්‍රියා කරයි. `Shift + CapsLock` යනු [ඉක්මන් ඉමෝජි](07-hotkeys.md#quick-emojis) සහ [අනෙකුත් සම්පූර්ණ කිරීම්](07-hotkeys.md#quick-completions) සඳහා වූ compose යතුරයි. ඔබට compose යතුර වෙනත් තැනක තිබීමට අවශ්‍ය නම්, `kb_options` තුළ ඇති `omarchy:shift_caps_compose` වෙනුවට එය ආදේශ කරන්න. උදාහරණයක් ලෙස, මෙය compose යතුර Right Alt වෙත ගෙන යයි:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ට්‍රැක්පෑඩ් ඉඟි

ඩෙස්ක්ටොප් එක වටා ගමන් කිරීමට ට්‍රැක්පෑඩය මත ස්වයිප් කරන්න:

| ඉඟිය | ක්‍රියාව |
| --- | --- |
| ඇඟිලි තුනක් වමට / දකුණට | පෙර / ඊළඟ වැඩතලය, හිස් ඒවා ඇතුළුව |
| ඇඟිලි තුනක් ඉහළට | AI කොන්සෝලය ටොගල් කරන්න |
| ඇඟිලි තුනක් පහළට | Omarchy මෙනුව විවෘත කරන්න |
| ඇඟිලි හතරක් වමට / දකුණට | සක්‍රිය කවුළුව පෙර / ඊළඟ වැඩතලයට ගෙන යන්න |
| ඇඟිලි හතරක් පහළට | සම්පූර්ණ තිරය ටොගල් කරන්න |

එකක් වෙනස් කිරීමට, ඔබේම [ට්‍රැක්පෑඩ් ඉඟියක්](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) එක් කිරීමට පෙර `~/.config/hypr/input.lua` තුළ එය unset කරන්න. එකම ඇඟිලි ගණනට සහ දිශාවට Hyprland ඉඟි දෙකක් නොගන්නා බැවිනි:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy හි සියලු ඉඟි ක්‍රියාවිරහිත කිරීමට, Omarchy හි පෙරනිමි පූරණය වීමට පෙර, `~/.config/hypr/hyprland.lua` හි ඉහළට ආසන්නව `omarchy_default_gestures = false` ලෙස සකසන්න.

haptic ටච්පෑඩයක් ඇති Dell XPS ලැප්ටොප්වල, _Trigger > Hardware > Touchpad Haptics_ යටතේ ක්ලික් කිරීමේ ශක්තිය අඩු, මැද හෝ ඉහළ ලෙස ද සැකසිය හැකිය.

### චීන, ජපන් සහ වෙනත් භාෂාවලින් යතුරුලියනය කිරීම

ස්ථාපකය ඔබේ යතුරුපුවරුව ගැන අසන විට Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) හෝ Hong Kong (Cangjie) තෝරන්න. නොබැඳි පළමු ආරම්භ සැකසුම අතරතුර ද ඇතුළුව, Omarchy යතුරුපුවරුව සහ ඊට ගැළපෙන ආදාන එන්ජිම ස්වයංක්‍රීයව වින්‍යාස කරයි. Japanese සඳහා Mozc භාවිත වේ. Korean සඳහා සම්මත two-set Hangul භාවිත වේ. Simplified Chinese සඳහා Pinyin භාවිත වේ. Taiwan සඳහා Chewing හි සම්මත Zhuyin සැකැස්ම භාවිත වේ. Hong Kong සඳහා Hong Kong අක්ෂර ආකාර සහිත Cangjie භාවිත වේ. Japanese (US keyboard) මඟින් US යතුරුපුවරු පිරිසැලසුමක් සහිත Mozc ලැබේ. ඔබ Dvorak, Colemak හෝ AZERTY සමඟ ලතින් අකුරු යතුරුලියනය කරන විට පවා Hangul, Zhuyin සහ Cangjie යතුරු ඒවායේ සම්මත ස්ථානවලම පවතී. ඔබ මීට පෙර Hangul හෝ Chewing එක් කර තිබුණේ නම්, එහි යතුරු එම ස්ථානවලට ගෙන යාමට _Setup > Typing > Input Methods_ යටතේ එය තේරීමෙන් ඉවත් කර නැවත තෝරන්න; ඔබ දැනටමත් යතුරුලියනය කිරීමට භාවිත කරන එන්ජිමකට Omarchy අත නොතබයි.

යතුරුලියනය Latin ප්‍රකාරයෙන් ආරම්භ වේ. වින්‍යාස කළ ආදාන ක්‍රම හරහා චක්‍රීයව යාමට `Super + I` ඔබන්න. ආපසු චක්‍රීයව යාමට `Super + Shift + I` ඔබන්න. Pinyin වැනි ආදාන ක්‍රමයකින් ලතින් අකුරු වෙත පිටත් වීමට `Shift` තනිවම තට්ටු කරන්න. ආපසු යාමට එය නැවත තට්ටු කරන්න. මෙය Sogou, Microsoft Pinyin සහ macOS ක්‍රියා කරන ආකාරයයි; `Shift` සහ අකුරක් එක්ව තවමත් කැපිටල් අකුරක් යතුරුලියනය කරයි. ජපන් යතුරුපුවරුවල, 全角/半角 ආදානය ටොගල් කරයි. 変換 එය සක්‍රිය කරයි. 無変換 එය ක්‍රියාවිරහිත කරයි. Korean සමඟ, 한/영 මඟින් Hangul මාරු වේ. 한자 මඟින් Hanja බවට පරිවර්තනය වේ. ඔබේ යතුරුපුවරුවේ ඒ සඳහාම වෙන් වූ යතුරු තිබුණත්, බොහෝ ලැප්ටොප් කරන ආකාරයට ඒවා වෙනුවට Right Alt සහ Right Ctrl යවනු ලැබුවත් මෙය එසේමය. එබැවින් එහිදී Right Alt සහ Right Ctrl යනු සරල විකරණකාරක නොවේ; ඒ වෙනුවට උච්චාරණයෙන් ලිවීම Alt + Space සමඟ ටොගල් වේ. `Ctrl + Space` Tmux සහ Herdr සඳහා තවමත් තිබේ; `Shift + CapsLock` තවමත් compose යතුරයි.

ඔබට යතුරුපුවරු පිරිසැලසුම් හෝ ආදාන ක්‍රම කිහිපයක් ඇති විට, යතුරුපුවරු දර්ශකය තීරුවේ දකුණු පසින් දිස් වේ. ආදාන භාෂා මාරු කිරීමට එය ක්ලික් කරන්න; Japanese මඟින් hiragana සඳහා あ ප්‍රදර්ශනය වේ. ජපන් අක්ෂර තේරීම් සඳහා, Japanese වෙත මාරු වී, `nihongo` වැනි වචනයක් යතුරුලියනය කර, ඉන්පසු Space දෙවරක් ඔබන්න. ඔබේ තේරීම පිළිගැනීමට Enter ඔබන්න. ඔබට යතුරුපුවරු පිරිසැලසුම් කිහිපයක් ද තිබේ නම්, ඒවා හරහා චක්‍රීයව යාමට දර්ශකය මත දකුණු-ක්ලික් කරන්න.

ස්ථාපනය අතරතුර ඉදිරිපත් කෙරෙන එම තේරීම්වලින්ම English සහ French වැනි පිරිසැලසුම් තේරීමට _Setup > Typing > Keyboard Layouts_ භාවිත කරන්න. කුමන සංයුති එන්ජින් සක්‍රිය විය යුතුද යන්න තේරීමට _Setup > Typing > Input Methods_ භාවිත කරන්න. තේරුම් දෙකම ඔබේ වත්මන් තේරීම් සලකුණු කර ඇතිව Omarchy මෙනුව තුළ විවෘත වේ. තේරීමක් ටොගල් කිරීමට ක්ලික් කරන්න හෝ Enter ඔබන්න; සෑම වෙනසක්ම වහාම ක්‍රියාත්මක වේ. ආදාන ක්‍රමයක තේරීම ඉවත් කිරීම එය අස්ථාපනය නොකර චක්‍රයෙන් ඉවත් කරයි; යතුරුපුවරුව තවමත් තිබේ.

එම තේරුම්ම විවෘත කිරීමට `omarchy setup keyboard` හෝ `omarchy setup input` ධාවනය කරන්න. විධාන පේළියෙන් එක් භාෂාවක් එක් කිරීමට, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` හෝ `cangjie5` භාවිත කරන්න. Quick, Boshiamy සහ Array, Cangjie සමඟම එකම පැකේජයේ එන අතර Input Methods තේරීමේ දිස් වේ. ඔබේ අභිරුචි මාරු කිරීමේ යතුරු ආරක්ෂා වේ. විකල්ප එන්ජින් පිරිසැලසුම් හෝ යතුරු සඳහා, `omarchy pkg add fcitx5-configtool` සමඟ `fcitx5-configtool` ස්ථාපනය කර එය පර්යන්තයකින් දියත් කරන්න. ආදාන භාෂාවක් තේරීම ඩෙස්ක්ටොප් භාෂාව වෙනස් නොකරයි. _Setup > Language_ යටතේ Japanese, Korean හෝ Chinese තේරීම, ඔබට තවම එකක් නොමැති විට එහි ආදාන ක්‍රමය එක් කරයි.

ආදාන ක්‍රම හෝ යතුරුපුවරු පිරිසැලසුම් හරහා චක්‍රීයව යාමට `Super + I` භාවිත කරන්න. අනෙක් දිශාවට ආපසු යාමට `Super + Shift + I` භාවිත කරන්න. එබැවින් වින්‍යාස කළ තුනක් සමඟ ඔබට අසල්වැසියන් දෙදෙනෙකු අතර ගමන් කළ හැකිය. ආදාන ක්‍රමයක් හෝ පිරිසැලසුමක් එකකට වැඩියෙන් වින්‍යාස කර ඇති විට පමණක් ආදාන දර්ශකය තීරුවේ දකුණු පසින් දිස් වේ. මෙම ඩෙස්ක්ටොප් බන්ධනය ඔබේ පවතින Fcitx මාරු කිරීමේ යතුරු සමඟම ක්‍රියා කරයි; ඔබට `~/.config/hypr/bindings.lua` තුළ එය අභිබවා යා හැකිය. ආදාන එන්ජින් සහ compose අනුක්‍රම සෑම සැසියකම දැනටමත් ධාවනය වන [Fcitx5](https://fcitx-im.org/) සේවාව භාවිත කරයි.

### ALT, SUPER ලෙස භාවිත කරන්න

සමහර යතුරුපුවරුවල, ප්‍රාථමික meta යතුර (Windows/cmd යතුර) SUPER ලෙස භාවිත කිරීම පහසු නොවේ. මෙම වෙනස භාවිතයෙන් ඔබට එය වෙනුවට ALT ලෙස මෙය වෙනස් කළ හැකිය:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
