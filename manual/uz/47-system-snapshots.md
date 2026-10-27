# Tizim lavhalari

Biz har bir Omarchy yangilanishida avtomatik lavhalarni yaratamiz, ammo oʻzingizni yaratmoqchi boʻlsangiz, `omarchy-snapshot create` dan foydalanishingiz mumkin.

Lavhani yuklash va tiklash uchun uni Limine boot loader dan tanlaysz. (Agar siz hozir toʻgʻridan-toʻgʻri Omarchy shifrini ochish ekraniga yuklayotgan boʻlsangiz, avval BIOS orqali Limine ni yuklash varianti sifatida tanlashingiz kerak boʻladi).

Bu ekrandan, sana va versiya asosida yuklamoqchi boʻlgan lavhani tanlang. Lavha vaqtidagi Omarchy versiyasi pastki chap burchakda koʻrinadi.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Ichkariga yetib kelganda, bildirishnoma paydo boʻlib, siz yuklanishi mumkin lavhada ekanligingizni bildiradi va agar uni bossangiz, tiklash jarayonini boshlaydi. Shu bilan birga, siz `omarchy-snapshot restore` dan foydalanishingiz mumkin.

 ![snapshots-restore](images/snapshots-restore.webp)

Bu sizning ildiz fayl tizimingizni tiklaydi, lekin `/home` ingizni emas. Shuning uchun u buzilgan tizim yangilanishini qaytarish uchun ishlaydi, lekin yoʻqotilgan shaxsiy fayllarni tiklash uchun emas.

Bu shuningdek, sizning `~/.config` katalogingiz oʻzgarmay qolgani demakdir. Shunday qilib, agar siz konfiguratsiya fayllarini yangi formatda saqlaydigan kutubxona yoki ilovaning avvalgi versiyaga qaytsangiz, buni qoʻlda saralashingiz kerak boʻladi.

_Eslatma: Bu xususiyat faqat Limine boot loader dan foydalanadigan oʻrnatishlarida mavjud, bu Omarchy 2.0 dan beri standart. Agar siz GRUB yoki systemd-boot da boʻlsangiz, bu mavjud emas._

### Yuklash menyusini oʻtkazib yuborish

Agar yuklash menyusiga hech qachon tegmasangiz va mashina shunchaki shifrini ochish ekraniga toʻgʻri ketishini istasangiz, Omarchy menyusida _Sozlash > Toʻgʻridan-toʻgʻri yuklash_ ni ishga tushiring. Bu firmware Omarchy ni yuklash uchun Limine da toʻxtamasligi uchun toʻgʻridan-toʻgʻri Omarchy-ga ishora qiluvchi EFI yozuvini qoʻshadi.

Muqobili yuqorida aytib oʻtilgan: toʻgʻridan-toʻgʻri yuklash yoqilgan boʻlsa, lavhaga yetish avval BIOS yuklash menyusidan Limine ni tanlash demakdir. Yozuvni olib tashlash va Limine orqali yuklashga qaytish uchun _Sozlash > Toʻgʻridan-toʻgʻri yuklash_ ni yana ishga tushiring. Baʼzi firmware maxsus EFI yozuvlarini yaxshi qabul qilmaydi, shuning uchun sozlash American Megatrends va Apple firmware da ishlashdan bosh tortadi.
