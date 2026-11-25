# Ishlab chiqish vositalari

## Muqobil muharrirlar

Omarchy yangi o'rnatishlarda standart muharrir sifatida Plain bilan birga keladi va [Neovim](https://neovim.io/) oldindan o'rnatilgan, lekin agar siz biroz kengroq tarqalgan va tanishroq narsani istasangiz, Omarchy Menu (`Super + Space`) ni ishga tushirib, _Install > Editor_ bo'limidagi variantlarni ko'rishingiz mumkin. U yerda VSCode, Cursor, Zed, Sublime Text, Helix, Vim va Emacs ro'yxati bor. Agar qidirayotganingizni topa olmasangiz, _Install > Package_ bo'limini ko'rib chiqing va u Arch paketi sifatida mavjudligini tekshiring (va agar mavjud bo'lmasa, AUR ni tekshirish uchun _Install > AUR_ ni sinab ko'ring).

Asl `vi` muharriri ham tayyor holatda mavjud. Terminalda faylni tahrirlash uchun `vi filename` ni ishga tushiring.

Mavzuga moslashtirish `VSCode`, `Cursor`, `VSCodium` va `Helix` uchun taklif etiladi.

Tizim bo'yicha standart muharrirni `Setup > Defaults > Editor` bo'limida o'rnatishingiz mumkin.

## Muhit

Omarchy Omarchy Menu (`Super + Space`) ning _Install > Development_ bo'limi orqali juda ko'p ishlab chiqish muhitlarini sozlashni qo'llab-quvvatlaydi. Siz albatta _Ruby on Rails_ ni topasiz, shuningdek JavaScript uchun uchta asosiy runtime (Node.js, Bun, Deno) ni, shuningdek Laravel va Symfony kabi mashhur PHP freymvorklarini ham. Ha, yana Go, Rust, Python, Java, Elixir (Phoenix bilan), .NET, OCaml, Zig, Clojure va Scala ham bor. Bu juda keng tanlov!

Ushbu muhitlarning aksariyati [Mise](https://mise.jdx.dev/) tomonidan boshqariladi. Bu bitta mashinada dasturlash tilining bir nechta versiyasini o'rnatish va ishga tushirish imkonini beradigan vositadir. Bu Ruby uchun rbenv yoki rvm ga yoki Python uchun virtualenv ga o'xshaydi, lekin u bir qancha turli muhitlar uchun ishlaydi.

Masalan, Ruby ni o'rnatish uchun `mise use -g ruby` ni ishga tushirasiz, bu ham Ruby ni o'rnatadi, ham uni global standart sifatida belgilaydi. Yoki, agar loyihangizda .ruby-version fayli bo'lsa, o'sha loyihaning ildiz katalogida shunchaki `mise i` ni ishga tushirishingiz mumkin.

## Oldindan o'rnatilgan CLI vositalari

`uv`, Node.js va `playwright-cli` (agentlar o'rnatilgan Chrome dan foydalanib brauzerni boshqarishi uchun) paketlar sifatida o'rnatilgan holda keladi va `omarchy update` ularni tizimning qolgan qismi bilan birga dolzarb holatda saqlaydi. `ghui`, [Hunk](https://github.com/modem-dev/hunk) hamda Basecamp, Cloudflare va HEY CLI lari _Install > CLI_ bo'limida bir tanlov narida, [kod yozuvchi agentlar](17-ai.md) esa _Install > AI > CLI_ bo'limida.

mise faqat _Install > Development_ bo'limidan siz sozlagan runtime larni boshqaradi; Omarchy o'zi orqali hech narsa o'rnatmaydi. Ularni Omarchy ning qolgan qismi bilan birga yangilash uchun `omarchy update` ni ishga tushiring; `mup` taxallusi faqat mise boshqaruvi ostidagi vositalarni yangilaydi. O'z konfiguratsiyangizga boshqa vosita qo'shish uchun `mise use -g <tool>` dan foydalaning.

## Docker

[Docker](https://www.docker.com/) ni deyarli tanishtirish shart emas. U izolyatsiya qilingan konteynerlarni ishga tushirish imkonini beradi va Omarchy uni yaxshi ishlashi uchun kerak bo'lgan hamma narsani, jumladan Docker ning o'zini va [Docker Compose](https://docs.docker.com/compose/) ni o'rnatadi.

Standart holatda sizning foydalanuvchingiz `docker` guruhida *emas*. Bu guruh amalda parolsiz root dir — undagi har qanday narsa `docker run -v /:/host` ni ishga tushirib, mashinani egallab olishi mumkin — shuning uchun siz sifatida ishlaydigan bitta yovuz skript yoki bog'liqlik aks holda root ga bitta buyruq qolganida yetib borgan bo'lardi. Shuning uchun buyruq satrida siz Docker ni `sudo` bilan ishga tushirasiz (`sudo docker ps`, `sudo docker compose up`), va demon bilan muloqot qiladigan grafik vositalar — Windows VM — kerak bo'lganda avtorizatsiya so'raydi. Agar guruhsiz sozlamaning qulayligini qaytarishni istasangiz va bu murosani tushunsangiz, uni **Setup > Security > Sudoless Docker** bo'limidan yoqing (yoki `omarchy-setup-security-sudoless-docker` ni ishga tushiring), bu ogohlantirishdan so'ng sizni `docker` guruhiga qo'shadi; shundan keyin oddiy `docker` va `d` taxallusi yana `sudo` siz ishlaydi.

Omarchy menyusidagi _Install > Development > Docker DB_ yordamida mahalliy ishlab chiqish uchun umumiy ma'lumotlar bazalarini Docker da sozlashingiz mumkin.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) bu `gh` bo'lib, terminaldan repozitoriylar, issue lar va pull request lar bilan ishlash uchun mo'ljallangan. _Setup > Git_ u yerda GitHub ga kirishni tanlaganingizda uni o'rnatadi, so'ng `gh repo clone org/repo` repozitoriyni klonlaydi. Uning buyruqlarini ko'rib chiqish uchun `gh --help` ni ishga tushiring.

_Install > CLI > GitHub_ GitHub CLI, `gh` ni, pull request lar uchun terminal interfeysi bo'lgan `ghui` bilan birga o'rnatadi. [Lazygit](https://github.com/jesseduffield/lazygit) Git ning o'zi bilan ishlash uchun oldindan o'rnatilgan.
