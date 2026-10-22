# Dasturlash vositalari

## Muqobil muharrirlar

Omarchy standart tarzda [Neovim](https://neovim.io/) bilan keladi, lekin yanada keng tarqalgan va tanish boʻlgan narsani istasangiz, Omarchy menyusini (`Super + Space`) ishga tushirib, _Oʻrnatish > Editor_ ostidagi variantlarni koʻrishingiz mumkin. U yerda VSCode, Cursor, Zed, Sublime Text, Helix, Vim va Emacs roʻyxatda bor. Izlagan narsangizni topmasangiz, _Oʻrnatish > Package_ ni tekshiring va u Arch paketida bor-yoʻqligini koʻring (agar boʻlmasa, AUR ni tekshirish uchun _Oʻrnatish > AUR_ ni sinab koʻring).

Asl `vi` muharriri ham qutidan chiqqanidayoq mavjud. Terminalda faylni tahrirlash uchun `vi filename` ni ishga tushiring.

Mavzu moslashtirish `VSCode`, `Cursor`, `VSCodium` va `Helix` uchun taklif etiladi.

Tizim boʻylab standart muharrirni `Sozlash > Defaults > Editor` ostida belgilashingiz mumkin.

## Muhit

Omarchy Omarchy menyusidagi (`Super + Space`) _Oʻrnatish > Development_ boʻlimi orqali juda koʻp dasturlash muhitlarini sozlashni qoʻllab-quvvatlaydi. Albatta _Ruby on Rails_ ni topasiz, lekin shu bilan birga JavaScript uchun uchta asosiy runtime (Node.js, Bun, Deno) hamda Laravel va Symfony kabi mashhur PHP freymvorklarini ham topasiz. Ha, yana Go, Rust, Python, Java, Elixir (Phoenix bilan), .NET, OCaml, Zig, Clojure va Scala ham bor. Bu juda keng tanlov!

Bu muhitlarning koʻpchiligi [Mise](https://mise.jdx.dev/) tomonidan boshqariladi. Bu bir mashinada dasturlash tilining bir nechta versiyasini oʻrnatish va ishga tushirish imkonini beruvchi vosita. U Ruby uchun rbenv yoki rvm, Python uchun virtualenv kabi, lekin turli xil muhitlar uchun ishlaydi.

Masalan, Ruby ni oʻrnatish uchun `mise use -g ruby` ni ishga tushirasiz, bu ham Ruby ni oʻrnatadi, ham uni global standart qilib belgilaydi. Yoki loyihangizda .ruby-version fayli boʻlsa, oʻsha loyiha ildizida shunchaki `mise i` ni ishga tushirishingiz mumkin.

## Docker

[Docker](https://www.docker.com/) deyarli tanishtirishga muhtoj emas. U izolyatsiya qilingan konteynerlarni ishga tushirish imkonini beradi va Omarchy uni yaxshi ishlatish uchun kerak boʻlgan hamma narsani, jumladan Docker ning oʻzini va [Docker Compose](https://docs.docker.com/compose/) ni oʻrnatadi.

Standart tarzda foydalanuvchingiz `docker` guruhida *emas*. Bu guruh amalda parolsiz root hisoblanadi — undagi har qanday narsa `docker run -v /:/host` qilib mashinani egallab olishi mumkin — shuning uchun siz sifatida ishlaydigan bitta yovuz skript yoki qaramlik aks holda root dan bir buyruq narida boʻlardi. Shuning uchun buyruq qatorida Docker ni `sudo` bilan ishga tushirasiz (`sudo docker ps`, `sudo docker compose up`), va demon bilan gaplashadigan grafik vositalar — Windows VM — kerak boʻlganda ruxsat soʻraydi. Agar guruhsiz sozlama qulayligini qaytarishni istasangiz va murosani tushunsangiz, uni **Sozlash > Security > Sudoless Docker** dan yoqing (yoki `omarchy-setup-security-sudoless-docker` ni ishga tushiring), u ogohlantirishdan keyin sizni `docker` guruhiga qoʻshadi; keyin oddiy `docker` va `d` alias yana `sudo` siz ishlaydi.

Mahalliy dasturlash uchun keng tarqalgan maʼlumotlar bazalarini Docker da Omarchy menyusidagi _Oʻrnatish > Development > Docker DB_ yordamida sozlashingiz mumkin.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) GitHub hisobingiz bilan autentifikatsiya qilish va undan foydalanib shaxsiy repozitoriylarni klonlash imkonini beradi. U dangasa yuklanuvchi mise stublaridan biri sifatida ulangan, shuning uchun birinchi marta `gh` ni ishga tushirganingizda, u oʻzini oʻzi oʻrnatadi. Autentifikatsiya qilish uchun `gh auth login` ni ishga tushiring. Keyin `gh repo clone org/repo` yordamida shaxsiy repozitoriylarni checkout qilishingiz mumkin.

Bu buyruq yordamida boshqa koʻplab GitHub amallarini ham bajarishingiz mumkin. Mumkin boʻlgan hamma narsani koʻrish uchun shunchaki `gh` ni ishga tushiring.

Pull requestlaringizni TUI da boshqarish uchun `ghui` uchun ham dangasa oʻrnatiladigan stub bor. Va agar git ning oʻzini ham TUI dan boshqarmoqchi boʻlsangiz, [lazygit](https://github.com/jesseduffield/lazygit) oldindan oʻrnatilgan.
