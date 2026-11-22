# Mac සහාය

## Apple Silicon සඳහා Omarchy

Apple Silicon සඳහා Omarchy යනු නිල Omacom විසඳුමක් වන අතර එය මුලින්ම නිකුත් කරන ලද්දේ Omarchy 4.5 සමඟයි. එය macOS අසලින්ම ස්ථාපනය වන අතර, ඔබේ Mac එක ආරම්භ වන විට ඔබ දෙකෙන් එකක් තෝරා ගනී.

Omarchy Mac පිළිබඳ දැනුම් දීමක් ලැබුණාද? [Omarchy Mac වෙතින් පැමිණීම](#coming-from-omarchy-mac) වෙත යන්න.

එය මෙම Mac මත ධාවනය වේ:

| Mac | චිප්ස් |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 සහ ඊට අලුත් Mac තවමත් සහාය දක්වන්නේ නැත. M4 සහාය edge channel එකේ පරීක්ෂා කරමින් පවතින අතර ඊළඟට පැමිණේ. ස්ථාපකය කිසිවක් වෙනස් කිරීමට පෙර ඔබේ Mac එක පරීක්ෂා කරයි.

M4 සහ ඊට අලුත් ඒවා ඇතුළුව ඕනෑම Apple Silicon Mac එකක, ඔබට [Try Omarchy](https://github.com/omacom/try-omarchy) සමඟ අතථ්‍ය යන්ත්‍රයක Omarchy ධාවනය කළ හැකිය.

### ඔබට අවශ්‍ය දේ

- macOS 15 Sequoia හෝ ඊට පසු, සහ පරිපාලක ගිණුමක්
- Omarchy සඳහා නිදහස් disk space එකක්. ස්ථාපකය ප්‍රමාණයක් යෝජනා කරන අතර එය වෙනස් කිරීමට ඔබට ඉඩ දෙයි.
- ඔබේ Mac එකේ උපස්ථයක්, බලය සහ අන්තර්ජාල සම්බන්ධතාවක්. ස්ථාපනය gigabyte කිහිපයක් බාගත කරයි.

### ස්ථාපනය කිරීම

ඔබ ස්ථාපනය කරන්නේ macOS වෙතින්මය. [Homebrew](https://brew.sh) සමඟ Omarchy Installer එක ස්ථාපනය කරන්න:

```sh
brew install omacom/mac/omarchy
```

නැතහොත් එහි [නිකුතු පිටුවෙන්](https://github.com/omacom/omarchy-mac-installer/releases) අලුත්ම Omarchy Installer එක බාගත කර එය විවෘත කරන්න.

ස්ථාපකය ඔබේ Mac එක පරීක්ෂා කරයි, සැලැස්ම ඔබට පෙන්වයි, සහ macOS කොටස හැකිලීමෙන් Omarchy සඳහා ඉඩ සාදයි. macOS disk එකේ පවතින අතර USB drive එකක් අවශ්‍ය නැත. පළමු අදියර අවසන් වූ විට, macOS Recovery තුළ සැකසීම අවසන් කරන ආකාරය එය ඔබට පියවරෙන් පියවර පෙන්වයි: shut down කරන්න, "Loading startup options" දිස්වන තුරු power button එක ඔබාගෙන සිටින්න, Omarchy තෝරන්න, සහ පියවර අනුගමනය කරන්න.

පළමු වරට ආරම්භ වන විට, Omarchy එහි disk එක සංකේතනය කරන password එකක් ඉල්ලා සිටියි. ප්‍රතිසාධන යතුරක් නැත: ඔබ password එක අමතක කළහොත්, ඔබේ Omarchy ගොනු නැවත ලබා ගත නොහැක.

පසුව Omarchy සහ macOS අතර මාරු වීමට, shut down කරන්න, ඉන්පසු ආරම්භ කිරීමේ විකල්ප දිස්වන තුරු power button එක ඔබාගෙන සිට එකක් තෝරන්න.

### Omarchy Mac වෙතින් පැමිණීම

Omarchy Mac දැන් Apple Silicon සඳහා Omarchy හි කොටසක් වන අතර, එය ධාවනය කළ සෑම Mac එකකටම සහාය දක්වයි. ඔබේ වත්මන් ස්ථාපනය දිගටම ධාවනය වන අතර, එහි පද්ධති පැකේජ තවමත් යාවත්කාලීන වේ, නමුත් එයට තවදුරටත් Omarchy යාවත්කාලීන කිරීම් නොලැබේ. කාලසීමාවක් නැත සහ තැනින් තැනම උත්ශ්‍රේණි කිරීමක් ද නොමැත: ඔබ උපස්ථ කරයි, පැරණි ස්ථාපනය ඉවත් කරයි, අලුතින් ස්ථාපනය කරයි, සහ ප්‍රතිසාධනය කරයි. 2 සිට 5 දක්වා පියවර සිදුවන්නේ macOS තුළ බැවින්, ඔබ නැවත ආරම්භ කිරීමට පෙර ඔබේ දුරකථනයෙන් මෙම පිටුව විවෘත කරන්න.

1. **Omarchy වෙතින්, Mac එකෙන් පිටතට උපස්ථ කරන්න.** පැරණි ස්ථාපනය ඉවත් කිරීම එය මකා දමන අතර, macOS හට Omarchy disk එක කියවිය නොහැක. SSH සහ GPG යතුරු, browser profile සහ push නොකළ වැඩ ඇතුළුව ඔබේ home folder එක බාහිර drive එකකට හෝ වෙනත් පරිගණකයකට පිටපත් කරන්න. `pacman -Qqe > ~/packages.txt` සමඟ ඔබේ පැකේජ ලැයිස්තුව සුරකින්න. ඉවත් කිරීම සහ ස්ථාපනය කිරීම යන දෙකම එහි disk එකේ ප්‍රමාණය වෙනස් කරන බැවින් macOS ද උපස්ථ කරන්න.
2. **ඔබේ Mac එක macOS වලින් ආරම්භ කරන්න.** Shut down කරන්න, ආරම්භ කිරීමේ විකල්ප දිස්වන තුරු power button එක ඔබාගෙන සිටින්න, සහ macOS තෝරන්න.
3. **[ස්ථාපනය කිරීම](#installing) තුළ පෙන්වා ඇති පරිදි Omarchy Installer එක ස්ථාපනය කරන්න.**
4. **පැරණි ස්ථාපනය ඉවත් කරන්න.** Omarchy Installer එක විවෘත කර Installation > Remove Omarchy තෝරන්න. එය මකා දමන දේ පෙන්වන අතර ඉඩ macOS වෙත ආපසු ලබා දෙයි. එය ඔබේ ස්ථාපනය හඳුනා නොගන්නේ නම්, එය disk එක වෙනස් නොකර නතර වේ. අතින් කොටස් මකා දැමීමෙන් macOS මැකී යා හැකි බැවින්, එසේ කරනවා වෙනුවට [Discord](https://discord.gg/tXFUdasqhY) තුළ උපකාර ඉල්ලන්න.
5. **ස්ථාපකය සමඟ Apple Silicon සඳහා Omarchy ස්ථාපනය කරන්න.**
6. **ඔබේ ගොනු ප්‍රතිසාධනය කරන්න.** පැරණි සැකසුම් අලුත් පෙරනිමි අභිබවා යා හැකි බැවින්, `~/.config` සියල්ලම අලුත් පෙරනිමි මතට පිටපත් කරනවා වෙනුවට ඔබේ සැකසුම් කෑල්ලෙන් කෑල්ල ආපසු ගෙනෙන්න.

### දැන ගැනීමට හොඳ දේ

- M1 සහ M2 MacBook වල, පියන විවෘත කිරීමෙන් හෝ power button එක එබීමෙන් sleep වලින් අවදි වන්න.
- ප්‍රශ්න හෝ ගැටලු: අපගේ [Discord](https://discord.gg/tXFUdasqhY) තුළ අසන්න.

[ස්ථාපකයේ README](https://github.com/omacom/omarchy-mac-installer#readme) එක නිකුතු නාලිකා, ස්ථාපකය යාවත්කාලීන කිරීම සහ Omarchy ඉවත් කිරීම ආවරණය කරයි.

## Intel Macs

සරල පරීක්ෂණයකදී, Omarchy ස්ථාපනය කිරීමෙන් පමණක් 2019 MacBook Pro එකක 36% ක කාර්ය සාධන වාසියක් ලබා ගැනීමට අපට හැකි විය.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac මත Omarchy ස්ථාපනය කිරීම

Omarchy දැනට සහාය දක්වන්නේ ස්ථාපනය කර ඇති **එකම** OS එක ලෙස සිටීමට පමණි. ස්ථාපනය අතරතුර, drive එක මකා දමනු ලබන අතර MacOS තවදුරටත් boot කළ නොහැකි වනු ඇත.

ඔබ කැමති නම් ඔබට පසුව Internet Recovery හරහා එය ප්‍රතිසාධනය කළ හැකිය.

මෙම කොටස සඳහා, ඔබ දැනටමත් [ආරම්භ කිරීම](02-getting-started.md) සමාලෝචනය කර ඇති අතර ඔබේ USB drive එක සූදානම් කර ඇති බව අපි උපකල්පනය කරමු. ඔබ එසේ කර නැතිනම් දැන්ම එය කරන්න.

#### Secure Boot අක්‍රිය කිරීම

Boot කළ හැකි USB එක මෙන්ම OS එක ද boot කිරීමට හැකි වීම සඳහා Apple හි Secure Boot අක්‍රිය කිරීම අවශ්‍ය වේ. එය අක්‍රිය කිරීමට, පහත දේ කරන්න:

1. ඔබේ Mac එක turn off කරන්න
2. එය turn on කර loading screen එක දිස්වන තුරු _වහාම_ Command-R ඔබාගෙන සිටින්න
3. ඔබේ user ව තෝරන්න සහ විමසූ විට ඔබේ password එක ඇතුළත් කරන්න
4. Recovery screen එක තුළ වූ පසු, menubar එකෙන් **Utilities > Startup Security Utility** තෝරන්න
5. අනන්‍යතාව තහවුරු කිරීමට විමසූ විට ඔබේ password එක ඇතුළත් කරන්න
6. Secure Boot විකල්ප වලින් "No Security" තෝරන්න
7. External Boot විකල්ප වලින් "Allow booting from external or removable media" තෝරන්න

#### ස්ථාපනය ආරම්භ කිරීම

1. USB drive එක ඇතුළත් කරන්න
2. ඔබේ Mac එක restart කර boot උපාංගවල screen එකක් දිස්වන තුරු _වහාම_ Option ඔබාගෙන සිටින්න
3. තැඹිලි EFI Boot උපාංගය තෝරන්න
4. [සාමාන්‍ය ආකාරයටම ස්ථාපනය කරගෙන යන්න](02-getting-started.md)

ස්ථාපකය Mac දෘඪාංග හඳුනාගෙන අවශ්‍ය නිවැරදි කිරීම් ස්වයංක්‍රීයව යොදයි: Broadcom Wi-Fi driver සහ firmware, ඒවා අවශ්‍ය MacBook මාදිලිවල SPI keyboard driver එක, සහ එම මාදිලි සඳහාම වන NVMe suspend නිවැරදි කිරීම.

### දන්නා සීමාවන්

ප්‍රජාවේ සාමාජිකයන් මෙම අභියෝග සඳහා විසඳුම් වෙනුවෙන් නිරන්තරයෙන් වැඩ කරමින් සිටින බැවින් මේවා ඔබට ගැටලුකාරී නම්, අපගේ [Discord](https://discord.gg/tXFUdasqhY) තුළ #omarchy-on-other හා සම්බන්ධ වී ඒවා විසඳීම සඳහා යාවත්කාලීන ක්‍රම තිබේදැයි බලන්න.

#### T1 Chip සහිත උපාංග

Apple T1 chip එක 2016 අගභාගයේදී හඳුන්වා දෙන ලද අතර එය භාවිතා කරන ලද්දේ Touch Bar සහිත පළමු පරම්පරාවේ MacBook Pro මාදිලිවල පමණි.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### දන්නා ගැටලු

- Touch Bar ක්‍රියා නොකරයි
- ශබ්දය ක්‍රියා නොකරයි

#### T2 Chip සහිත උපාංග

Apple T2 Security Chip එක 2017දී හඳුන්වා දෙන ලදී. 2020 සිට ආරම්භ වූ Apple silicon (M-series chips) වෙත සංක්‍රමණය වීමත් සමඟ T2 chip එක අත්හිටුවන ලදී.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

මෙම මාදිලිවල, ස්ථාපකය ස්වයංක්‍රීයව patch කරන ලද `linux-t2` kernel එක, T2 audio වින්‍යාසය, Apple හි Broadcom Wi-Fi/Bluetooth firmware, සහ `t2fanrd` හරහා fan පාලනය සකසයි. Touch Bar ධාවනය වන්නේ kernel එක තුළ ගොඩනගා ඇති Boot Camp විලාසිතාවේ සහාය මතයි.

#### iMac Retina 5K (2017)

2017 27-inch iMac එකේ T2 chip එකක් නැත, එබැවින් ස්ථාපකය එය අනෙකුත් Intel Mac මෙන් සකසයි.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### දන්නා ගැටලු

- Display එක එහි මව් 5120×2880 විභේදනයෙන් ධාවනය නොවේ: panel එක tile දෙකක් වන අතර, stock driver එක දැල්වෙන්නේ එකක් පමණි
- ශබ්දය ක්‍රියා නොකරයි
- දීප්තිය පාලනයට කිසිදු බලපෑමක් නැත
- Sleep යන්ත්‍රය හිර කරයි; power cycle එකකින් පමණක් එය ප්‍රතිසාධනය වේ

මෙම මාදිලිය සඳහා වූ ප්‍රජා patcher එකක් display එක, ශබ්දය සහ දීප්තිය නිවැරදි කරයි: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
