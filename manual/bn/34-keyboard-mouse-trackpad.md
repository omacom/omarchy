# কীবোর্ড, মাউস, ট্র্যাকপ্যাড

Hyprland আপনাকে আপনার সব ইনপুট বিশদভাবে কনফিগার করতে দেয়। আপনি কীবোর্ড রিপিটকে অতিসোনিক দ্রুত করতে পারেন কিংবা ট্র্যাকপ্যাডে ন্যাচারাল স্ক্রোলিং ব্যবহার করাতে পারেন। আপনি এসবের সবকিছু `~/.config/hypr/input.lua`-তে বদলান, যেখানে Omarchy মেনু (`Super + Space`) থেকে _Setup > Input_ দিয়েও পৌঁছাতে পারবেন। সেখানে যা সেট করবেন, তাই Omarchy-র ডিফল্টগুলোকে প্রতিস্থাপন করবে।

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

আপনি ইনপুটের জন্য Hyprland উইকিতে [সব ইনপুট অপশন দেখতে পারেন](https://wiki.hypr.land/Configuring/Basics/Variables/#input)।

CapsLock একটি স্বাভাবিক Caps Lock হিসেবে কাজ করে, এবং `Shift + CapsLock` হলো [দ্রুত ইমোজি](07-hotkeys.md#quick-emojis) এবং [অন্যান্য সম্পূর্ণকরণের](07-hotkeys.md#quick-completions) জন্য compose কী। আপনি যদি compose কীটি অন্যত্র রাখতে চান, তাহলে `kb_options`-এ `omarchy:shift_caps_compose` প্রতিস্থাপন করুন। যেমন, এটি compose কীটিকে Right Alt-এ সরিয়ে দেয়:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ট্র্যাকপ্যাড জেসচার

আপনি [টাচপ্যাড জেসচারও](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) চালু করতে পারেন, যেমন তিন আঙুলে সোয়াইপ করে ওয়ার্কস্পেস বদলানো:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

হ্যাপটিক টাচপ্যাডযুক্ত Dell XPS ল্যাপটপে, আপনি _Trigger > Hardware > Touchpad Haptics_-এর অধীনে ক্লিকের শক্তি low, mid বা high-তেও সেট করতে পারেন।

### চীনা, জাপানি এবং অন্যান্য ভাষায় টাইপ করা

ইনস্টলার যখন আপনার কীবোর্ডের কথা জিজ্ঞেস করবে, তখন Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) অথবা Hong Kong (Cangjie) নির্বাচন করুন। Omarchy স্বয়ংক্রিয়ভাবে কীবোর্ড এবং মানানসই ইনপুট ইঞ্জিন কনফিগার করে দেয়, অফলাইন ফার্স্ট-বুট সেটআপের সময়ও। Japanese Mozc ব্যবহার করে, Korean স্ট্যান্ডার্ড দুই-সেট Hangul ব্যবহার করে, Simplified Chinese Pinyin ব্যবহার করে, Taiwan Chewing-এর স্ট্যান্ডার্ড Zhuyin বিন্যাস ব্যবহার করে, এবং Hong Kong Hong Kong অক্ষরের রূপসহ Cangjie ব্যবহার করে। Japanese (US keyboard) US কীবোর্ড লেআউটসহ Mozc সরবরাহ করে। আপনি Dvorak, Colemak বা AZERTY দিয়ে ল্যাটিন অক্ষর টাইপ করলেও Hangul, Zhuyin এবং Cangjie কীগুলো তাদের স্ট্যান্ডার্ড অবস্থানেই থাকে। আপনি যদি এর আগে Hangul বা Chewing যোগ করে থাকেন, তাহলে এর কীগুলো সেখানে সরাতে _Setup > Typing > Input Methods_-এর অধীনে তা অনির্বাচন করে আবার নির্বাচন করুন; আপনি ইতিমধ্যে যে ইঞ্জিন দিয়ে টাইপ করেন, Omarchy তাকে অপরিবর্তিত রাখে।

টাইপিং ল্যাটিন মোডে শুরু হয়। কনফিগার করা ইনপুট পদ্ধতিগুলোর মধ্যে চক্রাকারে যেতে `Super + I` চাপুন, আর পেছনের দিকে চক্রাকারে যেতে `Super + Shift + I` চাপুন। Pinyin-এর মতো কোনো ইনপুট পদ্ধতি থেকে বেরিয়ে ল্যাটিন অক্ষরে যেতে নিজে নিজেই `Shift` ট্যাপ করুন, আর ফিরে যেতে আবার ট্যাপ করুন, যেভাবে Sogou, Microsoft Pinyin এবং macOS কাজ করে; `Shift` প্লাস একটি অক্ষর এখনো বড় হাতের অক্ষর টাইপ করে। Japanese কীবোর্ডে, 全角/半角 ইনপুট টগল করে, 変換 তা চালু করে, এবং 無変換 তা বন্ধ করে। Korean-এর ক্ষেত্রে, 한/영 Hangul বদলায় এবং 한자 Hanja-তে রূপান্তর করে, আপনার কীবোর্ডে ডেডিকেটেড কী থাকুক কিংবা সেগুলোর জন্য Right Alt এবং Right Ctrl পাঠাক, যেমন অনেক ল্যাপটপ করে, তাই সেখানে Right Alt এবং Right Ctrl সাধারণ মডিফায়ার নয়; ডিক্টেশন পুশ-টু-টক F9-তেই থাকে। `Ctrl + Space` Tmux এবং Herdr-এর জন্য উপলব্ধ থাকে; `Shift + CapsLock` compose কী হিসেবেই থাকে।

যখন আপনার একাধিক কীবোর্ড লেআউট বা ইনপুট পদ্ধতি থাকে, তখন বারের ডানদিকে কীবোর্ড নির্দেশকটি দেখা যায়। ইনপুট ভাষা বদলাতে এতে ক্লিক করুন; Japanese হিরাগানার জন্য あ প্রদর্শন করে। Japanese অক্ষর বাছাইয়ের জন্য, Japanese-এ স্যুইচ করুন, `nihongo`-র মতো একটি শব্দ টাইপ করুন, তারপর দুবার Space চাপুন। আপনার পছন্দ গ্রহণ করতে Enter চাপুন। আপনার যদি একাধিক কীবোর্ড লেআউটও থাকে, তাহলে সেগুলোর মধ্যে চক্রাকারে যেতে নির্দেশকটিতে রাইট-ক্লিক করুন।

ইনস্টলেশনের সময় দেওয়া একই পছন্দগুলো থেকে English এবং French-এর মতো লেআউট নির্বাচন করতে _Setup > Typing > Keyboard Layouts_ ব্যবহার করুন। কোন কম্পোজিশন ইঞ্জিনগুলো সক্রিয় থাকবে তা নির্বাচন করতে _Setup > Typing > Input Methods_ ব্যবহার করুন। দুটি পিকারই Omarchy মেনুর ভেতরে আপনার বর্তমান নির্বাচনগুলো চেক করা অবস্থায় খোলে। কোনো পছন্দ টগল করতে ক্লিক করুন বা Enter চাপুন; প্রতিটি পরিবর্তন সঙ্গে সঙ্গে প্রয়োগ হয়। কোনো ইনপুট পদ্ধতি অনির্বাচন করলে তা আনইনস্টল না করেই চক্র থেকে সরিয়ে দেওয়া হয়; কীবোর্ডটি উপলব্ধ থাকে।

একই পিকারগুলো খুলতে `omarchy setup keyboard` বা `omarchy setup input` চালান। কমান্ড লাইন থেকে একটি ভাষা যুক্ত করতে `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` বা `cangjie5` ব্যবহার করুন। Quick, Boshiamy এবং Array Cangjie-র সঙ্গেই একই প্যাকেজে আসে এবং Input Methods পিকারে দেখা যায়। আপনার কাস্টম স্যুইচিং কীগুলো সংরক্ষিত থাকে। বিকল্প ইঞ্জিন লেআউট বা কীগুলোর জন্য, `omarchy pkg add fcitx5-configtool` দিয়ে `fcitx5-configtool` ইনস্টল করুন এবং একটি টার্মিনাল থেকে তা চালু করুন। কোনো ইনপুট ভাষা নির্বাচন করলে ডেস্কটপের ভাষা বদলায় না। আপনার এখনো কোনো ইনপুট পদ্ধতি না থাকলে _Setup > Language_-এর অধীনে Japanese, Korean বা Chinese বেছে নিলে তার ইনপুট পদ্ধতি যুক্ত হয়ে যায়।

ইনপুট পদ্ধতি বা কীবোর্ড লেআউটগুলোর মধ্যে চক্রাকারে যেতে `Super + I` ব্যবহার করুন, আর উল্টো দিকে ফিরে যেতে `Super + Shift + I` ব্যবহার করুন, যাতে তিনটি কনফিগার করা থাকলে আপনি দুই প্রতিবেশীর মধ্যে চলাচল করতে পারেন। একাধিক ইনপুট পদ্ধতি বা লেআউট কনফিগার করা থাকলেই কেবল বারের ডানদিকে ইনপুট নির্দেশকটি দেখা যায়। এই ডেস্কটপ বাইন্ডিংটি আপনার বিদ্যমান Fcitx স্যুইচিং কীগুলোর পাশাপাশি কাজ করে; আপনি `~/.config/hypr/bindings.lua`-তে এটি ওভাররাইড করতে পারেন। ইনপুট ইঞ্জিনগুলো এবং compose সিকোয়েন্সগুলো প্রতিটি সেশনে ইতিমধ্যে চলমান [Fcitx5](https://fcitx-im.org/) সার্ভিস ব্যবহার করে।

### ALT-কে SUPER হিসেবে ব্যবহার করা

কিছু কীবোর্ডে, প্রাথমিক মেটা কী (Windows/cmd কী) SUPER হিসেবে ব্যবহার করা সুবিধাজনক নয়। এই পরিবর্তনটি ব্যবহার করে আপনি এর বদলে ALT-কে তা বানাতে পারেন:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
