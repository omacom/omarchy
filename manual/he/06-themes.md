# ערכות נושא

Omarchy מגיעה עם עשרים ושתיים ערכות נושא יפהפיות. אפשר לבחור ביניהן דרך _מראה > ערכת נושא_ בתפריט Omarchy (`Super + Space`) או לקפוץ ישירות לבורר ערכות הנושא באמצעות `Super + Ctrl + T`.

כל ערכת נושא מעצבת את שולחן העבודה, הטרמינל, neovim, מסך הפעילות (btop), Chromium, ואת כל מעטפת Omarchy: הסרגל העליון, התפריט, ההתראות, ה-OSD ומסך הנעילה. (ב-Obsidian, צריך לבחור ידנית את ערכת הנושא של Omarchy דרך _מראה > ערכות נושא_ בתוך האפליקציה).

לערכות הנושא יש סט של תמונות רקע שאפשר לבחור ביניהן באמצעות `Super + Ctrl + W`.

אפשר למצוא עוד ערכות נושא ב[דף ערכות הנושא הנוספות](https://omarchy.org/themes/) או אפילו [ליצור ערכת נושא משלכם](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

### סמלי יישומים

הסמלים במפעיל היישומים ובדוק מצוירים בצבעי ערכת הנושא שלך, כך שהם משתנים יחד איתה. הם מגיעים מסט סמלים, שבוחרים בנפרד מערכת הנושא תחת _מראה > סמלים_, מתוך תצוגות מקדימות של כל סט, בדיוק באותה דרך שבה בוחרים ערכת נושא:

- _Papercraft_ הוא ברירת המחדל: כל מה שמגיע מותקן, מצויר בסגנון אחד. יישומים המוכרים לפי הלוגו שלהם, כמו Chrome, HEY או YouTube, שומרים על הצורה שלהם ומקבלים את צבעי ערכת הנושא.
- _Arcade_ מצייר את אותם יישומים כפיקסל ארט של 8-bit, כמו שקונסולת משחקים ישנה הייתה מציירת.
- _Original_ מציג כל יישום עם הסמל שמי שיצר אותו נתן לו.

אפשר להתקין סט סמלים שמישהו אחר יצר באמצעות _התקנה > סגנון > סמלים_ (או `omarchy icons install <git url>`), ולהסיר אותו שוב תחת _הסרה > סמלים_. _עדכון > סמלים נוספים_ מביא את הגרסה העדכנית ביותר של הסטים שהתקנת.

כדי ליצור סט משלך, שים את הסמלים שלך ב-`~/.config/omarchy/icons/<name>/`, קובץ אחד לכל יישום, בשם לפי שורת ה-`Icon=` של קובץ ה-`.desktop` של היישום. קובץ המסתיים ב-`.svg` מוצג כפי שהוא. קובץ המסתיים ב-`.svg.tpl` מצויר בצבעי ערכת הנושא: כתוב `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` או `{{ icon_shadow }}` במקום שבו צריך להיות צבע. הסט המוגדר כברירת מחדל ב-`/usr/share/omarchy/icons/papercraft/` הוא מקום טוב להתחיל ממנו. הוסף `preview.png` כדי להציג את הסט שלך בבורר; בלעדיו, Omarchy מציירת תצוגה מקדימה מהסמלים שלך. כדי לשנות סמל בודד של סט ברירת המחדל, שים את הגרסה שלך ב-`~/.config/omarchy/icons/papercraft/`.

### ביטולי נעילה

לערכות נושא יכול להיות גם עיצוב ביטול נעילה מותאם אישית, המשמש לתהליך פענוח האתחול. אפשר לבחור אחד מהם תחת _מראה > ביטול נעילה_. הם נראים כך:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
