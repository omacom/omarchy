# යතුරුපුවරුව, මූසිකය, Trackpad

Hyprland මඟින් ඔබේ සියලුම ආදාන ඉතා සවිස්තරාත්මකව වින්‍යාස කිරීමට ඔබට ඉඩ දෙයි. ඔබට යතුරුපුවරු පුනරාවර්තනය අතිධ්වනික තරම් වේගවත් වන ලෙස වෙනස් කිරීමට හෝ trackpad එක natural scrolling භාවිත කරන ලෙස සැකසීමට හැකිය. ඔබ මේ සියල්ල වෙනස් කරන්නේ `~/.config/hypr/input.lua` තුළ වන අතර, Omarchy මෙනුව (`Super + Space`) තුළ _Setup > Input_ හරහාද ඔබට එයට පිවිසිය හැකිය. ඔබ එහි සකසන ඕනෑම දෙයක් Omarchy හි පෙරනිමි ප්‍රතිස්ථාපනය කරයි.

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

ඔබට ආදාන සඳහා Hyprland wiki එකේ [සියලුම ආදාන විකල්ප දැකගත හැකිය](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock සාමාන්‍ය Caps Lock එකක් ලෙස ක්‍රියා කරන අතර, `Shift + CapsLock` යනු [ඉක්මන් emojis](07-hotkeys.md#quick-emojis) සහ [වෙනත් සම්පූර්ණ කිරීම්](07-hotkeys.md#quick-completions) සඳහා වන compose යතුරයි. ඔබට compose යතුර වෙනත් තැනක තිබීමට අවශ්‍ය නම්, `kb_options` තුළ `omarchy:shift_caps_compose` ප්‍රතිස්ථාපනය කරන්න. උදාහරණයක් ලෙස, මෙය compose යතුර Right Alt වෙත ගෙන යයි:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ශ්‍රිත යතුරු

ලැප්ටොප් යතුරුපුවරුවක ඉහළ පෙළ පෙරනිමියෙන් media යතුරු (ශබ්දය, දීප්තිය ආදිය) යවන අතර, `Fn` අල්ලාගෙන සිටීමෙන් F1-F12 ලැබේ; `Fn + Esc` ඔබ එය නැවත ඔබන තුරු එය අනෙක් අතට අගුළු දමයි. බොහෝ යතුරුපුවරු එම අගුළ තමන් විසින්ම මතක තබා ගනී. ASUS ලැප්ටොප් සහ Apple විලාසිතාවේ යතුරුපුවරු එය Linux වෙත භාර දෙන අතර, Linux සෑම ආරම්භයකදීම ඒවා media යතුරු මතින් ආරම්භ කරයි. ඒ වෙනුවට ඒවා F1-F12 මතින් ආරම්භ වීමට අවශ්‍ය නම්, `omarchy device keyboard toprow fnkeys` ධාවනය කරන්න (ආපසු යාමට `omarchy device keyboard toprow mediakeys`); සමහර ලැප්ටොප් වල එය ක්‍රියාත්මක වන්නේ නැවත ආරම්භ කිරීමෙන් පසුවය. Apple Silicon Macs ඒවායේම සැකසුම තබා ගනී.

### Trackpad අභිනයන්

ඩෙස්ක්ටොප් එක වටා ගමන් කිරීමට trackpad එක මත swipe කරන්න:

| අභිනය | ක්‍රියාව |
| --- | --- |
| ඇඟිලි තුන වමට / දකුණට | හිස් ඒවා ඇතුළුව, පෙර / ඊළඟ workspace එක |
| ඇඟිලි තුන ඉහළට | AI console එක toggle කරන්න |
| ඇඟිලි තුන පහළට | Omarchy මෙනුව විවෘත කරන්න |
| ඇඟිලි හතර වමට / දකුණට | සක්‍රිය කවුළුව පෙර / ඊළඟ workspace එකට ගෙන යන්න |
| ඇඟිලි හතර පහළට | fullscreen toggle කරන්න |

එකක් වෙනස් කිරීමට, ඔබේම [touchpad gesture](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) එකක් එක් කිරීමට පෙර `~/.config/hypr/input.lua` තුළ එය unset කරන්න, මන්ද Hyprland එකම ඇඟිලි සහ දිශාව මත අභිනයන් දෙකක් භාර නොගන්නා බැවිනි:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy හි සියලුම අභිනයන් අක්‍රිය කිරීමට, Omarchy හි පෙරනිමි load වීමට පෙර, `~/.config/hypr/hyprland.lua` හි ඉහළට ආසන්නයේ `omarchy_default_gestures = false` ලෙස සකසන්න.

haptic touchpad එකක් ඇති Dell XPS ලැප්ටොප් වල, ඔබට _Trigger > Hardware > Touchpad Haptics_ යටතේ click කිරීමේ ශක්තිය low, mid, හෝ high ලෙසද සැකසිය හැකිය.

### චීන, ජපන්, සහ වෙනත් භාෂා වලින් ලිවීම

installer එක ඔබේ යතුරුපුවරුව ගැන අසන විට Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), හෝ Hong Kong (Cangjie) තෝරන්න. offline first-boot setup එක අතරතුර ඇතුළුව, Omarchy යතුරුපුවරුව සහ ගැලපෙන ආදාන engine එක ස්වයංක්‍රීයව වින්‍යාස කරයි. Japanese, Mozc භාවිත කරයි; Korean, සම්මත two-set Hangul භාවිත කරයි; Simplified Chinese, Pinyin භාවිත කරයි; Taiwan, Chewing හි සම්මත Zhuyin සැකැස්ම භාවිත කරයි; Hong Kong, Hong Kong අක්ෂර ආකාර සහිත Cangjie භාවිත කරයි. Japanese (US keyboard) මඟින් US යතුරුපුවරු සැකැස්මක් සහිත Mozc සපයයි. ඔබ Dvorak, Colemak, හෝ AZERTY සමඟ Latin අකුරු type කළද Hangul, Zhuyin, සහ Cangjie යතුරු ඒවායේ සම්මත ස්ථානවලම පවතී. ඔබ මීට පෙර Hangul හෝ Chewing එක් කර තිබුණේ නම්, එහි යතුරු එම ස්ථානවලට ගෙන යාමට _Setup > Keyboard > Input Methods_ යටතේ එය තේරීම ඉවත් කර නැවත තෝරන්න; ඔබ දැනටමත් type කිරීමට භාවිත කරන engine එකක් Omarchy විසින් එලෙසම තබයි.

Type කිරීම Latin mode එකෙන් ආරම්භ වේ. වින්‍යාස කර ඇති ආදාන ක්‍රම හරහා යාමට `Super + I` ඔබන්න, ආපසු යාමට `Super + Shift + I` ඔබන්න. Pinyin වැනි ආදාන ක්‍රමයකින් Latin අකුරු වෙත පියවර තැබීමට `Shift` තනිවම tap කරන්න, ආපසු යාමට එය නැවත tap කරන්න, Sogou, Microsoft Pinyin, සහ macOS ක්‍රියා කරන ආකාරයටම; `Shift` සහ අකුරක් එක්ව තවමත් ලොකු අකුරක් type කරයි. Japanese යතුරුපුවරු වල, 全角/半角 ආදානය toggle කරයි, 変換 එය ක්‍රියාත්මක කරයි, 無変換 එය අක්‍රිය කරයි. Korean සමඟ, 한/영 Hangul මාරු කරන අතර 한자 Hanja බවට පරිවර්තනය කරයි, ඔබේ යතුරුපුවරුවට ඒ සඳහා කැපවුණු යතුරු තිබුණත්, බොහෝ ලැප්ටොප් කරන ආකාරයට ඒවා සඳහා Right Alt සහ Right Ctrl යැව්වත්, එබැවින් Right Alt සහ Right Ctrl එහි සාමාන්‍ය modifiers නොවේ; ඒ වෙනුවට dictation එක Alt + Space සමඟ toggle වේ. `Ctrl + Space` Tmux සහ Herdr සඳහා තවමත් ලබාගත හැකිය; `Shift + CapsLock` compose යතුර ලෙසම පවතී.

ඔබට යතුරුපුවරු සැකැස්ම් හෝ ආදාන ක්‍රම කිහිපයක් ඇති විට යතුරුපුවරු දර්ශකය bar එකේ දකුණු පසින් දිස් වේ. ආදාන භාෂා මාරු කිරීමට එය click කරන්න; Japanese, hiragana සඳහා あ පෙන්වයි. Japanese අක්ෂර තේරීම් සඳහා, Japanese වෙත මාරු වී, `nihongo` වැනි වචනයක් type කර, ඉන්පසු Space දෙවරක් ඔබන්න. ඔබේ තේරීම පිළිගැනීමට Enter ඔබන්න. ඔබට යතුරුපුවරු සැකැස්ම් කිහිපයක්ද තිබේ නම්, ඒවා හරහා යාමට දර්ශකය right-click කරන්න.

ස්ථාපනය අතරතුර ලබා දෙන එකම තේරීම් වලින් English සහ French වැනි සැකැස්ම් තේරීමට _Setup > Keyboard > Keyboard Inputs_ භාවිත කරන්න. සක්‍රිය composition engines මොනවාදැයි තේරීමට _Setup > Keyboard > Input Methods_ භාවිත කරන්න. picker දෙකම ඔබේ වත්මන් තේරීම් සලකුණු කර ඇතිව Omarchy මෙනුව තුළ විවෘත වේ. තේරීමක් toggle කිරීමට click කරන්න හෝ Enter ඔබන්න; සෑම වෙනස්කමක්ම වහාම ක්‍රියාත්මක වේ. ආදාන ක්‍රමයක තේරීම ඉවත් කිරීමෙන් එය uninstall නොකර චක්‍රයෙන් ඉවත් කරයි; යතුරුපුවරුව තවමත් ලබාගත හැකිය.

එකම picker විවෘත කිරීමට `omarchy setup keyboard` හෝ `omarchy setup input` ධාවනය කරන්න. command line එකෙන් එක් භාෂාවක් ඇතුළත් කිරීමට, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, හෝ `cangjie5` භාවිත කරන්න. Quick, Boshiamy, සහ Array, Cangjie එකම package එකෙන්ම එන අතර Input Methods picker එකේ දිස් වේ. ඔබේ අභිරුචි මාරු කිරීමේ යතුරු ආරක්ෂා වේ. විකල්ප engine සැකැස්ම් හෝ යතුරු සඳහා, `omarchy pkg add fcitx5-configtool` සමඟ `fcitx5-configtool` ස්ථාපනය කර terminal එකකින් එය ආරම්භ කරන්න. ආදාන භාෂාවක් තේරීමෙන් ඩෙස්ක්ටොප් භාෂාව වෙනස් නොවේ. ඔබ සතුව තවම එකක් නොමැති විට _Setup > Region > Language_ යටතේ Japanese, Korean, හෝ Chinese තේරීමෙන් එහි ආදාන ක්‍රමය එක් වේ.

ආදාන ක්‍රම හෝ යතුරුපුවරු සැකැස්ම් හරහා යාමට `Super + I` භාවිත කරන්න, අනෙක් දිශාවට ආපසු යාමට `Super + Shift + I` භාවිත කරන්න, එවිට තුනක් වින්‍යාස කර ඇති විට ඔබට අසල්වැසියන් දෙදෙනෙකු අතර ගමන් කළ හැකිය. ආදාන දර්ශකය bar එකේ දකුණු පසින් දිස් වන්නේ ආදාන ක්‍රම හෝ සැකැස්ම් එකකට වඩා වින්‍යාස කර ඇති විට පමණි. මෙම desktop binding එක ඔබේ පවතින Fcitx මාරු කිරීමේ යතුරු සමඟම ක්‍රියා කරයි; ඔබට `~/.config/hypr/bindings.lua` තුළ එය override කළ හැකිය. ආදාන engines සහ compose අනුපිළිවෙලවල් සෑම session එකකම දැනටමත් ධාවනය වන [Fcitx5](https://fcitx-im.org/) සේවාව භාවිත කරයි.

### ALT එක SUPER ලෙස භාවිත කරන්න

සමහර යතුරුපුවරු වල, ප්‍රාථමික meta යතුර (Windows/cmd යතුර) SUPER ලෙස භාවිත කිරීම පහසු නැත. මෙම වෙනස භාවිතයෙන් ඔබට එය ඒ වෙනුවට ALT වන ලෙස වෙනස් කළ හැකිය:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
