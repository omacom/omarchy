# Yuqori panel

Ekraningizning yuqori qismidagi chiziq — Omarchy panelidir. Bu shunchaki yopishtirilgan holat paneli emas, balki Omarchy qobig‘ining bir qismi — menyuni, bildirishnomalarni, OSD qalqib chiquvchi oynalarini va qulflash ekranini ham chizadigan yagona, uzoq ishlaydigan Quickshell jarayoni. Shuning uchun u qolgan hamma narsa bilan mukammal uyg‘unlashadi va panel yangi ilovani ishga tushirmasdan, darhol ochiladi.

Bu, shuningdek, doimo ekranda bo‘ladigan yagona ish stoli qismi, shuning uchun o‘sha kichkina belgilarning barchasi nima qilishini bilib qo‘yish arziydi.

## Standart holatda unda nimalar bor

Panel uchta bo‘limdan iborat. Chap tomonda Omarchy logotipi (menyu ishga tushirgichi) va ish joyi ko‘rsatkichlari joylashgan. Markazda holat ko‘rsatkichlari, soat, Elsewhen (dunyo soati), ob-havo va Omarchy yangilanish belgisi bor. O‘ng tomonda: tizim treyi, klaviatura tartibi (birdan ortiq tartib yoki kiritish usuli sozlangan bo‘lsa), agentlar, bluetooth, tarmoq, audio, displey va quvvat.

Ulardan bir nechtasi faqat aytadigan gapi bo‘lganda paydo bo‘ladi. Klaviatura tartibi faqat birdan ortiq tartib yoki kiritish usulini sozlagan bo‘lsangiz paydo bo‘ladi. Yangilanish belgisi faqat Omarchy yangilanishi kutib turganda paydo bo‘ladi.

## Atrofni bosish

Deyarli har bir vidjet chap, o‘ng va o‘rta bosishda nimadir qiladi, bir nechtasi esa aylantirishga ham javob beradi. Odamlar aynan shu qismni o‘tkazib yuboradi — ko‘plab yaxshi narsalar o‘ng va o‘rta tugmalar ortida yashiringan.

| Vidjet | Chap | O‘ng | O‘rta / aylantirish |
| --- | --- | --- | --- |
| Menyu | Omarchy menyusi | Yangi terminal | — |
| Ish joylari | Ushbu monitorda o‘sha ish joyiga o‘tish | — | Aylantirish: keyingi/oldingi ish joyi |
| Soat | Taqvim qalqib chiquvchi oynasi | Yorliq formatini almashtirish | O‘rta: vaqt mintaqasini tanlash |
| Dunyo soati | Dunyo soati paneli | Yangilash | O‘rta: yangilash |
| Ob-havo | Prognoz qalqib chiquvchi oynasi | To‘liq ob-havo bildirishnoma sifatida | O‘rta: yangilash |
| Audio | Audio paneli | Ovozni o‘chirish | O‘rta: panel · aylantirish: ovoz balandligi |
| Mikrofon | Mikrofonni o‘chirish | — | O‘rta: audio paneli · aylantirish: kiritish ovoz balandligi |
| Tarmoq | Tarmoq paneli | — | — |
| Bluetooth | Bluetooth paneli | Radioni yoqish/o‘chirish | — |
| Displey | Displey paneli | — | Aylantirish: yorqinlik |
| Quvvat | Quvvat paneli | Batareya foizini yoqish/o‘chirish | — |
| Media | Ijro/pauza | Muqova rasmi qalqib chiquvchi oynasi | O‘rta: keyingi · aylantirish: oldingi/keyingi |
| Agentlar | Agentlar paneli | Agentingizni ishga tushirish | O‘rta: foydalanishni yangilash |
| Trey | Tortmani ochish uchun ustiga olib boring | Boshqarish uchun shevron ustida o‘ng tugma | — |
| Omarchy yangilanishi | Yangilanishni ishga tushirish | — | — |

Jadvaldagi hamma narsa ham panelingizda dastlabki holatda bo‘lavermaydi. Media vidjeti (MPRIS hozir ijro etilayotgani, aylantiriladigan trek va ijrochi bilan) va mikrofon vidjeti — ikkalasi ham o‘rnatilgan, lekin standart holatda o‘chirilgan — xohlasangiz, quyida tasvirlanganidek ularni qo‘shing.

## Panellar

Panel belgisini bosish panelni ochadi, bu maslahat oynasi emas, balki slayderlar, ro‘yxatlar va klaviatura navigatsiyasiga ega to‘laqonli qalqib chiquvchi oyna. Har birida tezkor tugma ham bor, shuning uchun hech qachon 16 pikselli belgini mo‘ljallab o‘tirish shart emas:

| Tezkor tugma | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Tarmoq |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displey |
| `Super + Ctrl + P` | Quvvat |
| `Super + Ctrl + Alt + D` | Taqvim |
| `Super + Ctrl + Alt + E` | Dunyo soati |
| `Super + Ctrl + X` | Agentlar |
| `Super + Ctrl + 1-9` | O‘ng bo‘limdagi n-panelni yoqish/o‘chirish |

Panellar shunchaki ma’lumot ko‘rsatadigan joy emas. Ular ishni haqiqatan bajaradigan joy:

- **Audio** da asosiy ovoz balandligi slayderi, chiqish qurilmasini tanlash va har bir ilova uchun mikser bor, shuning uchun qolgan hamma narsaga tegmasdan o‘sha bitta brauzer yorlig‘ining ovozini pasaytirishingiz mumkin.
- **Tarmoq** Wi-Fi ni qidiradi, signal kuchini ko‘rsatadi, ulanadi va DNS provayderini tanlash imkonini beradi.
- **Bluetooth** qurilmalaringizni ulanish/uzish va batareya darajalari bilan ro‘yxatlaydi.
- **Quvvat** batareya statistikasini ko‘rsatadi, quvvat profillarini almashtiradi (batareya va AC uchun alohida tanlovni eslab qoladi) va tizim haqida ba’zi ma’lumotlarni chiqaradi.
- **Displey** yorqinlik slayderi, matn o‘lchami, monitor masshtablash oldindan sozlamalari va — birdan ortiq ekraningiz bo‘lsa — har bir monitor uchun boshqaruvlarni olib keladi. Chuqurroq hikoya uchun [monitorlar](33-monitors.md) ga qarang.
- **Soat** ISO hafta raqamlari va oy bo‘ylab qadam tashlash bilan oy panjarasini ochadi.
- **Dunyo soati** har bir shahar uchun bitta qator saqlaydi, uning ob-havosi va kuni qanday o‘tayotgani bilan. Qidiruv vaqt mintaqalarini ham, shaharchalarni ham topadi, shuning uchun Fort Lauderdale — Fort Lauderdale, New York emas. Agar tepadagi qator noto‘g‘ri shaharni nomlasa, uni bosing va qayerda ekaningizni ayting; boshqa vaqt mintaqasidagi joyni tanlang va tizim soati ham o‘sha yerga ko‘chadi, bu sayohatda qo‘l keladi. Shahar ustiga olib boring va u yerda kim yashashini aytish uchun odam tugmasini bosing — oddiy ismlar, yoki yuzlarini ham olib kelish uchun `@` GitHub taxalluslari.

Har bir panel sichqonchani ham, klaviaturani ham qabul qiladi: strelkalar harakatlanadi, Return faollashtiradi, Tab qo‘shni panelga o‘tadi va Escape yopadi.

`Super + Ctrl + 1-9` o‘ng bo‘limdagi panellarni chapdan o‘ngga sanaydi, treyni o‘tkazib yuboradi, chunki uning o‘z paneli yo‘q. Shunday qilib raqam siz ko‘rsatadigan belgiga mos keladi.

### Tailscale va Dropbox

Yana ikkita vidjet panelda faqat mos xizmatni **O‘rnatish → Xizmat** dan o‘rnatganingizdan keyingina paydo bo‘ladi va ikkalasini ham bilib qo‘yish arziydi, chunki ular shunchaki holatni xabar qilishdan ko‘proq ish qiladi.

**Tailscale** paneli tailnet ga ulanadi va uziladi, hisoblar o‘rtasida almashadi va chiqish tugunini tanlaydi (o‘zingizning mashinalaringiz ham, Mullvad mintaqalari ham o‘sha ro‘yxatda chiqadi). U mashinalaringizni ham ko‘rib chiqadi — va biri tanlangan bo‘lsa, `s` unga Taildrop orqali fayllar yuboradi, bu faylni telefoningizga yoki boshqa noutbukka ko‘chirishning eng tezkor usuli. `c` mashinaning IP manzilini, `n` uning nomini va `d` uning to‘liq DNS nomini nusxalaydi. Har bir mashina qatorida yuborish tugmasi ham bor, agar bosishni afzal ko‘rsangiz. Terminaldan xuddi shu narsa `omarchy tailscale send <machine> [file...]` dir.

**Dropbox** paneli kirishni boshqaradi, qancha xotiradan foydalanganingizni ko‘rsatadi va yaqinda sinxronlangan fayllarni ro‘yxatlaydi.

Ikkala xizmatdan birini olib tashlash uning vidjetini ham paneldan olib tashlaydi.

## Ko‘rsatkichlar

Markazdagi kichkina to‘plam — ko‘rsatkichlar vidjeti. Bular siz yoqqan rejimlar uchun holat belgilaridir: bezovta qilmang, tungi yorug‘lik, navbatga qo‘yilgan [eslatma](09-reminders.md), faol ekran yozuvi va uyg‘oq turish, shuningdek parolsiz sudo yoqilgan yoki kimdir masofaviy sessiyaga ulangan paytdagi ogohlantirishlar. Ular rejim faol bo‘lganda yonadi va aks holda chetda turadi — faol bo‘lmaganlari o‘tiradigan joy yoniga olib boring va ularni ko‘zdan kechiring. Ko‘rsatkichni bosish o‘sha rejimni yoqadi/o‘chiradi. Yana biri faqat holat uchun: masofaviy sessiya kimdir ushbu mashinaga gliff orqali ulangan paytda qizil yonadi.

Agar ularning doimo ko‘rinib turishini istasangiz, vidjetda `alwaysShow` ni `true` ga sozlang. Va agar faqat ba’zilari sizga qiziq bo‘lsa, xohlaganlaringizni `items` da ro‘yxatlang: `["Dnd", "Reminder", "NightLight"]`. Birdan ortiq ko‘rsatkichlar vidjetiga ega bo‘lishingiz mumkin, shuning uchun turli bo‘limlar turli to‘plamlarni ko‘rsatishi mumkin.

## Panelni qayta tartibga solish

Panel o‘zini o‘zi sozlaydi. Narsalarni ko‘chirish uchun konfiguratsiya faylini ochishingiz shart emas.

Markaz atrofidagi panelning bo‘sh joyini ushlab, uni boshqa ekran chetiga sudrab boring, shunda panel o‘sha yerga ko‘chadi — chap, o‘ng, yuqori yoki pastki — hammasi ishlaydi va har bir vidjet moslashadi (vertikal panellar ixcham, faqat belgilardan iborat shakllarga o‘tadi). Bosib ushlab turish ham xuddi shu sudrashni boshlaydi. O‘sha bo‘sh joyni ikki marta chap tugma bilan bosing va panel fonini shaffofdan shishasimonga, undan xiraga aylantiring. Va istalgan vidjetni qayta tartiblash yoki boshqa bo‘limga tashlash uchun sudrab boring; boshqa vidjetlar u tushadigan joyda o‘rin bo‘shatish uchun ajraladi.

Panelning o‘rtasi — quti: undagi hamma narsa bitta guruh sifatida markazda turadi, uning ikki tomonidagi vidjetlar esa uning chetlariga osilib turadi. Vidjetni sudrayotganingizda quti kontur sifatida ko‘rinadi, bo‘sh bo‘lsa esa panel bo‘ylab chiziq sifatida, va siz uning ichiga yoki yoniga tashlashingiz mumkin. Tashlash qutiga tushadigan bo‘lsa, quti vidjetni qabul qilish uchun kattalashadi.

Doim qo‘l ostida, lekin doim ko‘rinib turishini istamaydigan vidjet treyning tortmasiga kirishi mumkin: uni trey ustiga sudrab boring, shunda tortma uni qabul qilish uchun ochiladi. U u yerda ilova belgilaridan keyin o‘tiradi, tortma chiqqanda har safar paydo bo‘ladi va paneli ochiq turganda tortmasini ochiq saqlaydi. Uni panelga qaytarish uchun yana panelga sudrab chiqaring.

Agar menyudan tanlashni afzal ko‘rsangiz, **Ko‘rinish → Menyu paneli** da joylashuv bor va **Panel foni** panel qanday chizilishini tanlaydi: **Xira panel**, **Shishasimon panel** (shaffof, orqasidagi narsa xiralashtirilgan) yoki **Shaffof panel**.

Xuddi shu narsalarning buyruqlari ham bor, bu [dotfiles](31-dotfiles.md) sozlamasi uchun aynan kerakli narsa:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Vidjetni butunlay qo‘shish yoki olib tashlash uchun plagin buyruqlaridan foydalaning. `omarchy plugin list` qobiq biladigan har bir vidjetni uning id si bilan chiqaradi, so‘ngra:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Panelni yashirish

`Super + Shift + Space` panelni qobiqni o‘ldirmasdan o‘chiradi va qayta yoqadi — panellar va tezkor tugmalar ishlashda davom etadi, siz shunchaki piksellarni qaytarib olasiz. U menyuda **Ko‘rinish → Menyu paneli → Panelni yashirish** ostida ham bor.

## Konfiguratsiya fayli

Hammasi `~/.config/omarchy/shell.json` da, `bar` kaliti ostida saqlanadi. Mana qisqartirilgan versiya:

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

Har bir vidjet beshta tartib massivlaridan biridagi bitta yozuv va uning sozlamalari aynan o‘sha yozuvda ichki joylashgan — alohida sozlamalar fayli ham, `config` kichik obyekti ham yo‘q. Soatning `format` i, `formatAlt` i (o‘ng tugma nimaga aylantirishi) va `verticalFormat` i — hammasi aynan `{ "id": "omarchy.clock" }` da joylashgan.

`center` — panel o‘rtasidagi quti: undagi hamma narsa ekranda bitta guruh sifatida markazlashtiriladi. `centerBegin` va `centerEnd` qutining ikki tomoniga osilib turadi, soat ob-havo va yangilanish belgisi kelib-ketib turganda ham aynan markazda qolishi shunday ta’minlanadi. `center` ga birdan ortiq vidjet qo‘ying va ular birga markazlashtiriladi; uni bo‘sh qoldiring va `centerBegin` bilan `centerEnd` panel o‘rtasida uchrashadi.

Ichiga singdirib olishga arziydigan bitta qoida: **o‘zingizning `shell.json` ingiz bo‘lgach, u kanonikdir**. Hech narsani moslashtirmaguningizcha qobiq Omarchy ning standart faylini o‘qiydi. Vidjetni sudragan, `omarchy bar` ni ishga tushirgan yoki faylni o‘zingiz tahrirlagan zahotingiz, u sizniki bo‘ladi — chuqur birlashtirish yo‘q, shuning uchun kelajakdagi Omarchy nashrlaridagi yangi standart vidjetlar panelingizda avtomatik paydo bo‘lmaydi. `omarchy bar defaults` qachon xohlasangiz toza sahifa uchun yetkazilgan tartibni qaytaradi.

Xuddi shu fayl `bar` kalitidan tashqarida, yuqori darajada bo‘sh turish vaqtlaringizni ham saqlaydi: `idle.screensaver` va `idle.lock`, ikkalasi ham bo‘sh turganingizdan beri soniyalarda. Shunday qilib standart ekran saqlagichi 150 soniyada ishga tushadi va qulflash 300 soniyada.
