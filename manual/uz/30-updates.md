# Yangilanishlar

Omarchy va paketlaringiz Omarchy menyusidagi _Yangilash > Omarchy_ (`Super + Space`) orqali yangilab turiladi.

Omarchy ning o'zi [Omarchy paketlar ombori](https://github.com/omacom-io/omarchy-pkgs) dan oddiy pacman paketlari sifatida o'rnatiladi, shuning uchun yangilanish [eng so'nggi Omarchy relizi](https://github.com/omacom/omarchy/releases) ni o'rnatadi, tizimingizni eng so'nggisi bilan sinxron holatga keltirish uchun kutilayotgan barcha migratsiyalarni ishga tushiradi va [Omarchy Arch oynasi](https://github.com/omacom-io/omarchy-mirror) hamda [AUR](https://aur.archlinux.org/) dan barcha tizim paketlarini yangilaydi (agar biron-bir AUR paketlarini o'rnatgan bo'lsangiz).

Yangi relizlar chiqqanda, soatingizning o'ng tomonida doiraviy strelka belgisi paydo bo'ladi. Uni bosing va yangilanish jarayoni boshlanadi.

![update-available](images/update-available.webp)

### To'rtta kanal

Omarchy to'rtta kanal bo'ylab yangilanadi: stable, RC, edge va dev. Yangi o'rnatishlar stable kanalidan boshlanadi, u [rasmiy relizlar](https://github.com/omacom/omarchy/releases/) ni, shuningdek eng so'nggisidan bir oy orqada qoladigan [barqaror Omarchy Arch oynasi](https://github.com/omacom-io/omarchy-mirror) ni kuzatib boradi, shunda biz konfiguratsiya o'zgarishlarini talab qiladigan har qanday yangi nomuvofiqliklarni odamlarga muammo tug'dirishidan oldin aniqlay olamiz.

Lekin agar siz ana shu ehtimoliy muammolarni aniqlashga yordam bermoqchi bo'lsangiz, edge kanalida ishlashingiz mumkin. Bu sizning Omarchy paketlaringiz eng so'nggi ishlab chiqish yig'ilishlarini kuzatishda davom etishini ta'minlaydi va eng so'nggi Arch paketlari mavjud bo'lishi bilanoq ularni yangilash imkonini beradi. Buni faqat Linux bilan tajribangiz bo'lsa va muammoga duch kelgan tizimni qanday tiklashni bilsangizgina qilishingiz kerak.

Har qanday yangi yirik relizdan oldin, biz RC kanali yordamida yakuniy tekshiruvni o'tkazamiz. Agar yakuniy sayqallashga yordam berishga qiziqsangiz, Discord dagi #omarchy-release-candidates ga kelib qo'shiling.

Nihoyat, dev kanali ham bor, u Omarchy ni to'g'ridan-to'g'ri `~/omarchy` dagi manba kodining git nusxasiga edge paketlari bilan birgalikda bog'laydi. Bu kanaldan faqat tajribali Linux foydalanuvchisi bo'lsangiz, bevosita Omarchy ustida ishlasangiz va buzilishlarga chidashga tayyor bo'lsangizgina foydalanishingiz kerak.

Omarchy menyusidagi _Yangilash > Kanal_ yordamida kanallar o'rtasida almashishingiz mumkin (yoki terminalda `omarchy channel set <stable|rc|edge|dev>`, qayerda ekaningizni ko'rish uchun `omarchy channel current` bilan).

### Yadrolarni almashtirish

Omarchy o'zining `linux-omarchy` yadrosini yuklaydi, lekin siz uning yonida boshqalarini ham o'rnatib qo'yishingiz mumkin, masalan standart Arch `linux` yadrosi yoki siz sinab ko'rayotgan eksperimental yig'ilish. Bir nechta yadro bo'lganda, Omarchy menyusidagi _Yangilash > Yadro_ ularni ro'yxatlaydi va sukut bo'yicha yuklanadiganining yoniga belgi qo'yadi. Boshqasini tanlang, parolingizni bir marta kiriting va u keyingi qayta yuklashdan keyin yuklanadi. Boshqa yadrolar yuklash menyusida qoladi, shuning uchun yangi sukut bo'yicha yadro sizga muammo tug'dirsa, siz hali ham birini qo'lda tanlashingiz mumkin. Terminalda joriy sukut bo'yicha yadroni ko'rish uchun `omarchy kernel`, nima o'rnatilganini ko'rish uchun `omarchy kernel list` va almashtirish uchun `omarchy kernel set <kernel>` ishlatiladi.

### Mikrodastur yangilanishlari

Eskirib qoladigan narsa faqat paketlaringiz emas. Ko'plab noutbuklar va periferiya qurilmalari BIOS, SSD va dok mikrodasturlarini Linux Vendor Firmware Service orqali yetkazib beradi va Omarchy menyusidagi _Yangilash > Mikrodastur_ qurilmangizda kutib turgan narsalarni olib kelib o'rnatadi. U birinchi marta ishga tushirganingizda `fwupd` ni o'rnatadi. Ko'plab mikrodasturlarni faqat qayta yuklash vaqtida yozish mumkin, shuning uchun sizdan qayta yuklash so'ralsa, hayron bo'lmang.

BIOS ning o'zida biron-bir sozlamani o'zgartirishingiz kerak bo'lganda, tizim menyusida (`Super + Escape`) `Alt` ni bosib turing va _Qayta yuklash_ _BIOS ga qayta yuklash_ ga aylanadi, bu esa yuklash vaqtida to'g'ri tugmani tutib qolishga urinishsiz to'g'ridan-to'g'ri mikrodastur sozlamalariga qayta ishga tushadi. Terminaldan bu `omarchy system firmware` dir.

### To'g'ridan-to'g'ri pacman/yay yangilanishlari haqida ogohlantirish

Agar siz Arch bilan allaqachon tanish bo'lsangiz, shunchaki `pacman -Syu` yoki `yay -Syu` ni o'zingiz ishga tushirish vasvasasiga tushishingiz mumkin, lekin agar shunday qilsangiz, Omarchy yangi paketlar bilan birgalikda ishga tushiradigan surat, migratsiyalar va konfiguratsiya yangilanishlarini o'tkazib yuborasiz. Shuning uchun Omarchy to'g'ridan-to'g'ri tizimni yangilashni aslida to'xtatadi va sizni o'rniga `omarchy update` ga yo'naltiradi. (Agar haqiqatan ham nima qilayotganingizni bilsangiz, himoya sizga uni bitta tranzaksiya uchun qanday chetlab o'tishni aytib beradi.)

### Yomon yangilanishlarni orqaga qaytarish

Agar yangilanish qilganingizdan keyin hech qachon muammoga duch kelsangiz, tizimingizni yangilanishdan oldin olingan suratga qaytarishingiz mumkin. Shunchaki qayta yuklang va yuklash menyusida yangilanishni boshlashdan oldingi suratni tanlang.

![bootloader](images/bootloader.webp)

Agar qandaydir tarzda konfiguratsiya fayllaringiz shikastlangan bo'lsa, terminalda `omarchy reinstall` yordamida Omarchy ni qayta o'rnatishni ham amalga oshirishingiz mumkin. Bu barcha sukut bo'yicha Omarchy paketlarini qayta o'rnatadi, sizni stable ga o'tkazadi (Apple Silicon da edge) va juda yangi bo'lgan har qanday paketlarni pasaytiradi hamda barcha konfiguratsiya fayllarini tiklaydi. E'tibor bering, buni qilish bilan Omarchy sukut bo'yicha sozlamalariga kiritgan barcha foydalanuvchi konfiguratsiya o'zgarishlaringiz ustidan yoziladi!
