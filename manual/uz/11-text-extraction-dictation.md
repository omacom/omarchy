# Matn ajratib olish & Diktovka

### Matn ajratib olish

Matn ajratib olish uchun ekranda hudud tanlash uchun `Super + Ctrl + PrtScr` ni bosing. So'ng tesseract ochiq kodli OCR modeli o'sha tanlangan hududni tezda matnga aylantiradi va almashuv buferiga joylashtiradi. Keyin yopishtirish uchun shunchaki `Super + V` ni bosing.

Bu tasvirlarning pastki izohlaridan manzillarni yoki veb-sayt sarlavhalariga joylashtirilgan telefon raqamlarini olish uchun juda qo'l keladi.

 ![text-extraction](images/text-extraction.webp)

### Diktovka

Yangi o'rnatishlarda [Superwhisper](https://superwhisper.com/) standart diktovka backendi hisoblanadi, u oflayn model yuklab olishlarsiz bulutli ishlov berishdan foydalanadi. Omarchy menyusida _Setup > Defaults > Dictation_ orqali Superwhisper, [Voxtype](https://voxtype.io/) yoki [Hex](https://anoma.ly/hex/) ni tanlang. Backendni tanlash, agar kerak bo'lsa, uni o'rnatadi va diktovka uchun standart qiladi. Voxtype 150MB joy egallaydigan asosiy inglizcha modelni yuklaydi; modelni `voxtype setup model` bilan, boshqa sozlamalarni esa `~/.config/voxtype/config.toml` orqali o'zgartiring. Superwhisper bulutli yoki lokal ishlov berishni tanlash uchun o'z sozlamalarini ochadi, OPR esa ilovani yangilab turadi. Hex o'rnatish vaqtida qurilmadagi nutq modelini yuklab oladi va `hex.service` foydalanuvchi xizmati sifatida ishlaydi; model va boshqa sozlamalarni o'zgartirish uchun uning oynasini paneldagi tray belgisidan oching yoki `hex` ni ishga tushiring.

Siz `Right Alt` ni bosib turib, yoki `Alt + Space` bilan almashtirib diktovka qilasiz, aytilgan matn esa fokuslangan kiritish maydonida paydo bo'ladi. Bu yorliqlar tanlangan backenddan foydalanadi. Right Alt modifikator akkordida ishlatilganda ham diktovkani boshlaydi; bunday akkordlar uchun Left Alt dan foydalaning. Right Alt AltGr bo'lgan klaviatura tartiblarida, shu jumladan siz o'tadigan tartib shunday bo'lganda ham, diktovka qilish uchun uni bir lahza yolg'iz bosib turing; boshqa tugma bilan birga bosilgan AltGr hali ham o'z belgisini yozadi. Alt + Space standart bo'lishidan oldingi o'rnatishlar bosib gapirish uchun `F9` ni va almashtirish uchun `Super + Ctrl + X` ni saqlab qoladi, ular `~/.config/hypr/bindings.lua` ga qo'shilgan, u yerda o'sha `Super + Ctrl + X` agentlar paneli o'rnini egallaydi; o'sha tugmalarni ilovalar va panelga qaytarish uchun ularni o'sha yerdan olib tashlang.

Xuddi shu yorliqlar har bir backend bilan ishlaydi. Backend ingizni Setup > Defaults > Dictation orqali tanlang. Backend o'rnatuvchisi uni sozlaydi va tanlovni saqlaydi. Qaysi biri tanlanganini ko'rish uchun `omarchy default dictation` ni ishga tushiring. Tanlov `~/.config/omarchy/defaults/dictation` da saqlanadi. Yangi o'rnatishlar Superwhisper ni avtomatik tanlaydi.

Omarchy tanlangan backendning ish stoli integratsiyasini avtomatik yuklaydi. `~/.config/hypr/` da hech qanday Superwhisper sozlamasi kerak emas.

Maxsus bog'lanishlar va skriptlar `omarchy dictation start`, `omarchy dictation stop` va `omarchy dictation toggle` dan foydalanishi mumkin. Tanlangan backend yozib olish va transkripsiyani bajaradi. Superwhisper ni tanlash uning o'zining bosib turish yorlig'ini o'chiradi va o'zining almashtirish yorlig'ini `Ctrl + Alt + Space` qilib belgilaydi, shu bilan uni Omarchy ning yozib olish tugmalaridan alohida saqlaydi. Superwhisper kamida bitta o'z yozib olish yorlig'ini talab qiladi, uning bekor qilish yorlig'i esa mavjud bo'lib qoladi.

Qo'shimcha backendlar Omarchy ni o'zgartirmasdan integratsiya qilinishi mumkin. PATH da `start`, `stop` va `toggle` ni qabul qiladigan va tezgina qaytadigan, muvaffaqiyatsizlikda noldan farqli holat qaytaradigan `omarchy-dictation-<backend>` nomli bajariladigan faylni taqdim eting. Uning o'rnatuvchisi provayderni sozlaydi va muvaffaqiyatli o'rnatishdan so'ng `omarchy-dictation-use <backend>` ni chaqiradi. Bu oldingi backendni to'xtatadi va tanlovni atomar saqlaydi; provayder bo'sh yoki mavjud bo'lmaganda `stop` muvaffaqiyatli tugashi kerak. Backend nomlari kichik harflar, raqamlar va tirelardan foydalanadi. O'rnatish uchun `omarchy-install-dictation-<backend>` ni taqdim eting; `omarchy default dictation <backend>` uni ishga tushiradi. O'sha tanlovchini chaqirish uchun Omarchy menyusi kengaytmasi orqali Defaults menyusiga yozuv qo'shing. Ixtiyoriy ish stoli integratsiyasi `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` da joylashishi mumkin.
