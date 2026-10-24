# لوحة المفاتيح والفأرة ولوحة اللمس

يتيح لك Hyprland ضبط جميع أجهزة الإدخال الخاصة بك بتفاصيل دقيقة. يمكنك تغيير تكرار لوحة المفاتيح ليكون سريعًا بشكل خارق، أو جعل لوحة اللمس تستخدم التمرير الطبيعي. تقوم بتغيير ذلك كله في `~/.config/hypr/input.lua`، الذي يمكنك الوصول إليه أيضًا عبر _الإعداد > Input_ في قائمة Omarchy (`Super + Space`). أي شيء تضبطه هناك يحل محل إعدادات Omarchy الافتراضية.

إليك مثال:

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

يمكنك [رؤية جميع خيارات الإدخال](https://wiki.hypr.land/Configuring/Basics/Variables/#input) على ويكي Hyprland للإدخال.

يعمل CapsLock بوصفه Caps Lock طبيعيًا، و`Shift + CapsLock` هو مفتاح التكوين (compose key) لـ[الإيموجي السريعة](07-hotkeys.md#quick-emojis) و[الإكمالات الأخرى](07-hotkeys.md#quick-completions). إذا كنت تفضّل أن يكون مفتاح التكوين في مكان آخر، فاستبدل `omarchy:shift_caps_compose` في `kb_options`. على سبيل المثال، هذا ينقل مفتاح التكوين إلى Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### إيماءات لوحة اللمس

يمكنك أيضًا تفعيل [إيماءات لوحة اللمس](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)، مثل السحب بثلاثة أصابع لتغيير مساحات العمل:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

على حواسيب Dell XPS المحمولة ذات لوحة اللمس الاهتزازية (haptic)، يمكنك أيضًا تعيين قوة النقر على منخفض أو متوسط أو مرتفع ضمن _تشغيل > Hardware > Touchpad Haptics_.

### الكتابة باللغات الصينية واليابانية ولغات أخرى

اختر اليابانية أو الكورية أو الصينية (المبسطة، Pinyin) أو الصينية (التقليدية، Zhuyin) عندما يطلب منك المثبّت اختيار لوحة المفاتيح. يقوم Omarchy بضبط لوحة المفاتيح ومحرك الإدخال المطابق تلقائيًا، بما في ذلك أثناء إعداد أول إقلاع دون اتصال. تستخدم اليابانية Mozc، وتستخدم الكورية مجموعة Hangul الثنائية القياسية، وتستخدم الصينية المبسطة Pinyin، وتستخدم الصينية التقليدية ترتيب Zhuyin القياسي في Chewing. وتوفر اليابانية (لوحة مفاتيح أمريكية) Mozc مع تخطيط لوحة مفاتيح أمريكي.

تبدأ الكتابة في الوضع اللاتيني. اضغط `Super + I` للتنقّل عبر طرق الإدخال المضبوطة، و`Super + Shift + I` للعودة إلى الوراء. اضغط `Shift` بمفرده للخروج من طريقة إدخال مثل Pinyin إلى الأحرف اللاتينية، واضغطه مرة أخرى للعودة، بنفس طريقة عمل Sogou وMicrosoft Pinyin وmacOS؛ ولا يزال `Shift` مع حرف يكتب حرفًا كبيرًا. على لوحات المفاتيح اليابانية، يقوم 全角/半角 بتبديل الإدخال، ويقوم 変換 بتشغيله، ويقوم 無変換 بإيقافه. أما على تخطيط لوحة مفاتيح كورية، فتقوم مفاتيح 한/영 و한자 المخصصة بتبديل Hangul والتحويل إلى Hanja. يبقى `Ctrl + Space` متاحًا لـ Tmux وHerdr؛ ويبقى `Shift + CapsLock` هو مفتاح التكوين.

يظهر مؤشر لوحة المفاتيح على يمين الشريط عندما يكون لديك تخطيطات لوحة مفاتيح أو طرق إدخال متعددة. انقر عليه لتبديل لغات الإدخال؛ تعرض اليابانية あ من أجل hiragana. بالنسبة لخيارات الأحرف اليابانية، انتقل إلى اليابانية، واكتب كلمة مثل `nihongo`، ثم اضغط Space مرتين. اضغط Enter لقبول اختيارك. إذا كان لديك أيضًا تخطيطات لوحة مفاتيح متعددة، فانقر بزر الفأرة الأيمن على المؤشر للتنقل بينها.

استخدم _الإعداد > Typing > Keyboard Layouts_ لاختيار التخطيطات مثل الإنجليزية والفرنسية، من الخيارات نفسها المقدمة أثناء التثبيت. واستخدم _الإعداد > Typing > Input Methods_ لاختيار محركات التكوين النشطة. يفتح كلا المنتقيين داخل قائمة Omarchy مع علامات اختيار على اختياراتك الحالية. انقر أو اضغط Enter لتبديل خيار؛ وتسري كل تغيير على الفور. إلغاء تحديد طريقة إدخال يزيلها من الدورة دون إلغاء تثبيتها؛ وتبقى لوحة المفاتيح متاحة.

شغّل `omarchy setup keyboard` أو `omarchy setup input` لفتح المنتقيين أنفسهما. لإضافة لغة واحدة من سطر الأوامر، استخدم `omarchy setup input mozc` أو `hangul` أو `pinyin` أو `chewing`. تُحفظ مفاتيح التبديل المخصصة الخاصة بك. بالنسبة لتخطيطات محرك بديلة أو مفاتيح، ثبّت `fcitx5-configtool` باستخدام `omarchy pkg add fcitx5-configtool` وشغّله من terminal. اختيار لغة إدخال لا يغير لغة سطح المكتب.

استخدم `Super + I` للتنقّل عبر طرق الإدخال أو تخطيطات لوحة المفاتيح، و`Super + Shift + I` للعودة في الاتجاه المعاكس، بحيث يمكنك مع ثلاثة مضبوطة التحرك بين جارَين. يظهر مؤشر الإدخال على يمين الشريط فقط عندما يتم ضبط أكثر من طريقة إدخال أو تخطيط واحد. يعمل هذا الربط على سطح المكتب جنبًا إلى جنب مع مفاتيح تبديل Fcitx الحالية الخاصة بك؛ ويمكنك تجاوزه في `~/.config/hypr/bindings.lua`. تستخدم محركات الإدخال وتسلسلات التكوين خدمة [Fcitx5](https://fcitx-im.org/) التي تعمل بالفعل في كل جلسة.

### استخدام ALT بوصفه SUPER

على بعض لوحات المفاتيح، ليس من الملائم استخدام مفتاح meta الأساسي (مفتاح Windows/cmd) بوصفه SUPER. يمكنك تغيير ذلك ليكون ALT بدلًا من ذلك باستخدام هذا التغيير:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
