# Klaviatura, Sichqoncha, Trekpad

Hyprland barcha kiritish qurilmalaringizni juda batafsil sozlash imkonini beradi. Klaviatura takrorlanishini tovushdan ham tez qilib qo'yishingiz yoki trekpadda tabiiy aylantirishni yoqishingiz mumkin. Bularning hammasini `~/.config/hypr/input.lua` faylida o'zgartirasiz, unga Omarchy menyusidagi (`Super + Space`) _Sozlash > Kiritish_ orqali ham yetishingiz mumkin. U yerda belgilagan har qanday narsa Omarchy standartlarini almashtiradi.

Mana bir misol:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Kiritishlar bo'yicha Hyprland wiki sahifasida [barcha kiritish parametrlarini ko'rishingiz](https://wiki.hypr.land/Configuring/Basics/Variables/#input) mumkin.

CapsLock odatdagi Caps Lock sifatida ishlaydi, `Shift + CapsLock` esa [tezkor emojilar](07-hotkeys.md#quick-emojis) va [boshqa to'ldirishlar](07-hotkeys.md#quick-completions) uchun tuzish tugmasi hisoblanadi. Agar tuzish tugmasi boshqa joyda bo'lishini istasangiz, `kb_options` ichidagi `omarchy:shift_caps_compose` ni almashtiring. Masalan, bu tuzish tugmasini O'ng Alt ga ko'chiradi:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funksiya tugmalari

Noutbuk klaviaturasining yuqori qatori sukut bo'yicha media tugmalarini (ovoz balandligi, yorqinlik va boshqalar) yuboradi, `Fn` ni ushlab turish esa F1-F12 ni beradi; `Fn + Esc` uni qayta bossangizga qadar teskari holatda qulflaydi. Ko'pchilik klaviaturalar bu qulfni o'zlari eslab qoladi. ASUS noutbuklari va Apple uslubidagi klaviaturalar buni Linux ga qoldiradi, Linux esa ularni har bir yuklanishda media tugmalarida ishga tushiradi. Ular o'rniga F1-F12 da ishga tushishi uchun `omarchy device keyboard toprow fnkeys` buyrug'ini bajaring (orqaga qaytish uchun `omarchy device keyboard toprow mediakeys`); ba'zi noutbuklarda bu qayta yuklashdan keyin kuchga kiradi. Apple Silicon Mac lar o'z sozlamalarini saqlab qoladi.

### Trekpad imo-ishoralari

Ish stoli bo'ylab harakatlanish uchun trekpadda suring:

| Imo-ishora | Amal |
| --- | --- |
| Uch barmoq chapga / o'ngga | Oldingi / keyingi ish maydoni, bo'shlarini ham qo'shib |
| Uch barmoq yuqoriga | AI konsolini almashtirish |
| Uch barmoq pastga | Omarchy menyusini ochish |
| To'rt barmoq chapga / o'ngga | Faol oynani oldingi / keyingi ish maydoniga ko'chirish |
| To'rt barmoq pastga | To'liq ekranni almashtirish |

Birini o'zgartirish uchun, o'zingizning [trekpad imo-ishorangizni](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) qo'shishdan oldin uni `~/.config/hypr/input.lua` da bekor qiling, chunki Hyprland bir xil barmoqlar va yo'nalishga ikkita imo-ishorani qabul qilmaydi:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy ning barcha imo-ishoralarini o'chirish uchun, Omarchy standartlari yuklanishidan oldin, `~/.config/hypr/hyprland.lua` ning yuqori qismiga yaqin joyda `omarchy_default_gestures = false` ni o'rnating.

Haptik trekpadga ega Dell XPS noutbuklarida _Trigger > Qurilma > Touchpad Haptics_ ostida bosish kuchini past, o'rta yoki yuqori qilib ham o'rnatishingiz mumkin.

### Xitoy, yapon va boshqa tillarda yozish

O'rnatuvchi klaviaturangizni so'raganda Yapon, Koreys, Xitoy (Soddalashtirilgan, Pinyin), Tayvan (Zhuyin) yoki Gonkong (Cangjie) ni tanlang. Omarchy klaviaturani va mos kiritish dvigatelini avtomatik sozlaydi, shu jumladan oflayn birinchi yuklash sozlash paytida ham. Yapon tili Mozc dan, koreys tili standart ikki to'plamli Hangul dan, soddalashtirilgan xitoy tili Pinyin dan, Tayvan Chewing ning standart Zhuyin joylashuvidan, Gonkong esa Gonkong belgilar shakllari bilan Cangjie dan foydalanadi. Yapon (AQSH klaviaturasi) AQSH klaviatura tartibi bilan Mozc ni taqdim etadi. Hangul, Zhuyin va Cangjie tugmalari, Dvorak, Colemak yoki AZERTY bilan lotin harflarini yozganingizda ham, o'z standart pozitsiyalarida qoladi. Agar bundan oldin Hangul yoki Chewing qo'shgan bo'lsangiz, uning tugmalarini u yerga ko'chirish uchun _Sozlash > Klaviatura > Kiritish usullari_ ostida uni bekor qilib, qayta tanlang; Omarchy siz allaqachon yozib kelayotgan dvigatelni o'z holicha qoldiradi.

Yozish lotin rejimida boshlanadi. Sozlangan kiritish usullari bo'ylab aylanish uchun `Super + I` ni, orqaga aylanish uchun `Super + Shift + I` ni bosing. Pinyin kabi kiritish usulidan lotin harflariga chiqish uchun `Shift` ni o'zini bosing, orqaga qaytish uchun uni yana bosing, xuddi Sogou, Microsoft Pinyin va macOS ishlaganidek; `Shift` va harf hali ham bosh harf yozadi. Yapon klaviaturalarida 全角/半角 kiritishni almashtiradi, 変換 uni yoqadi va 無変換 uni o'chiradi. Koreys tili bilan 한/영 Hangul ni almashtiradi va 한자 Hanja ga o'giradi, klaviaturangizda maxsus tugmalar bo'ladimi yoki ular uchun O'ng Alt va O'ng Ctrl yuboradimi, ko'p noutbuklar shunday qiladi, shuning uchun O'ng Alt va O'ng Ctrl u yerda oddiy modifikatorlar emas; o'rniga diktovka Alt + Space bilan almashadi. `Ctrl + Space` Tmux va Herdr uchun mavjud bo'lib qoladi; `Shift + CapsLock` tuzish tugmasi bo'lib qoladi.

Bir nechta klaviatura tartibi yoki kiritish usulingiz bo'lganda, panelning o'ng tomonida klaviatura ko'rsatkichi paydo bo'ladi. Kiritish tillarini almashtirish uchun uni bosing; yapon tili hiragana uchun あ ni ko'rsatadi. Yapon belgilarini tanlash uchun yapon tiliga o'ting, `nihongo` kabi so'z yozing, keyin Space ni ikki marta bosing. Tanlovingizni qabul qilish uchun Enter ni bosing. Agar sizda bir nechta klaviatura tartibi ham bo'lsa, ular bo'ylab aylanish uchun ko'rsatkichni o'ng tugma bilan bosing.

Ingliz va fransuz kabi tartiblarni, o'rnatish paytida taklif qilingan bir xil tanlovlardan, tanlash uchun _Sozlash > Klaviatura > Klaviatura kiritishlari_ dan foydalaning. Qaysi tuzish dvigatellari faol ekanini tanlash uchun _Sozlash > Klaviatura > Kiritish usullari_ dan foydalaning. Ikkala tanlovchi ham joriy tanlovlaringiz belgilangan holda Omarchy menyusi ichida ochiladi. Tanlovni almashtirish uchun bosing yoki Enter ni bosing; har bir o'zgarish darhol qo'llaniladi. Kiritish usulini bekor qilish uni o'chirmasdan aylanishdan olib tashlaydi; klaviatura mavjud bo'lib qoladi.

Xuddi shu tanlovchilarni ochish uchun `omarchy setup keyboard` yoki `omarchy setup input` ni bajaring. Buyruq satridan bitta til qo'shish uchun `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` yoki `cangjie5` dan foydalaning. Quick, Boshiamy va Array Cangjie bilan bir xil paketda keladi va Kiritish usullari tanlovchisida paydo bo'ladi. Sizning maxsus almashtirish tugmalaringiz saqlanib qoladi. Muqobil dvigatel tartiblari yoki tugmalari uchun `omarchy pkg add fcitx5-configtool` bilan `fcitx5-configtool` ni o'rnating va uni terminaldan ishga tushiring. Kiritish tilini tanlash ish stoli tilini o'zgartirmaydi. _Sozlash > Mintaqa > Til_ ostida yapon, koreys yoki xitoy tilini tanlash, sizda hali hech biri bo'lmasa, uning kiritish usulini qo'shadi.

Kiritish usullari yoki klaviatura tartiblari bo'ylab aylanish uchun `Super + I` dan, boshqa yo'nalishda orqaga borish uchun `Super + Shift + I` dan foydalaning, shuning uchun uchtasi sozlangan bo'lsa, ikkita qo'shni o'rtasida harakatlanishingiz mumkin. Kiritish ko'rsatkichi panelning o'ng tomonida faqat bir nechta kiritish usuli yoki tartibi sozlangan bo'lganda paydo bo'ladi. Bu ish stoli bog'lanishi mavjud Fcitx almashtirish tugmalaringiz bilan birga ishlaydi; uni `~/.config/hypr/bindings.lua` da bekor qilishingiz mumkin. Kiritish dvigatellari va tuzish ketma-ketliklari har bir sessiyada allaqachon ishlayotgan [Fcitx5](https://fcitx-im.org/) xizmatidan foydalanadi.

### ALT dan SUPER sifatida foydalanish

Ba'zi klaviaturalarda asosiy meta tugmasini (Windows/cmd tugmasi) SUPER sifatida ishlatish qulay emas. Buning o'rniga ALT bo'lishi uchun ushbu o'zgarishdan foydalanib, buni almashtirishingiz mumkin:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
