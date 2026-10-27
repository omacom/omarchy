# Ishlab chiqish vositalari

## Muqobil tahrirlagichlar

Omarchy sukut boʻyicha [Neovim](https://neovim.io/) bilan birga keladi, lekin agar sizga biroz keng tarqalgan va tanishroq narsa kerak boʻlsa, Omarchy Menu (`Super + Space`) ni ishga tushirib, _Oʻrnatish > Tahrirlagich_ ostidagi variantlarni koʻrishingiz mumkin. U yerda VSCode, Cursor, Zed, Sublime Text, Helix, Vim va Emacs roʻyxati bor. Izlaganingizni topa olmasangiz, _Oʻrnatish > Paket_ boʻlimini tekshirib koʻring va u Arch paketi ichida yoʻqmi, koʻring (agar yoʻq boʻlsa, AUR ni tekshirish uchun _Oʻrnatish > AUR_ ni sinab koʻring).

Asl `vi` tahrirlagichi ham qutidan chiqqan holda mavjud. Terminalda faylni tahrirlash uchun `vi filename` buyrugʻini ishga tushiring.

`VSCode`, `Cursor`, `VSCodium` va `Helix` uchun mavzuga moslashtirish taklif etiladi.

Tizim boʻyicha standart tahrirlagichni `Sozlash > Standartlar > Tahrirlagich` ostida belgilashingiz mumkin.

## Muhit

Omarchy Omarchy Menu (`Super + Space`) ning _Oʻrnatish > Ishlab chiqish_ boʻlimi orqali ishlab chiqish muhitlarining butun bir toʻplamini sozlashni qoʻllab-quvvatlaydi. Albatta, u yerda _Ruby on Rails_ ni topasiz, shuningdek JavaScript uchun uchta asosiy runtime (Node.js, Bun, Deno), hamda Laravel va Symfony kabi mashhur PHP freymvorklarini ham. Ha, yana Go, Rust, Python, Java, Elixir (Phoenix bilan), .NET, OCaml, Zig, Clojure va Scala ham bor. Bu juda keng tanlov!

Bu muhitlarning aksariyati [Mise](https://mise.jdx.dev/) tomonidan boshqariladi. Bu sizga bitta kompyuterda dasturlash tilining bir nechta versiyasini oʻrnatish va ishga tushirish imkonini beradigan vosita. Bu Ruby uchun rbenv yoki rvm kabi, Python uchun virtualenv kabi, lekin u turli xil muhitlarning bir qanchasi uchun ishlaydi.

Masalan, Ruby ni oʻrnatish uchun siz `mise use -g ruby` buyrugʻini ishga tushirasiz, bu ham Ruby ni oʻrnatadi, ham uni global standart qilib belgilaydi. Yoki, agar loyihangizda .ruby-version fayli boʻlsa, shunchaki oʻsha loyihaning ildizida `mise i` buyrugʻini ishga tushirishingiz mumkin.

## Oldindan oʻrnatilgan CLI vositalari

Omarchy `gh`, `uv` kabi vositalarni va aksariyat [dasturlash agentlari](17-ai.md) ni [mise ning kechiktirilgan oʻrnatilishi](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) orqali mavjud qiladi. Ulardan birini birinchi marta ishga tushirganingizda, mise uni oʻrnatadi. Keyingi ishga tushirishlar oʻrnatilgan versiyadan qayta foydalanadi; ular har bir ishga tushirishda yangilanish borligini tekshirmaydi.

Standartlarni tekshirishingiz yoki ularni oldindan oʻrnatishingiz ham mumkin:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Oʻrnatilgan vositalarni Omarchy ning qolgan qismi bilan birga yangilash uchun `omarchy update` buyrugʻini ishga tushiring. `mup` taxallusi faqat mise tomonidan boshqariladigan vositalarni yangilaydi. Oʻz konfiguratsiyangizga boshqa vosita qoʻshish uchun `mise use -g <tool>` dan foydalaning.

Python sozlamasi mise orqali `uv` ni ham oʻrnatadi. Python ishlab chiqish muhitini olib tashlash `uv` ni mustaqil vosita sifatida mavjud qoldiradi.

### Oʻzingiz oʻrnatgan nusxadan foydalanish

mise buyruqlari `PATH` da `~/.local/bin` dan oldin keladi, shuning uchun oʻzingiz oʻrnatgan vosita, masalan Claude Code yoki Cursor ning oʻz oʻrnatuvchisi bilan oʻrnatilgani, baribir mise nusxasini ishga tushiradi. Ish stoludan ishga tushirilgan ilovalar ham mise buyruqlarini tizim paketlaridan oldin topadi, shuning uchun `gh` ni ishga tushiradigan ilova, agar siz `github-cli` ni pacman bilan oʻrnatgan boʻlsangiz ham, mise nusxasini oladi va mise oʻsha nusxani birinchi marta oʻrnatadi. Buning oʻrniga oʻzingiznikidan foydalanish uchun mise nusxasini `~/.config/mise/config.toml` da oʻchirib qoʻying. Masalan, agar siz Cursor CLI ni oʻzingiz oʻrnatgan boʻlsangiz:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Agar sizda allaqachon `[settings]` jadvali boʻlsa, yozuvni oʻsha yerga qoʻshing; mavjud `disable_tools` roʻyxatini almashtirish oʻrniga uni kengaytiring. Oʻrnatganingiz `PATH` da ekanligiga ishonch hosil qiling. mise vosita nomidan foydalaning, u uning buyrugʻidan farq qilishi mumkin: masalan, `oh-my-pi` `omp` ni taqdim etadi. Standart agentni ishga tushiruvchi vosita ham `~/.local/bin` dagi foydalanuvchi oʻrnatgan Cursor yoki Muse ni afzal koʻradi.

### Standartlarni olib tashlash va tiklash

_Oldindan oʻrnatilganlarni olib tashlash_ mise ga foydalanuvchingiz uchun Omarchy vosita deklaratsiyalarini oʻtkazib yuborishni buyuradi, ularni `~/.config/mise/miserc.toml` dagi `ignored_config_paths` ga qoʻshish orqali. _Oldindan oʻrnatilganlarni tiklash_ oʻsha qatorni yana olib tashlaydi. Oʻzingiz deklaratsiya qilgan vositalar, oʻz konfiguratsiyangizda yoki loyihaning `mise.toml` ida boʻlsin, har qanday holatda ham ishlashda davom etadi. Agar oldindan oʻrnatilganlarni olib tashlaganingizdan keyin standart agentni tanlasangiz yoki Python ni sozlasangiz, oʻsha vosita oʻz konfiguratsiyangizga qoʻshiladi. Ikkalasi ham faqat foydalanuvchingizga tegishli; kompyuterdagi boshqa foydalanuvchilar oʻz tanlovini saqlab qoladi.

## Docker

[Docker](https://www.docker.com/) ni deyarli tanishtirish shart emas. U sizga izolyatsiya qilingan konteynerlarni ishga tushirish imkonini beradi va Omarchy uni yaxshi ishlashi uchun kerak boʻlgan hamma narsani, jumladan Docker ning oʻzini va [Docker Compose](https://docs.docker.com/compose/) ni oʻrnatadi.

Sukut boʻyicha foydalanuvchingiz `docker` guruhida *emas*. Bu guruh amalda parolsiz root hisoblanadi — undagi har qanday narsa `docker run -v /:/host` buyrugʻini ishga tushirib, kompyuterni egallab olishi mumkin — shuning uchun siz sifatida ishlaydigan bitta yovuz skript yoki bogʻliqlik aks holda root dan bitta buyruq uzoqlikda boʻlardi. Shuning uchun buyruq qatorida siz Docker ni `sudo` bilan ishga tushirasiz (`sudo docker ps`, `sudo docker compose up`), va demon bilan gaplashadigan grafik vositalar — Windows VM — kerak boʻlganda sizdan avtorizatsiya soʻraydi. Agar guruhsiz sozlamaning qulayligini qaytarishni istasangiz va murosani tushunsangiz, uni **Sozlash > Xavfsizlik > Sudosiz Docker** dan yoqing (yoki `omarchy-setup-security-sudoless-docker` buyrugʻini ishga tushiring), bu ogohlantirishdan keyin sizni `docker` guruhiga qoʻshadi; shunda oddiy `docker` va `d` taxallusi yana `sudo` siz ishlaydi.

Mahalliy ishlab chiqish uchun keng tarqalgan maʼlumotlar bazalarini Docker da Omarchy menyusidagi _Oʻrnatish > Ishlab chiqish > Docker DB_ orqali sozlashingiz mumkin.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) terminaldan repozitoriylar, issue lar va pull request lar bilan ishlash uchun `gh` sifatida mavjud. Uni birinchi marta ishlatganda oʻrnatish va autentifikatsiyadan oʻtish uchun `gh auth login` buyrugʻini ishga tushiring, soʻng repozitoriyni klonlash uchun `gh repo clone org/repo` buyrugʻini ishga tushiring. Uning buyruqlarini oʻrganish uchun `gh --help` buyrugʻini ishga tushiring.

Pull request lar uchun terminal interfeysi kerak boʻlsa, `ghui` ni ishga tushiring; mise uni ham birinchi marta ishlatganda oʻrnatadi. Git ning oʻzi bilan ishlash uchun [Lazygit](https://github.com/jesseduffield/lazygit) oldindan oʻrnatilgan.
