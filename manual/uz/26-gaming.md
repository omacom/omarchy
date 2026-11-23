# O'yinlar

Omarchy faqat _uNuMdOrLiK_ uchun emas, u ko'ngil ochish uchun ham, o'yindan ko'ra qiziqarliroq nima bo'lishi mumkin? Omarchy o'yinlar uchun butun boshli imkoniyatlar to'plami bilan keladi — Steam va RetroArch mahalliy va retro o'yinlar uchun, Battle.net, Lutris va Heroic Steam bo'lmagan do'konlar uchun, Moonlight PC strimingi uchun, Xbox Cloud Gaming + NVIDIA GeForce NOW bulut uchun, shuningdek abadiy klassika Minecraft.

Valve'ning [proton moslik qatlami](https://en.wikipedia.org/wiki/Proton_(software)) ustidagi ajoyib ishi tufayli, hozir Linuxda o'ynasa bo'ladigan o'n minglab zamonaviy o'yinlar mavjud. Oh, bilarmidingiz, [Steam Deck](https://store.steampowered.com/steamdeck/) aslida Arch'da ishlaydi!

Barcha o'yin o'rnatuvchilari Omarchy menyusidagi (`Super + Space`) _Install > Gaming_ ostida joylashgan. Agar birortasini bekor qilmoqchi bo'lsangiz, _Remove > Gaming_ dan foydalaning. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris va Heroic faqat x86 mashinalarida taklif etiladi.

## Steam

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Steam_ ni tanlab [Steam](https://store.steampowered.com/) ni o'rnating.

Uni o'rnatganingizdan keyin Steam'ni `Super + Space` bilan ishga tushira olasiz.

E'tibor bering, Steam ishga tushishi uchun 10-20 soniya vaqt ketishi mumkin va u yuklanayotganda hech qanday vizual bildirish bermaydi.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Omarchy menyusidan (`Super + Space`) _Install > Gaming > RetroArch_ ni tanlab [RetroArch](https://www.retroarch.com/) ni o'rnating. U libretro yadrolarining to'liq to'plami bilan keladi, shuning uchun barcha klassik tizimlar qamrab olingan.

RetroArch o'sha mukammal retro ko'rinish uchun chiroyli CRT Royale shaderi bilan to'liq oldindan sozlangan.

Boshlash uchun:

1. BIOS fayllaringizni `~/Games/bios` ga, ROM'laringizni esa `~/Games/roms` ga tashlang.
2. `Super + Space` bilan RetroArch'ni ishga tushiring va `retro` deb yozing.
3. `~/Games/roms` katalogini skanerlang va o'ynashga tayyorsiz.

Sevimli o'yiningizga ilova ishga tushirgichida o'z yozuvini ham berishingiz mumkin: _Install > Gaming > RetroArch Game Launcher_ yadro va ROM tanlash hamda `Super + Space` dan to'g'ridan-to'g'ri o'yinga sakrash imkonini beradi.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Xbox Cloud Gaming_ ni tanlab Xbox Cloud Gaming veb-ilovasini o'rnating. Bu xizmat uchun "shunchaki" veb-ilova, lekin u tez ishga tushadi va 1080p da ajoyib ishlaydi.

Agar sizda allaqachon Xbox Game Pass bo'lsa, bu Fortnite va Linuxda mahalliy ishga tushirib bo'lmaydigan boshqa o'yinlarni o'ynashning puxta usuli.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Omarchy menyusidan (`Super + Space`) _Install > Gaming > NVIDIA GeForce NOW_ ni tanlab bulutli o'yin xizmati [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) ni o'rnating. Linuxda mahalliy mavjud bo'lmagan o'yinlarni o'ynashning yana bir ajoyib usuli.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Minecraft_ ni tanlab Minecraft'ni o'rnating.

Steam kabi, e'tibor bering, tizimga kirgandan yoki ishga tushgandan keyin keyingi ekran paydo bo'lishi uchun biroz vaqt ketishi mumkin va siz kutayotganingizda hech qanday bildirish olmaysiz.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Xbox Controllers_ ni tanlab Bluetooth Xbox kontrollerlari uchun qo'llab-quvvatlashni o'rnating. Kontrollerlarni Bluetooth (`Super + Ctrl + B`) orqali ulang va ular barcha o'yinlaringizda ishlaydi. Agar kontrolleringizni USB-C kabeli bilan shunchaki simli ulayotgan bo'lsangiz, sizga bu kerak emas.

## Moonlight (PC dan o'yin strimingi)

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Moonlight_ ni tanlab [Moonlight client](https://github.com/moonlight-stream/moonlight-qt) ni o'rnating, shunda [Sunshine](https://app.lizardbyte.dev/Sunshine/) ishlayotgan Windows PC dan o'yinlarni strim qila olasiz.

Agar Omarchy mashinangiz ham, masofaviy o'yin PC ham simli ulangan bo'lsa, tajriba mahalliy o'ynashdan farq qilmaydi. O'lchamni mahalliy darajagacha ko'taring, yangilanish chastotasini 120Hz ga sozlang va bitreytni maksimumga chiqaring — bu Linuxda Fortnite kabi raqobatbardosh otishma o'yinlarini o'ynashning eng yaxshi usuli.

`omarchy install service sunshine` ni ishga tushirib Omarchy mashinasini hostga ham aylantirishingiz mumkin, bu Sunshine'ni o'rnatadi va LAN hamda Tailscale'ingiz uchun Moonlight striming portlarini ochadi.

## Battle.net

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Battle.net_ ni tanlab [Battle.net](https://eu.shop.battle.net/en-us) ni o'rnating. Bu sizga Diablo, Starcraft va World of Warcraft kabi o'yinlarni GE-Proton ostida ishlaydigan alohida o'rnatma sifatida beradi — Steam, Lutris yoki Heroic kerak emas.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows o'yinlari)

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Lutris_ ni tanlab [Lutris](https://lutris.net/) ni o'rnating. Lutris — bu yuqorida o'z o'rnatuvchisi bo'lmagan EA va Ubisoft Connect kabi do'konlardan Windows o'yinlarini o'ynash usuli.

O'rnatish biroz g'alati kechadi va ba'zida hech narsa bo'lmayotgandek ko'rinadi — shunchaki sabr qiling, u fonda ishlayapti.

## Heroic Launcher (Epic Games)

Omarchy menyusidan (`Super + Space`) _Install > Gaming > Heroic (Epic Games)_ ni tanlab [Heroic Launcher](https://heroicgameslauncher.com/) ni o'rnating. Heroic sizga anti-cheat'ga tayanmaydigan OddSparks kabi Epic Games o'yinlarini — shuningdek GOG va Amazon Prime Gaming o'yinlarini ishga tushirish imkonini beradi. Afsuski, bu Fortnite ham, Rocket League ham yo'q degani — Tim Sweeney Linuxga kelguniga qadar, erishish mumkin bo'lgani shugina.

Lutris kabi, o'yinlarni o'rnatayotganda u sekin va g'alati tuyulishi mumkin. Unga vaqt bering.
