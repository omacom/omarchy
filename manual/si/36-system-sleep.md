# පද්ධති නිද්‍රාව

Omarchy පෙරනිමියෙන් suspend සහ hibernation සක්‍රිය කරයි, නමුත් ඔබේ යන්ත්‍රයේ ඒ දෙකෙන් ඕනෑම එකක් සමඟ ඔබට ගැටලු ඇත්නම්, ඔබට ඒවා අක්‍රිය කළ හැකිය.

DGX Spark සහ ASUS Ascent GX10 වැනි NVIDIA GB10 යන්ත්‍රවල, NVIDIA හි DGX OS එකේ මෙන්ම suspend සහ hibernation අක්‍රිය කර ඇත, මන්ද එම hardware එක මත sleep ක්‍රියා කරන බව තවමත් පෙන්වා දී නැති බැවිනි. Suspend ටොගලය සහ hibernation සැකසීම එහි අදාළ නොවේ. Sleep නැවත සක්‍රිය කිරීමට, `sudo rm` සමඟ `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ඉවත් කරන්න; එවිට Suspend මෙනුවට නැවත පැමිණෙන අතර, hibernation වෙනත් යන්ත්‍රවල මෙන්ම සකසා ගත හැකිය. `sudo omarchy apply hardware --install-user "$USER"` ධාවනය කිරීමෙන් ගොනුව නැවත තබනු ලැබේ.

### බල පැතිකඩවල්

Laptop එකක, Omarchy ඔබේ බල පැතිකඩය සම්බන්ධ කර ඇති අවස්ථාවට සහ battery එකෙන් ක්‍රියාත්මක වන අවස්ථාවට වෙන වෙනම මතක තබා ගන්නා අතර, ඔබ සම්බන්ධ කරන සහ විසන්ධි කරන විට ඒ දෙක අතර මාරු වේ. මුල සිටම එයින් අදහස් වන්නේ AC මත performance සහ battery එක මත balanced යන්නයි.

`omarchy powerprofiles list` සමඟ ඔබේ යන්ත්‍රය ලබා දෙන දේ ඔබට දැක ගත හැකි අතර, `omarchy powerprofiles set autodetect power-saver` සමඟ ඔබ දැනට සිටින තත්ත්වය සඳහා ඔබට අවශ්‍ය එක සැකසිය හැකිය. කිසිවක් විසන්ධි නොකර අනෙක් තත්ත්වය සැකසීමට, එය සෘජුවම නම් කරන්න: `omarchy powerprofiles set battery power-saver`. ඔබ තෝරන ඕනෑම දෙයක්, ඊළඟ වතාවේ ඔබ එම තත්ත්වයේ සිටින විට ඔබට නැවත ලැබෙනු ඇත.

### Suspend ටොගල් කිරීම

Terminal එකෙන් `omarchy toggle suspend` ධාවනය කිරීමෙන් ඔබ suspend ටොගල් කරයි. එය _System_ යටතේ ඇති (හෝ `Super + Esc`) විකල්පය හුදෙක් පෙන්වයි/සඟවයි, එවිට එය ඔබේ පද්ධතියේ අනුකූලව ක්‍රියා කරන්නේ දැයි ඔබට දැක ගත හැකිය. එසේ නොවේ නම්, එම විධානයම සමඟ ඔබට එය නැවත සැඟවිය හැකිය.

### Hibernation ටොගල් කිරීම

Terminal එකෙන් `omarchy hibernation setup` ධාවනය කිරීමෙන් ඔබ hibernation සකසයි. Hibernation ඔබේ භෞතික RAM වෙන් කිරීමේ ප්‍රමාණයට ඔබේ boot drive එක මත /swap උපවොලියුමයක් සාදන බැවින්, ඔබට ඉතිරි කර ගැනීමට ඕනෑ තරම් ඉඩ ඇති බවට වග බලා ගන්න. 32GB යන්ත්‍රයක, මෙම වොලියුමය සඳහා ඔබට සැමවිටම 32GB+ නිදහස් ඉඩක් අවශ්‍ය වේ. Hibernation සඳහා පෙරනිමි Limine bootloader එකද අවශ්‍ය වේ.

සැකසූ විට, ඔබ _System_ යටතේ (හෝ `Super + Esc`) hibernate විකල්පය දකිනු ඇති අතර, එවිට එය ඔබේ පද්ධතියේ අනුකූලව ක්‍රියා කරන්නේ දැයි ඔබට දැක ගත හැකිය. එසේ නොවේ නම්, `omarchy hibernation remove` ධාවනය කිරීමෙන් ඔබට එය නැවත ඉවත් කළ හැකිය.
