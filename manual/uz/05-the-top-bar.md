# Yuqori panel

Ekraningizning yuqori qismidagi chiziq — Omarchy paneli. Bu keyinchalik yopishtirilgan holat paneli emas, balki Omarchy qobigʻining bir qismi — menyuni, bildirishnomalarni, OSD qalqib chiquvchi oynalarini va qulflash ekranini ham chizadigan yagona uzoq ishlaydigan Quickshell jarayoni. Shuning uchun u qolgan hamma narsa bilan mukammal uygʻunlashadi va shuning uchun panel yangi ilovani ishga tushirmasdan, bir zumda ochiladi.

Bu shuningdek doimo ekranda qoladigan yagona ish stoli qismi hamdir, shuning uchun oʻsha kichkina belgilarning hammasi nima qilishini bilib qoʻyganingiz arziydi.

## Standart holatda unda nimalar bor

Panel uch qismdan iborat. Chap tomonda Omarchy logotipi (menyu ochgichi) va ish maydonlari koʻrsatkichlari joylashgan. Markazda holat koʻrsatkichlari, soat, Elsewhen (jahon soati), ob-havo va Omarchy yangilanish belgisi bor. Oʻng tomonda: tizim treyi, klaviatura tartibi (birdan ortiq tartib sozlangan boʻlsa), agentlar, bluetooth, tarmoq, audio, displey va quvvat.

Ulardan bir qanchasi faqat aytadigan gapi boʻlgandagina paydo boʻladi. Klaviatura tartibi faqat birdan ortiq tartib sozlagan boʻlsangiz paydo boʻladi. Yangilanish belgisi faqat Omarchy yangilanishi kutayotgan boʻlsa paydo boʻladi. Agentlar belgisi esa Omarchy mashinada AI kodlashdan foydalanishni birinchi marta topganda paydo boʻladi (qarang: [AI](17-ai.md)).

## Atrofni bosish

Deyarli har bir vidjet chap, oʻng va oʻrta bosishga nimadir qiladi, bir qanchasi esa aylantirishga ham javob beradi. Odamlar aynan shu qismni oʻtkazib yuboradi — koʻp yaxshi narsalar oʻng va oʻrta tugmalarda yashiringan.

| Vidjet | Chap | Oʻng | Oʻrta / aylantirish |
| --- | --- | --- | --- |
| Menu | Omarchy menyusi | Yangi terminal | — |
| Workspaces | Ushbu monitorda oʻsha ish maydoniga oʻtish | — | Aylantirish: keyingi/oldingi ish maydoni |
| Clock | Kalendar qalqib chiquvchi oynasi | Yorliq formatini aylanib almashtirish | Oʻrta: vaqt mintaqasi tanlagichi |
| Weather | Prognoz qalqib chiquvchi oynasi | Toʻliq ob-havo bildirishnoma sifatida | Oʻrta: yangilash |
| Audio | Audio paneli | Ovozni oʻchirish | Oʻrta: panel · aylantirish: ovoz balandligi |
| Microphone | Mikrofonni oʻchirish | — | Oʻrta: audio paneli · aylantirish: kirish ovozi balandligi |
| Network | Tarmoq paneli | — | — |
| Bluetooth | Bluetooth paneli | Radioni yoqib-oʻchirish | — |
| Display | Displey paneli | — | Aylantirish: yorqinlik |
| Power | Quvvat paneli | Batareya foizini yoqib-oʻchirish | — |
| Media | Ijro/pauza | Muqova rasmi qalqib chiquvchi oynasi | Oʻrta: keyingi · aylantirish: oldingi/keyingi |
| Agents | Agentlar paneli | Agentingizni ishga tushirish | Oʻrta: keyingi obuna |
| Tray | Tortmani ochish uchun ustiga kursorni olib borish | Boshqarish uchun chevronga oʻng bosish | — |
| Omarchy update | Yangilanishni ishga tushirish | — | — |

Oʻsha jadvaldagi hamma narsa ham panelingizda dastlabki holatda boʻlmaydi. Media vidjeti (MPRIS hozir ijro etilayotgani, aylanib turadigan trek va ijrochi bilan) va mikrofon vidjeti — ikkalasi ham ichiga oʻrnatilgan, lekin standart holatda oʻchirilgan — istasangiz, quyida tasvirlanganidek ularni qoʻshing.

## Panellar

Panel belgisini bosish panelni ochadi; bu maslahat oynasi emas, balki slayderlari, roʻyxatlari va klaviatura navigatsiyasi bor toʻlaqonli qalqib chiquvchi oyna. Har birida tezkor tugma ham bor, shuning uchun 16 pikselli belgini nishonga olishingiz hech qachon shart emas:

| Tezkor tugma | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Oʻng qismdagi n-panelni yoqib-oʻchirish |

Panellar shunchaki koʻrsatib turadigan narsalar emas. Ular aynan oʻsha ishni haqiqatan qiladigan joyingiz:

- **Audio** da asosiy ovoz balandligi slayderi, chiqish qurilmasi tanlagichi va har bir ilova uchun alohida mikser bor, shuning uchun qolgan hamma narsaga tegmasdan oʻsha bitta brauzer yorligʻining ovozini pasaytirishingiz mumkin.
- **Network** Wi-Fi tarmoqlarini qidiradi, signal kuchini koʻrsatadi, ulanadi va DNS provayderini tanlashingizga imkon beradi.
- **Bluetooth** qurilmalaringizni ulanish/uzish va batareya darajalari bilan birga roʻyxatlaydi.
- **Power** batareya statistikasini koʻrsatadi, quvvat profillarini almashtiradi (batareya va AC uchun alohida tanlovni eslab qoladi) va tizim haqida biroz maʼlumot chiqaradi.
- **Display** da yorqinlik slayderi, matn oʻlchami, monitor masshtabi tayyor sozlamalari va — birdan ortiq ekraningiz boʻlsa — har bir monitor uchun alohida boshqaruvlar bor. Chuqurroq hikoya uchun [monitorlar](33-monitors.md) ga qarang.
- **Clock** ISO hafta raqamlari va oylar boʻyicha oʻtish imkoniyati bilan oylik panjarani ochadi.
- **World clock** har bir shahar uchun alohida qator saqlaydi, uning ob-havosi va kuni qanday oʻtayotgani bilan birga. Qidiruv shaharlarni ham, vaqt mintaqalarini ham topadi, shuning uchun Fort Lauderdale New York emas, aynan Fort Lauderdale boʻladi. Agar yuqori qatorda notoʻgʻri shahar nomi turgan boʻlsa, ustiga bosing va qayerda ekaningizni ayting; boshqa vaqt mintaqasidagi joyni tanlang va tizim soati ham oʻsha yoqqa koʻchadi, bu sayohat qilganingizda qoʻl keladi. Shahar ustiga kursorni olib boring va u yerda kim yashashini aytish uchun odam tugmasini bosing — oddiy ismlar yoki ularning yuzlarini ham olib kelish uchun `@` GitHub taxalluslari.

Har bir panel sichqonchani ham, klaviaturani ham qabul qiladi: strelkalar harakatlanadi, Return faollashtiradi, Tab qoʻshni panelga oʻtadi va Escape yopadi.

`Super + Ctrl + 1-9` oʻng qismdagi panellarni chapdan oʻngga qarab sanaydi, oʻz paneli boʻlmagani uchun treyni tashlab oʻtadi. Shuning uchun raqam ishora qilgan boʻlardingiz belgiga mos keladi.

### Tailscale va Dropbox

Yana ikkita vidjet panelda faqat mos xizmatni **Install → Service** dan oʻrnatganingizdan keyin paydo boʻladi va ikkalasini ham bilib qoʻyish arziydi, chunki ular shunchaki holatni xabar qilib qolmaydi.

**Tailscale** paneli tailnet ga ulanadi va undan uziladi, hisoblar oʻrtasida almashadi va chiqish tugunini tanlaydi (oʻz mashinalaringiz ham, Mullvad hududlari ham oʻsha roʻyxatda chiqadi). U mashinalaringizni ham koʻrib chiqadi — va biri tanlangan boʻlsa, `s` unga Taildrop orqali fayllar yuboradi, bu faylni telefoningizga yoki boshqa noutbukka koʻchirishning eng tezkor yoʻli. `c` mashinaning IP manzilini nusxalaydi, `n` uning nomini va `d` uning toʻliq DNS nomini. Agar bosishni afzal koʻrsangiz, har bir mashina qatorida yuborish tugmasi ham bor. Terminaldan xuddi shu narsa `omarchy tailscale send <machine> [file...]` dir.

**Dropbox** paneli tizimga kirishni boshqaradi, qancha xotiradan foydalanganingizni koʻrsatadi va yaqinda sinxronlangan fayllarni roʻyxatlaydi.

Ikkala xizmatdan birini olib tashlash uning vidjetini ham paneldan olib tashlaydi.

## Koʻrsatkichlar

Markazdagi kichkina toʻplam — koʻrsatkichlar vidjeti. Bular siz yoqqan rejimlar uchun holat belgilaridir: bezovta qilmaslik, tungi chiroq, navbatdagi [eslatma](09-reminders.md), faol ekran yozuvi, uygʻoq qolish va [diktovka](11-text-extraction-dictation.md). Rejim faol boʻlganda ular yonib turadi, aks holda yoʻldan chetda turadi — faol boʻlmaganlarini koʻzdan kechirish uchun kursorni panelning istalgan joyiga olib boring. Koʻrsatkichni bosish oʻsha rejimni yoqib-oʻchiradi. Yana bittasi faqat holat uchun: masofaviy sessiya kimdir ushbu mashinaga gliff orqali ulangan paytda qizil yonib turadi.

Agar ularning doimo koʻrinib turishini afzal koʻrsangiz, vidjetda `alwaysShow` ni `true` qilib qoʻying. Agar ulardan faqat baʼzilari sizga qiziq boʻlsa, istaganlaringizni `items` da roʻyxatlang: `["Dnd", "Reminder", "NightLight"]`. Birdan ortiq koʻrsatkichlar vidjetiga ega boʻlishingiz mumkin, shuning uchun turli qismlar turli kichik toʻplamlarni koʻrsatishi mumkin.

## Panelni qayta tartiblash

Panel oʻzini oʻzi sozlaydi. Narsalarni koʻchirish uchun konfiguratsiya faylini ochishingiz shart emas.

Panelning markaz atrofidagi boʻsh joyini ushlang va uni boshqa ekran chetiga torting, shunda panel oʻsha yoqqa koʻchadi — chap, oʻng, yuqori yoki pastki, hammasi ishlaydi va har bir vidjet moslashadi (vertikal panellar ixcham, faqat belgidan iborat shakllarga oʻtadi). Bosib ushlab turish ham xuddi shu sudrashni boshlaydi. Xuddi oʻsha boʻsh joyga ikki marta chap bosing va panel foni shaffofdan oynasimon va xira boʻlmaganga aylanib almashadi. Va istalgan vidjetni tartibini oʻzgartirish uchun yoki boshqa qismga uloqtirish uchun sudrab boring; qolgan vidjetlar u tushadigan joyni boʻshatish uchun ikki tomonga siljiydi.

Panelning oʻrtasi — bir quti: undagi hamma narsa bitta guruh sifatida markazda qoladi va uning ikki tomonidagi vidjetlar uning chetlariga osilib turadi. Vidjetni sudrayotganingizda quti kontur sifatida koʻrinadi yoki boʻsh boʻlganda panel boʻylab bir chiziq sifatida, va siz uning ichiga yoki yoniga tashlashingiz mumkin. Tashlash quti ichiga tushadigan boʻlsa, quti vidjetni sigʻdirish uchun kengayadi.

Har doim koʻz oldida boʻlishini istamaydigan, lekin atrofda boʻlishini istaydigan vidjet trey tortmasiga kirishi mumkin: uni trey ustiga sudrab boring va tortma uni qabul qilish uchun ochiladi. U u yerda ilova belgilari orqasida oʻtiradi, tortma qachon chiqsa oʻshanda chiqadi va paneli ochiq paytda tortmasini ochiq ushlab turadi. Uni panelga qaytarish uchun tortmadan panelga sudrab chiqaring.

Agar menyudan tanlashni afzal koʻrsangiz, **Appearance → Menu Bar** da joylashuv bor va **Bar Background** panel qanday chizilishini tanlaydi: **Opaque Bar**, **Glassy Bar** (shaffof, orqasidagi narsa xiralashgan holda) yoki **Clear Bar**.

Xuddi shu narsalarning buyruqlari ham bor, [dotfiles](31-dotfiles.md) sozlamasi uchun aynan shular kerak boʻladi:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Vidjetni butunlay qoʻshish yoki olib tashlash uchun plagin buyruqlaridan foydalaning. `omarchy plugin list` qobiq biladigan har bir vidjetni uning id si bilan birga chiqaradi, keyin esa:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Panelni yashirish

`Super + Shift + Space` qobiqni oʻldirmasdan panelni oʻchiradi va qayta yoqadi — panellar va tezkor tugmalar ishlashda davom etadi, siz shunchaki piksellarni qaytarib olasiz. Bu menyuda **Appearance → Menu Bar → Hide Bar** ostida ham bor.

## Konfiguratsiya fayli

Bularning hammasi `~/.config/omarchy/shell.json` da, `bar` kaliti ostida saqlanadi. Mana qisqartirilgan versiyasi:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Har bir vidjet beshta tartib massividan biridagi bitta yozuvdir va uning sozlamalari aynan oʻsha yozuvning ichida joylashadi — alohida sozlamalar fayli ham, `config` ichki obyekti ham yoʻq. Soatning `format`, `formatAlt` (oʻng bosish nimaga aylanib oʻtishi) va `verticalFormat` — hammasi aynan `{ "id": "omarchy.clock" }` ustida yashaydi.

`center` panel oʻrtasidagi qutidir: undagi hamma narsa ekranda bitta guruh sifatida markazda turadi. `centerBegin` va `centerEnd` qutining ikki tomoniga osilib turadi, soat ob-havo va yangilanish belgisi kelib-ketib turganda ham roppa-rosa markazda qolishi aynan shunday taʼminlanadi. `center` ga birdan ortiq vidjet qoʻying va ular birgalikda markazda turadi; uni boʻsh qoldiring va `centerBegin` bilan `centerEnd` panel oʻrtasida uchrashadi.

Ichga singdirib olishga arziydigan bitta qoida: **oʻz `shell.json` ingiz boʻlgach, u kanonik hisoblanadi**. Biror narsani sozlamaguningizcha qobiq Omarchy ning standart faylini oʻqiydi. Vidjetni sudragan, `omarchy bar` ni ishga tushirgan yoki faylni oʻzingiz tahrirlagan zahotingiz u sizniki boʻladi — chuqur birlashtirish yoʻq, shuning uchun kelajakdagi Omarchy nashrlaridagi yangi standart vidjetlar panelingizda avtomatik paydo boʻlmaydi. `omarchy bar defaults` toza holatdan boshlashni istaganingizda yetkazib berilgan tartibni qaytaradi.

Xuddi shu fayl yuqori darajada, `bar` kalitidan tashqarida, sizning boʻsh turish vaqtlaringizni ham saqlaydi: `idle.screensaver` va `idle.lock`, ikkalasi ham boʻsh turganingizdan beri oʻtgan soniyalarda. Shuning uchun standart ekran saqlagichi 150 soniyada, qulflash esa 300 soniyada ishga tushadi.
