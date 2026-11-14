# لوحة المفاتيح والفأرة ولوحة اللمس

يتيح لك Hyprland ضبط جميع أجهزة الإدخال لديك بتفصيل كبير. يمكنك جعل تكرار لوحة المفاتيح سريعًا بسرعة تفوق سرعة الصوت أو جعل لوحة اللمس تستخدم التمرير الطبيعي. تغيّر كل ذلك في `~/.config/hypr/input.lua`، والذي يمكنك الوصول إليه أيضًا عبر _Setup > Input_ في قائمة Omarchy (`Super + Space`). أي شيء تضبطه هناك يحل محل إعدادات Omarchy الافتراضية.

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

يعمل CapsLock كمفتاح Caps Lock عادي، ويكون `Shift + CapsLock` هو مفتاح Compose لـ[الرموز التعبيرية السريعة](07-hotkeys.md#quick-emojis) و[الإكمالات الأخرى](07-hotkeys.md#quick-completions). إذا كنت تفضّل أن يكون مفتاح Compose في موضع آخر، فاستبدل `omarchy:shift_caps_compose` في `kb_options`. على سبيل المثال، ينقل هذا مفتاح Compose إلى Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### مفاتيح الوظائف

يرسل الصف العلوي من لوحة مفاتيح الحاسوب المحمول مفاتيح الوسائط (مستوى الصوت والسطوع وما إلى ذلك) افتراضيًا، ويمنحك الضغط مع الاستمرار على `Fn` المفاتيح F1-F12؛ ويقفل `Fn + Esc` ذلك في الاتجاه المعاكس حتى تضغطه مرة أخرى. تتذكر معظم لوحات المفاتيح ذلك القفل بنفسها. تترك حواسيب ASUS المحمولة ولوحات المفاتيح على طراز Apple ذلك لـLinux، الذي يبدأ بها على مفاتيح الوسائط عند كل إقلاع. لجعلها تبدأ على F1-F12 بدلًا من ذلك، شغّل `omarchy keyboard toprow fnkeys` (و`omarchy keyboard toprow mediakeys` للعودة)؛ وفي بعض الحواسيب المحمولة يسري مفعوله بعد إعادة التشغيل. تحتفظ أجهزة Apple Silicon Macs بإعدادها الخاص.

### إيماءات لوحة اللمس

اسحب على لوحة اللمس للتنقل في سطح المكتب:

| الإيماءة | الإجراء |
| --- | --- |
| ثلاثة أصابع إلى اليسار / اليمين | مساحة العمل السابقة / التالية، بما في ذلك الفارغة منها |
| ثلاثة أصابع إلى الأعلى | تبديل وحدة تحكم الذكاء الاصطناعي |
| ثلاثة أصابع إلى الأسفل | فتح قائمة Omarchy |
| أربعة أصابع إلى اليسار / اليمين | نقل النافذة النشطة إلى مساحة العمل السابقة / التالية |
| أربعة أصابع إلى الأسفل | تبديل ملء الشاشة |

لتغيير إحداها، ألغِ ضبطها في `~/.config/hypr/input.lua` قبل إضافة [إيماءة لوحة اللمس](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) الخاصة بك، لأن Hyprland لن يقبل إيماءتين على الأصابع والاتجاه نفسهما:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

لإيقاف جميع إيماءات Omarchy، اضبط `omarchy_default_gestures = false` قرب أعلى `~/.config/hypr/hyprland.lua`، قبل تحميل إعدادات Omarchy الافتراضية.

في حواسيب Dell XPS المحمولة المزودة بلوحة لمس لمسية، يمكنك أيضًا ضبط قوة النقر على low أو mid أو high ضمن _Trigger > Hardware > Touchpad Haptics_.

### الكتابة بالصينية واليابانية ولغات أخرى

اختر اليابانية أو الكورية أو الصينية (المبسطة، Pinyin) أو تايوان (Zhuyin) أو هونغ كونغ (Cangjie) عندما يسألك المثبّت عن لوحة المفاتيح لديك. يضبط Omarchy لوحة المفاتيح ومحرك الإدخال المطابق تلقائيًا، بما في ذلك أثناء إعداد الإقلاع الأول دون اتصال. تستخدم اليابانية Mozc، وتستخدم الكورية Hangul القياسي ذا المجموعتين، وتستخدم الصينية المبسطة Pinyin، وتستخدم تايوان ترتيب Zhuyin القياسي من Chewing، وتستخدم هونغ كونغ Cangjie مع أشكال أحرف هونغ كونغ. توفر اليابانية (لوحة مفاتيح US) Mozc مع تخطيط لوحة مفاتيح US. تبقى مفاتيح Hangul وZhuyin وCangjie في مواضعها القياسية حتى عندما تكتب أحرفًا لاتينية باستخدام Dvorak أو Colemak أو AZERTY. إذا كنت قد أضفت Hangul أو Chewing قبل هذا، فألغِ تحديده ثم أعد تحديده ضمن _Setup > Keyboard > Input Methods_ لنقل مفاتيحه إلى هناك؛ يترك Omarchy المحرك الذي تكتب به بالفعل وشأنه.

تبدأ الكتابة في الوضع اللاتيني. اضغط `Super + I` للتنقل بين طرق الإدخال المضبوطة، و`Super + Shift + I` للتنقل في الاتجاه المعاكس. انقر `Shift` بمفرده للخروج من طريقة إدخال مثل Pinyin إلى الأحرف اللاتينية، وانقره مرة أخرى للعودة، على طريقة عمل Sogou وMicrosoft Pinyin وmacOS؛ ولا يزال `Shift` مع حرف يكتب حرفًا كبيرًا. في لوحات المفاتيح اليابانية، يبدّل 全角/半角 الإدخال، ويشغّله 変換، ويوقف تشغيله 無変換. مع الكورية، يبدّل 한/영 Hangul ويحوّل 한자 إلى Hanja، سواء أكانت لوحة المفاتيح لديك تحتوي على مفاتيح مخصصة أو ترسل Right Alt وRight Ctrl لهما، كما تفعل العديد من الحواسيب المحمولة، لذا لا يكون Right Alt وRight Ctrl مفتاحَي تعديل عاديين هناك؛ يتبدّل الإملاء باستخدام Alt + Space بدلًا من ذلك. يبقى `Ctrl + Space` متاحًا لـTmux وHerdr؛ ويبقى `Shift + CapsLock` مفتاح Compose.

يظهر مؤشر لوحة المفاتيح على يمين الشريط عندما يكون لديك تخطيطات متعددة للوحة المفاتيح أو طرق إدخال متعددة. انقره لتبديل لغات الإدخال؛ تعرض اليابانية あ لـhiragana. لخيارات الأحرف اليابانية، بدّل إلى اليابانية، واكتب كلمة مثل `nihongo`، ثم اضغط Space مرتين. اضغط Enter لقبول اختيارك. إذا كان لديك أيضًا تخطيطات متعددة للوحة المفاتيح، فانقر بزر الفأرة الأيمن على المؤشر للتنقل بينها.

استخدم _Setup > Keyboard > Keyboard Inputs_ لتحديد تخطيطات مثل English وFrench، من الخيارات نفسها المعروضة أثناء التثبيت. واستخدم _Setup > Keyboard > Input Methods_ لتحديد محركات التأليف النشطة. يفتح كلا المنتقيين داخل قائمة Omarchy مع وضع علامة على اختياراتك الحالية. انقر أو اضغط Enter لتبديل اختيار؛ يسري كل تغيير فورًا. تؤدي إزالة تحديد طريقة إدخال إلى إزالتها من الدورة دون إلغاء تثبيتها؛ وتبقى لوحة المفاتيح متاحة.

شغّل `omarchy setup keyboard` أو `omarchy setup input` لفتح المنتقيين نفسيهما. لإلحاق لغة واحدة من سطر الأوامر، استخدم `omarchy setup input mozc` أو `hangul` أو `pinyin` أو `chewing` أو `cangjie5`. تأتي Quick وBoshiamy وArray في الحزمة نفسها مع Cangjie وتظهر في منتقي Input Methods. تُحفظ مفاتيح التبديل المخصصة لديك. لتخطيطات أو مفاتيح محرك بديلة، ثبّت `fcitx5-configtool` باستخدام `omarchy pkg add fcitx5-configtool` وشغّله من طرفية. لا يؤدي تحديد لغة إدخال إلى تغيير لغة سطح المكتب. يؤدي اختيار اليابانية أو الكورية أو الصينية ضمن _Setup > Language_ إلى إضافة طريقة الإدخال الخاصة بها عندما لا يكون لديك أي منها بعد.

استخدم `Super + I` للتنقل بين طرق الإدخال أو تخطيطات لوحة المفاتيح، و`Super + Shift + I` للعودة في الاتجاه الآخر، لذا مع ضبط ثلاثة يمكنك التنقل بين جارين. يظهر مؤشر الإدخال على يمين الشريط فقط عندما يكون مضبوطًا أكثر من طريقة إدخال أو تخطيط واحد. يعمل رابط سطح المكتب هذا جنبًا إلى جنب مع مفاتيح تبديل Fcitx الحالية لديك؛ ويمكنك تجاوزه في `~/.config/hypr/bindings.lua`. تستخدم محركات الإدخال وتسلسلات Compose خدمة [Fcitx5](https://fcitx-im.org/) قيد التشغيل بالفعل في كل جلسة.

### استخدام ALT بدلًا من SUPER

في بعض لوحات المفاتيح، ليس من الملائم استخدام مفتاح meta الرئيسي (مفتاح Windows/cmd) باعتباره SUPER. يمكنك تغيير هذا ليكون ALT بدلًا من ذلك باستخدام هذا التغيير:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
