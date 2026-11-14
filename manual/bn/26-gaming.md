# গেমিং

Omarchy শুধু _pRoDUcTiVItY_-র জন্য নয়, এটি মজা করার জন্যও, আর গেমিংয়ের চেয়ে বেশি মজা আর কীসে আছে? Omarchy-তে গেমিং অপশনের একটা পুরো স্যুট রয়েছে — নেটিভ ও রেট্রো খেলার জন্য Steam আর RetroArch, নন-Steam স্টোরের জন্য Battle.net, Lutris, আর Heroic, PC স্ট্রিমিংয়ের জন্য Moonlight, ক্লাউডের জন্য Xbox Cloud Gaming + NVIDIA GeForce NOW, আর সেই চিরসবুজ Minecraft।

Valve-এর [Proton কম্প্যাটিবিলিটি লেয়ার](https://en.wikipedia.org/wiki/Proton_(software))-এর ওপর করা অবিশ্বাস্য কাজের জন্য ধন্যবাদ, এখন Linux-এ হাজার হাজার আধুনিক গেম খেলা যায়। ওহ, আর আপনি কি জানতেন যে [Steam Deck](https://store.steampowered.com/steamdeck/) আসলে Arch চালায়!

সব গেমিং ইনস্টলার রয়েছে Omarchy মেনুতে (`Super + Space`) _Install > Gaming_-এর অধীনে। আপনি যদি কখনও কোনো একটি পূর্বাবস্থায় ফেরাতে চান, তবে _Remove > Gaming_ ব্যবহার করুন।

## Steam

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Steam_ নির্বাচন করে [Steam](https://store.steampowered.com/) ইনস্টল করুন।

এটি ইনস্টল করার পর, আপনি `Super + Space` দিয়ে Steam চালু করতে পারবেন।

মনে রাখবেন যে Steam শুরু হতে 10-20 সেকেন্ড সময় নিতে পারে, এবং এটি লোড হচ্ছে এমন কোনো ভিজ্যুয়াল ফিডব্যাক এটি দেবে না।

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > RetroArch_ নির্বাচন করে [RetroArch](https://www.retroarch.com/) ইনস্টল করুন। এটি libretro কোরের সম্পূর্ণ সেট নিয়ে আসে, তাই সব ক্লাসিক সিস্টেমই কভার করা হয়েছে।

সেই নিখুঁত রেট্রো লুকের জন্য RetroArch সুন্দর CRT Royale শেডার দিয়ে সম্পূর্ণ প্রিকনফিগার করা রয়েছে।

শুরু করতে:

1. আপনার BIOS ফাইলগুলো `~/Games/bios`-এ আর আপনার ROM-গুলো `~/Games/roms`-এ ফেলুন।
2. `Super + Space` দিয়ে RetroArch চালু করুন আর `retro` টাইপ করুন।
3. `~/Games/roms` ডিরেক্টরি স্ক্যান করুন আর আপনি খেলার জন্য প্রস্তুত।

আপনি _Install > Gaming > RetroArch Game Launcher_ দিয়ে একটি প্রিয় গেমকে অ্যাপ লঞ্চারে তার নিজস্ব এন্ট্রিও দিতে পারেন, যা আপনাকে একটি কোর আর একটি ROM বেছে নিতে দেয়, আর `Super + Space` থেকে সরাসরি গেমে ঝাঁপিয়ে পড়তে দেয়।

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Xbox Cloud Gaming_ নির্বাচন করে Xbox Cloud Gaming ওয়েব অ্যাপ ইনস্টল করুন। এটি সার্ভিসটির জন্য "শুধুই" একটি ওয়েব অ্যাপ, কিন্তু এটি দ্রুত শুরু হয় আর 1080p-তে দারুণ চলে।

আপনার যদি ইতিমধ্যে Xbox Game Pass থাকে, তবে এটি Fortnite আর অন্যান্য টাইটেল খেলার একটি শক্ত উপায় যা আপনি Linux-এ নেটিভভাবে চালাতে পারেন না।

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > NVIDIA GeForce NOW_ নির্বাচন করে ক্লাউড-গেমিং সার্ভিস [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) ইনস্টল করুন। যেসব টাইটেল Linux-এ নেটিভভাবে পাওয়া যায় না সেগুলো খেলার আরেকটি দারুণ উপায়।

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Minecraft_ নির্বাচন করে Minecraft ইনস্টল করুন।

Steam-এর মতোই, মনে রাখবেন যে লগ ইন করার বা শুরু করার পর পরবর্তী স্ক্রিন আসতে কিছুটা সময় লাগতে পারে, এবং আপনি অপেক্ষা করার সময় কোনো ফিডব্যাক পাবেন না।

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Xbox Controllers_ নির্বাচন করে Bluetooth Xbox কন্ট্রোলারের জন্য সাপোর্ট ইনস্টল করুন। Bluetooth (`Super + Ctrl + B`) দিয়ে কন্ট্রোলারগুলো পেয়ার করুন আর সেগুলো আপনার সব গেমে কাজ করবে। আপনি যদি শুধু USB-C কেবল দিয়ে আপনার কন্ট্রোলার হার্ডওয়্যার করেন তবে আপনার এটির দরকার নেই।

## Moonlight (PC থেকে গেম স্ট্রিমিং)

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Moonlight_ নির্বাচন করে [Moonlight ক্লায়েন্ট](https://github.com/moonlight-stream/moonlight-qt) ইনস্টল করুন, আর আপনি [Sunshine](https://app.lizardbyte.dev/Sunshine/) চালানো একটি Windows PC থেকে গেম স্ট্রিম করতে পারবেন।

আপনার Omarchy মেশিন আর রিমোট গেমিং PC দুটোই যদি হার্ডওয়্যার করা থাকে, তবে অভিজ্ঞতাটি লোকালি খেলার থেকে আলাদা করা যায় না। রেজোলিউশন নেটিভ পর্যন্ত বাড়িয়ে দিন, রিফ্রেশ 120Hz-এ সেট করুন, আর বিটরেট সর্বোচ্চ করুন — Linux-এ Fortnite-এর মতো প্রতিযোগিতামূলক শুটার খেলার এটাই সেরা উপায়।

আপনি `omarchy install service sunshine` চালিয়ে একটি Omarchy মেশিনকেও হোস্টে পরিণত করতে পারেন, যা Sunshine ইনস্টল করে আর আপনার LAN আর Tailscale-এর জন্য Moonlight স্ট্রিমিং পোর্ট খুলে দেয়।

## Battle.net

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Battle.net_ নির্বাচন করে [Battle.net](https://eu.shop.battle.net/en-us) ইনস্টল করুন। এটি আপনাকে Diablo, Starcraft, আর World of Warcraft-এর মতো টাইটেল দেয় GE-Proton-এর অধীনে চলা একটি স্ট্যান্ডঅ্যালোন ইনস্টল হিসেবে — কোনো Steam, Lutris, বা Heroic-এর দরকার নেই।

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows গেম)

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Lutris_ নির্বাচন করে [Lutris](https://lutris.net/) ইনস্টল করুন। যেসব স্টোরের ওপরে নিজস্ব ইনস্টলার নেই, যেমন EA আর Ubisoft Connect, সেখানকার Windows গেম খেলার উপায় হলো Lutris।

ইনস্টলেশনটা একটু ঝামেলাপূর্ণ আর মাঝে মাঝে মনে হয় কিছুই হচ্ছে না — শুধু ধৈর্য ধরুন, এটি ব্যাকগ্রাউন্ডে কাজ করছে।

## Heroic Launcher (Epic Games)

Omarchy মেনু (`Super + Space`) থেকে _Install > Gaming > Heroic (Epic Games)_ নির্বাচন করে [Heroic Launcher](https://heroicgameslauncher.com/) ইনস্টল করুন। Heroic আপনাকে Epic Games টাইটেল চালাতে দেয়, যেমন OddSparks, যেগুলো anti-cheat-এর ওপর নির্ভর করে না — আর GOG আর Amazon Prime Gaming-এর গেমও। দুঃখের বিষয়, তার মানে কোনো Fortnite নেই আর কোনো Rocket League নেই — Tim Sweeney Linux-এ না আসা পর্যন্ত, এটাই সবচেয়ে কাছাকাছি পাওয়া।

Lutris-এর মতোই, গেম ইনস্টল করার সময় এটি ধীর আর ঝামেলাপূর্ণ মনে হতে পারে। এটিকে সময় দিন।
