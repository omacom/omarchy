# Gaming

Omarchy faqat _uNuMdOrLiK_ uchun emas, u ko'ngil ochish uchun ham, o'yindan ko'ra qiziqarliroq nima bor? Omarchy o'yin imkoniyatlarining butun to'plami bilan keladi — mahalliy va retro o'yinlar uchun Steam va RetroArch, Steam bo'lmagan do'konlar uchun Battle.net, Lutris va Heroic, PC strimingi uchun Moonlight, bulut uchun Xbox Cloud Gaming + NVIDIA GeForce NOW, shuningdek abadiy yashil Minecraft.

Valve'ning [proton moslik qatlami](https://en.wikipedia.org/wiki/Proton_(software)) ustidagi ajoyib ishi tufayli, hozir Linux'da o'ynasa bo'ladigan o'n minglab zamonaviy o'yinlar bor. Ha, aytgancha, [Steam Deck](https://store.steampowered.com/steamdeck/) aslida Arch'da ishlashini bilarmidingiz!

Barcha o'yin o'rnatuvchilari Omarchy menyusida (`Super + Space`) _Install > Gaming_ ostida joylashgan. Agar ulardan birini bekor qilmoqchi bo'lsangiz, _Remove > Gaming_ dan foydalaning.

## Steam

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Steam_ ni tanlab [Steam](https://store.steampowered.com/) ni o'rnating.

Uni o'rnatganingizdan so'ng, Steam'ni `Super + Space` bilan ishga tushira olasiz.

E'tibor bering, Steam ishga tushishi 10-20 soniya vaqt olishi mumkin va u yuklanayotgani haqida hech qanday vizual xabar bermaydi.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy menyusidan (`Super + Space`) _Install > Gaming > RetroArch_ ni tanlab [RetroArch](https://www.retroarch.com/) ni o'rnating. U libretro yadrolarining to'liq to'plami bilan keladi, shuning uchun barcha klassik tizimlar qamrab olingan.

RetroArch o'sha mukammal retro ko'rinish uchun chiroyli CRT Royale shaderi bilan to'liq oldindan sozlangan.

Boshlash uchun:

1. BIOS fayllaringizni `~/Games/bios` ga va ROM'laringizni `~/Games/roms` ga tashlang.
2. `Super + Space` bilan RetroArch'ni ishga tushiring va `retro` deb yozing.
3. `~/Games/roms` katalogini skanerlang va o'ynashga tayyorsiz.

Sevimli o'yinga ilovalarni ishga tushirgichda alohida yozuv ham berishingiz mumkin: _Install > Gaming > RetroArch Game Launcher_ yadro va ROM tanlash imkonini beradi va `Super + Space` dan to'g'ridan-to'g'ri o'yinga o'tkazadi.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Xbox Cloud Gaming_ ni tanlab Xbox Cloud Gaming veb-ilovasini o'rnating. Bu xizmat uchun "shunchaki" veb-ilova, lekin u tez ishga tushadi va 1080p da ajoyib ishlaydi.

Agar sizda allaqachon Xbox Game Pass bo'lsa, bu Fortnite va Linux'da mahalliy ishga tushirib bo'lmaydigan boshqa o'yinlarni o'ynashning ishonchli usuli.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy menyusidan (`Super + Space`) _Install > Gaming > NVIDIA GeForce NOW_ ni tanlab [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) bulutli o'yin xizmatini o'rnating. Linux'da mahalliy mavjud bo'lmagan o'yinlarni o'ynashning yana bir ajoyib usuli.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Minecraft_ ni tanlab Minecraft'ni o'rnating.

Steam kabi, e'tibor bering, tizimga kirgandan yoki ishga tushgandan keyin keyingi ekran paydo bo'lishi biroz vaqt olishi mumkin va kutayotganingizda hech qanday xabar olmaysiz.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox kontrollerlari

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Xbox Controllers_ ni tanlab Bluetooth Xbox kontrollerlarini qo'llab-quvvatlashni o'rnating. Kontrollerlarni Bluetooth (`Super + Ctrl + B`) orqali ulang va ular barcha o'yinlaringizda ishlaydi. Agar kontrolleringizni USB-C kabeli bilan to'g'ridan-to'g'ri ulayotgan bo'lsangiz, bu sizga kerak emas.

## Moonlight (PC dan o'yin strimingi)

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Moonlight_ ni tanlab [Moonlight client](https://github.com/moonlight-stream/moonlight-qt) ni o'rnating va siz [Sunshine](https://app.lizardbyte.dev/Sunshine/) ishlayotgan Windows PC dan o'yinlarni striming qilishingiz mumkin.

Agar Omarchy mashinangiz ham, uzoqdagi o'yin PC ham simli ulangan bo'lsa, tajriba mahalliy o'ynashdan farq qilmaydi. Tasvir o'lchamini mahalliy darajagacha ko'taring, yangilanish tezligini 120Hz ga qo'ying va bitrate'ni maksimal qiling — bu Linux'da Fortnite kabi musobaqali shooter'larni o'ynashning eng yaxshi usuli.

`omarchy install service sunshine` ni ishga tushirib Omarchy mashinasini host'ga ham aylantirishingiz mumkin, bu Sunshine'ni o'rnatadi va LAN va Tailscale uchun Moonlight striming portlarini ochadi.

## Battle.net

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Battle.net_ ni tanlab [Battle.net](https://eu.shop.battle.net/en-us) ni o'rnating. Bu sizga Diablo, Starcraft va World of Warcraft kabi o'yinlarni GE-Proton ostida ishlaydigan alohida o'rnatma sifatida beradi — Steam, Lutris yoki Heroic kerak emas.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows o'yinlari)

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Lutris_ ni tanlab [Lutris](https://lutris.net/) ni o'rnating. Lutris — yuqorida o'z o'rnatuvchisi bo'lmagan EA va Ubisoft Connect kabi do'konlardagi Windows o'yinlarini o'ynash usuli.

O'rnatish biroz noqulay va ba'zida hech narsa bo'lmayotgandek tuyuladi — shunchaki sabr qiling, u fonda ishlayapti.

## Heroic Launcher (Epic Games)

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Heroic (Epic Games)_ ni tanlab [Heroic Launcher](https://heroicgameslauncher.com/) ni o'rnating. Heroic sizga anti-cheat'ga tayanmaydigan OddSparks kabi Epic Games o'yinlarini — shuningdek GOG va Amazon Prime Gaming o'yinlarini ishga tushirish imkonini beradi. Afsuski, bu Fortnite ham yo'q, Rocket League ham yo'q degani — Tim Sweeney Linux'ga kelmaguncha, bundan yaqini bo'lmaydi.

Lutris kabi, u ham o'yinlarni o'rnatayotganda sekin va noqulay tuyulishi mumkin. Unga vaqt bering.
