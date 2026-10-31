# Muammolarni bartaraf etish

### Yangilanish bilan tizimimni buzib qo'ydim!

Avval [tizimingizni qaytarib ko'ring](47-system-snapshots.md) so'nggi yangilanishingizdan oldingi versiyaga. Agar bu ish bermasa, muammoingizni Discord'dagi #omarchy-help kanalida bo'lishish uchun `omarchy-debug` dan foydalaning. Va agar bularning barchasi ish bermasa, `omarchy-reinstall` yordamida standart konfiguratsiyalar va paketlarni qayta o'rnatishingiz mumkin.

### Nega ba'zi ilovalar displeyimda shunchalik katta?

Omarchy 2x yuqori aniqlikdagi displeyni nazarda tutadi, shuning uchun monitor panelida masshtabni tanlamaguningizcha `GDK_SCALE` ni 2 ga o'rnatadi. Agar siz 1x displeyda bo'lsangiz va GTK yoki X11 ilovalari juda katta chiqsa, monitor panelida u uchun 1x ni tanlang, yoki `~/.config/hypr/monitors.lua` ga `hl.env("GDK_SCALE", "1")` ni qo'shing (va keyin juda katta bo'lgan har qanday ilovani qayta ishga tushiring). Qarang: [monitorlar bo'yicha qo'llanma](33-monitors.md).

Spotify uchun UI ni kichraytirish uchun `Ctrl + Minus` dan foydalanishingiz mumkin (va kattalashtirish uchun `Ctrl + Plus` dan).

### Nega barcha Super tugma bog'lanishlarim ishlamay qoldi?

Ba'zi ASUS ROG va TUF noutbuklarida `Fn + Super` — bu proshivka darajasidagi Windows tugmasi qulfini yoqib-o'chiradigan, osongina ko'zdan qochiriladigan kombinatsiya (o'yin paytida tasodifan o'yindan chiqib ketmasligingiz uchun mo'ljallangan). Ekranda hech narsa bu sodir bo'lganini bildirmaydi. Qulf yoqilgan paytda Super umuman hech narsa chiqarmaydi — shuning uchun Super dan foydalanadigan har bir Omarchy bog'lanishi shunchaki to'xtaydi va Hyprland buzilgandek tuyuladi.

`~/.config/hypr/` ni kovlashdan oldin `Fn + Super` ni bir marta bosing, va agar bu Super ni qaytarmasa, qulfni yoqilgan holda qoldirmaslik uchun uni yana bosing. Bu Fn-lock emas, u faqat F-tugmalar qatori nima qilishini o'zgartiradi.

### Wi-Fi, Bluetooth, audio yoki trekpadim shunchaki ishlamay qoldi

Qayta yuklashdan oldin, aybdor quyi tizimni o'zini alohida qayta ishga tushirib ko'ring. Omarchy menyusidagi _Update > Hardware_ da Wi-Fi, Bluetooth, Audio va Trackpad bor, va ulardan birini qayta yuklash "besh daqiqa oldin ishlayotgandi" holatlarining aksariyatini hal qiladi — qayta ulanmayotgan Bluetooth garniturasi, uyqu rejimidan keyin o'lib qolgan trekpad, monitorni uzganingizda yo'qolib qolgan ovoz.

### Nega tashqi karnaylarim ovoz chiqarmayapti?

Ehtimol, ular asosiy chiqish sifatida o'rnatilmagan. Panelning o'ng tomonidagi karnay belgisini bosing, shunda ovoz balandligi qalqib chiquvchi oynasi ochiladi, u yerda chiqish qurilmasini tanlashingiz mumkin (va har bir ilova uchun ovoz balandligini alohida sozlashingiz ham mumkin).

### Noutbuk karnaylarim g'alati eshitilyapti

Ba'zi noutbuklarda Omarchy o'rnatilgan karnaylarning chastota javobini to'g'rilaydigan karnay sozlamasini avtomatik qo'llaydi. `omarchy audio tuning status` mashinangizda shunday sozlama faol yoki yo'qligini aytadi, va agar karnaylarni xom holida eshitishni afzal ko'rsangiz, `omarchy audio tuning off` uni o'chiradi.

### Nega parolim bilan kira olmayapman yoki sudo qila olmayapman?

Ehtimol, uni juda ko'p marta noto'g'ri terdingiz va bloklanib qoldingiz. Agar bu qulf ekranida sodir bo'layotgan bo'lsa, yangi TTY ni boshlash uchun `CTRL + ALT + F2` ni bosishingiz mumkin, u yerda root sifatida kirishingiz, so'ngra `faillock --reset --user [your-username]` ni ishga tushirishingiz mumkin. Bu bloklanishni tiklaydi va davom etishingiz mumkin.

### Nega 1Password SSH Agent / CLI uchun 1Password avtorizatsiya so'rovlarim paydo bo'lmayapti?

Bu 2 sababga ko'ra sodir bo'lishi mumkin:

Boy tasdiqlash so'rovi paydo bo'lishi uchun Settings > Advanced > Use Hardware Acceleration yoqilgan bo'lishi kerak. _Eslatma: Bu ishlay boshlashi uchun qayta yuklash talab qilinadi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Yoki agar yuklangandan beri 1Password ni ishga tushirmagan bo'lsangiz, so'rov paydo bo'lmaydi.
