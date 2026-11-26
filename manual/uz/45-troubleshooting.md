# Muammolarni bartaraf etish

### Yangilanish bilan tizimimni buzib qo'ydim!

Avval [tizimingizni orqaga qaytarib](47-system-snapshots.md), so'nggi yangilanishingizdan oldingi versiyaga qaytishga harakat qiling. Agar bu ish bermasa, muammoingizni Discord dagi #omarchy-help da ulashish uchun `omarchy-debug` dan foydalaning. Agar bularning barchasi ish bermasa, `omarchy-reinstall` yordamida standart konfiguratsiyalar va paketlarni qayta o'rnatishingiz mumkin.

### Nega ba'zi ilovalar displeyimda bunchalik katta ko'rinadi?

Omarchy 2x yuqori aniqlikdagi displeyni nazarda tutadi, shuning uchun monitor panelida masshtabni tanlamaguningizcha `GDK_SCALE` ni 2 qilib belgilaydi. Agar siz 1x displeyda bo'lsangiz va GTK yoki X11 ilovalari haddan tashqari katta chiqsa, monitor panelida u uchun 1x ni tanlang yoki `~/.config/hypr/monitors.lua` ga `hl.env("GDK_SCALE", "1")` ni qo'shing (so'ngra haddan tashqari katta bo'lgan har qanday ilovani qayta ishga tushiring). Qarang: [monitorlar bo'yicha qo'llanma](33-monitors.md).

Spotify uchun UI ni kichraytirish uchun `Ctrl + Minus` dan foydalanishingiz mumkin (kattalashtirish uchun esa `Ctrl + Plus`).

### Nega barcha Super tugmasi bog'lanishlarim ishlamay qoldi?

Ba'zi ASUS ROG va TUF noutbuklarida `Fn + Super` — osonlikcha sezilmay qoladigan kombinatsiya bo'lib, u proshivka darajasidagi Windows tugmasi qulfini yoqib-o'chiradi (o'yin paytida tasodifan o'yindan chiqib ketmasligingiz uchun mo'ljallangan). Bu sodir bo'lgani haqida ekranda hech narsa xabar bermaydi. Qulf yoqilgan paytda Super umuman hech narsa yubormaydi — shuning uchun Super dan foydalanadigan har bir Omarchy bog'lanishi shunchaki to'xtaydi va Hyprland buzilgandek ko'rinadi.

`~/.config/hypr/` ni kovlashdan oldin `Fn + Super` ni bir marta bosing, agar bu Super ni qaytarmasa, qulfni yoqilgan holda qoldirmaslik uchun uni yana bosing. Bu Fn-lock emas, u faqat F-tugmalar qatori nima qilishini o'zgartiradi.

### Wi-Fi, Bluetooth, audio yoki trekpadim birdan ishlamay qoldi

Qayta yuklashdan oldin, muammoli quyi tizimning o'zini alohida qayta ishga tushirib ko'ring. Omarchy menyusidagi _Update > Hardware_ da Wi-Fi, Bluetooth, Audio va Trackpad bor, ulardan birini qayta yuklash «besh daqiqa oldin ishlayotgan edi» holatlarining aksariyatini hal qiladi — qayta ulanmayotgan Bluetooth garniturasi, uyqu rejimidan keyin o'chib qolgan trekpad, monitorni uzganingizda yo'qolgan ovoz.

### Nega tashqi karnaylarim ovoz chiqarmayapti?

Ehtimol, ular asosiy chiqish sifatida belgilanmagani uchun. Panelning o'ng tomonidagi karnay belgisini bosing, shunda ovoz balandligi qalqib chiquvchi oynasi ochiladi, u yerda chiqish qurilmasini tanlashingiz mumkin (har bir ilova uchun ovoz balandligini alohida sozlash ham mumkin).

### Noutbuk karnaylarim g'alati eshitilyapti

Ba'zi noutbuklarda Omarchy o'rnatilgan karnaylarning chastota javobini to'g'rilaydigan karnay sozlamasini avtomatik qo'llaydi. `omarchy audio tuning status` sizning mashinangizda shunday sozlama faol yoki yo'qligini aytadi, `omarchy audio tuning off` esa karnaylarni xom holida eshitishni afzal ko'rsangiz, uni o'chiradi.

### Nega parolim bilan kira olmayman yoki sudo qila olmayman?

Ehtimol, uni o'n marta noto'g'ri kiritgansiz va bloklanib qolgansiz. Bloklash ikki daqiqadan keyin o'z-o'zidan bekor bo'ladi. Agar kuta olmasangiz va bu qulflash ekranida sodir bo'layotgan bo'lsa, root sifatida kira oladigan yangi TTY ni boshlash uchun `CTRL + ALT + F2` ni bosishingiz mumkin, so'ngra `faillock --reset --user [your-username]` ni ishga tushiring. Bu bloklashni tiklaydi va davom etishingiz mumkin.

### Parolim qabul qilinadi, lekin login ekraniga qaytaman

Buzilgan seans muhiti fayli parolingiz to'g'ri bo'lsa ham ish stoli boshlanishiga to'sqinlik qilishi mumkin. Bu ayniqsa `~/.config/uwsm/env.d/` ni tahrirlagandan keyin tekshirishga arziydi.

`Ctrl + Alt + F2` ni bosing, odatdagi foydalanuvchi nomingiz va parolingiz bilan kiring va joriy yuklanishning foydalanuvchi jurnalini tekshiring:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Muhit fayllaringizdan birini nomlaydigan xatoni, masalan `bad substitution` ni, env chiqish belgisi topilmagani haqidagi xabardan biroz oldin qidiring. Qayta kirishga urinishdan oldin o'sha faylni `env.d` dan tashqariga ko'chiring. Masalan, agar xato `99-custom` ni nomlasa:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM sintaksis xatosi bo'lgan faylni o'tkazib yuboradi, lekin faqat fayl ishlayotganda namoyon bo'ladigan halokatli xato, masalan `bad substitution`, baribir ish stoli boshlanishiga to'sqinlik qilishi mumkin. Tizim suratini orqaga qaytarish bu fayllarni tuzatmaydi, chunki `/home` orqaga qaytarilmaydi.

Kira olganingizdan keyin, saqlangan nusxani orqaga ko'chirishdan oldin uni tuzating. `sh -n` faylni ishga tushirmasdan sintaksis xatolarini ushlaydi, lekin u manba sifatida yuklanganda yuzaga keladigan har bir xatoni ushlay olmaydi. O'zgarishlarni sinab ko'rayotganda ishlaydigan terminalni ochiq qoldiring.

### Nega 1Password SSH Agent / CLI uchun 1Password avtorizatsiya so'rovlari ko'rinmayapti?

Bu 2 sababga ko'ra sodir bo'lishi mumkin:

To'liq tasdiqlash so'rovi ko'rinishi uchun Settings > Advanced > Use Hardware Acceleration yoqilgan bo'lishi kerak. _Eslatma: Bu ishlay boshlashi uchun qayta yuklash talab qilinadi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Yoki tizim yuklanganidan beri 1Password ni ishga tushirmagan bo'lsangiz, so'rov ko'rinmaydi.
