# Shell vositalari

Standart Linux vositalaridan tashqari, Omarchy bir qator takomillashtirilgan shell vositalari bilan ham keladi. Asosiylari mana.

## fzf

[fzf](https://junegunn.github.io/fzf/) sizga `ff` alias orqali fayllarni fuzzy usulda topishni beradi. Istalgan katalogga oʻting, `ff` deb yozing va oʻng tomonda toraytirib borayotgan fayllaringiz koʻrinishini koʻrib turib, oʻsha daraxtdagi istalgan faylga fuzzy usulda yoʻl topa olasiz.

Buyruqlar tarixingiz boʻylab fzf bilan fuzzy qidirish uchun `Ctrl + R` dan foydalanishingiz mumkin.

Bu vosita `Space Space` deb yozganingizda Neovim tomonidan ham ishlatiladi.

Toʻliq qoʻllanmani `man fzf` orqali topish mumkin.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) cd ning oʻrnini bosuvchi vositadir. U siz boʻlgan kataloglarni eslab qoladi, shuning uchun keyingi safar ularga osonroq sakrashingiz mumkin. Aytaylik, bir marta `cd ~/.config/omarchy` qilasiz. Keyingi safar shunchaki `cd omarchy` (yoki hatto shunchaki `cd oma`) qilishingiz mumkin va Zoxide sizni toʻgʻridan-toʻgʻri u yerga olib boradi.

Toʻliq qoʻllanmani `man zoxide` orqali topish mumkin.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) `rg <pattern> <path>` yordamida fayllar mazmunini qidiradi, masalan app katalogidagi `Controller` ning barcha tilga olinishini topish uchun `rg Controller app/`.

Bu vosita `Space S G` deb yozganingizda Neovim tomonidan ham ishlatiladi.

Toʻliq qoʻllanmani `man rg` orqali topish mumkin.

## eza

[eza](https://eza.rocks/) ls ning oʻrnini bosuvchi vositadir. U sizga koʻproq maʼlumot, rang va piktogrammalar bilan katalog roʻyxatlarini beradi. Standart tarzda eza ls sifatida alias qilingan. Ikki chuqurlikdagi ichma-ich roʻyxatni olish uchun `lt` dan ham foydalanishingiz mumkin. `lsa` yashirin fayllarni ham oʻz ichiga olgan roʻyxatni beradi. Va `lta` yashirin fayllar bilan ichma-ich roʻyxatni beradi.

Toʻliq qoʻllanmani `man eza` orqali topish mumkin.

## fd

[fd](https://github.com/sharkdp/fd) `find` ning ishlatish osonroq boʻlgan oʻrnini bosuvchi vositasidir. Joriy daraxt ichida `person.rb` deb ataluvchi faylni topish uchun `fd person.rb` dan foydalaning. `fd person.rb /` butun fayl tizimini qidiradi. `fd person.rb / -H` yashirin kataloglarni ham qoʻshib butun fayl tizimini qidiradi.

Toʻliq qoʻllanmani `man fd` orqali topish mumkin.

## bat

[bat](https://github.com/sharkdp/bat) sintaksis ajratish, qator raqamlari va sahifalash bilan `cat` dir. `bat somefile.rb` ni ishga tushiring va nima uchun orqaga qaytish qiyinligini koʻrasiz. U boshqa joylarda ham jimgina siz uchun ish qilmoqda: man sahifalaringizni boʻyaydigan ham shu, `ff` dagi koʻrinishlarni chizadigan ham shu.

Toʻliq qoʻllanmani `man bat` orqali topish mumkin.

## tldr

[tldr](https://tldr.sh/) bitta misolni koʻrsatishdan oldin uch ekran tarix bilan ochiladigan man sahifalariga qarshi doridir. `tldr tar` sizga aslida xohlagan bir hovuch chaqiruvlarni beradi.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) YouTube va yuzlab boshqa saytlardan video yuklab oladi. `yt-dlp <url>` mavjud eng yaxshi sifatni joriy katalogga olib keladi.

Toʻliq qoʻllanmani `man yt-dlp` orqali topish mumkin.

## try

[try](https://github.com/tobi/try) sana tamgʻalangan kataloglar bilan dasturlash tajribalarini boshqarishni osonlashtiradi. Barcha tajribalar `~/Work/tries` da yashaydi va ularga `try` orqali kirishingiz mumkin.

Omarchy loyihaning `bin/` katalogini `PATH` ga avtomatik qoʻshmaydi. Ishonchli loyiha-mahalliy vositalarni `bin/rails` yoki `./bin/dev` kabi aniq nisbiy yoʻl bilan ishga tushiring.
