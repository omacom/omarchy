# Dual Boot o'rnatish

Omarchy'ni Windows yoki boshqa o'rnatmalar yoniga bitta bo'limga o'rnatishingiz mumkin.

Bu o'rnatish usuli ham sukut bo'yicha bo'lim uchun LUKS shifrlashi bilan keladi, shuning uchun u aslida to'liq diskka o'rnatishdan hech qanday farq qilmaydi va shunchaki diskda bo'sh joy mavjud bo'lishini talab qiladi.

## Windows'da joy ajratish

Windows yoniga o'rnatish uchun boshlash menyusida `disk management` deb yozing va **Create and format hard disk partitions** variantini tanlang.

 ![dual-boot-1](images/dual-boot-1.webp)

Tegishli bo'limni toping, ustiga o'ng tugmani bosing va **Shrink Volume** bandini tanlang.

![dual-boot-2](images/dual-boot-2.webp)

 Hajmni qancha qisqartirmoqchi bo'lsangiz, o'sha miqdorni kiriting. Shuni yodda tutingki, bu kelajakdagi Omarchy o'rnatmangizning yuklash bo'limini ham o'z ichiga olgan hajmi bo'ladi.

 ![dual-boot-3](images/dual-boot-3.webp)

Tugatganingizda, taxminan shunday ko'rinishni ko'rishingiz kerak, bunda 50GB li qism ushbu misolda Omarchy'ni o'rnatadigan joyimizdir.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy'ni o'rnatish

Omarchy'ni o'rnatish jarayoni aslida odatdagidan farq qilmaydi. Diskingizni tanlaganingizdan so'ng, sizga **Free space install** varianti taklif qilinadi. To'liq disk o'chib ketishining oldini olish uchun o'sha variantni tanlang.

 ![dual-boot-5](images/dual-boot-5.webp)

Hammasi to'g'ri ekanini tasdiqlang va odatdagidek o'rnatish tugashini kuting. Aynan shu yerda, to'liq diskka o'rnatishdagi kabi, shifrlanmagan holda o'rnatishni ham tanlashingiz mumkin (tavsiya etilmaydi).
 ![dual-boot-6](images/dual-boot-6.webp)

## Boshqa o'rnatmalarni yuklovchiga qo'shish

Omarchy o'rnatishini tugatganingizda, endi Limine yuklovchisi sukut bo'yicha ekanini ko'rasiz. U bilan Windows kabi boshqa o'rnatmalaringiz uchun ham Limine'ga variantlar qo'shishingiz mumkin.

Boshqa operatsion tizimlarni qo'shish uchun `limine-scan` buyrug'ini ishga tushiring va kerakli yozuvlarni Limine konfiguratsiyangizga qo'shish uchun ko'rsatmalarga amal qiling. Yuklash menyusi sukut bo'yicha yashirin qoladi va bir soniyadan so'ng Omarchy'ni ishga tushiradi. Windows yoki boshqa yozuvni tanlash uchun Limine ishga tushishi bilanoq istalgan tugmani bosing; menyu paydo bo'lganda, yozuvni tanlash uchun strelka tugmalaridan foydalaning va Enter tugmasini bosing. Agar tugmani bosishingizdan oldin Omarchy ishga tushib ketsa, qayta ishga tushiring va yana urinib ko'ring. Agar _Setup > Direct Boot_ ni yoqqan bo'lsangiz, proshivka Limine'ni butunlay o'tkazib yuboradi, shuning uchun BIOS yuklash menyusidan Limine'ni tanlang yoki yozuvni olib tashlash uchun _Setup > Direct Boot_ ni yana ishga tushiring.

## Bitlocker

Shuni ta'kidlash kerakki, bu o'rnatish usuli Bitlocker bilan mos kelmaydi, chunki u faqat bo'limni emas, balki butun diskni shifrlaydi. Agar Bitlocker yoqilganligi aytilgan xatoga duch kelsangiz, Windows'ga yuklaning, **Settings -> Privacy & Security -> Device encryption** bo'limiga o'ting va Bitlocker'ni o'chiring. Diskning shifrini yechish biroz vaqt olishi mumkin.

 ![dual-boot-7](images/dual-boot-7.webp)
