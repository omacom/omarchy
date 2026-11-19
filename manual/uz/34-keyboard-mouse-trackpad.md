# Klaviatura, Sichqoncha, Trekpad

Hyprland barcha kiritish qurilmalaringizni juda batafsil sozlash imkonini beradi. Klaviatura takrorlanishini tovush tezligidan ham yuqori qilib qo‘yishingiz yoki trekpadda tabiiy aylantirishdan foydalanishingiz mumkin. Bularning barchasini `~/.config/hypr/input.lua` faylida o‘zgartirasiz, unga Omarchy menyusi (`Super + Space`) orqali _Setup > Input_ bo‘limidan ham kirishingiz mumkin. U yerda o‘rnatgan har qanday sozlamangiz Omarchy standart sozlamalarining o‘rnini bosadi.

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

Kiritish qurilmalari bo‘yicha Hyprland wiki sahifasida [barcha kiritish parametrlarini ko‘rishingiz](https://wiki.hypr.land/Configuring/Basics/Variables/#input) mumkin.

CapsLock odatdagi Caps Lock sifatida ishlaydi, `Shift + CapsLock` esa [tezkor emojilar](07-hotkeys.md#quick-emojis) va [boshqa to‘ldirishlar](07-hotkeys.md#quick-completions) uchun tuzish tugmasi hisoblanadi. Agar tuzish tugmasi boshqa joyda bo‘lishini istasangiz, `kb_options` ichidagi `omarchy:shift_caps_compose` ni almashtiring. Masalan, bu tuzish tugmasini Right Alt tugmasiga ko‘chiradi:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funksiya tugmalari

Noutbuk klaviaturasining yuqori qatori sukut bo‘yicha media tugmalarini (ovoz balandligi, yorqinlik va shu kabilar) yuboradi, `Fn` ni bosib tursangiz F1-F12 tugmalari ishlaydi; `Fn + Esc` uni yana bosmaguningizcha teskari holatda qulflaydi. Ko‘pgina klaviaturalar bu qulfni o‘zlari eslab qoladi. ASUS noutbuklari va Apple uslubidagi klaviaturalar uni Linux ga qoldiradi, Linux esa har yuklanishda ularni media tugmalari holatida ishga tushiradi. Ularning o‘rniga F1-F12 dan boshlanishini istasangiz, `omarchy device keyboard toprow fnkeys` buyrug‘ini ishga tushiring (ortga qaytish uchun `omarchy device keyboard toprow mediakeys`); ba’zi noutbuklarda u qayta yuklangandan keyin kuchga kiradi. Apple Silicon Mac lar o‘z sozlamasini saqlaydi.

### Trekpad jestlari

Ish stoli bo‘ylab harakatlanish uchun trekpadda suring:

| Jest | Harakat |
| --- | --- |
| Uch barmoq chapga / o‘ngga | Oldingi / keyingi ish maydoni, jumladan bo‘shlari ham |
| Uch barmoq yuqoriga | AI konsolini almashtirish |
| Uch barmoq pastga | Omarchy menyusini ochish |
| To‘rt barmoq chapga / o‘ngga | Faol oynani oldingi / keyingi ish maydoniga ko‘chirish |
| To‘rt barmoq pastga | To‘liq ekran rejimini almashtirish |

Birini o‘zgartirish uchun, o‘zingiznikini qo‘shishdan oldin uni `~/.config/hypr/input.lua` faylida bekor qiling va [sensor panel jesti](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) qo‘shing, chunki Hyprland bir xil barmoqlar soni va yo‘nalishdagi ikkita jestni qabul qilmaydi:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy jestlarining barchasini o‘chirish uchun, Omarchy standart sozlamalari yuklanishidan oldin, `~/.config/hypr/hyprland.lua` faylining yuqori qismiga yaqin joyda `omarchy_default_gestures = false` ni o‘rnating.

Haptik sensor panelga ega Dell XPS noutbuklarida _Trigger > Hardware > Touchpad Haptics_ bo‘limida bosish kuchini low, mid yoki high qilib o‘rnatishingiz ham mumkin.

### Xitoy, yapon va boshqa tillarda yozish

O‘rnatuvchi klaviaturangizni so‘raganda yapon, koreys, xitoy (soddalashtirilgan, Pinyin), Tayvan (Zhuyin) yoki Gonkong (Cangjie) ni tanlang. Omarchy klaviaturani va mos kiritish mexanizmini avtomatik sozlaydi, shu jumladan oflayn birinchi yuklashni sozlash paytida ham. Yapon tili Mozc dan foydalanadi, koreys tili standart ikki to‘plamli Hangul dan, soddalashtirilgan xitoy tili Pinyin dan, Tayvan Chewing ning standart Zhuyin joylashuvidan, Gonkong esa Gonkong belgi shakllari bilan Cangjie dan foydalanadi. Japanese (US keyboard) varianti Mozc ni AQSh klaviatura joylashuvi bilan beradi. Hangul, Zhuyin va Cangjie tugmalari, hatto lotin harflarini Dvorak, Colemak yoki AZERTY bilan yozsangiz ham, o‘zlarining standart o‘rinlarida qoladi. Agar bundan oldin Hangul yoki Chewing qo‘shgan bo‘lsangiz, uning tugmalarini o‘sha joyga ko‘chirish uchun _Setup > Keyboard > Input Methods_ bo‘limida uni tanlovdan chiqarib, qayta tanlang; Omarchy siz allaqachon yozib kelayotgan mexanizmni o‘z holicha qoldiradi.

Yozish lotin rejimidan boshlanadi. Sozlangan kiritish usullari orasida aylanib o‘tish uchun `Super + I` ni bosing, orqaga aylanib o‘tish uchun `Super + Shift + I` ni bosing. `Shift` ni alohida o‘zini bosish Pinyin kabi kiritish usulidan lotin harflariga chiqish imkonini beradi, qaytish uchun uni yana bosing — xuddi Sogou, Microsoft Pinyin va macOS dagi kabi; `Shift` bilan birga harf bosish hamon katta harf yozadi. Yapon klaviaturalarida 全角/半角 kiritishni almashtiradi, 変換 uni yoqadi va 無変換 uni o‘chiradi. Koreys tilida 한/영 Hangul ni almashtiradi va 한자 Hanja ga aylantiradi, klaviaturangizda alohida tugmalar bo‘ladimi yoki ko‘plab noutbuklardagi kabi ular uchun Right Alt va Right Ctrl yuboriladimi, bundan qat’i nazar, shuning uchun u yerda Right Alt va Right Ctrl oddiy modifikatorlar emas; o‘rniga diktovka Alt + Space bilan almashtiriladi. `Ctrl + Space` Tmux va Herdr uchun mavjud bo‘lib qoladi; `Shift + CapsLock` tuzish tugmasi bo‘lib qoladi.

Bir nechta klaviatura joylashuvi yoki kiritish usulingiz bo‘lganda, panelning o‘ng tomonida klaviatura indikatori paydo bo‘ladi. Kiritish tillarini almashtirish uchun uni bosing; yapon tili hiragana uchun あ ni ko‘rsatadi. Yapon belgilarini tanlash uchun yapon tiliga o‘ting, `nihongo` kabi so‘z yozing, keyin Space ni ikki marta bosing. Tanlovingizni qabul qilish uchun Enter ni bosing. Agar bir nechta klaviatura joylashuvingiz ham bo‘lsa, ular orasida aylanib o‘tish uchun indikatorni o‘ng tugma bilan bosing.

Ingliz va fransuz kabi joylashuvlarni, o‘rnatish paytida taklif qilingan o‘sha tanlovlardan tanlash uchun _Setup > Keyboard > Keyboard Inputs_ dan foydalaning. Qaysi tuzish mexanizmlari faol ekanini tanlash uchun _Setup > Keyboard > Input Methods_ dan foydalaning. Ikkala tanlovchi ham Omarchy menyusi ichida joriy tanlovlaringiz belgilangan holda ochiladi. Tanlovni almashtirish uchun bosing yoki Enter ni bosing; har bir o‘zgarish darhol qo‘llaniladi. Kiritish usulini tanlovdan chiqarish uni tizimdan o‘chirmasdan turib aylanish ro‘yxatidan olib tashlaydi; klaviatura mavjud bo‘lib qoladi.

Xuddi shu tanlovchilarni ochish uchun `omarchy setup keyboard` yoki `omarchy setup input` ni ishga tushiring. Buyruq satridan bitta til qo‘shish uchun `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` yoki `cangjie5` dan foydalaning. Quick, Boshiamy va Array Cangjie bilan bitta paketda keladi va Input Methods tanlovchisida paydo bo‘ladi. Maxsus almashtirish tugmalaringiz saqlanib qoladi. Muqobil mexanizm joylashuvlari yoki tugmalari uchun `fcitx5-configtool` ni `omarchy pkg add fcitx5-configtool` bilan o‘rnating va uni terminaldan ishga tushiring. Kiritish tilini tanlash ish stoli tilini o‘zgartirmaydi. _Setup > Language_ bo‘limida yapon, koreys yoki xitoy tilini tanlash, sizda hali hech biri bo‘lmasa, uning kiritish usulini qo‘shadi.

Kiritish usullari yoki klaviatura joylashuvlari orasida aylanib o‘tish uchun `Super + I` dan foydalaning, teskari yo‘nalishda qaytish uchun `Super + Shift + I` dan foydalaning, shunda uchtasi sozlangan bo‘lsa, ikki qo‘shni orasida harakatlana olasiz. Kiritish indikatori faqat bittadan ortiq kiritish usuli yoki joylashuv sozlangan bo‘lganda panelning o‘ng tomonida paydo bo‘ladi. Ushbu ish stoli bog‘lanishi mavjud Fcitx almashtirish tugmalaringiz bilan birga ishlaydi; uni `~/.config/hypr/bindings.lua` faylida o‘zingizniki bilan almashtirishingiz mumkin. Kiritish mexanizmlari va tuzish ketma-ketliklari har bir sessiyada allaqachon ishlayotgan [Fcitx5](https://fcitx-im.org/) xizmatidan foydalanadi.

### ALT ni SUPER sifatida ishlatish

Ba’zi klaviaturalarda asosiy meta tugmasini (Windows/cmd tugmasini) SUPER sifatida ishlatish qulay emas. Buning o‘rniga ALT ishlatilishi uchun uni ushbu o‘zgarish bilan almashtirishingiz mumkin:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
