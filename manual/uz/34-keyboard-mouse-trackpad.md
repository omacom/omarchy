# Klaviatura, sichqoncha, trekpad

Hyprland barcha kiritish qurilmalaringizni juda batafsil sozlash imkonini beradi. Klaviatura takrorlanishini tovushdan ham tez qilishingiz yoki trekpadda tabiiy aylantirishni ishlatishingiz mumkin. Bularning barchasini `~/.config/hypr/input.lua` faylida o‘zgartirasiz, unga Omarchy menyusi (`Super + Space`) orqali _Setup > Input_ bo‘limidan ham kirishingiz mumkin. U yerda o‘rnatgan har qanday sozlamangiz Omarchy standart sozlamalarining o‘rnini egallaydi.

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

Hyprland wiki sahifasida kiritish bo‘yicha [barcha kiritish sozlamalarini ko‘rishingiz](https://wiki.hypr.land/Configuring/Basics/Variables/#input) mumkin.

CapsLock oddiy Caps Lock sifatida ishlaydi, `Shift + CapsLock` esa [tezkor emojilar](07-hotkeys.md#quick-emojis) va [boshqa to‘ldirishlar](07-hotkeys.md#quick-completions) uchun compose tugmasi hisoblanadi. Agar compose tugmasi boshqa joyda bo‘lishini istasangiz, `kb_options` ichidagi `omarchy:shift_caps_compose` ni almashtiring. Masalan, bu compose tugmasini Right Alt ga ko‘chiradi:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trekpad imo-ishoralari

Ish stolida harakatlanish uchun trekpadni suring:

| Imo-ishora | Amal |
| --- | --- |
| Uch barmoq chapga / o‘ngga | Oldingi / keyingi ish maydoni, bo‘shlarini ham qo‘shib |
| Uch barmoq yuqoriga | AI konsolini yoqish/o‘chirish |
| Uch barmoq pastga | Omarchy menyusini ochish |
| To‘rt barmoq chapga / o‘ngga | Faol oynani oldingi / keyingi ish maydoniga ko‘chirish |
| To‘rt barmoq pastga | To‘liq ekran rejimini yoqish/o‘chirish |

Bittasini o‘zgartirish uchun, o‘zingizning [trekpad imo-ishorangizni](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) qo‘shishdan oldin uni `~/.config/hypr/input.lua` faylida bekor qiling, chunki Hyprland bir xil barmoqlar va yo‘nalish uchun ikkita imo-ishorani qabul qilmaydi:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy imo-ishoralarining barchasini o‘chirish uchun, Omarchy standart sozlamalari yuklanishidan oldin, `~/.config/hypr/hyprland.lua` faylining yuqori qismiga yaqin joyda `omarchy_default_gestures = false` ni o‘rnating.

Haptik trekpadli Dell XPS noutbuklarida _Trigger > Hardware > Touchpad Haptics_ bo‘limida bosish kuchini past, o‘rta yoki yuqori qilib ham o‘rnatishingiz mumkin.

### Xitoy, yapon va boshqa tillarda yozish

O‘rnatuvchi klaviaturangizni so‘raganda yapon, koreys, xitoy (soddalashtirilgan, Pinyin), Tayvan (Zhuyin) yoki Gonkong (Cangjie) ni tanlang. Omarchy klaviatura va mos kiritish mexanizmini avtomatik sozlaydi, shu jumladan offlayn birinchi yuklash sozlamasi paytida ham. Yapon tili Mozc dan, koreys tili standart ikki to‘plamli Hangul dan, soddalashtirilgan xitoy tili Pinyin dan, Tayvan Chewing ning standart Zhuyin joylashuvidan, Gonkong esa Gonkong belgilar shakllariga ega Cangjie dan foydalanadi. Yapon (US klaviaturasi) US klaviatura joylashuvi bilan Mozc ni taqdim etadi. Hangul, Zhuyin va Cangjie tugmalari lotin harflarini Dvorak, Colemak yoki AZERTY bilan yozganingizda ham o‘z standart joylarida qoladi. Agar bundan oldin Hangul yoki Chewing ni qo‘shgan bo‘lsangiz, tugmalarini o‘sha joyga ko‘chirish uchun _Setup > Typing > Input Methods_ bo‘limida uni tanlovdan chiqarib, qayta tanlang; Omarchy siz allaqachon yozib turgan mexanizmni o‘z holicha qoldiradi.

Yozish lotin rejimida boshlanadi. Sozlangan kiritish usullari bo‘ylab aylanish uchun `Super + I` ni bosing, orqaga aylanish uchun esa `Super + Shift + I` ni bosing. Pinyin kabi kiritish usulidan lotin harflariga chiqish uchun `Shift` ni o‘zini bosing, orqaga qaytish uchun uni yana bosing, xuddi Sogou, Microsoft Pinyin va macOS ishlaganidek; `Shift` va harf hali ham bosh harf yozadi. Yapon klaviaturalarida 全角/半角 kiritishni almashtiradi, 変換 uni yoqadi va 無変換 uni o‘chiradi. Koreys tilida 한/영 Hangul ni almashtiradi va 한자 Hanja ga aylantiradi, klaviaturangizda maxsus tugmalar bo‘ladimi yoki ko‘plab noutbuklardagi kabi ular uchun Right Alt va Right Ctrl yuboriladimi, farqi yo‘q, shuning uchun Right Alt va Right Ctrl u yerda oddiy modifierlar emas; diktovka uchun bosib gapirish F9 da qoladi. `Ctrl + Space` Tmux va Herdr uchun mavjud bo‘lib qoladi; `Shift + CapsLock` compose tugmasi bo‘lib qoladi.

Bir nechta klaviatura joylashuvingiz yoki kiritish usulingiz bo‘lganda klaviatura indikatori panelning o‘ng tomonida paydo bo‘ladi. Kiritish tillarini almashtirish uchun uni bosing; yapon tili hiragana uchun あ ni ko‘rsatadi. Yapon belgilarini tanlash uchun yapon tiliga o‘ting, `nihongo` kabi so‘zni yozing, keyin Space ni ikki marta bosing. Tanlovingizni qabul qilish uchun Enter ni bosing. Agar sizda bir nechta klaviatura joylashuvi ham bo‘lsa, ular bo‘ylab aylanish uchun indikatorni o‘ng tugma bilan bosing.

O‘rnatish paytida taklif qilingan o‘sha tanlovlar orasidan English va French kabi joylashuvlarni tanlash uchun _Setup > Typing > Keyboard Layouts_ dan foydalaning. Qaysi tarkib tuzish mexanizmlari faol bo‘lishini tanlash uchun _Setup > Typing > Input Methods_ dan foydalaning. Ikkala tanlov oynasi ham Omarchy menyusi ichida joriy tanlovlaringiz belgilangan holda ochiladi. Tanlovni almashtirish uchun bosing yoki Enter ni bosing; har bir o‘zgarish darhol qo‘llanadi. Kiritish usulini tanlovdan chiqarish uni o‘chirib tashlamasdan sikldan olib tashlaydi; klaviatura mavjud bo‘lib qoladi.

Xuddi shu tanlov oynalarini ochish uchun `omarchy setup keyboard` yoki `omarchy setup input` ni ishga tushiring. Buyruq satridan bitta tilni qo‘shish uchun `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` yoki `cangjie5` dan foydalaning. Quick, Boshiamy va Array Cangjie bilan bir xil paketda keladi va Input Methods tanlov oynasida paydo bo‘ladi. Sizning maxsus almashtirish tugmalaringiz saqlanib qoladi. Mexanizmning muqobil joylashuvlari yoki tugmalari uchun `omarchy pkg add fcitx5-configtool` bilan `fcitx5-configtool` ni o‘rnating va uni terminaldan ishga tushiring. Kiritish tilini tanlash ish stoli tilini o‘zgartirmaydi. _Setup > Language_ bo‘limida yapon, koreys yoki xitoy tilini tanlash, sizda hali hech biri bo‘lmasa, uning kiritish usulini qo‘shadi.

Kiritish usullari yoki klaviatura joylashuvlari bo‘ylab aylanish uchun `Super + I` dan, boshqa yo‘nalishda orqaga qaytish uchun `Super + Shift + I` dan foydalaning, shunda uchtasi sozlangan bo‘lsa, ikkita qo‘shni o‘rtasida harakatlanishingiz mumkin. Kiritish indikatori panelning o‘ng tomonida faqat bittadan ortiq kiritish usuli yoki joylashuvi sozlangan bo‘lgandagina paydo bo‘ladi. Bu ish stoli bog‘lamasi mavjud Fcitx almashtirish tugmalaringiz bilan birga ishlaydi; uni `~/.config/hypr/bindings.lua` faylida bekor qilishingiz mumkin. Kiritish mexanizmlari va compose ketma-ketliklari har bir sessiyada allaqachon ishlayotgan [Fcitx5](https://fcitx-im.org/) xizmatidan foydalanadi.

### ALT ni SUPER sifatida ishlatish

Ba’zi klaviaturalarda asosiy meta tugmasini (Windows/cmd tugmasi) SUPER sifatida ishlatish qulay emas. Buning o‘rniga ALT bo‘lishi uchun uni ushbu o‘zgarish bilan almashtirishingiz mumkin:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
