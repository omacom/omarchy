# الألعاب

Omarchy ليست فقط من أجل _الإنتاجية_، بل هي أيضًا من أجل المتعة، وما هو أكثر متعة من الألعاب؟ تأتي Omarchy مع مجموعة كاملة من خيارات الألعاب — Steam وRetroArch للعب الأصلي والقديم، وBattle.net وLutris وHeroic للمتاجر غير التابعة لـ Steam، وMoonlight لبث ألعاب PC، وXbox Cloud Gaming + NVIDIA GeForce NOW للعب السحابي، بالإضافة إلى Minecraft التي لا تنتهي شعبيتها أبدًا.

بفضل عمل Valve المذهل على [طبقة التوافق Proton](https://en.wikipedia.org/wiki/Proton_(software))، أصبح هناك الآن عشرات الآلاف من الألعاب الحديثة القابلة للعب على Linux. أوه، وهل كنت تعلم أن [Steam Deck](https://store.steampowered.com/steamdeck/) يعمل في الواقع بنظام Arch!

توجد جميع مثبتات الألعاب تحت _تثبيت > الألعاب_ في قائمة Omarchy (`Super + Space`). وإذا أردت يومًا التراجع عن أحدها، فاستخدم _إزالة > الألعاب_. تتوفر Minecraft وNVIDIA GeForce NOW وBattle.net وLutris وHeroic على أجهزة x86 فقط.

## Steam

ثبّت [Steam](https://store.steampowered.com/) بتحديد _تثبيت > الألعاب > Steam_ من قائمة Omarchy (`Super + Space`).

بعد تثبيته، ستتمكن من تشغيل Steam باستخدام `Super + Space`.

لاحظ أن Steam قد يستغرق من 10 إلى 20 ثانية ليبدأ، ولن يقدم أي مؤشر مرئي على أنه قيد التحميل.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

ثبّت [RetroArch](https://www.retroarch.com/) بتحديد _تثبيت > الألعاب > RetroArch_ من قائمة Omarchy (`Super + Space`). يأتي مع المجموعة الكاملة من أنوية libretro، لذا فإن جميع الأنظمة الكلاسيكية مشمولة.

RetroArch مهيأ مسبقًا بالكامل مع مُظلّل CRT Royale الجميل للحصول على ذلك المظهر القديم المثالي.

للبدء:

1. ضع ملفات BIOS في `~/Games/bios` وملفات ROM في `~/Games/roms`.
2. شغّل RetroArch باستخدام `Super + Space` واكتب `retro`.
3. افحص مجلد `~/Games/roms` وستكون جاهزًا للعب.

يمكنك أيضًا منح لعبة مفضلة إدخالها الخاص في مشغّل التطبيقات باستخدام _تثبيت > الألعاب > RetroArch Game Launcher_، والذي يتيح لك اختيار نواة وملف ROM، والقفز مباشرة إلى اللعبة من `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

ثبّت تطبيق Xbox Cloud Gaming على الويب بتحديد _تثبيت > الألعاب > Xbox Cloud Gaming_ من قائمة Omarchy (`Super + Space`). إنه "مجرد" تطبيق ويب للخدمة، لكنه سريع التشغيل ويعمل بشكل رائع بدقة 1080p.

إذا كان لديك Xbox Game Pass بالفعل، فهذه طريقة قوية للعب Fortnite وعناوين أخرى لا يمكنك تشغيلها أصليًا على Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

ثبّت خدمة الألعاب السحابية [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) بتحديد _تثبيت > الألعاب > NVIDIA GeForce NOW_ من قائمة Omarchy (`Super + Space`). طريقة رائعة أخرى للعب العناوين غير المتوفرة أصليًا على Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

ثبّت Minecraft بتحديد _تثبيت > الألعاب > Minecraft_ من قائمة Omarchy (`Super + Space`).

كما هو الحال مع Steam، لاحظ أن ظهور الشاشة التالية قد يستغرق بعض الوقت بعد تسجيل الدخول أو بدء التشغيل، ولن تحصل على أي مؤشر أثناء الانتظار.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## وحدات تحكم Xbox

ثبّت دعم وحدات تحكم Xbox عبر Bluetooth بتحديد _تثبيت > الألعاب > Xbox Controllers_ من قائمة Omarchy (`Super + Space`). قم بإقران وحدات التحكم عبر Bluetooth (`Super + Ctrl + B`) وستعمل في جميع ألعابك. لا تحتاج إلى هذا إذا كنت توصل وحدة التحكم سلكيًا فقط باستخدام كابل USB-C.

## Moonlight (بث الألعاب من PC)

ثبّت [عميل Moonlight](https://github.com/moonlight-stream/moonlight-qt) بتحديد _تثبيت > الألعاب > Moonlight_ من قائمة Omarchy (`Super + Space`)، ويمكنك بث الألعاب من PC يعمل بنظام Windows ويشغّل [Sunshine](https://app.lizardbyte.dev/Sunshine/).

إذا كان كل من جهاز Omarchy وجهاز الألعاب البعيد موصلين سلكيًا، فلن يمكن تمييز التجربة عن اللعب محليًا. ارفع الدقة إلى الدقة الأصلية، واضبط معدل التحديث على 120Hz، وارفع معدل البت إلى الحد الأقصى — هذه هي أفضل طريقة للعب ألعاب التصويب التنافسية مثل Fortnite على Linux.

يمكنك أيضًا تحويل جهاز Omarchy إلى مضيف بتشغيل `omarchy install service sunshine`، والذي يثبّت Sunshine ويفتح منافذ بث Moonlight لشبكة LAN وTailscale الخاصة بك.

## Battle.net

ثبّت [Battle.net](https://eu.shop.battle.net/en-us) بتحديد _تثبيت > الألعاب > Battle.net_ من قائمة Omarchy (`Super + Space`). يمنحك هذا عناوين مثل Diablo وStarcraft وWorld of Warcraft كتثبيت مستقل يعمل تحت GE-Proton — دون الحاجة إلى Steam أو Lutris أو Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (ألعاب Windows)

ثبّت [Lutris](https://lutris.net/) بتحديد _تثبيت > الألعاب > Lutris_ من قائمة Omarchy (`Super + Space`). Lutris هو الطريقة للعب ألعاب Windows من متاجر مثل EA وUbisoft Connect التي ليس لها مثبت خاص بها أعلاه.

التثبيت متعثر بعض الشيء ويبدو أحيانًا وكأن شيئًا لا يحدث — فقط كن صبورًا، فهو يعمل في الخلفية.

## Heroic Launcher (Epic Games)

ثبّت [Heroic Launcher](https://heroicgameslauncher.com/) بتحديد _تثبيت > الألعاب > Heroic (Epic Games)_ من قائمة Omarchy (`Super + Space`). يتيح لك Heroic تشغيل عناوين Epic Games، مثل OddSparks، التي لا تعتمد على مكافحة الغش — بالإضافة إلى ألعاب من GOG وAmazon Prime Gaming. وللأسف، هذا يعني أنه لا توجد Fortnite ولا Rocket League — إلى أن يأتي Tim Sweeney إلى Linux، فهذا هو أقرب ما يمكن الوصول إليه.

كما هو الحال مع Lutris، قد يبدو بطيئًا ومتعثرًا أثناء تثبيت الألعاب. امنحه بعض الوقت.
