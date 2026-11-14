# Navigatsiya

Omarchy'da hamma narsa klaviatura orqali sodir bo'ladi — _HAMMA NARSA!_ Tizim birinchi marta ishga tushganda, siz tom ma'noda faqat sichqoncha bilan hech narsa qila olmaysiz. Lekin Omarchy Menu'ni ochish uchun `Super + Space` tugmasini bosishingiz mumkin va shu yerdan deyarli hamma narsani qilishingiz mumkin.

Lekin Omarchy menyusi ko'p hollarda tizimni boshqarishning asosiy usuli bo'lishi ham mo'ljallanmagan. Biz bundan ham tezroq qila olamiz! Eng muhim ilovalarning hammasiga to'g'ridan-to'g'ri alohida tezkor tugmalar biriktirilgan. Siz terminalni `Super + Return` bilan, brauzerni esa `Super + Shift + Return` bilan ishga tushirasiz. Birini ketidan ikkinchisini bosib ko'ring, shunda Hyprland plitkalarining sehrini amalda ko'rasiz:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Keyin ularni yonma-yon o'rniga bir-birining ustiga taxlash uchun `Super + J` tugmasini bosishingiz mumkin:

 ![navigation-stacked](images/navigation-stacked.webp)

Ularni yonma-yon holatlariga qaytarish uchun `Super + J` ni yana bosing. Keyin brauzerdaligingizda oynalarni almashtirish uchun `Super + Shift + Arrow Right` ni bosib ko'ring.

Endi Activity monitorini ishga tushirish uchun `Super + Shift + T` ni bosib ko'ring. U suzuvchi oyna sifatida paydo bo'ladi. Siz `Super + T` yordamida uni plitkali qilishingiz mumkin (uni yana suzuvchi qilish uchun yana shu tugmani bosing). Endi fayl menejerini ochish uchun `Super + Shift + F` ni bosing. Sizda chiroyli to'rt tomonlama joylashuv bo'ladi:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Siz `Super + Arrow` bilan faol bo'lishini xohlagan oynangiz o'rtasida harakatlanasiz. Bu fokusni almashtiradi va kursorni yangi ilovaning markaziga ko'chiradi. Ekranning chetida u o'sha tomondagi monitorga o'tib ketadi.

Agar `Super + Shift + 2` ni bossangiz, hozir fokusdagi ilovani ikkinchi ish maydoniga ko'chirasiz. `Super + Shift + 1` uni orqaga ko'chiradi. (Va `Super + Shift + Alt + 2` hozir fokusdagi ilovani ikkinchi ish maydoniga, unga o'tmasdan ko'chiradi).

Bittadan ortiq monitorda har bir monitorning o'zining 1 dan 10 gacha bo'lgan ish maydonlari bor. `Super + 2` siz turgan monitorning ikkinchi ish maydoniga o'tadi va har bir monitorning yuqori paneli uning o'z ish maydonlarini va u ko'rsatayotganini ko'rsatadi. `Super + Tab` siz turgan monitordagi ish maydonlari o'rtasida aylanadi. `Super + Shift + Ctrl + Arrows` siz turgan oynani o'sha yo'nalishdagi monitorga, u ko'rsatayotgan ish maydoniga ko'chiradi va `Super + Shift + Alt + Arrows` siz turgan ish maydonini o'sha yo'nalishdagi monitorga ko'chiradi, u yerda bo'sh bo'lsa shu raqamni oladi. Monitor uzilganida o'z ish maydonlarini saqlab qoladi: ular boshqa ekrannikilariga qo'shiladi, unda allaqachon borlaridan keyin raqamlanadi va monitor qaytganda eski raqamlari ostiga qaytadi.

Agar `Super` ni bosib turib sichqoncha bilan oynani bossangiz, uning qayerda turishini qayta tartiblay olasiz. Agar `Super` ni bosib turib sichqonchaning o'ng tugmasidan foydalansangiz, oynaning o'lchamini erkin o'zgartira olasiz.

Siz oynani `Super + W` yoki `Super + Q` bilan yopasiz (va barcha oynalarni `Ctrl + Alt + Delete` bilan yopasiz).

Siz shuningdek `Super + F` bilan to'liq ekranga o'tishingiz yoki hatto `Super + Alt + F` bilan faqat to'liq kenglikka (yuqori panelni saqlab) yoki `Super + Ctrl + F` bilan oyna ichidagi to'liq ekranga o'tishingiz mumkin (YouTube uchun yaxshi!).

### Dwindle vs scrolling tartibi

Omarchy'ning standart tartibi dwindle deb ataladi. U bitta ish maydonida ochgan barcha oynalaringizni doimo ko'rinadigan qilib saqlaydi, hatto ularni kichraytirishga to'g'ri kelsa ham.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lekin siz ish maydonini oynalar yonma-yon, displeyning ko'rinadigan chetidan tashqarida tiziladigan scrolling tartibiga aylantirishni ham tanlashingiz mumkin. Siz bitta ish maydonini `Super + L` orqali shu tartibga aylantirasiz.

`Super + L` ni yana bosish ish maydonini suzuvchi holatga aylantiradi, bu yerda oynalar erkin ustma-ust tushadi va siz ularni o'zingiz joylashtirasiz, uchinchi marta bosish esa uni dwindle'ga qaytaradi. `Super + Alt + L` ularni teskari tartibda aylanib chiqadi. Baribir suzib yuradigan oyna — `Super + T` bilan chiqarib olganingiz yoki har doim suzuvchi bo'lib ochiladigan ilova — ish maydoni plitkalashga qaytganda suzishda davom etadi. Yuqori panel siz turgan ish maydonini uning tartibi bilan belgilaydi: dwindle uchun kvadrat, scrolling uchun doira va suzuvchi uchun uchburchak. O'sha belgini bosish ham tartibni almashtiradi.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Tanlov har bir ish maydoni uchun alohida va u saqlanib qoladi. Shunday qilib, siz 1-ish maydonini ko'rib chiqish uchun dwindle'da va 2-ish maydonini kod uchun scrolling'da saqlashingiz mumkin va ular qayta ishga tushirilgandan keyin ham shunday qaytadi.

Agar scrolling tartibini standart sifatida ishlatishni xohlasangiz, uni `~/.config/hypr/looknfeel.lua` da o'rnatishingiz mumkin:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Suzuvchi ish maydonlari

Suzuvchi ish maydoni an'anaviy ish stoli kabi ishlaydi: oynalar ustma-ust tushadi va siz ularni o'zingiz ko'chirasiz va o'lchamini o'zgartirasiz. Har bir oyna mavzuingiz ranglaridagi titlebar'ga ega bo'ladi, unda kichraytirish, kattalashtirish va yopish tugmalari bor. `Super + M` ham fokusdagi oynani kichraytiradi. Kichraytirilgan oyna dock'da kutadi; uni qaytarish uchun ilovasini bosing. Oynani oldinga chiqarish uchun uni bosing. Uni istalgan chetidan yoki burchagidan o'lchamini o'zgartiring. Yuqori panelni ko'rinadigan qilib saqlagan holda oynani kattalashtirish uchun titlebar'ni ikki marta bosing va eski o'lchamini qaytarish uchun yana bosing. Chrome va boshqa Chromium asosidagi brauzerlar, Disks va Document Viewer titlebar'ni o'tkazib yuborib, uning o'rniga o'z sarlavhasidan foydalanadi; `Super + Alt + F` ularni kattalashtiradi va `Super + M` ularni kichraytiradi.

Suzuvchi ish maydoni shuningdek dock'ni ko'rsatadi, unda mahkamlangan ilovalaringiz, ishlayotgan hamma narsa va ilovalar tugmasi orqasidagi har bir ilovaning panjarasi bor, uni `Super + Alt + Space` va Omarchy menyusidagi _Apps_ ham ochadi. Ilovani o'chirib tashlash uchun panjaradagi ilovani o'ng tugma bilan bosing yoki `Delete` ni bosing. Ilovani ochish yoki uning oynasini oldinga chiqarish uchun ilovani bosing; uning oynalari o'rtasida aylanish uchun yana bosing. O'rta tugma bilan bosish yangi oyna ochadi. Belgini ko'chirish uchun uni dock bo'ylab sudrab boring; ishlayotgan ilovani boshqalar orasiga sudrab kiritsangiz u o'sha yerda qoladi. Ilovani dock'da saqlash, uni olib tashlash yoki undan chiqish uchun o'ng tugmani bosing. Dock to'liq ekranli oyna yo'lidan chekinadi. Dock'ni boshqa chetga ko'chirish yoki ko'rsatkich uning chetiga yetguncha yashirinishi uchun ilovalar tugmasini o'ng tugma bilan bosing. Joylashuv shuningdek _Appearance > Dock > Dock Position_ ostida ham bor va `omarchy dock position left` hamda `omarchy dock autohide on` ikkalasini ham terminaldan o'rnatadi. Dock'da saqlagan ilovalaringiz ishlamayotgan vaqtida xira ko'rinadi.

Yangi ish maydonlari va `Super + L` bilan o'z tartibini bermagan har qanday ish maydoni standart tartibni ishlatadi. Standartni o'zgartirish oynalari bo'lmagan har bir ish maydonini unga qayta o'rnatadi, ustida oynalari bor ish maydoni esa o'zidagi tartibni saqlab qoladi. Dock'ga kichraytirilgan oyna hamon u tark etgan ish maydonidagi oyna sifatida hisoblanadi. Uni _Appearance > Workspace Layout_ ostida tanlang: Tiling, Scrolling yoki Floating. `omarchy-hyprland-workspace-layout-default scrolling` uni terminaldan o'rnatadi.

### Oynalarni guruhlash

Oynalarni `Super + G` yordamida guruhlash mumkin. Guruhga kirganingizdan keyin, u faol bo'lguncha ishga tushirgan har bir oynangiz guruhga tegishli bo'ladi. Siz bu guruhlangan oynalar o'rtasida `Super + Ctrl + Arrow Left/Right` yordamida yoki tartib bilan guruhlangan oynalarga to'g'ridan-to'g'ri o'tish uchun `Super + Alt + 1/2/3/4` yordamida harakatlanishingiz mumkin.

Siz `Super + Alt + G` bilan oynani guruhlashdan chiqarishingiz yoki `Super + G` ni yana bosib butun guruhni tarqatib yuborishingiz mumkin. Va nihoyat, siz `Super + Alt + Arrows` bilan guruhdan tashqaridagi oynalarni uning ichiga ko'chirishingiz mumkin.

### Oynalarni chiqarib olish

Siz `Super + O` bilan oynani uning ish maydoni taqsimotidan chiqarib olishingiz mumkin. Bu uni qayerga borsangiz ham ish maydoningizda sizga ergashadigan suzuvchi oyna sifatida mahkamlaydi. Video pleyerlar va shunga o'xshashlar uchun ajoyib.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad ish maydoni

Hozir turgan ish maydoningiz ustiga qoplanadigan maxsus to'liq o'lchamli scratchpad ish maydoni bor. Siz undagi narsalarga `Super + S` yordamida kirasiz va u yerga oynalarni `Super + Alt + S` yordamida joylashtirasiz.

U joriy ish maydonini tark etmasdan tezda o'zaro ta'sir qilmoqchi bo'lgan boshqaruv elementlari yoki terminal uchun yaxshi ishlaydi.

### Quake konsoli

Nihoyat, hozir turgan ish maydoningiz ustiga tushadigan yarim balandlikdagi Quake konsoli bor. Uni `Super + Grave` bilan almashtiring va u yerga `Super + Shift + Grave` yordamida oyna joylashtiring.

U standart agentingiz tayyor holda ochiladi. Konsol bitta oynani ushlab turganida, u ekranni qoplamasdan markazlashtirilgan panel sifatida tushadi. Unga ikkinchi ilovani qo'ying, shunda u to'liq kenglikka qaytadi, shu tariqa ikkalasiga yonma-yon turishga joy bo'ladi.

Oynani scratchpad'dan ham, konsoldan ham ko'chirish uchun uni `Super + Shift + 1` kabi narsa bilan to'g'ridan-to'g'ri boshqa ish maydoniga yuboring.

### Bunga ko'nikish uchun biroz vaqt kerak!

Ish stolingizda shu tarzda harakatlanishga ko'nikish uchun biroz vaqt kerak bo'ladi, lekin ko'nikkaningizdan keyin an'anaviy sichqoncha bilan boshqariladigan ish stoli tajribasiga qaytish qiyin bo'ladi!
