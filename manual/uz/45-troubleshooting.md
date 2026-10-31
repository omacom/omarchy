# Muammolarni bartaraf etish

### Yangilash bilan tizimimni buzib qo‘ydim!

Avval so‘nggi yangilashingizdan oldingi versiyaga [tizimingizni orqaga qaytarishga](47-system-snapshots.md) harakat qiling. Agar bu ish bermasa, Discord’dagi #omarchy-help kanalida muammoingiz haqida ma’lumot berish uchun `omarchy-debug` dan foydalaning. Agar bularning barchasi ham yordam bermasa, `omarchy-reinstall` yordamida standart konfiguratsiyalar va paketlarni qayta o‘rnatishingiz mumkin.

### Nima uchun ba’zi ilovalar displeyimda bunchalik katta ko‘rinadi?

Omarchy 2x yuqori aniqlikdagi displeyni nazarda tutadi, bu `~/.config/hypr/monitors.lua` da `GDK_SCALE` ni 2 qilib belgilashni talab qiladi. Ammo agar siz 1x displeyda bo‘lsangiz, `local omarchy_gdk_scale = 2` ni 1 ga o‘zgartirishingiz mumkin (so‘ngra haddan tashqari katta bo‘lgan har qanday ilovani qayta ishga tushiring). [Monitorlar bo‘yicha qo‘llanmaga](33-monitors.md) qarang.

Spotify uchun UI ni kichraytirish uchun `Ctrl + Minus` dan (kattalashtirish uchun esa `Ctrl + Plus` dan) foydalanishingiz mumkin.

### Nima uchun barcha Super tugmasi bog‘lamlarim ishlamay qoldi?

Ba’zi ASUS ROG va TUF noutbuklarida `Fn + Super` — bu osonlikcha ko‘zdan qochiriladigan kombinatsiya bo‘lib, Windows tugmasini blokirovka qiluvchi proshivka funksiyasini almashlab yoqib-o‘chiradi (tasodifan o‘yindan chiqib ketmasligingiz uchun o‘yin uchun mo‘ljallangan). Ekranda bu sodir bo‘lgani haqida hech narsa ko‘rsatilmaydi. Blokirovka yoqilgan vaqtda Super umuman hech narsa chiqarmaydi — shuning uchun Super dan foydalanadigan har bir Omarchy bog‘lami shunchaki to‘xtaydi va Hyprland buzilgandek tuyuladi.

`~/.config/hypr/` ni kovlashga kirishishdan oldin `Fn + Super` ni bir marta bosing, agar bu Super ni qaytarmasa, blokirovkani yoqilgan holda qoldirmaslik uchun uni yana bir marta bosing. Bu Fn-lock emas, u faqat F tugmalar qatori bajaradigan ishni o‘zgartiradi.

### Wi-Fi, Bluetooth, audio yoki trekpadim shunchaki ishlamay qoldi

Qayta yuklashdan oldin, muammoli quyi tizimning o‘zini alohida qayta ishga tushirib ko‘ring. Omarchy menyusidagi _Update > Hardware_ da Wi-Fi, Bluetooth, Audio va Trackpad bor, va ulardan birini qayta yuklash “besh daqiqa oldin ishlayotgan edi” holatlarining aksariyatini bartaraf etadi — qayta ulanmayotgan Bluetooth garniturasi, uyqu rejimidan keyin o‘lib qolgan trekpad, monitorni uzganingizda yo‘qolgan ovoz.

### Nima uchun tashqi karnaylarim ovoz chiqarmayapti?

Ehtimol, ular asosiy chiqish sifatida belgilanmagan. Panelning o‘ng tomonidagi karnay belgisini bosing, shunda ovoz balandligi qalqib chiquvchi oynasi ochiladi, u yerda chiqish qurilmasini tanlashingiz mumkin (har bir ilova uchun ovoz balandligini alohida aralashtirish ham mumkin).

### Noutbukim karnaylari g‘alati eshitiladi

Ba’zi noutbuklarda Omarchy avtomatik ravishda o‘rnatilgan karnaylarning chastota javobini tuzatadigan karnay sozlamasini qo‘llaydi. `omarchy audio tuning status` mashinangizda shunday sozlama faol ekanini aytib beradi, `omarchy audio tuning off` esa karnaylarni xom holicha eshitishni afzal ko‘rsangiz, uni o‘chiradi.

### Nima uchun parolim bilan kira olmayman yoki sudo qila olmayman?

Ehtimol, uni juda ko‘p marta noto‘g‘ri kiritgansiz va bloklanib qolgansiz. Agar bu blokirovka ekranida sodir bo‘layotgan bo‘lsa, yangi TTY ni boshlash uchun `CTRL + ALT + F2` ni bosishingiz mumkin, u yerda root sifatida kirib, so‘ngra `faillock --reset --user [your-username]` ni ishga tushirishingiz mumkin. Bu blokirovkani bekor qiladi va siz davom etishingiz mumkin.

### Nima uchun 1Password SSH Agent / CLI uchun 1Password avtorizatsiya so‘rovlarim paydo bo‘lmayapti?

Bu 2 ta sababga ko‘ra sodir bo‘lishi mumkin:

Boy tasdiqlash so‘rovi paydo bo‘lishi uchun Settings > Advanced > Use Hardware Acceleration yoqilgan bo‘lishi kerak. _Eslatma: Bu ishlay boshlashi uchun qayta yuklash talab etiladi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Yoki agar siz tizim yuklanganidan beri 1Password ni ishga tushirmagan bo‘lsangiz, so‘rov paydo bo‘lmaydi.
