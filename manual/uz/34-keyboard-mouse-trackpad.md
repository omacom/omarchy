# Klaviatura, Sichqoncha, Trekpad

Hyprland barcha kiritish qurilmalaringizni batafsil sozlashga imkon beradi. Siz klaviatura takrorlanishini nihoyatda tez qilishingiz yoki trekpadda tabiiy aylantirishdan foydalanishingiz mumkin. Bularning barchasini `~/.config/hypr/input.lua` faylida o‘zgartirasiz, unga Omarchy menyusi (`Super + Space`) orqali _Setup > Input_ bo‘limidan ham kirishingiz mumkin. U yerda o‘rnatgan har qanday sozlamangiz Omarchy’ning standart sozlamalari o‘rnini bosadi.

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

Hyprland wiki’sida kiritish bo‘yicha [barcha kiritish parametrlarini ko‘rishingiz](https://wiki.hypr.land/Configuring/Basics/Variables/#input) mumkin.

CapsLock oddiy Caps Lock sifatida ishlaydi, `Shift + CapsLock` esa [tezkor emojilar](07-hotkeys.md#quick-emojis) va [boshqa to‘ldirishlar](07-hotkeys.md#quick-completions) uchun compose tugmasidir. Agar compose tugmasi boshqa joyda bo‘lishini afzal ko‘rsangiz, `kb_options` ichidagi `omarchy:shift_caps_compose` ni almashtiring. Masalan, bu compose tugmasini Right Alt ga ko‘chiradi:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trekpad imo-ishoralari

Ish stoli bo‘ylab harakatlanish uchun trekpadda suring:

| Imo-ishora | Amal |
| --- | --- |
| Uch barmoq chapga / o‘ngga | Oldingi / keyingi ish maydoni, bo‘shlarini ham qo‘shib |
| Uch barmoq yuqoriga | AI konsolini yoqish/o‘chirish |
| Uch barmoq pastga | Omarchy menyusini ochish |
| To‘rt barmoq chapga / o‘ngga | Faol oynani oldingi / keyingi ish maydoniga ko‘chirish |
| To‘rt barmoq pastga | To‘liq ekranni yoqish/o‘chirish |

Birini o‘zgartirish uchun, o‘zingizning [trekpad imo-ishorangizni](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) qo‘shishdan oldin uni `~/.config/hypr/input.lua` faylida bekor qiling, chunki Hyprland bir xil barmoqlar va yo‘nalishga ikkita imo-ishorani qabul qilmaydi:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy’ning barcha imo-ishoralarini o‘chirish uchun, Omarchy’ning standart sozlamalari yuklanishidan oldin, `~/.config/hypr/hyprland.lua` faylining yuqori qismiga yaqin joyda `omarchy_default_gestures = false` ni o‘rnating.

Haptik trekpadga ega Dell XPS noutbuklarida _Trigger > Hardware > Touchpad Haptics_ bo‘limida bosish kuchini low, mid yoki high qilib o‘rnatishingiz ham mumkin.

### Xitoy, yapon va boshqa tillarda yozish

O‘rnatuvchi klaviaturangizni so‘raganda Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) yoki Hong Kong (Cangjie) ni tanlang. Omarchy klaviaturani va mos kiritish mexanizmini avtomatik sozlaydi, shu jumladan oflayn birinchi yuklashni sozlash paytida ham. Japanese Mozc dan foydalanadi, Korean standart ikki to‘plamli Hangul dan foydalanadi, Simplified Chinese Pinyin dan foydalanadi, Taiwan Chewing’ning standart Zhuyin tartibidan foydalanadi va Hong Kong Hong Kong belgilar shakllari bilan Cangjie dan foydalanadi. Japanese (US keyboard) US klaviatura tartibi bilan Mozc ni taqdim etadi. Hangul, Zhuyin va Cangjie tugmalari, siz lotin harflarini Dvorak, Colemak yoki AZERTY bilan yozganingizda ham, o‘zlarining standart joylarida qoladi. Agar bundan oldin Hangul yoki Chewing ni qo‘shgan bo‘lsangiz, uning tugmalarini o‘sha yerga ko‘chirish uchun _Setup > Typing > Input Methods_ bo‘limida uni bekor qilib, qayta tanlang; Omarchy siz allaqachon yozayotgan mexanizmga tegmaydi.

Yozish Latin rejimida boshlanadi. Sozlangan kiritish usullari bo‘ylab aylanish uchun `Super + I` ni, orqaga aylanish uchun `Super + Shift + I` ni bosing. Pinyin kabi kiritish usulidan lotin harflariga chiqish uchun `Shift` ni alohida teging, qaytish uchun uni yana teging — Sogou, Microsoft Pinyin va macOS ishlagani kabi; `Shift` va harf hali ham bosh harfni yozadi. Japanese klaviaturalarida 全角/半角 kiritishni almashtiradi, 変換 uni yoqadi va 無変換 uni o‘chiradi. Korean bilan 한/영 Hangul ni almashtiradi va 한자 Hanja ga o‘zgartiradi — klaviaturangizda buning uchun ajratilgan tugmalar bo‘ladimi yoki ko‘plab noutbuklardagi kabi ular uchun Right Alt va Right Ctrl yuboriladimi, bundan qat’i nazar — shuning uchun Right Alt va Right Ctrl u yerda oddiy modifikatorlar emas; buning o‘rniga diktovka Alt + Space bilan almashtiriladi. `Ctrl + Space` Tmux va Herdr uchun mavjud bo‘lib qoladi; `Shift + CapsLock` compose tugmasi bo‘lib qoladi.

Klaviatura ko‘rsatkichi bir nechta klaviatura tartibingiz yoki kiritish usulingiz bo‘lganda panelning o‘ng tomonida paydo bo‘ladi. Kiritish tillarini almashtirish uchun uni bosing; Japanese hiragana uchun あ ni ko‘rsatadi. Japanese belgi variantlari uchun Japanese ga o‘ting, `nihongo` kabi so‘zni yozing, keyin Space ni ikki marta bosing. Tanlovingizni qabul qilish uchun Enter ni bosing. Agar sizda bir nechta klaviatura tartibi ham bo‘lsa, ular bo‘ylab aylanish uchun ko‘rsatkichni o‘ng tugma bilan bosing.

English va French kabi tartiblarni, o‘rnatish paytida taklif qilingan o‘sha tanlovlardan, tanlash uchun _Setup > Typing > Keyboard Layouts_ dan foydalaning. Qaysi terish mexanizmlari faol ekanini tanlash uchun _Setup > Typing > Input Methods_ dan foydalaning. Ikkala tanlagich ham Omarchy menyusi ichida joriy tanlovlaringiz belgilangan holda ochiladi. Tanlovni almashtirish uchun bosing yoki Enter ni bosing; har bir o‘zgarish darhol qo‘llaniladi. Kiritish usulini bekor qilish uni o‘chirmasdan turib sikldan olib tashlaydi; klaviatura mavjud bo‘lib qoladi.

Xuddi shu tanlagichlarni ochish uchun `omarchy setup keyboard` yoki `omarchy setup input` ni ishga tushiring. Buyruq satridan bitta tilni qo‘shish uchun `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` yoki `cangjie5` dan foydalaning. Quick, Boshiamy va Array Cangjie bilan bir xil paketda keladi va Input Methods tanlagichida paydo bo‘ladi. Sizning maxsus almashtirish tugmalaringiz saqlanib qoladi. Muqobil mexanizm tartiblari yoki tugmalari uchun `omarchy pkg add fcitx5-configtool` bilan `fcitx5-configtool` ni o‘rnating va uni terminaldan ishga tushiring. Kiritish tilini tanlash ish stoli tilini o‘zgartirmaydi. Agar sizda hali hech biri bo‘lmasa, _Setup > Language_ bo‘limida Japanese, Korean yoki Chinese ni tanlash uning kiritish usulini qo‘shadi.

Kiritish usullari yoki klaviatura tartiblari bo‘ylab aylanish uchun `Super + I` dan, boshqa tomonga qaytish uchun `Super + Shift + I` dan foydalaning, shuning uchun uchtasi sozlangan bo‘lsa, ikkita qo‘shni o‘rtasida harakatlanishingiz mumkin. Kiritish ko‘rsatkichi faqat bir nechta kiritish usuli yoki tartibi sozlangan bo‘lganda panelning o‘ng tomonida paydo bo‘ladi. Ushbu ish stoli bog‘lanishi mavjud Fcitx almashtirish tugmalaringiz bilan birga ishlaydi; uni `~/.config/hypr/bindings.lua` faylida bekor qilishingiz mumkin. Kiritish mexanizmlari va compose ketma-ketliklari har bir sessiyada allaqachon ishlayotgan [Fcitx5](https://fcitx-im.org/) xizmatidan foydalanadi.

### ALT ni SUPER sifatida ishlatish

Ba’zi klaviaturalarda asosiy meta tugmasini (Windows/cmd tugmasini) SUPER sifatida ishlatish qulay emas. Buning o‘rniga uni ALT ga o‘zgartirish uchun ushbu o‘zgarishdan foydalanishingiz mumkin:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
