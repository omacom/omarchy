# යතුරුපුවරුව, මූසිකය, ට්‍රැක්පෑඩය

Hyprland මඟින් ඔබේ සියලුම ආදාන ඉතා සවිස්තරාත්මකව වින්‍යාස කිරීමට ඔබට ඉඩ දෙයි. ඔබට යතුරුපුවරු පුනරාවර්තනය අතිශය වේගවත් කළ හැකිය, නැතහොත් ට්‍රැක්පෑඩය natural scrolling භාවිත කරන ලෙස සැකසිය හැකිය. ඔබ මේ සියල්ල වෙනස් කරන්නේ `~/.config/hypr/input.lua` තුළිනි, එය Omarchy මෙනුව (`Super + Space`) හරහා _Setup > Input_ වෙතින්ද ළඟා විය හැකිය. ඔබ එහි සකසන ඕනෑම දෙයක් Omarchy හි පෙරනිමි සැකසුම් ප්‍රතිස්ථාපනය කරයි.

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

ආදාන සඳහා වන Hyprland wiki එකේ [සියලුම ආදාන විකල්ප දැකගත හැකිය](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock සාමාන්‍ය Caps Lock එකක් ලෙස ක්‍රියා කරන අතර, `Shift + CapsLock` යනු [ඉක්මන් emojis](07-hotkeys.md#quick-emojis) සහ [වෙනත් සම්පූර්ණ කිරීම්](07-hotkeys.md#quick-completions) සඳහා compose යතුරයි. ඔබට compose යතුර වෙනත් තැනක තැබීමට අවශ්‍ය නම්, `kb_options` හි `omarchy:shift_caps_compose` ප්‍රතිස්ථාපනය කරන්න. උදාහරණයක් ලෙස, මෙය compose යතුර Right Alt වෙත ගෙන යයි:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ක්‍රියාකාරී යතුරු

ලැප්ටොප් යතුරුපුවරුවක ඉහළ පෙළ පෙරනිමියෙන් media යතුරු (ශබ්දය, දීප්තිය සහ ආදී) යවන අතර, `Fn` අල්ලාගෙන සිටීමෙන් F1-F12 ලැබේ; `Fn + Esc` ඔබ එය නැවත එබන තුරු එය අනෙක් අතට අගුළු දමයි. බොහෝ යතුරුපුවරු එම අගුළ තමන්ම මතක තබා ගනී. ASUS ලැප්ටොප් සහ Apple විලාසිතාවේ යතුරුපුවරු එය Linux වෙත පවරන අතර, එය සෑම ඇරඹුමකදීම ඒවා media යතුරු වලින් ආරම්භ කරයි. ඒ වෙනුවට ඒවා F1-F12 වලින් ආරම්භ කිරීමට, `omarchy device keyboard toprow fnkeys` ධාවනය කරන්න (ආපසු යාමට `omarchy device keyboard toprow mediakeys`); සමහර ලැප්ටොප් වල එය නැවත ආරම්භ කිරීමකින් පසු ක්‍රියාත්මක වේ. Apple Silicon Macs ඒවායේම සැකසුම තබා ගනී.

### ට්‍රැක්පෑඩ අභිනයන්

ඩෙස්ක්ටොප් එක වටා ගමන් කිරීමට ට්‍රැක්පෑඩය මත ස්වයිප් කරන්න:

| අභිනය | ක්‍රියාව |
| --- | --- |
| ඇඟිලි තුන වමට / දකුණට | හිස් ඒවා ඇතුළුව, පෙර / ඊළඟ workspace එක |
| ඇඟිලි තුන ඉහළට | AI කොන්සෝලය සක්‍රිය/අක්‍රිය කරන්න |
| ඇඟිලි තුන පහළට | Omarchy මෙනුව විවෘත කරන්න |
| ඇඟිලි හතර වමට / දකුණට | සක්‍රිය කවුළුව පෙර / ඊළඟ workspace එකට ගෙන යන්න |
| ඇඟිලි හතර පහළට | fullscreen සක්‍රිය/අක්‍රිය කරන්න |

එකක් වෙනස් කිරීමට, ඔබේම [touchpad අභිනයක්](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) එක් කිරීමට පෙර `~/.config/hypr/input.lua` තුළ එය unset කරන්න, මන්ද Hyprland එකම ඇඟිලි සහ දිශාව මත අභිනයන් දෙකක් භාර නොගන්නා බැවිනි:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy හි සියලුම අභිනයන් අක්‍රිය කිරීමට, Omarchy හි පෙරනිමි පූරණය වීමට පෙර, `~/.config/hypr/hyprland.lua` හි ඉහළට ආසන්නව `omarchy_default_gestures = false` ලෙස සකසන්න.

haptic touchpad එකක් සහිත Dell XPS ලැප්ටොප් වල, _Trigger > Hardware > Touchpad Haptics_ යටතේ ඔබ ක්ලික් කිරීමේ තදබලය low, mid, හෝ high ලෙසද සකසන්න.

### චීන, ජපන් සහ වෙනත් භාෂා වලින් ටයිප් කිරීම

ස්ථාපකය ඔබේ යතුරුපුවරුව ගැන අසන විට Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), හෝ Hong Kong (Cangjie) තෝරන්න. නොබැඳි පළමු ඇරඹුම් සැකසුම අතරතුරද ඇතුළුව, Omarchy යතුරුපුවරුව සහ ගැලපෙන ආදාන එන්ජිම ස්වයංක්‍රීයව වින්‍යාස කරයි. Japanese Mozc භාවිත කරන අතර, Korean සම්මත two-set Hangul භාවිත කරයි, Simplified Chinese Pinyin භාවිත කරයි, Taiwan Chewing හි සම්මත Zhuyin සැකැස්ම භාවිත කරයි, සහ Hong Kong Hong Kong අක්ෂර ආකාර සහිත Cangjie භාවිත කරයි. Japanese (US keyboard) US යතුරුපුවරු සැකැස්මක් සහිත Mozc සපයයි. ඔබ Dvorak, Colemak, හෝ AZERTY සමඟ ලතින් අක්ෂර ටයිප් කරන විට පවා Hangul, Zhuyin, සහ Cangjie යතුරු ඒවායේ සම්මත ස්ථාන වලම පවතී. ඔබ මෙයට පෙර Hangul හෝ Chewing එක් කර තිබුණේ නම්, එහි යතුරු එහි ගෙන යාමට _Setup > Keyboard > Input Methods_ යටතේ එය තේරීම ඉවත් කර නැවත තෝරන්න; ඔබ දැනටමත් ටයිප් කිරීමට භාවිත කරන එන්ජිමක් Omarchy තනිවම තබයි.

ටයිප් කිරීම ලතින් ආකාරයෙන් ආරම්භ වේ. වින්‍යාස කළ ආදාන ක්‍රම හරහා චක්‍රීයව යාමට `Super + I` ඔබන්න, සහ ආපසු චක්‍රීයව යාමට `Super + Shift + I` ඔබන්න. Pinyin වැනි ආදාන ක්‍රමයකින් ලතින් අක්ෂර වෙත පිටත් වීමට `Shift` තනිවම තට්ටු කරන්න, සහ ආපසු යාමට එය නැවත තට්ටු කරන්න, Sogou, Microsoft Pinyin, සහ macOS ක්‍රියා කරන ආකාරයටම; `Shift` සහ අකුරක් එක්ව තවමත් ලොකු අකුරක් ටයිප් කරයි. ජපන් යතුරුපුවරු වල, 全角/半角 ආදානය සක්‍රිය/අක්‍රිය කරයි, 変換 එය සක්‍රිය කරයි, සහ 無変換 එය අක්‍රිය කරයි. Korean සමඟ, 한/영 Hangul මාරුにする අතර 한자 Hanja බවට පරිවර්තනය කරයි, ඔබේ යතුරුපුවරුවට ඒ සඳහා කැපවුණු යතුරු තිබුණත්, බොහෝ ලැප්ටොප් කරන ආකාරයට ඒ සඳහා Right Alt සහ Right Ctrl යැව්වත්, එබැවින් Right Alt සහ Right Ctrl එහි සරල modifiers නොවේ; ඒ වෙනුවට කටහඬින් ලිවීම Alt + Space සමඟ සක්‍රිය/අක්‍රිය වේ. `Ctrl + Space` Tmux සහ Herdr සඳහා තවමත් ලබා ගත හැකිය; `Shift + CapsLock` තවමත් compose යතුරයි.

ඔබට බහුවිධ යතුරුපුවරු සැකැස්ම හෝ ආදාන ක්‍රම ඇති විට යතුරුපුවරු දර්ශකය තීරුවේ දකුණේ දිස් වේ. ආදාන භාෂා මාරු කිරීමට එය ක්ලික් කරන්න; Japanese hiragana සඳහා あ දර්ශනය කරයි. ජපන් අක්ෂර තේරීම් සඳහා, Japanese වෙත මාරු වන්න, `nihongo` වැනි වචනයක් ටයිප් කරන්න, ඉන්පසු Space දෙවරක් ඔබන්න. ඔබේ තේරීම පිළිගැනීමට Enter ඔබන්න. ඔබට බහුවිධ යතුරුපුවරු සැකැස්මද ඇත්නම්, ඒවා හරහා චක්‍රීයව යාමට දර්ශකය right-click කරන්න.

ස්ථාපනය අතරතුර ඉදිරිපත් කළ එම තේරීම් වලින්ම English සහ French වැනි සැකැස්ම තේරීමට _Setup > Keyboard > Keyboard Inputs_ භාවිත කරන්න. කුමන සංයුති එන්ජින් සක්‍රියද යන්න තේරීමට _Setup > Keyboard > Input Methods_ භාවිත කරන්න. තෝරන්නන් දෙකම ඔබේ වත්මන් තේරීම් පරීක්ෂා කර ඇතිව Omarchy මෙනුව තුළ විවෘත වේ. තේරීමක් සක්‍රිය/අක්‍රිය කිරීමට ක්ලික් කරන්න හෝ Enter ඔබන්න; සෑම වෙනසක්ම වහාම ක්‍රියාත්මක වේ. ආදාන ක්‍රමයක තේරීම ඉවත් කිරීම එය අස්ථාපනය නොකර චක්‍රයෙන් ඉවත් කරයි; යතුරුපුවරුව තවමත් ලබා ගත හැකිය.

එම තෝරන්නන්ම විවෘත කිරීමට `omarchy setup keyboard` හෝ `omarchy setup input` ධාවනය කරන්න. විධාන රේඛාවෙන් එක් භාෂාවක් ඇතුළත් කිරීමට, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, හෝ `cangjie5` භාවිත කරන්න. Quick, Boshiamy, සහ Array Cangjie ලෙසම එකම පැකේජයේ එන අතර Input Methods තෝරන්නා තුළ දිස් වේ. ඔබේ අභිරුචි මාරු කිරීමේ යතුරු ආරක්ෂා වේ. විකල්ප එන්ජින් සැකැස්ම හෝ යතුරු සඳහා, `omarchy pkg add fcitx5-configtool` සමඟ `fcitx5-configtool` ස්ථාපනය කර එය පර්යන්තයකින් දියත් කරන්න. ආදාන භාෂාවක් තේරීම ඩෙස්ක්ටොප් භාෂාව වෙනස් නොකරයි. _Setup > Language_ යටතේ Japanese, Korean, හෝ Chinese තේරීම, ඔබට තවම කිසිවක් නැති විට එහි ආදාන ක්‍රමය එක් කරයි.

ආදාන ක්‍රම හෝ යතුරුපුවරු සැකැස්ම හරහා චක්‍රීයව යාමට `Super + I` භාවිත කරන්න, සහ අනෙක් දිශාවට ආපසු යාමට `Super + Shift + I` භාවිත කරන්න, එබැවින් වින්‍යාස කළ තුනක් සමඟ ඔබට අසල්වැසියන් දෙදෙනෙකු අතර ගමන් කළ හැකිය. ආදාන දර්ශකය තීරුවේ දකුණේ දිස් වන්නේ එක් ආදාන ක්‍රමයකට හෝ සැකැස්මකට වඩා වැඩි ගණනක් වින්‍යාස කර ඇති විට පමණි. මෙම ඩෙස්ක්ටොප් බන්ධනය ඔබේ පවතින Fcitx මාරු කිරීමේ යතුරු සමඟ ක්‍රියා කරන අතර; ඔබට එය `~/.config/hypr/bindings.lua` තුළ අභිබවා යා හැකිය. ආදාන එන්ජින් සහ compose අනුක්‍රම සෑම සැසියකම දැනටමත් ධාවනය වන [Fcitx5](https://fcitx-im.org/) සේවාව භාවිත කරයි.

### ALT එක SUPER ලෙස භාවිත කිරීම

සමහර යතුරුපුවරු වල, ප්‍රාථමික meta යතුර (Windows/cmd යතුර) SUPER ලෙස භාවිත කිරීම පහසු නැත. ඒ වෙනුවට මෙය ALT ලෙස වෙනස් කිරීමට ඔබට මෙම වෙනස භාවිත කළ හැකිය:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
