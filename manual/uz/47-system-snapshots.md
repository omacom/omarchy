# Tizim snapshotlari

Biz har bir Omarchy yangilanishida snapshotlarni avtomatik ravishda yaratamiz, lekin o'zingiz yaratmoqchi bo'lsangiz, `omarchy-snapshot create` dan foydalanishingiz mumkin.

Snapshotni yuklash va tiklash uchun uni Limine boot loader dan tanlaysiz. Yuklash menyusi odatiy holatda yashirin bo'ladi, shuning uchun uni chiqarish uchun Limine ishga tushishi bilanoq istalgan tugmani bosing.

O'sha ekrandan sana va versiyaga qarab yuklamoqchi bo'lgan snapshotni tanlang. Snapshot olingan paytdagi Omarchy versiyasini pastki chap burchakda ko'rishingiz mumkin.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Ichkariga kirganingizda, yuklanadigan snapshotda ekanligingiz haqida xabar beradigan bildirishnoma chiqadi va uni bossangiz, tiklash jarayoni boshlanadi. Muqobil ravishda, `omarchy-snapshot restore` dan foydalanishingiz mumkin.

 ![snapshots-restore](images/snapshots-restore.webp)

Bu sizning root fayl tizimingizni tiklaydi, lekin `/home` ni emas. Shuning uchun u buzilgan tizim yangilanishini orqaga qaytarish uchun ishlaydi, lekin yo'qolgan shaxsiy fayllarni tiklash uchun emas.

Bu shuningdek, `~/.config` katalogingiz o'z holicha qolishini anglatadi. Shuning uchun, agar siz konfiguratsiya fayllarini yangi formatda saqlaydigan kutubxona yoki dasturning eski versiyasiga qaytayotgan bo'lsangiz, buni qo'lda hal qilishingizga to'g'ri keladi.

Xuddi shu narsa qaysi migratsiyalar allaqachon ishga tushirilganligi haqidagi Omarchy ning o'z yozuviga ham tegishli: u sizning uy katalogingizda joylashgan, shuning uchun tiklashdan keyin ham saqlanib qoladi. Snapshot olingandan keyin ishga tushirilgan migratsiyalar bajarilgan deb belgilanganicha qoladi, garchi ular root fayl tizimiga kiritgan o'zgarishlar orqaga qaytarilgan bo'lsa ham, va keyingi `omarchy update` ularni qayta ishga tushirmaydi. Shuning uchun, agar tiklashdan keyin yana yangilasangiz va avvalgi yangilanish o'rnatgan narsa hali ham bo'lmasa, sababi katta ehtimol bilan shu.

_Eslatma: Bu xususiyat faqat Limine boot loader dan foydalanadigan o'rnatmalarda mavjud bo'lib, u Omarchy 2.0 dan beri standart hisoblanadi. Agar siz GRUB yoki systemd-boot da bo'lsangiz, u mavjud emas._
