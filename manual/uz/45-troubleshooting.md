# Muammolarni bartaraf etish

### Yangilanish bilan tizimimni buzib qo‘ydim!

Avval [tizimingizni qayta tiklashga](47-system-snapshots.md) harakat qilib ko‘ring — yaqinda o‘rnatgan yangilanishingizdan oldingi versiyaga. Agar bu yordam bermasa, `omarchy-debug` yordamida muammoingizni Discord dagi #omarchy-help kanalida ulashing. Agar bularning hech biri ish bermasa, `omarchy-reinstall` yordamida standart sozlamalar va paketlarni qayta o‘rnatishingiz mumkin.

### Nega ba’zi ilovalar displeyimda bunchalik katta ko‘rinadi?

Omarchy 2x yuqori aniqlikdagi displeyni nazarda tutadi, shuning uchun monitor panelida masshtabni tanlamaguningizcha `GDK_SCALE` ni 2 qilib belgilaydi. Agar siz 1x displeyda bo‘lsangiz va GTK yoki X11 ilovalari haddan tashqari katta chiqsa, monitor panelida u uchun 1x ni tanlang yoki `~/.config/hypr/monitors.lua` ga `hl.env("GDK_SCALE", "1")` ni qo‘shing (so‘ngra o‘lchami katta bo‘lib qolgan barcha ilovani qayta ishga tushiring). [Monitorlar bo‘yicha qo‘llanmaga](33-monitors.md) qarang.

Spotify uchun interfeysni kichraytirish maqsadida `Ctrl + Minus` dan foydalanishingiz mumkin (kattalashtirish uchun esa `Ctrl + Plus` dan).

### Nega barcha Super tugmasi bog‘lamlarim ishlamay qoldi?

Ba’zi ASUS ROG va TUF laptoplarida `Fn + Super` — sezilishi qiyin bo‘lgan chord bo‘lib, u mikrodasturdagi Windows tugmasi qulfini almashtirib qo‘yadi (bu o‘yin uchun mo‘ljallangan, tasodifan o‘yinni tark etib qo‘ymasligingiz uchun). Ekranda hech narsa bu sodir bo‘lganini bildirmaydi. Qulf yoqilgan paytda Super umuman hech narsa chiqarmaydi — shuning uchun Super dan foydalanadigan har bir Omarchy bog‘lami shunchaki to‘xtaydi va bu Hyprland buzilgandek ko‘rinadi.

`~/.config/hypr/` ni kovlashdan oldin bir marta `Fn + Super` ni bosing, agar bu Super ni qaytarmasa, qulfni yoniq qoldirmaslik uchun uni yana bir marta bosing. Bu Fn-lock emas, u faqat F-tugmalar qatori qanday ishlashini o‘zgartiradi.

### Wi-Fi, Bluetooth, audio yoki trekpadim to‘satdan ishlamay qoldi

Qayta yuklashdan oldin, muammoli quyi tizimning o‘zini qayta ishga tushirib ko‘ring. Omarchy menyusidagi _Update > Hardware_ da Wi-Fi, Bluetooth, Audio va Trackpad bor va ulardan birini qayta yuklash «besh daqiqa oldin ishlayotgandi» holatlarining aksariyatini hal qiladi — qayta ulanmayotgan Bluetooth quloqchini, uyqu rejimidan keyin o‘chib qolgan trekpad, monitorni uzganingizda yo‘qolib qolgan ovoz.

### Nega tashqi karnaylarim ovoz chiqarmayapti?

Ehtimol, ular asosiy chiqish qurilmasi sifatida belgilanmagan. Panelning o‘ng tomonidagi karnay belgisini bosing, shunda ovoz oynasi ochiladi va u yerda chiqish qurilmasini tanlashingiz mumkin (shuningdek, har bir ilova uchun ovoz balandligini alohida sozlashingiz ham mumkin).

### Laptop karnaylarim g‘alati eshitiladi

Ba’zi laptoplarda Omarchy avtomatik ravishda karnayni sozlashni qo‘llaydi, bu o‘rnatilgan karnaylarning chastota javobini to‘g‘rilaydi. `omarchy audio tuning status` sizning mashinangizda ulardan biri faol yoki yo‘qligini aytadi, `omarchy audio tuning off` esa karnaylarni xom holida eshitishni afzal ko‘rsangiz, uni o‘chiradi.

### Nega parolim bilan kira olmayman yoki sudo ishlata olmayman?

Ehtimol, uni juda ko‘p marta noto‘g‘ri kiritgansiz va bloklanib qolgansiz. Agar bu qulf ekranida sodir bo‘layotgan bo‘lsa, yangi TTY ni boshlash uchun `CTRL + ALT + F2` ni bosishingiz mumkin, u yerda root sifatida kirishingiz, so‘ngra `faillock --reset --user [your-username]` ni ishga tushirishingiz mumkin. Bu bloklanishni tiklaydi va davom etishingiz mumkin.

### Parolim qabul qilinadi, lekin login ekraniga qaytaveraman

Buzilgan sessiya muhiti fayli, parolingiz to‘g‘ri bo‘lsa ham, ish stolining ishga tushishiga to‘sqinlik qilishi mumkin. Bu ayniqsa `~/.config/uwsm/env.d/` ni tahrirlagandan keyin tekshirishga arziydi.

`Ctrl + Alt + F2` ni bosing, odatdagi foydalanuvchi nomingiz va parolingiz bilan kiring va joriy yuklanishning foydalanuvchi jurnalini tekshiring:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Muhit fayllaringizdan birini nomlaydigan xatoni qidiring, masalan `bad substitution`, muhit chiqishi belgisi topilmadi haqidagi xabardan oldin. Qayta kirishga urinishdan oldin o‘sha faylni `env.d` dan tashqariga ko‘chiring. Masalan, agar xato `99-custom` ni nomlasa:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM sintaksis xatosi bor faylni o‘tkazib yuboradi, lekin faqat fayl ishlayotganda namoyon bo‘ladigan halokatli xato, masalan `bad substitution`, ish stolining ishga tushishiga hamon to‘sqinlik qilishi mumkin. Tizim surati orqali qayta tiklash bu fayllarni tuzatmaydi, chunki `/home` qayta tiklanmaydi.

Kira olganingizdan keyin, saqlangan nusxani orqaga ko‘chirishdan oldin uni tuzating. `sh -n` faylni ishga tushirmasdan sintaksis xatolarini ushlaydi, lekin u manba sifatida yuklanganda sodir bo‘ladigan har bir xatoni ushlay olmaydi. O‘zgarishlarni sinab ko‘rayotganda ishlaydigan terminalni ochiq qoldiring.

### Nega 1Password SSH Agent / CLI uchun 1Password avtorizatsiya so‘rovlari chiqmayapti?

Bu 2 sababga ko‘ra sodir bo‘lishi mumkin:

Boy tasdiqlash so‘rovi chiqishi uchun Settings > Advanced > Use Hardware Acceleration yoqilgan bo‘lishi kerak. _Eslatma: Bu ishlashi uchun qayta yuklash talab qilinadi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Yoki agar siz kompyuter yoqilgandan beri 1Password ni ishga tushirmagan bo‘lsangiz, so‘rov chiqmaydi.
