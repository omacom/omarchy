# Navigatsiya

Omarchy'da hamma narsa klaviatura orqali bajariladi — _HAMMA NARSA!_ Tizim ilk bor ishga tushganda, faqat sichqoncha bilan tom ma'noda hech narsa qila olmaysiz. Lekin Omarchy menyusini ochish uchun `Super + Space` tugmalarini bosishingiz mumkin va shu yerdan deyarli hamma narsani bajarishingiz mumkin.

Lekin Omarchy menyusi ko'p hollarda tizimni boshqarishning asosiy usuli bo'lishi ham mo'ljallanmagan. Bundan ham tezroq ishlashimiz mumkin! Eng muhim ilovalarning barchasi to'g'ridan-to'g'ri alohida tezkor tugmalarga bog'langan. Terminalni `Super + Return` bilan, brauzerni esa `Super + Shift + Return` bilan ishga tushirasiz. Birini ketidan ikkinchisini bajarib ko'ring, Hyprland plitkalashining sehrini amalda ko'rasiz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Keyin ularni yonma-yon emas, bir-birining ustiga taxlash uchun `Super + J` tugmalarini bosishingiz mumkin:

 ![navigation-stacked](images/navigation-stacked.webp)

Ularni yonma-yon holatiga qaytarish uchun `Super + J` tugmalarini yana bosing. Keyin brauzerda turganingizda oynalarni almashtirish uchun `Super + Shift + Arrow Right` tugmalarini bosib ko'ring.

Endi Activity monitorini ishga tushirish uchun `Super + Shift + T` tugmalarini bosib ko'ring. U suzuvchi oyna sifatida paydo bo'ladi. Uni `Super + T` yordamida plitkalashingiz mumkin (yana suzuvchi qilish uchun shu tugmalarni yana bosing). Endi fayl menejerini ochish uchun `Super + Shift + F` tugmalarini bosing. Sizda chiroyli to'rt qismli joylashuv hosil bo'ladi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Faol bo'lishini xohlagan oynangizga `Super + Arrow` yordamida o'tasiz. Bu fokusni almashtiradi va kursorni yangi ilovaning markaziga olib boradi. Ekran chetida u o'sha tomondagi monitorga o'tishda davom etadi.

Agar `Super + Shift + 2` tugmalarini bossangiz, hozir fokusdagi ilovani ikkinchi ish maydoniga ko'chirasiz. `Super + Shift + 1` uni orqaga ko'chiradi. (Va `Super + Shift + Alt + 2` hozir fokusdagi ilovani unga o'tmasdan ikkinchi ish maydoniga ko'chiradi).

Bittadan ortiq monitor bo'lganda, har bir monitorning o'zining 1 dan 10 gacha ish maydonlari bo'ladi. `Super + 2` turgan monitoringizning ikkinchi ish maydoniga o'tadi, har bir monitorning yuqori paneli esa o'z ish maydonlarini va u ko'rsatayotganini ko'rsatadi. `Super + Tab` turgan monitoringizdagi ish maydonlari orasida navbat bilan aylanadi. `Super + Shift + Ctrl + Arrows` turgan oynangizni o'sha yo'nalishdagi monitorga, u ko'rsatayotgan ish maydoniga ko'chiradi, `Super + Shift + Alt + Arrows` esa turgan ish maydoningizni o'sha yo'nalishdagi monitorga ko'chiradi, u yerda u bo'sh bo'lsa, o'sha raqamni oladi. Monitor uzilganda o'z ish maydonlarini saqlab qoladi: ular boshqa ekrannikiga qo'shiladi, unda allaqachon mavjud bo'lganlaridan keyin raqamlanadi, monitor qaytganda esa eski raqamlari ostiga qaytadi.

Agar `Super` tugmasini bosib turib sichqoncha bilan oynani bossangiz, uning joylashuvini qayta tartiblashingiz mumkin bo'ladi. Agar `Super` tugmasini bosib turib sichqonchaning o'ng tugmasini ishlatsangiz, oynaning o'lchamini erkin o'zgartirishingiz mumkin.

Oynani `Super + W` yoki `Super + Q` bilan yopasiz (va barcha oynalarni `Ctrl + Alt + Delete` bilan yopasiz).

Shuningdek, `Super + F` bilan to'liq ekranga o'tishingiz, yoki `Super + Alt + F` bilan shunchaki to'liq kenglikka (yuqori panelni saqlab qolgan holda), yoki `Super + Ctrl + F` bilan oyna ichida to'liq ekranga o'tishingiz mumkin (YouTube uchun yaxshi!).

### Dwindle va scrolling tartibi

Omarchy'ning standart tartibi dwindle deb ataladi. U bitta ish maydonida ochgan barcha oynalaringizni har doim ko'rinadigan qilib saqlaydi, hatto ularni kichraytirishga to'g'ri kelsa ham.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lekin ish maydonini scrolling tartibiga aylantirishni ham tanlashingiz mumkin, unda oynalar displeyning ko'rinadigan chetidan tashqarida yonma-yon tiziladi. Bitta ish maydonini `Super + L` orqali shu tartibga aylantirasiz.

`Super + L` tugmalarini yana bosish ish maydonini suzuvchi holatga aylantiradi, unda oynalar erkin ustma-ust tushadi va ularni o'zingiz joylashtirasiz, uchinchi marta bosish esa uni dwindle'ga qaytaradi. `Super + Alt + L` ularni teskari yo'nalishda aylanib chiqadi. Baribir suzuvchi oyna — `Super + T` bilan chiqarib olganingiz yoki har doim suzuvchi bo'lib ochiladigan ilova — ish maydoni plitkalashga qaytganda ham suzuvchi bo'lib qoladi. Yuqori panel turgan ish maydoningizni uning tartibi bilan belgilaydi: dwindle uchun kvadrat, scrolling uchun doira va suzuvchi uchun uchburchak. Shu belgini bosish ham tartibni navbat bilan almashtiradi, noutbuklarda mavjud bo'lsa, displey tugmasi ham shunday qiladi.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Tanlov har bir ish maydoni uchun alohida va u saqlanib qoladi. Shunday qilib, 1-ish maydonini ko'rish uchun dwindle'da, 2-ish maydonini kod uchun scrolling'da saqlashingiz mumkin, ular qayta ishga tushirilgandan keyin ham shunday holatda qaytadi.

Scrolling tartibini standart sifatida ishlatishni xohlasangiz, uni `~/.config/hypr/looknfeel.lua` da o'rnatishingiz mumkin:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Suzuvchi ish maydonlari

Suzuvchi ish maydoni an'anaviy ish stoli kabi ishlaydi: oynalar ustma-ust tushadi, ularni o'zingiz ko'chirasiz va o'lchamini o'zgartirasiz. Har bir oyna mavzuingiz ranglaridagi sarlavha panelini oladi, unda kichraytirish, kattalashtirish va yopish tugmalari bo'ladi. `Super + M` ham fokusdagi oynani kichraytiradi. Kichraytirilgan oyna dock'da kutadi; uni qaytarish uchun ilovasini bosing. Oynani oldinga olib chiqish uchun uni bosing. Uni istalgan chet yoki burchakdan o'lchamini o'zgartiring. Yuqori panelni ko'rinishda saqlab qolgan holda oynani kattalashtirish uchun sarlavha panelini ikki marta bosing, eski o'lchamini qaytarish uchun yana ikki marta bosing. Chrome va Chromium asosidagi boshqa brauzerlar, Disks va Document Viewer sarlavha panelini o'tkazib yuboradi va o'rniga o'z sarlavhasidan foydalanadi; `Super + Alt + F` ularni kattalashtiradi, `Super + M` esa ularni kichraytiradi.

Suzuvchi ish maydoni, shuningdek, dock'ni ham ko'rsatadi, unda mahkamlangan ilovalaringiz, ishlayotgan hamma narsa va ilovalar tugmasi ortidagi har bir ilovaning panjarasi bo'ladi, uni `Super + Alt + Space` va Omarchy menyusidagi _Apps_ ham ochadi. Ilovani o'chirish uchun panjaradagi ilovani o'ng tugma bilan bosing yoki `Delete` tugmasini bosing. Ilovani ochish yoki uning oynasini oldinga olib chiqish uchun ilovani bosing; uning oynalari orasida navbat bilan aylanish uchun yana bosing. Files faqat turgan ish maydoningizdan oynani qaytaradi, aks holda yangisini ochadi, Terminal va Agent esa har doim boshqasini ishga tushiradi, lekin kichraytirilgan oyna avval qaytadi. O'rta tugmani bosish yangi oyna ochadi. Belgini ko'chirish uchun uni dock bo'ylab sudrab boring; ishlayotgan ilovani boshqalar orasiga sudrab olib kirish uni o'sha yerda saqlaydi. Ilovani dock'da saqlash, undan olib tashlash yoki undan chiqish uchun o'ng tugmani bosing. Dock to'liq ekranli oynaga yo'l bo'shatadi. Dock'ni boshqa chetga ko'chirish yoki ko'rsatkich uning chetiga yetguncha yashirinishi uchun ilovalar tugmasini o'ng tugma bilan bosing. Joylashuv _Appearance > Dock > Dock Position_ ostida ham bor, `omarchy dock position left` va `omarchy dock autohide on` esa ikkalasini ham terminaldan o'rnatadi. Dock'da saqlaydigan ilovalaringiz ishlamayotgan paytda xira bo'ladi.

Yangi ish maydonlari va `Super + L` bilan o'z tartibini bermagan har qanday ish maydonlari standart tartibdan foydalanadi. Standartni o'zgartirish oynalari bo'lmagan har bir ish maydonini unga qayta o'rnatadi, oynalari bor ish maydoni esa o'zidagi tartibni saqlaydi. Dock'ga kichraytirilgan oyna hali ham u tark etgan ish maydonidagi oyna hisoblanadi. Uni _Appearance > Workspace Layout_ ostida tanlang: Tiling, Scrolling yoki Floating. `omarchy hyprland workspace layout default scrolling` uni terminaldan o'rnatadi.

### Oynalarni guruhlash

Oynalarni `Super + G` yordamida guruhlash mumkin. Guruhga kirganingizdan keyin, u faol bo'lgan paytda ishga tushirgan har bir oynangiz guruhga tegishli bo'ladi. Guruhlangan oynalar orasida `Super + Ctrl + Arrow Left/Right` yordamida harakatlanishingiz, yoki tartib bo'yicha guruhlangan oynalarga to'g'ridan-to'g'ri o'tish uchun `Super + Alt + 1/2/3/4` dan foydalanishingiz mumkin.

Oynani `Super + Alt + G` bilan guruhlashdan chiqarishingiz yoki `Super + G` tugmalarini yana bosib butun guruhni tarqatib yuborishingiz mumkin. Nihoyat, guruhdan tashqaridagi oynalarni `Super + Alt + Arrows` bilan uning ichiga ko'chirishingiz mumkin.

### Oynalarni chiqarib olish

Oynani `Super + O` bilan ish maydoni taqsimotidan chiqarib olishingiz mumkin. Bu uni qaysi ish maydoniga borsangiz ham sizga ergashadigan suzuvchi oyna sifatida mahkamlaydi. Video pleyerlar va shunga o'xshashlar uchun ajoyib.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad ish maydoni

Hozir turgan ish maydoningiz ustiga qoplanadigan maxsus to'liq o'lchamli scratchpad ish maydoni bor. Undagi narsalarga `Super + S` yordamida kirasiz, oynalarni esa u yerga `Super + Alt + S` yordamida joylashtirasiz.

U joriy ish maydonini tark etmasdan tezda ishlatmoqchi bo'lgan boshqaruv elementlari yoki terminal uchun yaxshi ishlaydi.

### Quake konsoli

Nihoyat, hozir turgan ish maydoningiz ustiga tushadigan yarim balandlikdagi Quake konsoli bor. Uni `Super + the key above Tab` bilan almashtiring (AQSh tartiblarida grave), u yerga oynani esa `Super + Shift + the key above Tab` yordamida joylashtiring.

U birinchi marta ochilganda, standart agentingizni ishga tushiradi, yoki hali tanlamagan bo'lsangiz, bittasini tanlashingizni so'raydi. Konsolda bitta oyna bo'lgan paytda, u ekranni qoplamasdan, markazlashgan panel sifatida tushadi. Unga ikkinchi ilovani qo'ying, u to'liq kenglikka qaytadi, shunda ikkalasi yonma-yon joylashishi uchun joy bo'ladi.

Oynani scratchpad'dan yoki konsoldan ko'chirish uchun uni `Super + Shift + 1` kabi tugmalar bilan to'g'ridan-to'g'ri boshqa ish maydoniga yuboring.

### Bunga ko'nikish uchun biroz vaqt kerak!

Ish stolingizda shu tarzda harakatlanishga ko'nikish uchun biroz vaqt kerak bo'ladi, lekin ko'nikkaningizdan keyin an'anaviy sichqoncha bilan boshqariladigan ish stoli tajribasiga qaytish qiyin bo'ladi!
