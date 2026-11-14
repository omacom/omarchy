# কীবোর্ড, মাউস, ট্র্যাকপ্যাড

Hyprland আপনাকে আপনার সব ইনপুট বিস্তারিতভাবে কনফিগার করার সুযোগ দেয়। আপনি কীবোর্ড রিপিটকে অতিধ্বনির মতো দ্রুত করতে পারেন অথবা ট্র্যাকপ্যাডে ন্যাচারাল স্ক্রলিং ব্যবহার করাতে পারেন। আপনি সবকিছু `~/.config/hypr/input.lua`-তে পরিবর্তন করেন, যেখানে Omarchy মেনুতে (`Super + Space`) _Setup > Input_ দিয়েও পৌঁছাতে পারেন। সেখানে যা সেট করবেন, তা Omarchy-র ডিফল্টগুলোকে প্রতিস্থাপন করবে।

এখানে একটি উদাহরণ দেওয়া হলো:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

আপনি Hyprland উইকিতে ইনপুটের জন্য [সব ইনপুট অপশন দেখতে পারেন](https://wiki.hypr.land/Configuring/Basics/Variables/#input)।

CapsLock সাধারণ Caps Lock হিসেবে কাজ করে, এবং `Shift + CapsLock` হলো [দ্রুত ইমোজি](07-hotkeys.md#quick-emojis) এবং [অন্যান্য কমপ্লিশন](07-hotkeys.md#quick-completions)-এর জন্য কম্পোজ কী। আপনি যদি কম্পোজ কী অন্য কোথাও রাখতে চান, তাহলে `kb_options`-এ `omarchy:shift_caps_compose` প্রতিস্থাপন করুন। উদাহরণস্বরূপ, এটি কম্পোজ কী Right Alt-এ সরিয়ে দেয়:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ফাংশন কী

ল্যাপটপ কীবোর্ডের উপরের সারি ডিফল্টভাবে মিডিয়া কী (ভলিউম, উজ্জ্বলতা ইত্যাদি) পাঠায়, এবং `Fn` ধরে রাখলে F1-F12 পাওয়া যায়; `Fn + Esc` এটিকে উল্টোভাবে লক করে, যতক্ষণ না আপনি আবার এটি চাপেন। বেশিরভাগ কীবোর্ড নিজেই সেই লক মনে রাখে। ASUS ল্যাপটপ এবং Apple-ধাঁচের কীবোর্ড এটি Linux-এর উপর ছেড়ে দেয়, যা প্রতিটি বুটে সেগুলোকে মিডিয়া কী দিয়ে শুরু করে। পরিবর্তে সেগুলোকে F1-F12 দিয়ে শুরু করতে, `omarchy keyboard toprow fnkeys` চালান (এবং ফিরে যেতে `omarchy keyboard toprow mediakeys`); কিছু ল্যাপটপে এটি রিবুটের পরে কার্যকর হয়। Apple Silicon Mac গুলো তাদের নিজস্ব সেটিং রাখে।

### ট্র্যাকপ্যাড জেসচার

ডেস্কটপে ঘোরাফেরা করতে ট্র্যাকপ্যাডে সোয়াইপ করুন:

| জেসচার | কাজ |
| --- | --- |
| তিন আঙুল বামে / ডানে | আগের / পরের ওয়ার্কস্পেস, খালিগুলোসহ |
| তিন আঙুল উপরে | AI কনসোল টগল করুন |
| তিন আঙুল নিচে | Omarchy মেনু খুলুন |
| চার আঙুল বামে / ডানে | সক্রিয় উইন্ডোটি আগের / পরের ওয়ার্কস্পেসে সরান |
| চার আঙুল নিচে | ফুলস্ক্রিন টগল করুন |

কোনো একটি পরিবর্তন করতে, আপনার নিজের [টাচপ্যাড জেসচার](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) যোগ করার আগে `~/.config/hypr/input.lua`-তে সেটি আনসেট করুন, কারণ Hyprland একই আঙুল ও দিকে দুটি জেসচার নেবে না:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy-র সব জেসচার বন্ধ করতে, Omarchy-র ডিফল্ট লোড হওয়ার আগে, `~/.config/hypr/hyprland.lua`-র উপরের দিকে `omarchy_default_gestures = false` সেট করুন।

Dell XPS ল্যাপটপে হ্যাপটিক টাচপ্যাড থাকলে, আপনি _Trigger > Hardware > Touchpad Haptics_-এর অধীনে ক্লিকের শক্তি low, mid, বা high-তেও সেট করতে পারেন।

### চীনা, জাপানি এবং অন্যান্য ভাষায় টাইপ করা

ইনস্টলার যখন আপনার কীবোর্ডের কথা জিজ্ঞাসা করবে, তখন Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), বা Hong Kong (Cangjie) নির্বাচন করুন। Omarchy কীবোর্ড এবং মিলে যাওয়া ইনপুট ইঞ্জিন স্বয়ংক্রিয়ভাবে কনফিগার করে, অফলাইন প্রথম-বুট সেটআপের সময়সহ। Japanese Mozc ব্যবহার করে, Korean স্ট্যান্ডার্ড দুই-সেট Hangul ব্যবহার করে, Simplified Chinese Pinyin ব্যবহার করে, Taiwan Chewing-এর স্ট্যান্ডার্ড Zhuyin বিন্যাস ব্যবহার করে, এবং Hong Kong Hong Kong অক্ষরের রূপসহ Cangjie ব্যবহার করে। Japanese (US keyboard) US কীবোর্ড লেআউটসহ Mozc সরবরাহ করে। আপনি Dvorak, Colemak, বা AZERTY দিয়ে ল্যাটিন অক্ষর টাইপ করলেও Hangul, Zhuyin, এবং Cangjie কীগুলো তাদের স্ট্যান্ডার্ড অবস্থানেই থাকে। আপনি যদি এর আগে Hangul বা Chewing যোগ করে থাকেন, তাহলে এর কীগুলো সেখানে সরাতে _Setup > Keyboard > Input Methods_-এর অধীনে এটি অনির্বাচন করে আবার নির্বাচন করুন; আপনি ইতিমধ্যে যে ইঞ্জিন দিয়ে টাইপ করেন, Omarchy সেটিকে একা ছেড়ে দেয়।

টাইপ করা Latin মোডে শুরু হয়। কনফিগার করা ইনপুট পদ্ধতিগুলোর মধ্যে চক্রাকারে যেতে `Super + I` চাপুন, এবং পেছনের দিকে চক্রাকারে যেতে `Super + Shift + I` চাপুন। Pinyin-এর মতো একটি ইনপুট পদ্ধতি থেকে ল্যাটিন অক্ষরে বেরিয়ে আসতে শুধু `Shift` আলতো করে চাপুন, এবং ফিরে যেতে আবার আলতো করে চাপুন, যেভাবে Sogou, Microsoft Pinyin, এবং macOS কাজ করে; `Shift` প্লাস একটি অক্ষর তবুও বড় হাতের অক্ষর টাইপ করে। Japanese কীবোর্ডে, 全角/半角 ইনপুট টগল করে, 変換 এটি চালু করে, এবং 無変換 এটি বন্ধ করে। Korean-এর সাথে, 한/영 Hangul সুইচ করে এবং 한자 Hanja-তে রূপান্তর করে, আপনার কীবোর্ডে ডেডিকেটেড কী থাকুক বা অনেক ল্যাপটপের মতো সেগুলোর জন্য Right Alt এবং Right Ctrl পাঠাক, তাই সেখানে Right Alt এবং Right Ctrl সাধারণ মডিফায়ার নয়; ডিক্টেশন এর পরিবর্তে Alt + Space দিয়ে টগল হয়। `Ctrl + Space` Tmux এবং Herdr-এর জন্য উপলব্ধ থাকে; `Shift + CapsLock` কম্পোজ কী হিসেবেই থাকে।

আপনার একাধিক কীবোর্ড লেআউট বা ইনপুট পদ্ধতি থাকলে কীবোর্ড সূচকটি বারের ডানদিকে দেখা যায়। ইনপুট ভাষা সুইচ করতে এটিতে ক্লিক করুন; Japanese হিরাগানার জন্য あ প্রদর্শন করে। Japanese অক্ষর বাছাইয়ের জন্য, Japanese-এ সুইচ করুন, `nihongo`-এর মতো একটি শব্দ টাইপ করুন, তারপর Space দুবার চাপুন। আপনার পছন্দ গ্রহণ করতে Enter চাপুন। আপনার যদি একাধিক কীবোর্ড লেআউটও থাকে, তাহলে সেগুলোর মধ্যে চক্রাকারে যেতে সূচকটিতে রাইট-ক্লিক করুন।

ইনস্টলেশনের সময় দেওয়া একই পছন্দগুলো থেকে English এবং French-এর মতো লেআউট নির্বাচন করতে _Setup > Keyboard > Keyboard Inputs_ ব্যবহার করুন। কোন কম্পোজিশন ইঞ্জিনগুলো সক্রিয় থাকবে তা নির্বাচন করতে _Setup > Keyboard > Input Methods_ ব্যবহার করুন। দুটি পিকারই Omarchy মেনুর ভেতরে খোলে, আপনার বর্তমান নির্বাচনগুলো চেক করা অবস্থায়। একটি পছন্দ টগল করতে ক্লিক করুন বা Enter চাপুন; প্রতিটি পরিবর্তন অবিলম্বে প্রয়োগ হয়। একটি ইনপুট পদ্ধতি অনির্বাচন করলে এটি আনইনস্টল না করেই চক্র থেকে সরিয়ে দেওয়া হয়; কীবোর্ডটি উপলব্ধ থাকে।

একই পিকারগুলো খুলতে `omarchy setup keyboard` বা `omarchy setup input` চালান। কমান্ড লাইন থেকে একটি ভাষা যুক্ত করতে, `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, বা `cangjie5` ব্যবহার করুন। Quick, Boshiamy, এবং Array Cangjie-এর একই প্যাকেজে আসে এবং Input Methods পিকারে দেখা যায়। আপনার কাস্টম সুইচিং কীগুলো সংরক্ষিত থাকে। বিকল্প ইঞ্জিন লেআউট বা কীগুলোর জন্য, `omarchy pkg add fcitx5-configtool` দিয়ে `fcitx5-configtool` ইনস্টল করুন এবং টার্মিনাল থেকে এটি চালু করুন। একটি ইনপুট ভাষা নির্বাচন করলে ডেস্কটপের ভাষা পরিবর্তন হয় না। আপনার এখনও কোনো ইনপুট পদ্ধতি না থাকলে, _Setup > Language_-এর অধীনে Japanese, Korean, বা Chinese বেছে নিলে এর ইনপুট পদ্ধতি যোগ হয়।

ইনপুট পদ্ধতি বা কীবোর্ড লেআউটের মধ্যে চক্রাকারে যেতে `Super + I` ব্যবহার করুন, এবং অন্য দিকে ফিরে যেতে `Super + Shift + I` ব্যবহার করুন, তাই তিনটি কনফিগার করা থাকলে আপনি দুই প্রতিবেশীর মধ্যে চলাচল করতে পারবেন। একাধিক ইনপুট পদ্ধতি বা লেআউট কনফিগার করা থাকলেই কেবল ইনপুট সূচকটি বারের ডানদিকে দেখা যায়। এই ডেস্কটপ বাইন্ডিংটি আপনার বিদ্যমান Fcitx সুইচিং কীগুলোর পাশাপাশি কাজ করে; আপনি `~/.config/hypr/bindings.lua`-তে এটি ওভাররাইড করতে পারেন। ইনপুট ইঞ্জিন এবং কম্পোজ সিকোয়েন্সগুলো প্রতিটি সেশনে ইতিমধ্যে চলমান [Fcitx5](https://fcitx-im.org/) পরিষেবা ব্যবহার করে।

### SUPER হিসেবে ALT ব্যবহার করুন

কিছু কীবোর্ডে, SUPER হিসেবে প্রাথমিক মেটা কী (Windows/cmd কী) ব্যবহার করা সুবিধাজনক নয়। আপনি এই পরিবর্তনটি ব্যবহার করে পরিবর্তে ALT-কে তা করতে পারেন:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
