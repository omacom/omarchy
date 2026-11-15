# ערכות נושא

Omarchy מגיעה עם עשרים ושתיים ערכות נושא יפהפיות. ניתן לבחור ביניהן דרך _Appearance > Theme_ בתפריט של Omarchy (`Super + Space`) או לקפוץ ישירות לבורר ערכות הנושא באמצעות `Super + Ctrl + T`.

כל ערכת נושא מעצבת את שולחן העבודה, הטרמינל, neovim, מסך הפעילות (btop), Chromium, ואת כל מעטפת Omarchy: הסרגל העליון, התפריט, ההתראות, ה-OSD ומסך הנעילה. (עבור Obsidian, יש לבחור ידנית את ערכת הנושא של Omarchy דרך _Appearance > Themes_ בתוך האפליקציה).

לערכות הנושא יש סט של תמונות רקע שניתן לבחור ביניהן באמצעות `Super + Ctrl + W`.

ניתן למצוא עוד ערכות נושא ב[עמוד ערכות הנושא הנוספות](https://omarchy.org/themes/) או אפילו [ליצור ערכת נושא משלכם](43-making-your-own-theme.md).

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

### סמלי אפליקציות

הסמלים במפעיל האפליקציות וב-dock מצוירים בצבעי ערכת הנושא שלכם, כך שהם משתנים יחד איתה. הם מגיעים מסט סמלים, שבוחרים בנפרד מערכת הנושא תחת _Appearance > Icons_:

- _Papercraft_ היא ברירת המחדל: כל מה שמגיע מותקן, מצויר בסגנון אחד. אפליקציות המוכרות לפי הלוגו שלהן, כמו Chrome, HEY או YouTube, שומרות על הצורה שלהן ומקבלות את צבעי ערכת הנושא.
- _Arcade_ מציירת את אותן אפליקציות כאמנות פיקסלים ב-8-bit, כמו שקונסולת משחקים ישנה הייתה עושה.
- _Original_ מציגה כל אפליקציה עם הסמל שיוצרה נתן לה.

ניתן להתקין סט סמלים שמישהו אחר יצר באמצעות _Install > Style > Icons_ (או `omarchy icons install <git url>`), ולהסיר אותו שוב תחת _Remove > Icons_. האפשרות _Update > Extra Icons_ מביאה את הגרסה העדכנית ביותר של הסטים שהתקנתם.

כדי ליצור סט משלכם, שימו את הסמלים שלכם ב-`~/.config/omarchy/icons/<name>/`, קובץ אחד לכל אפליקציה, על שם שורת ה-`Icon=` בקובץ ה-`.desktop` של האפליקציה. קובץ שמסתיים ב-`.svg` מוצג כמות שהוא. קובץ שמסתיים ב-`.svg.tpl` מצויר בצבעי ערכת הנושא: כתבו `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` או `{{ icon_shadow }}` במקום שבו אמור להיות צבע. סט ברירת המחדל ב-`/usr/share/omarchy/icons/papercraft/` הוא מקום טוב להתחיל ממנו. כדי לשנות סמל בודד מסט ברירת המחדל, שימו את הגרסה שלכם ב-`~/.config/omarchy/icons/papercraft/`.

### עיצובי פתיחה

לערכות נושא יכול להיות גם עיצוב פתיחה מותאם אישית, המשמש לתהליך פענוח האתחול. ניתן לבחור אחד מהם תחת _Appearance > Unlock_. כך הם נראים:

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
