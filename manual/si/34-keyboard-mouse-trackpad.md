# යතුරුපුවරුව, මූසිකය, Trackpad

Hyprland මඟින් ඔබේ සියලු ආදාන ඉතා විස්තරාත්මකව වින්‍යාස කිරීමට ඔබට ඉඩ දෙයි. ඔබට යතුරුපුවරු පුනරාවර්තනය අතිශය වේගවත් කළ හැකිය, නැතහොත් trackpad එක ස්වභාවික අනුචලනය භාවිත කරන ලෙස සැකසිය හැකිය. ඔබ මේ සියල්ල වෙනස් කරන්නේ `~/.config/hypr/input.lua` තුළින් වන අතර, Omarchy මෙනුව (`Super + Space`) හරහා _Setup > Input_ වෙත ගොස්ද ඔබට එයට ළඟා විය හැකිය. ඔබ එහි සඳහන් කරන ඕනෑම දෙයක් Omarchy හි පෙරනිමි අගයන් වෙනුවට ආදේශ වේ.

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

ආදාන සඳහා වන Hyprland wiki එකෙන් ඔබට [සියලුම ආදාන විකල්ප බලන්න](https://wiki.hypr.land/Configuring/Basics/Variables/#input) පුළුවන්.

CapsLock සාමාන්‍ය Caps Lock එකක් ලෙස ක්‍රියා කරන අතර, `Shift + CapsLock` යනු [ඉක්මන් emojis](07-hotkeys.md#quick-emojis) සහ [වෙනත් සම්පූර්ණ කිරීම්](07-hotkeys.md#quick-completions) සඳහා වන compose යතුරයි. ඔබට compose යතුර වෙනත් තැනක තැබීමට අවශ්‍ය නම්, `kb_options` තුළ ඇති `omarchy:shift_caps_compose` වෙනුවට එය ආදේශ කරන්න. උදාහරණයක් ලෙස, මෙය compose යතුර Right Alt වෙත ගෙන යයි:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Function යතුරු

ලැප්ටොප් යතුරුපුවරුවක ඉහළ පේළිය පෙරනිමියෙන් මාධ්‍ය යතුරු (ශබ්දය, දීප්තිය සහ වෙනත් දේ) යවන අතර, `Fn` අල්ලාගෙන සිටීමෙන් F1-F12 ලැබේ; `Fn + Esc` ඔබ එය නැවත ඔබන තුරු එය අනෙක් අතට අගුළු දමයි. බොහෝ යතුරුපුවරු එම අගුළ තමන් විසින්ම මතක තබා ගනී. ASUS ලැප්ටොප් සහ Apple විලාසිතාවේ යතුරුපුවරු එය Linux වෙත භාර දෙන අතර, Linux සෑම ආරම්භයකදීම ඒවා මාධ්‍ය යතුරුවලින් ආරම්භ කරයි. ඒ වෙනුවට ඒවා F1-F12 වලින් ආරම්භ වීමට ඔබට අවශ්‍ය නම්, `omarchy keyboard toprow fnkeys` ධාවනය කරන්න (ආපසු යාමට `omarchy keyboard toprow mediakeys`); සමහර ලැප්ටොප්වල මෙය නැවත ආරම්භ කිරීමකින් පසු ක්‍රියාත්මක වේ. Apple Silicon Mac සියම තමන්ගේම සැකසුම තබා ගනී.

### Trackpad අභිනයන්

ඩෙස්ක්ටොප් එක වටා ගමන් කිරීමට trackpad එක මත අතුල්ලන්න:

| අභිනය | ක්‍රියාව |
| --- | --- |
| ඇඟිලි තුනක් වමට / දකුණට | පෙර / ඊළඟ workspace, හිස් ඒවාද ඇතුළුව |
| ඇඟිලි තුනක් ඉහළට | AI කොන්සෝලය ටොගල් කරන්න |
| ඇඟිලි තුනක් පහළට | Omarchy මෙනුව විවෘත කරන්න |
| ඇඟිලි හතරක් වමට / දකුණට | සක්‍රිය කවුළුව පෙර / ඊළඟ workspace වෙත ගෙන යන්න |
| ඇඟිලි හතරක් පහළට | පූර්ණ තිරය ටොගල් කරන්න |

එකක් වෙනස් කිරීමට, ඔබේම [touchpad අභිනය](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) එක් කිරීමට පෙර `~/.config/hypr/input.lua` තුළ එය unset කරන්න, මන්ද Hyprland එකම ඇඟිලි සහ දිශාව මත අභිනයන් දෙකක් භාර නොගන්නා බැවිනි:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy හි සියලුම අභිනයන් අක්‍රිය කිරීමට, Omarchy හි පෙරනිමි අගයන් පූරණය වීමට පෙර, `~/.config/hypr/hyprland.lua` හි ඉහළට ආසන්නයේ `omarchy_default_gestures = false` ලෙස සකසන්න.

හැප්ටික් touchpad එකක් ඇති Dell XPS ලැප්ටොප්වල, _Trigger > Hardware > Touchpad Haptics_ යටතේ ඔබට ක්ලික් කිරීමේ ශක්තිය low, mid, හෝ high ලෙසද සැකසිය හැකිය.

### චීන, ජපන්, සහ වෙනත් භාෂාවලින් ටයිප් කිරීම

ස්ථාපකය ඔබේ යතුරුපුවරුව ගැන විමසන විට Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), හෝ Hong Kong (Cangjie) තෝරන්න. Omarchy යතුරුපුවරුව සහ ගැලපෙන ආදාන එන්ජිම ස්වයංක්‍රීයව වින්‍යාස කරයි, නොබැඳි පළමු ආරම්භ සැකසුම අතරතුරද ඇතුළුව. Japanese විසින් Mozc භාවිත කරයි, Korean සම්මත two-set Hangul භාවිත කරයි, Simplified Chinese විසින් Pinyin භාවිත කරයි, Taiwan විසින් Chewing හි සම්මත Zhuyin සැකැස්ම භාවිත කරයි, සහ Hong Kong විසින් Hong Kong අක්ෂර ආකාර සහිත Cangjie භාවිත කරයි. Japanese (US keyboard) විසින් US යතුරුපුවරු පිරිසැලසුමක් සහිත Mozc සපයයි. ඔබ Dvorak, Colemak, හෝ AZERTY සමඟ ලතින් අකුරු ටයිප් කරන විට පවා Hangul, Zhuyin, සහ Cangjie යතුරු ඒවායේ සම්මත ස්ථානවලම පවතී. ඔබ මීට පෙර Hangul හෝ Chewing එක් කර ඇත්නම්, එහි යතුරු එම ස්ථානවලට ගෙන යාමට _Setup > Keyboard > Input Methods_ යටතේ එය තේරීම ඉවත් කර නැවත තෝරන්න; ඔබ දැනටමත් ටයිප් කිරීමට භාවිත කරන එන්ජිමක් Omarchy එලෙසම තබයි.

ටයිප් කිරීම ලතින් මාදිලියෙන් ආරම්භ වේ. වින්‍යාස කර ඇති ආදාන ක්‍රම හරහා චක්‍රීයව යාමට `Super + I` ඔබන්න, සහ ආපසු චක්‍රීයව යාමට `Super + Shift + I` ඔබන්න. Pinyin වැනි ආදාන ක්‍රමයකින් ලතින් අකුරු වෙත පියවර තැබීමට `Shift` තනිවම තට්ටු කරන්න, සහ ආපසු යාමට එය නැවත තට්ටු කරන්න, Sogou, Microsoft Pinyin, සහ macOS ක්‍රියා කරන ආකාරයටම; `Shift` සහ අකුරක් එක්ව තවමත් ලොකු අකුරක් ටයිප් කරයි. ජපන් යතුරුපුවරුවල, 全角/半角 ආදානය ටොගල් කරයි, 変換 එය සක්‍රිය කරයි, සහ 無変換 එය අක්‍රිය කරයි. Korean සමඟ, 한/영 Hangul මාරු කරන අතර 한자 Hanja බවට පරිවර්තනය කරයි, ඔබේ යතුරුපුවරුවේ ඒ සඳහාම වෙන් වූ යතුරු තිබුණත්, බොහෝ ලැප්ටොප් කරන ආකාරයට ඒවා සඳහා Right Alt සහ Right Ctrl යැව්වත්, එබැවින් Right Alt සහ Right Ctrl එහි සරල විකරණය කරන්නන් නොවේ; ඒ වෙනුවට උච්චාරණය Alt + Space සමඟ ටොගල් වේ. `Ctrl + Space` Tmux සහ Herdr සඳහා ලබා ගත හැකිව පවතී; `Shift + CapsLock` compose යතුර ලෙසම පවතී.

ඔබට යතුරුපුවරු පිරිසැලසුම් හෝ ආදාන ක්‍රම කිහිපයක් ඇති විට යතුරුපුවරු දර්ශකය තීරුවේ දකුණු පසින් දිස් වේ. ආදාන භාෂා මාරු කිරීමට එය ක්ලික් කරන්න; Japanese විසින් hiragana සඳහා あ පෙන්වයි. ජපන් අක්ෂර තේරීම් සඳහා, Japanese වෙත මාරු වන්න, `nihongo` වැනි වචනයක් ටයිප් කරන්න, ඉන්පසු Space දෙවරක් ඔබන්න. ඔබේ තේරීම පිළිගැනීමට Enter ඔබන්න. ඔබට යතුරුපුවරු පිරිසැලසුම් කිහිපයක්ද ඇත්නම්, ඒවා හරහා චක්‍රීයව යාමට දර්ශකය දකුණු-ක්ලික් කරන්න.

ස්ථාපනය අතරතුර පිරිනමන ලද එම තේරීම්වලින්ම, English සහ French වැනි පිරිසැලසුම් තේරීමට _Setup > Keyboard > Keyboard Inputs_ භාවිත කරන්න. කුමන සංයුති එන්ජින් සක්‍රියද යන්න තේරීමට _Setup > Keyboard > Input Methods_ භාවිත කරන්න. තේරීම්කාරක දෙකම ඔබේ වත්මන් තේරීම් සලකුණු කර ඇතිව Omarchy මෙනුව තුළ විවෘත වේ. තේරීමක් ටොගල් කිරීමට ක්ලික් කරන්න හෝ Enter ඔබන්න; සෑම වෙනසක්ම වහාම ක්‍රියාත්මක වේ. ආදාන ක්‍රමයක තේරීම ඉවත් කිරීම එය අස්ථාපනය නොකර චක්‍රයෙන් එය ඉවත් කරයි; යතුරුපුවරුව ලබා ගත හැකිව පවතී.

එම තේරීම්කාරකම විවෘත කිරීමට `omarchy setup keyboard` හෝ `omarchy setup input` ධාවනය කරන්න. විධාන පේළියෙන් එක් භාෂාවක් එක් කිරීමට, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, හෝ `cangjie5` භාවිත කරන්න. Quick, Boshiamy, සහ Array, Cangjie සමඟම එකම පැකේජයේ එන අතර Input Methods තේරීම්කාරකය තුළ දිස් වේ. ඔබේ අභිරුචි මාරු කිරීමේ යතුරු ආරක්ෂා කරනු ලැබේ. විකල්ප එන්ජින් පිරිසැලසුම් හෝ යතුරු සඳහා, `omarchy pkg add fcitx5-configtool` සමඟ `fcitx5-configtool` ස්ථාපනය කර එය ටර්මිනලයකින් දියත් කරන්න. ආදාන භාෂාවක් තේරීම ඩෙස්ක්ටොප් භාෂාව වෙනස් නොකරයි. ඔබට තවම එකක් නැති විට _Setup > Language_ යටතේ Japanese, Korean, හෝ Chinese තේරීම එහි ආදාන ක්‍රමය එක් කරයි.

ආදාන ක්‍රම හෝ යතුරුපුවරු පිරිසැලසුම් හරහා චක්‍රීයව යාමට `Super + I` භාවිත කරන්න, සහ අනෙක් අතට ආපසු යාමට `Super + Shift + I` භාවිත කරන්න, එබැවින් තුනක් වින්‍යාස කර ඇති විට ඔබට අසල්වැසියන් දෙදෙනෙකු අතර ගමන් කළ හැකිය. ආදාන ක්‍රමයක් හෝ පිරිසැලසුමක් එකකට වඩා වින්‍යාස කර ඇති විට පමණක් ආදාන දර්ශකය තීරුවේ දකුණු පසින් දිස් වේ. මෙම ඩෙස්ක්ටොප් බන්ධනය ඔබේ පවතින Fcitx මාරු කිරීමේ යතුරු සමඟම ක්‍රියා කරන අතර; ඔබට එය `~/.config/hypr/bindings.lua` තුළ අභිබවා යා හැකිය. ආදාන එන්ජින් සහ compose අනුක්‍රම සෑම සැසියකම දැනටමත් ධාවනය වන [Fcitx5](https://fcitx-im.org/) සේවාව භාවිත කරයි.

### ALT, SUPER ලෙස භාවිත කරන්න

සමහර යතුරුපුවරුවල, ප්‍රාථමික meta යතුර (Windows/cmd යතුර) SUPER ලෙස භාවිත කිරීම පහසු නැත. මෙම වෙනස භාවිතයෙන් ඔබට ඒ වෙනුවට එය ALT ලෙස වෙනස් කළ හැකිය:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
