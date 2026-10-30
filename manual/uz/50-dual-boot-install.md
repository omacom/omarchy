# Ikki tomonlama yuklash oʻrnatish

Siz Omarchy ni Windows yoki boshqa oʻrnatishlar yonida bitta boʻlimga oʻrnatishingiz mumkin.

Ushbu oʻrnatish usuli hali ham boʻlim uchun standart bilan LUKS shifrlashi bilan keladi, shuning uchun toʻliq drayvdan farqi yoʻq va shunchaki diskda boʻsh joy boʻlishini talab qiladi.

## Windows-da joy yaratish

Windows yonida oʻrnatish uchun boshlash menyusida `disk management` ni yozing va **Create and format hard disk partitions** variantini tanlang.

 ![dual-boot-1](images/dual-boot-1.webp)

Tegishli boʻlimni toping, oʻng tugmani bosing va **Shrink Volume** ni tanlang.

![dual-boot-2](images/dual-boot-2.webp)

 Hajmni kichiklashtirmoqchi boʻlgan miqdorni kiriting. Bu sizning kelajakdagi Omarchy oʻrnatishingizning oʻlchami boʻladi, yuklash boʻlimini oʻz ichiga oladi.

 ![dual-boot-3](images/dual-boot-3.webp)

Tugatganingizda, siz shunga oʻxshash narsani koʻrishingiz kerak, u yerda 50GB boʻlim biz ushbu misolda Omarchy ni oʻrnatadigan joy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy ni oʻrnatish

Omarchy uchun oʻrnatish jarayoni oddiyga amalda bir xil. Diskingizni tanlaganingizdan soʻng, sizga **Free space install** varianti beriladi. Butun diskni tozalashning oldini olish uchun shu variantni tanlang.

 ![dual-boot-5](images/dual-boot-5.webp)

Hammasi yaxshi koʻrinishini tasdiqlang va oʻrnatish odatdagidek tugashini kuding. Bu shuningdek shifrlanmagan oʻrnatishni tanlashingiz mumkin boʻlgan joy (tavsiya etilmaydi), xuddi toʻliq drayv oʻrnatishidagi kabi.
 ![dual-boot-6](images/dual-boot-6.webp)

## Bootloaderga boshqa oʻrnatishlarni qoʻshish

Omarchy oʻrnatishingizni tugatganingizda, Limine bootloaderi hozir standart ekanini sezasiz. Bunga Windows kabi boshqa oʻrnatishlaringiz uchun Limine ga variantlarni ham qoʻsha olasiz.

Buni qilish uchun `limine-scan` ni ishga tushiring va limine konfiguratsiyangizga qoʻshishni istagan elementlarni qoʻshish uchun koʻrsatmalarga amal qiling. Keyin yuklaganda, Omarchy uchun odatdagi variantlaringizni, shuningdek Windows Boot Manager yoki boshqalarni koʻrasiz.

## Bitlocker

Shunisi muhimki, ushbu oʻrnatish usuli Bitlocker bilan mos kelmaydi, chunki u butun drayvni shifrlaydi, shunchaki boʻlimni emas. Agar Bitlocker yoqilganligi aytilgan xatoga duch kelsangiz, Windows ga yuklang, **Settings -> Privacy & Security -> Device encryption** ga oʻting va Bitlocker ni oʻchiring. Drayvni shifrlashni yechish biroz vaqt olishi mumkin.

 ![dual-boot-7](images/dual-boot-7.webp)
