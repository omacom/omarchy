# কিবোর্ড, মাউস, ট্র্যাকপ্যাড

Hyprland আপনাকে আপনার সব ইনপুট বিস্তারিতভাবে কনফিগার করতে দেয়। আপনি কিবোর্ড পুনরাবৃত্তিকে অতিদ্রুত করতে পারেন অথবা ট্র্যাকপ্যাডকে স্বাভাবিক স্ক্রলিং ব্যবহার করাতে পারেন। আপনি এর সবই `~/.config/hypr/input.lua`-তে বদলান, যেখানে আপনি Omarchy মেনুতে (`Super + Space`) _সেটআপ > ইনপুট_-এর মাধ্যমেও পৌঁছতে পারেন। আপনি সেখানে যা সেট করেন তা Omarchy ডিফল্টগুলোকে বদলে দেয়।

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

আপনি ইনপুটের জন্য Hyprland উইকিতে [সব ইনপুট বিকল্প দেখতে](https://wiki.hypr.land/Configuring/Basics/Variables/#input) পারেন।

CapsLock একটি সাধারণ Caps Lock হিসেবে কাজ করে, এবং `Shift + CapsLock` হলো [দ্রুত ইমোজি](07-hotkeys.md#quick-emojis) এবং [অন্যান্য পূরণের](07-hotkeys.md#quick-completions) জন্য কম্পোজ কী। আপনি কম্পোজ কিটি অন্য কোথাও চাইলে, `kb_options`-এ `omarchy:shift_caps_compose` বদল করুন। উদাহরণস্বরূপ, এটি কম্পোজ কিটিকে Right Alt-এ সরায়:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ট্র্যাকপ্যাডের ভঙ্গি

আপনি [টাচপ্যাডের ভঙ্গিও](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) চালু করতে পারেন, যেমন ওয়ার্কস্পেস বদলাতে তিন আঙুল দিয়ে সোয়াইপ করা:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

হ্যাপটিক টাচপ্যাডসহ Dell XPS ল্যাপটপে, আপনি _ট্রিগার > হার্ডওয়্যার > টাচপ্যাড হ্যাপটিক্স_-এর অধীনে ক্লিকের শক্তি কম, মাঝারি বা বেশি সেটও করতে পারেন।

### চীনা, জাপানি এবং অন্যান্য ভাষায় টাইপ করা

ইনস্টলার আপনার কিবোর্ড চাইলে Japanese, Korean, Chinese (Simplified, Pinyin) অথবা Chinese (Traditional, Zhuyin) বাছুন। Omarchy অফলাইন প্রথম-বুট সেটআপের সময়সহ, কিবোর্ড ও মিলে যাওয়া ইনপুট ইঞ্জিন স্বয়ংক্রিয়ভাবে কনফিগার করে। Japanese Mozc ব্যবহার করে, Korean সাধারণ দুই-সেট Hangul ব্যবহার করে, Simplified Chinese Pinyin ব্যবহার করে এবং Traditional Chinese Chewing-এর সাধারণ Zhuyin বিন্যাস ব্যবহার করে। Japanese (US keyboard) একটি US কিবোর্ড লেআউটসহ Mozc দেয়।

টাইপিং লাতিন মোডে শুরু হয়। কনফিগার করা ইনপুট পদ্ধতিগুলো ঘুরে দেখতে `Super + I` চাপুন, এবং পেছনে ঘুরতে `Super + Shift + I` চাপুন। Pinyin-এর মতো কোনো ইনপুট পদ্ধতি থেকে লাতিন হরফে বেরিয়ে আসতে শুধু `Shift`-এ টোকা দিন, এবং ফিরে যেতে আবার টোকা দিন, যেভাবে Sogou, Microsoft Pinyin এবং macOS কাজ করে; `Shift` ও একটি হরফ এখনও বড় হাতের হরফ টাইপ করে। জাপানি কিবোর্ডে, 全角/半角 ইনপুট টগল করে, 変換 এটিকে চালু করে এবং 無変換 এটিকে বন্ধ করে। কোরিয়ান কিবোর্ড লেআউটে, নিবেদিত 한/영 এবং 한자 কী Hangul বদলায় এবং Hanja-তে রূপান্তর করে। `Ctrl + Space` Tmux এবং Herdr-এর জন্য পাওয়া যায়; `Shift + CapsLock` কম্পোজ কী হিসেবেই থাকে।

আপনার একাধিক কিবোর্ড লেআউট বা ইনপুট পদ্ধতি থাকলে কিবোর্ড সূচকটি বারের ডানদিকে দেখা যায়। ইনপুট ভাষা বদলাতে এতে ক্লিক করুন; Japanese হিরাগানার জন্য あ দেখায়। জাপানি অক্ষরের পছন্দের জন্য, Japanese-এ যান, `nihongo`-এর মতো কোনো শব্দ টাইপ করুন, তারপর দুবার Space চাপুন। আপনার পছন্দ গ্রহণ করতে Enter চাপুন। আপনার একাধিক কিবোর্ড লেআউটও থাকলে, সেগুলো ঘুরে দেখতে সূচকটিতে রাইট-ক্লিক করুন।

ইনস্টলের সময় দেওয়া একই পছন্দগুলো থেকে English এবং French-এর মতো লেআউট বাছতে _সেটআপ > টাইপিং > কিবোর্ড লেআউট_ ব্যবহার করুন। কোন কম্পোজিশন ইঞ্জিনগুলো সক্রিয় তা বাছতে _সেটআপ > টাইপিং > ইনপুট পদ্ধতি_ ব্যবহার করুন। দুটি পিকারই আপনার বর্তমান নির্বাচনগুলো টিক করে Omarchy মেনুর ভেতরে খোলে। কোনো পছন্দ টগল করতে ক্লিক করুন অথবা Enter চাপুন; প্রতিটি বদল সঙ্গে সঙ্গে প্রযোজ্য হয়। কোনো ইনপুট পদ্ধতির নির্বাচন বাতিল করলে এটিকে আনইনস্টল না করেই চক্র থেকে সরানো হয়; কিবোর্ডটি পাওয়া যায়ই থাকে।

একই পিকারগুলো খুলতে `omarchy setup keyboard` অথবা `omarchy setup input` চালান। কমান্ড লাইন থেকে একটি ভাষা যোগ করতে, `omarchy setup input mozc`, `hangul`, `pinyin` অথবা `chewing` ব্যবহার করুন। আপনার কাস্টম স্যুইচিং কীগুলো সংরক্ষণ করা হয়। বিকল্প ইঞ্জিন লেআউট বা কী-এর জন্য, `omarchy pkg add fcitx5-configtool` দিয়ে `fcitx5-configtool` ইনস্টল করুন এবং একটি টার্মিনাল থেকে এটি চালান। কোনো ইনপুট ভাষা বাছলে ডেস্কটপের ভাষা বদলায় না।

ইনপুট পদ্ধতি বা কিবোর্ড লেআউট ঘুরে দেখতে `Super + I` ব্যবহার করুন, এবং উল্টোদিকে যেতে `Super + Shift + I` ব্যবহার করুন, ফলে তিনটি কনফিগার করা থাকলে আপনি দুই প্রতিবেশীর মধ্যে যেতে পারেন। একাধিক ইনপুট পদ্ধতি বা লেআউট কনফিগার করা থাকলেই কেবল ইনপুট সূচকটি বারের ডানদিকে দেখা যায়। এই ডেস্কটপ বাইন্ডিংটি আপনার বিদ্যমান Fcitx স্যুইচিং কীগুলোর পাশাপাশি কাজ করে; আপনি `~/.config/hypr/bindings.lua`-তে এটিকে বদল করতে পারেন। ইনপুট ইঞ্জিনগুলো এবং কম্পোজ সিকোয়েন্সগুলো প্রতিটি সেশনে ইতিমধ্যে চলা [Fcitx5](https://fcitx-im.org/) পরিষেবাটি ব্যবহার করে।

### ALT-কে SUPER হিসেবে ব্যবহার করুন

কিছু কিবোর্ডে, প্রাথমিক মেটা কীটিকে (Windows/cmd কী) SUPER হিসেবে ব্যবহার করা সুবিধাজনক নয়। আপনি এই বদল ব্যবহার করে এর পরিবর্তে এটিকে ALT করতে পারেন:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
