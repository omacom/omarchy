# גיימינג

Omarchy היא לא רק בשביל _פרודוקטיביות_, היא גם בשביל כיף, ומה יותר כיף מגיימינג? Omarchy מגיעה עם חבילה שלמה של אפשרויות גיימינג — Steam ו-RetroArch למשחק נייטיב ורטרו, Battle.net, Lutris ו-Heroic לחנויות שאינן של Steam, Moonlight לסטרימינג ממחשב, Xbox Cloud Gaming + NVIDIA GeForce NOW לענן, ועוד Minecraft הנצחי.

בזכות העבודה המדהימה של Valve על [שכבת התאימות Proton](https://en.wikipedia.org/wiki/Proton_(software)), יש כיום עשרות אלפי משחקים מודרניים שניתן לשחק בהם ב-Linux. אה, וידעתם ש-[Steam Deck](https://store.steampowered.com/steamdeck/) בעצם מריץ Arch!

כל מתקיני הגיימינג נמצאים תחת _התקנה > גיימינג_ בתפריט של Omarchy (`Super + Space`). אם תרצו אי פעם לבטל התקנה, השתמשו ב-_הסרה > גיימינג_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris ו-Heroic מוצעים במכונות x86 בלבד.

## Steam

התקינו את [Steam](https://store.steampowered.com/) על ידי בחירת _התקנה > גיימינג > Steam_ מתפריט Omarchy (`Super + Space`).

לאחר שתתקינו אותו, תוכלו להפעיל את Steam באמצעות `Super + Space`.

שימו לב ש-Steam עשוי לקחת 10-20 שניות להיפתח, והוא לא יספק שום חיווי חזותי על כך שהוא נטען.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

התקינו את [RetroArch](https://www.retroarch.com/) על ידי בחירת _התקנה > גיימינג > RetroArch_ מתפריט Omarchy (`Super + Space`). הוא מגיע עם הסט המלא של ליבות libretro, כך שכל המערכות הקלאסיות מכוסות.

RetroArch מוגדר מראש במלואו עם שיידר CRT Royale היפהפה למראה הרטרו המושלם.

כדי להתחיל:

1. שימו את קבצי ה-BIOS שלכם בתוך `~/Games/bios` ואת ה-ROMs שלכם בתוך `~/Games/roms`.
2. הפעילו את RetroArch באמצעות `Super + Space` והקלדת `retro`.
3. סרקו את תיקיית `~/Games/roms` ותהיו מוכנים לשחק.

תוכלו גם לתת למשחק אהוב כניסה משלו במפעיל האפליקציות באמצעות _התקנה > גיימינג > RetroArch Game Launcher_, שמאפשר לכם לבחור ליבה ו-ROM, ולקפוץ ישירות לתוך המשחק מ-`Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

התקינו את אפליקציית הרשת Xbox Cloud Gaming על ידי בחירת _התקנה > גיימינג > Xbox Cloud Gaming_ מתפריט Omarchy (`Super + Space`). זו "בסך הכל" אפליקציית רשת לשירות, אבל היא נפתחת מהר ורצה מצוין ב-1080p.

אם כבר יש לכם Xbox Game Pass, זו דרך מוצלחת לשחק ב-Fortnite ובמשחקים אחרים שאי אפשר להריץ באופן נייטיב ב-Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

התקינו את שירות הגיימינג בענן [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) על ידי בחירת _התקנה > גיימינג > NVIDIA GeForce NOW_ מתפריט Omarchy (`Super + Space`). עוד דרך מצוינת לשחק במשחקים שאינם זמינים באופן נייטיב ב-Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

התקינו את Minecraft על ידי בחירת _התקנה > גיימינג > Minecraft_ מתפריט Omarchy (`Super + Space`).

כמו Steam, שימו לב שייתכן שייקח זמן לאחר ההתחברות או ההפעלה עד שהמסך הבא יופיע, ושלא תקבלו שום חיווי בזמן ההמתנה.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## בקרי Xbox

התקינו תמיכה בבקרי Xbox עם Bluetooth על ידי בחירת _התקנה > גיימינג > בקרי Xbox_ מתפריט Omarchy (`Super + Space`). חברו את הבקרים באמצעות Bluetooth (`Super + Ctrl + B`) והם יעבדו בכל המשחקים שלכם. אינכם צריכים זאת אם אתם פשוט מחברים את הבקר שלכם בחיבור קווי עם כבל USB-C.

## Moonlight (סטרימינג של משחקים ממחשב)

התקינו את [לקוח Moonlight](https://github.com/moonlight-stream/moonlight-qt) על ידי בחירת _התקנה > גיימינג > Moonlight_ מתפריט Omarchy (`Super + Space`), ותוכלו להזרים משחקים ממחשב Windows המריץ את [Sunshine](https://app.lizardbyte.dev/Sunshine/).

אם גם מכונת ה-Omarchy שלכם וגם מחשב הגיימינג המרוחק מחוברים בחיבור קווי, החוויה אינה נבדלת ממשחק מקומי. העלו את הרזולוציה לנייטיב, הגדירו את קצב הרענון ל-120Hz, והעלו את קצב הסיביות למקסימום — זו הדרך הטובה ביותר לשחק ביורים תחרותיים כמו Fortnite ב-Linux.

תוכלו גם להפוך מכונת Omarchy למארחת על ידי הרצת `omarchy install service sunshine`, שמתקין את Sunshine ופותח את פורטי הסטרימינג של Moonlight עבור ה-LAN וה-Tailscale שלכם.

## Battle.net

התקינו את [Battle.net](https://eu.shop.battle.net/en-us) על ידי בחירת _התקנה > גיימינג > Battle.net_ מתפריט Omarchy (`Super + Space`). זה נותן לכם משחקים כמו Diablo, Starcraft ו-World of Warcraft כהתקנה עצמאית הרצה תחת GE-Proton — בלי צורך ב-Steam, Lutris או Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (משחקי Windows)

התקינו את [Lutris](https://lutris.net/) על ידי בחירת _התקנה > גיימינג > Lutris_ מתפריט Omarchy (`Super + Space`). Lutris היא הדרך לשחק במשחקי Windows מחנויות כמו EA ו-Ubisoft Connect שאין להן מתקין משלהן למעלה.

ההתקנה קצת מקרטעת ונראית כאילו שום דבר לא קורה לפעמים — פשוט היו סבלניים, זה עובד ברקע.

## Heroic Launcher (Epic Games)

התקינו את [Heroic Launcher](https://heroicgameslauncher.com/) על ידי בחירת _התקנה > גיימינג > Heroic (Epic Games)_ מתפריט Omarchy (`Super + Space`). Heroic מאפשר לכם להפעיל משחקי Epic Games, כמו OddSparks, שאינם מסתמכים על anti-cheat — ועוד משחקים מ-GOG ומ-Amazon Prime Gaming. למרבה הצער, זה אומר שאין Fortnite ואין Rocket League — עד ש-Tim Sweeney יגיע ל-Linux, זה הכי קרוב שיש.

כמו Lutris, הוא יכול להרגיש איטי ומקרטע בזמן התקנת משחקים. תנו לו זמן.
