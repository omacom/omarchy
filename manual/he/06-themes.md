# ערכות נושא

Omarchy מגיעה עם עשרים ושלוש ערכות נושא יפהפיות. אפשר לבחור ביניהן דרך _Appearance > Theme_ בתפריט של Omarchy (`Super + Space`) או לקפוץ ישירות לבוחר ערכות הנושא באמצעות `Super + Ctrl + T`.

כל ערכת נושא מעצבת את שולחן העבודה, את הטרמינל, את neovim, את מסך הפעילות (btop), את הדפדפן שלך (Chrome, Chromium, Edge או Brave) ואת כל המעטפת של Omarchy: הסרגל העליון, התפריט, ההתראות, ה-OSD ומסך הנעילה. (עבור Obsidian, צריך לבחור ידנית את ערכת הנושא של Omarchy דרך _Appearance > Themes_ בתוך האפליקציה).

לערכות הנושא יש סט של תמונות רקע שאפשר לבחור ביניהן באמצעות `Super + Ctrl + W`.

אפשר למצוא עוד ערכות נושא ב[דף ערכות הנושא הנוספות](https://omarchy.org/themes/) או אפילו [ליצור ערכת נושא משלך](43-making-your-own-theme.md).

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

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### סמלי אפליקציות

הסמלים במפעיל האפליקציות וב-dock מצוירים בצבעי ערכת הנושא שלך, כך שהם משתנים יחד איתה. הם מגיעים מתוך סט סמלים, שבוחרים בנפרד מערכת הנושא תחת _Appearance > Icons_, מתוך תצוגות מקדימות של כל סט, באותו אופן שבו בוחרים ערכת נושא:

- _Papercraft_ היא ברירת המחדל: כל מה שמותקן, מצויר בסגנון אחד. אפליקציות המוכרות לפי הלוגו שלהן, כמו Chrome, HEY או YouTube, שומרות על הצורה שלו ומקבלות את צבעי ערכת הנושא.
- _Arcade_ מציירת את אותן אפליקציות כפיקסל ארט של 8-bit, כמו שקונסולת משחקים ישנה הייתה מציירת.
- _Original_ מציגה כל אפליקציה עם הסמל שהיוצר שלה נתן לה.

אפשר להתקין סט סמלים שמישהו אחר יצר באמצעות _Install > Style > Icons_ (או `omarchy icons install <git url>`), ולהסיר אותו שוב תחת _Remove > Icons_. האפשרות _Update > Extra Icons_ מורידה את הגרסה העדכנית ביותר של הסטים שהתקנת.

כדי ליצור סט משלך, שים את הסמלים שלך ב-`~/.config/omarchy/icons/<name>/`, קובץ אחד לכל אפליקציה, על שם שורת ה-`Icon=` של קובץ ה-`.desktop` של האפליקציה. קובץ המסתיים ב-`.svg` מוצג כפי שהוא. קובץ המסתיים ב-`.svg.tpl` מצויר בצבעי ערכת הנושא: כתוב `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` או `{{ icon_shadow }}` במקום שבו צריך להיות צבע. הסט המוגדר כברירת מחדל ב-`/usr/share/omarchy/icons/papercraft/` הוא מקום טוב להתחיל ממנו. הוסף `preview.png` כדי להציג את הסט שלך בבוחר; בלעדיו, Omarchy מציירת תצוגה מקדימה מהסמלים שלך. כדי לשנות סמל בודד של סט ברירת המחדל, שים את הגרסה שלך ב-`~/.config/omarchy/icons/papercraft/`.

### עיצובי פתיחה

לערכות נושא יכול להיות גם עיצוב פתיחה מותאם אישית, המשמש לתהליך פענוח האתחול. אפשר לבחור אחד מהם תחת _Appearance > Unlock_. כך הם נראים:

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

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

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

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
