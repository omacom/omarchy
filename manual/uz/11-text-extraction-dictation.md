# Matn ajratib olish va diktant

### Matn ajratib olish

Ekranda matn ajratib olish uchun hudud tanlash uchun `Super + Ctrl + PrtScr` tugmasini bosing. So'ng tesseract ochiq manbali OCR modeli o'sha tanlovni tezda matnga aylantiradi va uni almashish buferiga joylashtiradi. Keyin joylashtirish uchun shunchaki `Super + V` tugmasini bosing.

Bu rasmlarning pastki qismidagi manzillarni yoki veb-sayt sarlavhalariga joylashtirilgan telefon raqamlarini olish uchun juda foydali.

 ![text-extraction](images/text-extraction.webp)

### Diktant

Yangi o'rnatishlarda [Superwhisper](https://superwhisper.com/) standart diktant backend hisoblanadi va oflayn model yuklab olishlarisiz bulutli ishlov berishdan foydalanadi. Omarchy menyusidagi _Setup > Defaults > Dictation_ orqali Superwhisper yoki [Voxtype](https://voxtype.io/) ni tanlang. Backend tanlash kerak bo'lsa uni o'rnatadi va uni diktant uchun standart qiladi. Voxtype 150MB joy egallaydigan asosiy inglizcha modelni yuklaydi; modelni `voxtype setup model` bilan, boshqa sozlamalarni esa `~/.config/voxtype/config.toml` orqali o'zgartiring. Superwhisper bulutli yoki mahalliy ishlov berishni tanlash uchun o'z sozlamalarini ochadi va OPR ilovani yangilab turadi.

Siz `Right Alt` tugmasini bosib turib yoki `Alt + Space` bilan almashtirib diktant qilasiz va aytilgan matn fokuslangan kiritish maydonida paydo bo'ladi. Bu yorliqlar tanlangan backenddan foydalanadi. Right Alt modifikator akkordida ishlatilganda ham diktantni boshlaydi; bunday akkordlar uchun Left Alt dan foydalaning. Right Alt AltGr bo'lgan klaviatura tartiblarida AltGr ni yozish uchun bo'sh qoldirish uchun `Alt + Space` dan foydalaning. Alt + Space standart bo'lishidan oldingi o'rnatishlar bosib gapirish uchun `F9` ni va almashtirish uchun `Super + Ctrl + X` ni saqlab qoladi, ular `~/.config/hypr/bindings.lua` ga qo'shilgan; o'sha tugmalarni ilovalarga qaytarish uchun ularni o'sha yerdan olib tashlang.

Xuddi shu yorliqlar ikkala backend bilan ham ishlaydi. Backend ingizni Setup > Defaults > Dictation orqali tanlang. Backend o'rnatuvchisi uni sozlaydi va tanlovni saqlaydi. Qaysi biri tanlanganini ko'rish uchun `omarchy default dictation` ni ishga tushiring. Tanlov `~/.config/omarchy/defaults/dictation` da saqlanadi. Yangi o'rnatishlar Superwhisper ni avtomatik ravishda tanlaydi.

Omarchy tanlangan backendning ish stoli integratsiyasini avtomatik ravishda yuklaydi. `~/.config/hypr/` da hech qanday Superwhisper sozlamasi kerak emas.

Maxsus bog'lanishlar va skriptlar `omarchy dictation start`, `omarchy dictation stop` va `omarchy dictation toggle` dan foydalanishi mumkin. Tanlangan backend yozib olish va transkripsiyani bajaradi. Superwhisper ni tanlash uning mahalliy bosib turish yorlig'ini o'chiradi va uning mahalliy almashtirish yorlig'ini `Ctrl + Alt + Space` ga o'rnatadi va uni Omarchy ning yozib olish tugmalaridan alohida saqlaydi. Superwhisper kamida bitta mahalliy yozib olish yorlig'ini talab qiladi va uning bekor qilish yorlig'i mavjud bo'lib qoladi.

Qo'shimcha backendlar Omarchy ni o'zgartirmasdan integratsiya qilinishi mumkin. PATH da `start`, `stop` va `toggle` ni qabul qiladigan, tezda qaytadigan va muvaffaqiyatsizlikda noldan farqli holat qaytaradigan `omarchy-dictation-<backend>` nomli bajariladigan faylni taqdim eting. Uning o'rnatuvchisi provayderni sozlaydi va muvaffaqiyatli o'rnatishdan so'ng `omarchy-dictation-use <backend>` ni chaqiradi. Bu oldingi backendni to'xtatadi va tanlovni atomar tarzda saqlaydi; provayder bo'sh yoki mavjud bo'lmaganda `stop` muvaffaqiyatli yakunlanishi kerak. Backend nomlarida kichik harflar, raqamlar va defislar ishlatiladi. O'rnatish uchun `omarchy-install-dictation-<backend>` ni taqdim eting; `omarchy default dictation <backend>` uni ishga tushiradi. O'sha selektorni chaqirish uchun Omarchy menyu kengaytmasi orqali Defaults menyusiga yozuv qo'shing. Ixtiyoriy ish stoli integratsiyasi `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` da joylashishi mumkin.
