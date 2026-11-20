# Matn chiqarib olish va diktant

### Matn chiqarib olish

Matn chiqarib olish uchun ekranda hududni tanlash uchun `Super + Ctrl + PrtScr` tugmalarini bosing. Keyin tesseract ochiq kodli OCR modeli o'sha tanlovni tezda matnga aylantiradi va uni almashinish buferiga joylashtiradi. Keyin joylashtirish uchun shunchaki `Super + V` tugmalarini bosing.

Bu rasmlarning pastki qismidagi manzillarni yoki veb-sayt sarlavhalariga joylashtirilgan telefon raqamlarini olish uchun juda foydali.

 ![text-extraction](images/text-extraction.webp)

### Diktant

Yangi o'rnatishlarda [Superwhisper](https://superwhisper.com/) standart diktant backend'i hisoblanadi va oflayn modellarni yuklab olmasdan, bulutda qayta ishlashdan foydalanadi. Omarchy menyusidagi _Setup > Defaults > Dictation_ orqali Superwhisper, [Voxtype](https://voxtype.io/) yoki [Hex](https://anoma.ly/hex/) ni tanlang. Backend'ni tanlash, agar kerak bo'lsa, uni o'rnatadi va uni diktant uchun standart qilib qo'yadi. Voxtype 150MB joy egallaydigan asosiy inglizcha modelni yuklaydi; modelni `voxtype setup model` bilan o'zgartiring, boshqa sozlamalarni esa `~/.config/voxtype/config.toml` orqali o'zgartiring. Superwhisper bulutli yoki mahalliy qayta ishlashni tanlash uchun o'z sozlamalarini ochadi, OPR esa ilovani yangilab turadi. Hex o'rnatish paytida qurilmadagi nutq modelini yuklab oladi va `hex.service` foydalanuvchi xizmati sifatida ishlaydi; model va boshqa sozlamalarni o'zgartirish uchun uning oynasini paneldagi tray belgisidan oching yoki `hex` ni ishga tushiring.

Siz `Right Alt` ni bosib turib yoki `Alt + Space` bilan almashtirib diktant qilasiz va aytilgan matn fokuslangan kiritish maydonida paydo bo'ladi. Bu yorliqlar tanlangan backend'dan foydalanadi. Right Alt modifikatorlar kombinatsiyasining bir qismi sifatida ishlatilganda ham diktantni boshlaydi; bunday kombinatsiyalar uchun Left Alt dan foydalaning. Right Alt — AltGr bo'lgan klaviatura tartiblarida AltGr ni yozish uchun ochiq qoldirish uchun `Alt + Space` dan foydalaning. Alt + Space standart bo'lishidan oldingi o'rnatishlar bosib gapirish uchun `F9` ni va almashtirish uchun `Super + Ctrl + X` ni saqlab qoladi, bular `~/.config/hypr/bindings.lua` ga qo'shilgan, o'sha yerda o'sha `Super + Ctrl + X` agentlar paneli o'rnini egallaydi; o'sha tugmalarni ilovalarga va panelga qaytarish uchun ularni o'sha yerdan olib tashlang.

Xuddi shu yorliqlar har bir backend bilan ishlaydi. Backend'ingizni Setup > Defaults > Dictation orqali tanlang. Backend o'rnatuvchisi uni sozlaydi va tanlovni saqlaydi. Qaysi biri tanlanganini ko'rish uchun `omarchy default dictation` ni ishga tushiring. Tanlov `~/.config/omarchy/defaults/dictation` da saqlanadi. Yangi o'rnatishlar Superwhisper ni avtomatik tanlaydi.

Omarchy tanlangan backend'ning ish stoli integratsiyasini avtomatik yuklaydi. `~/.config/hypr/` da hech qanday Superwhisper sozlamasi kerak emas.

Maxsus bog'lanishlar va skriptlar `omarchy dictation start`, `omarchy dictation stop` va `omarchy dictation toggle` dan foydalanishi mumkin. Tanlangan backend yozib olish va transkripsiyani amalga oshiradi. Superwhisper ni tanlash uning o'z bosib turish yorlig'ini o'chirib qo'yadi va uning o'z almashtirish yorlig'ini `Ctrl + Alt + Space` qilib belgilaydi, uni Omarchy yozib olish tugmalaridan alohida ushlab turadi. Superwhisper kamida bitta o'z yozib olish yorlig'ini talab qiladi va uning bekor qilish yorlig'i mavjud bo'lib qolaveradi.

Qo'shimcha backend'lar Omarchy ni o'zgartirmasdan integratsiyalashishi mumkin. PATH da `start`, `stop` va `toggle` ni qabul qiladigan, tezda qaytadigan va muvaffaqiyatsizlikda noldan farqli holat qaytaradigan `omarchy-dictation-<backend>` nomli bajariladigan faylni taqdim eting. Uning o'rnatuvchisi provayderni sozlaydi va muvaffaqiyatli o'rnatishdan keyin `omarchy-dictation-use <backend>` ni chaqiradi. Bu oldingi backend'ni to'xtatadi va tanlovni atomik tarzda saqlaydi; provayder bo'sh turganda yoki mavjud bo'lmaganda `stop` muvaffaqiyatli tugashi kerak. Backend nomlari kichik harflar, raqamlar va chiziqchalardan foydalanadi. O'rnatish uchun `omarchy-install-dictation-<backend>` ni taqdim eting; `omarchy default dictation <backend>` uni ishga tushiradi. O'sha tanlovchini chaqirish uchun Omarchy menyu kengaytmasi orqali Defaults menyusiga band qo'shing. Ixtiyoriy ish stoli integratsiyasi `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` da joylashishi mumkin.
