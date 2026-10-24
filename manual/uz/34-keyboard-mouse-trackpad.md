# Klaviatura, sichqoncha, sensor panel

Hyprland barcha kiritishlaringizni katta tafsilot bilan sozlash imkonini beradi. Klaviatura takrorini tovushdan yuqori tezlikda qilishingiz yoki sensor panel tabiiy aylantirishdan foydalanishi mumkin. Hammasini `~/.config/hypr/input.lua` da oʻzgartirasiz, unga Omarchy menyusidagi (`Super + Space`) _Sozlash > Input_ orqali ham yetishingiz mumkin. U yerda belgilagan har qanday narsa Omarchy standartlarini almashtiradi.

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

Kiritishlar uchun Hyprland wikida [barcha kiritish variantlarini koʻrishingiz](https://wiki.hypr.land/Configuring/Basics/Variables/#input) mumkin.

CapsLock oddiy Caps Lock sifatida ishlaydi va `Shift + CapsLock` [tezkor emojilar](07-hotkeys.md#quick-emojis) va [boshqa toʻldirishlar](07-hotkeys.md#quick-completions) uchun compose tugmasidir. Agar compose tugmasi boshqa joyda boʻlishini afzal koʻrsangiz, `kb_options` dagi `omarchy:shift_caps_compose` ni almashtiring. Masalan, bu compose tugmasini Right Alt ga koʻchiradi:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Sensor panel imo-ishoralari

Ish maydonlarini oʻzgartirish uchun uch barmoq bilan surish kabi [sensor panel imo-ishoralari](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) ni ham yoqishingiz mumkin:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Haptik sensor panelga ega Dell XPS noutbuklarida, _Ishga tushirish > Hardware > Touchpad Haptics_ ostida bosish kuchini low, mid yoki high ga ham belgilashingiz mumkin.

### Xitoy, yapon va boshqa tillarda yozish

Oʻrnatuvchi klaviaturangizni soʻraganda Japanese, Korean, Chinese (Simplified, Pinyin) yoki Chinese (Traditional, Zhuyin) ni tanlang. Omarchy klaviatura va mos kiritish dvigatelini avtomatik sozlaydi, jumladan oflayn birinchi yuklash sozlashi davomida. Yapon tili Mozc dan, koreys tili standart ikki toʻplamli Hangul dan, soddalashtirilgan xitoy tili Pinyin dan va anʼanaviy xitoy tili Chewing ning standart Zhuyin tartibidan foydalanadi. Japanese (US keyboard) US klaviatura tartibi bilan Mozc ni taʼminlaydi.

Yozish lotin rejimida boshlanadi. Sozlangan kiritish usullari boʻylab aylanish uchun `Super + I` ni va orqaga aylanish uchun `Super + Shift + I` ni bosing. Pinyin kabi kiritish usulidan lotin harflariga chiqish uchun `Shift` ni oʻzini bosing va orqaga borish uchun yana bosing, Sogou, Microsoft Pinyin va macOS ishlaganidek; `Shift` plyus harf baribir katta harf yozadi. Yapon klaviaturalarida 全角/半角 kiritishni almashtiradi, 変換 uni yoqadi va 無変換 uni oʻchiradi. Koreys klaviatura tartibida maxsus 한/영 va 한자 tugmalari Hangul ni almashtiradi va Hanja ga aylantiradi. `Ctrl + Space` Tmux va Herdr uchun mavjud boʻlib qoladi; `Shift + CapsLock` compose tugmasi boʻlib qoladi.

Klaviatura koʻrsatkichi bir nechta klaviatura tartiblari yoki kiritish usullaringiz boʻlganda panelning oʻng tomonida paydo boʻladi. Kiritish tillarini almashtirish uchun uni bosing; yapon tili hiragana uchun あ ni koʻrsatadi. Yapon belgilarini tanlash uchun yapon tiliga oʻting, `nihongo` kabi soʻzni yozing, keyin Space ni ikki marta bosing. Tanlovingizni qabul qilish uchun Enter ni bosing. Agar sizda bir nechta klaviatura tartiblari ham boʻlsa, ularni aylanish uchun koʻrsatkichni oʻng tugma bilan bosing.

Oʻrnatish davomida taklif etilgan bir xil tanlovlardan English va French kabi tartiblarni tanlash uchun _Sozlash > Typing > Keyboard Layouts_ dan foydalaning. Qaysi kompozitsiya dvigatellari faol ekanligini tanlash uchun _Sozlash > Typing > Input Methods_ dan foydalaning. Ikkala tanlagich ham Omarchy menyusida joriy tanlovlaringiz belgilangan holda ochiladi. Tanlovni almashtirish uchun bosing yoki Enter ni bosing; har bir oʻzgarish darhol qoʻllanadi. Kiritish usulini bekor qilish uni oʻrnatishdan olib tashlamasdan sikldan chiqaradi; klaviatura mavjud boʻlib qoladi.

Bir xil tanlagichlarni ochish uchun `omarchy setup keyboard` yoki `omarchy setup input` ni ishga tushiring. Buyruq qatoridan bitta til qoʻshish uchun `omarchy setup input mozc`, `hangul`, `pinyin` yoki `chewing` dan foydalaning. Maxsus almashtirish tugmalaringiz saqlanadi. Muqobil dvigatel tartiblari yoki tugmalari uchun `fcitx5-configtool` ni `omarchy pkg add fcitx5-configtool` bilan oʻrnating va uni terminaldan ishga tushiring. Kiritish tilini tanlash ish stoli tilini oʻzgartirmaydi.

Kiritish usullari yoki klaviatura tartiblari boʻylab aylanish uchun `Super + I` dan va boshqa yoʻnalishda borish uchun `Super + Shift + I` dan foydalaning, shunday qilib uchta sozlangan boʻlsa ikki qoʻshni orasida harakat qilishingiz mumkin. Kiritish koʻrsatkichi faqat bittadan koʻp kiritish usuli yoki tartib sozlangan boʻlganda panelning oʻng tomonida paydo boʻladi. Bu ish stoli bogʻlanishi mavjud Fcitx almashtirish tugmalaringiz bilan birga ishlaydi; uni `~/.config/hypr/bindings.lua` da ustiga yozishingiz mumkin. Kiritish dvigatellari va compose ketma-ketliklari har bir sessiyada allaqachon ishlayotgan [Fcitx5](https://fcitx-im.org/) xizmatidan foydalanadi.

### ALT ni SUPER sifatida ishlatish

Baʼzi klaviaturalarda asosiy meta tugmasini (Windows/cmd tugmasi) SUPER sifatida ishlatish qulay emas. Bu oʻzgarish yordamida buni uning oʻrniga ALT qilib oʻzgartirishingiz mumkin:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
