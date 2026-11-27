# لوحة المفاتيح والفأرة ولوحة اللمس

يتيح لك Hyprland ضبط جميع أجهزة الإدخال لديك بتفصيل كبير. يمكنك جعل تكرار لوحة المفاتيح بسرعة تفوق سرعة الصوت أو جعل لوحة اللمس تستخدم التمرير الطبيعي. تغيّر كل ذلك في `~/.config/hypr/input.lua`، ويمكنك أيضًا الوصول إليه عبر _Setup > Input_ في قائمة Omarchy (`Super + Space`). أي شيء تضبطه هناك يحل محل إعدادات Omarchy الافتراضية.

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

يمكنك [الاطلاع على جميع خيارات الإدخال](https://wiki.hypr.land/Configuring/Basics/Variables/#input) على ويكي Hyprland للإدخال.

يعمل CapsLock كمفتاح Caps Lock عادي، و`Shift + CapsLock` هو مفتاح الإنشاء لـ[الإيموجي السريعة](07-hotkeys.md#quick-emojis) و[الإكمالات الأخرى](07-hotkeys.md#quick-completions). إذا كنت تفضّل أن يكون مفتاح الإنشاء في مكان آخر، فاستبدل `omarchy:shift_caps_compose` في `kb_options`. على سبيل المثال، ينقل هذا مفتاح الإنشاء إلى Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### مفاتيح الوظائف

يرسل الصف العلوي في لوحة مفاتيح الحاسوب المحمول مفاتيح الوسائط (مستوى الصوت والسطوع وما إلى ذلك) افتراضيًا، والضغط مع الاستمرار على `Fn` يمنحك F1-F12؛ و`Fn + Esc` يقفل ذلك في الاتجاه المعاكس حتى تضغط عليه مرة أخرى. تتذكر معظم لوحات المفاتيح هذا القفل بنفسها. تترك حواسيب ASUS المحمولة ولوحات المفاتيح على طراز Apple ذلك لـ Linux، الذي يبدأ بها على مفاتيح الوسائط عند كل إقلاع. لكي تبدأ على F1-F12 بدلًا من ذلك، شغّل `omarchy device keyboard toprow fnkeys` (و`omarchy device keyboard toprow mediakeys` للعودة)؛ وفي بعض الحواسيب المحمولة يسري مفعوله بعد إعادة التشغيل. تحتفظ حواسيب Apple Silicon Macs بإعدادها الخاص.

### إيماءات لوحة اللمس

مرّر على لوحة اللمس للتنقل في سطح المكتب:

| الإيماءة | الإجراء |
| --- | --- |
| ثلاثة أصابع إلى اليسار / اليمين | مساحة العمل السابقة / التالية، بما في ذلك الفارغة منها |
| ثلاثة أصابع إلى الأعلى | تبديل وحدة تحكم AI |
| ثلاثة أصابع إلى الأسفل | فتح قائمة Omarchy |
| أربعة أصابع إلى اليسار / اليمين | نقل النافذة النشطة إلى مساحة العمل السابقة / التالية |
| أربعة أصابع إلى الأسفل | تبديل وضع ملء الشاشة |

لتغيير واحدة منها، ألغِ ضبطها في `~/.config/hypr/input.lua` قبل إضافة [إيماءة لوحة اللمس](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) الخاصة بك، لأن Hyprland لن يقبل إيماءتين بنفس الأصابع والاتجاه:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

لإيقاف جميع إيماءات Omarchy، اضبط `omarchy_default_gestures = false` بالقرب من أعلى `~/.config/hypr/hyprland.lua`، قبل تحميل إعدادات Omarchy الافتراضية.

في حواسيب Dell XPS المحمولة المزودة بلوحة لمس ذات استجابة لمسية، يمكنك أيضًا ضبط قوة النقر على low أو mid أو high ضمن _Trigger > Hardware > Touchpad Haptics_.

### الكتابة بالصينية واليابانية ولغات أخرى

اختر اليابانية أو الكورية أو الصينية (المبسطة، Pinyin) أو تايوان (Zhuyin) أو هونغ كونغ (Cangjie) عندما يطلب منك المثبّت اختيار لوحة المفاتيح. يضبط Omarchy لوحة المفاتيح ومحرك الإدخال المطابق تلقائيًا، بما في ذلك أثناء إعداد الإقلاع الأول دون اتصال. تستخدم اليابانية Mozc، وتستخدم الكورية Hangul القياسي ذا المجموعتين، وتستخدم الصينية المبسطة Pinyin، وتستخدم تايوان ترتيب Zhuyin القياسي من Chewing، وتستخدم هونغ كونغ Cangjie مع أشكال حروف هونغ كونغ. توفر اليابانية (لوحة مفاتيح US) Mozc مع تخطيط لوحة مفاتيح US. تبقى مفاتيح Hangul وZhuyin وCangjie في مواضعها القياسية حتى عندما تكتب الحروف اللاتينية باستخدام Dvorak أو Colemak أو AZERTY. إذا أضفت Hangul أو Chewing قبل هذا، فقم بإلغاء اختياره وإعادة اختياره ضمن _Setup > Keyboard > Input Methods_ لنقل مفاتيحه إلى هناك؛ يترك Omarchy المحرك الذي تكتب به بالفعل وشأنه.

تبدأ الكتابة في وضع Latin. اضغط `Super + I` للتنقل بين طرق الإدخال المهيأة، و`Super + Shift + I` للتنقل في الاتجاه المعاكس. اضغط `Shift` وحده للخروج من طريقة إدخال مثل Pinyin إلى الحروف اللاتينية، واضغطه مرة أخرى للعودة، بالطريقة التي تعمل بها Sogou وMicrosoft Pinyin وmacOS؛ و`Shift` مع حرف لا يزال يكتب حرفًا كبيرًا. في لوحات المفاتيح اليابانية، يبدّل 全角/半角 الإدخال، ويشغّله 変換، ويوقفه 無変換. مع الكورية، يبدّل 한/영 Hangul ويحوّل 한자 إلى Hanja، سواء كانت لوحة مفاتيحك تحتوي على مفاتيح مخصصة أو ترسل Right Alt وRight Ctrl لهما، كما تفعل العديد من الحواسيب المحمولة، لذا لا يعمل Right Alt وRight Ctrl كمعدّلات عادية هناك؛ يتبدّل الإملاء الصوتي بدلًا من ذلك باستخدام Alt + Space. يبقى `Ctrl + Space` متاحًا لـ Tmux وHerdr؛ ويبقى `Shift + CapsLock` مفتاح الإنشاء.

يظهر مؤشر لوحة المفاتيح على يمين الشريط عندما يكون لديك تخطيطات متعددة للوحة المفاتيح أو طرق إدخال متعددة. انقر عليه لتبديل لغات الإدخال؛ تعرض اليابانية あ لـ hiragana. لاختيارات الحروف اليابانية، بدّل إلى اليابانية، واكتب كلمة مثل `nihongo`، ثم اضغط Space مرتين. اضغط Enter لقبول اختيارك. إذا كان لديك أيضًا تخطيطات متعددة للوحة المفاتيح، فانقر بزر الفأرة الأيمن على المؤشر للتنقل بينها.

استخدم _Setup > Keyboard > Keyboard Inputs_ لاختيار تخطيطات مثل الإنجليزية والفرنسية، من نفس الخيارات المعروضة أثناء التثبيت. استخدم _Setup > Keyboard > Input Methods_ لاختيار محركات الإنشاء النشطة. يفتح كلا المنتقيين داخل قائمة Omarchy مع وضع علامة على اختياراتك الحالية. انقر أو اضغط Enter لتبديل اختيار؛ يسري كل تغيير فورًا. يؤدي إلغاء اختيار طريقة إدخال إلى إزالتها من الدورة دون إلغاء تثبيتها؛ تبقى لوحة المفاتيح متاحة.

شغّل `omarchy setup keyboard` أو `omarchy setup input` لفتح المنتقيين نفسيهما. لإضافة لغة واحدة من سطر الأوامر، استخدم `omarchy setup input mozc` أو `hangul` أو `pinyin` أو `chewing` أو `cangjie5`. تأتي Quick وBoshiamy وArray في نفس حزمة Cangjie وتظهر في منتقي Input Methods. تُحفظ مفاتيح التبديل المخصصة لديك. لتخطيطات أو مفاتيح بديلة للمحرك، ثبّت `fcitx5-configtool` باستخدام `omarchy pkg add fcitx5-configtool` وشغّله من طرفية. لا يؤدي اختيار لغة إدخال إلى تغيير لغة سطح المكتب. يؤدي اختيار اليابانية أو الكورية أو الصينية ضمن _Setup > Region > Language_ إلى إضافة طريقة الإدخال الخاصة بها عندما لا يكون لديك أي طريقة بعد.

استخدم `Super + I` للتنقل بين طرق الإدخال أو تخطيطات لوحة المفاتيح، و`Super + Shift + I` للعودة في الاتجاه الآخر، لذا مع ثلاث طرق مهيأة يمكنك التنقل بين جارين. يظهر مؤشر الإدخال على يمين الشريط فقط عندما تكون أكثر من طريقة إدخال أو تخطيط واحد مهيأة. يعمل ارتباط سطح المكتب هذا إلى جانب مفاتيح تبديل Fcitx الحالية لديك؛ يمكنك تجاوزه في `~/.config/hypr/bindings.lua`. تستخدم محركات الإدخال وتسلسلات الإنشاء خدمة [Fcitx5](https://fcitx-im.org/) التي تعمل بالفعل في كل جلسة.

### استخدام ALT كـ SUPER

في بعض لوحات المفاتيح، ليس من الملائم استخدام مفتاح meta الأساسي (مفتاح Windows/cmd) كـ SUPER. يمكنك تغيير ذلك ليكون ALT بدلًا منه باستخدام هذا التغيير:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
