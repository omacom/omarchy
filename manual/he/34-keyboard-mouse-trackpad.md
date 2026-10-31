# מקלדת, עכבר, משטח מגע

Hyprland מאפשר לך להגדיר את כל אמצעי הקלט שלך בפירוט רב. אפשר לשנות את חזרת המקלדת כך שתהיה מהירה בצורה על-קולית, או לגרום למשטח המגע להשתמש בגלילה טבעית. את כל זה משנים ב-`~/.config/hypr/input.lua`, שאפשר להגיע אליו גם דרך _הגדרות > קלט_ בתפריט Omarchy (`Super + Space`). כל מה שתגדיר שם מחליף את ברירות המחדל של Omarchy.

הנה דוגמה:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

אפשר [לראות את כל אפשרויות הקלט](https://wiki.hypr.land/Configuring/Basics/Variables/#input) בוויקי של Hyprland בנושא קלט.

CapsLock עובד כ-Caps Lock רגיל, ו-`Shift + CapsLock` הוא מקש ה-compose עבור [אימוג'ים מהירים](07-hotkeys.md#quick-emojis) ו[השלמות אחרות](07-hotkeys.md#quick-completions). אם אתה מעדיף את מקש ה-compose במקום אחר, החלף את `omarchy:shift_caps_compose` ב-`kb_options`. לדוגמה, כך מעבירים את מקש ה-compose אל Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### מחוות משטח מגע

החלק על משטח המגע כדי לנוע ברחבי שולחן העבודה:

| מחווה | פעולה |
| --- | --- |
| שלוש אצבעות שמאלה / ימינה | סביבת העבודה הקודמת / הבאה, כולל ריקות |
| שלוש אצבעות למעלה | הצגה/הסתרה של קונסולת ה-AI |
| שלוש אצבעות למטה | פתיחת תפריט Omarchy |
| ארבע אצבעות שמאלה / ימינה | העברת החלון הפעיל לסביבת העבודה הקודמת / הבאה |
| ארבע אצבעות למטה | הצגה/הסתרה של מסך מלא |

כדי לשנות אחת מהן, בטל אותה ב-`~/.config/hypr/input.lua` לפני שתוסיף [מחוות משטח מגע](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) משלך, כי Hyprland לא יקבל שתי מחוות על אותן אצבעות ובאותו כיוון:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

כדי לכבות את כל המחוות של Omarchy, הגדר `omarchy_default_gestures = false` קרוב לראש `~/.config/hypr/hyprland.lua`, לפני שברירות המחדל של Omarchy נטענות.

במחשבים ניידים מדגם Dell XPS עם משטח מגע הפטי, אפשר גם להגדיר את עוצמת הלחיצה לנמוכה, בינונית או גבוהה תחת _הפעלה > חומרה > הפטיקת משטח מגע_.

### הקלדה בסינית, ביפנית ובשפות אחרות

בחר יפנית, קוריאנית, סינית (מפושטת, Pinyin), טאיוואן (Zhuyin) או הונג קונג (Cangjie) כשהמתקין שואל על המקלדת שלך. Omarchy מגדיר את המקלדת ואת מנוע הקלט המתאים באופן אוטומטי, כולל במהלך הגדרת האתחול הראשון במצב לא מקוון. יפנית משתמשת ב-Mozc, קוריאנית משתמשת ב-Hangul סטנדרטי בשיטת שני הסטים, סינית מפושטת משתמשת ב-Pinyin, טאיוואן משתמשת בסידור ה-Zhuyin הסטנדרטי של Chewing, והונג קונג משתמשת ב-Cangjie עם צורות תווים של הונג קונג. יפנית (מקלדת US) מספקת את Mozc עם פריסת מקלדת US. מקשי Hangul, Zhuyin ו-Cangjie נשארים במיקומיהם הסטנדרטיים גם כשמקלידים אותיות לטיניות עם Dvorak, Colemak או AZERTY. אם הוספת את Hangul או את Chewing לפני כן, בטל את הבחירה בהם ובחר בהם שוב תחת _הגדרות > הקלדה > שיטות קלט_ כדי להעביר את המקשים שלהם לשם; Omarchy משאיר בשקט מנוע שכבר מקלידים איתו.

ההקלדה מתחילה במצב לטיני. לחץ על `Super + I` כדי לעבור בין שיטות הקלט שהוגדרו, ועל `Super + Shift + I` כדי לעבור אחורה. הקש על `Shift` בפני עצמו כדי לצאת משיטת קלט כמו Pinyin אל אותיות לטיניות, והקש עליו שוב כדי לחזור, כמו ש-Sogou, Microsoft Pinyin ו-macOS עובדים; `Shift` יחד עם אות עדיין מקליד אות גדולה. במקלדות יפניות, 全角/半角 מחליף את מצב הקלט, 変換 מפעיל אותו, ו-無変換 מכבה אותו. עם קוריאנית, 한/영 מחליף את Hangul ו-한자 ממיר ל-Hanja, בין אם למקלדת שלך יש מקשים ייעודיים ובין אם היא שולחת עבורם Right Alt ו-Right Ctrl, כפי שמחשבים ניידים רבים עושים, כך ש-Right Alt ו-Right Ctrl אינם מקשי שינוי רגילים שם; ההכתבה מתחלפת עם Alt + Space במקום זאת. `Ctrl + Space` נשאר זמין עבור Tmux ו-Herdr; `Shift + CapsLock` נשאר מקש ה-compose.

מחוון המקלדת מופיע בצד ימין של הסרגל כשיש לך כמה פריסות מקלדת או שיטות קלט. לחץ עליו כדי להחליף שפות קלט; יפנית מציגה あ עבור hiragana. עבור אפשרויות תווים ביפנית, עבור ליפנית, הקלד מילה כמו `nihongo`, ואז לחץ על Space פעמיים. לחץ על Enter כדי לאשר את הבחירה שלך. אם יש לך גם כמה פריסות מקלדת, לחץ לחיצה ימנית על המחוון כדי לעבור ביניהן.

השתמש ב-_הגדרות > הקלדה > פריסות מקלדת_ כדי לבחור פריסות כמו אנגלית וצרפתית, מאותן אפשרויות שמוצעות במהלך ההתקנה. השתמש ב-_הגדרות > הקלדה > שיטות קלט_ כדי לבחור אילו מנועי הרכבה פעילים. שני הבוררים נפתחים בתוך תפריט Omarchy כשהבחירות הנוכחיות שלך מסומנות. לחץ או לחץ על Enter כדי להחליף בחירה; כל שינוי חל מיד. ביטול הבחירה בשיטת קלט מסיר אותה מהמחזור בלי להסיר את התקנתה; המקלדת נשארת זמינה.

הפעל את `omarchy setup keyboard` או את `omarchy setup input` כדי לפתוח את אותם בוררים. כדי להוסיף שפה אחת משורת הפקודה, השתמש ב-`omarchy setup input mozc`, ב-`hangul`, ב-`pinyin`, ב-`chewing` או ב-`cangjie5`. Quick, Boshiamy ו-Array מגיעים באותה חבילה כמו Cangjie ומופיעים בבורר שיטות הקלט. מקשי ההחלפה המותאמים אישית שלך נשמרים. עבור פריסות או מקשים חלופיים למנוע, התקן את `fcitx5-configtool` עם `omarchy pkg add fcitx5-configtool` והפעל אותו ממסוף. בחירת שפת קלט אינה משנה את שפת שולחן העבודה. בחירת יפנית, קוריאנית או סינית תחת _הגדרות > שפה_ מוסיפה את שיטת הקלט שלה כשאין לך עדיין אף אחת.

השתמש ב-`Super + I` כדי לעבור בין שיטות קלט או פריסות מקלדת, וב-`Super + Shift + I` כדי לחזור בכיוון השני, כך שעם שלוש מוגדרות אפשר לנוע בין שני שכנים. מחוון הקלט מופיע בצד ימין של הסרגל רק כשמוגדרת יותר משיטת קלט או פריסה אחת. קיצור שולחן עבודה זה עובד לצד מקשי ההחלפה הקיימים שלך ב-Fcitx; אפשר לעקוף אותו ב-`~/.config/hypr/bindings.lua`. מנועי הקלט ורצפי ה-compose משתמשים בשירות [Fcitx5](https://fcitx-im.org/) שכבר פועל בכל הפעלה.

### שימוש ב-ALT כ-SUPER

במקלדות מסוימות, לא נוח להשתמש במקש ה-meta הראשי (מקש Windows/cmd) כ-SUPER. אפשר לשנות זאת כך שיהיה ALT במקום זאת באמצעות השינוי הזה:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
