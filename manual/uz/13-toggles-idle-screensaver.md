# Almashtirgichlar, bo'sh turish va ekran saqlagichi

Kundalik o'zgartiradigan narsalaringizning ko'pi aslida sozlama emas. Bu bir soatga yoqib, keyin yana o'chirib qo'yadigan rejim: kech ishlayotganingizda tungi yorug'lik, taqdimot qilayotganingizda bezovta qilinmasin, biror narsa tomosha qilayotganingizda uyg'oq turish. Omarchy bularni almashtirgichlar deb ataydi va ularning barchasi bir xil ishlaydi — tezkor tugma, menyu bandi va buyruq, barchasi bitta kalitga tegadi.

### Almashtirgich menyusi

`Super + Ctrl + O` to'g'ridan-to'g'ri _Trigger > Toggle_ ni ochadi yoki Omarchy menyusidan (`Super + Space`) u yerga o'tishingiz mumkin. O'sha ro'yxatdagi hamma narsa holat qayerda saqlanishi haqida o'ylamasdan almashtirishingiz mumkin bo'lgan kalit. Ish stoli qanday ko'rinishi uchun kalitlar uning yonida, _Appearance_ ostida joylashgan.

Terminaldan xuddi shu kalitlar `omarchy toggle <thing>` ko'rinishida bo'ladi. Butun guruhni ko'rish uchun `omarchy toggle` ni o'zini ishga tushiring.

| Almashtirgich | Tezkor tugma | Buyruq |
| ------ | ------ | ------- |
| Tungi yorug'lik | — | `omarchy toggle nightlight` |
| Bildirishnomalarni o'chirish | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Uyg'oq turish (bo'sh turganda qulflanmaslik) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Halokatni yozib olish | — | `omarchy toggle crash-capture` |
| Ekran saqlagichi | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) mavzusini sinxronlash | — | `omarchy toggle theme sync` |
| Menyu paneli | `Super + Shift + Space` | `omarchy toggle bar` |
| Sensor panel | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Sensor ekran | — | `omarchy toggle touchscreen` |
| To'xtatib turish | — | `omarchy toggle suspend` |
| Gibrid GPU | — | `omarchy toggle hybrid gpu` |

Sensor panel, sensor ekran va gibrid GPU kalitlari Toggle ostida emas, _Trigger > Hardware_ (`Super + Ctrl + H`) ostida joylashgan, chunki ular faqat sizda o'sha uskuna haqiqatan bo'lgandagina ko'rinadi. Sensor panel va sensor ekran kalitlari Hyprland qayta yuklanishidan keyin ham saqlanadi — o'chirilgan qurilmaning nomi kichik holat fayliga saqlanadi, Hyprland ishga tushganda uni o'qib, qurilmani yana o'chiradi.

_Appearance_ menyu paneli va animatsiyalarni, shuningdek `omarchy toggle` buyruqlari bo'lmasa ham xuddi shunday ishlaydigan bir nechta narsani o'z ichiga oladi: paneldagi batareya foizi, standart ish maydoni tartibi va _Windows_ ostida oyna bo'shliqlari (`Super + Shift + Backspace`) hamda 1 oynali kvadrat nisbat (`Super + Ctrl + Backspace`).

Hyprland chizish uchun GPU topa olmasa va buning o'rniga CPU da render qilsa (llvmpipe), masalan GPU si hali qo'llab-quvvatlanmaydigan Mac larda, aksariyat virtual mashinalarda yoki grafik drayver yuklanmasa, Omarchy o'sha sessiya uchun animatsiyalar, xiralashtirish va soyalarni o'chiradi va bu haqda bir marta bildirishnoma bilan xabar beradi. _Appearance > Animations On_ ularni qaytaradi va Omarchy buni keyingi sessiyalar uchun ham eslab qoladi.

Bularning aksariyati `~/.local/state/omarchy/toggles/` ostidagi shunchaki bayroq fayli. Agar skriptda ulardan biriga qarab shart tekshirmoqchi bo'lsangiz, `omarchy-toggle-enabled` sizni izlab yurishingizga majbur qilmasdan chiqish kodini beradi:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayroqlar o'chirilgan holat nomi bilan ataladi — `screensaver-off`, `suspend-off`, `bar-off` — shuning uchun ularning mavjudligi funksiya o'chirilganini anglatadi.

### Paneldagi ko'rsatkichlar

Rejim yoqilganida, soat yonidagi yuqori panelning o'rtasida kichik belgi olasiz. Bu ko'rsatkichlar vidjeti bo'lib, u diktovka, ekran yozuvi, kutilayotgan eslatmalar, tungi yorug'lik, bezovta qilinmasin va uyg'oq turishni tashiydi.

Faol bo'lmagan ko'rsatkichlar yashirinadi. Sichqonchani panelning istalgan joyiga olib boring va ular xira ko'rinishda paydo bo'ladi, shunda tezkor tugmasini bilmasdan ham birini bosib yoqishingiz mumkin. Faolini bosish uni yana o'chiradi. Agar ularning hammasini doim ko'rib turishni afzal ko'rsangiz, `~/.config/omarchy/shell.json` dagi `omarchy.indicators` bandida `alwaysShow` ni `true` qilib o'rnating — panel vidjetlari qanday sozlanishi haqida [yuqori panel](05-the-top-bar.md) ga qarang.

### Tungi yorug'lik

Tungi yorug'lik ekranni 4000K gacha ilitadi va uni yana almashtirish 6500K ga qaytaradi. Uni almashtirgich menyusidan (`Super + Ctrl + O`) yoki `omarchy toggle nightlight` bilan almashtiring. U hyprsunset tomonidan boshqariladi, almashtirgich agar u allaqachon ishlamayotgan bo'lsa, uni siz uchun ishga tushiradi.

Standart holatda hyprsunset ekraningizga umuman hech narsa qilmaydi. `~/.config/hypr/hyprsunset.conf` aynan identity profili bilan birga keladi, shunda siz iliqlikni so'ramaguningizcha displey tegilmasdan qoladi. Agar uning o'rniga soat bo'yicha almashishini afzal ko'rsangiz, buni vaqt profili bilan almashtiring:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Keyin tizimga kirishda hyprsunset ni ishga tushirish uchun `~/.config/hypr/autostart.lua` ga `o.launch_on_start("hyprsunset")` ni qo'shing. Almashtirgich ishlatadigan 4000K/6500K juftligi qat'iy belgilangan, shuning uchun boshqa haroratni xohlasangiz, konfiguratsiya fayliga borishingiz kerak.

### Bezovta qilinmasin

`Super + Ctrl + Alt + ,` bildirishnomalarni o'chiradi. U yoqilgan paytda hech qanday qalqib chiquvchi xabarlar chiqmaydi va ustiga chiziq tortilgan qo'ng'iroq ko'rsatkichi ish stoli nima uchun jim bo'lib qolganini eslatish uchun panelda turadi.

Hech narsa yo'qolmaydi. O'chirilgan bildirishnomalar ushlab turiladi: oxirgi bir nechtasini `Super + Shift + Alt + ,` bilan ekranga qaytaring. Qolganlari uchun [xabarlar](10-notices.md) ga qarang.

Ikki turdagi xabar baribir o'tadi: hozirgina qilgan ishingiz uchun Omarchy ning o'z tasdiq xabarlari ("Theme changed", "Screenshot saved") va buyruq satridan yuborilgan muhim ogohlantirishlar. Hamma narsani sizning oldingizga majburlab chiqish uchun muhim deb belgilaydigan chat ilovalari bunga kirmaydi.

### Bo'sh turish

Omarchy qobig'i bo'sh turish xatti-harakatiga egalik qiladi va vaqtlar `~/.config/omarchy/shell.json` dagi yuqori darajadagi `idle` blokida bo'ladi:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ikkala raqam ham bo'sh turishni boshlagan paytingizdan sanaladigan soniyalar — bir-biridan emas. Shunday qilib, standart qiymatlar bilan ekran saqlagichi ikki yarim daqiqadan keyin chiqadi va qulflash ekrani ekran saqlagichi ishlagan-ishlamaganidan qat'i nazar, besh daqiqada o'z o'rnini egallaydi. Faylni saqlang va qobiq yangi vaqtlarni darhol qabul qiladi.

Agar ekran saqlagichini qulflash muddatidan oldin yopsangiz, bu faollik hisoblanadi va kutilayotgan qulf bekor qilinadi. Mashinangizga bir qarab qo'yganingiz uchun qulflanib qolmaysiz.

Bo'sh turganda qulflashni butunlay to'xtatish uchun `Super + Ctrl + I` — yoki `omarchy toggle idle` — uyg'oq turishni yoqadi va panelda kofe piyolasi ko'rsatkichi paydo bo'ladi. Bu uzun taqdimot yoki kuzatib turmoqchi bo'lgan yig'ishdan oldin bosiladigan tugma. Normal holatga qaytish uchun uni yana bosing. Agar skriptdan kerak bo'lsa, `omarchy toggle idle status` joriy holatni JSON sifatida chop etadi.

Bu qulflash va ekran saqlagichi haqida, quvvat haqida emas. To'xtatib turish va uyqu rejimi [tizim uyqusi](36-system-sleep.md) da o'z sozlamalariga ega.

### Ekran saqlagichi

Omarchy ekran saqlagichi tasodifiy matn effektlari orqali o'tadigan ASCII san'ati bo'lib, har bir monitor uchun bitta nusxadan ishlaydi. Har qanday tugma yoki sichqoncha harakati undan chiqadi.

Uni talab bo'yicha _System > Screensaver_ (`Super + Esc`) dan ishga tushirishingiz mumkin, bu bo'sh turgandagi ekran saqlagichini o'chirib qo'ygan bo'lsangiz ham uni majburan chiqaradi. Standart holatda unga hech qanday tezkor tugma biriktirilmagan.

Agar ishlashdan to'g'ridan-to'g'ri qulflangan holatga o'tishni afzal ko'rsangiz, `omarchy toggle screensaver` bo'sh turgandagi ekran saqlagichini o'chiradi. Har qanday tugma, bosish, aylantirish yoki sichqoncha harakati uni yopadi.

U chizadigan logotipni _Appearance > Branding > Screensaver_ ostida o'zgartirishingiz mumkin. png yoki svg yuklang va Omarchy uni ASCII ga aylantiradi. [brending](41-branding.md) ga qarang.

### Qulflash ekrani

`Super + Ctrl + L` mashinani qulflaydi. Bu Omarchy qobig'idan qulflash ekranini ishga tushiradi, displeyni qoraytiradi, parolingizni noto'g'ri alifboda yozmasligingiz uchun klaviatura tartibingizni birinchisiga qaytaradi va — agar u ishlayotgan bo'lsa — chiqishda 1Password ni qulflaydi.

Qulflash ekrani parolni qabul qiladi va siz barmoq izini sozlaganingizdan keyin uni ham qabul qiladi. Bu va autentifikatsiyaning boshqa usullari [uskuna autentifikatsiyasi](37-hardware-authentication.md) da yoritilgan.
