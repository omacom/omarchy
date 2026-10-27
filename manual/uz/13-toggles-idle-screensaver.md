# Almashmalar, Bo‘sh turish va Ekran saqlovchisi

Har kuni o‘zgartiradigan narsalaringizning ko‘pi aslida sozlama emas. Bu bir soatga yoqib, keyin yana o‘chirib qo‘yadigan rejim: kech ishlayotganingizda tungi yorug‘lik, taqdimot qilayotganingizda bezovta qilinmaslik, nimadir tomosha qilayotganda uyg‘oq qolish. Omarchy bularni almashmalar deb ataydi va ularning barchasi bir xilda ishlaydi — tezkor tugma, menyu bandi va buyruq, hammasi bitta kalitga tegadi.

### Almashmalar menyusi

`Super + Ctrl + O` _Trigger > Toggle_ ni to‘g‘ridan-to‘g‘ri ochadi yoki u yerga Omarchy menyusidan (`Super + Space`) borishingiz mumkin. O‘sha ro‘yxatdagi hamma narsa holat qayerda saqlanishi haqida o‘ylamasdan yoqib-o‘chirishingiz mumkin bo‘lgan kalitdir. Ish stoli qanday ko‘rinishiga oid kalitlar uning yonida, _Appearance_ ostida joylashgan.

Terminaldan xuddi shu kalitlar `omarchy toggle <thing>` ko‘rinishida bo‘ladi. Butun guruhni ko‘rish uchun `omarchy toggle` ni o‘zini ishga tushiring.

| Almashma | Tezkor tugma | Buyruq |
| ------ | ------ | ------- |
| Tungi yorug‘lik | — | `omarchy toggle nightlight` |
| Bildirishnomalarni jim qilish | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Uyg‘oq qolish (bo‘sh turganda qulflanmaydi) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Qulashlarni qayd etish | — | `omarchy toggle crash-capture` |
| Ekran saqlovchisi | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) mavzu sinxronizatsiyasi | — | `omarchy toggle theme sync` |
| Menyu paneli | `Super + Shift + Space` | `omarchy toggle bar` |
| Sensor panel | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Sensor ekran | — | `omarchy toggle touchscreen` |
| To‘xtatib turish | — | `omarchy toggle suspend` |
| Gibrid GPU | — | `omarchy toggle hybrid gpu` |

Sensor panel, sensor ekran va gibrid GPU kalitlari Toggle ostida emas, _Trigger > Hardware_ (`Super + Ctrl + H`) ostida joylashgan, chunki ular faqat o‘sha apparat haqiqatan ham mavjud bo‘lgandagina ko‘rinadi. Sensor panel va sensor ekran kalitlari Hyprland qayta yuklanishidan keyin ham saqlanib qoladi — o‘chirilgan qurilmaning nomi kichik holat fayliga saqlanadi va Hyprland ishga tushganda uni o‘qib, qurilmani yana o‘chiradi.

_Appearance_ menyu paneli va animatsiyalarni, shuningdek, `omarchy toggle` buyruqlari bo‘lmasa ham xuddi shunday ishlaydigan bir nechta narsani o‘z ichiga oladi: paneldagi batareya foizi, standart ish maydoni tartibi va _Windows_ ostida oyna oraliqlari (`Super + Shift + Backspace`) hamda 1 oynali kvadrat nisbat (`Super + Ctrl + Backspace`).

Bularning ko‘pi shunchaki `~/.local/state/omarchy/toggles/` ostidagi bayroq faylidir. Skriptda birortasiga qarab shart qo‘ymoqchi bo‘lsangiz, `omarchy-toggle-enabled` uni izlab yurishingizga majbur qilmasdan chiqish kodini beradi:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayroqlar o‘chirilgan holat nomi bilan ataladi — `screensaver-off`, `suspend-off`, `bar-off` — shuning uchun ularning mavjudligi funksiya o‘chirilganini bildiradi.

### Paneldagi indikatorlar

Rejim yoqilganida soat yonidagi yuqori panelning o‘rtasida kichik belgi paydo bo‘ladi. Bu indikatorlar vidjeti bo‘lib, u diktofon, ekran yozuvi, kutilayotgan eslatmalar, tungi yorug‘lik, bezovta qilinmaslik va uyg‘oq qolishni o‘z ichiga oladi.

Faol bo‘lmagan indikatorlar yashirinadi. Panelning istalgan joyiga sichqonchani olib boring va ular xira holda ko‘rinadi, shunda tezkor tugmasini bilmasdan ham birini bosib yoqishingiz mumkin. Faol birini bosish uni yana o‘chiradi. Agar ularning hammasini doimo ko‘rib turishni afzal ko‘rsangiz, `~/.config/omarchy/shell.json` dagi `omarchy.indicators` yozuvida `alwaysShow` ni `true` qilib qo‘ying — panel vidjetlari qanday sozlanishini bilish uchun [yuqori panel](05-the-top-bar.md) ga qarang.

### Tungi yorug‘lik

Tungi yorug‘lik ekranni 4000K gacha isitadi va uni yana almashtirish 6500K ga qaytaradi. Uni almashmalar menyusidan (`Super + Ctrl + O`) yoki `omarchy toggle nightlight` bilan yoqib-o‘chiring. Uni hyprsunset boshqaradi, almashma esa u allaqachon ishlamayotgan bo‘lsa, uni siz uchun ishga tushiradi.

Standart holatda hyprsunset ekraningizga umuman hech narsa qilmaydi. `~/.config/hypr/hyprsunset.conf` aynan displey siz iliqlik so‘ramaguningizcha tegilmay turishi uchun identity profili bilan keladi. Agar uning soat bo‘yicha almashishini afzal ko‘rsangiz, uni vaqt profili bilan almashtiring:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Keyin `~/.config/hypr/autostart.lua` ga `o.launch_on_start("hyprsunset")` ni qo‘shib, hyprsunset ni tizimga kirishda ishga tushiring. Almashma ishlatadigan 4000K/6500K juftligi qat’iy belgilangan, shuning uchun boshqa haroratni xohlasangiz, konfiguratsiya fayliga borasiz.

### Bezovta qilinmasin

`Super + Ctrl + Alt + ,` bildirishnomalarni jim qiladi. U yoqilgan paytda hech qanday tostlar chiqmaydi va paneldagi ustidan chiziq tortilgan qo‘ng‘iroq indikatori ish stoli nima uchun jim bo‘lib qolganini eslatib turadi.

Lekin hech narsa yo‘qolmaydi. Jim qilingan bildirishnomalar ushlab turiladi: oxirgi bir nechtasini `Super + Shift + Alt + ,` bilan ekranga qaytaring. Qolganini bilish uchun [bildirishnomalar](10-notices.md) ga qarang.

Ikki turdagi xabar baribir o‘tadi: siz hozirgina qilgan ishingiz uchun Omarchy ning o‘z tasdiqlash tostlari («Mavzu o‘zgartirildi», «Ekran tasviri saqlandi») va buyruq qatoridan yuborilgan muhim ogohlantirishlar. O‘zingizni oldingizga majburan chiqish uchun hamma narsani muhim deb belgilaydigan chat ilovalari bunga kirmaydi.

### Bo‘sh turish

Bo‘sh turishdagi xatti-harakatni Omarchy qobig‘i boshqaradi va vaqtlar `~/.config/omarchy/shell.json` dagi yuqori darajadagi `idle` blokida joylashgan:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ikkala son ham siz bo‘sh qolgan paytdan boshlab sanaladigan soniyalardir — bir-biridan emas. Shunday qilib, standart sozlamalar bilan ekran saqlovchisi ikki yarim daqiqadan keyin chiqadi va qulflash ekrani ekran saqlovchisi ishlagan-ishlamaganidan qat’i nazar besh daqiqada egallaydi. Faylni saqlang va qobiq yangi vaqtlarni darhol qabul qiladi.

Agar qulflash muddatidan oldin ekran saqlovchisini yopib yuborsangiz, bu faollik deb hisoblanadi va kutilayotgan qulflash bekor qilinadi. Mashinangizga bir qarab qo‘yganingiz uchun qulflanib qolmaysiz.

Bo‘sh turganda qulflashni butunlay to‘xtatish uchun `Super + Ctrl + I` — yoki `omarchy toggle idle` — uyg‘oq qolishni yoqadi va panelda qahva piyolasi indikatori paydo bo‘ladi. Uzoq taqdimotdan yoki kuzatmoqchi bo‘lgan yig‘ishdan oldin aynan shuni bosing. Oddiy holatga qaytish uchun uni yana bosing. Agar skriptdan kerak bo‘lsa, `omarchy toggle idle status` joriy holatni JSON sifatida chop etadi.

Bu quvvat haqida emas, qulflash va ekran saqlovchisi haqida. To‘xtatib turish va gibrid uyqu rejimining o‘z sozlamalari [tizim uyqusi](36-system-sleep.md) da joylashgan.

### Ekran saqlovchisi

Omarchy ekran saqlovchisi tasodifiy matn effektlaridan o‘tadigan ASCII art bo‘lib, har bir monitor uchun bittadan nusxada ishlaydi. Har qanday tugma yoki sichqoncha harakati undan chiqadi.

Uni _System > Screensaver_ (`Super + Esc`) dan talab bo‘yicha ishga tushirishingiz mumkin, bu bo‘sh turgandagi ekran saqlovchisini o‘chirib qo‘ygan bo‘lsangiz ham uni majburan chiqaradi. Standart holatda unga hech qanday tezkor tugma bog‘lanmagan.

Agar ishlashdan to‘g‘ridan-to‘g‘ri qulflangan holatga o‘tishni afzal ko‘rsangiz, bo‘sh turgandagi ekran saqlovchisini `omarchy toggle screensaver` o‘chiradi. Unga qanday sozlashni biladigan terminal kerak — Alacritty, Foot, Ghostty yoki Kitty — va standart terminalingiz boshqa narsa bo‘lsa, sizga shuni aytadi.

U chizadigan logotip sizniki va uni o‘zgartirishingiz mumkin, _Appearance > Branding > Screensaver_ ostida. png yoki svg yuklang va Omarchy uni ASCII ga aylantiradi. [brending](41-branding.md) ga qarang.

### Qulflash ekrani

`Super + Ctrl + L` mashinani qulflaydi. Bu Omarchy qobig‘idagi qulflash ekranini ishga tushiradi, displeyni qoraytiradi, parolingizni noto‘g‘ri alifboda yozmasligingiz uchun klaviatura tartibini birinchi tartibga qaytaradi va — agar u ishlayotgan bo‘lsa — chiqishda 1Password ni qulflaydi.

Qulflash ekrani parolni qabul qiladi va barmoq izini sozlaganingizdan keyin uni ham qabul qiladi. Bu va autentifikatsiyaning boshqa usullari [apparat autentifikatsiyasi](37-hardware-authentication.md) da yoritilgan.
