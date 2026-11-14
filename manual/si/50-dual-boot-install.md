# Dual Boot ස්ථාපනය

ඔබට Windows හෝ වෙනත් ස්ථාපනයන් සමඟ තනි partition එකක Omarchy ස්ථාපනය කළ හැකිය.

මෙම ස්ථාපන ක්‍රමය තවමත් පෙරනිමියෙන් partition එක සඳහා LUKS encryption සමඟ එන බැවින් එය ප්‍රායෝගිකව සම්පූර්ණ drive එකක් භාවිතා කිරීමට වඩා වෙනස් නොවේ. අවශ්‍ය වන්නේ disk එකේ free space ප්‍රමාණයක් තිබීම පමණි.

## Windows හි ඉඩ සකස් කිරීම

Windows සමඟ ස්ථාපනය කිරීමට, start menu එකේ `disk management` ලෙස type කර **Create and format hard disk partitions** යන විකල්පය තෝරන්න.

 ![dual-boot-1](images/dual-boot-1.webp)

සුදුසු partition එක සොයා ගන්න, right click කරන්න, සහ **Shrink Volume** තෝරන්න.

![dual-boot-2](images/dual-boot-2.webp)

 ඔබට volume එක shrink කිරීමට අවශ්‍ය ප්‍රමාණය ඇතුළත් කරන්න. මෙය boot partition එක ඇතුළුව ඔබේ අනාගත Omarchy ස්ථාපනයේ ප්‍රමාණය වන බව සලකන්න.

 ![dual-boot-3](images/dual-boot-3.webp)

ඔබ අවසන් කළ පසු, මෙම උදාහරණයේ Omarchy ස්ථාපනය කරන 50GB කොටස පෙන්වන මෙවැනි දෙයක් ඔබට දැකිය යුතුය.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy ස්ථාපනය කිරීම

Omarchy සඳහා වන ස්ථාපන ක්‍රියාවලිය ප්‍රායෝගිකව සාමාන්‍ය ආකාරයටම සිදු වේ. ඔබ ඔබේ disk එක තෝරා ගත් පසු, ඔබට **Free space install** යන විකල්පය ලැබෙනු ඇත. සම්පූර්ණ disk එකම wipe වීම වැළැක්වීමට එම විකල්පය තෝරන්න.

 ![dual-boot-5](images/dual-boot-5.webp)

සියල්ල හොඳින් පෙනෙන බව තහවුරු කර, සාමාන්‍ය ආකාරයටම ස්ථාපනය අවසන් වන තෙක් රැඳී සිටින්න. සම්පූර්ණ-drive ස්ථාපනයකදී මෙන්ම, මෙහිදීද ඔබට unencrypted ලෙස ස්ථාපනය කිරීමට තෝරා ගත හැකිය (නිර්දේශ නොකෙරේ).
 ![dual-boot-6](images/dual-boot-6.webp)

## Bootloader එකට වෙනත් ස්ථාපනයන් එකතු කිරීම

ඔබ Omarchy ස්ථාපනය අවසන් කළ පසු, Limine bootloader එක දැන් පෙරනිමිය බව ඔබට පෙනෙනු ඇත. මෙය සමඟ, Windows වැනි ඔබේ වෙනත් ස්ථාපනයන් සඳහාද ඔබට Limine වෙත විකල්ප එකතු කළ හැකිය.

වෙනත් operating systems එකතු කිරීමට, `limine-scan` ධාවනය කර ඔබට අවශ්‍ය entries ඔබේ Limine config එකට එකතු කිරීමට prompts අනුගමනය කරන්න. Boot menu එක පෙරනිමියෙන් සැඟවී පවතින අතර තත්පරයකින් Omarchy ආරම්භ වේ. Windows හෝ වෙනත් entry එකක් තෝරා ගැනීමට, Limine ආරම්භ වූ වහාම ඕනෑම යතුරක් ඔබන්න; menu එක දිස් වූ විට, entry එකක් තේරීමට arrow keys භාවිතා කර Enter ඔබන්න. ඔබ යතුරක් ඔබන්නට පෙර Omarchy ආරම්භ වුවහොත්, restart කර නැවත උත්සාහ කරන්න. ඔබ _Setup > Direct Boot_ සක්‍රිය කළේ නම්, firmware එක Limine සම්පූර්ණයෙන්ම මඟ හරිනු ඇත, එබැවින් ඔබේ BIOS boot menu එකෙන් Limine තෝරන්න හෝ entry එක ඉවත් කිරීමට නැවත _Setup > Direct Boot_ ධාවනය කරන්න.

## Bitlocker

මෙම ස්ථාපන ක්‍රමය Bitlocker සමඟ අනුකූල නොවන බව සැලකීම වැදගත්ය, මන්ද එය partition එක පමණක් නොව සම්පූර්ණ drive එකම encrypt කරයි. Bitlocker සක්‍රිය කර ඇති බව සඳහන් දෝෂයක් ඔබට හමු වුවහොත්, Windows වෙත boot කර, **Settings -> Privacy & Security -> Device encryption** වෙත ගොස් Bitlocker අක්‍රිය කරන්න. Drive එක decrypt කිරීමට යම් කාලයක් ගත විය හැකිය.

 ![dual-boot-7](images/dual-boot-7.webp)
