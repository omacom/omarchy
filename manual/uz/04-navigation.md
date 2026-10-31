# Navigatsiya

Omarchy'da hamma narsa klaviatura orqali amalga oshiriladi — _HAMMA NARSA!_ Tizim birinchi marta ishga tushganda, sichqonchaning o'zi bilan tom ma'noda hech narsa qila olmaysiz. Lekin Omarchy Menu'ni ochish uchun `Super + Space` tugmalarini bosishingiz mumkin va bu yerdan deyarli hamma narsani qila olasiz.

Lekin Omarchy menyusi hatto ko'p vaqt davomida tizimni boshqarishning asosiy usuli bo'lishi ham mo'ljallanmagan. Biz bundan ham tezroq qila olamiz! Eng muhim ilovalarning barchasi to'g'ridan-to'g'ri alohida tezkor tugmalarga bog'langan. Terminalni `Super + Return` bilan, brauzerni esa `Super + Shift + Return` bilan ishga tushirasiz. Birin-ketin qilib ko'ring, shunda Hyprland plitkalashining sehrini amalda ko'rasiz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Keyin ularni yonma-yon emas, bir-birining ustiga taxlash uchun `Super + J` tugmalarini bosishingiz mumkin:

 ![navigation-stacked](images/navigation-stacked.webp)

Ularni yonma-yon holatiga qaytarish uchun yana `Super + J` tugmalarini bosing. Keyin brauzerda turgan holda oynalarni almashtirish uchun `Super + Shift + Arrow Right` tugmalarini bosib ko'ring.

Endi Activity monitor'ni ishga tushirish uchun `Super + Shift + T` tugmalarini bosib ko'ring. U suzuvchi oyna sifatida paydo bo'ladi. Uni `Super + T` yordamida plitkalashingiz mumkin (uni yana suzuvchi qilish uchun o'sha tugmalarni yana bosing). Endi fayllar boshqaruvchisini ochish uchun `Super + Shift + F` tugmalarini bosing. Sizda chiroyli to'rt tomonlama joylashuv hosil bo'ladi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Faol bo'lishini xohlagan oynangizga `Super + Arrow` yordamida o'tasiz. Bu fokusni almashtiradi va kursorni yangi ilovaning markaziga olib boradi. Ekranning chetida u o'sha tomondagi monitorga o'tib ketadi.

Agar `Super + Shift + 2` tugmalarini bossangiz, hozir fokusdagi ilovani ikkinchi ish maydoniga ko'chirasiz. `Super + Shift + 1` uni ortga qaytaradi. (Va `Super + Shift + Alt + 2` hozir fokusdagi ilovani ikkinchi ish maydoniga unga o'tmasdan ko'chiradi).

Bir nechta monitor bo'lsa, har bir monitorning o'zining 1 dan 10 gacha ish maydonlari bo'ladi. `Super + 2` siz turgan monitorning ikkinchi ish maydoniga o'tadi, har bir monitorning yuqori paneli esa uning o'z ish maydonlarini va u ko'rsatayotganini ko'rsatadi. `Super + Tab` siz turgan monitordagi ish maydonlari bo'ylab aylanib o'tadi. `Super + Shift + Ctrl + Arrows` siz turgan oynani o'sha yo'nalishdagi monitorga, u ko'rsatayotgan ish maydoniga ko'chiradi, `Super + Shift + Alt + Arrows` esa siz turgan ish maydonini o'sha yo'nalishdagi monitorga ko'chiradi, u yerda agar bo'sh bo'lsa, o'sha raqamni oladi. Monitor uzilganda o'z ish maydonlarini saqlab qoladi: ular boshqa ekrannikiga qo'shiladi, unda allaqachon borlarining ketidan raqamlanadi va monitor qaytganda eski raqamlari ostiga qaytadi.

`Super` tugmasini bosib turib, sichqoncha bilan oynani bossangiz, uning qayerda turishini qayta tartibga sola olasiz. Agar `Super` tugmasini bosib turib, sichqonchaning o'ng tugmasini ishlatsangiz, oynaning o'lchamini erkin o'zgartira olasiz.

Oynani `Super + W` yoki `Super + Q` bilan yopasiz (va barcha oynalarni `Ctrl + Alt + Delete` bilan yopasiz).

Shuningdek, `Super + F` bilan to'liq ekranga o'tishingiz, yoki `Super + Alt + F` bilan shunchaki to'liq kenglikka (yuqori panelni saqlab qolgan holda), yoki `Super + Ctrl + F` bilan oyna ichida to'liq ekranga o'tishingiz mumkin (YouTube uchun ayni muddao!).

### Dwindle va scrolling tartibi

Omarchy'ning standart tartibi dwindle deb ataladi. U bitta ish maydonida ochgan barcha oynalaringizni doim ko'rinadigan qilib turadi, hatto ularni kichraytirishga to'g'ri kelsa ham.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lekin ish maydonini scrolling tartibiga aylantirishni ham tanlashingiz mumkin, unda oynalar displeyning ko'rinadigan chetidan tashqarida yonma-yon tizilib turadi. Bitta ish maydonini `Super + L` orqali shu tartibga aylantirasiz.

`Super + L` tugmalarini yana bosish ish maydonini suzuvchiga aylantiradi, unda oynalar erkin bir-birini qoplaydi va ularni o'zingiz joylashtirasiz, uchinchi marta bosish esa uni dwindle'ga qaytaradi. `Super + Alt + L` ularni teskari tartibda aylanib o'tadi. Baribir suzib yuradigan oyna — `Super + T` bilan chiqarib olganingiz yoki doim suzuvchi bo'lib ochiladigan ilova — ish maydoni plitkalashga qaytganda ham suzuvchi bo'lib qoladi. Yuqori panel siz turgan ish maydonini uning tartibi bilan belgilaydi: dwindle uchun kvadrat, scrolling uchun doira va suzuvchi uchun uchburchak. O'sha belgini bosish ham tartibni aylanib o'tadi.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Tanlov har bir ish maydoni uchun alohida va u saqlanib qoladi. Shunday qilib, 1-ish maydonini ko'rib chiqish uchun dwindle'da, 2-ish maydonini esa kod uchun scrolling'da saqlashingiz mumkin va ular qayta ishga tushirilgandan keyin ham shunday qaytadi.

Agar scrolling tartibini standart sifatida ishlatmoqchi bo'lsangiz, uni `~/.config/hypr/looknfeel.lua` faylida o'rnatishingiz mumkin:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Suzuvchi ish maydonlari

Suzuvchi ish maydoni an'anaviy ish stoli kabi ishlaydi: oynalar bir-birini qoplaydi, ularni o'zingiz ko'chirasiz va o'lchamini o'zgartirasiz. Har bir oyna mavzuingiz ranglaridagi sarlavha paneliga ega bo'ladi, unda kichraytirish, kattalashtirish va yopish tugmalari bo'ladi. `Super + M` ham fokusdagi oynani kichraytiradi. Kichraytirilgan oyna dock'da kutadi; uni qaytarish uchun ilovasini bosing. Oynani oldinga chiqarish uchun uni bosing. Uning o'lchamini istalgan chet yoki burchakdan o'zgartiring. Yuqori panelni ko'rinishda saqlagan holda oynani kattalashtirish uchun sarlavha panelini ikki marta bosing, eski o'lchamini qaytarish uchun yana ikki marta bosing.

Suzuvchi ish maydoni shuningdek dock'ni ham ko'rsatadi, unda mahkamlangan ilovalaringiz, ishlayotgan hamma narsa va ilovalar tugmasi ortidagi har bir ilovaning to'ri bo'ladi, uni `Super + Alt + Space` va Omarchy menyusidagi _Apps_ ham ochadi. Ilovani o'chirib tashlash uchun to'rdagi ilovani o'ng tugma bilan bosing yoki `Delete` tugmasini bosing. Ilovani ochish yoki uning oynasini oldinga chiqarish uchun uni bosing; uning oynalari bo'ylab aylanib o'tish uchun yana bosing. O'rta tugma bilan bosish yangi oyna ochadi. Belgini ko'chirish uchun uni dock bo'ylab sudrab boring; ishlayotgan ilovani boshqalar orasiga sudrab kiritsangiz, u o'sha yerda qoladi. Ilovani dock'da saqlash, undan chiqarib olish yoki undan chiqish uchun o'ng tugma bilan bosing. Dock to'liq ekranli oynaga yo'l bo'shatadi. Dock'ni boshqa chetga ko'chirish yoki ko'rsatkich uning chetiga yetguncha yashirinib turishini ta'minlash uchun ilovalar tugmasini o'ng tugma bilan bosing. Joylashuv shuningdek _Appearance > Dock > Dock Position_ ostida ham bor, `omarchy dock position left` va `omarchy dock autohide on` esa ikkalasini ham terminaldan o'rnatadi. Dock'da saqlagan ilovalaringiz ishlamayotgan paytda xira ko'rinadi.

Yangi ish maydonlari va `Super + L` bilan o'z tartibini bermaganlaringiz standart tartibdan foydalanadi. Standartni o'zgartirish oynalari yo'q har bir ish maydonini unga qayta o'rnatadi, oynalari bor ish maydoni esa o'zidagi tartibni saqlab qoladi. Dock'ga kichraytirilgan oyna hamon u tark etgan ish maydonidagi oyna sifatida hisoblanadi. Uni _Appearance > Workspace Layout_ ostida tanlang: Tiling, Scrolling yoki Floating. `omarchy-hyprland-workspace-layout-default scrolling` uni terminaldan o'rnatadi.

### Oynalarni guruhlash

Oynalarni `Super + G` yordamida guruhlash mumkin. Guruhga kirganingizdan keyin, u faol bo'lgan paytda ishga tushirgan har bir oynangiz guruhga tegishli bo'ladi. Bu guruhlangan oynalar orasida `Super + Ctrl + Arrow Left/Right` yordamida harakatlanishingiz yoki tartib bo'yicha guruhlangan oynaga to'g'ridan-to'g'ri o'tish uchun `Super + Alt + 1/2/3/4` tugmalaridan foydalanishingiz mumkin.

Oynani `Super + Alt + G` bilan guruhdan chiqarishingiz yoki yana `Super + G` tugmalarini bosib butun guruhni tarqatib yuborishingiz mumkin. Va nihoyat, guruhdan tashqaridagi oynalarni `Super + Alt + Arrows` bilan uning ichiga ko'chirishingiz mumkin.

### Oynalarni chiqarib olish

Oynani `Super + O` bilan uning ish maydonidagi joyidan chiqarib olishingiz mumkin. Bu uni qaysi ish maydoniga o'tsangiz ham siz bilan birga boradigan suzuvchi oyna sifatida mahkamlaydi. Video pleyerlar va shunga o'xshashlar uchun ayni muddao.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad ish maydoni

Hozir turgan ish maydoningiz ustiga qoplanadigan maxsus to'liq o'lchamli scratchpad ish maydoni bor. Undagi narsalarga `Super + S` yordamida kirasiz, oynalarni esa u yerga `Super + Alt + S` yordamida joylashtirasiz.

U hozirgi ish maydonini tark etmasdan tezda ishlatmoqchi bo'lgan boshqaruv elementlari yoki terminal uchun juda qo'l keladi.

### Quake konsoli

Va nihoyat, hozir turgan ish maydoningiz ustiga tushadigan yarim balandlikdagi Quake konsoli bor. Uni `Super + Grave` bilan almashtiring, oynani esa u yerga `Super + Shift + Grave` yordamida joylashtiring.

U standart agentingiz tayyor holatda ochiladi. Konsolda bitta oyna bo'lgan paytda, u ekranni qoplamasdan, markazlashgan panel sifatida tushadi. Unga ikkinchi ilovani qo'ying, shunda u yana to'liq kenglikka qaytadi, toki ikkalasiga yonma-yon joylashishga joy bo'lsin.

Oynani scratchpad'dan ham, konsoldan ham ko'chirish uchun uni `Super + Shift + 1` kabi tugmalar bilan to'g'ridan-to'g'ri boshqa ish maydoniga yuboring.

### Bunga ko'nikish uchun biroz vaqt kerak!

Ish stolingizda shu tarzda harakatlanishga ko'nikish uchun biroz vaqt kerak bo'ladi, lekin ko'nikkaningizdan keyin an'anaviy sichqoncha bilan boshqariladigan ish stoli tajribasiga qaytish qiyin bo'ladi!
