# Almaştirgichlar, Boşda turuş va Ekran saqlağich

Kundalik oʻzgartiradigan narsalaringizning koʻpi aslida sozlama emas. Bu bir soatga yoqib, keyin yana oʻchirib qoʻyadigan rejim: kech ishlayotganingizda tungi yorugʻlik, taqdimot qilayotganingizda bezovta qilinmaslik, biror narsa tomosha qilayotganingizda uygʻoq turish. Omarchy bularni almaştirgichlar deb ataydi va ularning barchasi bir xil ishlaydi — tez klavish, menyu bandi va buyruq, barchasi bitta almaştirgichga uriladi.

### Almaştirgich menyusi

`Super + Ctrl + O` toʻgʻridan-toʻgʻri _Trigger > Toggle_ ni ochadi, yoki u yerga Omarchy menyusidan (`Super + Space`) borishingiz mumkin. Roʻyxatdagi hamma narsa holat qayerda saqlanishi haqida oʻylamasdan almashtira oladigan almaştirgichdir. Ish stoli qanday koʻrinishiga oid almaştirgichlar uning yonida, _Appearance_ ostida joylashgan.

Terminaldan xuddi shu almaştirgichlar `omarchy toggle <thing>` dir. Butun guruhni koʻrish uchun `omarchy toggle` ni oʻzini ishga tushiring.

| Almaştirgich | Tez klavish | Buyruq |
| ------ | ------ | ------- |
| Tungi yorugʻlik | — | `omarchy toggle nightlight` |
| Bildirishnomalarni jim qilish | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Uygʻoq turish (boʻsh vaqtda qulf yoʻq) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Buzilishlarni yozib olish | — | `omarchy toggle crash-capture` |
| Ekran saqlagich | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) mavzu sinxronizatsiyasi | — | `omarchy toggle theme sync` |
| Menyu paneli | `Super + Shift + Space` | `omarchy toggle bar` |
| Sensorli panel | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Sensorli ekran | — | `omarchy toggle touchscreen` |
| Kutish rejimi | — | `omarchy toggle suspend` |
| Gibrid GPU | — | `omarchy toggle hybrid gpu` |

Sensorli panel, sensorli ekran va gibrid GPU almaştirgichlari Toggle ostida emas, _Trigger > Hardware_ (`Super + Ctrl + H`) ostida joylashgan, chunki ular faqat sizda chindan ham oʻsha apparat boʻlgandagina koʻrinadi. Sensorli panel va sensorli ekran almaştirgichlari Hyprland qayta yuklanishidan keyin ham saqlanib qoladi — oʻchirilgan qurilmaning nomi kichik holat fayliga saqlanadi, Hyprland ishga tushganda uni oʻqib, qurilmani yana oʻchiradi.

_Appearance_ menyu paneli va animatsiyalarni, shuningdek `omarchy toggle` buyruqlari boʻlmasa ham xuddi shunday ishlaydigan bir nechta narsani oʻz ichiga oladi: paneldagi batareya foizi, standart ish maydoni tartibi va _Windows_ ostida oyna boʻshliqlari (`Super + Shift + Backspace`) hamda 1 oynali kvadrat nisbat (`Super + Ctrl + Backspace`).

Ularning aksariyati shunchaki `~/.local/state/omarchy/toggles/` ostidagi bayroq faylidir. Agar skriptda ulardan biriga qarab shart tekshirmoqchi boʻlsangiz, `omarchy-toggle-enabled` sizni izlab yurishga majburlamasdan chiqish kodini beradi:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayroqlar oʻchirilgan holat uchun nomlangan — `screensaver-off`, `suspend-off`, `bar-off` — shuning uchun ularning mavjudligi funksiya oʻchirilganligini bildiradi.

### Paneldagi indikatorlar

Rejim yoqilganda, soat yonidagi yuqori panelning oʻrtasida kichik glif paydo boʻladi. Bu indikatorlar vidjeti boʻlib, u diktovkani, ekran yozuvini, kutilayotgan eslatmalarni, tungi yorugʻlikni, bezovta qilinmaslikni va uygʻoq turishni oʻz ichiga oladi.

Faol boʻlmagan indikatorlar yashiriladi. Sichqonchani panelning istalgan joyiga olib boring va ular xira holda paydo boʻladi, shunda tez klavishini bilmasdan ham yoqish uchun ulardan birini bosishingiz mumkin. Faolini bosish uni yana oʻchiradi. Agar ularning barchasini doim koʻrishni istasangiz, `~/.config/omarchy/shell.json` dagi `omarchy.indicators` yozuvi uchun `alwaysShow` ni `true` ga oʻrnating — panel vidjetlari qanday sozlanishi uchun [yuqori panel](05-the-top-bar.md) ga qarang.

### Tungi yorugʻlik

Tungi yorugʻlik ekranni 4000K gacha ilitadi, uni yana almashtirish esa 6500K ga qaytaradi. Uni almaştirgich menyusidan (`Super + Ctrl + O`) yoki `omarchy toggle nightlight` bilan almashtiring. U hyprsunset tomonidan boshqariladi, almaştirgich agar u allaqachon ishlamayotgan boʻlsa, uni siz uchun ishga tushiradi.

Standart boʻyicha hyprsunset ekraningizga umuman hech narsa qilmaydi. `~/.config/hypr/hyprsunset.conf` aynan shunday oʻzgarmas profil bilan keladi, toki siz iliqlik soʻramaguningizcha displey tegilmasdan qoladi. Agar uning soat boʻyicha almashishini istasangiz, uni vaqt profili bilan almashtiring:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Soʻngra `~/.config/hypr/autostart.lua` ga `o.launch_on_start("hyprsunset")` qoʻshib, hyprsunset ni tizimga kirishda ishga tushiring. Almaştirgich ishlatadigan 4000K/6500K juftligi qatʼiy belgilangan, shuning uchun boshqa harorat istasangiz konfiguratsiya fayliga borishingiz kerak.

### Bezovta qilinmaslik

`Super + Ctrl + Alt + ,` bildirishnomalarni jim qiladi. U yoqilgan paytda hech qanday qalqib chiquvchi xabarlar chiqmaydi va paneldagi ustiga chiziq tortilgan qoʻngʻiroq indikatori ish stoli nima uchun jim boʻlib qolganini eslatib turadi.

Lekin hech narsa yoʻqolmaydi. Jim qilingan bildirishnomalar ushlab turiladi: oxirgi bir nechtasini `Super + Shift + Alt + ,` bilan ekranga qaytaring. Qolganlari uchun [xabarnomalar](10-notices.md) ga qarang.

Ikki turdagi xabar baribir oʻtib ketadi: siz hozirgina qilgan ishingiz uchun Omarchy ning oʻz tasdiqlash qalqib chiquvchi xabarlari ("Theme changed", "Screenshot saved") va buyruq satridan yuborilgan muhim ogohlantirishlar. Hamma narsani sizning oldingizga majburlab chiqish uchun muhim deb belgilaydigan chat ilovalari bunga kirmaydi.

### Boʻshda turish

Omarchy qobigʻi boʻshda turish xatti-harakatini boshqaradi va vaqtlar `~/.config/omarchy/shell.json` dagi yuqori darajadagi `idle` blokidir:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ikkala raqam ham siz boʻsh qolgan paytdan boshlab sanaladigan soniyalar — bir-biridan emas. Shunday qilib, standart qiymatlar bilan ekran saqlagich ikki yarim daqiqadan keyin chiqadi va qulflash ekrani ekran saqlagich ishlagan-ishlamaganidan qatʼi nazar besh daqiqada egallaydi. Faylni saqlang va qobiq yangi vaqtlarni darhol qabul qiladi.

Agar qulflash muddatidan oldin ekran saqlagichni yopsangiz, bu faollik hisoblanadi va kutilayotgan qulflash bekor qilinadi. Mashinangizga bir qarab qoʻyganingiz uchun qulflanib qolmaysiz.

Boʻsh vaqtda qulflashni butunlay toʻxtatish uchun `Super + Ctrl + I` — yoki `omarchy toggle idle` — uygʻoq turishni yoqadi va panelda kofe chashkasi indikatori paydo boʻladi. Uzoq taqdimot yoki tomosha qilmoqchi boʻlgan yigʻishdan oldin bosiladigan tugma shu. Normal holatga qaytish uchun uni yana bosing. `omarchy toggle idle status` kerak boʻlsa skriptdan foydalanish uchun joriy holatni JSON sifatida chop etadi.

Bu quvvat haqida emas, qulflash va ekran saqlagich haqida. Kutish va qish uyqusi rejimlarining oʻz sozlamalari [tizim uyqusi](36-system-sleep.md) da bor.

### Ekran saqlagich

Omarchy ekran saqlagichi har bir monitor uchun bitta nusxada tasodifiy matn effektlari orqali ishlaydigan ASCII sanʼatdir. Har qanday tugma yoki sichqoncha harakati undan chiqadi.

Uni talab boʻyicha _System > Screensaver_ (`Super + Esc`) dan ishga tushirishingiz mumkin, bu boʻsh vaqtdagi ekran saqlagichni oʻchirib qoʻygan boʻlsangiz ham uni majburan chiqaradi. Standart boʻyicha unga hech qanday tez klavish bogʻlanmagan.

Agar ishdan toʻgʻridan-toʻgʻri qulflangan holatga oʻtishni afzal koʻrsangiz, `omarchy toggle screensaver` boʻsh vaqtdagi ekran saqlagichni oʻchiradi. Har qanday tugma, bosish, aylantirish yoki sichqoncha harakati uni yopadi.

U chizadigan logotipni _Appearance > Branding > Screensaver_ ostida oʻzgartirishingiz mumkin. png yoki svg yuklang va Omarchy uni ASCII ga aylantiradi. [brending](41-branding.md) ga qarang.

### Qulflash ekrani

`Super + Ctrl + L` mashinani qulflaydi. Bu Omarchy qobigʻidan qulflash ekranini ishga tushiradi, displeyni qoraytiradi, parolingizni notoʻgʻri alifboda yozmasligingiz uchun klaviatura tartibini birinchisiga qaytaradi va — agar u ishlayotgan boʻlsa — chiqishda 1Password ni qulflaydi.

Qulflash ekrani parolni qabul qiladi va barmoq izini oʻrnatganingizdan keyin uni ham qabul qiladi. Bu va autentifikatsiyaning boshqa usullari [apparat autentifikatsiyasi](37-hardware-authentication.md) da yoritilgan.
