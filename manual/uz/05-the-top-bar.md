# Yuqori panel

Ekraningiz tepasidagi chiziq — Omarchy paneli. Bu mahkamlangan holat paneli emas, menyu, bildirishnomalar, OSD oynalari va qulf ekranni ham chizadigan yagona uzoq ishlaydigan Quickshell jarayoni — Omarchy shellining bir qismi. Shuning uchun u boshqa hamma narsa bilan mukammal mavzulashadi va panel yangi ilova ochmasdan bir zumda ochiladi.

Bu shuningdek har doim ekranda boʻladigan ish stolining yagona qismi, shuning uchun oʻsha kichik gliflarning hammasi nima qilishini bilishga arziydi.

## Standartda unda nimalar bor

Panel uchta boʻlimga ega. Chapda Omarchy logotipi (menyu ishga tushirgichi) va ish maydoni koʻrsatkichlari oʻtiradi. Markazda holat koʻrsatkichlari, soat, Elsewhen (dunyo soati), ob-havo va Omarchy yangilanish belgisi. Oʻngda: klaviatura tartibi (bittadan koʻproq sozlangan boʻlsa), tizim laganda, agentlar, bluetooth, tarmoq, ovoz, displey va quvvat.

Ulardan bir nechtasi faqat aytadigan narsasi boʻlganda paydo boʻladi. Klaviatura tartibi faqat bittadan koʻproq tartib sozlagan boʻlsangiz paydo boʻladi. Yangilanish belgisi faqat Omarchy yangilanishi kutayotgan boʻlsa paydo boʻladi. Va agentlar ikonkasi Omarchy mashinada AI kodlash ishlatilishini birinchi topganda paydo boʻladi ([AI](17-ai.md) ga qarang).

## Atrofni bosish

Deyarli har bir vidjet chap, oʻng va oʻrta bosishda nimadir qiladi va bir nechtasi aylantirishga javob beradi. Bu odamlar oʻtkazib yuboradigan qismi — oʻng va oʻrta tugmalar yaxshi narsalarning koʻpi yashirinadigan joydir.

| Vidjet | Chap | Oʻng | Oʻrta / aylantirish |
| --- | --- | --- | --- |
| Menyu | Omarchy menyusi | Yangi terminal | — |
| Ish maydonlari | Oʻsha ish maydoniga fokus | — | Aylantirish: keyingi/oldingi ish maydoni |
| Soat | Kalendar oynasi | Yorliq formatini aylantirish | Oʻrta: vaqt zonasi tanlogichi |
| Ob-havo | Prognoz oynasi | Toʻliq ob-havo bildirishnoma sifatida | Oʻrta: yangilash |
| Ovoz | Ovoz paneli | Ovozsiz | Oʻrta: panel · aylantirish: hajm |
| Mikrofon | Mikrofonni ovozsiz qilish | — | Oʻrta: ovoz paneli · aylantirish: kiritish hajmi |
| Tarmoq | Tarmoq paneli | — | — |
| Bluetooth | Bluetooth paneli | Radioni almashtirish | — |
| Displey | Displey paneli | — | Aylantirish: yorqinlik |
| Quvvat | Quvvat paneli | Batareya foizini almashtirish | — |
| Media | Oʻynatish/pauza | Albom muqovasi oynasi | Oʻrta: keyingi · aylantirish: oldingi/keyingi |
| Agentlar | Agentlar paneli | Agentingizni ishga tushirish | Oʻrta: keyingi obuna |
| Laganda | Tortmani ochish uchun ustiga olib borish | Boshqarish uchun shevronni oʻng bosish | — |
| Omarchy yangilanish | Yangilanishni ishga tushirish | — | — |

Oʻsha jadvaldagi hamma narsa qutidan chiqiboq panelingizda emas. Media vidjeti (aylanadigan trek va artist bilan MPRIS hozir oʻynalmoqda) va mikrofon vidjeti ikkalasi ham ichki, lekin standartda oʻchiq — xohlasangiz, quyida tasvirlanganidek, ularni qoʻshing.

## Panellar

Panel ikonkasanini bosish panelni ochadi, u asbob uchi emas, slayderlar, roʻyxatlar va klaviatura navigatsiyasiga ega toʻgʻri oynadir. Har birida hotkey ham bor, shuning uchun siz hech qachon 16 pikselli glifga nishan olishingizga toʻgʻri kelmaydi:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Ovoz |
| `Super + Ctrl + W` | Tarmoq |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displey |
| `Super + Ctrl + P` | Quvvat |
| `Super + Ctrl + Alt + D` | Kalendar |
| `Super + Ctrl + Alt + E` | Dunyo soati |
| `Super + Ctrl + 1-9` | Oʻng boʻlimdagi n-chi panelni almashtirish |

Panellar oʻqib beradigan narsa emas. Ular siz haqiqatan ishni bajaradigan joydir:

- **Ovoz**da asosiy hajm slayderi, chiqish qurilmasi tanlogichi va ilova boʻyicha mikser bor, shuning uchun boshqa hamma narsaga tegmasdan oʻsha bitta brauzer tabini pasaytirishingiz mumkin.
- **Tarmoq** Wi-Fi ni skanerlaydi, signal kuchini koʻrsatadi, ulanadi va DNS provayderni tanlash imkonini beradi.
- **Bluetooth** qurilmalaringizni ulanish/uzish va batareya darajasi bilan roʻyxatlaydi.
- **Quvvat** batareya statistikasini koʻrsatadi, quvvat rejimlarini almashtiradi (batareya va AC uchun alohida tanlovni eslab qoladi) va tizim maʼlumotlarini chop etadi.
- **Displey** yorqinlik slayderi, matn oʻlchami, monitor masshtablash oldindan sozlamalari va — bittadan koʻproq ekraningiz boʻlganda — monitor boʻyicha boshqaruvlarni tashiydi. Chuqurroq hikoya uchun [monitorlar](33-monitors.md) ga qarang.
- **Soat** oy qadamlari va ISO hafta raqamlari bilan oy panjarasini ochadi.

Har bir panel sichqoncha bilan birga klaviaturani ham oladi: oʻqlar harakatlanadi, Return faollashtiradi, Tab qoʻshni panelga qadam tashlaydi va Escape yopadi.

`Super + Ctrl + 1-9` oʻng boʻlimda panellarni chapdan oʻngga sanaydi, lagandani oʻtkazib yuboradi, chunki uning oʻz paneli yoʻq. Demak raqam siz koʻrsatadigan ikonkaga mos keladi.

### Tailscale va Dropbox

Yana ikkita vidjet panelda faqat mos xizmatni **Oʻrnatish → Xizmat** dan oʻrnatganingizdan keyin paydo boʻladi va ikkalasi ham bilishga arziydi, chunki ular holat xabar qilishdan koʻproq qiladi.

**Tailscale** paneli tailnetni ulaydi va uzadi, hisoblar orasida almashadi va chiqish tugunini tanlaydi (oʻz mashinalaringiz va Mullvad mintaqalari ikkalasi ham oʻsha roʻyxatda paydo boʻladi). U mashinalaringizni ham koʻrib chiqadi — va bittasi tanlangan holda, `s` unga Taildrop orqali fayllar yuboradi, bu faylni telefoningizga yoki boshqa noutbukga koʻchirishning eng tezkor yoʻlidir. `c` mashinaning IP sini, `n` uning nomini va `d` uning toʻliq DNS nomini nusxalaydi. Agar bosishni afzal koʻrsangiz, har bir mashina qatorida yuborish tugmasi ham bor. Terminaldan xuddi shuni `omarchy tailscale send <machine> [file...]` qiladi.

**Dropbox** paneli kirishni boshqaradi, qancha xotira ishlatganingizni koʻrsatadi va yaqinda sinxronlangan fayllarni roʻyxatlaydi.

Har ikkala xizmatni olib tashlash uning vidjetini paneldan olib tashlaydi.

## Koʻrsatkichlar

Markazdagi kichik klaster — koʻrsatkichlar vidjeti. Bular siz yoqqan rejimlar uchun holat gliflari: bezovta qilmang, tungi yorugʻlik, navbatga qoʻyilgan [eslatma](09-reminders.md), faol ekran yozuvi, uygʻoq qolish va [diktovka](11-text-extraction-dictation.md). Ular rejim faol boʻlganda yonadi va aks holda yoʻldan chetda qoladi — faol boʻlmaganlarni koʻrib chiqish uchun soatning chap tomoniga (vertikal panelda uning ustiga) olib boring. Koʻrsatkichni bosish oʻsha rejimni almashtiradi. Yana bittasi faqat holat: masofaviy sessiya birov gliff orqali ushbu mashinaga ulangan paytda qizil yonadi.

Agar ularning har doim koʻrinishini afzal koʻrsangiz, vidjetda `alwaysShow` ni `true` ga oʻrnating. Va agar ularning faqat baʼzilariga qiziqsangiz, xohlaganlaringizni `items` da roʻyxatlang: `["Dnd", "Reminder", "NightLight"]`. Sizda bittadan koʻproq koʻrsatkichlar vidjeti boʻlishi mumkin, shuning uchun turli boʻlimlar turli qism toʻplamlarni koʻrsatishi mumkin.

## Panelni qayta tartibga solish

Panel oʻzini sozlaydi. Narsalarni koʻchirish uchun konfiguratsiya faylini ochishingiz shart emas.

Markaz atrofidagi panelning boʻsh joyini ushlang va uni boshqa ekran chetiga sudrab boring va panel u yerga koʻchadi — chap, oʻng, yuqori yoki past hammasi ishlaydi va har bir vidjet moslashadi (vertikal panellar ixcham faqat ikonka shakllariga qaytadi). Bosib ushlab turish xuddi shu sudrashni boshlaydi. Panel fonini shaffofdan shishasimondan shaffofmasga aylantirish uchun oʻsha boʻsh joyni ikki marta chap bosing. Va istalgan vidjetni qayta tartibga solish yoki boshqa boʻlimga tashlash uchun sudrab boring.

Qoʻl ostingizda boʻlishini, lekin har doim koʻzga tashlanishini xohlamagan vidjet lagandaning tortmasida turishi mumkin: uni lagandaga sudrab boring, tortma uni qabul qilish uchun ochiladi. U u yerda ilova ikonkalaridan keyin joylashadi, tortma qachon ochilsa paydo boʻladi va paneli ochiq boʻlganda tortmani ochiq ushlab turadi. Uni joyiga qaytarish uchun yana panelga sudrab olib chiqing.

Agar menyudan tanlashni afzal koʻrsangiz, **Ishga tushirish → Koʻrinish → Menyu paneli** da joylashuv bor va **Panel foni** panel qanday chizilishini tanlaydi: **Shaffofmas panel**, **Shishasimon panel** (orqasidagi narsa xeralangan holda koʻrinadigan) yoki **Shaffof panel**.

Bir xil narsalarning buyruqlari bor, bu [dotfiles](31-dotfiles.md) sozlamasi uchun siz xohlagan narsadir:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Vidjetni butunlay qoʻshish yoki olib tashlash uchun plagin buyruqlaridan foydalaning. `omarchy plugin list` shell biladigan har bir vidjetni uning id si bilan chop etadi va keyin:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Panelni yashirish

`Super + Shift + Space` shellni oʻldirmasdan panelni oʻchiradi va yoqadi — panellar va hotkeylar ishlashda davom etadi, siz shunchaki piksellarni qaytarib olasiz. Bu menyuda **Ishga tushirish → Koʻrinish → Menyu paneli → Panelni yashirish** ostida ham bor.

## Konfiguratsiya fayli

Bularning hammasi `bar` tugmasi ostida `~/.config/omarchy/shell.json` da saqlanadi. Mana qisqartirilgan versiya:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Har bir vidjet uchta tartib massivlaridan birida bitta yozuvdir va uning sozlamalari oʻsha yozuvda ichki oʻtiradi — alohida sozlamalar fayli va `config` sub-obyekti yoʻq. Soatning `format`, `formatAlt` (oʻng bosish nimaga aylantiradi) va `verticalFormat` hammasi toʻgʻridan-toʻgʻri `{ "id": "omarchy.clock" }` da yashaydi.

`centerAnchor` ekranning aniq markaziga mahkamlanadigan bitta markaz vidjetini nomlaydi, boshqalar uni yonlaydi. Shunday qilib ob-havo va yangilanish belgisi kelib-ketib turganda ham soat aynan markazda qoladi. Uni boʻsh satrga oʻrnatsangiz, markaz roʻyxati oʻrniga guruh sifatida shunchaki markazlashtiriladi.

Ichki qabul qilishga arziydigan bitta qoida: **oʻz `shell.json` ingiz boʻlgandan keyin, u kanonikdir**. Hech narsani moslaganingizcha, shell Omarchyning standart faylini oʻqiydi. Vidjetni sudragan, `omarchy bar` ni ishga tushirgan yoki faylni oʻzingiz tahrirlagan paytingizda, siz uning egasisiz — chuqur birlashma yoʻq, shuning uchun kelajakdagi Omarchy relizlardagi yangi standart vidjetlar panelingizda avtomatik paydo boʻlmaydi. `omarchy bar defaults` toza taxta xohlaganingizda joʻnatilgan tartibni qaytaradi.

Xuddi shu fayl yuqori darajada, `bar` tugmasidan tashqarida boʻsh vaqtlaringizni ham saqlaydi: `idle.screensaver` va `idle.lock`, ikkalasi ham boʻsh qolganingizdan beri soniyalarda. Demak standart ekran saqlagich 150 soniyada va qulf 300 soniyada ishga tushadi.
