# Navigatsiya

Omarchydagi hamma narsa klaviatura orqali bo'ladi — _HAMMASI!_ Tizim ilk bor ishga tushganda, faqat sichqoncha bilan tom ma'noda hech narsa qila olmaysiz. Lekin Omarchy menyusini ochish uchun `Super + Space` ni bosishingiz mumkin va shu yerdan deyarli hamma narsani qila olasiz.

Lekin Omarchy menyusi ko'p hollarda tizimni boshqarishning asosiy usuli bo'lishi ham ko'zda tutilmagan. Biz bundan ham tezroq ishlay olamiz! Eng muhim ilovalarning barchasi to'g'ridan-to'g'ri alohida tezkor tugmalarga bog'langan. Terminalni `Super + Return` bilan, brauzerni esa `Super + Shift + Return` bilan ishga tushirasiz. Birini ketidan ikkinchisini bajarib ko'ring, shunda Hyprland plitkalashining sehrini amalda ko'rasiz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Keyin ularni yonma-yon emas, ustma-ust joylashtirish uchun `Super + J` ni bosishingiz mumkin:

 ![navigation-stacked](images/navigation-stacked.webp)

Ularni yonma-yon holatiga qaytarish uchun yana `Super + J` ni bosing. Keyin brauzerda turgan holda oynalarni almashtirish uchun `Super + Shift + Arrow Right` ni bosib ko'ring.

Endi Activity monitorini ishga tushirish uchun `Super + Shift + T` ni bosib ko'ring. U suzuvchi oyna sifatida paydo bo'ladi. Uni `Super + T` yordamida plitkalashingiz mumkin (yana shu tugmani bossangiz, u yana suzuvchi bo'lib qoladi). Endi fayl boshqaruvchisini ochish uchun `Super + Shift + F` ni bosing. Sizda chiroyli to'rt tomonlama joylashuv hosil bo'ladi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Faol bo'lishini xohlagan oynangizga `Super + Arrow` bilan o'tasiz. Bu fokusni almashtiradi va kursorni yangi ilovaning markaziga olib boradi. Ekran chetida u o'sha tomondagi monitorga o'tib ketaveradi.

Agar `Super + Shift + 2` ni bossangiz, hozir fokusdagi ilovani ikkinchi ish maydoniga ko'chirasiz. `Super + Shift + 1` uni qaytarib olib keladi. (`Super + Shift + Alt + 2` esa hozir fokusdagi ilovani ikkinchi ish maydoniga unga o'tmasdan ko'chiradi).

Bittadan ortiq monitor bo'lsa, har bir monitorning o'zining 1 dan 10 gacha ish maydonlari bo'ladi. `Super + 2` siz turgan monitorning ikkinchi ish maydoniga o'tadi, har bir monitorning yuqori paneli uning o'z ish maydonlarini va u ko'rsatayotganini ko'rsatadi. `Super + Tab` siz turgan monitordagi ish maydonlari bo'ylab aylanadi. `Super + Shift + Ctrl + Arrows` siz turgan oynani o'sha yo'nalishdagi monitorga, u ko'rsatayotgan ish maydoniga ko'chiradi, `Super + Shift + Alt + Arrows` esa siz turgan ish maydonini o'sha yo'nalishdagi monitorga ko'chiradi, u yerda u bo'sh bo'lsa o'sha raqamni oladi. Monitor uzilganda o'z ish maydonlarini saqlab qoladi: ular boshqa ekrannikiga qo'shiladi, unda allaqachon borlarining ketidan raqamlanadi va monitor qaytganda eski raqamlari ostiga qaytadi.

Agar `Super` ni bosib turib sichqoncha bilan oynani bossangiz, uning qayerda turishini qayta joylashtira olasiz. Agar `Super` ni bosib turib sichqonchaning o'ng tugmasidan foydalansangiz, oynani erkin o'lchamini o'zgartira olasiz.

Oynani `Super + W` yoki `Super + Q` bilan yopasiz (barcha oynalarni esa `Ctrl + Alt + Delete` bilan yopasiz).

Shuningdek, `Super + F` bilan to'liq ekranga o'tishingiz, yoki hatto `Super + Alt + F` bilan faqat to'liq kenglikka (yuqori panelni saqlab qolgan holda), yoki `Super + Ctrl + F` bilan oyna ichidagi to'liq ekranga o'tishingiz mumkin (YouTube uchun ajoyib!).

### Dwindle va aylantiriladigan joylashuv

Omarchyning standart joylashuvi dwindle deb ataladi. U bitta ish maydonida ochgan barcha oynalaringizni doimo ko'rinadigan holda saqlaydi, buning uchun ularni kichraytirishiga to'g'ri kelsa ham.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lekin ish maydonini oynalar yonma-yon qator bo'lib, displeyning ko'rinadigan chetidan tashqariga chiqib ketadigan aylantiriladigan joylashuvga aylantirishni ham tanlashingiz mumkin. Bitta ish maydonini `Super + L` orqali shu joylashuvga aylantirasiz.

`Super + L` ni yana bosish ish maydonini suzuvchiga aylantiradi, unda oynalar erkin ustma-ust tushadi va ularni o'zingiz joylashtirasiz, uchinchi marta bosish esa uni dwindle ga qaytaradi. `Super + Alt + L` ularni teskari yo'nalishda aylanadi. Baribir suzadigan oyna — `Super + T` bilan chiqarib olganingiz, yoki har doim suzuvchi bo'lib ochiladigan ilova — ish maydoni plitkalashga qaytganda suzishda davom etadi. Yuqori panel siz turgan ish maydonini uning joylashuvi bilan belgilaydi: dwindle uchun kvadrat, aylantiriladigan uchun doira va suzuvchi uchun uchburchak. O'sha belgini bosish ham joylashuvni aylanadi.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Tanlov har bir ish maydoni uchun alohida va saqlanib qoladi. Shunday qilib, 1-ish maydonini ko'rish uchun dwindle da, 2-ish maydonini esa kod uchun aylantiriladiganda saqlashingiz mumkin va ular qayta ishga tushgandan keyin ham shunday qaytadi.

Agar aylantiriladigan joylashuvni standart sifatida ishlatmoqchi bo'lsangiz, buni `~/.config/hypr/looknfeel.lua` da o'rnatishingiz mumkin:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Suzuvchi ish maydonlari

Suzuvchi ish maydoni an'anaviy ish stoli kabi ishlaydi: oynalar ustma-ust tushadi, ularni o'zingiz ko'chirasiz va o'lchamini o'zgartirasiz. Har bir oyna mavzuingiz ranglaridagi sarlavha paneliga ega bo'ladi, unda kichraytirish, kattalashtirish va yopish tugmalari bor. `Super + M` ham fokusdagi oynani kichraytiradi. Kichraytirilgan oyna dockda kutadi; uni qaytarish uchun ilovasini bosing. Oynani oldinga olib chiqish uchun uni bosing. Uni istalgan cheti yoki burchagidan o'lchamini o'zgartiring. Yuqori panelni ko'rinishda saqlab qolgan holda oynani kattalashtirish uchun sarlavha panelini ikki marta bosing, eski o'lchamini qaytarish uchun yana ikki marta bosing. Chrome va boshqa Chromium asosidagi brauzerlar, Disks va Document Viewer sarlavha panelini o'tkazib yuborib, o'rniga o'z sarlavhasidan foydalanadi; `Super + Alt + F` ularni kattalashtiradi, `Super + M` esa ularni kichraytiradi.

Suzuvchi ish maydoni shuningdek dockni ham ko'rsatadi, unda qadalgan ilovalaringiz, ishlayotgan hamma narsa va ilovalar tugmasi orqasidagi har bir ilovaning panjarasi bor, uni `Super + Alt + Space` va Omarchy menyusidagi _Apps_ ham ochadi. Ilovani o'chirish uchun panjaradagi ilovani o'ng tugma bilan bosing yoki `Delete` ni bosing. Ilovani ochish yoki uning oynasini oldinga olib chiqish uchun ilovani bosing; uning oynalari bo'ylab aylanish uchun yana bosing. Files faqat siz turgan ish maydonidan oynani qaytaradi, aks holda yangisini ochadi, Terminal va Agent esa har doim boshqasini ishga tushiradi, garchi kichraytirilgan oyna birinchi bo'lib qaytsa ham. O'rta tugma bilan bosish yangi oyna ochadi. Belgini ko'chirish uchun uni dock bo'ylab sudrab boring; ishlayotgan ilovani boshqalari orasiga sudrab kiritsangiz, u o'sha yerda qoladi. Ilovani dockda saqlash, undan olib tashlash yoki undan chiqish uchun o'ng tugma bilan bosing. Dock to'liq ekranli oynaga yo'l berib chetga chiqadi. Dockni boshqa chetga ko'chirish yoki ko'rsatgich uning chetiga yetguncha uni yashirib turish uchun ilovalar tugmasini o'ng tugma bilan bosing. Joylashuv shuningdek _Tashqi ko'rinish > Dock > Dock joylashuvi_ ostida ham bor, `omarchy dock position left` va `omarchy dock autohide on` esa ikkalasini ham terminaldan o'rnatadi. Dockda saqlaydigan ilovalaringiz ular ishlamayotgan paytda xira ko'rinadi.

Yangi ish maydonlari va `Super + L` bilan o'z joylashuvini bermaganlaringiz standart joylashuvdan foydalanadi. Standartni o'zgartirish oynalari yo'q har bir ish maydonini unga qayta o'rnatadi, oynalari bor ish maydoni esa o'zidagi joylashuvni saqlaydi. Dockga kichraytirilgan oyna hamon u tark etgan ish maydonidagi oyna sifatida hisoblanadi. Uni _Tashqi ko'rinish > Ish maydoni joylashuvi_ ostida tanlang: Plitkalash, Aylantiriladigan yoki Suzuvchi. `omarchy-hyprland-workspace-layout-default scrolling` uni terminaldan o'rnatadi.

### Oynalarni guruhlash

Oynalarni `Super + G` yordamida guruhlash mumkin. Guruhga kirganingizdan so'ng, u faol bo'lgan paytda ishga tushirgan har bir oynangiz guruhga tegishli bo'ladi. Bu guruhlangan oynalar orasida `Super + Ctrl + Arrow Left/Right` yordamida, yoki tartib bo'yicha guruhlangan oynalarga to'g'ridan-to'g'ri o'tish uchun `Super + Alt + 1/2/3/4` yordamida harakatlanishingiz mumkin.

Oynani `Super + Alt + G` bilan guruhlashdan chiqarishingiz yoki yana `Super + G` ni bosib butun guruhni tarqatib yuborishingiz mumkin. Va nihoyat, guruhdan tashqaridagi oynalarni uning ichiga `Super + Alt + Arrows` bilan ko'chirishingiz mumkin.

### Oynalarni chiqarib olish

Oynani `Super + O` bilan uning ish maydoniga ajratilgan joyidan chiqarib olishingiz mumkin. Bu uni qaysi ish maydoniga borsangiz ham siz bilan ergashadigan suzuvchi oyna sifatida qadaydi. Video pleyerlar va shunga o'xshashlar uchun ajoyib.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad ish maydoni

Hozir turgan ish maydoningiz ustiga qoplanadigan maxsus to'liq o'lchamli scratchpad ish maydoni bor. Undagi narsalarga `Super + S` bilan kirasiz, oynalarni esa u yerga `Super + Alt + S` bilan joylashtirasiz.

U hozirgi ish maydonini tark etmasdan tezda o'zaro ishlashni xohlaydigan boshqaruv elementlari yoki terminal uchun yaxshi ishlaydi.

### Quake konsoli

Va nihoyat, hozir turgan ish maydoningiz ustidan tushadigan yarim balandlikdagi Quake konsoli bor. Uni `Super + Grave` bilan almashtiring, oynani esa u yerga `Super + Shift + Grave` yordamida joylashtiring.

U standart agentingiz tayyor holatda ochiladi. Konsolda bitta oyna bo'lsa, u ekranni qoplamasdan, markazlashgan panel sifatida tushadi. Unga ikkinchi ilovani qo'ysangiz, u to'liq kenglikka qaytadi, shunda ikkalasiga yonma-yon joylashishga joy bo'ladi.

Oynani scratchpaddan ham, konsoldan ham ko'chirish uchun uni `Super + Shift + 1` kabi tugmalar bilan to'g'ridan-to'g'ri boshqa ish maydoniga yuboring.

### Bunga ko'nikishga biroz vaqt kerak bo'ladi!

Ish stolingizda shunday harakatlanishga ko'nikish biroz vaqt oladi, lekin ko'nikkaningizdan so'ng an'anaviy sichqoncha bilan boshqariladigan ish stoli tajribasiga qaytish qiyin bo'ladi!
