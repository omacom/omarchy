# Mac বা Windows থেকে আসছেন

আপনি যদি macOS বা Windows-এ বছরের পর বছর কাটিয়ে থাকেন, আপনার আঙুল এমন শত শত জিনিস জানে যা আপনার মস্তিষ্ক কখনো শিখেছিল বলেই ভুলে গেছে। এই অধ্যায়টি হলো সেই অনুবাদের স্তর: Omarchy-তে সেই সহজাত অভ্যাসগুলো কোথায় গিয়ে মেলে। ফিচারগুলো নিজে অন্য জায়গায় গভীরভাবে আলোচনা করা হয়েছে — এটি শুধুই মানচিত্র।

### Super-ই সবকিছুর কেন্দ্র

Cmd বা Windows key ঘিরে গড়ে ওঠা আপনার সমস্ত পেশী-স্মৃতি একটিমাত্র key-তে চলে আসে: Super। PC keyboard-এ সেটাই Windows key, আর Omarchy-র প্রায় প্রতিটি hotkey-র নোঙর হলো এটি।

আপনার Spotlight বা Raycast বা Start-menu-র সহজাত প্রতিক্রিয়া হয়ে যাবে `Super + Space`। এটি Omarchy menu খোলে, যা app চালু করে, settings বদলায়, software install করে, screen capture করে — প্রায় সবকিছুই। filter করতে টাইপ করা শুরু করুন। `Super + Alt + Space` Launchpad-এর মতো করে একটিমাত্র grid-এ সব app দেখায়। দেখুন [নেভিগেশন](04-navigation.md)।

### desktop-এ কোনো icon নেই, আর dock আড়ালেই থাকে

desktop-এ সাজানোর মতো কোনো icon নেই, আর কোনো workspace-এ একটি window থাকলেই dock লুকিয়ে যায়, যতক্ষণ না আপনি pointer-টিকে screen-এর তার প্রান্তের দিকে ঠেলে দেন, আপনি সরিয়ে না দিলে সেটি হলো নিচের প্রান্ত (দেখুন [নেভিগেশন](04-navigation.md))। app শুরু হয় একটি hotkey থেকে (`Super + Return` terminal-এর জন্য, `Super + Shift + Return` browser-এর জন্য, আর `Super + K` ম্যাপ করা সবকিছুর তালিকার জন্য) অথবা menu থেকে। UI-এর একটিমাত্র স্থায়ী অংশ হলো [উপরের bar](05-the-top-bar.md), যা আগে menu bar, system tray, আর Notification Center আপনার জন্য যা করত, তার সবই সামলায় — আর এর উপর প্রায় প্রতিটি widget-ই left, right, আর middle click-এ কিছু না কিছু করে।

### Window নিজে নিজেই জায়গা করে নেয়

সবচেয়ে বড় মানসিক বদল: আপনি window টেনে এদিক-ওদিক নেন না বা screen-এর অর্ধেকে snap করেন না। একটি window খুলুন আর এটি পুরো screen নিয়ে নেবে। দ্বিতীয়টি খুলুন আর তারা screen ভাগ করে নেবে। আপনাকে কখনো আরেকটির নিচ থেকে একটি window খুঁজে বের করতে হয় না, কারণ window একে অপরের উপর চাপে না।

যখন সত্যিই আপনার একটি floating window দরকার হয়, `Super + T` সক্রিয়টিকে tiling থেকে বের করে আনে (আবার ফিরিয়েও নেয়)। কিন্তু আগে tiling-কে সত্যিকার সুযোগ দিন — এটাই পুরো জিনিসটির প্রাণ। [নেভিগেশন](04-navigation.md) আপনাকে এটির মধ্য দিয়ে হাঁটিয়ে নিয়ে যাবে।

Workspace পরিচিতই মনে হবে: এগুলো macOS Spaces বা Windows virtual desktop, শুধু আপনি এগুলো সত্যিই ব্যবহার করবেন, কারণ `Super + 1/2/3/4` সরাসরি একটিতে ঝাঁপ দেয় আর `Super + Shift + 1/2/3/4` সক্রিয় window-টিকে সেখানে পাঠিয়ে দেয়। কোনো animation-এর বিলম্ব নেই, শুধু তাৎক্ষণিক ঝাঁপ। এর মানে, আপনি আগে একাধিক monitor-এ অভ্যস্ত থাকলেও আপনার হয়তো সেগুলোর আর দরকারই হবে না।

### Copy আর paste শুধু কাজ করে

Mac-এ আপনার সব জায়গায় ছিল Cmd + C। Windows-এ আপনার সব জায়গায় ছিল Ctrl + C — terminal বাদে, যেখানে এটি আপনার program মেরে ফেলে। Omarchy আপনাকে দেয় `Super + C`, `Super + X`, আর `Super + V`, আর এগুলো সব জায়গায় কাজ করে, terminal-সহ। shell-এর জন্য আলাদা কোনো সহজাত প্রতিক্রিয়া শিখতে হবে না।

Windows-এর লোকেরা: আপনার Win + V clipboard history রয়েছে `Super + Ctrl + V`-তে, আর এটি text-এর পাশাপাশি ছবিও ধারণ করে। দেখুন [একীভূত clipboard ও history](08-unified-clipboard-history.md)।

### অনুবাদের টেবিল

| আপনি যা খোঁজেন | Omarchy-তে |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menu |
| AirDrop | LocalSend, `Super + Ctrl + S` দিয়ে — দেখুন [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` অথবা `Print Screen` — দেখুন [screenshot ও recording](12-screenshots-recording.md) |
| Notification Center | `Super + Shift + Alt + ,`-তে Notification history |
| Time Machine (system-এর জন্য) | প্রতিটি update-এ স্বয়ংক্রিয় [system snapshot](47-system-snapshots.md) |
| App Store / একটি installer download করা | menu-তে _Install_, অথবা `omarchy pkg add` — দেখুন [অন্যান্য package](29-other-packages.md) |
| System Settings / Control Panel | menu-তে _Setup_, যা plain config file সম্পাদনা করে — দেখুন [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, `Super + Shift + F`-তে — দেখুন [GUIs](22-guis.md) |
| Safari / Edge | `Super + Shift + Return`-তে Google Chrome; _Setup > Defaults > Browser_-এর অধীনে আরেকটি বেছে নিন — দেখুন [browser](23-browsers.md) |
| Preview / Photos | ছবি, video আর music-এর জন্য Omaview, PDF-এর জন্য Document Viewer — দেখুন [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, `Super + Shift + N`-তে; _Setup > Defaults > Editor_-এর অধীনে আরেকটি বেছে নিন |

### কিছু জিনিস সত্যিই আলাদা

অনেক settings থাকে text file-এ যা আপনি সম্পাদনা করেন, এমন panel-এ নয় যেখানে আপনি click করে করে এগোন। এটি আদিম শোনায় যতক্ষণ না আপনি বুঝতে পারেন এর মানে প্রতিটি tweak দেখা যায়, আপনার পরের machine-এ copy করা যায়, আর version control-এ রাখা যায়। _Setup_ menu আপনাকে সরাসরি সঠিক file-এ ফেলে দেয় আর আপনি শেষ করলে যার যা restart করা দরকার তা restart করে দেয়।

Update আসে একটিমাত্র command দিয়ে — _Update > Omarchy_ — যা Omarchy নিজেকে আর system-এর প্রতিটি package update করে, আগে একটি snapshot নিয়ে নেয়। যত্রতত্র যখন-তখন আপনাকে বিরক্ত করা per-app updater নেই। দেখুন [update](30-updates.md)।

Software আসে একটি package manager থেকে, download করা installer থেকে নয়।

আর আপনি যখন একটি window বন্ধ করেন, app সত্যিই quit করে। macOS-এর সেই ঝুলন্ত অবস্থা নেই যেখানে কোনো window ছাড়াই program চলতে থাকে। `Super + W` — অথবা `Super + Q`, যদি সেই আঙুলের স্মৃতি নিয়েই আপনি এসে থাকেন — মানে চলে গেছে।

### Mac hardware-এ

Omarchy Intel Mac-এ ভালো চলে, আর Omarchy for Apple Silicon দিয়ে M1, M2 আর M3 Mac-এও চলে। দেখুন [Mac support](44-mac-support.md)। আর keyboard আপনার প্রতি সদয়: Omarchy কিছুই remap করে না, আর Linux Command key-কে Super হিসেবে গণ্য করে, তাই Super ঠিক সেখানেই বসে যেখানে Cmd সবসময় ছিল। আপনার বুড়ো আঙুল এই বদল টেরই পাবে না।

### দুই সপ্তাহ সময় দিন

আপনার ধারণার চেয়ে দ্রুত সহজাত অভ্যাসগুলো বদলে যায়। [hotkeys](07-hotkeys.md) অধ্যায়টি একবার চোখ বুলিয়ে নিন, আর যখনই কোনো binding মনে পড়বে না, `Super + K` চাপুন — এটি আপনাকে সবগুলো দেখিয়ে দেবে। এটাই একমাত্র hotkey যা আপনাকে সত্যিই মুখস্থ করতে হবে।
