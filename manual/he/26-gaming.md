# משחקים

Omarchy לא נועדה רק ל־_pRoDUcTiVItY_, היא נועדה גם לכיף, ומה יותר כיף ממשחקים? Omarchy מגיעה עם חבילה שלמה של אפשרויות משחק — Steam ו־RetroArch למשחק מקורי ורטרו, Battle.net, Lutris ו־Heroic לחנויות שאינן Steam, Moonlight להזרמה ממחשב PC, Xbox Cloud Gaming + NVIDIA GeForce NOW לענן, וגם Minecraft הנצחי.

בזכות העבודה המדהימה של Valve על [שכבת התאימות Proton](https://en.wikipedia.org/wiki/Proton_(software)), יש כעת עשרות אלפי משחקים מודרניים שניתן לשחק בהם ב־Linux. אה, וידעתם ש־[Steam Deck](https://store.steampowered.com/steamdeck/) בעצם מריץ Arch!

כל מתקיני המשחקים נמצאים תחת _Install > Gaming_ בתפריט של Omarchy (`Super + Space`). אם תרצו אי פעם לבטל אחד מהם, השתמשו ב־_Remove > Gaming_.

## Steam

התקינו את [Steam](https://store.steampowered.com/) על ידי בחירת _Install > Gaming > Steam_ מתפריט Omarchy (`Super + Space`).

לאחר ההתקנה, תוכלו להפעיל את Steam באמצעות `Super + Space`.

שימו לב שיכול לקחת ל־Steam כ־10-20 שניות להיפתח, והוא לא יספק שום חיווי חזותי על כך שהוא נטען.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

התקינו את [RetroArch](https://www.retroarch.com/) על ידי בחירת _Install > Gaming > RetroArch_ מתפריט Omarchy (`Super + Space`). הוא מגיע עם הסט המלא של ליבות libretro, כך שכל המערכות הקלאסיות מכוסות.

RetroArch מוגדר מראש במלואו עם שיידר CRT Royale היפהפה, למראה הרטרו המושלם.

כדי להתחיל:

1. שימו את קבצי ה־BIOS שלכם ב־`~/Games/bios` ואת ה־ROMs שלכם ב־`~/Games/roms`.
2. הפעילו את RetroArch באמצעות `Super + Space` והקלדת `retro`.
3. סרקו את תיקיית `~/Games/roms` ואתם מוכנים לשחק.

תוכלו גם לתת למשחק אהוב כניסה משלו במפעיל היישומים עם _Install > Gaming > RetroArch Game Launcher_, שמאפשר לכם לבחור ליבה ו־ROM ולקפוץ ישירות למשחק מתוך `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

התקינו את אפליקציית האינטרנט של Xbox Cloud Gaming על ידי בחירת _Install > Gaming > Xbox Cloud Gaming_ מתפריט Omarchy (`Super + Space`). זו "רק" אפליקציית אינטרנט לשירות, אבל היא נפתחת מהר ורצה מצוין ב־1080p.

אם כבר יש לכם Xbox Game Pass, זו דרך מצוינת לשחק ב־Fortnite ובכותרים אחרים שאי אפשר להריץ באופן מקורי ב־Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

התקינו את שירות משחקי הענן [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) על ידי בחירת _Install > Gaming > NVIDIA GeForce NOW_ מתפריט Omarchy (`Super + Space`). עוד דרך מצוינת לשחק בכותרים שאינם זמינים באופן מקורי ב־Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

התקינו את Minecraft על ידי בחירת _Install > Gaming > Minecraft_ מתפריט Omarchy (`Super + Space`).

כמו Steam, שימו לב שיכול לקחת זמן לאחר הכניסה או ההפעלה עד שהמסך הבא יופיע, ולא תקבלו שום חיווי בזמן ההמתנה.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## בקרי Xbox

התקינו תמיכה בבקרי Xbox ב־Bluetooth על ידי בחירת _Install > Gaming > Xbox Controllers_ מתפריט Omarchy (`Super + Space`). צמדו את הבקרים באמצעות Bluetooth (`Super + Ctrl + B`) והם יעבדו בכל המשחקים שלכם. אינכם צריכים זאת אם אתם פשוט מחברים את הבקר בחיבור קווי עם כבל USB-C.

## Moonlight (הזרמת משחקים ממחשב PC)

התקינו את [לקוח Moonlight](https://github.com/moonlight-stream/moonlight-qt) על ידי בחירת _Install > Gaming > Moonlight_ מתפריט Omarchy (`Super + Space`), ותוכלו להזרים משחקים ממחשב Windows שמריץ את [Sunshine](https://app.lizardbyte.dev/Sunshine/).

אם גם מכונת ה־Omarchy שלכם וגם מחשב המשחקים המרוחק מחוברים בחיבור קווי, החוויה לא תהיה ניתנת להבחנה ממשחק מקומי. העלו את הרזולוציה לטבעית, הגדירו את קצב הרענון ל־120Hz ומקסמו את קצב הסיביות — זו הדרך הטובה ביותר לשחק במשחקי יריות תחרותיים כמו Fortnite ב־Linux.

תוכלו גם להפוך מכונת Omarchy למארחת על ידי הרצת `omarchy install service sunshine`, שמתקינה את Sunshine ופותחת את יציאות ההזרמה של Moonlight עבור ה־LAN ו־Tailscale שלכם.

## Battle.net

התקינו את [Battle.net](https://eu.shop.battle.net/en-us) על ידי בחירת _Install > Gaming > Battle.net_ מתפריט Omarchy (`Super + Space`). זה נותן לכם כותרים כמו Diablo, Starcraft ו־World of Warcraft כהתקנה עצמאית הרצה תחת GE-Proton — בלי צורך ב־Steam, Lutris או Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (משחקי Windows)

התקינו את [Lutris](https://lutris.net/) על ידי בחירת _Install > Gaming > Lutris_ מתפריט Omarchy (`Super + Space`). Lutris היא הדרך לשחק במשחקי Windows מחנויות כמו EA ו־Ubisoft Connect שאין להן מתקין משלהן לעיל.

ההתקנה מעט מקרטעת ולפעמים נראה כאילו כלום לא קורה — פשוט היו סבלניים, זה עובד ברקע.

## Heroic Launcher (Epic Games)

התקינו את [Heroic Launcher](https://heroicgameslauncher.com/) על ידי בחירת _Install > Gaming > Heroic (Epic Games)_ מתפריט Omarchy (`Super + Space`). Heroic מאפשר לכם להריץ כותרי Epic Games, כמו OddSparks, שאינם מסתמכים על anti-cheat — וגם משחקים מ־GOG ומ־Amazon Prime Gaming. לצערנו, זה אומר שאין Fortnite ואין Rocket League — עד ש־Tim Sweeney יגיע ל־Linux, זה הכי קרוב שיש.

כמו Lutris, זה יכול להרגיש איטי ומקרטע בזמן התקנת משחקים. תנו לזה זמן.
