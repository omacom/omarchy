# Klaviatura, Sichqoncha, Trekpad

Hyprland barcha kiritish qurilmalaringizni batafsil sozlash imkonini beradi. Klaviatura takrorlanishini nihoyatda tez qilishingiz yoki trekpadda tabiiy aylantirishdan foydalanishingiz mumkin. Hammasini `~/.config/hypr/input.lua` faylida oʻzgartirasiz, unga Omarchy menyusidagi (`Super + Space`) _Setup > Input_ orqali ham kirish mumkin. U yerda belgilagan har qanday sozlama Omarchy standartlarining oʻrnini bosadi.

Mana misol:

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

Kiritishlar boʻyicha Hyprland wiki sahifasida [barcha kiritish sozlamalarini koʻrishingiz](https://wiki.hypr.land/Configuring/Basics/Variables/#input) mumkin.

CapsLock oddiy Caps Lock sifatida ishlaydi, `Shift + CapsLock` esa [tezkor emojilar](07-hotkeys.md#quick-emojis) va [boshqa toʻldirishlar](07-hotkeys.md#quick-completions) uchun tuzish tugmasi hisoblanadi. Agar tuzish tugmasi boshqa joyda boʻlishini istasangiz, `kb_options` ichidagi `omarchy:shift_caps_compose` ni almashtiring. Masalan, quyidagisi tuzish tugmasini Right Alt ga koʻchiradi:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trekpad imo-ishoralari

Shuningdek, ish maydonlarini almashtirish uchun uch barmoq bilan surish kabi [sensor panel imo-ishoralarini](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) yoqishingiz mumkin:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Haptik sensor panelli Dell XPS noutbuklarida _Trigger > Hardware > Touchpad Haptics_ ostida bosish kuchini past, oʻrta yoki yuqori qilib ham belgilashingiz mumkin.

### Xitoy, yapon va boshqa tillarda yozish

Oʻrnatuvchi klaviaturangizni soʻraganda yapon, koreys, xitoy (soddalashtirilgan, Pinyin), Tayvan (Zhuyin) yoki Hong Kong (Cangjie) ni tanlang. Omarchy klaviatura va mos kiritish dvijogini avtomatik sozlaydi, shu jumladan oflayn birinchi yuklash sozlamasi paytida ham. Yapon tili Mozc dan, koreys tili standart ikki toʻplamli Hangul dan, soddalashtirilgan xitoy tili Pinyin dan, Tayvan Chewing ning standart Zhuyin tartibidan, Hong Kong esa Hong Kong belgi shakllariga ega Cangjie dan foydalanadi. Japanese (US keyboard) AQSH klaviatura tartibi bilan Mozc ni taqdim etadi. Lotin harflarini Dvorak, Colemak yoki AZERTY bilan yozsangiz ham, Hangul, Zhuyin va Cangjie tugmalari oʻzlarining standart joylarida qoladi. Agar bundan oldin Hangul yoki Chewing qoʻshgan boʻlsangiz, uning tugmalarini oʻsha joyga koʻchirish uchun _Setup > Typing > Input Methods_ ostida uni tanlovdan olib tashlang va qayta tanlang; Omarchy siz allaqachon yozayotgan dvijokni oʻz holicha qoldiradi.

Yozish lotin rejimida boshlanadi. Sozlangan kiritish usullari oʻrtasida aylanish uchun `Super + I` ni, orqaga aylanish uchun `Super + Shift + I` ni bosing. Pinyin kabi kiritish usulidan lotin harflariga chiqish uchun `Shift` ni alohida bosing, orqaga qaytish uchun uni yana bosing — Sogou, Microsoft Pinyin va macOS dagi kabi; `Shift` plyus harf hali ham bosh harf yozadi. Yapon klaviaturalarida 全角/半角 kiritishni almashtiradi, 変換 uni yoqadi va 無変換 uni oʻchiradi. Koreys tilida 한/영 Hangul ni almashtiradi va 한자 Hanja ga oʻgiradi, klaviaturangizda maxsus tugmalar boʻladimi yoki koʻplab noutbuklardagi kabi ular uchun Right Alt va Right Ctrl yuboriladimi, bundan qatʼi nazar, shuning uchun Right Alt va Right Ctrl u yerda oddiy oʻzgartiruvchi tugmalar emas; diktovka push-to-talk F9 da qoladi. `Ctrl + Space` Tmux va Herdr uchun mavjud boʻlib qoladi; `Shift + CapsLock` tuzish tugmasi boʻlib qoladi.

Bir nechta klaviatura tartibi yoki kiritish usulingiz boʻlsa, klaviatura koʻrsatkichi panelning oʻng tomonida paydo boʻladi. Kiritish tillarini almashtirish uchun uni bosing; yapon tili hiragana uchun あ ni koʻrsatadi. Yapon belgi variantlari uchun yapon tiliga oʻting, `nihongo` kabi soʻzni yozing, soʻng Space ni ikki marta bosing. Tanlovingizni qabul qilish uchun Enter ni bosing. Agar sizda bir nechta klaviatura tartibi ham boʻlsa, ular oʻrtasida aylanish uchun koʻrsatkichni oʻng tugma bilan bosing.

English va French kabi tartiblarni oʻrnatish paytida taklif qilingan oʻsha tanlovlar orasidan tanlash uchun _Setup > Typing > Keyboard Layouts_ dan foydalaning. Qaysi tuzish dvijoklari faol boʻlishini tanlash uchun _Setup > Typing > Input Methods_ dan foydalaning. Ikkala tanlagich ham joriy tanlovlaringiz belgilangan holda Omarchy menyusi ichida ochiladi. Tanlovni almashtirish uchun bosing yoki Enter ni bosing; har bir oʻzgarish darhol qoʻllanadi. Kiritish usulini tanlovdan olib tashlash uni oʻchirib tashlamasdan sikldan olib tashlaydi; klaviatura mavjud boʻlib qoladi.

Xuddi shu tanlagichlarni ochish uchun `omarchy setup keyboard` yoki `omarchy setup input` ni ishga tushiring. Buyruq satridan bitta tilni qoʻshish uchun `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` yoki `cangjie5` dan foydalaning. Quick, Boshiamy va Array Cangjie bilan bitta paketda keladi va Input Methods tanlagichida paydo boʻladi. Sizning maxsus almashtirish tugmalaringiz saqlanib qoladi. Muqobil dvijok tartiblari yoki tugmalari uchun `omarchy pkg add fcitx5-configtool` bilan `fcitx5-configtool` ni oʻrnating va uni terminaldan ishga tushiring. Kiritish tilini tanlash ish stoli tilini oʻzgartirmaydi. Hali hech qanday kiritish usulingiz boʻlmasa, _Setup > Language_ ostida yapon, koreys yoki xitoy tilini tanlash uning kiritish usulini qoʻshadi.

Kiritish usullari yoki klaviatura tartiblari oʻrtasida aylanish uchun `Super + I` dan, boshqa tomonga qaytish uchun `Super + Shift + I` dan foydalaning, shunday qilib uchtasi sozlangan boʻlsa, ikkita qoʻshni oʻrtasida harakatlanishingiz mumkin. Kiritish koʻrsatkichi faqat bir nechta kiritish usuli yoki tartibi sozlangan boʻlsa, panelning oʻng tomonida paydo boʻladi. Ushbu ish stoli bogʻlamasi mavjud Fcitx almashtirish tugmalaringiz bilan birga ishlaydi; uni `~/.config/hypr/bindings.lua` da bekor qilishingiz mumkin. Kiritish dvijoklari va tuzish ketma-ketliklari har bir sessiyada allaqachon ishlayotgan [Fcitx5](https://fcitx-im.org/) xizmatidan foydalanadi.

### ALT dan SUPER sifatida foydalanish

Baʼzi klaviaturalarda asosiy meta tugmasidan (Windows/cmd tugmasi) SUPER sifatida foydalanish qulay emas. Buning oʻrniga ALT boʻlishi uchun buni quyidagi oʻzgarish yordamida almashtirishingiz mumkin:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
