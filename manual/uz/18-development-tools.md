# Dasturlash vositalari

## Muqobil muharrirlar

Omarchy yangi o'rnatishlarda standart muharrir sifatida Plain bilan keladi va [Neovim](https://neovim.io/) oldindan o'rnatilgan, lekin agar sizga biroz kengroq tarqalgan va tanishroq narsa kerak bo'lsa, Omarchy Menu (`Super + Space`) ni ishga tushirib, _Install > Editor_ ostidagi variantlarni ko'rishingiz mumkin. U yerda VSCode, Cursor, Zed, Sublime Text, Helix, Vim va Emacs ro'yxati bor. Agar izlaganingizni topmasangiz, _Install > Package_ ni ko'rib chiqing va u Arch paketida yo'qmi, tekshiring (agar yo'q bo'lsa, AUR ni tekshirish uchun _Install > AUR_ ni sinab ko'ring).

Original `vi` muharriri ham qutidan chiqiboq mavjud. Terminalda faylni tahrirlash uchun `vi filename` ni ishga tushiring.

Mavzuga moslashtirish `VSCode`, `Cursor`, `VSCodium` va `Helix` uchun taklif qilinadi.

Tizim bo'ylab standart muharrirni `Setup > Defaults > Editor` ostida belgilashingiz mumkin.

## Muhit

Omarchy Omarchy Menu (`Super + Space`) ning _Install > Development_ bo'limi orqali juda ko'p dasturlash muhitlarini sozlashni qo'llab-quvvatlaydi. Albatta _Ruby on Rails_ ni topasiz, shuningdek JavaScript uchun uchta asosiy runtime (Node.js, Bun, Deno) ni ham, Laravel va Symfony kabi mashhur PHP freymvorklarini ham. Oh, yana Go, Rust, Python, Java, Elixir (Phoenix bilan), .NET, OCaml, Zig, Clojure va Scala ham bor. Bu juda keng tanlov!

Bu muhitlarning aksariyati [Mise](https://mise.jdx.dev/) tomonidan boshqariladi. Bu bitta mashinada dasturlash tilining bir nechta versiyasini o'rnatish va ishga tushirish imkonini beradigan vosita. Bu Ruby uchun rbenv yoki rvm, Python uchun virtualenv kabidir, lekin u juda ko'p turli muhitlar uchun ishlaydi.

Masalan, Ruby ni o'rnatish uchun `mise use -g ruby` ni ishga tushirasiz, bu Ruby ni ham o'rnatadi, ham uni global standart sifatida belgilaydi. Yoki loyihangizda .ruby-version fayli bo'lsa, o'sha loyiha ildizida shunchaki `mise i` ni ishga tushirishingiz mumkin.

## Oldindan o'rnatilgan CLI vositalari

`uv`, Node.js va `playwright-cli` (agentlar o'rnatilgan Chrome yordamida brauzerni boshqarishi uchun) paketlar sifatida o'rnatilgan holda keladi va `omarchy update` ularni tizimning qolgan qismi bilan birga yangilab turadi. [Hunk](https://github.com/modem-dev/hunk) hamda GitHub, Basecamp, Cloudflare va HEY CLI lari _Install > CLI_ ostida bir tanlov uzoqlikda, [kod yozish agentlari](17-ai.md) esa _Install > AI > CLI_ ostida.

mise faqat _Install > Development_ dan siz sozlagan runtime larni boshqaradi; Omarchy uning orqali o'zicha hech narsa o'rnatmaydi. Ularni Omarchy ning qolgan qismi bilan birga yangilash uchun `omarchy update` ni ishga tushiring; `mup` taxallusi faqat mise boshqargan vositalarni yangilaydi. O'z konfiguratsiyangizga boshqa vosita qo'shish uchun `mise use -g <tool>` dan foydalaning.

## Docker

[Docker](https://www.docker.com/) ni deyarli tanishtirish shart emas. U izolyatsiya qilingan konteynerlarni ishga tushirish imkonini beradi va Omarchy uni yaxshi ishlashi uchun kerak bo'lgan hamma narsani, jumladan Docker ning o'zini va [Docker Compose](https://docs.docker.com/compose/) ni o'rnatadi.

Standart holatda foydalanuvchingiz `docker` guruhida *emas*. Bu guruh amalda parolsiz root dir — undagi har qanday narsa `docker run -v /:/host` ni ishga tushirib, mashinani egallab olishi mumkin — shuning uchun siz sifatida ishlayotgan bitta yovuz skript yoki bog'liqlik aks holda root ga bitta buyruq uzoqlikda bo'lardi. Shuning uchun buyruq satrida Docker ni `sudo` bilan ishga tushirasiz (`sudo docker ps`, `sudo docker compose up`), daemon bilan gaplashadigan grafik vositalar — Windows VM — kerak bo'lganda avtorizatsiya so'raydi. Agar guruhsiz sozlamaning qulayligini qaytarishni istasangiz va murosani tushunsangiz, uni **Setup > Security > Sudoless Docker** dan yoqing (yoki `omarchy-setup-security-sudoless-docker` ni ishga tushiring), bu ogohlantirishdan keyin sizni `docker` guruhiga qo'shadi; shundan keyin oddiy `docker` va `d` taxallusi yana `sudo` siz ishlaydi.

Omarchy menyusidagi _Install > Development > Docker DB_ orqali mahalliy dasturlash uchun keng tarqalgan ma'lumotlar bazalarini Docker da sozlashingiz mumkin.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) — bu terminaldan repozitoriylar, issue lar va pull request lar bilan ishlash uchun `gh`. _Setup > Git_ uni u yerda GitHub ga kirishni tanlaganingizda o'rnatadi, yoki uni alohida _Install > CLI > GitHub_ dan o'rnating. Keyin `gh repo clone org/repo` repozitoriyni klonlaydi; uning buyruqlarini o'rganish uchun `gh --help` ni ishga tushiring.

[Lazygit](https://github.com/jesseduffield/lazygit) Git ning o'zi bilan ishlash uchun oldindan o'rnatilgan.
