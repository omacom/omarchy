# පද්ධතියේ නින්ද

Omarchy පෙරනිමියෙන් suspend සහ hibernation සක්‍රිය කරයි, නමුත් ඔබේ යන්ත්‍රයේ ඒ දෙකෙන් එකක් සමඟ ගැටලු ඇති නම්, ඔබට ඒවා අක්‍රිය කළ හැකිය.

DGX Spark සහ ASUS Ascent GX10 වැනි NVIDIA GB10 යන්ත්‍රවල, NVIDIA හි DGX OS හි මෙන්ම suspend සහ hibernation අක්‍රිය කර ඇත, මන්ද එම දෘඪාංගය මත sleep තවම ක්‍රියා කරන බව පෙන්වීමට නොහැකි වී ඇති බැවිනි. ASUS Zenbook A16 (UX3607OA) සඳහා ද එය එසේමය, එහිදී suspend මගින් chip එක සම්පූර්ණයෙන්ම නින්දට නොදමන අතර රාත්‍රී පුරාම සිරවිය හැකිය. suspend toggle එක සහ hibernation සැකසීම එහි අදාළ නොවේ. sleep නැවත සක්‍රිය කිරීමට, `sudo rm` භාවිතයෙන් `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ඉවත් කරන්න; එවිට Suspend නැවත menu එකට එකතු වේ, තවද අනෙකුත් යන්ත්‍රවල මෙන් hibernation සැකසිය හැකිය. `sudo omarchy apply hardware --install-user "$USER"` ධාවනය කිරීමෙන් එම ගොනුව නැවත දමා ගත හැකිය.

### බල පැතිකඩ

Laptop එකක, Omarchy ඔබේ power profile එක plugged in අවස්ථාවට සහ battery එකෙන් ධාවනය වන අවස්ථාවට වෙන වෙනම මතක තබා ගනී, තවද ඔබ plug කරන සහ unplug කරන විට ඒ දෙක අතර මාරු වේ. මුලින්ම ලැබෙන පරිදි එයින් අදහස් වන්නේ AC මත performance සහ battery මත balanced යන්නයි.

`omarchy powerprofiles list` මගින් ඔබේ යන්ත්‍රය ලබා දෙන්නේ මොනවාදැයි ඔබට බැලිය හැකිය, තවද `omarchy powerprofiles set autodetect power-saver` මගින් ඔබ දැනට සිටින තත්ත්වය සඳහා ඔබට අවශ්‍ය එක සැකසිය හැකිය. කිසිවක් unplug නොකර අනෙක් තත්ත්වය සැකසීමට, එය කෙලින්ම නම් කරන්න: `omarchy powerprofiles set battery power-saver`. ඔබ තෝරන ඕනෑම එකක්, ඊළඟ වතාවේ ඔබ එම තත්ත්වයට පැමිණි විට ඔබට නැවත ලැබෙනු ඇත.

### suspend toggle කිරීම

terminal එකෙන් `omarchy toggle suspend` ධාවනය කිරීමෙන් ඔබ suspend toggle කරයි. එමගින් _System_ (හෝ `Super + Esc`) යටතේ ඇති විකල්පය හුදෙක් පෙන්වනු/සඟවනු ලැබේ, තවද ඔබේ පද්ධතියේ එය ස්ථාවරව ක්‍රියා කරයිදැයි ඔබට පරීක්ෂා කළ හැකිය. එසේ නොවේ නම්, එම විධානයම භාවිතයෙන් ඔබට එය නැවත සැඟවිය හැකිය.

### hibernation toggle කිරීම

terminal එකෙන් `omarchy hibernation setup` ධාවනය කිරීමෙන් ඔබ hibernation සකසයි. Hibernation මගින් ඔබේ physical RAM ධාරිතාවේ ප්‍රමාණයටම ඔබේ boot drive එකේ /swap subvolume එකක් නිර්මාණය කරයි, එබැවින් ඔබට ප්‍රමාණවත් ඉඩක් ඉතිරිව ඇති බවට වග බලා ගන්න. 32GB යන්ත්‍රයක, මෙම volume එක සඳහා ඔබට සැමවිටම 32GB+ නිදහස් ඉඩක් අවශ්‍ය වනු ඇත. Hibernation සඳහා default Limine bootloader එක ද අවශ්‍ය වේ.

සැකසූ පසු, ඔබට _System_ (හෝ `Super + Esc`) යටතේ hibernate විකල්පය පෙනෙනු ඇත, තවද ඔබේ පද්ධතියේ එය ස්ථාවරව ක්‍රියා කරයිදැයි ඔබට පරීක්ෂා කළ හැකිය. එසේ නොවේ නම්, `omarchy hibernation remove` ධාවනය කිරීමෙන් ඔබට එය නැවත ඉවත් කළ හැකිය.
