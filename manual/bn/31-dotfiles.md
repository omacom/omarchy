# ডটফাইলস

Omarchy মূলত তথাকথিত ডটফাইলগুলোর মাধ্যমে কনফিগার করা হয়, যেগুলো `~/.config`-এ থাকে। সেগুলোকে আপনার পরিবর্তনের জন্য আপনার নিজের ফাইল হিসেবে ধরা হয়। `/usr/share/omarchy`-তে থাকা ফাইলগুলো Omarchy-এর নিজের, আর সেগুলো নিয়ে আপনার ঘাঁটাঘাঁটি করা উচিত নয়। `/usr/share/omarchy`-তে কিছু বদলানোর দরকার হলে, তার বদলে `~/.config`-এ সেই মানটি ওভাররাইট করা উচিত।

মূল কনফিগগুলো সরাসরি Omarchy মেনু (`Super + Space`) থেকে সম্পাদনা করা যায়, যেমন _Setup > Keybindings_, _Setup > Input_, এবং _Setup > Config > [file]_। এভাবে করলে, কনফিগ সম্পাদনার পর যেসব প্রসেস পুনরায় চালু করা দরকার, সেগুলো সম্পাদক (ডিফল্ট হিসেবে Neovim — `:wq`, মনে আছে তো! — তবে _Setup > Defaults > Editor_ দিয়ে তা বদলাতে পারেন) থেকে বেরিয়ে এলেই স্বয়ংক্রিয়ভাবে পুনরায় চালু হয়ে যাবে।

এখানে `~/.config`-এর মূল ফাইলগুলোর একটি তালিকা দেওয়া হলো এবং সেগুলো কী নিয়ন্ত্রণ করে:

| ফাইল                  | উদ্দেশ্য              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | প্রধান Hyprland কনফিগ। Omarchy-এর ডিফল্টগুলোর পাশাপাশি নিচে দেওয়া আপনার ওভাররাইড ফাইলগুলো লোড করে। [Hyprland কনফিগ সম্পর্কে আরও জানুন](https://wiki.hypr.land/Configuring/)।  |
| `~/.config/hypr/bindings.lua` | আপনার নিজের keybinding এবং ডিফল্টগুলোর ওভাররাইড। |
| `~/.config/hypr/monitors.lua` | মনিটর প্যানেলে যেসব সেটিং নেই, সেগুলোর জন্য মনিটর সেটিং, যেমন rotation, অতিরিক্ত mode, বা কোনো মনিটর বন্ধ রাখা। |
| `~/.config/hypr/input.lua` | আপনার keyboard layout, mouse এবং trackpad সেটিং নিয়ন্ত্রণ করে। |
| `~/.config/hypr/looknfeel.lua` | gap, border, animation এবং বাকি চেহারার সবকিছু নিয়ন্ত্রণ করে। |
| `~/.config/hypr/autostart.lua` | সেশনের সঙ্গে শুরু হওয়া অতিরিক্ত প্রসেস নিয়ন্ত্রণ করে। |
| `~/.config/omarchy/shell.json` | Omarchy shell নিয়ন্ত্রণ করে: bar-এর অবস্থান, layout এবং widget, পাশাপাশি screensaver, lock এবং idle-এর সময়। |
| `~/.config/foot/foot.ini` | আপনার terminal নিয়ন্ত্রণ করে (foot হলো ডিফল্ট)। |
| `~/.XCompose` | আপনার দ্রুত-অ্যাক্সেস emoji এবং নাম/email autocomplete নির্ধারণ করে। পরিবর্তন করার পর `omarchy-restart-xcompose` চালাতে ভুলবেন না। |

আপনি যদি নিজের সেটআপ টুইক করতে গিয়ে অনেক পরিবর্তন করে ফেলেন, তাহলে এই সব ডটফাইলের ব্যাকআপ রাখা ভালো বুদ্ধি। [Stow তা করার দারুণ একটি উপায়](https://www.youtube.com/watch?v=NoFiYOqnC4o)।

### সেশনের সঙ্গে আপনার নিজের অ্যাপ চালু করা

প্রতিবার লগ ইন করার সময় যদি কিছু চালাতে চান — একটি sync daemon, একটি chat অ্যাপ, আপনার নিজের script — তাহলে তা `~/.config/hypr/autostart.lua`-তে রাখুন:

```lua
o.launch_on_start("my-service")
```

এটি কমান্ডটিকে সেশনের অংশ হিসেবে চালু করে, তাই আবার লগ আউট করলে এটি ঠিকমতো পরিষ্কার হয়ে যায়।

### সিস্টেম ইভেন্টে script চালানো

Omarchy কয়েকটি নির্দিষ্ট মুহূর্তে hook চালু করে, আর আপনি সেগুলোর সঙ্গে আপনার নিজের script ঝুলিয়ে দিতে পারেন। এগুলো থাকে `~/.config/omarchy/hooks/<event>.d/`-তে, প্রতি ইভেন্টের জন্য একটি করে directory, আর ইভেন্ট ঘটলে সেখানে থাকা প্রতিটি executable ফাইল চলে:

| ইভেন্ট | কখন চলে |
| ----- | ------------ |
| `post-boot` | ডেস্কটপ চালু হওয়ার ঠিক পরেই |
| `post-update` | `omarchy update`-এর প্রায় শেষের দিকে, package, migration এবং service পুনরায় চালু হওয়ার পর, mise tool আপডেট হওয়ার আগে |
| `pre-refresh-pacman` | `omarchy refresh pacman` প্যাকেজ কনফিগ পুনরায় sync করার পর, প্যাকেজ আপডেট করার আগে; channel বদলালে একই refresh ধাপের মধ্যে এটি চলে |
| `theme-set` | theme বদলানোর পর (theme-এর নাম `$1`-এ) |
| `font-set` | font বদলানোর পর (font-এর নাম `$1`-এ) |
| `battery-low` | ব্যাটারি কমে গেলে (শতাংশ `$1`-এ) |

`pre-refresh-pacman` hook-ই হলো custom repository বা `IgnorePkg` লাইন রাখার জায়গা, কারণ এটি package transaction-এর আগে চলে। আপডেট-সংক্রান্ত দুটি hook-ই Omarchy তার cached sudo অনুমোদন মুছে দেওয়ার পর আপনার user হিসেবে চলে, তাই `sudo` ব্যবহার করে এমন hook-এর নিজস্ব অনুমোদন লাগবে এবং তা আপনার password চাইতে পারে।

এই directory-গুলোর প্রতিটিতেই ইতিমধ্যে একটি `.sample` ফাইল আছে, যাতে একটি hook-এর গঠন কেমন হয় তা দেখানো হয়েছে — নাম থেকে `.sample` অংশটি সরিয়ে দিলেই তা কাজে লাগবে। অন্য কোথাও লেখা কোনো script ইনস্টল করতে `omarchy hook install post-boot ~/my-hook` ব্যবহার করুন, যা এটিকে কপি করে এনে executable করে দেবে।

### আপনার নিজের মেনু এন্ট্রি যোগ করা

Omarchy মেনু (`Super + Space`) `~/.config/omarchy/extensions/omarchy-menu.jsonc` সম্পাদনা করে আপনার নিজের সারি দিয়ে বাড়ানো যায়। এন্ট্রিগুলো একটি dotted id দিয়ে চিহ্নিত করা হয়, আর এই id-ই নির্ধারণ করে সেগুলো tree-তে কোথায় বসবে, তাই `personal` মূল মেনুতে দেখা যায় এবং `personal.notes` তার ভেতরে দেখা যায়:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

বিদ্যমান কোনো id আবার ব্যবহার করলে নতুন একটি যোগ না করে আপনি সেই সারিটিকেই ওভাররাইড করবেন। ফাইলটিতে উপলব্ধ সব field comment হিসেবে নথিভুক্ত অবস্থায় দেওয়া আছে।

### আপনার নিজের shell export, function এবং alias যোগ করা

Omarchy অনেক ergonomic alias এবং সহায়ক function নিয়ে আসে, তবে নিজেরগুলো যোগ করতে চাওয়া খুবই সাধারণ ব্যাপার। alias, function এবং export — সবই আপনার `~/.bashrc`-তে যোগ করা উচিত। আপডেটে এই ফাইলটি ওভাররাইট হবে না। Omarchy-এর কোনো ডিফল্ট বদলাতে চাইলেও নিরাপদে এখানে তা যোগ করতে পারেন।

### অভ্যন্তরীণ Omarchy ফাইল বদলানো

দেখুন, এটা আপনার কম্পিউটার। আপনি যা খুশি তাই করতে পারেন, তবে `/usr/share/omarchy`-এর ফাইলগুলোতে সরাসরি পরিবর্তন না করার পরামর্শই আমি দেব। সেগুলো Omarchy pacman package-এর অন্তর্ভুক্ত, তাই পরের আপডেটেই আপনার পরিবর্তনগুলো ওভাররাইট হয়ে যাবে। তার বদলে `~/.config/*` ফোল্ডারে আপনার পছন্দ নয় এমন যেকোনো ডিফল্ট মান ওভাররাইট করে নেওয়াই আপনার জন্য ভালো।

এভাবে আপনি প্রায় সবকিছুই বদলাতে পারেন, যেমন ডিফল্ট keybinding। শুধু `~/.config/hypr/bindings.lua` সম্পাদনা করুন, ধরুন, [Obsidian](https://obsidian.md/)-কে [Joplin](https://joplinapp.org/) দিয়ে বদলাতে (ইনস্টল করুন `omarchy-pkg-add joplin-bin` দিয়ে):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` প্রতিস্থাপনটি যোগ করার আগে বিদ্যমান binding-টি সরিয়ে দেয়। এটি `o.bind`-এর মতোই argument নেয়, launch helper এবং binding option-সহ। binding যোগ করতে `o.bind` ব্যবহার করুন, অথবা প্রতিস্থাপন না করে কোনো binding সরাতে `hl.unbind` ব্যবহার করুন।

আপনি যদি অভ্যন্তরীণ Omarchy ফাইলগুলো হ্যাক করতেই চান, তাহলে _Update > Channel > Dev_ দিয়ে dev channel-এ চলে যান। তাতে Omarchy `~/omarchy`-তে থাকা source code-এর একটি git checkout-এর সঙ্গে যুক্ত হয়ে যাবে, যা আপনি মন ভরে বদলাতে পারবেন। আপনাকে বারণ করার কেউ এখানে নেই!

### যেকোনো পরিবর্তন রিসেট করা

কনফিগারেশনগুলো নিয়ে যদি গোলমাল পাকিয়ে ফেলেন, তাহলে Omarchy মেনুর _Update > Config_ দিয়ে সবসময় সেগুলোকে ডিফল্টে ফিরিয়ে আনতে পারেন। অথবা সবকিছু রিসেট করতে `omarchy reinstall configs` চালিয়েও তা করতে পারেন।
