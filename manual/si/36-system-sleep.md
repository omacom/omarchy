# පද්ධතියේ නින්ද

Omarchy පෙරනිමියෙන්ම suspend සක්‍රීය කරන අතර, එය සකසා ගත් පසු hibernation ද සක්‍රීය කරයි, නමුත් ඔබේ යන්ත්‍රයේ මේ දෙකෙන් ඕනෑම එකක් සමඟ ගැටලු ඇත්නම්, ඔබට ඒවා අක්‍රීය කළ හැකිය.

DGX Spark සහ ASUS Ascent GX10 වැනි NVIDIA GB10 යන්ත්‍රවල, NVIDIA හි DGX OS හි මෙන්ම, suspend සහ hibernation අක්‍රීය කර ඇත, මන්ද එම දෘඪාංගය මත sleep ක්‍රියා කරන බව තවමත් පෙන්වා දී නොමැති බැවිනි. Suspend toggle එක සහ hibernation සැකසුම එහි අදාළ නොවේ. Sleep නැවත සක්‍රීය කිරීමට, `sudo rm` සමඟ `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ඉවත් කරන්න; එවිට Suspend නැවත මෙනුවට එන අතර, අනෙකුත් යන්ත්‍රවල මෙන් hibernation සකසා ගත හැකිය. `sudo omarchy apply hardware --install-user "$USER"` ධාවනය කිරීමෙන් ගොනුව නැවත එහි තබයි.

### බල පැතිකඩ

ලැප්ටොප් එකක, Omarchy ඔබේ බල පැතිකඩ plugged in අවස්ථාවට සහ battery එකෙන් ක්‍රියාත්මක වන අවස්ථාවට වෙන් වෙන්ව මතක තබා ගන්නා අතර, ඔබ plug කරන විට සහ unplug කරන විට ඒ දෙක අතර මාරු වේ. පෙරනිමියෙන්ම එයින් අදහස් වන්නේ AC මත performance සහ battery එක මත balanced යන්නයි.

ඔබේ යන්ත්‍රය ලබා දෙන දේ `omarchy powerprofiles list` සමඟ බලා ගත හැකි අතර, ඔබ දැනට සිටින අවස්ථාව සඳහා අවශ්‍ය එක `omarchy powerprofiles set autodetect power-saver` සමඟ සැකසිය හැකිය. කිසිවක් unplug නොකර අනෙක් අවස්ථාව සැකසීමට, එය කෙලින්ම නම් කරන්න: `omarchy powerprofiles set battery power-saver`. ඔබ තෝරා ගන්නා ඕනෑම දෙයක්, ඊළඟ වතාවේ ඔබ එම අවස්ථාවේ සිටින විට ඔබට නැවත ලැබෙනු ඇත.

### Suspend toggle කිරීම

Terminal එකෙන් `omarchy toggle suspend` ධාවනය කිරීමෙන් ඔබ suspend toggle කරයි. එය _System_ (හෝ `Super + Esc`) යටතේ ඇති විකල්පය හුදෙක් පෙන්වයි/සඟවයි, එවිට එය ඔබේ පද්ධතිය මත අඛණ්ඩව ක්‍රියා කරනවාදැයි ඔබට බලා ගත හැකිය. එසේ නොවේ නම්, එම විධානයම භාවිතා කර ඔබට එය නැවත සැඟවිය හැකිය.

### Hibernation toggle කිරීම

Terminal එකෙන් `omarchy hibernation setup` ධාවනය කිරීමෙන් ඔබ hibernation සකසා ගනී (එය Apple Silicon Macs මත ලබා ගත නොහැකිය). Hibernation මඟින් ඔබේ භෞතික RAM වෙන් කිරීමේ ප්‍රමාණයට සමාන /swap උප-වොලියුමයක් ඔබේ boot drive එක මත නිර්මාණය කරන බැවින්, ඔබට ඉතිරි කිරීමට ඇති තරම් ඉඩ ඇති බව සහතික කර ගන්න. 32GB යන්ත්‍රයක, මෙම වොලියුමය සඳහා ඔබට සැමවිටම 32GB+ නිදහස් ඉඩ අවශ්‍ය වනු ඇත. Hibernation සඳහා පෙරනිමි Limine bootloader එක ද අවශ්‍ය වේ.

සකසා ගත් පසු, ඔබට _System_ (හෝ `Super + Esc`) යටතේ hibernate විකල්පය පෙනෙනු ඇති අතර, එවිට එය ඔබේ පද්ධතිය මත අඛණ්ඩව ක්‍රියා කරනවාදැයි ඔබට බලා ගත හැකිය. එසේ නොවේ නම්, `omarchy hibernation remove` ධාවනය කිරීමෙන් ඔබට එය නැවත ඉවත් කළ හැකිය.
