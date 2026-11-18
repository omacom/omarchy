# תמיכה ב-Mac

ל-Omarchy יש תמיכה מובנית ב-**Intel Macs**. יש כמה מגבלות ידועות כרגע, אבל כל עוד אתה מודע להן וזה בסדר מבחינתך; אתה יכול להפיח חיים חדשים ב-Mac הישן שלך על ידי טעינת Omarchy.

שים לב שהתקנה על Mac מסדרת M אינה נתמכת ישירות בשלב זה. אתה יכול לגלות עוד על המצב של זה ב-#omarchy-on-other ב-[Discord](https://discord.gg/tXFUdasqhY) שלנו.

בבדיקה פשוטה, הצלחנו להשיג שיפור ביצועים של 36% על MacBook Pro משנת 2019 רק על ידי התקנת Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### התקנת Omarchy על Mac

Omarchy תומך כרגע רק במצב שבו הוא מערכת ההפעלה ה**יחידה** המותקנת. במהלך ההתקנה, הכונן יימחק ו-MacOS כבר לא יהיה ניתן לאתחול.

עדיין תוכל לשחזר אותו מאוחר יותר באמצעות Internet Recovery אם תרצה.

לצורך חלק זה, נניח שכבר עברת על [תחילת העבודה](02-getting-started.md) ושהתקן ה-USB שלך מוכן. אם לא, לך ועשה את זה עכשיו.

#### השבתת Secure Boot

יש צורך להשבית את Secure Boot של Apple כדי לאתחל את התקן ה-USB הניתן לאתחול, כמו גם את מערכת ההפעלה. כדי להשבית אותו, בצע את הפעולות הבאות:

1. כבה את ה-Mac שלך
2. הפעל אותו ו_מיד_ לחץ והחזק את Command-R עד שתראה את מסך הטעינה מופיע
3. בחר את המשתמש שלך והזן את הסיסמה שלך אם תתבקש
4. ברגע שתגיע למסך השחזור, בחר **Utilities > Startup Security Utility** משורת התפריטים
5. הזן את הסיסמה שלך כאשר תתבקש לבצע אימות
6. בחר "No Security" מתוך אפשרויות Secure Boot
7. בחר "Allow booting from external or removable media" מתוך אפשרויות External Boot

#### התחלת ההתקנה

1. הכנס את התקן ה-USB
2. הפעל מחדש את ה-Mac שלך ו_מיד_ לחץ והחזק את Option עד שתראה מסך של התקני אתחול
3. בחר את התקן EFI Boot הכתום
4. המשך עם [ההתקנה כרגיל](02-getting-started.md)

תוכנית ההתקנה מזהה חומרת Mac ומחילה את התיקונים הדרושים באופן אוטומטי: מנהלי התקן וקושחת Broadcom Wi-Fi, מנהל ההתקן למקלדת SPI בדגמי MacBook שזקוקים לו, ותיקון להשעיית NVMe עבור אותם דגמים.

### מגבלות ידועות

חברי הקהילה עובדים כל הזמן על פתרונות לאתגרים האלה, אז אם אלה בעייתיים עבורך, הצטרף ל-#omarchy-on-other ב-[Discord](https://discord.gg/tXFUdasqhY) שלנו ובדוק אם יש שיטות עדכניות כלשהן לפתרונם.

#### מכשירים עם שבב T1

שבב Apple T1 הוצג בסוף 2016 ושימש באופן בלעדי בדגמי MacBook Pro מהדור הראשון עם Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### בעיות ידועות

- Touch Bar אינו פועל
- השמע אינו פועל

#### מכשירים עם שבב T2

שבב האבטחה Apple T2 הוצג בשנת 2017. שבב T2 הופסק עם המעבר ל-Apple silicon (שבבי סדרת M) החל משנת 2020.

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

בדגמים אלה, תוכנית ההתקנה מגדירה באופן אוטומטי את ליבת `linux-t2` המתוקנת, את תצורת השמע של T2, את קושחת Broadcom Wi-Fi/Bluetooth של Apple, ואת בקרת המאווררים באמצעות `t2fanrd`. ה-Touch Bar פועל על התמיכה המובנית בסגנון Boot Camp של הליבה.

#### iMac Retina 5K (2017)

ל-iMac בגודל 27 אינץ' משנת 2017 אין שבב T2, אז תוכנית ההתקנה מגדירה אותו כמו שאר Intel Macs.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### בעיות ידועות

- התצוגה אינה פועלת ברזולוציה המקורית שלה 5120×2880: הפאנל מורכב משני אריחים, ומנהל ההתקן הסטנדרטי מאיר רק אחד מהם
- השמע אינו פועל
- לבקרת הבהירות אין השפעה
- מצב שינה תוקע את המחשב; רק כיבוי והפעלה מחדש משחזרים אותו

מתקן קהילתי לדגם זה מתקן את התצוגה, השמע והבהירות: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
