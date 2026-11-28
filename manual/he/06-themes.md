# ערכות נושא

Omarchy מגיעה עם עשרים ושלוש ערכות נושא יפהפיות. ניתן לבחור ביניהן דרך _מראה > ערכת נושא_ בתפריט של Omarchy (`Super + Space`) או לקפוץ ישירות לבורר ערכות הנושא עם `Super + Ctrl + T`.

כל ערכת נושא מעצבת את שולחן העבודה, המסוף, neovim, מסך הפעילות (btop), הדפדפן שלכם (Chrome, Chromium, Edge או Brave), ואת כל מעטפת Omarchy: השורה העליונה, התפריט, ההתראות, ה‑OSD ומסך הנעילה. (ב‑Obsidian, עליכם לבחור ידנית את ערכת הנושא של Omarchy דרך _מראה > ערכות נושא_ בתוך האפליקציה).

לערכות הנושא יש אוסף של תמונות רקע שתוכלו לבחור ביניהן עם `Super + Ctrl + W`.

תוכלו למצוא עוד ערכות נושא ב[דף ערכות הנושא הנוספות](https://omarchy.org/themes/) או אפילו [ליצור ערכת נושא משלכם](43-making-your-own-theme.md).

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

הסמלים במפעיל האפליקציות וב‑dock מצוירים בצבעי ערכת הנושא שלכם, כך שהם משתנים יחד איתה. הם מגיעים מערכת סמלים, שאותה בוחרים בנפרד מערכת הנושא תחת _מראה > סמלים_, מתוך תצוגות מקדימות של כל ערכה, באותה דרך שבה בוחרים ערכת נושא:

- _Papercraft_ היא ברירת המחדל: כל מה שמגיע מותקן, מצויר בסגנון אחד. אפליקציות המוכרות לפי הלוגו שלהן, כמו Chrome, HEY או YouTube, שומרות על הצורה שלהן ומקבלות את צבעי ערכת הנושא.
- _Arcade_ מציירת את אותן אפליקציות כפיקסל ארט של 8-bit, כמו שקונסולת משחקים ישנה הייתה מציירת.
- _Original_ מציגה כל אפליקציה עם הסמל שיוצרה נתן לה.

תוכלו להתקין ערכת סמלים שמישהו אחר יצר עם _התקנה > סגנון > סמלים_ (או `omarchy icons install <git url>`), ולהסיר אותה שוב תחת _הסרה > סמלים_. _עדכון > סמלים נוספים_ מביא את הגרסה העדכנית ביותר של הערכות שהתקנתם.

כדי ליצור ערכה משלכם, שימו את הסמלים שלכם ב‑`~/.config/omarchy/icons/<name>/`, קובץ אחד לכל אפליקציה, בשם התואם את שורת ה‑`Icon=` של קובץ ה‑`.desktop` של האפליקציה. קובץ המסתיים ב‑`.svg` מוצג כמות שהוא. קובץ המסתיים ב‑`.svg.tpl` מצויר בצבעי ערכת הנושא: כתבו `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` או `{{ icon_shadow }}` במקום שבו צריך להיות צבע. ערכת ברירת המחדל ב‑`/usr/share/omarchy/icons/papercraft/` היא מקום טוב להתחיל ממנו. הוסיפו `preview.png` כדי להציג את הערכה שלכם בבורר; בלעדיו, Omarchy תצייר תצוגה מקדימה מהסמלים שלכם. כדי לשנות סמל בודד של ערכת ברירת המחדל, שימו את הגרסה שלכם ב‑`~/.config/omarchy/icons/papercraft/`.

### אתחול והתחברות

המסך שמבקש את סיסמת הכונן שלכם כשהמחשב מופעל, ומסך ההתחברות, הולכים גם הם אחרי ערכת הנושא. בכל פעם שאתם מחליפים ערכות נושא, הם מקבלים את הרקע, הטקסט, צבע ההדגשה והצבעים האדומים שלה, כך שאין עיצוב נעילה נפרד שצריך לבחור. במחשבי Apple Silicon Macs, מסך סיסמת הכונן שומר על המראה הדיפולטיבי של Omarchy בכל ערכת נושא.
