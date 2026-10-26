# لوحة المفاتيح والفأرة ولوحة اللمس

يتيح لك Hyprland ضبط جميع أجهزة الإدخال لديك بتفصيل كبير. يمكنك جعل تكرار لوحة المفاتيح سريعًا بسرعة تفوق الصوت أو جعل لوحة اللمس تستخدم التمرير الطبيعي. تغيّر كل ذلك في `~/.config/hypr/input.lua`، والذي يمكنك الوصول إليه أيضًا عبر _Setup > Input_ في قائمة Omarchy (`Super + Space`). أي شيء تضبطه هناك يحل محل إعدادات Omarchy الافتراضية.

إليك مثالًا:

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

يمكنك [اطّلاع جميع خيارات الإدخال](https://wiki.hypr.land/Configuring/Basics/Variables/#input) على ويكي Hyprland الخاص بالإدخال.

يعمل CapsLock كمفتاح Caps Lock عادي، و`Shift + CapsLock` هو مفتاح الإنشاء (compose) لـ[الرموز التعبيرية السريعة](07-hotkeys.md#quick-emojis) و[الإكمالات السريعة الأخرى](07-hotkeys.md#quick-completions). إذا كنت تفضّل أن يكون مفتاح الإنشاء في مكان آخر، فاستبدل `omarchy:shift_caps_compose` في `kb_options`. على سبيل المثال، ينقل هذا مفتاح الإنشاء إلى Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### إيماءات لوحة اللمس

يمكنك أيضًا تفعيل [إيماءات لوحة اللمس](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)، مثل التمرير بثلاثة أصابع لتغيير مساحات العمل:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

على أجهزة Dell XPS المحمولة المزوّدة بلوحة لمس لمسية (haptic)، يمكنك أيضًا ضبط قوة النقر على منخفضة أو متوسطة أو عالية ضمن _Trigger > Hardware > Touchpad Haptics_.

### الكتابة بالصينية واليابانية ولغات أخرى

اختر اليابانية أو الكورية أو الصينية (المبسطة، Pinyin) أو تايوان (Zhuyin) أو هونغ كونغ (Cangjie) عندما يسألك المثبّت عن لوحة المفاتيح. يضبط Omarchy لوحة المفاتيح ومحرك الإدخال المطابق تلقائيًا، بما في ذلك أثناء إعداد أول إقلاع دون اتصال. تستخدم اليابانية Mozc، وتستخدم الكورية Hangul القياسي ذا المجموعتين، وتستخدم الصينية المبسطة Pinyin، وتستخدم تايوان ترتيب Zhuyin القياسي من Chewing، وتستخدم هونغ كونغ Cangjie بأشكال أحرف هونغ كونغ. توفّر اليابانية (لوحة مفاتيح US) Mozc مع تخطيط لوحة مفاتيح US. تبقى مفاتيح Hangul وZhuyin وCangjie في مواضعها القياسية حتى عندما تكتب أحرفًا لاتينية باستخدام Dvorak أو Colemak أو AZERTY. إذا كنت قد أضفت Hangul أو Chewing قبل هذا، فألغِ تحديده ثم أعد تحديده ضمن _Setup > Typing > Input Methods_ لنقل مفاتيحه إلى هناك؛ يترك Omarchy أي محرك تكتب به بالفعل وشأنه.

تبدأ الكتابة في الوضع اللاتيني. اضغط `Super + I` للتنقل عبر طرق الإدخال المضبوطة، و`Super + Shift + I` للتنقل بالعكس. انقر `Shift` وحده للخروج من طريقة إدخال مثل Pinyin إلى الأحرف اللاتينية، وانقره مرة أخرى للعودة، بالطريقة نفسها التي يعمل بها Sogou وMicrosoft Pinyin وmacOS؛ ما زال `Shift` مع حرف يكتب حرفًا كبيرًا. على لوحات المفاتيح اليابانية، يبدّل 全角/半角 الإدخال، ويشغّله 変換، ويوقفه 無変換. مع الكورية، يبدّل 한/영 Hangul ويحوّل 한자 إلى Hanja، سواء كانت لوحة مفاتيحك تحتوي على مفاتيح مخصصة أو ترسل Right Alt وRight Ctrl لها، كما تفعل العديد من الأجهزة المحمولة، لذا فإن Right Alt وRight Ctrl ليسا معدّلين عاديين هناك؛ يبقى الضغط للتحدث للإملاء على F9. يبقى `Ctrl + Space` متاحًا لـ Tmux وHerdr؛ ويبقى `Shift + CapsLock` مفتاح الإنشاء.

يظهر مؤشر لوحة المفاتيح على يمين الشريط عندما يكون لديك تخطيطات لوحة مفاتيح أو طرق إدخال متعددة. انقره لتبديل لغات الإدخال؛ تعرض اليابانية あ للهيراغانا. لاختيارات الأحرف اليابانية، بدّل إلى اليابانية، واكتب كلمة مثل `nihongo`، ثم اضغط Space مرتين. اضغط Enter لقبول اختيارك. إذا كان لديك أيضًا تخطيطات لوحة مفاتيح متعددة، فانقر بزر الفأرة الأيمن على المؤشر للتنقل عبرها.

استخدم _Setup > Typing > Keyboard Layouts_ لتحديد تخطيطات مثل الإنجليزية والفرنسية، من الخيارات نفسها المقدّمة أثناء التثبيت. استخدم _Setup > Typing > Input Methods_ لتحديد محركات التركيب النشطة. يفتح كلا المنتقيين داخل قائمة Omarchy مع وضع علامة على اختياراتك الحالية. انقر أو اضغط Enter لتبديل اختيار؛ يُطبّق كل تغيير فورًا. إلغاء تحديد طريقة إدخال يزيلها من الدورة دون إلغاء تثبيتها؛ تبقى لوحة المفاتيح متاحة.

شغّل `omarchy setup keyboard` أو `omarchy setup input` لفتح المنتقيين أنفسهما. لإضافة لغة واحدة من سطر الأوامر، استخدم `omarchy setup input mozc` أو `hangul` أو `pinyin` أو `chewing` أو `cangjie5`. تأتي Quick وBoshiamy وArray في الحزمة نفسها مع Cangjie وتظهر في منتقي Input Methods. تُحفظ مفاتيح التبديل المخصصة لديك. لتخطيطات أو مفاتيح بديلة للمحركات، ثبّت `fcitx5-configtool` باستخدام `omarchy pkg add fcitx5-configtool` وشغّله من طرفية. تحديد لغة إدخال لا يغيّر لغة سطح المكتب. اختيار اليابانية أو الكورية أو الصينية ضمن _Setup > Language_ يضيف طريقة إدخالها عندما لا يكون لديك أي طريقة بعد.

استخدم `Super + I` للتنقل عبر طرق الإدخال أو تخطيطات لوحة المفاتيح، و`Super + Shift + I` للعودة بالاتجاه الآخر، فمع ضبط ثلاث منها يمكنك الانتقال بين جارين. يظهر مؤشر الإدخال على يمين الشريط فقط عندما يكون هناك أكثر من طريقة إدخال أو تخطيط واحد مضبوط. يعمل ربط سطح المكتب هذا إلى جانب مفاتيح تبديل Fcitx الحالية لديك؛ يمكنك تجاوزه في `~/.config/hypr/bindings.lua`. تستخدم محركات الإدخال وتسلسلات الإنشاء خدمة [Fcitx5](https://fcitx-im.org/) التي تعمل بالفعل في كل جلسة.

### استخدام ALT بدلًا من SUPER

على بعض لوحات المفاتيح، ليس من الملائم استخدام مفتاح meta الأساسي (مفتاح Windows/cmd) باعتباره SUPER. يمكنك تغيير هذا ليكون ALT بدلًا منه باستخدام هذا التغيير:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
