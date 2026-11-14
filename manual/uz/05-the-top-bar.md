# Yuqori panel

Ekraningizning yuqori qismi bo‘ylab cho‘zilgan chiziq — Omarchy paneli. Bu yopishtirib qo‘yilgan holat paneli emas, balki Omarchy qobig‘ining bir qismi, menyuni, bildirishnomalarni, OSD qalqib chiquvchi oynalarini va qulflash ekranini ham chizadigan yagona, uzoq ishlaydigan Quickshell jarayonidir. Shuning uchun u qolgan hamma narsa bilan mukammal uyg‘unlashadi va shuning uchun panel yangi ilovani ishga tushirmasdan, darhol ochiladi.

Bu, shuningdek, doim ekranda qoladigan yagona ish stoli qismi, shuning uchun o‘sha kichkina belgilar nima qilishini bilib olishga arziydi.

## Odatiy holatda unda nimalar bor

Panel uchta bo‘limdan iborat. Chap tomonda Omarchy logotipi (menyu ishga tushirgichi) va ish joylari indikatorlari joylashgan. Markazda holat indikatorlari, soat, Elsewhen (jahon soati), ob-havo va Omarchy yangilanishi belgisi beriladi. O‘ng tomonda: tizim treyi, klaviatura tartibi (birdan ortiq tartib sozlangan bo‘lsa), agentlar, bluetooth, tarmoq, audio, displey va quvvat.

Ulardan ba’zilari faqat aytadigan gapi bo‘lgandagina ko‘rinadi. Klaviatura tartibi faqat birdan ortiq tartib sozlagan bo‘lsangizgina chiqadi. Yangilanish belgisi faqat Omarchy yangilanishi kutib turgandagina chiqadi. Agentlar belgisi esa Omarchy mashinada AI kodlashdan foydalanishni birinchi marta topganida chiqadi (qarang: [AI](17-ai.md)).

## Atrofni bosish

Deyarli har bir vidjet chap, o‘ng va o‘rta bosishda nimadir qiladi, bir nechtasi esa aylantirishga ham javob beradi. Odamlar o‘tkazib yuboradigan qismi shu — o‘ng va o‘rta tugmalar ortida yaxshi narsalarning ko‘pi yashiringan.

| Vidjet | Chap | O‘ng | O‘rta / aylantirish |
| --- | --- | --- | --- |
| Menyu | Omarchy menyusi | Yangi terminal | — |
| Ish joylari | Shu monitorda o‘sha ish joyiga fokuslash | — | Aylantirish: keyingi/oldingi ish joyi |
| Soat | Kalendar qalqib chiquvchi oynasi | Yorliq formatini almashtirish | O‘rta: vaqt mintaqasini tanlagich |
| Ob-havo | Bashorat qalqib chiquvchi oynasi | To‘liq ob-havo bildirishnoma sifatida | O‘rta: yangilash |
| Audio | Audio paneli | Ovozni o‘chirish | O‘rta: panel · aylantirish: ovoz balandligi |
| Mikrofon | Mikrofonni o‘chirish | — | O‘rta: audio paneli · aylantirish: kirish ovoz balandligi |
| Tarmoq | Tarmoq paneli | — | — |
| Bluetooth | Bluetooth paneli | Radioni yoqish/o‘chirish | — |
| Displey | Displey paneli | — | Aylantirish: yorqinlik |
| Quvvat | Quvvat paneli | Batareya foizini yoqish/o‘chirish | — |
| Media | Ijro/pauza | Muqova rasmi qalqib chiquvchi oynasi | O‘rta: keyingi · aylantirish: oldingi/keyingi |
| Agentlar | Agentlar paneli | Agentingizni ishga tushirish | O‘rta: keyingi obuna |
| Trey | Tortmani ko‘rsatish uchun sichqonchani olib boring | Boshqarish uchun shevron ustida o‘ng tugma | — |
| Omarchy yangilanishi | Yangilanishni ishga tushirish | — | — |

O‘sha jadvaldagi hamma narsa ham panelingizda tayyor holatda bo‘lmaydi. Media vidjeti (aylanadigan trek va ijrochi ko‘rinadigan MPRIS hozir ijro etilayotgani) ham, mikrofon vidjeti ham ichiga o‘rnatilgan, lekin odatiy holatda o‘chiq — xohlasangiz, quyida tasvirlanganidek, ularni qo‘shing.

## Panellar

Panel belgisini bosish panelni ochadi, bu maslahat oynasi emas, balki slayderlari, ro‘yxatlari va klaviaturada navigatsiyasi bor to‘laqonli qalqib chiquvchi oyna. Ularning har birida tezkor tugma ham bor, shuning uchun 16 pikselli belgini nishanlab o‘tirishingiz hech qachon kerak bo‘lmaydi:

| Tezkor tugma | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Tarmoq |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displey |
| `Super + Ctrl + P` | Quvvat |
| `Super + Ctrl + Alt + D` | Kalendar |
| `Super + Ctrl + Alt + E` | Jahon soati |
| `Super + Ctrl + 1-9` | O‘ng bo‘limdagi n-panelni yoqish/o‘chirish |

Panellar shunchaki ko‘rsatib turadigan narsalar emas. Ishni aynan o‘sha yerda bajarasiz:

- **Audio** da asosiy ovoz balandligi slayderi, chiqish qurilmasini tanlagich va ilova bo‘yicha mikser bor, shuning uchun qolgan hamma narsaga tegmasdan, bitta brauzer yorlig‘ining ovozini pasaytirishingiz mumkin.
- **Tarmoq** Wi-Fi ni qidiradi, signal kuchini ko‘rsatadi, ulanadi va DNS provayderini tanlash imkonini beradi.
- **Bluetooth** qurilmalaringizni ulanish/uzish va batareya darajalari bilan ro‘yxatlaydi.
- **Quvvat** batareya statistikasini ko‘rsatadi, quvvat profillarini almashtiradi (batareya va AC uchun alohida tanlovni eslab qoladi) va tizim haqida ba’zi ma’lumotlarni chiqaradi.
- **Displey** da yorqinlik slayderi, matn o‘lchami, monitor masshtabi oldindan sozlamalari va — birdan ortiq ekraningiz bo‘lsa — har bir monitor uchun alohida boshqaruvlar bor. Chuqurroq hikoya uchun qarang: [monitorlar](33-monitors.md).
- **Soat** ISO hafta raqamlari va oy bo‘yicha o‘tish imkoni bilan oylik katakchani ochadi.
- **Jahon soati** har bir shahar uchun alohida qator saqlaydi, uning ob-havosi va kuni qanday o‘tayotgani bilan birga. Qidiruv vaqt mintaqalarini ham, shaharchalarni ham topadi, shuning uchun Fort Lauderdale Nyu-York emas, aynan Fort Lauderdale bo‘ladi. Agar yuqori qator noto‘g‘ri shaharni nomlayotgan bo‘lsa, uni bosing va qayerda ekaningizni ayting; boshqa vaqt mintaqasidagi joyni tanlasangiz, tizim soati ham o‘sha yerga ko‘chadi, bu sayohatda qulay. Shahar ustiga sichqonchani olib boring va u yerda kim yashashini aytish uchun odam tugmasini bosing — oddiy ismlar, yoki yuzlarini ham olib kelish uchun `@` GitHub identifikatorlari.

Har bir panel sichqoncha bilan birga klaviaturani ham qabul qiladi: strelkalar harakatlanadi, Return faollashtiradi, Tab qo‘shni panelga o‘tadi va Escape yopadi.

`Super + Ctrl + 1-9` o‘ng bo‘limdagi panellarni chapdan o‘ngga sanaydi, treyni tashlab o‘tadi, chunki uning o‘z paneli yo‘q. Shuning uchun raqam siz ko‘rsatadigan belgiga mos keladi.

### Tailscale va Dropbox

Yana ikkita vidjet mos keladigan xizmatni **O‘rnatish → Xizmat** dan o‘rnatganingizdagina panelda chiqadi va ikkalasini ham bilib olishga arziydi, chunki ular shunchaki holatni xabar qilishdan ko‘prog‘ini qiladi.

**Tailscale** paneli tailnet ga ulanadi va undan uziladi, hisoblar o‘rtasida almashadi va chiqish tugunini tanlaydi (o‘z mashinalaringiz ham, Mullvad hududlari ham o‘sha ro‘yxatda chiqadi). U mashinalaringizni ham ko‘rib chiqadi — va biri tanlangan bo‘lsa, `s` unga Taildrop orqali fayllar yuboradi, bu faylni telefoningizga yoki boshqa noutbukka ko‘chirishning eng tez yo‘li. `c` mashinaning IP manzilini, `n` uning nomini va `d` uning to‘liq DNS nomini nusxalaydi. Har bir mashina qatorida yuborish tugmasi ham bor, bosishni afzal ko‘rsangiz. Terminaldan xuddi shu narsa `omarchy tailscale send <machine> [file...]` dir.

**Dropbox** paneli tizimga kirishni bajaradi, qancha saqlash joyidan foydalanganingizni ko‘rsatadi va yaqinda sinxronlangan fayllarni ro‘yxatlaydi.

Xizmatlardan birini olib tashlash uning vidjetini ham paneldan olib tashlaydi.

## Indikatorlar

Markazdagi kichkina to‘p — indikatorlar vidjeti. Bular siz yoqqan rejimlar uchun holat belgilaridir: bezovta qilmaslik, tungi yorug‘lik, navbatdagi [eslatma](09-reminders.md), faol ekran yozuvi, uyg‘oq qolish va [diktatsiya](11-text-extraction-dictation.md). Ular rejim faol bo‘lganda yonadi, aks holda yo‘ldan chetda turadi — faolsizlari o‘tiradigan joy yoniga sichqonchani olib boring, o‘shalarni ko‘rib olish uchun. Indikatorni bosish o‘sha rejimni yoqadi yoki o‘chiradi. Yana biri faqat holat uchun: uzoqdan sessiya kimdir bu mashinaga gliff orqali ulangan paytda qizil yonadi.

Ular doim ko‘rinib turishini afzal ko‘rsangiz, vidjetda `alwaysShow` ni `true` qilib sozlang. Va faqat ularning ba’zilari sizga qiziq bo‘lsa, xohlaganlaringizni `items` da ro‘yxatlang: `["Dnd", "Reminder", "NightLight"]`. Birdan ortiq indikatorlar vidjetiga ega bo‘lishingiz mumkin, shuning uchun turli bo‘limlar turli kichik to‘plamlarni ko‘rsatishi mumkin.

## Panelni qayta tartiblash

Panel o‘zini o‘zi sozlaydi. Narsalarni ko‘chirish uchun konfiguratsiya faylini ochishingiz shart emas.

Markaz atrofidan panelning bo‘sh joyini ushlang va uni ekranning boshqa chekkasi tomon sudrab boring, panel o‘sha yerga ko‘chadi — chap, o‘ng, yuqori yoki past, hammasi ishlaydi va har bir vidjet moslashadi (vertikal panellar ixcham, faqat belgi ko‘rinishiga qaytadi). Bosib ushlab turish xuddi shu sudrashni boshlaydi. Panel fonini tiniqdan shishasimonga, undan xira bo‘lmaganga almashtirish uchun o‘sha bo‘sh joyni chap tugma bilan ikki marta bosing. Va istalgan vidjetni tartibini o‘zgartirish yoki uni boshqa bo‘limga tashlash uchun sudrab boring; boshqa vidjetlar u qo‘nadigan joyga joy ochish uchun ikki tomonga suriladi.

Panelning o‘rtasi — quti: undagi hamma narsa bitta guruh sifatida markazda qoladi, uning ikki tomonidagi vidjetlar esa qutining chekkalariga osilib turadi. Vidjetni sudrayotganingizda quti kontur sifatida ko‘rinadi, bo‘sh bo‘lganda esa panel bo‘ylab chiziq sifatida, va siz uning ichiga yoki yoniga tashlashingiz mumkin. Tashlash quti ichiga tushadigan bo‘lsa, quti vidjetni sig‘dirish uchun kattalashadi.

Atrofda bo‘lishini xohlaydigan, lekin doim ko‘rinib turishini istamaydigan vidjet trey tortmasiga kirishi mumkin: uni trey ustiga sudrab boring, tortma uni olish uchun ochiladi. U u yerda ilova belgilaridan keyin o‘tiradi, tortma har safar chiqqanda ko‘rinadi va paneli ochiq turganda tortmasini ham ochiq saqlaydi. Uni qaytarish uchun panelga qayta sudrab chiqarib oling.

Menyudan tanlashni afzal ko‘rsangiz, **Tashqi ko‘rinish → Menyu paneli** da joylashuv bor, **Panel foni** esa panel qanday chizilishini tanlaydi: **Xira bo‘lmagan panel**, **Shishasimon panel** (ko‘rinib turadigan, orqasidagi narsa xiralashtirilgan) yoki **Tiniq panel**.

Xuddi shu narsalarda buyruqlar ham bor, bu sizga [dotfiles](31-dotfiles.md) sozlamasi uchun kerak bo‘ladigan narsadir:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Vidjetni butunlay qo‘shish yoki olib tashlash uchun plugin buyruqlaridan foydalaning. `omarchy plugin list` qobiq biladigan har bir vidjetni uning identifikatori bilan chiqaradi, undan keyin:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Panelni yashirish

`Super + Shift + Space` qobiqni o‘ldirmasdan panelni o‘chiradi va qayta yoqadi — panellar va tezkor tugmalar ishlashda davom etadi, siz shunchaki piksellarni qaytarib olasiz. Bu menyuda ham bor: **Tashqi ko‘rinish → Menyu paneli → Panelni yashirish**.

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

Har bir vidjet beshta tartib massividan biridagi bitta yozuvdir va uning sozlamalari o‘sha yozuvning o‘zida joylashgan — alohida sozlamalar fayli ham, `config` kichik obyekti ham yo‘q. Soatning `format` i, `formatAlt` i (o‘ng bosish nimaga almashtirishi) va `verticalFormat` i hammasi aynan o‘sha yerda, `{ "id": "omarchy.clock" }` da yashaydi.

`center` — panel o‘rtasidagi quti: undagi hamma narsa bitta guruh sifatida ekranda markazlashadi. `centerBegin` va `centerEnd` qutining ikki tomoniga osilib turadi, soat aynan shu tufayli ob-havo va yangilanish belgisi kelib-ketib turganda ham roppa-rosa markazda qoladi. `center` ga birdan ortiq vidjet qo‘ysangiz, ular birga markazlashadi; uni bo‘sh qoldirsangiz, `centerBegin` va `centerEnd` panel o‘rtasida uchrashadi.

Ichga singdirishga arziydigan bitta qoida: **o‘z `shell.json` ingiz paydo bo‘lgan zahoti, u kanonikdir**. Hech narsani o‘zingiz sozlamaguningizcha qobiq Omarchy ning odatiy faylini o‘qiydi. Vidjetni sudragan, `omarchy bar` ni ishga tushirgan yoki faylni o‘zingiz tahrirlagan zahotingiz, u sizniki bo‘ladi — chuqur birlashtirish yo‘q, shuning uchun kelajakdagi Omarchy nashrlaridagi yangi odatiy vidjetlar panelingizda avtomatik chiqmaydi. Toza holatdan boshlashni xohlagan har safaringizda `omarchy bar defaults` yetkazib berilgan tartibni qaytaradi.

Xuddi shu fayl yuqori darajada, `bar` kalitidan tashqarida, harakatsizlik vaqtlaringizni ham saqlaydi: `idle.screensaver` va `idle.lock`, ikkalasi ham harakatsiz qolganingizdan beri soniyalarda. Shuning uchun odatiy ekran saqlagichi 150 soniyada, qulf esa 300 soniyada ishga tushadi.
