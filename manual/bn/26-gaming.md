# গেমিং

Omarchy শুধু _pRoDUcTiVItY_-র জন্য নয়, এটা মজা করার জন্যও, আর গেমিংয়ের চেয়ে বেশি মজা আর কীসে? Omarchy-র সঙ্গে গেমিং অপশনের পুরো একটা স্যুট আসে — নেটিভ ও রেট্রো খেলার জন্য Steam ও RetroArch, নন-Steam স্টোরের জন্য Battle.net, Lutris ও Heroic, PC স্ট্রিমিংয়ের জন্য Moonlight, ক্লাউডের জন্য Xbox Cloud Gaming + NVIDIA GeForce NOW, আর সেই সঙ্গে চিরসবুজ Minecraft।

Valve-এর [Proton কম্প্যাটিবিলিটি লেয়ার](https://en.wikipedia.org/wiki/Proton_(software))-এর ওপর অবিশ্বাস্য কাজের সৌজন্যে, এখন Linux-এ দশ হাজার হাজার আধুনিক গেম খেলা যায়। ওহ, আর আপনি কি জানতেন যে [Steam Deck](https://store.steampowered.com/steamdeck/)-এ আসলে Arch-ই চলে!

সব গেমিং ইনস্টলার Omarchy মেনুতে (`Super + Space`) _Install > Gaming_-এর অধীনে থাকে। কোনো একটা কখনো বাতিল করতে চাইলে _Remove > Gaming_ ব্যবহার করুন। Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris ও Heroic শুধু x86 মেশিনের জন্যই দেওয়া হয়।

## Steam

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Steam_ বেছে নিয়ে [Steam](https://store.steampowered.com/) ইনস্টল করুন।

ইনস্টল করার পর, আপনি `Super + Space` দিয়ে Steam চালু করতে পারবেন।

মনে রাখবেন, Steam চালু হতে 10-20 সেকেন্ড লাগতে পারে, আর এটা লোড হচ্ছে এমন কোনো ভিজ্যুয়াল ফিডব্যাক এটি দেবে না।

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > RetroArch_ বেছে নিয়ে [RetroArch](https://www.retroarch.com/) ইনস্টল করুন। এর সঙ্গে libretro কোরের পুরো সেট আসে, তাই সব ক্লাসিক সিস্টেমই কভার করা হয়েছে।

সেই নিখুঁত রেট্রো লুকের জন্য RetroArch সুন্দর CRT Royale শেডার দিয়ে পুরোপুরি প্রিকনফিগার করা থাকে।

শুরু করতে:

1. আপনার BIOS ফাইলগুলো `~/Games/bios`-এ আর আপনার ROMগুলো `~/Games/roms`-এ ফেলুন।
2. `Super + Space` দিয়ে RetroArch চালু করুন আর `retro` টাইপ করুন।
3. `~/Games/roms` ডিরেক্টরি স্ক্যান করুন, ব্যাস, খেলার জন্য তৈরি।

_Install > Gaming > RetroArch Game Launcher_ দিয়ে আপনি প্রিয় কোনো গেমকে অ্যাপ লঞ্চারে নিজের আলাদা এন্ট্রিও দিতে পারেন, যেখানে আপনি একটি কোর আর একটি ROM বেছে নিতে পারেন, আর `Super + Space` থেকে সরাসরি গেমে ঝাঁপিয়ে পড়তে পারেন।

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Xbox Cloud Gaming_ বেছে নিয়ে Xbox Cloud Gaming ওয়েব অ্যাপ ইনস্টল করুন। এটি সার্ভিসটির জন্য "শুধুই" একটি ওয়েব অ্যাপ, কিন্তু এটি দ্রুত চালু হয় আর 1080p-তে দারুণ চলে।

আপনার কাছে ইতিমধ্যে Xbox Game Pass থাকলে, Fortnite আর Linux-এ নেটিভভাবে চালাতে পারবেন না এমন অন্যান্য টাইটেল খেলার জন্য এটি একটি শক্তপোক্ত উপায়।

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > NVIDIA GeForce NOW_ বেছে নিয়ে ক্লাউড-গেমিং সার্ভিস [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) ইনস্টল করুন। Linux-এ নেটিভভাবে পাওয়া যায় না এমন টাইটেল খেলার আরেকটি দারুণ উপায়।

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Minecraft_ বেছে নিয়ে Minecraft ইনস্টল করুন।

Steam-এর মতোই, মনে রাখবেন লগ ইন করার বা চালু হওয়ার পর পরের স্ক্রিন আসতে কিছুটা সময় লাগতে পারে, আর অপেক্ষা করার সময় আপনি কোনো ফিডব্যাক পাবেন না।

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Xbox Controllers_ বেছে নিয়ে Bluetooth Xbox কন্ট্রোলারের সাপোর্ট ইনস্টল করুন। Bluetooth দিয়ে (`Super + Ctrl + B`) কন্ট্রোলারগুলো পেয়ার করুন, আর সেগুলো আপনার সব গেমেই কাজ করবে। আপনি যদি USB-C কেবল দিয়ে কন্ট্রোলার সরাসরি তারে জুড়ে ব্যবহার করেন, তাহলে আপনার এটির দরকার নেই।

## Moonlight (PC থেকে গেম স্ট্রিমিং)

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Moonlight_ বেছে নিয়ে [Moonlight client](https://github.com/moonlight-stream/moonlight-qt) ইনস্টল করুন, আর আপনি [Sunshine](https://app.lizardbyte.dev/Sunshine/) চলা একটি Windows PC থেকে গেম স্ট্রিম করতে পারবেন।

আপনার Omarchy মেশিন আর রিমোট গেমিং PC দুটোই তারে জোড়া থাকলে, অভিজ্ঞতা লোকালি খেলার থেকে আলাদা করে বোঝা যাবে না। রেজোলিউশন নেটিভ পর্যন্ত বাড়িয়ে দিন, রিফ্রেশ 120Hz-এ সেট করুন, আর বিটরেট সর্বোচ্চ করে দিন — Linux-এ Fortnite-এর মতো প্রতিযোগিতামূলক শ্যুটার খেলার এটাই সেরা উপায়।

আপনি `omarchy install service sunshine` চালিয়ে একটি Omarchy মেশিনকে হোস্টও বানাতে পারেন, যা Sunshine ইনস্টল করে আর আপনার LAN ও Tailscale-এর জন্য Moonlight স্ট্রিমিং পোর্ট খুলে দেয়।

## Battle.net

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Battle.net_ বেছে নিয়ে [Battle.net](https://eu.shop.battle.net/en-us) ইনস্টল করুন। এতে আপনি Diablo, Starcraft আর World of Warcraft-এর মতো টাইটেল GE-Proton-এর অধীনে চলা স্ট্যান্ডঅ্যালোন ইনস্টল হিসেবে পাবেন — Steam, Lutris বা Heroic-এর কোনো দরকার নেই।

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows গেম)

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Lutris_ বেছে নিয়ে [Lutris](https://lutris.net/) ইনস্টল করুন। উপরে যাদের নিজের ইনস্টলার নেই, EA আর Ubisoft Connect-এর মতো স্টোর থেকে Windows গেম খেলার উপায় হলো Lutris।

ইনস্টলেশন একটু খাপছাড়া, আর মাঝে মাঝে মনে হয় কিছুই হচ্ছে না — শুধু ধৈর্য ধরুন, এটি ব্যাকগ্রাউন্ডে কাজ করছে।

## Heroic Launcher (Epic Games)

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Heroic (Epic Games)_ বেছে নিয়ে [Heroic Launcher](https://heroicgameslauncher.com/) ইনস্টল করুন। Heroic দিয়ে আপনি OddSparks-এর মতো অ্যান্টি-চিটের ওপর নির্ভর করে না এমন Epic Games টাইটেল চালাতে পারবেন — তার সঙ্গে GOG আর Amazon Prime Gaming-এর গেমও। দুঃখের বিষয়, তার মানে কোনো Fortnite নেই, কোনো Rocket League নেই — Tim Sweeney Linux-এ না আসা পর্যন্ত, এটাই সবচেয়ে কাছাকাছি পাওয়া।

Lutris-এর মতোই, গেম ইনস্টল করার সময় এটি ধীর আর খাপছাড়া মনে হতে পারে। একে সময় দিন।
