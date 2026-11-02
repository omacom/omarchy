# গেমিং

Omarchy শুধু _উৎপাদনশীলতার_ জন্যই নয়, এটি মজা করার জন্যও, আর গেমিংয়ের চেয়ে বেশি মজার আর কী আছে? Omarchy গেমিং বিকল্পের একটি পুরো গুচ্ছ সহ আসে — নেটিভ ও রেট্রো খেলার জন্য Steam এবং RetroArch, non-Steam স্টোরের জন্য Battle.net, Lutris এবং Heroic, PC স্ট্রিমিংয়ের জন্য Moonlight, ক্লাউডের জন্য Xbox Cloud Gaming + NVIDIA GeForce NOW, সেই সঙ্গে চিরসবুজ Minecraft।

Valve-এর [proton কম্প্যাটিবিলিটি লেয়ারের](https://en.wikipedia.org/wiki/Proton_(software)) উপর অবিশ্বাস্য কাজের জন্য ধন্যবাদ, এখন Linux-এ হাজার হাজার খেলারযোগ্য আধুনিক গেম আছে। ওহ, আর আপনি কি জানতেন যে [Steam Deck](https://store.steampowered.com/steamdeck/) আসলে Arch চালায়!

সব গেমিং ইনস্টলার Omarchy মেনুতে (`Super + Space`) _ইনস্টল > Gaming_-এর অধীনে থাকে। আপনি কখনও কোনোটি ফিরিয়ে নিতে চাইলে, _সরান > Gaming_ ব্যবহার করুন।

## Steam

Omarchy মেনু (`Super + Space`) থেকে _ইনস্টল > Gaming > Steam_ বেছে [Steam](https://store.steampowered.com/) ইনস্টল করুন।

আপনি এটি ইনস্টল করার পর, আপনি `Super + Space` দিয়ে Steam চালাতে পারবেন।

লক্ষ করুন, Steam শুরু হতে 10-20 সেকেন্ড লাগতে পারে, এবং এটি লোড হচ্ছে বলে কোনো দৃশ্যমান প্রতিক্রিয়া দেবে না।

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy মেনু (`Super + Space`) থেকে _ইনস্টল > Gaming > RetroArch_ বেছে [RetroArch](https://www.retroarch.com/) ইনস্টল করুন। এটি libretro কোরের পুরো সেটসহ আসে, ফলে সব ক্লাসিক সিস্টেমই কভার হয়।

RetroArch সেই নিখুঁত রেট্রো চেহারার জন্য সুন্দর CRT Royale শেডার দিয়ে সম্পূর্ণভাবে আগে থেকে কনফিগার করা আছে।

শুরু করতে:

1. আপনার BIOS ফাইলগুলো `~/Games/bios`-এ এবং আপনার ROM-গুলো `~/Games/roms`-এ রাখুন।
2. `Super + Space` দিয়ে RetroArch চালান এবং `retro` টাইপ করুন।
3. `~/Games/roms` ডিরেক্টরি স্ক্যান করুন আর আপনি খেলতে প্রস্তুত।

আপনি _ইনস্টল > Gaming > RetroArch Game Launcher_ দিয়ে কোনো পছন্দের গেমকে অ্যাপ লঞ্চারে তার নিজের এন্ট্রিও দিতে পারেন, যা আপনাকে একটি কোর ও একটি ROM বাছতে দেয়, এবং `Super + Space` থেকে সরাসরি গেমে যেতে দেয়।

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy মেনু (`Super + Space`) থেকে _ইনস্টল > Gaming > Xbox Cloud Gaming_ বেছে Xbox Cloud Gaming ওয়েব অ্যাপটি ইনস্টল করুন। এটি পরিষেবাটির জন্য "শুধু" একটি ওয়েব অ্যাপ, তবে এটি দ্রুত শুরু হয় এবং 1080p-তে দারুণভাবে চলে।

আপনার যদি ইতিমধ্যেই Xbox Game Pass থাকে, তাহলে Fortnite এবং অন্যান্য গেম যেগুলো আপনি Linux-এ নেটিভভাবে চালাতে পারবেন না, সেগুলো খেলার এটি একটি শক্ত উপায়।

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy মেনু (`Super + Space`) থেকে _ইনস্টল > Gaming > NVIDIA GeForce NOW_ বেছে ক্লাউড-গেমিং পরিষেবা [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) ইনস্টল করুন। Linux-এ নেটিভভাবে পাওয়া যায় না এমন গেম খেলার আরেকটি দারুণ উপায়।

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy মেনু (`Super + Space`) থেকে _ইনস্টল > Gaming > Minecraft_ বেছে Minecraft ইনস্টল করুন।

Steam-এর মতো, লক্ষ করুন, লগ ইন করা বা শুরু করার পর পরের স্ক্রিনটি আসতে কিছুটা সময় লাগতে পারে, এবং আপনি অপেক্ষা করার সময় কোনো প্রতিক্রিয়া পাবেন না।

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy মেনু (`Super + Space`) থেকে _ইনস্টল > Gaming > Xbox Controllers_ বেছে Bluetooth Xbox কন্ট্রোলারের জন্য সমর্থন ইনস্টল করুন। Bluetooth-এর মাধ্যমে (`Super + Ctrl + B`) কন্ট্রোলারগুলো পেয়ার করুন আর তারা আপনার সব গেমে কাজ করবে। আপনি যদি শুধু USB-C কেবল দিয়ে আপনার কন্ট্রোলারটি তার দিয়ে যুক্ত করেন, তাহলে আপনার এটির প্রয়োজন নেই।

## Moonlight (একটি PC থেকে গেম স্ট্রিমিং)

[Moonlight ক্লায়েন্ট](https://github.com/moonlight-stream/moonlight-qt) Omarchy-এর সঙ্গে আগে থেকেই ইনস্টল করা থাকে, ফলে আপনি [Sunshine](https://app.lizardbyte.dev/Sunshine/) চলা একটি Windows PC থেকে এখনই গেম স্ট্রিম করতে পারেন। `Super + Space`-এর মাধ্যমে Moonlight চালান।

আপনার Omarchy মেশিন এবং দূরবর্তী গেমিং PC দুটোই তার দিয়ে যুক্ত থাকলে, সেই অভিজ্ঞতা স্থানীয়ভাবে খেলার থেকে আলাদা করা যায় না। রেজোলিউশন নেটিভ পর্যন্ত বাড়ান, রিফ্রেশ 120Hz-এ সেট করুন এবং বিটরেট সর্বোচ্চ করুন — Linux-এ Fortnite-এর মতো প্রতিযোগিতামূলক শুটার খেলার এটি সেরা উপায়।

আপনি `omarchy install service sunshine` চালিয়ে একটি Omarchy মেশিনকে হোস্টও বানাতে পারেন, যা Sunshine ইনস্টল করে এবং আপনার LAN ও Tailscale-এর জন্য Moonlight স্ট্রিমিং পোর্টগুলো খুলে দেয়।

## Battle.net

Omarchy মেনু (`Super + Space`) থেকে _ইনস্টল > Gaming > Battle.net_ বেছে [Battle.net](https://eu.shop.battle.net/en-us) ইনস্টল করুন। এটি আপনাকে Diablo, Starcraft এবং World of Warcraft-এর মতো গেম GE-Proton-এর অধীনে চলা একটি স্বতন্ত্র ইনস্টল হিসেবে দেয় — কোনো Steam, Lutris বা Heroic-এর প্রয়োজন নেই।

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows গেম)

Omarchy মেনু (`Super + Space`) থেকে _ইনস্টল > Gaming > Lutris_ বেছে [Lutris](https://lutris.net/) ইনস্টল করুন। Lutris হলো EA এবং Ubisoft Connect-এর মতো স্টোরের Windows গেম খেলার উপায় যাদের উপরে নিজস্ব কোনো ইনস্টলার নেই।

ইনস্টলটি একটু অগোছালো এবং মাঝে মাঝে মনে হয় কিছুই হচ্ছে না — শুধু ধৈর্য ধরুন, এটি পটভূমিতে কাজ করছে।

## Heroic Launcher (Epic Games)

Omarchy মেনু (`Super + Space`) থেকে _ইনস্টল > Gaming > Heroic (Epic Games)_ বেছে [Heroic Launcher](https://heroicgameslauncher.com/) ইনস্টল করুন। Heroic আপনাকে OddSparks-এর মতো Epic Games গেম চালাতে দেয় যেগুলো anti-cheat-এর উপর নির্ভর করে না — সেই সঙ্গে GOG এবং Amazon Prime Gaming-এর গেমও। দুঃখের বিষয়, এর মানে হলো কোনো Fortnite এবং কোনো Rocket League নেই — Tim Sweeney Linux-এ না আসা পর্যন্ত, এটাই সবচেয়ে কাছাকাছি যাওয়া যায়।

Lutris-এর মতো, গেম ইনস্টলের সময় এটি ধীর ও অগোছালো অনুভূত হতে পারে। এটিকে সময় দিন।
