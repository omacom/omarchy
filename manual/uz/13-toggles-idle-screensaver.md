# Almashtirgichlar, Bekor turish & Ekran saqlagich

Kun sayin o'zgartirib turadigan narsalaringizning ko'pi aslida sozlama emas. Bu bir soatga yoqib, keyin yana o'chirib qo'yadigan rejim: kech ishlayotganingizda tungi yorug'lik, taqdimot qilayotganingizda bezovta qilinmaslik, biror narsa tomosha qilayotganingizda uyg'oq qolish. Omarchy bularni almashtirgichlar deb ataydi va ularning barchasi bir xil ishlaydi — tezkor tugma, menyudagi band va buyruq, hammasi bitta almashtirgichning o'ziga ta'sir qiladi.

### Almashtirgichlar menyusi

`Super + Ctrl + O` _Trigger > Toggle_ ni to'g'ridan-to'g'ri ochadi yoki u yerga Omarchy menyusidan (`Super + Space`) ham borishingiz mumkin. Bu ro'yxatdagi hamma narsa holat qayerda saqlanishi haqida o'ylamasdan o'zgartirishingiz mumkin bo'lgan almashtirgichdir. Ish stoli qanday ko'rinishi haqidagi almashtirgichlar uning yonida, _Appearance_ ostida joylashgan.

Terminaldan, xuddi shu almashtirgichlar `omarchy toggle <thing>` dir. Butun guruhni ko'rish uchun `omarchy toggle` ni o'zini ishga tushiring.

| Almashtirgich | Tezkor tugma | Buyruq |
| ------ | ------ | ------- |
| Tungi yorug'lik | — | `omarchy toggle nightlight` |
| Bildirishnomalarni o'chirish | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Uyg'oq qolish (bekor turganda qulflanmaslik) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Buzilishni yozib olish | — | `omarchy toggle crash-capture` |
| Ekran saqlagich | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) mavzu sinxronizatsiyasi | — | `omarchy toggle theme sync` |
| Menyu paneli | `Super + Shift + Space` | `omarchy toggle bar` |
| Butun ekranli ish stoli (panel yo'q, bo'shliqlar yo'q) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animatsiyalar, xiralashtirish va soyalar | — | `omarchy toggle animations` |
| Sensor panel | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Sensor ekran | — | `omarchy device touchscreen` |
| To'xtatib turish | — | `omarchy toggle suspend` |
| Gibrid GPU | — | `omarchy device gpu hybrid` |

Sensor panel, sensor ekran va gibrid GPU almashtirgichlari Toggle ostida emas, _Trigger > Hardware_ (`Super + Ctrl + H`) ostida joylashgan, chunki ular faqat sizda haqiqatan ham o'sha apparat bo'lgandagina chiqadi. Sensor panel va sensor ekranniki Hyprland qayta yuklanishidan keyin ham saqlanib qoladi — o'chirilgan qurilmaning nomi kichik holat fayliga saqlanadi, Hyprland esa ishga tushishda uni o'qib, yana o'chiradi.

_Appearance_ menyu paneli va animatsiyalarni, shuningdek `omarchy toggle` buyruqlari bo'lmasa ham xuddi shunday ishlaydigan bir nechta narsani o'z ichiga oladi: paneldagi batareya foizi, standart ish maydoni tartibi va _Windows_ ostida, oyna bo'shliqlari (`Super + Shift + Backspace`) hamda 1 oynali kvadrat nisbat (`Super + Ctrl + Backspace`).

Hyprland da chizish uchun GPU bo'lmasa va uning o'rniga CPU da render qilsa (llvmpipe), masalan GPU si hali qo'llab-quvvatlanmaydigan Mac larda, aksariyat virtual mashinalarda yoki grafik drayver yuklanmasa, Omarchy o'sha sessiya uchun animatsiyalar, xiralashtirish va soyalarni o'chiradi va bu haqda sizga bitta bildirishnoma bilan bir marta aytadi. _Appearance > Animations On_ ularni qaytaradi va Omarchy buni keyingi sessiyalar uchun ham eslab qoladi.

Bularning aksariyati `~/.local/state/omarchy/toggles/` ostidagi shunchaki bayroq faylidir. Agar skriptda biriga qarab shart qo'ymoqchi bo'lsangiz, `omarchy-toggle-enabled` sizni izlab yurishga majbur qilmasdan chiqish kodini beradi:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Bayroqlar o'chirilgan holat uchun nomlangan — `screensaver-off`, `suspend-off`, `bar-off` — shuning uchun ularning mavjudligi funksiya o'chirilganini anglatadi.

### Paneldagi indikatorlar

Rejim yoqilgan bo'lsa, yuqori panelning o'rtasida, soat yonida kichik glif olasiz. Bu indikatorlar vidjeti bo'lib, u ekran yozib olish, kutilayotgan eslatmalar, tungi yorug'lik, bezovta qilinmaslik va uyg'oq qolishni, shuningdek parolsiz sudo yoqilgan yoki masofaviy sessiyaga kimdir ulangan paytdagi ogohlantirishlarni olib yuradi.

Faol bo'lmagan indikatorlar yashirin bo'ladi. Sichqonchani panelning istalgan joyiga olib boring, ular xira ko'rinishda paydo bo'ladi, shunda tezkor tugmasini bilmasangiz ham birini bosib yoqishingiz mumkin. Faol birini bossangiz, u yana o'chadi. Agar ularning barchasini doim ko'rib turishni istasangiz, `~/.config/omarchy/shell.json` dagi `omarchy.indicators` bandida `alwaysShow` ni `true` qilib qo'ying — panel vidjetlari qanday sozlanishi haqida [yuqori panel](05-the-top-bar.md) ga qarang.

### Tungi yorug'lik

Tungi yorug'lik ekranni 4000K gacha isitadi, uni yana o'zgartirsangiz 6500K ga qaytaradi. Uni almashtirgichlar menyusidan (`Super + Ctrl + O`) yoki `omarchy toggle nightlight` bilan o'zgartiring. Uni hyprsunset boshqaradi, almashtirgich esa agar u hali ishlamayotgan bo'lsa, uni siz uchun ishga tushiradi.

Standart holatda hyprsunset ekraningizga umuman hech narsa qilmaydi. `~/.config/hypr/hyprsunset.conf` aynan identity profil bilan keladi, shunda siz iliqlik so'ramaguningizcha displey tegilmasdan qoladi. Agar uning soat bo'yicha almashishini istasangiz, buning o'rniga vaqt profilini qo'ying:

```
profile {
    time = 20:00
    temperature = 4000
}
```

So'ngra `~/.config/hypr/autostart.lua` ga `o.launch_on_start("hyprsunset")` ni qo'shib, tizimga kirishda hyprsunset ni ishga tushiring. Almashtirgich ishlatadigan 4000K/6500K juftligi qat'iy belgilangan, shuning uchun boshqa harorat istasangiz, konfiguratsiya fayliga borasiz.

### Bezovta qilinmaslik

`Super + Ctrl + Alt + ,` bildirishnomalarni o'chiradi. U yoqilgan paytda hech qanday qalqib chiquvchi xabarlar chiqmaydi va paneldagi ustidan chiziq tortilgan qo'ng'iroq indikatori ish stoli nima uchun jim bo'lib qolganini eslatib turadi.

Hech narsa yo'qolmaydi. O'chirilgan bildirishnomalar ushlab turiladi: oxirgi bir nechtasini `Super + Shift + Alt + ,` bilan ekranga qaytaring. Qolganini [xabarlar](10-notices.md) da ko'ring.

Uch turdagi xabar baribir o'tib ketadi: hozirgina qilgan ishingiz uchun Omarchy ning o'z tasdiq xabarlari ("Mavzu o'zgardi", "Skrinshot saqlandi"), buyruq qatoridan yuborilgan o'ta muhim ogohlantirishlar va tasdiqlash kodlari. O'zini sizning oldingizga majburan chiqarish uchun hamma narsani o'ta muhim deb belgilaydigan chat ilovalari bunga kirmaydi.

### Bekor turish

Omarchy qobig'i bekor turish xatti-harakatini boshqaradi va vaqtlar `~/.config/omarchy/shell.json` dagi yuqori darajadagi `idle` blokidir:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Har ikki raqam ham siz bekor qolgan paytdan boshlab sanaladigan soniyalar — bir-biridan emas. Shunday qilib, standart holatda ekran saqlagich ikki yarim daqiqadan keyin chiqadi va qulf ekrani besh daqiqada o'z o'rnini egallaydi, ekran saqlagich ishlagan-ishlamaganidan qat'i nazar. Faylni saqlang va qobiq yangi vaqtlarni darhol qabul qiladi.

Agar qulf muddati tugamasdan ekran saqlagichni yopib yuborsangiz, bu faollik deb hisoblanadi va kutilayotgan qulf bekor qilinadi. Mashinangizga bir qarab qo'yganingiz uchun qulflanib qolmaysiz.

Bekor turganda qulflashni butunlay to'xtatish uchun `Super + Ctrl + I` — yoki `omarchy toggle idle` — uyg'oq qolishni yoqadi va panelda kofe chashkasi indikatori paydo bo'ladi. Uzoq taqdimotdan yoki kuzatib turmoqchi bo'lgan yig'ishdan oldin bosiladigani aynan shu. Normal holatga qaytish uchun uni yana bosing. Agar skriptdan kerak bo'lsa, `omarchy toggle idle status` joriy holatni JSON sifatida chop etadi.

Bu qulflash va ekran saqlagich haqida, quvvat haqida emas. To'xtatib turish va gibernatsiyaning o'z sozlamasi [tizim uyqusi](36-system-sleep.md) da bor.

### Ekran saqlagich

Omarchy ning ekran saqlagichi tasodifiy matn effektlari orqali o'tadigan ASCII surat bo'lib, har bir monitor uchun bittadan nusxada ishlaydi. Har qanday tugma yoki sichqoncha harakati undan chiqadi.

Uni _System > Screensaver_ (`Super + Esc`) dan talab bo'yicha ishga tushirishingiz mumkin, bu bekor turgandagi ekran saqlagichni o'chirib qo'ygan bo'lsangiz ham uni majburan chiqaradi. Standart holatda unga hech qanday tezkor tugma biriktirilmagan.

`omarchy toggle screensaver` bekor turgandagisini o'chiradi, agar ishlashdan to'g'ridan-to'g'ri qulflangan holatga o'tishni afzal ko'rsangiz. Har qanday tugma, bosish, aylantirish yoki sichqoncha harakati uni yopadi.

U chizadigan logotipni o'zgartirish sizning qo'lingizda, _Appearance > Branding > Screensaver_ ostida. png yoki svg yuklang va Omarchy uni ASCII ga aylantiradi. [brending](41-branding.md) ga qarang.

### Qulf ekrani

`Super + Ctrl + L` mashinani qulflaydi. Bu Omarchy qobig'idan qulf ekranini ishga tushiradi, displeyni qoraytiradi, parolingizni noto'g'ri alifboda yozib qo'ymasligingiz uchun klaviatura tartibini birinchisiga qaytaradi va — agar u ishlayotgan bo'lsa — chiqishda 1Password ni qulflaydi.

Qulf ekrani parolni qabul qiladi, barmoq izini o'rnatgan bo'lsangiz, uni ham qabul qiladi. Bu va autentifikatsiyaning boshqa usullari [apparat autentifikatsiyasi](37-hardware-authentication.md) da yoritilgan.
