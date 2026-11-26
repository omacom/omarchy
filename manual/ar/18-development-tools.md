# أدوات التطوير

## محررات بديلة

تأتي Omarchy مع Plain كمحرر افتراضي في عمليات التثبيت الجديدة ومع [Neovim](https://neovim.io/) مثبت مسبقًا، لكن إذا أردت شيئًا أكثر شيوعًا وألفة، يمكنك تشغيل Omarchy Menu (`Super + Space`) والاطلاع على الخيارات ضمن _Install > Editor_. لدينا هناك VSCode وCursor وZed وSublime Text وHelix وVim وEmacs. إذا لم تجد ما تبحث عنه، فاطّلع على _Install > Package_ لترى إن كان متوفرًا في حزمة Arch (وإن لم يكن، فجرّب _Install > AUR_ للتحقق من AUR).

محرر `vi` الأصلي متوفر أيضًا من البداية. شغّل `vi filename` لتحرير ملف في الطرفية.

تُقدَّم مطابقة السمات لـ `VSCode` و`Cursor` و`VSCodium` و`Helix`.

يمكنك تعيين المحرر الافتراضي على مستوى النظام ضمن `Setup > Defaults > Editor`.

## البيئة

تدعم Omarchy إعداد مجموعة كاملة من بيئات التطوير من خلال قسم _Install > Development_ في Omarchy Menu (`Super + Space`). ستجد بالطبع _Ruby on Rails_، بل ستجد أيضًا الأوقات التشغيلية الثلاثة الرئيسية لـ JavaScript (Node.js وBun وDeno)، بالإضافة إلى أطر عمل PHP الشهيرة مثل Laravel وSymfony. آه، وهناك أيضًا Go وRust وPython وJava وElixir (مع Phoenix) و.NET وOCaml وZig وClojure وScala. إنه اختيار واسع جدًا!

تُدار غالبية هذه البيئات بواسطة [Mise](https://mise.jdx.dev/). إنها أداة تتيح لك تثبيت وتشغيل إصدارات متعددة من لغة برمجة على نفس الجهاز. إنها مثل rbenv أو rvm لـ Ruby أو virtualenv لـ Python، لكنها تعمل مع مجموعة من البيئات المختلفة.

لتثبيت Ruby مثلًا، شغّل `mise use -g ruby`، وسيؤدي ذلك إلى تثبيت Ruby وتعيينه كافتراضي عام. أو، إذا كان مشروعك يحتوي على ملف .ruby-version، يمكنك ببساطة تشغيل `mise i` في جذر ذلك المشروع.

## أدوات CLI المثبتة مسبقًا

تأتي `uv` وNode.js و`playwright-cli` (ليتمكن الوكلاء من قيادة متصفح، باستخدام Chrome المثبت) مثبتة كحزم، ويبقيها `omarchy update` محدثة مع بقية النظام. وتتوفر [Hunk](https://github.com/modem-dev/hunk) وأدوات CLI الخاصة بـ GitHub وBasecamp وCloudflare وHEY على بُعد اختيار واحد ضمن _Install > CLI_، وتتوفر [وكلاء البرمجة](17-ai.md) ضمن _Install > AI > CLI_.

تدير mise فقط أوقات التشغيل التي تعدّها من _Install > Development_؛ فـ Omarchy لا تثبت أي شيء من خلالها من تلقاء نفسها. شغّل `omarchy update` لتحديثها مع بقية Omarchy؛ أما الاسم المستعار `mup` فيحدّث الأدوات التي تديرها mise فقط. لإضافة أداة أخرى إلى إعداداتك الخاصة، استخدم `mise use -g <tool>`.

## Docker

يكاد [Docker](https://www.docker.com/) لا يحتاج إلى أي مقدمة. فهو يتيح لك تشغيل حاويات معزولة، وتثبت Omarchy كل ما يلزم لتشغيله بشكل جيد، بما في ذلك Docker نفسه و[Docker Compose](https://docs.docker.com/compose/).

افتراضيًا، مستخدمك *ليس* في مجموعة `docker`. فتلك المجموعة هي فعليًا root بدون كلمة مرور — فأي شيء فيها يمكنه تشغيل `docker run -v /:/host` والسيطرة على الجهاز — لذا فإن سكربتًا مارقًا واحدًا أو تبعية واحدة تعمل باسمك ستكون على بُعد أمر واحد من root. لهذا السبب تشغّل Docker على سطر الأوامر باستخدام `sudo` (`sudo docker ps` و`sudo docker compose up`)، وتطلب الأدوات الرسومية التي تتحدث إلى الخادم الخلفي — Windows VM — إذنًا عند الحاجة إليه. إذا أردت استعادة راحة إعداد بدون مجموعة وفهمت المقايضة، فعّلها من **Setup > Security > Sudoless Docker** (أو شغّل `omarchy-setup-security-sudoless-docker`)، وسيضيفك ذلك إلى مجموعة `docker` بعد تحذير؛ وبعدها يعمل `docker` العادي والاسم المستعار `d` بدون `sudo` مرة أخرى.

يمكنك إعداد قواعد البيانات الشائعة للتطوير المحلي في Docker باستخدام _Install > Development > Docker DB_ في قائمة Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) هي `gh`، للعمل مع المستودعات والمشكلات وطلبات السحب من الطرفية. يثبتها _Setup > Git_ عندما تختار تسجيل الدخول إلى GitHub هناك، أو ثبّتها منفردة من _Install > CLI > GitHub_. بعد ذلك، ينسخ `gh repo clone org/repo` مستودعًا؛ شغّل `gh --help` لاستكشاف أوامرها.

[Lazygit](https://github.com/jesseduffield/lazygit) مثبت مسبقًا للعمل مع Git نفسه.
