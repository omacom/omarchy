# الألعاب

Omarchy ليس فقط من أجل _الإنتااااجية_، بل من أجل الاستمتاع أيضًا، وما الذي يضاهي الألعاب في المتعة؟ يأتي Omarchy مع مجموعة كاملة من خيارات الألعاب — Steam وRetroArch للعب الأصيل والرجعي، وBattle.net وLutris وHeroic للمتاجر غير Steam، وMoonlight لبث ألعاب الكمبيوتر، وXbox Cloud Gaming + NVIDIA GeForce NOW للسحابة، إضافة إلى Minecraft الخالدة.

بفضل عمل Valve الرائع على [طبقة التوافق proton](https://en.wikipedia.org/wiki/Proton_(software))، توجد الآن عشرات آلاف الألعاب الحديثة القابلة للعب على Linux. آه، وهل تعلم أن [Steam Deck](https://store.steampowered.com/steamdeck/) يعمل فعليًا على Arch!

تعيش جميع مثبّتات الألعاب ضمن _تثبيت > Gaming_ في قائمة Omarchy (`Super + Space`). إذا أردت يومًا التراجع عن إحداها، فاستخدم _إزالة > Gaming_.

## Steam

ثبّت [Steam](https://store.steampowered.com/) عن طريق اختيار _تثبيت > Gaming > Steam_ من قائمة Omarchy (`Super + Space`).

بعد تثبيته، ستتمكن من تشغيل Steam باستخدام `Super + Space`.

لاحظ أن Steam قد يستغرق 10-20 ثانية ليبدأ، ولن يوفر أي إشارة مرئية على أنه يقوم بالتحميل.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

ثبّت [RetroArch](https://www.retroarch.com/) عن طريق اختيار _تثبيت > Gaming > RetroArch_ من قائمة Omarchy (`Super + Space`). يأتي مع المجموعة الكاملة من أنوية libretro، لذا كل الأنظمة الكلاسيكية مشمولة.

يأتي RetroArch مضبوطًا مسبقًا بالكامل مع Shader CRT Royale الجميل لتلك الإطلالة الرجعية المثالية.

للبدء:

1. ضع ملفات BIOS في `~/Games/bios` وملفات ROM في `~/Games/roms`.
2. شغّل RetroArch باستخدام `Super + Space` واكتب `retro`.
3. امسح مجلد `~/Games/roms` وستكون جاهزًا للعب.

يمكنك أيضًا منح لعبة مفضلة إدخالًا خاصًا بها في مشغّل التطبيقات باستخدام _تثبيت > Gaming > RetroArch Game Launcher_، الذي يتيح لك اختيار نواة وملف ROM، والقفز مباشرة إلى اللعبة من `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

ثبّت تطبيق ويب Xbox Cloud Gaming عن طريق اختيار _تثبيت > Gaming > Xbox Cloud Gaming_ من قائمة Omarchy (`Super + Space`). إنه "مجرد" تطبيق ويب لهذه الخدمة، ولكنه سريع في البدء ويعمل على نحو رائع بدقة 1080p.

إذا كان لديك Xbox Game Pass بالفعل، فهذه طريقة موثوقة للعب Fortnite وألعاب أخرى لا يمكنك تشغيلها أصيلًا على Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

ثبّت خدمة الألعاب السحابية [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) عن طريق اختيار _تثبيت > Gaming > NVIDIA GeForce NOW_ من قائمة Omarchy (`Super + Space`). طريقة أخرى رائعة للعب ألعاب غير متاحة أصيلًا على Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

ثبّت Minecraft عن طريق اختيار _تثبيت > Gaming > Minecraft_ من قائمة Omarchy (`Super + Space`).

مثل Steam، لاحظ أنه قد يستغرق الأمر بعض الوقت بعد تسجيل الدخول أو البدء قبل أن تظهر الشاشة التالية، ولن تحصل على أي إشارة أثناء انتظارك.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## وحدات تحكم Xbox

ثبّت الدعم لوحدات تحكم Xbox عبر Bluetooth عن طريق اختيار _تثبيت > Gaming > Xbox Controllers_ من قائمة Omarchy (`Super + Space`). قم بإقران وحدات التحكم عبر Bluetooth (`Super + Ctrl + B`) وستعمل في جميع ألعابك. لا تحتاج إلى هذا إذا كنت تحوّل وحدات التحكم إلى تشغيل سلكي باستخدام كابل USB-C فحسب.

## Moonlight (بث الألعاب من كمبيوتر)

يأتي [عميل Moonlight](https://github.com/moonlight-stream/moonlight-qt) مثبتًا مسبقًا مع Omarchy، لتتمكن من بث الألعاب من كمبيوتر Windows يعمل بـ [Sunshine](https://app.lizardbyte.dev/Sunshine/) فورًا. شغّل Moonlight عبر `Super + Space`.

إذا كان كل من جهاز Omarchy وجهاز ألعابك البعيد موصولين سلكيًا، فستكون التجربة لا يمكن تمييزها عن اللعب محليًا. ارفع الدقة إلى الأصلية، واضبط معدل التحديث على 120Hz، وضِع معدل البت عند أقصى حد — فهذه أفضل طريقة للعب ألعاب التصويب التنافسية مثل Fortnite على Linux.

يمكنك أيضًا تحويل جهاز Omarchy إلى مضيف عن طريق تشغيل `omarchy install service sunshine`، الذي يقوم بتثبيت Sunshine ويفتح منافذ بث Moonlight لشبكتك المحلية وTailscale.

## Battle.net

ثبّت [Battle.net](https://eu.shop.battle.net/en-us) عن طريق اختيار _تثبيت > Gaming > Battle.net_ من قائمة Omarchy (`Super + Space`). هذا يمنحك ألعابًا مثل Diablo وStarcraft وWorld of Warcraft كعملية تثبيت مستقلة تعمل تحت GE-Proton — دون حاجة إلى Steam أو Lutris أو Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (ألعاب Windows)

ثبّت [Lutris](https://lutris.net/) عن طريق اختيار _تثبيت > Gaming > Lutris_ من قائمة Omarchy (`Super + Space`). Lutris هي الطريقة للعب ألعاب Windows من متاجر مثل EA وUbisoft Connect التي ليس لديها مثبّت خاص بها أعلاه.

عملية التثبيت خرقاء بعض الشيء وتبدو وكأنه لا يحدث شيء في بعض الأوقات — فقط كن صبورًا، فهو يعمل في الخلفية.

## Heroic Launcher (Epic Games)

ثبّت [Heroic Launcher](https://heroicgameslauncher.com/) عن طريق اختيار _تثبيت > Gaming > Heroic (Epic Games)_ من قائمة Omarchy (`Super + Space`). يتيح لك Heroic تشغيل ألعاب Epic Games، مثل OddSparks، التي لا تعتمد على مكافحة الغش — بالإضافة إلى ألعاب من GOG وAmazon Prime Gaming. للأسف، هذا يعني لا Fortnite ولا Rocket League — حتى يأتي Tim Sweeney إلى Linux، فهذا هو أقرب ما يمكن الوصول إليه.

مثل Lutris، قد يبدو بطيئًا وخرقًا أثناء تثبيت الألعاب. امنحه وقتًا.
