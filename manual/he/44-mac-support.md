# תמיכת Mac

Omarchy כולל תמיכה מובנית ב-**מחשבי Mac עם Intel**. יש כמה מגבלות ידועות כרגע, אך כל עוד אתם מודעים ומסכימים להן; תוכלו להפיח חיים חדשים במחשבי ה-Mac הישנים שלכם על ידי טעינת Omarchy.

שימו לב שהתקנה על Mac מסדרת M אינה נתמכת ישירות בשלב זה. תוכלו לגלות עוד על מצב זה ב-#omarchy-on-other ב[Discord](https://discord.gg/tXFUdasqhY) שלנו.

בבדיקה פשוטה, הצלחנו להשיג שיפור ביצועים של 36% ב-MacBook Pro מ-2019 רק על ידי התקנת Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### התקנת Omarchy על Mac

Omarchy תומך רק בלהיות מערכת ההפעלה **היחידה** המותקנת כרגע. במהלך ההתקנה, הכונן יימחק ו-MacOS לא יהיה ניתן עוד לאתחול.

תוכלו עדיין לשחזר אותו מאוחר יותר דרך Internet Recovery אם תרצו.

לצורך חלק זה, נניח שכבר סקרתם את [תחילת העבודה](02-getting-started.md) וכונן ה-USB שלכם מוכן. אם לא, קדימה ועשו זאת עכשיו.

#### השבתת אתחול מאובטח

יש צורך להשבית את האתחול המאובטח של Apple כדי לאתחל את ה-USB הניתן לאתחול, וגם את מערכת ההפעלה. כדי להשבית אותו, בצעו את הפעולות הבאות:

1. כבו את ה-Mac שלכם
2. הדליקו אותו ו_מיד_ החזיקו Command-R עד שתראו את מסך הטעינה מופיע
3. בחרו את המשתמש שלכם והזינו את הסיסמה אם תתבקשו
4. כשאתם במסך השחזור, בחרו **Utilities > Startup Security Utility** משורת התפריטים
5. הזינו את הסיסמה שלכם כשתתבקשו לאמת
6. בחרו "No Security" מאפשרויות האתחול המאובטח
7. בחרו "Allow booting from external or removable media" מאפשרויות האתחול החיצוני

#### התחלת ההתקנה

1. הכניסו את כונן ה-USB
2. הפעילו מחדש את ה-Mac שלכם ו_מיד_ החזיקו Option עד שתראו מסך של התקני אתחול
3. בחרו את התקן EFI Boot הכתום
4. המשיכו עם [ההתקנה כרגיל](02-getting-started.md)

המתקין מזהה חומרת Mac ומחיל את התיקונים הנדרשים אוטומטית: מנהלי התקן וקושחת Wi-Fi של Broadcom, מנהל התקן מקלדת SPI בדגמי MacBook שצריכים אותו, ותיקון השהיית NVMe עבור אותם דגמים.

### מגבלות ידועות

חברי הקהילה עובדים כל הזמן על פתרונות לאתגרים אלה, כך שאם אלה בעייתיים עבורכם, הצטרפו ל-#omarchy-on-other ב[Discord](https://discord.gg/tXFUdasqhY) שלנו ובדקו אם יש שיטות עדכניות כלשהן לפתרונם.

#### התקנים עם שבב T1

שבב Apple T1 הוצג בסוף 2016 ושימש באופן בלעדי בדגמי MacBook Pro מהדור הראשון עם Touch Bar.

- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### בעיות ידועות

- Touch Bar אינו פונקציונלי
- הצליל אינו פועל

#### התקנים עם שבב T2

שבב האבטחה Apple T2 הוצג ב-2017. שבב T2 הופסק עם המעבר לסיליקון של Apple (שבבי סדרת M) החל מ-2020.

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

בדגמים אלה, המתקין מגדיר אוטומטית את ליבת `linux-t2` המתוקנת, את תצורת השמע T2, את קושחת Wi-Fi/Bluetooth של Broadcom של Apple, ובקרת מאוורר דרך `t2fanrd`. ה-Touch Bar פועל על תמיכת Boot Camp המובנית בליבה.
