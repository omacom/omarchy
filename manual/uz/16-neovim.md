# Neovim

[Neovim](https://neovim.io/) — 1976-yilda Bill Joy tomonidan yaratilgan [vi editor](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) ning zamonaviy amalga oshirilishi. Bu kiritish rejimi va buyruq rejimi ajratilgan modal editor va nihoyatda chuqur tugmalar buyruqlari toʻplamining kichik bir qismigina oʻrgansangiz ham, bu biroz super kuchdir. Lekin oʻrganish egri chizigʻi ham ancha tik!

Agar vim uslubidagi tahrirlashda mutlaqo yangi boʻlsangiz, YouTubeda [ThePrimeagenning Vim As Your Editor seriyasi](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) ni koʻrib chiqishingizni tavsiya qilaman. Bu sizga asoslarni oʻrgatadi. Shuni bilingizki, koʻproq oʻxshash asosiy editorlardan farqli oʻlaroq, vimda bazaviy mahoratga erishish sizga koʻproq vaqt oladi. Lekin erishganingizdan keyin, mukofot ham kattaroq boʻladi.

Endi Neovim asosan cheksiz sozlanishi mumkin. Agar haqiqatan ham haddan oshmoqchi boʻlsangiz, oʻz Neovim konfiguratsiyangizni noldan yaratishingiz mumkin. [Typecraftdan Neovimni noldan sozlash haqida](https://www.youtube.com/watch?v=zHTeCSVAFNY) ajoyib kurs bor. Va [ThePrimeagendan ham bor](https://www.youtube.com/watch?v=w7i4amO_zaE).

Lekin Omarchy toʻliq Neovim sozlamasi — `omarchy-nvim` paketi — bilan keladi, u qutidan chiqiboq mumkin boʻlganlarning eng yaxshisini koʻrsatish uchun mehr bilan sozlangan. Bir qator konfiguratsiya yozishingizga toʻgʻri kelmasdan! U Neovim plaginlari va konfiguratsiyalarining distributivi boʻlgan [LazyVim](https://www.lazyvim.org/) ga qurilgan. Bu ajoyib.

## LazyVim asoslari

Yuqorida aytganimdek, bu qisqa kirishda sizga vim oʻrgatmayman, lekin LazyVimning bir nechta asoslarini va qanday harakatlanishni koʻrsatishim mumkin.

Avvalambor, Neovimda leader tugmasi gʻoyasi bor. Bu asosan barcha buyruqlarga kirish eshigidir. LazyVim uni `Space` ga oʻrnatgan. Demak shunchaki uni bosing, bir soniya kuting va mana bunday ichki tushuntirilgan bir qator variantlarni koʻrasiz:

Mana men har doim ishlatadigan baʼzi bazaviy buyruqlar:

- `Space Space` - Joriy katalogdagi istalgan faylni fuzzy-qidirish.
- `Space S G` - Oldindan koʻrish bilan grep yordamida barcha fayllarni qidirish.
- `Space E` - Fayl daraxtini yoqish/oʻchirish.
- `Ctrl + W W` - Fayl daraxtidan editorga va orqaga sakrash.
- `Shift + H` - Ochiq tablar (vim ularni buferlar deb ataydi) orasida chapga harakatlanish.
- `Shift + L` - Ochiq tablar orasida oʻngga harakatlanish.
- `Space B D` - Tabni yopish.
- `Space B O` - Joriydan boshqa barcha tablarni yopish.
- `Space G G` - Joriy katalogdan suzuvchi panelda LazyGit ni ishga tushirish.
- `Space U W` - Yumshoq oʻrashni almashtirish.

Fayl daraxtida boʻlsangiz (ochish uchun `Space E`, u yerga sakrash uchun `Ctrl + W W`), `a` bilan yangi fayl yoki `A` bilan yangi katalog qoʻshishingiz mumkin. Barcha buyruqlarni koʻrish uchun daraxtda boʻlganingizda `?` ni bosing.

Agar bazaviy vim tilini oʻzlashtirmoqchi boʻlsangiz, men [uch qismli sintaksis](https://world.hey.com/dhh/wonderful-vi-a1d034d3) va oʻsha ajoyib kombo harakatlarni qanday bajarish haqida yozganman!

Barcha mumkin boʻlgan buyruqlarni [LazyVim Keymaps sahifasida](https://www.lazyvim.org/keymaps) koʻrishingiz mumkin.

## Neovimni boshlash

Neovimni `Super + Shift + N` yordamida boshlashingiz mumkin (bogʻlanish standart editingizni ishga tushiradi, bu qutidan chiqiboq Neovim), lekin uni terminaldan ishlashni xohlagan katalogga oʻtib va `n` yozib boshqarish odatda osonroq. `n` — `nvim` uchun taxallus, u standartda joriy katalogni ochishga ishlatadi. Bitta faylni `n myfile.txt` bilan ochishingiz mumkin.

## Sudo tahrirlari uchun Neovimdan foydalanish

Faqat super foydalanuvchi sifatida oʻzgartirishingiz mumkin boʻlgan fayllarni tahrirlashingiz kerak boʻlsa, barcha plaginlaringiz sozlangan holda neovimdan foydalanish uchun `sudoedit /etc/sudoers.d/00-sudo-only-file` ni ishga tushirib foydalanishingiz mumkin.
