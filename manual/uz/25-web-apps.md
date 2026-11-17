# Veb-ilovalar

Siz Omarchy menyusidagi (`Super + Space`) _O‘rnatish > Veb-ilova_ orqali o‘zingizning veb-ilovalaringizni qo‘shishingiz mumkin. U sizdan ilova nomini, ilova URL manzilini va, agar favicon orqali ololmasa, ikona URL manzilini so‘raydi. Ko‘plab mashhur veb-ilovalar uchun ajoyib PNG ikonalarni [Dashboard Icons](https://dashboardicons.com) saytida topishingiz mumkin.

Keyin ular ilovalarni ishga tushirgich (`Super + Space`) orqali mavjud bo‘ladi va chiroyli ramkasiz veb-ilova oynasidan foydalanadi.

Agar veb-ilovani olib tashlamoqchi bo‘lsangiz, shunchaki Omarchy menyusida _Olib tashlash > Veb-ilova_ bo‘limiga o‘ting.

Veb-ilova yorliqlaridan foydalanishdan oldin barcha hisoblaringizga oddiy brauzer orqali kirib olganingiz ma’qul. Yupqa o‘ram ramkasi 1password bilan yaxshi ishlamaydi, shuning uchun avval to‘g‘ridan-to‘g‘ri kirib olish osonroq.

Bu veb-ilovalar uchun barcha klaviatura tezkor tugmalarini `~/.config/hypr/bindings.lua` faylida o‘zgartirish mumkin.

Veb-ilovada bo‘lganingizda, `Shift + Alt + L` yordamida joriy URL manzilini almashuv buferiga nusxalashingiz mumkin.

Odatiy holatda, Omarchy allaqachon turli xil standart ilovalar to‘plami bilan keladi:

## HEY

[HEY](https://www.hey.com/) Gmail, Outlook yoki Apple Mail dan charchaganlar uchun ajoyib muqobil bo‘ladigan elektron pochta va taqvim xizmatidir. U Omarchy paydo bo‘lgan [37signals](https://37signals.com/) tomonidan yaratilgan.

HEY Email ni `Super + Shift + E` yordamida ishga tushirishingiz, `Super + Shift + Alt + E` yordamida to‘g‘ridan-to‘g‘ri yangi xat yozishga o‘tishingiz va HEY Calendar ni `Super + Shift + C` yordamida ishga tushirishingiz mumkin.

## Basecamp

[Basecamp](https://basecamp.com/) kichik jamoalarga tezroq harakat qilish va ko‘proq natijaga erishishga yordam beradigan loyihalarni boshqarish xizmatidir. Trello, Slack, Asana, Notion yoki boshqa nimaningdir aralashmasini yig‘ib yurish o‘rniga, Basecamp bilan hammasini bir joyda olishingiz mumkin. U Omarchy paydo bo‘lgan [37signals](https://37signals.com/) tomonidan yaratilgan.

Basecamp ni ilovalarni ishga tushirgich (`Super + Space`) yordamida ishga tushirishingiz mumkin

## ChatGPT

[ChatGPT](https://chatgpt.com) dunyodagi eng mashhur AI chat-botdir.

ChatGPT ni `Super + Shift + A` yordamida ishga tushirishingiz mumkin.

## Grok

[Grok](https://grok.com) xAI ning chat-botidir.

Grok ni `Super + Shift + Alt + A` yordamida ishga tushirishingiz mumkin.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) dunyodagi eng mashhur xabar almashish xizmatlaridan biri bo‘lib, veb-versiyasi Linux uchun ajoyib tanlovdir.

WhatsApp ni `Super + Shift + Alt + G` yordamida ishga tushirishingiz mumkin.

## Google ilovalari

Google Messages, Google Photos, Google Maps va Google Contacts ham veb-ilovalar sifatida kiritilgan.

Google Messages ni `Super + Shift + Ctrl + G` yordamida, Google Photos ni `Super + Shift + P` yordamida va Google Maps ni `Super + Shift + S` yordamida ishga tushirishingiz mumkin. Google Contacts ilovalarni ishga tushirgich (`Super + Space`) orqali mavjud.

## X

X — yangiliklar tarqaladigan joy.

X ni `Super + Shift + X` yordamida ishga tushirishingiz va `Super + Shift + Alt + X` yordamida to‘g‘ridan-to‘g‘ri yangi post yozishga o‘tishingiz mumkin.

## YouTube

[YouTube](https://youtube.com/) dunyodagi eng mashhur video platformadir.

YouTube ni `Super + Shift + Y` yordamida ishga tushirishingiz mumkin.

## Zoom

[Zoom](https://zoom.us/) AQShda ishlatiladigan eng mashhur videochat tizimidir. Butun dunyo bo‘ylab ajoyib aloqalar. Va 40 daqiqalik uchrashuvlarni pullik hisobsiz ham o‘tkazish mumkin. Omarchy Zoom ning veb-mijozini o‘rab oladi va zoom uchrashuv havolalari to‘g‘ridan-to‘g‘ri unda ochiladi.

Zoom ni ilovalarni ishga tushirgich (`Super + Space`) yordamida ishga tushirasiz.

## Discord

[Discord](https://discord.com/) aksariyat gaming va open source hamjamiyatlari, jumladan [Omarchy ning o‘zi](https://discord.gg/tXFUdasqhY) ham to‘planadigan joydir.

Discord ni ilovalarni ishga tushirgich (`Super + Space`) yordamida ishga tushirasiz.

## Microsoft ilovalari

Outlook, Word, Excel, PowerPoint, Teams va OneDrive ni veb-ilovalar sifatida qo‘shish uchun _O‘rnatish > Xizmat > Microsoft_ ni tanlang. Har bir ilovaning o‘z ishga tushirgichi bor va u tijoriy Microsoft 365 URL manzillari hamda mavjud brauzer profilingizdan foydalanib, to‘g‘ridan-to‘g‘ri ochiladi. Ular Omarchy ning boshqa veb-ilovalari kabi bir xil brauzer ilova oynalarida ochiladi; ular alohida Teams for Linux mijozini o‘rnatmaydi.

To‘plamni _Olib tashlash > Xizmat > Microsoft_ orqali olib tashlang yoki alohida ilovalarni _Olib tashlash > Veb-ilova_ orqali olib tashlang. Shuningdek, faqat o‘zingiz xohlagan ilovalarni _O‘rnatish > Veb-ilova_ orqali o‘rnatishingiz mumkin.

Davlat yoki suveren bulut uchun, `~/.local/share/applications/` ostidagi tegishli ishga tushirgichda, masalan, `Microsoft Teams.desktop` da, `Exec=` qatoridagi URL manzilni tashkilotingiz bergan URL manzil bilan tahrirlang. O‘sha qatordagi har qanday literal `%` ni `%%` sifatida yozing. O‘zgarishlar keyingi ishga tushirishda qo‘llanadi. To‘plam o‘rnatuvchisini yana ishga tushirish uning ishga tushirgichlarini standart URL manzillar bilan almashtiradi.

Ishga kirishlarni alohida saqlash uchun, har bir ishga tushirgichning `Exec=` qatoriga brauzer ma’lumotlar katalogini qo‘shing:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Misol katalogni o‘zingiz tanlagan mutlaq yo‘l bilan almashtiring va ishga kirishlarni ular orasida ulashish uchun barcha oltita ishga tushirgich uchun bir xil yo‘ldan foydalaning. Veb-ilovalar Omarchy tomonidan tanlangan qo‘llab-quvvatlanadigan brauzerdan foydalanadi, standart brauzer qo‘llab-quvvatlanmasa, Chrome ga qaytadi.
