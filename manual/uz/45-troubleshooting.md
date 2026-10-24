# Muammolarni hal qilish

### Men tizimimni yangilanish bilan buzdim!

Avval soʻnggi yangilanishingizdan oldingi versiyaga [tizimingizni qaytarishga](47-system-snapshots.md) urinib koʻring. Agar bu ishlamasa, Discord dagi #omarchy-help da muammoingizni ulashish uchun `omarchy-debug` dan foydalaning. Va agar barchasi muvaffaqiyatsiz boʻlsa, `omarchy-reinstall` yordamida standart konfiguratsiyalar va paketlarni qayta oʻrnatishingiz mumkin.

### Nega baʼzi ilovalar mening displeyimda juda katta?

Omarchy 2x yuqori aniqlikdagi displeyni taxmin qiladi, bu `~/.config/hypr/monitors.lua` da `GDK_SCALE` ni 2 ga oʻrnatishni talab qiladi. Lekin agar siz 1x displeyda boʻlsangiz, `local omarchy_gdk_scale = 2` ni 1 ga oʻzgartirishingiz mumkin (va keyin katta oʻlchamdagi har qanday ilovani qayta ishga tushiring). [Monitorlar boʻyicha qoʻllanmani](33-monitors.md) koʻring.

Spotify uchun UIning hajmini kichiklashtirish uchun `Ctrl + Minus` dan foydalanishingiz mumkin (va kattalashtirish uchun `Ctrl + Plus`).

### Mening Wi-Fi, Bluetooth, audio yoki trackpadim shunchaki ishlashni toʻxtatdi

Qayta yuklashdan oldin, aybdor quyi tizimni oʻz-oʻzidan qayta ishga tushirib koʻring. Omarchy menyusidagi _Yangilash > Qurilmalar_ da Wi-Fi, Bluetooth, Audio va Trackpad mavjud va ulardan birini qayta yuklash aksariyat «besh daqiqa oldin ishlayotgandi» holatlarini bartaraf etadi — qayta ulanmaydigan Bluetooth quloqchin, kutishdan keyin oʻlgan trackpad, monitorni uzganingizda yoʻqolgan ovoz.

### Nega mening tashqi karnaylarim ovoz chiqarmayapti?

Ehtimol ular asosiy chiqish sifatida oʻrnatilmagan. Panelning oʻng tomonidagi karnay belgisini bosing va u chiqish qurilmasini tanlashingiz mumkin boʻlgan (va ilova boʻyicha hajmlarni ham aralashtiradigan) ovoz oynachani ochadi.

### Mening noutbuk karnaylarim boshqacha eshitilyapti

Baʼzi noutbuklarda Omarchy avtomatik oʻrnatilgan karnaylarning chastota javobini tuzatadigan karnay sozlashini qoʻllaydi. `omarchy audio tuning status` sizga mashinangizda biri faolmi-yoʻqligini aytadi va `omarchy audio tuning off` agar karnaylarni xom eshitishni afzal koʻrsangiz uni oʻchiradi.

### Nega men parolim bilan kira olmayman yoki sudo qila olmayman?

Ehtimol siz uni juda koʻp marta notoʻgʻri yozgansiz va qulflangansiz. Agar bu qulf ekranida sodir boʻlayotgan boʻlsa, root sifatida kira olishingiz mumkin boʻlgan yangi TTYni boshlash uchun `CTRL + ALT + F2` ni bosishingiz mumkin, keyin `faillock --reset --user [your-username]` ni ishga tushiring. Bu qulfni qayta tiklaydi va siz tayyorsiz.

### Nega mening 1Password SSH Agent / CLI uchun 1Password avtorizatsiya soʻrovlari paydo boʻlmayapti?

Bu 2 sababga koʻra sodir boʻlishi mumkin:

Boy tasdiqlash soʻrovi paydo boʻlishi uchun Settings > Advanced > Use Hardware Acceleration yoqilgan boʻlishi kerak. _Eslatma: Bu ishlashni boshlash uchun qayta yuklashni talab qiladi._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Yoki yuklaganingzdan beri 1Passwordni ishga tushirmagan boʻlsangiz, soʻrov paydo boʻlmaydi.
