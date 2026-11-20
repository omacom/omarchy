# Dual Boot usulida o‘rnatish

Omarchy ni Windows yoki boshqa o‘rnatilgan tizimlar yoniga bitta bo‘limga o‘rnatishingiz mumkin.

Bu o‘rnatish usuli ham bo‘lim uchun sukut bo‘yicha LUKS shifrlash bilan keladi, shuning uchun u amalda butun diskka o‘rnatishdan farq qilmaydi va shunchaki diskda bo‘sh joy mavjud bo‘lishini talab qiladi.

## Windows da joy ajratish

Windows yoniga o‘rnatish uchun boshlash menyusida `disk management` deb yozing va **Qattiq disk bo‘limlarini yaratish va formatlash** variantini tanlang.

 ![dual-boot-1](images/dual-boot-1.webp)

Kerakli bo‘limni toping, sichqonchaning o‘ng tugmasini bosing va **Hajmni qisqartirish** ni tanlang.

![dual-boot-2](images/dual-boot-2.webp)

 Hajmni qanchaga qisqartirmoqchi ekanligingizni kiriting. Eslatma: bu sizning kelajakdagi Omarchy o‘rnatishingizning hajmi bo‘ladi, yuklash bo‘limi ham shunga kiradi.

 ![dual-boot-3](images/dual-boot-3.webp)

Tugatganingizda, shunga o‘xshash ko‘rinishni ko‘rishingiz kerak, bu yerda 50GB bo‘lim ushbu misolda Omarchy ni o‘rnatadigan joyimiz hisoblanadi.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy ni o‘rnatish

Omarchy ni o‘rnatish jarayoni amalda odatdagisi bilan bir xil. Diskingizni tanlaganingizdan so‘ng, sizga **Bo‘sh joyga o‘rnatish** varianti beriladi. Butun diskni tozalab tashlamaslik uchun shu variantni tanlang.

 ![dual-boot-5](images/dual-boot-5.webp)

Hammasi yaxshi ekanligini tasdiqlang va o‘rnatish odatdagidek tugashini kuting. Bu yerda siz butun diskka o‘rnatishdagi kabi shifrlanmagan holda o‘rnatishni ham tanlashingiz mumkin (tavsiya etilmaydi).
 ![dual-boot-6](images/dual-boot-6.webp)

## Boshqa o‘rnatilgan tizimlarni yuklagichga qo‘shish

Omarchy ni o‘rnatib bo‘lganingizda, endi Limine yuklagichi sukut bo‘yicha ekanligini sezasiz. Buning bilan siz Limine ga Windows kabi boshqa o‘rnatilgan tizimlaringiz uchun variantlarni ham qo‘shishingiz mumkin.

Boshqa operatsion tizimlarni qo‘shish uchun `limine-scan` ni ishga tushiring va kerakli yozuvlarni Limine konfiguratsiyangizga qo‘shish uchun ko‘rsatmalarga amal qiling. Yuklash menyusi sukut bo‘yicha yashirin bo‘ladi va bir soniyadan so‘ng Omarchy ni ishga tushiradi. Windows ni yoki boshqa yozuvni tanlash uchun Limine ishga tushishi bilanoq istalgan tugmani bosing; menyu paydo bo‘lganda, yozuvni tanlash uchun strelka tugmalaridan foydalaning va Enter ni bosing. Agar tugmani bosishingizdan oldin Omarchy ishga tushib ketsa, qayta ishga tushiring va yana urinib ko‘ring.

## Bitlocker

Shuni ta’kidlash muhimki, bu o‘rnatish usuli Bitlocker bilan mos kelmaydi, chunki u butun diskni shifrlaydi, faqat bo‘limni emas. Agar Bitlocker yoqilganligi aytilgan xatoga duch kelsangiz, Windows ga yuklaning, **Sozlamalar -> Maxfiylik va xavfsizlik -> Qurilmani shifrlash** bo‘limiga o‘ting va Bitlocker ni o‘chiring. Diskni deshifrlash biroz vaqt olishi mumkin.

 ![dual-boot-7](images/dual-boot-7.webp)
