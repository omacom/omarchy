# Ikki tizimlik o‘rnatish

Omarchy ni Windows yoki boshqa o‘rnatilgan tizimlar yoniga bitta bo‘limga o‘rnatishingiz mumkin.

Bu o‘rnatish usuli ham sukut bo‘yicha bo‘lim uchun LUKS shifrlash bilan keladi, shuning uchun u amalda to‘liq diskka o‘rnatishdan farq qilmaydi va shunchaki diskda bo‘sh joy bo‘lishini talab qiladi.

## Windows da joy bo‘shatish

Windows yoniga o‘rnatish uchun boshlash menyusiga `disk management` deb yozing va **Create and format hard disk partitions** variantini tanlang.

 ![dual-boot-1](images/dual-boot-1.webp)

Kerakli bo‘limni toping, sichqonchaning o‘ng tugmasini bosing va **Shrink Volume** ni tanlang.

![dual-boot-2](images/dual-boot-2.webp)

 Hajmni qancha qisqartirmoqchi bo‘lsangiz, o‘sha miqdorni kiriting. Eslatib o‘tamiz, bu yuklash bo‘limini ham o‘z ichiga olgan holda kelajakdagi Omarchy o‘rnatishingizning hajmi bo‘ladi.

 ![dual-boot-3](images/dual-boot-3.webp)

Tugatganingizda, shunga o‘xshash narsani ko‘rishingiz kerak, bunda 50GB lik bo‘lim ushbu misolda Omarchy ni o‘rnatadigan joyimiz bo‘ladi.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy ni o‘rnatish

Omarchy ni o‘rnatish jarayoni amalda odatdagidek bir xil. Diskingizni tanlaganingizdan so‘ng, sizga **Free space install** varianti taklif qilinadi. To‘liq diskni o‘chirib yubormaslik uchun o‘sha variantni tanlang.

 ![dual-boot-5](images/dual-boot-5.webp)

Hammasi to‘g‘ri ekanini tasdiqlang va odatdagidek o‘rnatish tugashini kuting. To‘liq diskka o‘rnatishda bo‘lgani kabi, aynan shu yerda shifrlanmagan holda o‘rnatishni ham tanlashingiz mumkin (tavsiya etilmaydi).
 ![dual-boot-6](images/dual-boot-6.webp)

## Boshqa o‘rnatilgan tizimlarni yuklagichga qo‘shish

Omarchy ni o‘rnatishni tugatganingizda, endi sukut bo‘yicha Limine yuklagichi turganini sezasiz. Uning yordamida Windows kabi boshqa o‘rnatilgan tizimlaringiz uchun ham Limine ga variantlar qo‘shishingiz mumkin.

Boshqa operatsion tizimlarni qo‘shish uchun `limine-scan` ni ishga tushiring va kerakli yozuvlarni Limine konfiguratsiyangizga qo‘shish bo‘yicha ko‘rsatmalarga amal qiling. Yuklash menyusi sukut bo‘yicha yashirin turadi va bir soniyadan so‘ng Omarchy ni ishga tushiradi. Windows yoki boshqa yozuvni tanlash uchun Limine ishga tushishi bilanoq istalgan tugmani bosing; menyu paydo bo‘lganda, yozuvni tanlash uchun strelka tugmalaridan foydalaning va Enter ni bosing. Agar tugmani bosishingizdan oldin Omarchy ishga tushib ketsa, qayta ishga tushiring va yana urinib ko‘ring.

## Bitlocker

Shuni ta’kidlash kerakki, bu o‘rnatish usuli Bitlocker bilan mos kelmaydi, chunki u faqat bo‘limni emas, balki butun diskni shifrlaydi. Agar Bitlocker yoqilganligi haqidagi xatoga duch kelsangiz, Windows ni yuklang, **Settings -> Privacy & Security -> Device encryption** bo‘limiga o‘ting va Bitlocker ni o‘chiring. Disk shifrini ochish biroz vaqt olishi mumkin.

 ![dual-boot-7](images/dual-boot-7.webp)

## Windows ni qayta o‘rnatish

Agar bu kompyuter Windows bilan birga kelgan bo‘lsa, uning mahsulot kaliti proshivkada saqlangan. Uni chiqarish uchun `omarchy windows key` ni ishga tushiring, shunda Windows ni bu mashinaga qachon qayta o‘rnatsangiz ham, uni yana faollashtirishingiz mumkin.
