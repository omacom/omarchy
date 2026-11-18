# Tizim snapshotlari

Biz har bir Omarchy yangilanishida snapshotlarni avtomatik ravishda yaratamiz, lekin o'zingiznikini yaratmoqchi bo'lsangiz, `omarchy-snapshot create` dan foydalanishingiz mumkin.

Snapshotni yuklash va tiklash uchun uni Limine boot loaderidan tanlaysiz. (Agar hozir to'g'ridan-to'g'ri Omarchy shifrini ochish ekraniga yuklanayotgan bo'lsangiz, avval BIOS orqali Limine ni yuklash varianti sifatida tanlashingiz kerak bo'ladi).

O'sha ekrandan sana va versiyaga qarab yuklamoqchi bo'lgan snapshotingizni tanlang. Snapshot olingan paytdagi Omarchy versiyasini pastki chap burchakda ko'rish mumkin.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Ichkariga kirganingizda, yuklanadigan snapshotda ekanligingiz haqida xabar beradigan bildirishnoma chiqadi va uni bossangiz, tiklash jarayoni boshlanadi. Muqobil ravishda, `omarchy-snapshot restore` dan foydalanishingiz mumkin.

 ![snapshots-restore](images/snapshots-restore.webp)

Bu sizning root fayl tizimingizni tiklaydi, lekin `/home` ni emas. Shunday qilib, u buzilgan tizim yangilanishini orqaga qaytarish uchun ishlaydi, lekin yo'qolgan shaxsiy fayllarni tiklash uchun emas.

Bu shuningdek, `~/.config` katalogingiz o'z holicha qolishini anglatadi. Shunday qilib, agar konfiguratsiya fayllarini yangi formatda saqlaydigan kutubxona yoki ilovaning oldingi versiyasiga qaytayotgan bo'lsangiz, buni qo'lda hal qilishingizga to'g'ri keladi.

Xuddi shu narsa qaysi migratsiyalar allaqachon ishga tushganligi haqidagi Omarchy ning o'z yozuviga ham tegishli: u sizning home katalogingizda joylashgan, shuning uchun tiklashdan keyin ham saqlanib qoladi. Snapshot olingandan keyin ishga tushgan migratsiyalar bajarilgan deb belgilangan holda qoladi, garchi ular root fayl tizimiga kiritgan o'zgarishlar orqaga qaytarilgan bo'lsa ham, va keyingi `omarchy update` ularni qayta ishga tushirmaydi. Shunday qilib, agar tiklashdan keyin yana yangilasangiz va oldingi yangilanish o'rnatgan biror narsa hali ham bo'lmasa, ehtimoliy sabab shudir.

_Eslatma: Bu xususiyat faqat Limine boot loaderidan foydalanadigan o'rnatishlarda mavjud bo'lib, u Omarchy 2.0 dan beri standart hisoblanadi. Agar siz GRUB yoki systemd-boot da bo'lsangiz, u mavjud emas._

### Yuklash menyusini o'tkazib yuborish

Agar yuklash menyusiga hech qachon tegmasangiz va mashina to'g'ridan-to'g'ri shifrni ochish ekraniga o'tishini istasangiz, Omarchy menyusida _Setup > Direct Boot_ ni ishga tushiring. Bu to'g'ridan-to'g'ri Omarchy ga ishora qiluvchi EFI yozuvini qo'shadi, shuning uchun firmware Limine da to'xtamasdan uni yuklaydi.

Muqobil zarari yuqorida tilga olinganidir: to'g'ridan-to'g'ri yuklash yoqilgan holda, snapshotga o'tish avval BIOS yuklash menyusidan Limine ni tanlashni anglatadi. Yozuvni olib tashlash va Limine orqali yuklashga qaytish uchun _Setup > Direct Boot_ ni yana ishga tushiring. Ba'zi firmwarelar maxsus EFI yozuvlarini yaxshi qabul qilmaydi, shuning uchun o'rnatish American Megatrends va Apple firmwarelarida ishlashdan bosh tortadi.
