# صفحه‌کلید، ماوس، تاچ‌پد

Hyprland به شما اجازه می‌دهد همه ورودی‌های خود را با جزئیات بسیار پیکربندی کنید. می‌توانید تکرار صفحه‌کلید را به‌صورت فوق‌صوت سریع تغییر دهید یا تاچ‌پد را وادار به استفاده از پیمایش طبیعی کنید. همه آن را در `~/.config/hypr/input.lua` تغییر می‌دهید، که همچنین می‌توانید از طریق _تنظیمات > Input_ در منوی Omarchy (`Super + Space`) به آن برسید. هر چیزی که آنجا تنظیم کنید پیش‌فرض‌های Omarchy را جایگزین می‌کند.

در اینجا یک مثال آمده است:

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

می‌توانید [همه گزینه‌های ورودی را ببینید](https://wiki.hypr.land/Configuring/Basics/Variables/#input) در ویکی Hyprland برای ورودی‌ها.

CapsLock به‌صورت یک Caps Lock عادی کار می‌کند، و `Shift + CapsLock` کلید compose برای [ایموجی‌های سریع](07-hotkeys.md#quick-emojis) و [تکمیل‌های دیگر](07-hotkeys.md#quick-completions) است. اگر ترجیح می‌دهید کلید compose جای دیگری باشد، `omarchy:shift_caps_compose` را در `kb_options` جایگزین کنید. مثلاً، این کلید compose را به Right Alt منتقل می‌کند:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ژست‌های تاچ‌پد

همچنین می‌توانید [ژست‌های تاچ‌پد](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) را روشن کنید، مانند کشیدن با سه انگشت برای تغییر فضاهای کاری:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

روی لپ‌تاپ‌های Dell XPS با یک تاچ‌پد لمسی، همچنین می‌توانید قدرت کلیک را روی کم، متوسط یا زیاد زیر _اجرا > Hardware > Touchpad Haptics_ تنظیم کنید.

### تایپ به چینی، ژاپنی و زبان‌های دیگر

وقتی نصاب صفحه‌کلید شما را می‌پرسد، ژاپنی، کره‌ای، چینی (ساده‌شده، Pinyin)، یا چینی (سنتی، Zhuyin) را انتخاب کنید. Omarchy صفحه‌کلید و موتور ورودی مطابق را به‌طور خودکار پیکربندی می‌کند، از جمله در طول راه‌اندازی آفلاین اولین بوت. ژاپنی از Mozc استفاده می‌کند، کره‌ای از Hangul دو مجموعه استاندارد استفاده می‌کند، چینی ساده‌شده از Pinyin استفاده می‌کند، و چینی سنتی از چیدمان استاندارد Zhuyin Chewing استفاده می‌کند. ژاپنی (صفحه‌کلید US) Mozc را با یک چیدمان صفحه‌کلید US ارائه می‌دهد.

تایپ در حالت لاتین شروع می‌شود. `Super + I` را بزنید تا در روش‌های ورودی پیکربندی‌شده بچرخید، و `Super + Shift + I` را بزنید تا برگردید. `Shift` را به‌تنهایی بزنید تا از یک روش ورودی مانند Pinyin به حروف لاتین بیرون بروید، و دوباره آن را بزنید تا برگردید، به روشی که Sogou، Microsoft Pinyin و macOS کار می‌کنند؛ `Shift` به‌علاوه یک حرف هنوز یک حرف بزرگ تایپ می‌کند. روی صفحه‌کلیدهای ژاپنی، 全角/半角 ورودی را تغییر می‌دهد، 変換 آن را روشن می‌کند، و 無変換 آن را خاموش می‌کند. روی یک چیدمان صفحه‌کلید کره‌ای، کلیدهای اختصاصی 한/영 و 한자 Hangul را جابه‌جا می‌کنند و به Hanja تبدیل می‌کنند. `Ctrl + Space` برای Tmux و Herdr در دسترس می‌ماند؛ `Shift + CapsLock` کلید compose می‌ماند.

نشانگر صفحه‌کلید در سمت راست نوار ظاهر می‌شود وقتی چند چیدمان صفحه‌کلید یا روش ورودی دارید. روی آن کلیک کنید تا زبان‌های ورودی را جابه‌جا کنید؛ ژاپنی برای هیراگانا あ را نمایش می‌دهد. برای انتخاب حروف ژاپنی، به ژاپنی جابه‌جا شوید، کلمه‌ای مانند `nihongo` تایپ کنید، آنگاه دوبار Space را بزنید. Enter را بزنید تا انتخاب خود را بپذیرید. اگر همچنین چند چیدمان صفحه‌کلید دارید، روی نشانگر راست‌کلیک کنید تا در آن‌ها بچرخید.

از _تنظیمات > Typing > Keyboard Layouts_ برای انتخاب چیدمان‌هایی مانند انگلیسی و فرانسوی، از همان انتخاب‌هایی که در طول نصب ارائه شدند، استفاده کنید. از _تنظیمات > Typing > Input Methods_ برای انتخاب اینکه کدام موتورهای ترکیب فعال هستند استفاده کنید. هر دو انتخاب‌گر داخل منوی Omarchy با انتخاب‌های فعلی شما علامت‌خورده باز می‌شوند. کلیک کنید یا Enter را بزنید تا یک انتخاب را تغییر دهید؛ هر تغییر بلافاصله اعمال می‌شود. لغو انتخاب یک روش ورودی آن را از چرخه حذف می‌کند بدون حذف نصب آن؛ صفحه‌کلید در دسترس می‌ماند.

`omarchy setup keyboard` یا `omarchy setup input` را اجرا کنید تا همان انتخاب‌گرها را باز کنید. برای افزودن یک زبان از خط فرمان، از `omarchy setup input mozc`، `hangul`، `pinyin`، یا `chewing` استفاده کنید. کلیدهای جابه‌جایی سفارشی شما حفظ می‌شوند. برای چیدمان‌ها یا کلیدهای موتور جایگزین، `fcitx5-configtool` را با `omarchy pkg add fcitx5-configtool` نصب کنید و آن را از یک ترمینال اجرا کنید. انتخاب یک زبان ورودی زبان دسکتاپ را تغییر نمی‌دهد.

از `Super + I` برای چرخیدن در روش‌های ورودی یا چیدمان‌های صفحه‌کلید استفاده کنید، و `Super + Shift + I` برای رفتن به راه دیگر، پس با سه پیکربندی‌شده می‌توانید بین دو همسایه حرکت کنید. نشانگر ورودی در سمت راست نوار فقط وقتی ظاهر می‌شود که بیش از یک روش ورودی یا چیدمان پیکربندی شده باشد. این میانبر دسکتاپ در کنار کلیدهای جابه‌جایی Fcitx موجود شما کار می‌کند؛ می‌توانید آن را در `~/.config/hypr/bindings.lua` بازنویسی کنید. موتورهای ورودی و دنباله‌های compose از خدمت [Fcitx5](https://fcitx-im.org/) که از قبل در هر نشست در حال اجرا است استفاده می‌کنند.

### استفاده از ALT به‌عنوان SUPER

روی برخی صفحه‌کلیدها، استفاده از کلید متای اصلی (کلید Windows/cmd) به‌عنوان SUPER راحت نیست. می‌توانید این را به ALT تغییر دهید به جای آن با استفاده از این تغییر:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
