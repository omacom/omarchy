# משחקים

Omarchy אינה מיועדת רק ל_פְרוֹדוּקְטִיבִיוּת_, היא גם מיועדת להנאה, ומה יותר מהנה ממשחקים? Omarchy מגיעה עם חבילה שלמה של אפשרויות משחק — Steam ו-RetroArch למשחק מקומי ורטרו, Battle.net, Lutris ו-Heroic לחנויות שאינן Steam, Moonlight להזרמת PC, Xbox Cloud Gaming + NVIDIA GeForce NOW לענן, בנוסף ל-Minecraft הנצחי.

בזכות העבודה המדהימה של Valve על [שכבת התאימות proton](https://en.wikipedia.org/wiki/Proton_(software)), יש כיום עשרות אלפי משחקים מודרניים ניתנים למשחק ב-Linux. אה, וידעתם שה-[Steam Deck](https://store.steampowered.com/steamdeck/) מריץ בפועל את Arch!

כל מתקיני המשחקים נמצאים תחת _התקנה > משחקים_ בתפריט Omarchy (`Super + Space`). אם אי פעם תרצו לבטל אחד, השתמשו ב_הסרה > משחקים_.

## Steam

התקינו את [Steam](https://store.steampowered.com/) על ידי בחירת _התקנה > משחקים > Steam_ מתפריט Omarchy (`Super + Space`).

לאחר שהתקנתם אותו, תוכלו להפעיל את Steam עם `Super + Space`.

שימו לב ש-Steam עלול לקחת 10-20 שניות להפעלה, והוא אינו עומד לספק שום משוב חזותי שהוא נטען.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

התקינו את [RetroArch](https://www.retroarch.com/) על ידי בחירת _התקנה > משחקים > RetroArch_ מתפריט Omarchy (`Super + Space`). הוא מגיע עם הסט המלא של ליבות libretro, כך שכל המערכות הקלאסיות מכוסות.

RetroArch מוגדר מראש במלואו עם שיידר CRT Royale היפהפה למראה הרטרו המושלם ההוא.

כדי להתחיל:

1. השליכו את קבצי ה-BIOS שלכם לתוך `~/Games/bios` ואת ה-ROMs שלכם לתוך `~/Games/roms`.
2. הפעילו את RetroArch עם `Super + Space` והקלדת `retro`.
3. סרקו את ספריית `~/Games/roms` ואתם מוכנים לשחק.

תוכלו גם לתת למשחק אהוב ערך משלו במפעיל האפליקציות עם _התקנה > משחקים > משגר משחקי RetroArch_, המאפשר לכם לבחור ליבה ו-ROM, ולקפוץ ישירות למשחק מ-`Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

התקינו את אפליקציית הרשת Xbox Cloud Gaming על ידי בחירת _התקנה > משחקים > Xbox Cloud Gaming_ מתפריט Omarchy (`Super + Space`). זו "רק" אפליקציית רשת עבור השירות, אבל היא מהירה להפעלה ופועלת נהדר ב-1080p.

אם כבר יש לכם Xbox Game Pass, זו דרך מוצקה לשחק ב-Fortnite ובכותרות אחרות שאינכם יכולים להפעיל באופן מקומי ב-Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

התקינו את שירות משחקי הענן [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) על ידי בחירת _התקנה > משחקים > NVIDIA GeForce NOW_ מתפריט Omarchy (`Super + Space`). עוד דרך מצוינת לשחק בכותרות שאינן זמינות באופן מקומי ב-Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

התקינו את Minecraft על ידי בחירת _התקנה > משחקים > Minecraft_ מתפריט Omarchy (`Super + Space`).

כמו Steam, שימו לב שעלול לקחת זמן לאחר כניסה או הפעלה עד שהמסך הבא יופיע, ולא תקבלו שום משוב בזמן שאתם ממתינים.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## בקרי Xbox

התקינו תמיכה בבקרי Xbox ב-Bluetooth על ידי בחירת _התקנה > משחקים > בקרי Xbox_ מתפריט Omarchy (`Super + Space`). שייכו את הבקרים דרך Bluetooth (`Super + Ctrl + B`) והם יעבדו בכל המשחקים שלכם. אינכם זקוקים לכך אם אתם פשוט מחברים את הבקר שלכם בכבל USB-C.

## Moonlight (הזרמת משחקים מ-PC)

[לקוח Moonlight](https://github.com/moonlight-stream/moonlight-qt) מגיע מותקן מראש עם Omarchy, כך שתוכלו להזרים משחקים מ-PC עם Windows המריץ את [Sunshine](https://app.lizardbyte.dev/Sunshine/) מיד. הפעילו את Moonlight דרך `Super + Space`.

אם הן מכונת Omarchy שלכם והן מחשב המשחקים המרוחק מחוברים בכבל, החוויה אינה ניתנת להבחנה ממשחק מקומי. הגביהו את הרזולוציה למקורית, הגדירו את הרענון ל-120Hz, ומקסימו את קצב הסיביות — זו הדרך הטובה ביותר לשחק ביריות תחרותיות כמו Fortnite ב-Linux.

תוכלו גם להפוך מכונת Omarchy למארחת על ידי הרצת `omarchy install service sunshine`, המתקינה את Sunshine ופותחת את פורטי ההזרמה של Moonlight עבור ה-LAN ו-Tailscale שלכם.

## Battle.net

התקינו את [Battle.net](https://eu.shop.battle.net/en-us) על ידי בחירת _התקנה > משחקים > Battle.net_ מתפריט Omarchy (`Super + Space`). זה נותן לכם כותרות כמו Diablo, Starcraft ו-World of Warcraft כהתקנה עצמאית הפועלת תחת GE-Proton — ללא צורך ב-Steam, Lutris או Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (משחקי Windows)

התקינו את [Lutris](https://lutris.net/) על ידי בחירת _התקנה > משחקים > Lutris_ מתפריט Omarchy (`Super + Space`). Lutris היא הדרך לשחק במשחקי Windows מחנויות כמו EA ו-Ubisoft Connect שאין להן מתקין משלהן לעיל.

ההתקנה קצת מקרטעת ונראית כאילו דבר אינו קורה לעיתים — פשוט היו סבלניים, היא עובדת ברקע.

## Heroic Launcher (Epic Games)

התקינו את [Heroic Launcher](https://heroicgameslauncher.com/) על ידי בחירת _התקנה > משחקים > Heroic (Epic Games)_ מתפריט Omarchy (`Super + Space`). Heroic מאפשר לכם להפעיל כותרות Epic Games, כמו OddSparks, שאינן מסתמכות על אנטי-צ'יט — בנוסף למשחקים מ-GOG ומ-Amazon Prime Gaming. למרבה הצער, זה אומר ללא Fortnite וללא Rocket League — עד שטים סוויני יגיע ל-Linux, זה הכי קרוב שאפשר.

כמו Lutris, הוא עלול להרגיש איטי ומקרטע בזמן התקנת משחקים. תנו לו זמן.
