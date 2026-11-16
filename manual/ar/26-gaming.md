# الألعاب

لا يقتصر Omarchy على _الإنتاجية_ فحسب، بل هو للمتعة أيضًا، وما الذي يمكن أن يكون أكثر متعة من الألعاب؟ يأتي Omarchy مع مجموعة كاملة من خيارات الألعاب — Steam وRetroArch للعب الأصلي والكلاسيكي، وBattle.net وLutris وHeroic للمتاجر غير التابعة لـ Steam، وMoonlight لبث ألعاب PC، وXbox Cloud Gaming + NVIDIA GeForce NOW للألعاب السحابية، بالإضافة إلى Minecraft الخالدة.

بفضل العمل المذهل الذي قامت به Valve على [طبقة توافق Proton](https://en.wikipedia.org/wiki/Proton_(software))، أصبح هناك الآن عشرات الآلاف من الألعاب الحديثة القابلة للعب على Linux. أوه، وهل كنت تعلم أن [Steam Deck](https://store.steampowered.com/steamdeck/) يعمل فعليًا بنظام Arch!

توجد جميع مثبّتات الألعاب ضمن _تثبيت > الألعاب_ في قائمة Omarchy (`Super + Space`). وإذا أردت التراجع عن أي منها في أي وقت، فاستخدم _إزالة > الألعاب_.

## Steam

ثبّت [Steam](https://store.steampowered.com/) عن طريق اختيار _تثبيت > الألعاب > Steam_ من قائمة Omarchy (`Super + Space`).

بعد تثبيته، ستتمكن من تشغيل Steam باستخدام `Super + Space`.

لاحظ أن Steam قد يستغرق من 10 إلى 20 ثانية ليبدأ، ولن يقدّم أي مؤشر مرئي على أنه قيد التحميل.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

ثبّت [RetroArch](https://www.retroarch.com/) عن طريق اختيار _تثبيت > الألعاب > RetroArch_ من قائمة Omarchy (`Super + Space`). يأتي مع المجموعة الكاملة من أنوية libretro، لذا فجميع الأنظمة الكلاسيكية مشمولة.

يأتي RetroArch مهيّأً بالكامل مسبقًا مع تظليل CRT Royale الجميل للحصول على ذلك المظهر الكلاسيكي المثالي.

للبدء:

1. ضع ملفات BIOS الخاصة بك في `~/Games/bios` وملفات ROM الخاصة بك في `~/Games/roms`.
2. شغّل RetroArch باستخدام `Super + Space` وكتابة `retro`.
3. امسح دليل `~/Games/roms` وستكون جاهزًا للعب.

يمكنك أيضًا منح لعبة مفضلة إدخالها الخاص في مشغّل التطبيقات باستخدام _تثبيت > الألعاب > مشغّل ألعاب RetroArch_، والذي يتيح لك اختيار نواة وملف ROM، والانتقال مباشرة إلى اللعبة من `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

ثبّت تطبيق Xbox Cloud Gaming على الويب عن طريق اختيار _تثبيت > الألعاب > Xbox Cloud Gaming_ من قائمة Omarchy (`Super + Space`). إنه «مجرد» تطبيق ويب للخدمة، لكنه سريع في البدء ويعمل بشكل رائع بدقة 1080p.

إذا كان لديك Xbox Game Pass بالفعل، فهذه طريقة ممتازة للعب Fortnite وعناوين أخرى لا يمكنك تشغيلها أصليًا على Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

ثبّت خدمة الألعاب السحابية [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) عن طريق اختيار _تثبيت > الألعاب > NVIDIA GeForce NOW_ من قائمة Omarchy (`Super + Space`). طريقة رائعة أخرى للعب العناوين غير المتوفرة أصليًا على Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

ثبّت Minecraft عن طريق اختيار _تثبيت > الألعاب > Minecraft_ من قائمة Omarchy (`Super + Space`).

مثل Steam، لاحظ أنه قد يستغرق الأمر بعض الوقت بعد تسجيل الدخول أو بدء التشغيل حتى تظهر الشاشة التالية، ولن تحصل على أي مؤشر أثناء الانتظار.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## وحدات تحكم Xbox

ثبّت دعم وحدات تحكم Xbox عبر Bluetooth عن طريق اختيار _تثبيت > الألعاب > وحدات تحكم Xbox_ من قائمة Omarchy (`Super + Space`). قم بإقران وحدات التحكم عبر Bluetooth (`Super + Ctrl + B`) وستعمل في جميع ألعابك. لا تحتاج إلى هذا إذا كنت توصّل وحدة التحكم سلكيًا فقط باستخدام كابل USB-C.

## Moonlight (بث الألعاب من جهاز PC)

ثبّت [عميل Moonlight](https://github.com/moonlight-stream/moonlight-qt) عن طريق اختيار _تثبيت > الألعاب > Moonlight_ من قائمة Omarchy (`Super + Space`)، ويمكنك بث الألعاب من جهاز PC يعمل بنظام Windows ويشغّل [Sunshine](https://app.lizardbyte.dev/Sunshine/).

إذا كان كل من جهاز Omarchy وجهاز الألعاب عن بُعد موصولين سلكيًا، فستكون التجربة غير قابلة للتمييز عن اللعب محليًا. ارفع الدقة إلى الدقة الأصلية، واضبط معدل التحديث على 120Hz، وارفع معدل البت إلى الحد الأقصى — هذه هي أفضل طريقة للعب ألعاب التصويب التنافسية مثل Fortnite على Linux.

يمكنك أيضًا تحويل جهاز Omarchy إلى المضيف عن طريق تشغيل `omarchy install service sunshine`، والذي يثبّت Sunshine ويفتح منافذ بث Moonlight لشبكة LAN وTailscale الخاصة بك.

## Battle.net

ثبّت [Battle.net](https://eu.shop.battle.net/en-us) عن طريق اختيار _تثبيت > الألعاب > Battle.net_ من قائمة Omarchy (`Super + Space`). يمنحك هذا عناوين مثل Diablo وStarcraft وWorld of Warcraft كتثبيت مستقل يعمل تحت GE-Proton — دون الحاجة إلى Steam أو Lutris أو Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (ألعاب Windows)

ثبّت [Lutris](https://lutris.net/) عن طريق اختيار _تثبيت > الألعاب > Lutris_ من قائمة Omarchy (`Super + Space`). Lutris هي الطريقة للعب ألعاب Windows من متاجر مثل EA وUbisoft Connect التي ليس لديها مثبّتها الخاص أعلاه.

التثبيت متعثّر بعض الشيء ويبدو أحيانًا وكأن شيئًا لا يحدث — تحلَّ بالصبر فقط، فهو يعمل في الخلفية.

## Heroic Launcher (Epic Games)

ثبّت [Heroic Launcher](https://heroicgameslauncher.com/) عن طريق اختيار _تثبيت > الألعاب > Heroic (Epic Games)_ من قائمة Omarchy (`Super + Space`). يتيح لك Heroic تشغيل عناوين Epic Games، مثل OddSparks، التي لا تعتمد على مكافحة الغش — بالإضافة إلى ألعاب من GOG وAmazon Prime Gaming. للأسف، هذا يعني أنه لا توجد Fortnite ولا Rocket League — وحتى يأتي Tim Sweeney إلى Linux، فهذا هو أقرب ما يمكنك الحصول عليه.

مثل Lutris، قد يبدو بطيئًا ومتعثّرًا أثناء تثبيت الألعاب. امنحه بعض الوقت.
