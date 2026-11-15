# থিম

Omarchy-র সঙ্গে বাইশটি সুন্দর থিম আসে। আপনি Omarchy Menu (`Super + Space`)-তে _Appearance > Theme_ দিয়ে সেগুলোর মধ্যে থেকে বেছে নিতে পারেন অথবা `Super + Ctrl + T` ব্যবহার করে সরাসরি থিম নির্বাচকে চলে যেতে পারেন।

প্রতিটি থিম ডেস্কটপ, টার্মিনাল, neovim, অ্যাক্টিভিটি স্ক্রিন (btop), Chromium এবং পুরো Omarchy শেলের স্টাইল বদলে দেয়: টপ বার, মেনু, বিজ্ঞপ্তি, OSD এবং লক স্ক্রিন। (Obsidian-এর জন্য, আপনাকে অ্যাপের ভিতরে _Appearance > Themes_ দিয়ে ম্যানুয়ালি Omarchy থিমটি নির্বাচন করতে হবে)।

থিমগুলোর সঙ্গে একগুচ্ছ ব্যাকগ্রাউন্ড ছবি থাকে, যেগুলোর মধ্যে থেকে আপনি `Super + Ctrl + W` ব্যবহার করে বেছে নিতে পারেন।

আপনি [অতিরিক্ত থিমের পৃষ্ঠায়](https://omarchy.org/themes/) আরও বেশি থিম খুঁজে পেতে পারেন অথবা এমনকি [নিজের থিম নিজেই তৈরি করতে পারেন](43-making-your-own-theme.md)।

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

### অ্যাপ আইকন

অ্যাপ লঞ্চার ও ডকের আইকনগুলো আপনার থিমের রঙে আঁকা হয়, তাই থিমের সঙ্গেই সেগুলো বদলে যায়। এগুলো একটি আইকন সেট থেকে আসে, যা আপনি _Appearance > Icons_-এর অধীনে থিমের থেকে আলাদাভাবে বেছে নেন:

- _Papercraft_ হলো ডিফল্ট: ইনস্টল করা অবস্থায় যা যা আসে, সবই এক স্টাইলে আঁকা। Chrome, HEY বা YouTube-এর মতো লোগো দিয়ে পরিচিত অ্যাপগুলো তাদের আকার ধরে রাখে এবং থিমের রঙ ধারণ করে।
- _Arcade_ একই অ্যাপগুলোকে 8-bit পিক্সেল আর্ট হিসেবে আঁকে, যেমনটা কোনো পুরোনো গেম কনসোল করত।
- _Original_ প্রতিটি অ্যাপকে তার নির্মাতার দেওয়া আইকন দিয়েই দেখায়।

আপনি অন্য কারও তৈরি করা একটি আইকন সেট _Install > Style > Icons_ দিয়ে (অথবা `omarchy icons install <git url>` দিয়ে) ইনস্টল করতে পারেন, এবং _Remove > Icons_-এর অধীনে আবার সেটি সরিয়েও ফেলতে পারেন। _Update > Extra Icons_ আপনার ইনস্টল করা সেটগুলোর সর্বশেষ সংস্করণ নিয়ে আসে।

নিজেরটি তৈরি করতে, আপনার আইকনগুলো `~/.config/omarchy/icons/<name>/`-এ রাখুন, প্রতি অ্যাপের জন্য একটি করে ফাইল, অ্যাপের `.desktop` ফাইলের `Icon=` লাইনের নাম অনুসারে নাম দিয়ে। `.svg` দিয়ে শেষ হওয়া একটি ফাইল যেমন আছে তেমনই দেখানো হয়। `.svg.tpl` দিয়ে শেষ হওয়া একটি ফাইল থিমের রঙে আঁকা হয়: যেখানে রঙ বসবে সেখানে `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` অথবা `{{ icon_shadow }}` লিখুন। `/usr/share/omarchy/icons/papercraft/`-এ থাকা ডিফল্ট সেটটি শুরু করার জন্য একটি ভালো জায়গা। ডিফল্ট সেটের একটি মাত্র আইকন বদলাতে, আপনার সংস্করণটি `~/.config/omarchy/icons/papercraft/`-এ রাখুন।

### আনলক

থিমগুলোর একটি কাস্টম আনলক ডিজাইনও থাকতে পারে, যা বুট ডিক্রিপশন প্রক্রিয়ার জন্য ব্যবহার করা হয়। আপনি _Appearance > Unlock_-এর অধীনে এগুলোর একটি বেছে নিতে পারেন। এগুলো দেখতে এমন:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
