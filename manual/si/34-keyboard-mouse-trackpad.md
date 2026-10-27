# යතුරුපුවරුව, මූසිකය, Trackpad

Hyprland මඟින් ඔබේ සියලු ආදාන ඉතා විස්තරාත්මකව සකසා ගැනීමට ඔබට ඉඩ දෙයි. යතුරුපුවරුවේ පුනරාවර්තනය අතිශය වේගවත් කළ හැකිය, නැතහොත් trackpad එකේ natural scrolling භාවිත කළ හැකිය. ඒ සියල්ල වෙනස් කරන්නේ `~/.config/hypr/input.lua` තුළින් වන අතර, Omarchy මෙනුවේ (`Super + Space`) _Setup > Input_ හරහාද එයට පිවිසිය හැකිය. එහි ඔබ සකසන ඕනෑම දෙයක් Omarchy හි පෙරනිමි අගයන් වෙනුවට යෙදේ.

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

ආදාන සඳහා වන [සියලු ආදාන විකල්ප](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprland wiki එකෙන් ඔබට දැක ගත හැකිය.

CapsLock සාමාන්‍ය Caps Lock එකක් ලෙස ක්‍රියා කරන අතර, `Shift + CapsLock` යනු [ඉක්මන් emojis](07-hotkeys.md#quick-emojis) සහ [වෙනත් සම්පූර්ණ කිරීම්](07-hotkeys.md#quick-completions) සඳහා වන compose යතුරයි. compose යතුර වෙනත් තැනකට දැමීමට ඔබ කැමති නම්, `kb_options` තුළ ඇති `omarchy:shift_caps_compose` වෙනුවට එය ආදේශ කරන්න. උදාහරණයක් ලෙස, මෙය compose යතුර Right Alt වෙත ගෙන යයි:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad අභිනය

workspaces වෙනස් කිරීමට ඇඟිලි තුනකින් swipe කිරීම වැනි [touchpad අභිනය](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) ද ඔබට සක්‍රිය කළ හැකිය:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

haptic touchpad එකක් ඇති Dell XPS ලැප්ටොප්වල, _Trigger > Hardware > Touchpad Haptics_ යටතේ click කිරීමේ ශක්තිය low, mid, හෝ high ලෙසද සැකසිය හැකිය.

### චීන, ජපන්, සහ වෙනත් භාෂාවලින් ටයිප් කිරීම

ස්ථාපකය ඔබේ යතුරුපුවරුව ගැන අසන විට Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), හෝ Hong Kong (Cangjie) තෝරන්න. අන්තර්ජාලයෙන් තොර පළමු ආරම්භක සැකසුම අතරතුරද ඇතුළුව, Omarchy යතුරුපුවරුව සහ ඊට ගැළපෙන ආදාන එන්ජිම ස්වයංක්‍රීයව සකසයි. Japanese සඳහා Mozcද, Korean සඳහා සම්මත two-set Hangulද, Simplified Chinese සඳහා Pinyinද, Taiwan සඳහා Chewing හි සම්මත Zhuyin සැකැස්මද, Hong Kong සඳහා Hong Kong අක්ෂර ආකෘති සහිත Cangjieද භාවිත වේ. Japanese (US keyboard) මඟින් US යතුරුපුවරු සැකැස්මක් සහිත Mozc ලබා දෙයි. ඔබ Dvorak, Colemak, හෝ AZERTY සමඟ Latin අක්ෂර ටයිප් කරන විට පවා Hangul, Zhuyin, සහ Cangjie යතුරු ඒවායේ සම්මත ස්ථානවලම පවතී. ඔබ මීට පෙර Hangul හෝ Chewing එකතු කර ඇත්නම්, එහි යතුරු එම ස්ථානවලට ගෙන යාමට _Setup > Typing > Input Methods_ යටතේ එය තේරීමෙන් ඉවත් කර නැවත තෝරන්න; ඔබ දැනටමත් ටයිප් කිරීමට භාවිත කරන එන්ජිමක් Omarchy එලෙසම තබයි.

ටයිප් කිරීම Latin ප්‍රකාරයෙන් ආරම්භ වේ. සකසා ඇති ආදාන ක්‍රම අතර චක්‍රීයව යාමට `Super + I` ඔබන්න, ආපස්සට චක්‍රීයව යාමට `Super + Shift + I` ඔබන්න. Pinyin වැනි ආදාන ක්‍රමයකින් Latin අක්ෂර වෙත පිටත් වීමට `Shift` තනිවම තට්ටු කරන්න, ආපසු යාමට එය නැවත තට්ටු කරන්න, Sogou, Microsoft Pinyin, සහ macOS ක්‍රියා කරන ආකාරයටම; `Shift` සහ අක්ෂරයක් එක්ව තවමත් ලොකු අකුරක් ටයිප් කරයි. Japanese යතුරුපුවරුවල, 全角/半角 මඟින් ආදානය සක්‍රිය/අක්‍රිය කරයි, 変換 මඟින් එය සක්‍රිය කරයි, 無変換 මඟින් එය අක්‍රිය කරයි. Korean සමඟ, 한/영 මඟින් Hangul මාරු කරන අතර 한자 මඟින් Hanja බවට පරිවර්තනය කරයි, ඔබේ යතුරුපුවරුවට ඒ සඳහාම වෙන් වූ යතුරු තිබුණත්, බොහෝ ලැප්ටොප් කරන ආකාරයට ඒ සඳහා Right Alt සහ Right Ctrl යවුවත්; එබැවින් එහි Right Alt සහ Right Ctrl සාමාන්‍ය modifiers නොවේ; dictation push-to-talk F9 මතම පවතී. `Ctrl + Space` Tmux සහ Herdr සඳහා ලබා ගත හැකිවම පවතී; `Shift + CapsLock` compose යතුර ලෙසම පවතී.

ඔබට යතුරුපුවරු සැකැස්ම් හෝ ආදාන ක්‍රම කිහිපයක් ඇති විට යතුරුපුවරු දර්ශකය තීරුවේ දකුණු පැත්තේ දිස් වේ. ආදාන භාෂා මාරු කිරීමට එය click කරන්න; Japanese මඟින් hiragana සඳහා あ පෙන්වයි. Japanese අක්ෂර තේරීම් සඳහා, Japanese වෙත මාරු වී, `nihongo` වැනි වචනයක් ටයිප් කර, ඉන්පසු Space දෙවරක් ඔබන්න. ඔබේ තේරීම පිළිගැනීමට Enter ඔබන්න. ඔබට යතුරුපුවරු සැකැස්ම් කිහිපයක්ද ඇත්නම්, ඒවා අතර චක්‍රීයව යාමට දර්ශකය right-click කරන්න.

ස්ථාපනය අතරතුර ඉදිරිපත් කරන ලද එම තේරීම්වලින්ම English සහ French වැනි සැකැස්ම් තේරීමට _Setup > Typing > Keyboard Layouts_ භාවිත කරන්න. කුමන composition එන්ජින් සක්‍රියද යන්න තේරීමට _Setup > Typing > Input Methods_ භාවිත කරන්න. තෝරනයන් දෙකම ඔබේ වත්මන් තේරීම් සලකුණු කරමින් Omarchy මෙනුව තුළම විවෘත වේ. තේරීමක් සක්‍රිය/අක්‍රිය කිරීමට click කරන්න හෝ Enter ඔබන්න; සෑම වෙනස්කමක්ම වහාම ක්‍රියාත්මක වේ. ආදාන ක්‍රමයක තේරීම ඉවත් කිරීමෙන් එය අස්ථාපනය නොකර චක්‍රයෙන් එය ඉවත් කරයි; යතුරුපුවරුව තවමත් ලබා ගත හැකිය.

එම තෝරනයන්ම විවෘත කිරීමට `omarchy setup keyboard` හෝ `omarchy setup input` ධාවනය කරන්න. විධාන පේළියෙන් එක් භාෂාවක් එකතු කිරීමට, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, හෝ `cangjie5` භාවිත කරන්න. Quick, Boshiamy, සහ Array, Cangjie සමඟම එකම package එකෙන් ලැබෙන අතර Input Methods තෝරනයේ දිස් වේ. ඔබේ අභිරුචි මාරු කිරීමේ යතුරු ආරක්ෂා වේ. විකල්ප එන්ජින් සැකැස්ම් හෝ යතුරු සඳහා, `omarchy pkg add fcitx5-configtool` සමඟ `fcitx5-configtool` ස්ථාපනය කර එය terminal එකකින් දියත් කරන්න. ආදාන භාෂාවක් තේරීමෙන් desktop භාෂාව වෙනස් නොවේ. ඔබට තවම එකක් නොමැති විට _Setup > Language_ යටතේ Japanese, Korean, හෝ Chinese තේරීමෙන් එහි ආදාන ක්‍රමය එකතු කරයි.

ආදාන ක්‍රම හෝ යතුරුපුවරු සැකැස්ම් අතර චක්‍රීයව යාමට `Super + I` භාවිත කරන්න, අනෙක් දිශාවට ආපසු යාමට `Super + Shift + I` භාවිත කරන්න, එබැවින් සකසා ඇති තුනක් සමඟ ඔබට අසල්වැසියන් දෙදෙනෙකු අතර ගමන් කළ හැකිය. ආදාන ක්‍රම හෝ සැකැස්ම් එකකට වඩා සකසා ඇති විට පමණක් ආදාන දර්ශකය තීරුවේ දකුණු පැත්තේ දිස් වේ. මෙම desktop බැඳීම ඔබේ පවතින Fcitx මාරු කිරීමේ යතුරුවලට අමතරව ක්‍රියා කරන අතර; ඔබට එය `~/.config/hypr/bindings.lua` තුළ අභිබවා යා හැකිය. ආදාන එන්ජින් සහ compose අනුපිළිවෙළ සෑම session එකකම දැනටමත් ක්‍රියාත්මක වන [Fcitx5](https://fcitx-im.org/) සේවාව භාවිත කරයි.

### ALT එක SUPER ලෙස භාවිත කිරීම

සමහර යතුරුපුවරුවල, ප්‍රාථමික meta යතුර (Windows/cmd යතුර) SUPER ලෙස භාවිත කිරීම පහසු නොවේ. මෙම වෙනස්කම භාවිතයෙන් ඔබට එය වෙනුවට ALT භාවිත කිරීමට මෙය වෙනස් කළ හැකිය:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
