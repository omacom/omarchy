# Toggle'lar, Bekor turish va Ekran saqlovchi

Kundan kunga o'zgartirib turadigan narsalaringizning aksariyati aslida sozlama emas. Bu bir soatga yoqib, keyin yana o'chirib qo'yadigan rejim: kech ishlayotganingizda tungi yorug'lik, taqdimot qilayotganingizda bezovta qilmaslik, biror narsa tomosha qilayotganingizda uyg'oq qolish. Omarchy ularni toggle deb ataydi va ularning barchasi bir xil ishlaydi — tezkor tugma, menyu bandi va buyruq, barchasi bitta kalitga tegadi.

### Toggle menyusi

`Super + Ctrl + O` to'g'ridan-to'g'ri _Trigger > Toggle_ ni ochadi, yoki u yerga Omarchy menyusidan (`Super + Space`) ham borishingiz mumkin. U ro'yxatdagi hamma narsa holat qayerda saqlanayotganini o'ylamasdan o'zgartirishingiz mumkin bo'lgan kalitdir. Ish stoli qanday ko'rinishini belgilaydigan kalitlar uning yonida, _Appearance_ ostida joylashgan.

Terminaldan o'sha kalitlar `omarchy toggle <thing>` dir. Butun guruhni ko'rish uchun `omarchy toggle` ni o'zini ishga tushiring.

| Toggle | Tezkor tugma | Buyruq |
| ------ | ------ | ------- |
| Tungi yorug'lik | — | `omarchy toggle nightlight` |
| Bildirishnomalarni jim qilish | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Uyg'oq qolish (bekor holatda qulflanmaslik) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Qulashni yozib olish | — | `omarchy toggle crash-capture` |
| Ekran saqlovchi | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) mavzusini sinxronlash | — | `omarchy toggle theme sync` |
| Menyu paneli | `Super + Shift + Space` | `omarchy toggle bar` |
| Sensor panel | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Sensorli ekran | — | `omarchy device touchscreen` |
| Kutish rejimi | — | `omarchy toggle suspend` |
| Gibrid GPU | — | `omarchy toggle hybrid gpu` |

Sensor panel, sensorli ekran va gibrid GPU kalitlari Toggle ostida emas, _Trigger > Hardware_ (`Super + Ctrl + H`) ostida joylashgan, chunki ular faqat sizda o'sha uskuna haqiqatan bo'lganda paydo bo'ladi. Sensor panel va sensorli ekran kalitlari Hyprland qayta yuklangandan keyin ham saqlanib qoladi — o'chirilgan qurilmaning nomi kichik holat fayliga saqlanadi, Hyprland ishga tushganda uni o'qib, qurilmani yana o'chiradi.

_Appearance_ da menyu paneli va animatsiyalar, shuningdek `omarchy toggle` buyruqlari bo'lmasa ham xuddi shunday ishlaydigan bir nechta narsa bor: paneldagi batareya foizi, standart ish maydoni tartibi va _Windows_ ostida oyna bo'shliqlari (`Super + Shift + Backspace`) hamda 1 oynalik kvadrat nisbat (`Super + Ctrl + Backspace`).

Hyprland da chizish uchun GPU bo'lmasa va uning o'rniga CPU da render qilsa (llvmpipe), masalan GPU si hali qo'llab-quvvatlanmaydigan Mac larda, aksariyat virtual mashinalarda yoki grafik drayver yuklana olmaganda, Omarchy o'sha sessiya uchun animatsiyalar, xiralashtirish va soyalarni o'chiradi va bu haqda sizga bir marta bildirishnoma bilan xabar beradi. _Appearance > Animations On_ ularni qaytaradi va Omarchy buni keyingi sessiyalar uchun ham eslab qoladi.

Ularning aksariyati shunchaki `~/.local/state/omarchy/toggles/` ostidagi bayroq faylidir. Agar skriptda ulardan biriga qarab shart qo'ymoqchi bo'lsangiz, `omarchy-toggle-enabled` sizni izlab yurishingizdan qutqarib, chiqish kodini beradi:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayroqlar o'chirilgan holat nomi bilan atalgan — `screensaver-off`, `suspend-off`, `bar-off` — shuning uchun ularning mavjudligi funksiya o'chirilganini anglatadi.

### Paneldagi indikatorlar

Rejim yoqilganda, yuqori panelning o'rtasida soat yonida kichik belgi paydo bo'ladi. Bu indikatorlar vidjeti bo'lib, u diktovka, ekranni yozib olish, kutilayotgan eslatmalar, tungi yorug'lik, bezovta qilmaslik va uyg'oq qolishni ko'rsatadi.

Nofaol indikatorlar yashirin bo'ladi. Kursorni panelning istalgan joyiga olib boring va ular xira ko'rinishda paydo bo'ladi, shunda tezkor tugmasini bilmasdan ham birini bosib yoqishingiz mumkin. Faolini bosish uni yana o'chiradi. Agar ularning barchasini doim ko'rib turishni afzal ko'rsangiz, `~/.config/omarchy/shell.json` dagi `omarchy.indicators` yozuvida `alwaysShow` ni `true` qilib qo'ying — panel vidjetlari qanday sozlanishini [yuqori panel](05-the-top-bar.md) dan ko'ring.

### Tungi yorug'lik

Tungi yorug'lik ekranni 4000K gacha ilitadi, uni yana almashtirish esa 6500K ga qaytaradi. Uni toggle menyusidan (`Super + Ctrl + O`) yoki `omarchy toggle nightlight` bilan o'zgartiring. Uni hyprsunset boshqaradi, agar u allaqachon ishlamayotgan bo'lsa, toggle uni siz uchun ishga tushiradi.

Sukut bo'yicha hyprsunset ekraningizga umuman hech narsa qilmaydi. `~/.config/hypr/hyprsunset.conf` aynan displey siz iliqlik so'ramaguningizcha tegilmasdan qolishi uchun identitet profili bilan yetkaziladi. Agar uning o'rniga soat bo'yicha almashishini xohlasangiz, uni vaqt profili bilan almashtiring:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Keyin `~/.config/hypr/autostart.lua` ga `o.launch_on_start("hyprsunset")` ni qo'shib, hyprsunset ni tizimga kirishda ishga tushiring. Toggle ishlatadigan 4000K/6500K juftligi qat'iy belgilangan, shuning uchun boshqa harorat xohlasangiz, konfiguratsiya fayliga murojaat qilasiz.

### Bezovta qilmaslik

`Super + Ctrl + Alt + ,` bildirishnomalarni jim qiladi. U yoqilganda hech qanday tostlar chiqmaydi va ustidan chizilgan qo'ng'iroq indikatori ish stoli nima uchun jim bo'lib qolganini eslatish uchun panelda turadi.

Biroq hech narsa yo'qolmaydi. Jim qilingan bildirishnomalar ushlab turiladi: oxirgi bir nechtasini `Super + Shift + Alt + ,` bilan ekranga qaytaring. Qolganini [bildirishnomalar](10-notices.md) dan ko'ring.

Ikki turdagi xabar baribir o'tadi: siz hozirgina qilgan ishingiz uchun Omarchy ning o'z tasdiqlash tostlari ("Theme changed", "Screenshot saved") va buyruq satridan yuborilgan kritik ogohlantirishlar. O'zini sizning oldingizga majburan chiqarish uchun hamma narsani kritik deb belgilaydigan chat ilovalari bu qatorga kirmaydi.

### Bekor turish

Omarchy qobig'i bekor turish xatti-harakatini boshqaradi va vaqtlar `~/.config/omarchy/shell.json` dagi yuqori darajali `idle` blokidir:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Har ikkala raqam ham siz bekor holatga o'tgan paytdan boshlab sanaladigan soniyalar — bir-biridan emas. Shunday qilib, sukut bo'yicha ekran saqlovchi ikki yarim daqiqadan keyin chiqadi va qulflash ekrani ekran saqlovchi ishlagan-ishlamaganidan qat'i nazar, besh daqiqada o'rnini egallaydi. Faylni saqlang va qobiq yangi vaqtlarni darhol qabul qiladi.

Agar qulflash muddati kelmasidan ekran saqlovchini yopib yuborsangiz, bu faollik deb hisoblanadi va kutilayotgan qulflash bekor qilinadi. Mashinangizga bir qarab qo'yganingiz uchun qulflanib qolmaysiz.

Bekor holatda qulflashni butunlay to'xtatish uchun `Super + Ctrl + I` — yoki `omarchy toggle idle` — uyg'oq qolishni yoqadi va panelda qahva chashkasi indikatori paydo bo'ladi. Uzoq taqdimotdan yoki kuzatmoqchi bo'lgan yig'ilishdan oldin bosiladigan tugma shu. Normal holatga qaytish uchun uni yana bosing. Agar skriptdan kerak bo'lsa, `omarchy toggle idle status` joriy holatni JSON sifatida chop etadi.

Bu qulflash va ekran saqlovchi haqida, quvvat haqida emas. Kutish va gibernatsiyaning o'z sozlamalari [tizim uyqusi](36-system-sleep.md) da bor.

### Ekran saqlovchi

Omarchy ning ekran saqlovchisi tasodifiy matn effektlari orqali o'tadigan ASCII art bo'lib, har bir monitor uchun bitta nusxadan ishlaydi. Har qanday tugma yoki sichqoncha harakati undan chiqadi.

Uni talab bo'yicha _System > Screensaver_ (`Super + Esc`) dan ishga tushirishingiz mumkin, bu bekor holatdagi ekran saqlovchini o'chirib qo'ygan bo'lsangiz ham uni majburan chiqaradi. Sukut bo'yicha unga hech qanday tezkor tugma biriktirilmagan.

Agar ishlashdan to'g'ridan-to'g'ri qulflangan holatga o'tishni afzal ko'rsangiz, bekor holatdagisini o'chiradigan narsa `omarchy toggle screensaver` dir. Har qanday tugma, bosish, aylantirish yoki sichqoncha harakati uni yopadi.

U chizadigan logotipni _Appearance > Branding > Screensaver_ ostida o'zingiz o'zgartirishingiz mumkin. png yoki svg yuklang va Omarchy uni ASCII ga aylantiradi. [brending](41-branding.md) ga qarang.

### Qulflash ekrani

`Super + Ctrl + L` mashinani qulflaydi. Bu Omarchy qobig'idagi qulflash ekranini ishga tushiradi, displeyni qoraytiradi, parolingizni noto'g'ri alifboda yozmasligingiz uchun klaviatura tartibingizni birinchisiga qaytaradi va — agar u ishlayotgan bo'lsa — chiqishda 1Password ni qulflaydi.

Qulflash ekrani parolni qabul qiladi va siz barmoq izini sozlab olganingizdan keyin uni ham qabul qiladi. Bu va autentifikatsiyaning boshqa usullari [uskuna autentifikatsiyasi](37-hardware-authentication.md) da yoritilgan.
