# لوحة المفاتيح والفأرة ولوحة اللمس

يتيح لك Hyprland تكوين جميع وسائل الإدخال لديك بتفصيل كبير. يمكنك جعل تكرار لوحة المفاتيح سريعًا بشكل خيالي أو جعل لوحة اللمس تستخدم التمرير الطبيعي. تغيّر كل هذا في `~/.config/hypr/input.lua`، والذي يمكنك الوصول إليه أيضًا عبر _Setup > Input_ في قائمة Omarchy (`Super + Space`). أي شيء تضبطه هناك يحل محل إعدادات Omarchy الافتراضية.

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

يمكنك [الاطلاع على جميع خيارات الإدخال](https://wiki.hypr.land/Configuring/Basics/Variables/#input) على ويكي Hyprland الخاصة بالإدخال.

يعمل CapsLock كمفتاح Caps Lock عادي، و`Shift + CapsLock` هو مفتاح الإنشاء لـ[الإيموجي السريعة](07-hotkeys.md#quick-emojis) و[الإكمالات الأخرى](07-hotkeys.md#quick-completions). إذا كنت تفضل وضع مفتاح الإنشاء في مكان آخر، فاستبدل `omarchy:shift_caps_compose` في `kb_options`. على سبيل المثال، ينقل هذا مفتاح الإنشاء إلى Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### إيماءات لوحة اللمس

مرّر على لوحة اللمس للتنقل في سطح المكتب:

| الإيماءة | الإجراء |
| --- | --- |
| ثلاث أصابع إلى اليسار / اليمين | مساحة العمل السابقة / التالية، بما في ذلك الفارغة منها |
| ثلاث أصابع إلى الأعلى | تبديل وحدة تحكم الذكاء الاصطناعي |
| ثلاث أصابع إلى الأسفل | فتح قائمة Omarchy |
| أربع أصابع إلى اليسار / اليمين | نقل النافذة النشطة إلى مساحة العمل السابقة / التالية |
| أربع أصابع إلى الأسفل | تبديل ملء الشاشة |

لتغيير إحداها، ألغِ ضبطها في `~/.config/hypr/input.lua` قبل إضافة [إيماءة لوحة اللمس](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) الخاصة بك، لأن Hyprland لن يقبل إيماءتين بنفس الأصابع والاتجاه:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

لإيقاف جميع إيماءات Omarchy، اضبط `omarchy_default_gestures = false` قرب أعلى `~/.config/hypr/hyprland.lua`، قبل تحميل إعدادات Omarchy الافتراضية.

على حواسيب Dell XPS المحمولة المزودة بلوحة لمس لمسية، يمكنك أيضًا ضبط قوة النقر إلى منخفضة أو متوسطة أو عالية ضمن _Trigger > Hardware > Touchpad Haptics_.

### الكتابة بالصينية واليابانية ولغات أخرى

اختر اليابانية أو الكورية أو الصينية (المبسطة، Pinyin) أو تايوان (Zhuyin) أو هونغ كونغ (Cangjie) عندما يسألك المثبّت عن لوحة المفاتيح. يهيّئ Omarchy لوحة المفاتيح ومحرك الإدخال المطابق تلقائيًا، بما في ذلك أثناء إعداد الإقلاع الأول دون اتصال. تستخدم اليابانية Mozc، وتستخدم الكورية Hangul القياسي بصفّين، وتستخدم الصينية المبسطة Pinyin، وتستخدم تايوان ترتيب Zhuyin القياسي في Chewing، وتستخدم هونغ كونغ Cangjie بأشكال أحرف هونغ كونغ. توفر اليابانية (لوحة مفاتيح US) Mozc مع تخطيط لوحة مفاتيح US. تبقى مفاتيح Hangul وZhuyin وCangjie في مواضعها القياسية حتى عندما تكتب أحرفًا لاتينية باستخدام Dvorak أو Colemak أو AZERTY. إذا كنت قد أضفت Hangul أو Chewing قبل هذا، فألغِ تحديده ثم أعد تحديده ضمن _Setup > Typing > Input Methods_ لنقل مفاتيحه إلى هناك؛ يترك Omarchy أي محرك تكتب به بالفعل وشأنه.

تبدأ الكتابة في الوضع اللاتيني. اضغط `Super + I` للتنقّل عبر طرق الإدخال المهيّأة، و`Super + Shift + I` للتنقّل في الاتجاه المعاكس. انقر `Shift` لوحده للخروج من طريقة إدخال مثل Pinyin إلى الأحرف اللاتينية، وانقره مرة أخرى للعودة، بنفس طريقة عمل Sogou وMicrosoft Pinyin وmacOS؛ لا يزال `Shift` مع حرف يكتب حرفًا كبيرًا. على لوحات المفاتيح اليابانية، يبدّل 全角/半角 الإدخال، ويشغّله 変換، ويوقف تشغيله 無変換. مع الكورية، يبدّل 한/영 Hangul ويحوّل 한자 إلى Hanja، سواء كانت لوحة مفاتيحك تحتوي على مفاتيح مخصصة أو ترسل Right Alt وRight Ctrl لها، كما تفعل العديد من الحواسيب المحمولة، لذا فإن Right Alt وRight Ctrl ليسا معدّلين عاديين هناك؛ يبقى الضغط والتحدث للإملاء على F9. يبقى `Ctrl + Space` متاحًا لـ Tmux وHerdr؛ يبقى `Shift + CapsLock` مفتاح الإنشاء.

يظهر مؤشر لوحة المفاتيح على يمين الشريط عندما يكون لديك تخطيطات متعددة للوحة المفاتيح أو طرق إدخال. انقر عليه لتبديل لغات الإدخال؛ تعرض اليابانية あ لـ hiragana. لاختيارات الأحرف اليابانية، بدّل إلى اليابانية، واكتب كلمة مثل `nihongo`، ثم اضغط Space مرتين. اضغط Enter لقبول اختيارك. إذا كان لديك أيضًا تخطيطات متعددة للوحة المفاتيح، فانقر بزر الفأرة الأيمن على المؤشر للتنقّل عبرها.

استخدم _Setup > Typing > Keyboard Layouts_ لتحديد تخطيطات مثل الإنجليزية والفرنسية، من نفس الخيارات المعروضة أثناء التثبيت. استخدم _Setup > Typing > Input Methods_ لتحديد محركات التركيب النشطة. يفتح كلا المنتقيَين داخل قائمة Omarchy مع وضع علامة على اختياراتك الحالية. انقر أو اضغط Enter لتبديل اختيار؛ يُطبّق كل تغيير فورًا. إلغاء تحديد طريقة إدخال يزيلها من الدورة دون إلغاء تثبيتها؛ تبقى لوحة المفاتيح متاحة.

شغّل `omarchy setup keyboard` أو `omarchy setup input` لفتح نفس المنتقيَين. لإضافة لغة واحدة من سطر الأوامر، استخدم `omarchy setup input mozc` أو `hangul` أو `pinyin` أو `chewing` أو `cangjie5`. تأتي Quick وBoshiamy وArray في نفس الحزمة مثل Cangjie وتظهر في منتقي Input Methods. تُحفظ مفاتيح التبديل المخصصة الخاصة بك. لتخطيطات أو مفاتيح محرك بديلة، ثبّت `fcitx5-configtool` باستخدام `omarchy pkg add fcitx5-configtool` وشغّله من طرفية. تحديد لغة إدخال لا يغيّر لغة سطح المكتب. اختيار اليابانية أو الكورية أو الصينية ضمن _Setup > Language_ يضيف طريقة الإدخال الخاصة بها عندما لا يكون لديك أي منها بعد.

استخدم `Super + I` للتنقّل عبر طرق الإدخال أو تخطيطات لوحة المفاتيح، و`Super + Shift + I` للعودة في الاتجاه الآخر، لذا مع ثلاث طرق مهيّأة يمكنك التنقل بين جارين. يظهر مؤشر الإدخال على يمين الشريط فقط عندما يكون هناك أكثر من طريقة إدخال أو تخطيط واحد مهيّأ. يعمل ربط سطح المكتب هذا بجانب مفاتيح تبديل Fcitx الحالية لديك؛ يمكنك تجاوزه في `~/.config/hypr/bindings.lua`. تستخدم محركات الإدخال وتسلسلات الإنشاء خدمة [Fcitx5](https://fcitx-im.org/) التي تعمل بالفعل في كل جلسة.

### استخدام ALT كـ SUPER

على بعض لوحات المفاتيح، ليس من المناسب استخدام مفتاح meta الأساسي (مفتاح Windows/cmd) كـ SUPER. يمكنك تغيير هذا ليكون ALT بدلاً من ذلك باستخدام هذا التغيير:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
