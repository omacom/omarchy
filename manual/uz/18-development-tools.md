# Dasturlash vositalari

## Muqobil tahrirlagichlar

Omarchy yangi o'rnatishlarda standart tahrirlagich sifatida Plain bilan birga keladi va [Neovim](https://neovim.io/) oldindan o'rnatilgan, lekin agar sizga biroz ko'proq keng tarqalgan va tanishroq narsa kerak bo'lsa, Omarchy Menu (`Super + Space`) ni ochib, _Install > Editor_ ostidagi variantlarni ko'rishingiz mumkin. U yerda VSCode, Cursor, Zed, Sublime Text, Helix, Vim va Emacs ro'yxatda bor. Izlayotgan narsangizni topa olmasangiz, _Install > Package_ ni ko'rib chiqing va u Arch paketida yo'qligini tekshiring (agar yo'q bo'lsa, AUR ni tekshirish uchun _Install > AUR_ ni sinab ko'ring).

Asl `vi` tahrirlagichi ham qutidan chiqishi bilanoq mavjud. Terminalda faylni tahrirlash uchun `vi filename` ni ishga tushiring.

Mavzuga moslashtirish `VSCode`, `Cursor`, `VSCodium` va `Helix` uchun taklif etiladi.

Butun tizim bo'yicha standart tahrirlagichni `Setup > Defaults > Editor` ostida belgilashingiz mumkin.

## Muhit

Omarchy Omarchy Menu (`Super + Space`) ning _Install > Development_ bo'limi orqali juda ko'p dasturlash muhitlarini sozlashni qo'llab-quvvatlaydi. Albatta, u yerda _Ruby on Rails_ ni topasiz, shuningdek JavaScript uchun barcha uchta asosiy ishga tushirish muhitini (Node.js, Bun, Deno), hamda Laravel va Symfony kabi mashhur PHP freymvorklarini ham. Oh, yana Go, Rust, Python, Java, Elixir (Phoenix bilan), .NET, OCaml, Zig, Clojure va Scala ham bor. Bu juda keng tanlov!

Bu muhitlarning aksariyati [Mise](https://mise.jdx.dev/) tomonidan boshqariladi. Bu bitta mashinada dasturlash tilining bir nechta versiyasini o'rnatish va ishga tushirish imkonini beradigan vosita. Bu Ruby uchun rbenv yoki rvm ga, Python uchun virtualenv ga o'xshaydi, lekin u bir qancha turli muhitlar uchun ishlaydi.

Masalan, Ruby ni o'rnatish uchun `mise use -g ruby` ni ishga tushirasiz, bu Ruby ni ham o'rnatadi, ham uni global standart sifatida belgilaydi. Yoki loyihangizda .ruby-version fayli bo'lsa, o'sha loyihaning ildizida shunchaki `mise i` ni ishga tushirishingiz mumkin.

## Oldindan o'rnatilgan CLI vositalari

Omarchy `gh`, `uv` kabi vositalarni va aksariyat [kodlash agentlarini](17-ai.md) [mise'ning dangasa o'rnatishi](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) orqali taqdim etadi. Ulardan birini birinchi marta ishga tushirganingizda, mise uni o'rnatadi. Kodlash agentlari keyin ishga tushishdan oldin yangilanish bor-yo'qligini tekshiradi, ko'pi bilan har to'rt soatda bir marta; `gh` va `uv` kabi boshqa vositalar esa siz yangilamaguningizcha o'rnatilgan versiyadan qayta foydalanadi.

Shuningdek, standartlarni tekshirishingiz yoki ularni oldindan o'rnatishingiz mumkin:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

O'rnatilgan vositalarni Omarchy'ning qolgan qismi bilan birga yangilash uchun `omarchy update` ni ishga tushiring. `mup` taxallusi faqat mise tomonidan boshqariladigan vositalarni yangilaydi. O'z konfiguratsiyangizga boshqa vosita qo'shish uchun `mise use -g <tool>` dan foydalaning.

Python sozlamasi ham mise orqali `uv` ni o'rnatadi. Python dasturlash muhitini olib tashlash `uv` ni mustaqil vosita sifatida mavjud bo'lib qolishiga ta'sir qilmaydi.

### O'zingizning o'rnatmangizdan foydalanish

mise'ning buyruqlari `PATH` da `~/.local/bin` dan oldin keladi, shuning uchun o'zingiz o'rnatgan vosita, masalan Claude Code yoki Cursor'ning o'z o'rnatuvchisi bilan o'rnatgan bo'lsangiz ham, baribir mise'ning nusxasi ishga tushadi. Ish stolidan ishga tushirilgan ilovalar ham mise'ning buyruqlarini tizim paketlaridan oldin topadi, shuning uchun `gh` ni ishga tushiradigan ilova, siz `github-cli` ni pacman bilan o'rnatgan bo'lsangiz ham, mise'ning nusxasini oladi va mise bu nusxani birinchi martada o'rnatadi. Buning o'rniga o'zingiznikidan foydalanish uchun `~/.config/mise/config.toml` da mise'ning nusxasini o'chirib qo'ying. Masalan, agar Cursor CLI ni o'zingiz o'rnatgan bo'lsangiz:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Agar sizda allaqachon `[settings]` jadvali bo'lsa, yozuvni o'sha yerga qo'shing; mavjud `disable_tools` ro'yxatini almashtirish o'rniga uni kengaytiring. O'rnatmangiz `PATH` da ekanligiga ishonch hosil qiling. mise vosita nomidan foydalaning, u uning buyrug'idan farq qilishi mumkin: masalan, `oh-my-pi` `omp` ni taqdim etadi. Standart agentni ishga tushiruvchi ham `~/.local/bin` dagi foydalanuvchi o'rnatgan Cursor yoki Muse'ni afzal ko'radi.

### Standartlarni olib tashlash va tiklash

_Remove > Preinstalls_ Omarchy'ning oldindan o'rnatilgan veb-ilovalari, TUI lari va ilovalarini olib tashlaydi va ularni `~/.config/mise/miserc.toml` dagi `ignored_config_paths` ga qo'shish orqali mise'ga sizning foydalanuvchingiz uchun Omarchy'ning vosita e'lonlarini o'tkazib yuborishni buyuradi. _Install > Preinstalls_ ularni qaytarib olib keladi va o'sha qatorni yana olib tashlaydi. O'zingiz e'lon qilgan vositalar, o'z konfiguratsiyangizda yoki loyihaning `mise.toml` ida bo'lsin, har qanday holatda ham ishlashda davom etadi. Agar oldindan o'rnatilganlarni olib tashlaganingizdan keyin standart agentni tanlasangiz yoki Python ni sozlasangiz, o'sha vosita o'z konfiguratsiyangizga qo'shiladi. mise sozlamasi faqat sizning foydalanuvchingizga tegishli, boshqa foydalanuvchilar esa o'z tanlovini saqlab qoladi; ilovalar paketlar bo'lgani uchun esa, ularni olib tashlash yoki tiklash ularni mashinadagi hamma uchun o'zgartiradi.

## Docker

[Docker](https://www.docker.com/) ni deyarli tanishtirish shart emas. U sizga izolyatsiyalangan konteynerlarni ishga tushirish imkonini beradi va Omarchy uni yaxshi ishlashi uchun kerak bo'lgan hamma narsani, jumladan Docker'ning o'zini va [Docker Compose](https://docs.docker.com/compose/) ni o'rnatadi.

Standart bo'yicha sizning foydalanuvchingiz `docker` guruhida *emas*. Bu guruh amalda parolsiz root hisoblanadi — undagi har qanday narsa `docker run -v /:/host` ni ishga tushirib, mashinani egallab olishi mumkin — shuning uchun siz sifatida ishlayotgan bitta yovuz skript yoki bog'liqlik aks holda root dan bitta buyruq uzoqlikda bo'lardi. Shuning uchun buyruq qatorida siz Docker ni `sudo` bilan ishga tushirasiz (`sudo docker ps`, `sudo docker compose up`), daemon bilan gaplashadigan grafik vositalar — Windows VM — esa kerak bo'lganda avtorizatsiya so'raydi. Agar guruhsiz sozlash qulayligini qaytarishni xohlasangiz va almashinuvni tushunsangiz, uni **Setup > Security > Sudoless Docker** dan yoqing (yoki `omarchy-setup-security-sudoless-docker` ni ishga tushiring), bu ogohlantirishdan keyin sizni `docker` guruhiga qo'shadi; keyin oddiy `docker` va `d` taxallusi yana `sudo` siz ishlaydi.

Omarchy menyusidagi _Install > Development > Docker DB_ yordamida Docker da mahalliy dasturlash uchun keng tarqalgan ma'lumotlar bazalarini sozlashingiz mumkin.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) terminaldan repozitoriylar, issue lar va pull request lar bilan ishlash uchun `gh` sifatida mavjud. Uni birinchi foydalanishda o'rnatish va autentifikatsiya qilish uchun `gh auth login` ni ishga tushiring, keyin repozitoriyni klonlash uchun `gh repo clone org/repo` ni ishga tushiring. Uning buyruqlarini o'rganish uchun `gh --help` ni ishga tushiring.

Pull request lar uchun terminal interfeysi uchun `ghui` ni ishga tushiring; mise uni ham birinchi foydalanishda o'rnatadi. Git'ning o'zi bilan ishlash uchun [Lazygit](https://github.com/jesseduffield/lazygit) oldindan o'rnatilgan.
