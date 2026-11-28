# থিম

Omarchy তেইশটি সুন্দর থিম নিয়ে আসে। আপনি Omarchy Menu-তে (`Super + Space`) _Appearance > Theme_ দিয়ে এগুলোর মধ্যে থেকে বেছে নিতে পারেন, অথবা `Super + Ctrl + T` ব্যবহার করে সরাসরি থিম নির্বাচকে চলে যেতে পারেন।

প্রতিটি থিম ডেস্কটপ, টার্মিনাল, neovim, অ্যাক্টিভিটি স্ক্রিন (btop), আপনার ব্রাউজার (Chrome, Chromium, Edge বা Brave) এবং পুরো Omarchy শেলকে স্টাইল করে: টপ বার, মেনু, বিজ্ঞপ্তি, OSD এবং লক স্ক্রিন। (Obsidian-এর জন্য, অ্যাপের ভিতরে _Appearance > Themes_ দিয়ে আপনাকে নিজে হাতে Omarchy থিমটি নির্বাচন করতে হবে)।

থিমগুলোর সঙ্গে একগুচ্ছ ব্যাকগ্রাউন্ড ছবি থাকে, যেগুলোর মধ্যে থেকে আপনি `Super + Ctrl + W` ব্যবহার করে বেছে নিতে পারেন।

আপনি [অতিরিক্ত থিমের পৃষ্ঠায়](https://omarchy.org/themes/) আরও বেশি থিম খুঁজে পেতে পারেন, এমনকি [নিজের থিমও তৈরি করতে পারেন](43-making-your-own-theme.md)।

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

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### অ্যাপ আইকন

অ্যাপ লঞ্চার ও ডকের আইকনগুলো আপনার থিমের রঙে আঁকা হয়, তাই থিমের সঙ্গে সঙ্গে সেগুলোও বদলে যায়। এগুলো আসে একটি আইকন সেট থেকে, যেটি আপনি থিম থেকে আলাদাভাবে _Appearance > Icons_-এর অধীনে বেছে নেন, প্রতিটি সেটের প্রিভিউ থেকে, ঠিক যেভাবে আপনি একটি থিম বেছে নেন:

- _Papercraft_ হলো ডিফল্ট: ইনস্টল করা সবকিছু, একই স্টাইলে আঁকা। Chrome, HEY বা YouTube-এর মতো লোগো দিয়ে পরিচিত অ্যাপগুলো তাদের আকৃতি ধরে রাখে এবং থিমের রঙ ধারণ করে।
- _Arcade_ একই অ্যাপগুলোকে 8-bit পিক্সেল আর্ট হিসেবে আঁকে, পুরোনো গেম কনসোল যেমন আঁকত।
- _Original_ প্রতিটি অ্যাপকে তার নির্মাতার দেওয়া আইকন দিয়েই দেখায়।

আপনি অন্য কারও তৈরি করা একটি আইকন সেট _Install > Style > Icons_ দিয়ে (অথবা `omarchy icons install <git url>`) ইনস্টল করতে পারেন, এবং _Remove > Icons_-এর অধীনে সেটি আবার সরিয়েও ফেলতে পারেন। _Update > Extra Icons_ আপনার ইনস্টল করা সেটগুলোর সর্বশেষ সংস্করণ নিয়ে আসে।

নিজেরটি তৈরি করতে, আপনার আইকনগুলো `~/.config/omarchy/icons/<name>/`-এ রাখুন, প্রতিটি অ্যাপের জন্য একটি করে ফাইল, অ্যাপের `.desktop` ফাইলের `Icon=` লাইনের নাম অনুসারে নামকরণ করে। `.svg` দিয়ে শেষ হওয়া একটি ফাইল যেমন আছে তেমনই দেখানো হয়। `.svg.tpl` দিয়ে শেষ হওয়া একটি ফাইল থিমের রঙে আঁকা হয়: যেখানে রঙ বসবে সেখানে `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` অথবা `{{ icon_shadow }}` লিখুন। শুরু করার জন্য `/usr/share/omarchy/icons/papercraft/`-এ থাকা ডিফল্ট সেটটি একটি ভালো জায়গা। আপনার সেটটি পিকারে দেখাতে একটি `preview.png` যোগ করুন; সেটি না থাকলে, Omarchy আপনার আইকনগুলো থেকে একটি প্রিভিউ এঁকে নেয়। ডিফল্ট সেটের একটি মাত্র আইকন বদলাতে, আপনার সংস্করণটি `~/.config/omarchy/icons/papercraft/`-এ রাখুন।

### বুট ও লগইন

কম্পিউটার চালু হওয়ার সময় যে স্ক্রিনটি আপনার ড্রাইভের পাসওয়ার্ড চায়, এবং লগইন স্ক্রিন, সেগুলোও থিম অনুসরণ করে। প্রতিবার আপনি থিম বদলালে, সেগুলো তার ব্যাকগ্রাউন্ড, টেক্সট, অ্যাকসেন্ট এবং লাল রঙগুলো গ্রহণ করে, তাই বেছে নেওয়ার জন্য আলাদা কোনো আনলক ডিজাইন নেই। Apple Silicon Mac-গুলোতে, ড্রাইভ পাসওয়ার্ড স্ক্রিনটি থিম যাই হোক না কেন Omarchy-র ডিফল্ট চেহারাই ধরে রাখে।
