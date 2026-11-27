# Mac সহায়তা

## Apple Silicon-এর জন্য Omarchy

Apple Silicon-এর জন্য Omarchy একটি অফিসিয়াল Omacom সমাধান, যা প্রথম Omarchy 4.5-এর সঙ্গে প্রকাশিত হয়েছিল। এটি macOS-এর পাশাপাশি ইনস্টল হয়, এবং আপনার Mac চালু হওয়ার সময় আপনি দুটির মধ্যে একটি বেছে নেন।

Omarchy Mac সম্পর্কে কোনো নোটিশ পেয়েছেন? [Omarchy Mac থেকে আসছেন](#coming-from-omarchy-mac) অংশে যান।

এটি এই Mac-গুলোতে চলে:

| Mac | চিপ |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 এবং তার চেয়ে নতুন Mac এখনও সমর্থিত নয়। M4 সমর্থন edge channel-এ পরীক্ষাধীন আছে এবং এর পরেই আসছে। ইনস্টলার কিছু পরিবর্তন করার আগে আপনার Mac যাচাই করে।

M4 এবং তার চেয়ে নতুনসহ যেকোনো Apple Silicon Mac-এ, আপনি [Try Omarchy](https://github.com/omacom/try-omarchy) দিয়ে একটি ভার্চুয়াল মেশিনে Omarchy চালাতে পারবেন।

### আপনার যা যা লাগবে

- macOS 15 Sequoia বা তার পরের সংস্করণ, এবং একটি administrator account
- Omarchy-র জন্য ফাঁকা disk জায়গা। ইনস্টলার একটি আকারের পরামর্শ দেয় এবং আপনাকে তা পরিবর্তন করতে দেয়।
- আপনার Mac-এর একটি backup, power, এবং একটি internet সংযোগ। ইনস্টলটিতে কয়েক gigabytes ডাউনলোড হয়।

### ইনস্টল করা

আপনি macOS থেকে ইনস্টল করেন। [Homebrew](https://brew.sh) দিয়ে Omarchy Installer ইনস্টল করুন:

```sh
brew install omacom/mac/omarchy
```

অথবা এর [releases page](https://github.com/omacom/omarchy-mac-installer/releases) থেকে সবচেয়ে নতুন Omarchy Installer ডাউনলোড করে খুলুন।

ইনস্টলার আপনার Mac যাচাই করে, আপনাকে পরিকল্পনাটি দেখায়, এবং macOS partition ছোট করে Omarchy-র জন্য জায়গা তৈরি করে। macOS disk-এই থেকে যায় এবং কোনো USB drive লাগে না। প্রথম ধাপ শেষ হলে, এটি আপনাকে macOS Recovery-তে সেটআপ শেষ করার প্রক্রিয়াটি ধাপে ধাপে বুঝিয়ে দেয়: শাট ডাউন করুন, "Loading startup options" না আসা পর্যন্ত power button চেপে ধরে রাখুন, Omarchy বেছে নিন, এবং ধাপগুলো অনুসরণ করুন।

প্রথম boot-এ, Omarchy একটি password চায় যা এর disk encrypt করে। কোনো recovery key নেই: password ভুলে গেলে আপনার Omarchy ফাইলগুলো আর পুনরুদ্ধার করা যাবে না।

পরে Omarchy এবং macOS-এর মধ্যে বদলাতে হলে, শাট ডাউন করুন, তারপর startup options না আসা পর্যন্ত power button চেপে ধরে রাখুন এবং একটি বেছে নিন।

### Omarchy Mac থেকে আসছেন

Omarchy Mac এখন Apple Silicon-এর জন্য Omarchy-র অংশ, এবং যেসব Mac-এ এটি চলত তার সবগুলোই সমর্থিত। আপনার বর্তমান ইনস্টল চলতেই থাকবে, এবং এর system packages এখনও update হবে, কিন্তু এটি আর কোনো Omarchy updates পাবে না। কোনো deadline নেই এবং কোনো in-place upgrade নেই: আপনি backup নেন, পুরোনো ইনস্টল সরিয়ে ফেলেন, নতুন করে ইনস্টল করেন, এবং restore করেন। 2 থেকে 5 নম্বর ধাপগুলো macOS-এ করতে হয়, তাই restart করার আগে এই page-টি আপনার ফোনে খুলে রাখুন।

1. **Omarchy থেকে backup নিন, Mac-এর বাইরে।** পুরোনো ইনস্টল সরিয়ে ফেললে তা মুছে যাবে, এবং macOS Omarchy disk পড়তে পারে না। SSH এবং GPG keys, browser profiles এবং push না করা কাজসহ আপনার home folder একটি external drive বা অন্য কোনো computer-এ copy করুন। `pacman -Qqe > ~/packages.txt` দিয়ে আপনার package list সংরক্ষণ করুন। macOS-এরও backup নিন, কারণ সরানো এবং ইনস্টল করা—দুটোই এর disk-এর আকার বদলায়।
2. **আপনার Mac macOS-এ চালু করুন।** শাট ডাউন করুন, startup options না আসা পর্যন্ত power button চেপে ধরে রাখুন, এবং macOS বেছে নিন।
3. **[ইনস্টল করা](#installing) অংশে যেভাবে দেখানো হয়েছে সেভাবে Omarchy Installer ইনস্টল করুন।**
4. **পুরোনো ইনস্টলটি সরিয়ে ফেলুন।** Omarchy Installer খুলুন এবং Installation > Remove Omarchy বেছে নিন। এটি কী কী মুছবে তা দেখায় এবং জায়গাটি macOS-কে ফিরিয়ে দেয়। এটি যদি আপনার ইনস্টলটি চিনতে না পারে, তাহলে disk-এ কোনো পরিবর্তন না করেই এটি থেমে যায়। নিজে হাতে partitions মুছে ফেলার বদলে [Discord](https://discord.gg/tXFUdasqhY)-এ সাহায্য চান, কারণ তাতে macOS মুছে যেতে পারে।
5. **ইনস্টলার দিয়ে Apple Silicon-এর জন্য Omarchy ইনস্টল করুন।**
6. **আপনার ফাইলগুলো restore করুন।** নতুন defaults-এর ওপর `~/.config`-এর সবকিছু copy করে দেওয়ার বদলে আপনার settings একটু একটু করে ফিরিয়ে আনুন, কারণ পুরোনো settings সেগুলোকে override করে দিতে পারে।

### জেনে রাখা ভালো

- M1 এবং M2 MacBook-গুলোতে, ঢাকনা খুলে বা power button চেপে sleep থেকে জাগান।
- প্রশ্ন বা সমস্যা থাকলে: আমাদের [Discord](https://discord.gg/tXFUdasqhY)-এ জিজ্ঞাসা করুন।

[ইনস্টলারের README](https://github.com/omacom/omarchy-mac-installer#readme)-তে release channels, ইনস্টলার update করা এবং Omarchy সরিয়ে ফেলা নিয়ে আলোচনা করা হয়েছে।

## Intel Macs

একটি সাধারণ পরীক্ষায়, শুধু Omarchy ইনস্টল করেই আমরা একটি 2019 MacBook Pro-তে 36% performance বৃদ্ধি পেতে সক্ষম হয়েছিলাম।

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac-এ Omarchy ইনস্টল করা

Omarchy এই মুহূর্তে ইনস্টল করা **একমাত্র** OS হিসেবে থাকাকেই সমর্থন করে। ইনস্টলেশনের সময় drive-টি সম্পূর্ণ মুছে ফেলা হবে এবং MacOS আর boot করা যাবে না।

আপনি চাইলে পরে Internet Recovery দিয়ে এটি এখনও restore করতে পারবেন।

এই অংশের জন্য আমরা ধরে নিচ্ছি আপনি ইতিমধ্যেই [Getting Started](02-getting-started.md) দেখে নিয়েছেন এবং আপনার USB drive প্রস্তুত আছে। যদি না করে থাকেন, তাহলে এখনই করে নিন।

#### Secure Boot নিষ্ক্রিয় করুন

bootable USB, সেইসঙ্গে OS boot করার জন্য Apple-এর Secure Boot নিষ্ক্রিয় করা প্রয়োজন। এটি নিষ্ক্রিয় করতে নিচের ধাপগুলো অনুসরণ করুন:

1. আপনার Mac বন্ধ করুন
2. এটি চালু করুন এবং loading screen না আসা পর্যন্ত _সঙ্গে সঙ্গে_ Command-R চেপে ধরে রাখুন
3. আপনার user বেছে নিন এবং জিজ্ঞাসা করা হলে আপনার password লিখুন
4. recovery screen-এ পৌঁছে গেলে, menubar থেকে **Utilities > Startup Security Utility** বেছে নিন
5. authenticate করতে বলা হলে আপনার password লিখুন
6. Secure Boot options থেকে "No Security" বেছে নিন
7. External Boot options থেকে "Allow booting from external or removable media" বেছে নিন

#### ইনস্টলেশন শুরু করুন

1. USB drive-টি ঢোকান
2. আপনার Mac restart করুন এবং boot devices-এর একটি screen না আসা পর্যন্ত _সঙ্গে সঙ্গে_ Option চেপে ধরে রাখুন
3. কমলা রঙের EFI Boot device-টি বেছে নিন
4. [স্বাভাবিক নিয়মে ইনস্টল](02-getting-started.md) চালিয়ে যান

ইনস্টলার Mac hardware শনাক্ত করে এবং প্রয়োজনীয় fixগুলো স্বয়ংক্রিয়ভাবে প্রয়োগ করে: Broadcom Wi-Fi drivers এবং firmware, Broadcom 1570 আছে এমন মেশিনগুলোতে FaceTime HD camera driver (Mac online হলেই এর firmware Apple থেকে ডাউনলোড করা হয়, কারণ ইনস্টলার offline কাজ করে), যেসব MacBook model-এ লাগে সেগুলোতে SPI keyboard driver, এবং ওই একই model-গুলোর জন্য একটি NVMe suspend fix।

### পরিচিত সীমাবদ্ধতা

community-র সদস্যরা এই চ্যালেঞ্জগুলোর সমাধান নিয়ে নিয়মিত কাজ করে যাচ্ছেন, তাই এগুলো আপনার জন্য সমস্যা হলে আমাদের [Discord](https://discord.gg/tXFUdasqhY)-এ #omarchy-on-other-এ যোগ দিন এবং দেখুন এগুলো সমাধানের কোনো হালনাগাদ পদ্ধতি আছে কিনা।

#### FaceTime HD Camera

camera driver লোড করা থাকা অবস্থায় Mac hibernate করলে সেটি মেশিনটিকে hang করে দেয়, তাই এটিকে আগে থেকেই unload করা হয়। কোনো app camera খুলে রেখেছে এমন অবস্থায় এটিকে unload করা যায় না, তাই app-টির নাম উল্লেখ করে একটি notification দিয়ে hibernation বাতিল করা হয়: app-টি বন্ধ করুন এবং আবার hibernate করুন। এর মধ্যে রয়েছে critical battery-তে স্বয়ংক্রিয়ভাবে hibernate করা, এবং suspend-then-hibernate, যা suspend হওয়ার আগেই প্রত্যাখ্যান করা হয়। সাধারণ suspend, camera খোলা থাকলে driver নিজেই প্রত্যাখ্যান করে, কোনো notification ছাড়াই।

camera-র firmware Apple থেকে ডাউনলোড করা হয়, তাই Mac একবার online হওয়ার পরই কেবল camera কাজ করে। download-টি boot-এর সময় শুরু হয় এবং network সমস্যা থাকা অবস্থায় প্রতি 15 মিনিটে আবার চেষ্টা করা হয়; Apple-এর ফাইলটি বদলে গিয়ে থাকলে এটি থেমে যায় এবং একটি Omarchy update-এর জন্য অপেক্ষা করে। camera দেখা না গেলে `journalctl -u facetimehd-firmware-fetcher` জানিয়ে দেয় কেন, `sudo systemctl restart facetimehd-firmware-fetcher` আবার চেষ্টা করে, এবং download শেষ হয়ে গেলেও camera এখনও না থাকলে একটি reboot driver-টি লোড করে।

#### T1 Chip-ওয়ালা ডিভাইস

Apple T1 chip 2016 সালের শেষে আনা হয়েছিল এবং এটি শুধু Touch Bar-ওয়ালা প্রথম প্রজন্মের MacBook Pro model-গুলোতেই ব্যবহৃত হয়েছিল।
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### পরিচিত সমস্যা

- Touch Bar কাজ করে না
- Sound কাজ করে না

#### T2 Chip-ওয়ালা ডিভাইস

Apple T2 Security Chip 2017 সালে আনা হয়েছিল। 2020 সাল থেকে শুরু করে Apple silicon (M-series chips)-এ রূপান্তরের সঙ্গে সঙ্গে T2 chip বন্ধ করে দেওয়া হয়।

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

এই model-গুলোতে ইনস্টলার স্বয়ংক্রিয়ভাবে patched `linux-t2` kernel, T2 audio configuration, Apple-এর Broadcom Wi-Fi/Bluetooth firmware, এবং `t2fanrd` দিয়ে fan control সেটআপ করে। Touch Bar kernel-এর বিল্ট-ইন Boot Camp-ধাঁচের সমর্থনে চলে।

#### iMac Retina 5K (2017)

2017 সালের 27-inch iMac-এ কোনো T2 chip নেই, তাই ইনস্টলার এটিকে বাকি Intel Mac-গুলোর মতোই সেটআপ করে।

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### পরিচিত সমস্যা

- display এর নিজস্ব 5120×2880 রেজোলিউশনে চলে না: panel-টি দুটি tile দিয়ে তৈরি, এবং stock driver শুধু একটিকেই আলোকিত করে
- Sound কাজ করে না
- brightness control-এর কোনো প্রভাব নেই
- Sleep মেশিনটিকে hang করে দেয়; শুধু একটি power cycle দিয়েই এটি ফিরিয়ে আনা যায়

এই model-টির জন্য একটি community patcher display, sound এবং brightness ঠিক করে দেয়: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)।
