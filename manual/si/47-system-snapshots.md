# පද්ධති ස්නැප්ෂොට්

සෑම Omarchy යාවත්කාලීනයකදීම අපි ස්වයංක්‍රීයව ස්නැප්ෂොට් නිර්මාණය කරනවා, නමුත් ඔබටම එකක් නිර්මාණය කිරීමට අවශ්‍ය නම්, ඔබට `omarchy-snapshot create` භාවිත කළ හැක.

ඔබ ස්නැප්ෂොටයක් boot කර restore කරන ආකාරය රඳා පවතින්නේ ඔබේ යන්ත්‍රය ආරම්භ වන boot loader එක මතය. නව UEFI ස්ථාපන systemd-boot භාවිත කරන අතර, පැරණි ස්ථාපන සහ BIOS යන්ත්‍ර Limine භාවිත කරයි. ඔබ සතුව ඇත්තේ කුමක්දැයි `omarchy-boot-backend` ඔබට කියයි.

## systemd-boot සමඟ

Omarchy මෙනුවෙන් _System > Snapshots_ තෝරා, ඔබට boot වීමට අවශ්‍ය ස්නැප්ෂොටය තෝරන්න. යන්ත්‍රය එක් වරක් එයට restart වේ. නැතහොත් යන්ත්‍රය ආරම්භ වන විට Space ඔබාගෙන සිට boot මෙනුව බලන්න, එහි සෑම ස්නැප්ෂොටයක්ම එහි Omarchy අනුවාදය සහ දිනය සමඟ අලුත්ම එක පළමුව ලෙස ලැයිස්තුගත කර ඇත.

ස්නැප්ෂොටයක් උඩින් තාවකාලික ස්ථරයක් සමඟ boot වන නිසා, ඔබට එය සාමාන්‍ය පරිදි භාවිත කළ හැක, නමුත් ඔබ කරන ඕනෑම වෙනසක් ඊළඟ reboot එකේදී නැති වී යයි. එය තබා ගැනීමට, එය ඔබේ පද්ධතිය බවට පත් කරන්න: ඔබ log in වන විට දිස්වන දැනුම්දීම click කරන්න, _System > Snapshots > Restore This Snapshot_ තෝරන්න, නැතහොත් `omarchy-snapshot restore` run කරන්න. යන්ත්‍රය restart වන අතරතුර restore එක සිදු වේ. පෙර තිබූ ආකාරයේ පද්ධතිය _Before restore_ ලෙස boot මෙනුවේ පවතින අතර, `omarchy-snapshot restore backup` එය නැවත ලබා දෙයි.

Terminal එකෙන්:

- `omarchy-snapshot list` ඔබ boot කළ හැකි ස්නැප්ෂොට් ලැයිස්තුගත කරයි;
- `omarchy-snapshot boot 12` ස්නැප්ෂොට් 12 වෙත එක් වරක් restart කරයි;
- `omarchy-snapshot restore 12` ඊළඟ restart එකේදී ස්නැප්ෂොට් 12 පද්ධතිය බවට පත් කරයි, සහ `omarchy-snapshot restore --cancel` එම restart එකට පෙර ඔබේ තීරණය අවලංගු කරයි.

## Limine සමඟ

ස්නැප්ෂොටයක් boot කර restore කිරීමට, ඔබ එය Limine boot loader එකෙන් තෝරයි. Boot මෙනුව පෙරනිමියෙන් සැඟවී පවතින නිසා, එය පෙන්වීමට Limine ආරම්භ වූ වහාම ඕනෑම යතුරක් ඔබන්න.

එම තිරයෙන්, දිනය සහ අනුවාදය පදනම් කරගෙන ඔබට boot වීමට අවශ්‍ය ස්නැප්ෂොටය තෝරන්න. ස්නැප්ෂොටය ගත් අවස්ථාවේ Omarchy අනුවාදය පහළ වම් කෙළවරේ දැකිය හැක.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

ඔබ ඇතුළට පැමිණි විට, ඔබ boot කළ හැකි ස්නැප්ෂොටයක සිටින බව දැනුම් දෙන දැනුම්දීමක් උත්පතනය වන අතර, ඔබ එය click කළහොත්, restore කිරීමේ ක්‍රියාවලිය ආරම්භ වේ. විකල්පයක් ලෙස, ඔබට `omarchy-snapshot restore` භාවිත කළ හැක.

 ![snapshots-restore](images/snapshots-restore.webp)

## Restore එකක් ආවරණය කරන්නේ කුමක්ද

Restore එකක් ඔබේ root filesystem එක නැවත ලබා දෙන නමුත්, ඔබේ `/home` එක නොවේ. එබැවින් එය කැඩුණු පද්ධති යාවත්කාලීනයක් ආපසු හැරවීමට වැඩ කරන නමුත්, නැති වූ පුද්ගලික ගොනු නැවත ලබා ගැනීමට නොවේ.

මෙයින් අදහස් වන්නේ ඔබේ `~/.config` directory එක තිබූ ආකාරයටම පවතින බවයි. එබැවින් ඔබ නව format එකක configuration files ගබඩා කරන library එකක හෝ application එකක පැරණි අනුවාදයකට ආපසු යන්නේ නම්, ඔබට එය අතින්ම විසඳා ගැනීමට සිදු වේ.

එයම Omarchy හි දැනටමත් run වී ඇති migrations මොනවාද යන එහිම වාර්තාවටද අදාළ වේ: එය ඔබේ home directory එකේ පවතින නිසා, එය restore එකෙන් ඉතිරි වේ. ස්නැප්ෂොටය ගත් පසු run වූ migrations, root filesystem එකට ඔවුන් කළ වෙනස්කම් ආපසු හැරවූවද, done ලෙස සලකුණු වී පවතින අතර, ඊළඟ `omarchy update` එක ඒවා නැවත run නොකරයි. එබැවින් restore එකකින් පසු ඔබ නැවත update කර, කලින් update එකක් සකසා තිබූ දෙයක් තවමත් නැති වී ඇත්නම්, එයට හේතුව එය වීමට ඉඩ ඇත.
