# السمات

يأتي Omarchy مع اثنتين وعشرين سمة جميلة. يمكنك الاختيار بينها عبر _المظهر > السمة_ في قائمة Omarchy (`Super + Space`) أو الانتقال مباشرة إلى منتقي السمات باستخدام `Super + Ctrl + T`.

تُنسّق كل سمة سطح المكتب والطرفية وneovim وشاشة النشاط (btop) وChromium وواجهة Omarchy بالكامل: الشريط العلوي والقائمة والإشعارات وOSD وشاشة القفل. (بالنسبة إلى Obsidian، يجب عليك اختيار سمة Omarchy يدويًا عبر _المظهر > السمات_ داخل التطبيق).

تحتوي السمات على مجموعة من صور الخلفية يمكنك الاختيار بينها باستخدام `Super + Ctrl + W`.

يمكنك العثور على مزيد من السمات على [صفحة السمات الإضافية](https://omarchy.org/themes/) أو حتى [صنع سمتك الخاصة](43-making-your-own-theme.md).

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

### أيقونات التطبيقات

تُرسم الأيقونات في مشغّل التطبيقات والرصيف بألوان سمتك، لذا تتغير معها. وهي تأتي من مجموعة أيقونات تختارها بشكل منفصل عن السمة ضمن _المظهر > الأيقونات_، من معاينات لكل مجموعة، بالطريقة نفسها التي تختار بها سمة:

- _Papercraft_ هي الافتراضية: كل ما يأتي مثبّتًا، مرسوم بأسلوب واحد. التطبيقات المعروفة بشعارها، مثل Chrome وHEY وYouTube، تحتفظ بشكلها وتكتسب ألوان السمة.
- _Arcade_ ترسم التطبيقات نفسها كفن بكسل 8-bit، كما كانت ستفعل وحدة تحكّم ألعاب قديمة.
- _Original_ تعرض كل تطبيق بالأيقونة التي منحه إياها صانعه.

يمكنك تثبيت مجموعة أيقونات صنعها شخص آخر عبر _تثبيت > النمط > الأيقونات_ (أو `omarchy icons install <git url>`)، وإزالتها مجددًا ضمن _إزالة > الأيقونات_. يجلب _تحديث > أيقونات إضافية_ أحدث إصدار من المجموعات التي ثبّتها.

لصنع مجموعتك الخاصة، ضع أيقوناتك في `~/.config/omarchy/icons/<name>/`، ملفًا واحدًا لكل تطبيق، مسمّى تسمية سطر `Icon=` في ملف `.desktop` الخاص بالتطبيق. يُعرض الملف الذي ينتهي بـ `.svg` كما هو. أما الملف الذي ينتهي بـ `.svg.tpl` فيُرسم بألوان السمة: اكتب `{{ icon_main }}` أو `{{ icon_mark }}` أو `{{ icon_paper }}` أو `{{ icon_body }}` أو `{{ icon_edge }}` أو `{{ icon_ink }}` أو `{{ icon_shadow }}` حيث يوضع لون. المجموعة الافتراضية في `/usr/share/omarchy/icons/papercraft/` مكان جيد لتبدأ منه. أضف `preview.png` لعرض مجموعتك في المنتقي؛ وبدونه، يرسم Omarchy معاينة من أيقوناتك. لتغيير أيقونة واحدة من المجموعة الافتراضية، ضع نسختك في `~/.config/omarchy/icons/papercraft/`.

### تصاميم إلغاء القفل

يمكن أن تحتوي السمات أيضًا على تصميم مخصص لإلغاء القفل، يُستخدم في عملية فك تشفير الإقلاع. يمكنك اختيار أحدها ضمن _المظهر > إلغاء القفل_. وهي تبدو هكذا:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
