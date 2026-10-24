# Almashtirishlar, boʻsh vaqt va ekran saqlagich

Kundan kunga oʻzgartiradigan koʻp narsa aslida sozlama emas. Bu bir soatga yoqib, yana oʻchiradigan rejim: kech ishlayotganingizda tungi yorugʻlik, taqdimot qilayotganingizda bezovta qilmang, nimadir koʻrayotganingizda uygʻoq qolish. Omarchy ularni almashtirishlar deb ataydi va ularning hammasi bir xil ishlaydi — hotkey, menyu yozuvi va buyruq, hammasi bir xil kalitga uradi.

### Almashtirish menyusi

`Super + Ctrl + O` _Ishga tushirish > Almashtirish_ ni bevosita ochadi yoki u yerga Omarchy menyusidan (`Super + Space`) yurishingiz mumkin. Oʻsha roʻyxatdagi hamma narsa holat qayerda yashashini oʻylamasdan almashtirishingiz mumkin boʻlgan kalitdir. Ish stoli qanday koʻrinishi uchun kalitlar uning yonida, _Ishga tushirish > Koʻrinish_ ostida oʻtiradi.

Terminaldan xuddi shu kalitlar `omarchy toggle <thing>` dir. Butun guruhni koʻrish uchun `omarchy toggle` ni oʻzicha ishga tushiring.

| Almashtirish | Hotkey | Buyruq |
| ------ | ------ | ------- |
| Tungi yorugʻlik | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Bildirishnomalarni ovozsiz qilish | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Uygʻoq qolish (boʻsh qulf yoʻq) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Buzilish qaydi | — | `omarchy toggle crash-capture` |
| Ekran saqlagich | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) mavzu sinxronlash | — | `omarchy toggle theme sync` |
| Menyu paneli | `Super + Shift + Space` | `omarchy toggle bar` |
| Sensor panel | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Sensor ekran | — | `omarchy toggle touchscreen` |
| Kutish | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Sensor panel, sensor ekran va hybrid GPU kalitlari Almashtirish ostida emas, _Ishga tushirish > Qurilmalar_ (`Super + Ctrl + H`) ostida yashaydi, chunki ular faqat sizda oʻsha apparatura haqiqatan boʻlganda paydo boʻladi. Sensor panel va sensor ekran Hyprland qayta yuklanishidan omon qoladi — oʻchirilgan qurilmaning nomi Hyprland ishga tushganda uni yana oʻchirish uchun oʻqiydigan kichik holat fayliga saqlanadi.

_Ishga tushirish > Koʻrinish_ menyu paneli va animatsiyalarni, plyus `omarchy toggle` buyruqlari boʻlmagan, lekin bir xil harakat qiladigan bir necha narsani saqlaydi: paneldagi batareya foizi, standart ish maydoni tartibi, oyna oraliqlari (`Super + Shift + Backspace`) va 1-oyna kvadrat nisbati (`Super + Ctrl + Backspace`).

Bulardan koʻpi shunchaki `~/.local/state/omarchy/toggles/` ostidagi bayroq faylidir. Agar skriptda bittasiga tarmoqlanmoqchi boʻlsangiz, `omarchy-toggle-enabled` sizni qidirishga majbur qilish oʻrniga chiqish kodi beradi:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayroqlar oʻchiq holat uchun nomlangan — `screensaver-off`, `suspend-off`, `bar-off` — demak ularning mavjudligi xususiyat oʻchirilganini anglatadi.

### Paneldagi koʻrsatkichlar

Rejim yoqiq boʻlganda, soat yonidagi yuqori panelning oʻrtasida kichik glif olasiz. Bu koʻrsatkichlar vidjeti boʻlib, u diktovka, ekran yozuvi, kutilayotgan eslatmalar, tungi yorugʻlik, bezovta qilmang va uygʻoq qolishni tashiydi.

Faol boʻlmagan koʻrsatkichlar yashirilgan. Ular atrofidagi maydonni ustiga olib boring va ular xiralashib paydo boʻladi, shuning uchun uning hotkeyini bilmasdan uni yoqish uchun birini bosishingiz mumkin. Faol birini bosish uni orqaga oʻchiradi. Agar ularning hammasini har doim koʻrishni afzal koʻrsangiz, `~/.config/omarchy/shell.json` dagi `omarchy.indicators` yozuvida `alwaysShow` ni `true` ga oʻrnating — panel vidjetlari qanday sozlanishi haqida [yuqori panel](05-the-top-bar.md) ga qarang.

### Tungi yorugʻlik

`Super + Ctrl + N` ekranni 4000K ga isitadi va uni yana bosish 6500K ga qaytaradi. U hyprsunset tomonidan boshqariladi, almashtirish agar u allaqachon ishlamayotgan boʻlsa siz uchun boshlaydi.

Standartda hyprsunset ekraningizga umuman hech narsa qilmaydi. `~/.config/hypr/hyprsunset.conf` displey iliq soʻramaguningizcha tegilmagan qolishi uchun identity profili bilan keladi. Agar uning soat boʻyicha almashishini afzal koʻrsangiz, uni vaqt profili bilan almashtiring:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Keyin `o.launch_on_start("hyprsunset")` ni `~/.config/hypr/autostart.lua` ga qoʻshib, kirishda hyprsunsetni boshlang. Almashtirish ishlatadigan 4000K/6500K juftligi qatʼiy belgilangan, shuning uchun boshqa harorat xohlasangiz konfiguratsiya fayli siz boradigan joydir.

### Bezovta qilmang

`Super + Ctrl + ,` bildirishnomalarni ovozsiz qiladi. U yoqiq paytda hech qanday tost paydo boʻlmaydi va ish stoli nima uchun jim boʻlib qolganini eslatish uchun chizilgan qoʻngʻiroq koʻrsatkichi panelda oʻtiradi.

Ammo hech narsa yoʻqolmaydi. Ovozsiz qilingan bildirishnoma toʻgʻridan-toʻgʻri bildirishnoma tarixingizga yoziladi, bu qaytib kelganingizda va nimani oʻtkazib yuborganingizni qiziqtirganingizda siz xohlagan yozuvdir. Uni `Super + Shift + Alt + ,` bilan oching. Bildirishnoma hikoyasining qolgan qismi uchun [maʼlumotlar](10-notices.md) ga qarang.

Ikki turdagi xabar baribir oʻtadi: siz hozirgina qilgan narsa uchun Omarchyning oʻz tasdiq tostlari ("Mavzu oʻzgardi", "Skrinshot saqlandi") va buyruq qatoridan yuborilgan muhim ogohlantirishlar. Hamma narsani sizning oldingizda majburlash uchun muhim deb belgilaydigan chat ilovalari bunga loyiq emas.

### Boʻsh vaqt

Omarchy shelli boʻsh xulq-atvoriga egalik qiladi va vaqtlar `~/.config/omarchy/shell.json` dagi yuqori darajali `idle` blokidir:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Har ikkala raqam siz boʻsh qolgan paytingizdan sanaladigan soniya — bir-biridan emas. Demak standartlar bilan ekran saqlagich ikki yarim daqiqadan keyin keladi va qulf ekran besh daqiqada egallaydi, ekran saqlagich ishlaganmi yoki yoʻqmi. Faylni saqlang va shell yangi vaqtlarni darhol oladi.

Ekran saqlagichni qulf muddatidan oldin yopsangiz, bu faoliyat hisoblanadi va kutilayotgan qulf bekor qilinadi. Mashinangizga koʻz tashlaganingiz uchun qulflanib qolmaysiz.

Boʻsh vaqtda qulflashni butunlay toʻxtatish uchun `Super + Ctrl + I` — yoki `omarchy toggle idle` — uygʻoq qolishni yoqadi va panelda kofe chashka koʻrsatkichi paydo boʻladi. Bu uzun taqdimotdan yoki kuzatmoqchi boʻlgan yigʻilishdan oldin bosiladigan tugma. Normalga qaytish uchun uni yana bosing. Agar skriptdan kerak boʻlsa, `omarchy toggle idle status` joriy holatni JSON sifatida chop etadi.

Bu quvvat haqida emas, qulflash va ekran saqlagich haqida. Kutish va uyquning oʻz sozlamasi [tizim uyqusi](36-system-sleep.md) da bor.

### Ekran saqlagich

Omarchyning ekran saqlagichi tasodifiy matn effektlarida ishlaydigan ASCII sanʼatidir, har bir monitor uchun bitta namuna. Har qanday tugma yoki sichqoncha harakati undan chiqadi.

Uni _Tizim > Ekran saqlagich_ (`Super + Esc`) dan talab boʻyicha boshlashingiz mumkin, u boʻsh ekran saqlagichni oʻchirgan boʻlsangiz ham uni majbur qiladi. Standartda unga bogʻlangan hotkey yoʻq.

`omarchy toggle screensaver` boʻsh ekran saqlagichni oʻchiradi, agar siz ishlashdan toʻgʻridan-toʻgʻri qulflangan holatga oʻtishni afzal koʻrsangiz. Unga qanday sozlashni biladigan terminal kerak — Alacritty, Foot, Ghostty yoki Kitty — va agar standart terminalingiz boshqa narsa boʻlsa sizga aytadi.

U chizadigan logotipni _Uslub > Ekran saqlagich_ ostida oʻzgartirishingiz mumkin. png yoki svg yuklang va Omarchy uni ASCII ga aylantiradi. [Brending](41-branding.md) ga qarang.

### Qulf ekran

`Super + Ctrl + L` mashinani qulflaydi. Bu Omarchy shellidan qulf ekranni ishga tushiradi, displeyni qorayadi, parolingizni notoʻgʻri alifboda yozmasligingiz uchun klaviatura tartibingizni birinchisiga qaytaradi va — agar ishlatayotgan boʻlsangiz — chiqishda 1Passwordni qulflaydi.

Qulf ekran parol oladi va bir marta oʻrnatganingizdan keyin barmoq izini ham oladi. Bu va autentifikatsiyaning boshqa usullari [apparat autentifikatsiyasi](37-hardware-authentication.md) da yoritilgan.
