# Neovim

[Neovim](https://neovim.io/) — Bill Joy tomonidan naq 1976-yilda yaratilgan [vi muharriri](<https://en.wikipedia.org/wiki/Vi_(text_editor)>)ning zamonaviy amalga oshirilishi. Bu modal muharrir bo‘lib, unda kiritish rejimi va buyruq rejimi ajratilgan, va nihoyatda chuqur tugma buyruqlari to‘plamining hech bo‘lmasa bir qismini o‘rganib olsangiz, bu bitta super kuchga aylanadi. Lekin o‘rganish egri chizig‘i ham ancha tik!

Agar siz vim uslubidagi tahrirlashga mutlaqo yangi bo‘lsangiz, YouTube’dagi [ThePrimeagen’ning Vim As Your Editor turkumi](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R)ni ko‘rib chiqishingizni tavsiya qilaman. U sizga asoslarni o‘rgatadi. Shuni bilingki, ko‘proq o‘xshash bo‘lgan asosiy muharrirlardan farqli o‘laroq, vim’da asosiy malakaga ega bo‘lishingiz ko‘proq vaqt oladi. Lekin bunga erishganingizdan keyin, samara ham kattaroq bo‘ladi.

Endi Neovim asosan cheksiz darajada sozlanishi mumkin. Agar haqiqatan ham haddan oshmoqchi bo‘lsangiz, o‘zingizning Neovim konfiguratsiyangizni noldan yaratishingiz mumkin. [Typecraft’dan Neovim’ni noldan sozlash bo‘yicha](https://www.youtube.com/watch?v=zHTeCSVAFNY) ajoyib kurs bor. Va [ThePrimeagen’da ham bittasi bor](https://www.youtube.com/watch?v=w7i4amO_zaE).

Lekin Omarchy to‘liq Neovim sozlamasi — `omarchy-nvim` paketi — bilan birga keladi, u qutidan chiqqan holda mumkin bo‘lgan eng yaxshi narsalarni namoyish etish uchun mehr bilan sozlangan. Siz bir qator ham konfiguratsiya yozishingizga to‘g‘ri kelmasdan! U Neovim plaginlari va konfiguratsiyalari distributivi bo‘lgan [LazyVim](https://www.lazyvim.org/) asosida qurilgan. U ajoyib.

## LazyVim asoslari

Ta’kidlanganidek, men ushbu qisqa kirishda sizga vim’ni o‘rgatmoqchi emasman, lekin LazyVim’ning bir nechta asoslarini va unda qanday harakatlanishni ko‘rsatib bera olaman.

Birinchidan, Neovim’da leader tugmasi tushunchasi bor. Bu asosan barcha buyruqlarga kirish eshigi hisoblanadi. LazyVim uni `Space` qilib belgilagan. Shuning uchun shunchaki uni bosing, bir soniya kuting, va siz shunday ichki tarzda izohlangan bir qator variantlarni ko‘rasiz:

Mana men doim foydalanadigan ba’zi asosiy buyruqlar:

- `Space Space` - Joriy katalogdagi istalgan faylni noaniq qidiruv bilan topish.
- `Space S G` - Oldindan ko‘rish bilan grep yordamida barcha fayllarni qidirish.
- `Space E` - Fayl daraxtini yoqish/o‘chirish.
- `Ctrl + W W` - Fayl daraxtidan muharrirga va orqaga sakrash.
- `Shift + H` - Ochiq yorliqlar (vim ularni buffers deb ataydi) orasida chapga o‘tish.
- `Shift + L` - Ochiq yorliqlar orasida o‘ngga o‘tish.
- `Space B D` - Yorliqni yopish.
- `Space B O` - Joriydan boshqa barcha yorliqlarni yopish.
- `Space G G` - Joriy katalogdan suzuvchi panelda LazyGit’ni ishga tushirish.
- `Space U W` - Yumshoq o‘rashni yoqish/o‘chirish.

Fayl daraxtida bo‘lganingizda (`Space E` ochish uchun, `Ctrl + W W` u yerga sakrash uchun), `a` bilan yangi fayl yoki `A` bilan yangi katalog qo‘shishingiz mumkin. Barcha buyruqlarni ko‘rish uchun daraxtda bo‘lganingizda `?` ni bosing.

Agar asosiy vim tilini o‘zlashtirmoqchi bo‘lsangiz, men [uch qismli sintaksis](https://world.hey.com/dhh/wonderful-vi-a1d034d3) va o‘sha ajoyib kombinatsion harakatlarni qanday amalga oshirish haqida yozganman!

Barcha mumkin bo‘lgan buyruqlarni [LazyVim Keymaps sahifasi](https://www.lazyvim.org/keymaps)da ko‘rishingiz mumkin.

## Neovim’ni ishga tushirish

`Super + Shift + N` standart muharriringizni ishga tushiradi, u yangi o‘rnatishlarda Plain hisoblanadi; uning o‘rniga Neovim ishga tushishi uchun _Setup > Defaults > Editor_ ostida Neovim’ni tanlang. Lekin odatda uni terminaldan, ishlamoqchi bo‘lgan katalogingizga o‘tib, `n` deb yozish orqali boshqarish osonroq. `n` — `nvim` uchun taxallus bo‘lib, u standart holatda joriy katalogdan ochish uchun foydalanadi. Bitta faylni `n myfile.txt` bilan ochishingiz mumkin.

## Neovim’ni sudo tahrirlari uchun ishlatish

Agar faqat super foydalanuvchi sifatida o‘zgartirishingiz mumkin bo‘lgan fayllarni tahrirlashingiz kerak bo‘lsa, `sudoedit /etc/sudoers.d/00-sudo-only-file` ni ishga tushiring. U standart muharriringizni ochadi, shuning uchun agar uni u yerda barcha plaginlaringiz bilan istasangiz, _Setup > Defaults > Editor_ ostida Neovim’ni o‘rnating.
