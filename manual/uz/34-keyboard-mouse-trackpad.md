# Klaviatura, sichqoncha, trekpad

Hyprland barcha kiritish qurilmalaringizni juda batafsil sozlash imkonini beradi. Klaviatura takrorlanishini tovush tezligidan ham tezroq qilishingiz yoki trekpadni tabiiy aylantirishdan foydalanadigan qilishingiz mumkin. Hammasini `~/.config/hypr/input.lua` faylida o'zgartirasiz, unga Omarchy menyusi (`Super + Space`) orqali _Setup > Input_ yo'li bilan ham kirishingiz mumkin. U yerda o'rnatgan har qanday narsa Omarchy standart sozlamalari o'rnini bosadi.

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

Kirishlarga oid [barcha kiritish parametrlarini](https://wiki.hypr.land/Configuring/Basics/Variables/#input) Hyprland wiki sahifasida ko'rishingiz mumkin.

CapsLock oddiy Caps Lock sifatida ishlaydi, `Shift + CapsLock` esa [tezkor emojilar](07-hotkeys.md#quick-emojis) va [boshqa to'ldirishlar](07-hotkeys.md#quick-completions) uchun tuzish tugmasi hisoblanadi. Agar tuzish tugmasi boshqa joyda bo'lishini ma'qul ko'rsangiz, `kb_options` ichidagi `omarchy:shift_caps_compose` ni almashtiring. Masalan, quyidagisi tuzish tugmasini Right Alt ga ko'chiradi:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funksiya tugmalari

Noutbuk klaviaturasining yuqori qatori sukut bo'yicha media tugmalarini (ovoz, yorqinlik va boshqalar) yuboradi, `Fn` ni ushlab turish F1-F12 ni beradi; `Fn + Esc` uni yana bosguningizcha teskari holatda qulflaydi. Ko'pchilik klaviaturalar o'sha qulfni o'zlari eslab qoladi. ASUS noutbuklari va Apple uslubidagi klaviaturalar buni Linux ga qoldiradi, u esa har bir yuklanishda ularni media tugmalaridan boshlaydi. Ular o'rniga F1-F12 dan boshlanishi uchun `omarchy keyboard toprow fnkeys` buyrug'ini ishga tushiring (orqaga qaytish uchun `omarchy keyboard toprow mediakeys`); ba'zi noutbuklarda bu qayta yuklashdan keyin kuchga kiradi. Apple Silicon Mac lar o'z sozlamasini saqlaydi.

### Trekpad imo-ishoralari

Ish stolida harakatlanish uchun trekpadda suring:

| Imo-ishora | Amal |
| --- | --- |
| Uch barmoq chapga / o'ngga | Oldingi / keyingi ish maydoni, bo'shlarini ham qo'shib |
| Uch barmoq yuqoriga | AI konsolini yoqish/o'chirish |
| Uch barmoq pastga | Omarchy menyusini ochish |
| To'rt barmoq chapga / o'ngga | Faol oynani oldingi / keyingi ish maydoniga ko'chirish |
| To'rt barmoq pastga | To'liq ekranni yoqish/o'chirish |

Birini o'zgartirish uchun, o'zingizning [trekpad imo-ishorangizni](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) qo'shishdan oldin uni `~/.config/hypr/input.lua` faylida bekor qiling, chunki Hyprland bir xil barmoqlar va bir xil yo'nalishga ikkita imo-ishorani qabul qilmaydi:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy ning barcha imo-ishoralarini o'chirish uchun, Omarchy standart sozlamalari yuklanishidan oldin, `~/.config/hypr/hyprland.lua` faylining yuqori qismiga yaqin joyda `omarchy_default_gestures = false` ni o'rnating.

Haptik sensorli panelli Dell XPS noutbuklarida, _Trigger > Hardware > Touchpad Haptics_ bo'limida bosish kuchini low, mid yoki high qilib ham o'rnatishingiz mumkin.

### Xitoy, yapon va boshqa tillarda yozish

O'rnatuvchi klaviaturangizni so'raganda Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) yoki Hong Kong (Cangjie) ni tanlang. Omarchy klaviaturani va mos kiritish mexanizmini avtomatik sozlaydi, shu jumladan oflayn birinchi yuklashda sozlash paytida ham. Japanese Mozc dan foydalanadi, Korean standart ikki to'plamli Hangul dan foydalanadi, Simplified Chinese Pinyin dan foydalanadi, Taiwan Chewing ning standart Zhuyin tartibidan foydalanadi, Hong Kong esa Hong Kong belgilar shakllari bilan Cangjie dan foydalanadi. Japanese (US keyboard) US klaviatura tartibi bilan Mozc ni taqdim etadi. Hangul, Zhuyin va Cangjie tugmalari, lotin harflarini Dvorak, Colemak yoki AZERTY bilan yozsangiz ham, standart o'rinlarida qoladi. Agar Hangul yoki Chewing ni bundan oldin qo'shgan bo'lsangiz, uning tugmalarini o'sha yerga ko'chirish uchun _Setup > Keyboard > Input Methods_ bo'limida uni tanlovdan chiqarib, qayta tanlang; Omarchy siz allaqachon yozayotgan mexanizmni o'zgartirmaydi.

Yozish lotin rejimida boshlanadi. Sozlangan kiritish usullari orasida aylanish uchun `Super + I` ni bosing, orqaga aylanish uchun esa `Super + Shift + I` ni bosing. Pinyin kabi kiritish usulidan lotin harflariga chiqish uchun `Shift` ni o'zini bosing, orqaga qaytish uchun uni yana bosing — Sogou, Microsoft Pinyin va macOS ishlaganidek; `Shift` va harf hali ham bosh harf yozadi. Yapon klaviaturalarida 全角/半角 kiritishni yoqib-o'chiradi, 変換 uni yoqadi, 無変換 esa uni o'chiradi. Korean bilan 한/영 Hangul ni almashtiradi va 한자 Hanja ga o'giradi, klaviaturangizda alohida tugmalar bo'ladimi yoki ko'p noutbuklar qilganidek ular uchun Right Alt va Right Ctrl yuboradimi, baribir, shuning uchun Right Alt va Right Ctrl u yerda oddiy modifikatorlar emas; ovoz bilan kiritish o'rniga Alt + Space bilan yoqib-o'chiriladi. `Ctrl + Space` Tmux va Herdr uchun mavjud bo'lib qoladi; `Shift + CapsLock` tuzish tugmasi bo'lib qoladi.

Bir nechta klaviatura tartibingiz yoki kiritish usulingiz bo'lganda, panelning o'ng tomonida klaviatura ko'rsatkichi paydo bo'ladi. Kiritish tillarini almashtirish uchun uni bosing; Japanese hiragana uchun あ ni ko'rsatadi. Yapon belgilarini tanlash uchun Japanese ga o'ting, `nihongo` kabi so'z yozing, keyin Space ni ikki marta bosing. Tanlovingizni qabul qilish uchun Enter ni bosing. Agar sizda bir nechta klaviatura tartibi ham bo'lsa, o'sha tartiblar orasida aylanish uchun ko'rsatkichni o'ng tugma bilan bosing.

English va French kabi tartiblarni tanlash uchun _Setup > Keyboard > Keyboard Inputs_ dan foydalaning, o'rnatish paytida taklif qilingan o'sha tanlovlar orasidan. Qaysi tuzish mexanizmlari faol bo'lishini tanlash uchun _Setup > Keyboard > Input Methods_ dan foydalaning. Ikkala tanlovchi ham Omarchy menyusi ichida ochiladi, joriy tanlovlaringiz belgilangan holda. Tanlovni yoqib-o'chirish uchun bosing yoki Enter ni bosing; har bir o'zgarish darhol qo'llaniladi. Kiritish usulini tanlovdan chiqarish uni o'chirmasdan aylanishdan olib tashlaydi; klaviatura mavjud bo'lib qoladi.

O'sha tanlovchilarni ochish uchun `omarchy setup keyboard` yoki `omarchy setup input` ni ishga tushiring. Buyruq satridan bitta til qo'shish uchun `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` yoki `cangjie5` dan foydalaning. Quick, Boshiamy va Array Cangjie bilan bir xil paketda keladi va Input Methods tanlovchisida paydo bo'ladi. Sizning maxsus almashtirish tugmalaringiz saqlanadi. Muqobil mexanizm tartiblari yoki tugmalari uchun `omarchy pkg add fcitx5-configtool` bilan `fcitx5-configtool` ni o'rnating va uni terminaldan ishga tushiring. Kiritish tilini tanlash ish stoli tilini o'zgartirmaydi. _Setup > Language_ bo'limida Japanese, Korean yoki Chinese ni tanlash, hali hech biri bo'lmaganda, uning kiritish usulini qo'shadi.

Kiritish usullari yoki klaviatura tartiblari orasida aylanish uchun `Super + I` dan foydalaning, boshqa yo'nalishda orqaga borish uchun esa `Super + Shift + I` dan foydalaning, shunda uchtasi sozlangan bo'lsa, ikki qo'shni orasida harakatlana olasiz. Kiritish ko'rsatkichi faqat bittadan ortiq kiritish usuli yoki tartibi sozlangan bo'lganda panelning o'ng tomonida paydo bo'ladi. Bu ish stoli bog'lanishi mavjud Fcitx almashtirish tugmalaringiz bilan birga ishlaydi; uni `~/.config/hypr/bindings.lua` faylida bekor qilishingiz mumkin. Kiritish mexanizmlari va tuzish ketma-ketliklari har bir sessiyada allaqachon ishlayotgan [Fcitx5](https://fcitx-im.org/) xizmatidan foydalanadi.

### ALT ni SUPER sifatida ishlatish

Ba'zi klaviaturalarda asosiy meta tugmani (Windows/cmd tugmasi) SUPER sifatida ishlatish qulay emas. Buni ushbu o'zgarish yordamida o'rniga ALT bo'ladigan qilib o'zgartirishingiz mumkin:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
