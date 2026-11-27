# Tizim snapshotlari

Biz har bir Omarchy yangilanishida avtomatik ravishda snapshotlar yaratamiz, lekin o'zingiznikini yaratmoqchi bo'lsangiz, `omarchy-snapshot create` dan foydalanishingiz mumkin.

Snapshotni qanday yuklash va tiklashingiz mashinangiz qaysi boot loader bilan ishga tushishiga bog'liq. Yangi UEFI o'rnatmalari systemd-boot dan foydalanadi; eski o'rnatmalar va BIOS mashinalari Limine dan foydalanadi. `omarchy-boot-backend` sizda qaysi biri borligini aytadi.

## systemd-boot bilan

Omarchy menyusida _Tizim > Snapshotlar_ ni tanlang va yuklamoqchi bo'lgan snapshotni tanlang. Mashina bir marta uning ichiga qayta ishga tushadi. Yoki yuklash menyusini ko'rish uchun mashina ishga tushayotganda Space tugmasini bosib turing, u yerda har bir snapshot Omarchy versiyasi va sanasi bilan eng yangisi birinchi bo'lib ro'yxatga olingan.

Snapshot ustida vaqtinchalik qatlam bilan yuklanadi, shuning uchun undan odatdagidek foydalanishingiz mumkin, lekin qilgan har qanday o'zgarishingiz keyingi qayta yuklashda yo'qoladi. Uni saqlab qolish uchun uni tizimingizga aylantiring: tizimga kirganingizda chiqadigan bildirishnomani bosing, _Tizim > Snapshotlar > Ushbu snapshotni tiklash_ ni tanlang yoki `omarchy-snapshot restore` ni ishga tushiring. Tiklash mashina qayta ishga tushayotganda sodir bo'ladi. Avvalgi holatidagi tizim yuklash menyusida _Tiklashdan oldin_ sifatida qoladi va `omarchy-snapshot restore backup` uni qaytarib qo'yadi.

Terminaldan:

- `omarchy-snapshot list` yuklashingiz mumkin bo'lgan snapshotlarni ro'yxatga oladi;
- `omarchy-snapshot boot 12` bir marta 12-snapshot ichiga qayta ishga tushiradi;
- `omarchy-snapshot restore 12` keyingi qayta ishga tushirishda 12-snapshotni tizimga aylantiradi va `omarchy-snapshot restore --cancel` o'sha qayta ishga tushirishdan oldin fikringizni o'zgartiradi.

## Limine bilan

Snapshotni yuklash va tiklash uchun uni Limine boot loader dan tanlaysiz. Yuklash menyusi sukut bo'yicha yashirin qoladi, shuning uchun uni chiqarish uchun Limine ishga tushishi bilanoq istalgan tugmani bosing.

O'sha ekrandan sana va versiyaga qarab yuklamoqchi bo'lgan snapshotni tanlang. Snapshot paytidagi Omarchy versiyasini pastki chap burchakda ko'rish mumkin.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Ichkariga kirganingizda, yuklanadigan snapshot ichida ekaningizni bildiradigan bildirishnoma chiqadi va uni bossangiz, tiklash jarayonini boshlaydi. Muqobil ravishda `omarchy-snapshot restore` dan foydalanishingiz mumkin.

 ![snapshots-restore](images/snapshots-restore.webp)

## Tiklash nimalarni qamrab oladi

Tiklash ildiz fayl tizimingizni qaytaradi, lekin `/home` ingizni emas. Shuning uchun u buzilgan tizim yangilanishini orqaga qaytarish uchun ishlaydi, lekin yo'qolgan shaxsiy fayllarni tiklash uchun emas.

Bu shuningdek `~/.config` katalogingiz o'z holicha qolishini anglatadi. Shuning uchun konfiguratsiya fayllarini yangi formatda saqlaydigan kutubxona yoki ilovaning eski versiyasiga qaytayotgan bo'lsangiz, buni qo'lda hal qilishingizga to'g'ri keladi.

Xuddi shu narsa Omarchy ning qaysi migratsiyalar allaqachon bajarilgani haqidagi o'z yozuviga ham tegishli: u uy katalogingizda yashaydi, shuning uchun tiklashdan omon qoladi. Snapshot olinganidan keyin bajarilgan migratsiyalar, ildiz fayl tizimiga kiritgan o'zgarishlari orqaga qaytarilgan bo'lsa ham, bajarilgan deb belgilanganicha qoladi va keyingi `omarchy update` ularni yana bajarmaydi. Shuning uchun tiklashdan keyin yana yangilasangiz va oldingi yangilanish o'rnatgan narsa hali ham yo'q bo'lsa, sababi katta ehtimol bilan shu.
