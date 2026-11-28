# السمات

يأتي Omarchy مع ثلاث وعشرين سمة جميلة. يمكنك الاختيار بينها عبر _المظهر > السمة_ في قائمة Omarchy (`Super + Space`) أو الانتقال مباشرة إلى منتقي السمات باستخدام `Super + Ctrl + T`.

تُضفي كل سمة طابعها على سطح المكتب، والطرفية، وneovim، وشاشة النشاط (btop)، ومتصفحك (Chrome أو Chromium أو Edge أو Brave)، وواجهة Omarchy بأكملها: الشريط العلوي، والقائمة، والإشعارات، وOSD، وشاشة القفل. (بالنسبة إلى Obsidian، يجب عليك اختيار سمة Omarchy يدويًا عبر _المظهر > السمات_ داخل التطبيق).

تحتوي السمات على مجموعة من صور الخلفية التي يمكنك الاختيار بينها باستخدام `Super + Ctrl + W`.

يمكنك العثور على المزيد من السمات في [صفحة السمات الإضافية](https://omarchy.org/themes/) أو حتى [إنشاء سمتك الخاصة](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### أيقونات التطبيقات

تُرسم الأيقونات في مشغّل التطبيقات وشريط الإرساء بألوان سمتك، لذا تتغير معها. وهي تأتي من مجموعة أيقونات تختارها بشكل منفصل عن السمة ضمن _المظهر > الأيقونات_، من معاينات لكل مجموعة، بالطريقة نفسها التي تختار بها سمة:

- _Papercraft_ هي الافتراضية: كل ما يأتي مثبّتًا، مرسوم بأسلوب واحد. التطبيقات المعروفة بشعارها، مثل Chrome وHEY وYouTube، تحتفظ بشكلها وتكتسب ألوان السمة.
- _Arcade_ ترسم التطبيقات نفسها على هيئة فن البكسل بأسلوب 8-bit، كما تفعل وحدة ألعاب قديمة.
- _Original_ تُظهر كل تطبيق بالأيقونة التي أعطاه إياها صانعه.

يمكنك تثبيت مجموعة أيقونات صنعها شخص آخر عبر _تثبيت > النمط > الأيقونات_ (أو `omarchy icons install <git url>`)، وإزالتها مجددًا ضمن _إزالة > الأيقونات_. يجلب _تحديث > أيقونات إضافية_ أحدث إصدار من المجموعات التي ثبّتها.

لصنع مجموعتك الخاصة، ضع أيقوناتك في `~/.config/omarchy/icons/<name>/`، ملف واحد لكل تطبيق، مسمّى وفق سطر `Icon=` في ملف `.desktop` الخاص بالتطبيق. الملف الذي ينتهي بـ `.svg` يُعرض كما هو. والملف الذي ينتهي بـ `.svg.tpl` يُرسم بألوان السمة: اكتب `{{ icon_main }}` أو `{{ icon_mark }}` أو `{{ icon_paper }}` أو `{{ icon_body }}` أو `{{ icon_edge }}` أو `{{ icon_ink }}` أو `{{ icon_shadow }}` حيث يذهب اللون. المجموعة الافتراضية في `/usr/share/omarchy/icons/papercraft/` مكان جيد للبدء منه. أضف `preview.png` لعرض مجموعتك في المنتقي؛ وبدونه، يرسم Omarchy معاينة من أيقوناتك. لتغيير أيقونة واحدة من المجموعة الافتراضية، ضع نسختك في `~/.config/omarchy/icons/papercraft/`.

### الإقلاع وتسجيل الدخول

الشاشة التي تطلب كلمة مرور محرك الأقراص عند بدء تشغيل الكمبيوتر، وشاشة تسجيل الدخول، تتبعان السمة أيضًا. في كل مرة تبدّل فيها السمات، تلتقطان خلفيتها وألوان نصها وتمييزها ولونها الأحمر، لذا لا يوجد تصميم منفصل لإلغاء القفل لتختاره. على أجهزة Mac المزودة بـ Apple Silicon، تحتفظ شاشة كلمة مرور محرك الأقراص بالمظهر الافتراضي لـ Omarchy مهما كانت السمة.
