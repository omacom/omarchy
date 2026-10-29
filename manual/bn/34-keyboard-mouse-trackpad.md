# কীবোর্ড, মাউস, ট্র্যাকপ্যাড

Hyprland আপনাকে আপনার সব ইনপুট অত্যন্ত বিস্তারিতভাবে কনফিগার করতে দেয়। আপনি কীবোর্ড রিপিটকে সুপারসনিকভাবে দ্রুত করতে পারেন, কিংবা ট্র্যাকপ্যাডকে natural scrolling ব্যবহার করাতে পারেন। আপনি সবকিছুই `~/.config/hypr/input.lua`-তে বদলান, যেখানে Omarchy মেনু (`Super + Space`) দিয়ে _Setup > Input_ হয়েও পৌঁছানো যায়। সেখানে যা-ই সেট করবেন, তাই Omarchy-র ডিফল্টের জায়গা নেবে।

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

CapsLock সাধারণ Caps Lock হিসেবে কাজ করে, এবং `Shift + CapsLock` হলো [quick emojis](07-hotkeys.md#quick-emojis) ও [other completions](07-hotkeys.md#quick-completions)-এর জন্য compose key। আপনি যদি compose key অন্য কোথাও রাখতে চান, তাহলে `kb_options`-এ `omarchy:shift_caps_compose` বদলে দিন। উদাহরণস্বরূপ, এটি compose key-কে Right Alt-এ সরিয়ে দেয়:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ট্র্যাকপ্যাড অঙ্গভঙ্গি

ডেস্কটপে ঘোরাফেরা করতে ট্র্যাকপ্যাডে সোয়াইপ করুন:

| অঙ্গভঙ্গি | কাজ |
| --- | --- |
| তিন আঙুল বামে / ডানে | আগের / পরের workspace, খালিগুলোসহ |
| তিন আঙুল উপরে | AI কনসোল টগল করুন |
| তিন আঙুল নিচে | Omarchy মেনু খুলুন |
| চার আঙুল বামে / ডানে | সক্রিয় উইন্ডোটিকে আগের / পরের workspace-এ সরান |
| চার আঙুল নিচে | fullscreen টগল করুন |

কোনো একটি বদলাতে চাইলে, নিজের [touchpad gesture](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) যোগ করার আগে `~/.config/hypr/input.lua`-তে সেটিকে unset করুন, কারণ Hyprland একই আঙুল ও একই দিকে দুটি অঙ্গভঙ্গি নেবে না:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy-র সব অঙ্গভঙ্গি বন্ধ করতে, Omarchy-র ডিফল্ট লোড হওয়ার আগে `~/.config/hypr/hyprland.lua`-র উপরের দিকে, কাছাকাছি জায়গায় `omarchy_default_gestures = false` সেট করুন।

haptic touchpad-সহ Dell XPS ল্যাপটপে, আপনি _Trigger > Hardware > Touchpad Haptics_-এর অধীনে click strength low, mid বা high-তেও সেট করতে পারেন।

### চীনা, জাপানি ও অন্যান্য ভাষায় টাইপ করা

ইনস্টলার যখন আপনার কীবোর্ডের কথা জিজ্ঞাসা করবে, তখন Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) বা Hong Kong (Cangjie) নির্বাচন করুন। Omarchy কীবোর্ড ও তার সঙ্গে মিলে এমন ইনপুট ইঞ্জিন স্বয়ংক্রিয়ভাবে কনফিগার করে দেয়, অফলাইন first-boot সেটআপের সময়ও। Japanese ব্যবহার করে Mozc, Korean ব্যবহার করে standard two-set Hangul, Simplified Chinese ব্যবহার করে Pinyin, Taiwan ব্যবহার করে Chewing-এর standard Zhuyin বিন্যাস, এবং Hong Kong ব্যবহার করে Hong Kong অক্ষর রূপসহ Cangjie। Japanese (US keyboard) US কীবোর্ড লেআউটসহ Mozc দেয়। আপনি Dvorak, Colemak বা AZERTY দিয়ে ল্যাটিন অক্ষর টাইপ করলেও Hangul, Zhuyin ও Cangjie-র কীগুলো তাদের standard অবস্থানেই থাকে। আপনি যদি এর আগে Hangul বা Chewing যোগ করে থাকেন, তাহলে এর কীগুলো সেখানে সরাতে _Setup > Typing > Input Methods_-এর অধীনে সেটিকে অনির্বাচন করে আবার নির্বাচন করুন; আপনি ইতিমধ্যে যে ইঞ্জিন দিয়ে টাইপ করেন, Omarchy সেটিকে হাত না দিয়ে রেখে দেয়।

টাইপিং Latin মোডে শুরু হয়। কনফিগার করা ইনপুট পদ্ধতিগুলোর মধ্যে চক্রাকারে যেতে `Super + I` চাপুন, এবং পেছনের দিকে চক্রাকারে যেতে `Super + Shift + I` চাপুন। Pinyin-এর মতো কোনো ইনপুট পদ্ধতি থেকে বেরিয়ে ল্যাটিন অক্ষরে যেতে `Shift`-কে একা আলতো চাপুন, আর ফিরে যেতে আবার আলতো চাপুন, ঠিক যেভাবে Sogou, Microsoft Pinyin ও macOS কাজ করে; `Shift`-এর সঙ্গে একটি অক্ষর চাপলে তখনও বড় হাতের অক্ষরই টাইপ হয়। জাপানি কীবোর্ডে, 全角/半角 ইনপুট টগল করে, 変換 সেটিকে চালু করে, এবং 無変換 সেটিকে বন্ধ করে। Korean-এর ক্ষেত্রে, 한/영 Hangul বদলায় এবং 한자 Hanja-তে রূপান্তর করে, আপনার কীবোর্ডে আলাদা কী থাকুক বা অনেক ল্যাপটপের মতো সেগুলোর জন্য Right Alt ও Right Ctrl পাঠাক, তাই সেখানে Right Alt ও Right Ctrl সাধারণ modifier নয়; dictation push-to-talk F9-তেই থাকে। `Ctrl + Space` Tmux ও Herdr-এর জন্য উপলব্ধ থাকে; `Shift + CapsLock` compose key-ই থাকে।

আপনার একাধিক কীবোর্ড লেআউট বা ইনপুট পদ্ধতি থাকলে কীবোর্ড নির্দেশকটি বারের ডানদিকে দেখা যায়। ইনপুট ভাষা বদলাতে সেটিতে ক্লিক করুন; Japanese hiragana-র জন্য あ দেখায়। জাপানি অক্ষরের পছন্দগুলোর জন্য, Japanese-এ বদলে নিন, `nihongo`-র মতো একটি শব্দ টাইপ করুন, তারপর Space দুবার চাপুন। আপনার পছন্দ গ্রহণ করতে Enter চাপুন। আপনার যদি একাধিক কীবোর্ড লেআউটও থাকে, তাহলে সেগুলোর মধ্যে চক্রাকারে যেতে নির্দেশকটিতে right-click করুন।

ইনস্টলেশনের সময় দেওয়া একই পছন্দগুলো থেকে English ও French-এর মতো লেআউট নির্বাচন করতে _Setup > Typing > Keyboard Layouts_ ব্যবহার করুন। কোন composition engine সক্রিয় থাকবে তা নির্বাচন করতে _Setup > Typing > Input Methods_ ব্যবহার করুন। দুটি picker-ই Omarchy মেনুর ভিতরে খোলে, যেখানে আপনার বর্তমান নির্বাচনগুলোতে টিক দেওয়া থাকে। কোনো পছন্দ টগল করতে ক্লিক করুন বা Enter চাপুন; প্রতিটি পরিবর্তন সঙ্গে সঙ্গে প্রয়োগ হয়। কোনো ইনপুট পদ্ধতি অনির্বাচন করলে সেটি আনইনস্টল না করেই চক্র থেকে সরিয়ে দেওয়া হয়; কীবোর্ডটি উপলব্ধই থাকে।

একই picker খুলতে `omarchy setup keyboard` বা `omarchy setup input` চালান। কমান্ড লাইন থেকে একটি ভাষা যোগ করতে `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` বা `cangjie5` ব্যবহার করুন। Quick, Boshiamy ও Array Cangjie-র সঙ্গেই একই প্যাকেজে আসে এবং Input Methods picker-এ দেখা যায়। আপনার কাস্টম switching key সংরক্ষিত থাকে। বিকল্প ইঞ্জিন লেআউট বা কী-র জন্য, `omarchy pkg add fcitx5-configtool` দিয়ে `fcitx5-configtool` ইনস্টল করুন এবং টার্মিনাল থেকে সেটি চালু করুন। কোনো ইনপুট ভাষা নির্বাচন করলে ডেস্কটপের ভাষা বদলায় না। আপনার এখনও কোনো ইনপুট পদ্ধতি না থাকলে, _Setup > Language_-এর অধীনে Japanese, Korean বা Chinese বেছে নিলে তার ইনপুট পদ্ধতি যোগ হয়ে যায়।

ইনপুট পদ্ধতি বা কীবোর্ড লেআউটের মধ্যে চক্রাকারে যেতে `Super + I` ব্যবহার করুন, এবং অন্য দিকে ফিরে যেতে `Super + Shift + I` ব্যবহার করুন, ফলে তিনটি কনফিগার করা থাকলে আপনি দুই প্রতিবেশীর মধ্যে যাওয়া-আসা করতে পারবেন। একাধিক ইনপুট পদ্ধতি বা লেআউট কনফিগার করা থাকলেই কেবল ইনপুট নির্দেশকটি বারের ডানদিকে দেখা যায়। এই ডেস্কটপ বাইন্ডিং আপনার বিদ্যমান Fcitx switching key-র পাশাপাশি কাজ করে; আপনি `~/.config/hypr/bindings.lua`-তে সেটিকে override করতে পারেন। ইনপুট ইঞ্জিন ও compose sequence প্রতিটি সেশনে ইতিমধ্যে চলমান [Fcitx5](https://fcitx-im.org/) সেবাটি ব্যবহার করে।

### ALT-কে SUPER হিসেবে ব্যবহার করুন

কিছু কীবোর্ডে, প্রাথমিক meta key (Windows/cmd key) SUPER হিসেবে ব্যবহার করা সুবিধাজনক নয়। এই পরিবর্তনটি ব্যবহার করে আপনি এর বদলে ALT ব্যবহার করতে পারেন:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
