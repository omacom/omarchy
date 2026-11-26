# පොදු සකස්කිරීම්

මෙය Omarchy සැකසුම සඳහා පොදු අභිරුචිකරණයන්ගේ එකතුවකි. පද්ධති යාවත්කාලීන කිරීම් සඳහා ඇතැම් වින්‍යාසයන් ඒවායේ මුල් තත්ත්වයට ප්‍රතිස්ථාපනය කිරීමට විටින් විට අවශ්‍ය විය හැකි බව දැනගන්න. මෙය සිදුවුවහොත්, ඔබේ වෙනස්කම් නැති නොවනු ඇත, නමුත් මුල් ගොනුව අසල `.bak.<timestamp>` ගොනුවක් තුළ තබනු ලැබේ.

ඔබ යමක් අවුල් කළහොත්, Omarchy මෙනුවේ _Update > Config_ හරහා තනි තනි වින්‍යාසයන් ඒවායේ මුල් සැකසුමට ප්‍රතිස්ථාපනය කළ හැකිය. ඔබ _ඇත්තටම_ සියල්ල අවුල් කළහොත්, `omarchy reinstall configs` හරහා සියලු වින්‍යාසයන් යළි සකසන්න, නැතහොත් `omarchy reinstall` භාවිතයෙන් සෑම පෙරනිමි පැකේජයක්ම සහ වින්‍යාසයක්ම නැවත ස්ථාපනය කරන්න.

### සියලු tray අයිකන හැමවිටම හෙළි කරන්න

පෙරනිමියෙන්, Dropbox, 1password, හෝ Steam වැනි tray අයිකන, tray expander ඊතලය පිටුපස සැඟවී ඇති අතර, ඔබ එය මත hover කළ විට ඒවා හෙළි වේ. ඔබට ඒවා හැමවිටම නිරාවරණය කර තබා ගැනීමට අවශ්‍ය නම්, tray අයිකන කළමනාකරු විවෘත කිරීමට expander ඊතලය right-click කරන්න, පසුව ඔබට දෘශ්‍යමානව තබා ගැනීමට අවශ්‍ය අයිකන pin කරන්න (ඔබට කිසිවිට දැකීමට අවශ්‍ය නැති ඒවා සැඟවියද හැකිය).

### වටකුරු කවුළු කොන්

Omarchy හි පෙරනිමි සැලසුම හතරැස් කොන් සහිත එකකි, නමුත් ඔබට එය ටිකක් මෘදු කිරීමට කැමති නම්, Omarchy මෙනුවේ _Appearance > Windows > Window Corners > Rounded Corners_ තෝරන්න, නැතහොත් `omarchy hyprland corners rounded` ධාවනය කරන්න. _Theme Corners_ මඟින් තේමාව භාවිත කරන ඕනෑම දෙයකට ආපසු යයි. ඔබේම අරය තෝරා ගැනීමට, _Theme Corners_ (`omarchy hyprland corners theme`) මතම රැඳී සිටින්න, මන්ද Rounded සහ Sharp ඔබේ වින්‍යාසයෙන් පසුව load වී එය override කරන බැවිනි, සහ `~/.config/hypr/looknfeel.lua` හි rounding හි අදහස් දැක්වීම ඉවත් කරන්න:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### කවුළු හිඩැස් ඉවත් කරන්න

ලැප්ටොප් තිරවල, සමහර අය කවුළු හිඩැස් සඳහා කිසිදු pixel එකක් නාස්ති කිරීමට කැමති නැත (හෝ `Super + Shift + Space` භාවිතයෙන් toggle off කළ හැකි top bar එකක් සඳහා පවා). ඔබට `Super + Shift + Backspace` භාවිතයෙන් සියලු හිඩැස් සහ borders toggle off කළ හැකිය, නැතහොත් `~/.config/hypr/looknfeel.lua` හි මෙම කොටසේ අදහස් ඉවත් කිරීමෙන් ඒවා ස්ථිරවම ඉවත් කළ හැකිය:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
