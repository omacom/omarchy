# යතුරුපුවරුව, මූසිකය, Trackpad

Hyprland මඟින් ඔබේ සියලු ආදාන ඉතා සවිස්තරාත්මකව වින්‍යාස කිරීමට ඔබට ඉඩ දෙයි. ඔබට යතුරුපුවරු පුනරාවර්තනය අතිධ්වනි වේගයෙන් ක්‍රියා කරන ලෙස වෙනස් කිරීමට හෝ trackpad එක ස්වාභාවික අනුචලනය භාවිත කරන ලෙස සැකසීමට හැකිය. ඔබ මේ සියල්ල වෙනස් කරන්නේ `~/.config/hypr/input.lua` තුළ වන අතර, Omarchy මෙනුවේ (`Super + Space`) _Setup > Input_ හරහාද ඔබට එයට පිවිසිය හැකිය. ඔබ එහි සකසන ඕනෑම දෙයක් Omarchy හි පෙරනිමියන් වෙනුවට ආදේශ වේ.

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

ආදාන සඳහා Hyprland wiki එකේ [සියලු ආදාන විකල්ප ඔබට දැකගත හැකිය](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock සාමාන්‍ය Caps Lock එකක් ලෙස ක්‍රියා කරන අතර, `Shift + CapsLock` යනු [ඉක්මන් emojis](07-hotkeys.md#quick-emojis) සහ [අනෙකුත් සම්පූර්ණ කිරීම්](07-hotkeys.md#quick-completions) සඳහා වන compose යතුරයි. ඔබට compose යතුර වෙනත් තැනක තිබීම වඩා කැමති නම්, `kb_options` තුළ ඇති `omarchy:shift_caps_compose` වෙනුවට ආදේශ කරන්න. උදාහරණයක් ලෙස, මෙය compose යතුර Right Alt වෙත ගෙන යයි:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad අභිනයන්

ඩෙස්ක්ටොප් එක වටා ගමන් කිරීමට trackpad එක මත swipe කරන්න:

| අභිනය | ක්‍රියාව |
| --- | --- |
| ඇඟිලි තුනක් වමට / දකුණට | හිස් ඒවාද ඇතුළුව, පෙර / ඊළඟ workspace එක |
| ඇඟිලි තුනක් ඉහළට | AI console එක toggle කිරීම |
| ඇඟිලි තුනක් පහළට | Omarchy මෙනුව විවෘත කිරීම |
| ඇඟිලි හතරක් වමට / දකුණට | සක්‍රිය කවුළුව පෙර / ඊළඟ workspace එකට ගෙන යාම |
| ඇඟිලි හතරක් පහළට | Fullscreen toggle කිරීම |

එකක් වෙනස් කිරීමට, ඔබේම [touchpad අභිනයක්](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) එකතු කිරීමට පෙර `~/.config/hypr/input.lua` තුළ එය unset කරන්න, මන්ද Hyprland එකම ඇඟිලි සහ දිශාව සඳහා අභිනයන් දෙකක් නොගන්නා බැවිනි:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy හි සියලු අභිනයන් අක්‍රිය කිරීමට, Omarchy හි පෙරනිමියන් load වීමට පෙර, `~/.config/hypr/hyprland.lua` හි ඉහළට ආසන්නයේ `omarchy_default_gestures = false` ලෙස සකසන්න.

Haptic touchpad එකක් සහිත Dell XPS laptops වල, _Trigger > Hardware > Touchpad Haptics_ යටතේ click කිරීමේ ශක්තිය අඩු, මැද, හෝ වැඩි ලෙසද ඔබට සැකසිය හැකිය.

### චීන, ජපන් සහ වෙනත් භාෂාවලින් ටයිප් කිරීම

Installer එක ඔබේ යතුරුපුවරුව ගැන අසන විට Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), හෝ Hong Kong (Cangjie) තෝරන්න. Offline පළමු ආරම්භක සැකසුම අතරතුරද ඇතුළුව, Omarchy විසින් යතුරුපුවරුව සහ ඊට ගැලපෙන ආදාන එන්ජිම ස්වයංක්‍රීයව වින්‍යාස කරයි. Japanese සඳහා Mozc භාවිත කරයි, Korean සඳහා සම්මත two-set Hangul භාවිත කරයි, Simplified Chinese සඳහා Pinyin භාවිත කරයි, Taiwan සඳහා Chewing හි සම්මත Zhuyin සැකැස්ම භාවිත කරයි, සහ Hong Kong සඳහා Hong Kong අක්ෂර ආකෘති සහිත Cangjie භාවිත කරයි. Japanese (US keyboard) මඟින් US යතුරුපුවරු සැකැස්මක් සහිත Mozc සපයයි. ඔබ Dvorak, Colemak, හෝ AZERTY සමඟ Latin අකුරු ටයිප් කරන විට පවා Hangul, Zhuyin, සහ Cangjie යතුරු ඒවායේ සම්මත ස්ථානවලම පවතී. ඔබ මීට පෙර Hangul හෝ Chewing එකතු කළා නම්, එහි යතුරු එම ස්ථානවලට ගෙන යාමට _Setup > Typing > Input Methods_ යටතේ එය තේරීමෙන් ඉවත් කර නැවත තෝරන්න; ඔබ දැනටමත් ටයිප් කිරීමට භාවිත කරන එන්ජිමක් Omarchy විසින් එලෙසම තබයි.

ටයිප් කිරීම Latin මාදිලියෙන් ආරම්භ වේ. වින්‍යාස කළ ආදාන ක්‍රම අතර චක්‍රීයව මාරු වීමට `Super + I` ඔබන්න, සහ ආපසු චක්‍රීයව යාමට `Super + Shift + I` ඔබන්න. Sogou, Microsoft Pinyin, සහ macOS ක්‍රියා කරන ආකාරයටම, Pinyin වැනි ආදාන ක්‍රමයකින් පිටත්ව Latin අකුරු වෙත යාමට `Shift` තනිවම තට්ටු කරන්න, සහ ආපසු යාමට එය නැවත තට්ටු කරන්න; `Shift` සහ අකුරක් එක්ව තවමත් ලොකු අකුරක් ටයිප් කරයි. ජපන් යතුරුපුවරුවල, 全角/半角 ආදානය toggle කරයි, 変換 එය සක්‍රිය කරයි, සහ 無変換 එය අක්‍රිය කරයි. Korean සමඟ, 한/영 Hangul මාරු කරයි සහ 한자 Hanja බවට පරිවර්තනය කරයි, ඔබේ යතුරුපුවරුවට ඒ සඳහා කැපවුණු යතුරු තිබුණත්, බොහෝ laptops කරන පරිදි ඒවා සඳහා Right Alt සහ Right Ctrl යවතත්, එබැවින් එහි Right Alt සහ Right Ctrl සරල modifiers නොවේ; dictation push-to-talk F9 මතම පවතී. `Ctrl + Space` Tmux සහ Herdr සඳහා ලබාගත හැකිව පවතී; `Shift + CapsLock` compose යතුර ලෙසම පවතී.

ඔබට යතුරුපුවරු සැකැස්ම හෝ ආදාන ක්‍රම කිහිපයක් ඇති විට යතුරුපුවරු දර්ශකය bar එකේ දකුණු පසින් දිස් වේ. ආදාන භාෂා මාරු කිරීමට එය click කරන්න; Japanese මඟින් hiragana සඳහා あ දර්ශනය කරයි. ජපන් අක්ෂර තේරීම් සඳහා, Japanese වෙත මාරු වන්න, `nihongo` වැනි වචනයක් ටයිප් කරන්න, ඉන්පසු Space දෙවරක් ඔබන්න. ඔබේ තේරීම පිළිගැනීමට Enter ඔබන්න. ඔබට යතුරුපුවරු සැකැස්ම කිහිපයක්ද තිබේ නම්, ඒවා අතර චක්‍රීයව යාමට දර්ශකය right-click කරන්න.

ස්ථාපනය අතරතුර පිරිනමනු ලබන එකම තේරීම්වලින් English සහ French වැනි සැකැස්ම තේරීමට _Setup > Typing > Keyboard Layouts_ භාවිත කරන්න. කුමන composition එන්ජින් සක්‍රියද යන්න තේරීමට _Setup > Typing > Input Methods_ භාවිත කරන්න. Picker දෙකම ඔබේ වත්මන් තේරීම් check කර ඇතිව Omarchy මෙනුව තුළ විවෘත වේ. තේරීමක් toggle කිරීමට click කරන්න හෝ Enter ඔබන්න; සෑම වෙනසක්ම වහාම ක්‍රියාත්මක වේ. ආදාන ක්‍රමයක තේරීම ඉවත් කිරීමෙන් එය uninstall නොකර චක්‍රයෙන් ඉවත් කරයි; යතුරුපුවරුව තවමත් ලබාගත හැකිය.

එකම picker විවෘත කිරීමට `omarchy setup keyboard` හෝ `omarchy setup input` ධාවනය කරන්න. Command line එකෙන් එක් භාෂාවක් ඇමිණීමට, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, හෝ `cangjie5` භාවිත කරන්න. Quick, Boshiamy, සහ Array, Cangjie සහිත එකම package එකෙන් ලැබෙන අතර Input Methods picker එකේ දිස් වේ. ඔබේ අභිරුචි මාරු කිරීමේ යතුරු ආරක්ෂා වේ. විකල්ප එන්ජින් සැකැස්ම හෝ යතුරු සඳහා, `omarchy pkg add fcitx5-configtool` සමඟ `fcitx5-configtool` ස්ථාපනය කර terminal එකකින් එය launch කරන්න. ආදාන භාෂාවක් තේරීමෙන් ඩෙස්ක්ටොප් භාෂාව වෙනස් නොවේ. ඔබට තවම එකක් නොමැති විට _Setup > Language_ යටතේ Japanese, Korean, හෝ Chinese තේරීමෙන් එහි ආදාන ක්‍රමය එකතු වේ.

ආදාන ක්‍රම හෝ යතුරුපුවරු සැකැස්ම අතර චක්‍රීයව යාමට `Super + I` භාවිත කරන්න, සහ අනෙක් දිශාවට ආපසු යාමට `Super + Shift + I` භාවිත කරන්න, එබැවින් වින්‍යාස කළ තුනක් සමඟ ඔබට අසල්වැසියන් දෙදෙනෙකු අතර ගමන් කළ හැකිය. ආදාන ක්‍රමයක් හෝ සැකැස්මක් එකකට වඩා වින්‍යාස කර ඇති විට පමණක් ආදාන දර්ශකය bar එකේ දකුණු පසින් දිස් වේ. මෙම ඩෙස්ක්ටොප් බැඳීම ඔබේ පවතින Fcitx මාරු කිරීමේ යතුරු සමඟ ක්‍රියා කරයි; ඔබට `~/.config/hypr/bindings.lua` තුළ එය override කළ හැකිය. ආදාන එන්ජින් සහ compose අනුපිළිවෙලවල් සෑම session එකකම දැනටමත් ධාවනය වන [Fcitx5](https://fcitx-im.org/) සේවාව භාවිත කරයි.

### ALT එක SUPER ලෙස භාවිත කිරීම

සමහර යතුරුපුවරුවල, ප්‍රාථමික meta යතුර (Windows/cmd යතුර) SUPER ලෙස භාවිත කිරීම පහසු නැත. මෙම වෙනස භාවිත කරමින් ඔබට ඒ වෙනුවට ALT භාවිත කිරීමට මෙය වෙනස් කළ හැකිය:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
