# Matnni ajratib olish va diktovka

### Matnni ajratib olish

Ekranda matnni ajratib olish uchun hududni tanlash uchun `Super + Ctrl + PrtScr` ni bosing. So'ngra tesseract ochiq manbali OCR modeli ushbu tanlangan hududni tezda matnga aylantiradi va uni almashinuv buferiga joylashtiradi. Keyin uni joylashtirish uchun shunchaki `Super + V` ni bosasiz.

Bu tasvirlarning pastki qismlaridagi manzillarni yoki veb-sayt sarlavhalariga joylashtirilgan telefon raqamlarini tortib olish uchun juda qo'l keladi.

 ![text-extraction](images/text-extraction.webp)

### Diktovka

Yangi o'rnatishlarda [Superwhisper](https://superwhisper.com/) standart diktovka backendi hisoblanadi va oflayn modellarni yuklab olmasdan bulutli qayta ishlashdan foydalanadi. Omarchy menyusidagi _Setup > Defaults > Dictation_ orqali Superwhisper, [Voxtype](https://voxtype.io/) yoki [Hex](https://anoma.ly/hex/) dan birini tanlang. Backendni tanlash, agar kerak bo'lsa, uni o'rnatadi va uni diktovka uchun standart qiladi. Voxtype 150MB joy egallaydigan asosiy inglizcha modelni yuklaydi; modelni `voxtype setup model` bilan, boshqa sozlamalarni esa `~/.config/voxtype/config.toml` orqali o'zgartiring. Superwhisper bulutli yoki lokal qayta ishlashni tanlash uchun o'z sozlamalarini ochadi va OPR ilovani yangilab turadi. Hex o'rnatish vaqtida qurilmadagi nutq modelini yuklab oladi va `hex.service` foydalanuvchi xizmati sifatida ishlaydi; model va boshqa sozlamalarni o'zgartirish uchun uning oynasini paneldagi tray belgisidan oching yoki `hex` ni ishga tushiring.

Siz `Right Alt` ni bosib turib yoki `Alt + Space` bilan yoqib-o'chirib diktovka qilasiz va aytilgan matn fokusdagi kiritish maydonida paydo bo'ladi. Ushbu yorliqlar tanlangan backenddan foydalanadi. Right Alt modifikator birikmasining bir qismi sifatida ishlatilganda ham diktovkani boshlaydi; bunday birikmalar uchun Left Alt dan foydalaning. Right Alt AltGr bo'lgan klaviatura tartiblarida AltGr ni yozish uchun mavjud qoldirib qo'yish uchun `Alt + Space` dan foydalaning. Alt + Space standart bo'lishidan oldingi o'rnatishlar bosib gapirish uchun `F9` ni va yoqib-o'chirish uchun `Super + Ctrl + X` ni saqlab qoladi, ular `~/.config/hypr/bindings.lua` ga qo'shilgan; ushbu tugmalarni ilovalarga qaytarib berish uchun ularni o'sha yerdan olib tashlang.

Xuddi shu yorliqlar har bir backend bilan ishlaydi. Backendingizni Setup > Defaults > Dictation orqali tanlang. Backend o'rnatuvchisi uni sozlaydi va tanlovni saqlaydi. Qaysi biri tanlanganini ko'rish uchun `omarchy default dictation` ni ishga tushiring. Tanlov `~/.config/omarchy/defaults/dictation` da saqlanadi. Yangi o'rnatishlar Superwhisper ni avtomatik ravishda tanlaydi.

Omarchy tanlangan backendning ish stoli integratsiyasini avtomatik ravishda yuklaydi. `~/.config/hypr/` da hech qanday Superwhisper sozlamasi kerak emas.

Maxsus bog'lamlar va skriptlar `omarchy dictation start`, `omarchy dictation stop` va `omarchy dictation toggle` dan foydalanishi mumkin. Tanlangan backend yozib olish va transkripsiyani bajaradi. Superwhisper ni tanlash uning o'zining bosib turish yorlig'ini o'chirib qo'yadi va uning o'zining yoqib-o'chirish yorlig'ini `Ctrl + Alt + Space` ga o'rnatadi, shu tarzda uni Omarchy yozib olish tugmalaridan alohida saqlaydi. Superwhisper kamida bitta o'zining yozib olish yorlig'ini talab qiladi va uning bekor qilish yorlig'i mavjud bo'lib qolaveradi.

Qo'shimcha backendlar Omarchy ni o'zgartirmasdan integratsiya qilinishi mumkin. PATH da `start`, `stop` va `toggle` ni qabul qiladigan, zudlik bilan qaytadigan va muvaffaqiyatsizlik holatida noldan farqli holat qaytaradigan `omarchy-dictation-<backend>` nomli bajariladigan faylni taqdim eting. Uning o'rnatuvchisi provayderni sozlaydi va muvaffaqiyatli o'rnatishdan so'ng `omarchy-dictation-use <backend>` ni chaqiradi. Bu oldingi backendni to'xtatadi va tanlovni atomar tarzda saqlaydi; provayder bo'sh turgan yoki mavjud bo'lmagan holatda `stop` muvaffaqiyatli bajarilishi shart. Backend nomlarida kichik harflar, raqamlar va chiziqchalar ishlatiladi. O'rnatish uchun `omarchy-install-dictation-<backend>` ni taqdim eting; `omarchy default dictation <backend>` uni ishga tushiradi. Ushbu tanlovchini chaqirish uchun Omarchy menyu kengaytmasi orqali Defaults menyusiga yozuv qo'shing. Ixtiyoriy ish stoli integratsiyasi `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` da joylashishi mumkin.
