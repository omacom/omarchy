# دعم Mac

يحتوي Omarchy على دعم مدمج لأجهزة **Intel Mac**. هناك بعض القيود المعروفة في الوقت الحالي، ولكن طالما أنك على علم بها وموافق عليها؛ يمكنك بث حياة جديدة في أجهزة Mac القديمة الخاصة بك عن طريق تحميل Omarchy.

يرجى ملاحظة أن التثبيت على جهاز Mac من سلسلة M غير مدعوم مباشرة في هذا الوقت. يمكنك معرفة المزيد عن حالة هذا في #omarchy-on-other في [Discord](https://discord.gg/tXFUdasqhY) الخاص بنا.

في اختبار بسيط، تمكنّا من تحقيق مكاسب أداء بنسبة 36٪ على جهاز MacBook Pro من عام 2019 فقط عن طريق تثبيت Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### تثبيت Omarchy على Mac

يدعم Omarchy أن يكون نظام التشغيل **الوحيد** المثبّت في الوقت الحالي. أثناء التثبيت، سيُمسح محرك الأقراص ولن يعود MacOS قابلًا للإقلاع.

لا يزال بإمكانك استعادته لاحقًا عبر Internet Recovery إذا أردت.

من أجل هذا الجزء، سنفترض أنك راجعت بالفعل [البدء](02-getting-started.md) وأن محرك USB الخاص بك جاهز. إذا لم تفعل، فافعل ذلك الآن.

#### تعطيل الإقلاع الآمن

من الضروري تعطيل الإقلاع الآمن من Apple من أجل إقلاع USB القابل للإقلاع، وكذلك نظام التشغيل. لتعطيله، نفّذ الخطوات التالية:

1. أوقف تشغيل جهاز Mac الخاص بك
2. شغّله واضغط _فورًا_ مع الاستمرار على Command-R حتى ترى شاشة التحميل تظهر
3. حدّد المستخدم الخاص بك وأدخل كلمة المرور الخاصة بك إذا طُلب منك ذلك
4. بمجرد أن تكون في شاشة الاسترداد، اختر **Utilities > Startup Security Utility** من شريط القائمة
5. أدخل كلمة المرور الخاصة بك عندما يُطلب منك المصادقة
6. اختر "No Security" من خيارات الإقلاع الآمن
7. اختر "Allow booting from external or removable media" من خيارات الإقلاع الخارجي

#### بدء التثبيت

1. أدخل محرك USB
2. أعد تشغيل جهاز Mac الخاص بك واضغط _فورًا_ مع الاستمرار على Option حتى ترى شاشة أجهزة الإقلاع
3. حدّد جهاز EFI Boot البرتقالي
4. تابع مع [التثبيت كالمعتاد](02-getting-started.md)

يكشف المثبّت عتاد Mac ويطبّق الإصلاحات اللازمة تلقائيًا: برامج تشغيل Broadcom Wi-Fi والبرامج الثابتة، ومحرك لوحة مفاتيح SPI على طرازات MacBook التي تحتاجه، وإصلاح تعليق NVMe لتلك الطرازات نفسها.

### القيود المعروفة

يعمل أعضاء المجتمع باستمرار على حلول لهذه التحديات، لذا إذا كانت هذه مشكلة بالنسبة لك، فانضم إلى #omarchy-on-other في [Discord](https://discord.gg/tXFUdasqhY) الخاص بنا وانظر ما إذا كانت هناك أي طرق محدّثة لحلها.

#### الأجهزة مع رقاقة T1

قُدّمت رقاقة Apple T1 في أواخر عام 2016 واستُخدمت حصريًا في طرازات الجيل الأول من MacBook Pro مع Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### المشكلات المعروفة

- Touch Bar غير وظيفي
- الصوت لا يعمل

#### الأجهزة مع رقاقة T2

قُدّمت رقاقة أمان Apple T2 في عام 2017. أُوقفت رقاقة T2 مع الانتقال إلى Apple silicon (رقاقات سلسلة M) بدءًا من عام 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

على هذه الطرازات، يُعدّ المثبّت تلقائيًا نواة `linux-t2` المصحّحة، وتكوين صوت T2، والبرامج الثابتة لـ Broadcom Wi-Fi/Bluetooth من Apple، والتحكم في المروحة عبر `t2fanrd`. يعمل Touch Bar على دعم Boot Camp المدمج في النواة.
