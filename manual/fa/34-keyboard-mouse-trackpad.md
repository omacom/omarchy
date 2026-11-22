# صفحه‌کلید، ماوس، ترک‌پد

Hyprland به شما اجازه می‌دهد همه ورودی‌هایتان را با جزئیات کامل پیکربندی کنید. می‌توانید تکرار صفحه‌کلید را به‌طرز مافوق‌صوت سریع کنید یا ترک‌پد را وادار کنید از اسکرول طبیعی استفاده کند. همه این‌ها را در `~/.config/hypr/input.lua` تغییر می‌دهید، که از طریق _Setup > Input_ در منوی Omarchy (`Super + Space`) هم می‌توانید به آن برسید. هر چیزی که آنجا تنظیم کنید جایگزین پیش‌فرض‌های Omarchy می‌شود.

این هم یک نمونه:

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

می‌توانید [همه گزینه‌های ورودی را](https://wiki.hypr.land/Configuring/Basics/Variables/#input) در ویکی Hyprland برای ورودی‌ها ببینید.

CapsLock مثل یک Caps Lock معمولی کار می‌کند و `Shift + CapsLock` کلید compose برای [ایموجی‌های سریع](07-hotkeys.md#quick-emojis) و [تکمیل‌های دیگر](07-hotkeys.md#quick-completions) است. اگر ترجیح می‌دهید کلید compose جای دیگری باشد، `omarchy:shift_caps_compose` را در `kb_options` جایگزین کنید. برای مثال، این کار کلید compose را به Right Alt منتقل می‌کند:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### کلیدهای تابعی

ردیف بالای صفحه‌کلید لپ‌تاپ به‌طور پیش‌فرض کلیدهای رسانه‌ای (صدا، روشنایی و غیره) را ارسال می‌کند و نگه‌داشتن `Fn`، کلیدهای F1-F12 را می‌دهد؛ `Fn + Esc` این رفتار را برعکس قفل می‌کند تا وقتی دوباره آن را فشار دهید. بیشتر صفحه‌کلیدها خودشان آن قفل را به خاطر می‌سپارند. لپ‌تاپ‌های ASUS و صفحه‌کلیدهای به سبک Apple این کار را به Linux واگذار می‌کنند، که در هر بوت آن‌ها را روی کلیدهای رسانه‌ای شروع می‌کند. برای اینکه در عوض روی F1-F12 شروع شوند، `omarchy device keyboard toprow fnkeys` را اجرا کنید (و برای برگشتن `omarchy device keyboard toprow mediakeys` را)؛ در بعضی لپ‌تاپ‌ها بعد از یک راه‌اندازی مجدد اثر می‌کند. مک‌های Apple Silicon تنظیم خودشان را نگه می‌دارند.

### ژست‌های ترک‌پد

روی ترک‌پد بکشید تا در دسکتاپ جابه‌جا شوید:

| ژست | عمل |
| --- | --- |
| سه انگشت به چپ / راست | فضای کاری قبلی / بعدی، از جمله فضای‌های خالی |
| سه انگشت به بالا | باز و بسته کردن کنسول AI |
| سه انگشت به پایین | باز کردن منوی Omarchy |
| چهار انگشت به چپ / راست | انتقال پنجره فعال به فضای کاری قبلی / بعدی |
| چهار انگشت به پایین | باز و بسته کردن تمام‌صفحه |

برای تغییر یکی از آن‌ها، قبل از اضافه کردن [ژست ترک‌پد](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) خودتان، آن را در `~/.config/hypr/input.lua` غیرفعال کنید، چون Hyprland دو ژست روی همان انگشت‌ها و همان جهت را قبول نمی‌کند:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

برای خاموش کردن همه ژست‌های Omarchy، `omarchy_default_gestures = false` را نزدیک بالای `~/.config/hypr/hyprland.lua`، قبل از بارگذاری پیش‌فرض‌های Omarchy، تنظیم کنید.

در لپ‌تاپ‌های Dell XPS با تاچ‌پد لمسی، می‌توانید قدرت کلیک را هم روی low، mid یا high زیر _Trigger > Hardware > Touchpad Haptics_ تنظیم کنید.

### تایپ به چینی، ژاپنی و زبان‌های دیگر

وقتی نصب‌کننده صفحه‌کلیدتان را می‌پرسد، Japanese، Korean، Chinese (Simplified, Pinyin)، Taiwan (Zhuyin) یا Hong Kong (Cangjie) را انتخاب کنید. Omarchy صفحه‌کلید و موتور ورودی متناسب را به‌طور خودکار پیکربندی می‌کند، از جمله در حین راه‌اندازی آفلاین اولین بوت. Japanese از Mozc استفاده می‌کند، Korean از Hangul استاندارد دو-مجموعه‌ای استفاده می‌کند، Simplified Chinese از Pinyin استفاده می‌کند، Taiwan از چیدمان استاندارد Zhuyin مربوط به Chewing استفاده می‌کند و Hong Kong از Cangjie با شکل‌های نویسه Hong Kong استفاده می‌کند. Japanese (US keyboard) Mozc را با چیدمان صفحه‌کلید US ارائه می‌دهد. کلیدهای Hangul، Zhuyin و Cangjie حتی وقتی حروف Latin را با Dvorak، Colemak یا AZERTY تایپ می‌کنید در موقعیت‌های استانداردشان می‌مانند. اگر قبل از این Hangul یا Chewing را اضافه کرده‌اید، آن را زیر _Setup > Keyboard > Input Methods_ از انتخاب خارج و دوباره انتخاب کنید تا کلیدهایش به آنجا منتقل شوند؛ Omarchy موتوری را که همین حالا با آن تایپ می‌کنید به حال خودش می‌گذارد.

تایپ در حالت Latin شروع می‌شود. `Super + I` را فشار دهید تا بین روش‌های ورودی پیکربندی‌شده بچرخید و `Super + Shift + I` را فشار دهید تا برعکس بچرخید. `Shift` را به‌تنهایی بزنید تا از یک روش ورودی مثل Pinyin بیرون بیایید و به حروف Latin بروید و دوباره آن را بزنید تا برگردید، همان‌طور که Sogou، Microsoft Pinyin و macOS کار می‌کنند؛ `Shift` به‌همراه یک حرف همچنان یک حرف بزرگ تایپ می‌کند. در صفحه‌کلیدهای ژاپنی، 全角/半角 ورودی را باز و بسته می‌کند، 変換 آن را روشن می‌کند و 無変換 آن را خاموش می‌کند. در Korean، 한/영 بین Hangul جابه‌جا می‌شود و 한자 به Hanja تبدیل می‌کند، چه صفحه‌کلیدتان کلیدهای اختصاصی داشته باشد چه برای آن‌ها Right Alt و Right Ctrl ارسال کند، همان‌طور که بسیاری از لپ‌تاپ‌ها این کار را می‌کنند، پس Right Alt و Right Ctrl در آنجا اصلاح‌گرهای ساده نیستند؛ دیکته در عوض با Alt + Space باز و بسته می‌شود. `Ctrl + Space` برای Tmux و Herdr در دسترس می‌ماند؛ `Shift + CapsLock` همچنان کلید compose می‌ماند.

نشانگر صفحه‌کلید وقتی چند چیدمان صفحه‌کلید یا روش ورودی دارید در سمت راست نوار ظاهر می‌شود. روی آن کلیک کنید تا زبان‌های ورودی را عوض کنید؛ Japanese برای hiragana، あ را نمایش می‌دهد. برای انتخاب نویسه‌های ژاپنی، به Japanese بروید، کلمه‌ای مثل `nihongo` تایپ کنید، سپس Space را دو بار فشار دهید. Enter را فشار دهید تا انتخابتان را بپذیرید. اگر چند چیدمان صفحه‌کلید هم دارید، روی نشانگر راست‌کلیک کنید تا بین آن‌ها بچرخید.

از _Setup > Keyboard > Keyboard Inputs_ استفاده کنید تا چیدمان‌هایی مثل English و French را از همان انتخاب‌هایی که هنگام نصب ارائه می‌شوند انتخاب کنید. از _Setup > Keyboard > Input Methods_ استفاده کنید تا انتخاب کنید کدام موتورهای ترکیب فعال باشند. هر دو انتخاب‌گر داخل منوی Omarchy باز می‌شوند و انتخاب‌های فعلی‌تان تیک خورده‌اند. کلیک کنید یا Enter را فشار دهید تا یک انتخاب را باز و بسته کنید؛ هر تغییر بلافاصله اعمال می‌شود. از انتخاب خارج کردن یک روش ورودی آن را بدون حذف نصب از چرخه حذف می‌کند؛ صفحه‌کلید در دسترس می‌ماند.

`omarchy setup keyboard` یا `omarchy setup input` را اجرا کنید تا همان انتخاب‌گرها باز شوند. برای اضافه کردن یک زبان از خط فرمان، از `omarchy setup input mozc`، `hangul`، `pinyin`، `chewing` یا `cangjie5` استفاده کنید. Quick، Boshiamy و Array در همان بسته Cangjie می‌آیند و در انتخاب‌گر Input Methods ظاهر می‌شوند. کلیدهای تعویض سفارشی شما حفظ می‌شوند. برای چیدمان‌ها یا کلیدهای جایگزین موتور، `fcitx5-configtool` را با `omarchy pkg add fcitx5-configtool` نصب کنید و آن را از یک ترمینال اجرا کنید. انتخاب یک زبان ورودی زبان دسکتاپ را تغییر نمی‌دهد. انتخاب Japanese، Korean یا Chinese زیر _Setup > Region > Language_ وقتی هنوز هیچ‌کدام را ندارید روش ورودی آن را اضافه می‌کند.

از `Super + I` استفاده کنید تا بین روش‌های ورودی یا چیدمان‌های صفحه‌کلید بچرخید و از `Super + Shift + I` استفاده کنید تا از راه دیگر برگردید، پس با سه مورد پیکربندی‌شده می‌توانید بین دو همسایه جابه‌جا شوید. نشانگر ورودی فقط وقتی بیش از یک روش ورودی یا چیدمان پیکربندی شده باشد در سمت راست نوار ظاهر می‌شود. این اتصال دسکتاپ در کنار کلیدهای تعویض موجود Fcitx شما کار می‌کند؛ می‌توانید آن را در `~/.config/hypr/bindings.lua` بازنویسی کنید. موتورهای ورودی و دنباله‌های compose از سرویس [Fcitx5](https://fcitx-im.org/) استفاده می‌کنند که از قبل در هر جلسه در حال اجراست.

### استفاده از ALT به‌عنوان SUPER

در بعضی صفحه‌کلیدها، استفاده از کلید متای اصلی (کلید Windows/cmd) به‌عنوان SUPER راحت نیست. می‌توانید با این تغییر، آن را در عوض ALT کنید:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
