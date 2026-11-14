# מקלדת, עכבר, משטח מגע

Hyprland מאפשר לך להגדיר את כל הקלטים שלך בפירוט רב. אפשר לשנות את חזרת המקלדת כך שתהיה מהירה באופן על-קולי, או לגרום למשטח המגע להשתמש בגלילה טבעית. את כל זה משנים ב-`~/.config/hypr/input.lua`, שאפשר להגיע אליו גם דרך _הגדרות > קלט_ בתפריט Omarchy‏ (`Super + Space`). כל מה שתגדיר שם מחליף את ברירות המחדל של Omarchy.

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

אפשר [לראות את כל אפשרויות הקלט](https://wiki.hypr.land/Configuring/Basics/Variables/#input) בוויקי של Hyprland עבור קלטים.

CapsLock פועל כ-Caps Lock רגיל, ו-`Shift + CapsLock` הוא מקש ה-compose עבור [אמוג'ים מהירים](07-hotkeys.md#quick-emojis) ו[השלמות אחרות](07-hotkeys.md#quick-completions). אם אתה מעדיף שמקש ה-compose יהיה במקום אחר, החלף את `omarchy:shift_caps_compose` ב-`kb_options`. לדוגמה, כך מעבירים את מקש ה-compose ל-Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### מקשי פונקציה

השורה העליונה של מקלדת מחשב נייד שולחת כברירת מחדל את מקשי המדיה (עוצמת קול, בהירות וכן הלאה), והחזקת `Fn` נותנת את F1-F12;‏ `Fn + Esc` נועל זאת בכיוון ההפוך עד שלוחצים עליו שוב. רוב המקלדות זוכרות את הנעילה הזו בעצמן. מחשבים ניידים של ASUS ומקלדות בסגנון Apple משאירים זאת ל-Linux, שמפעיל אותם על מקשי המדיה בכל אתחול. כדי שהם יתחילו במקום זאת על F1-F12, הרץ את `omarchy keyboard toprow fnkeys` (ואת `omarchy keyboard toprow mediakeys` כדי לחזור); בחלק מהמחשבים הניידים זה נכנס לתוקף אחרי אתחול מחדש. מחשבי Mac עם Apple Silicon שומרים על ההגדרה שלהם עצמם.

### מחוות משטח מגע

החלק על משטח המגע כדי לנוע בשולחן העבודה:

| מחווה | פעולה |
| --- | --- |
| שלוש אצבעות שמאלה / ימינה | סביבת העבודה הקודמת / הבאה, כולל ריקות |
| שלוש אצבעות למעלה | החלפת מצב מסוף ה-AI |
| שלוש אצבעות למטה | פתיחת תפריט Omarchy |
| ארבע אצבעות שמאלה / ימינה | העברת החלון הפעיל לסביבת העבודה הקודמת / הבאה |
| ארבע אצבעות למטה | החלפת מצב מסך מלא |

כדי לשנות אחת מהן, בטל אותה ב-`~/.config/hypr/input.lua` לפני הוספת [מחוות משטח מגע](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) משלך, כי Hyprland לא יקבל שתי מחוות על אותן אצבעות ובאותו כיוון:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

כדי לכבות את כל המחוות של Omarchy, הגדר את `omarchy_default_gestures = false` ליד ראש `~/.config/hypr/hyprland.lua`, לפני שברירות המחדל של Omarchy נטענות.

במחשבים ניידים Dell XPS עם משטח מגע הפטי, אפשר גם להגדיר את עוצמת הלחיצה לנמוכה, בינונית או גבוהה תחת _מפעיל > חומרה > הפטיקה של משטח מגע_.

### הקלדה בסינית, יפנית ושפות אחרות

בחר יפנית, קוריאנית, סינית (מפושטת, Pinyin), טאיוואן (Zhuyin) או הונג קונג (Cangjie) כאשר תוכנית ההתקנה שואלת על המקלדת שלך. Omarchy מגדיר את המקלדת ואת מנוע הקלט התואם באופן אוטומטי, כולל במהלך הגדרת האתחול הראשון הלא מקוונת. יפנית משתמשת ב-Mozc, קוריאנית משתמשת ב-Hangul סטנדרטי בשתי מערכות, סינית מפושטת משתמשת ב-Pinyin, טאיוואן משתמשת בסידור Zhuyin הסטנדרטי של Chewing, והונג קונג משתמשת ב-Cangjie עם צורות תווים של הונג קונג. יפנית (מקלדת US) מספקת את Mozc עם פריסת מקלדת US. מקשי Hangul,‏ Zhuyin ו-Cangjie נשארים במיקומיהם הסטנדרטיים גם כשמקלידים אותיות לטיניות עם Dvorak,‏ Colemak או AZERTY. אם הוספת את Hangul או Chewing לפני כן, בטל את בחירתו ובחר אותו מחדש תחת _הגדרות > מקלדת > שיטות קלט_ כדי להעביר את מקשיו לשם; Omarchy משאיר בשקט מנוע שאתה כבר מקליד איתו.

ההקלדה מתחילה במצב לטיני. לחץ על `Super + I` כדי לעבור בין שיטות הקלט שהוגדרו, ועל `Super + Shift + I` כדי לחזור אחורה. הקש על `Shift` בפני עצמו כדי לצאת משיטת קלט כמו Pinyin לאותיות לטיניות, והקש עליו שוב כדי לחזור, כפי ש-Sogou,‏ Microsoft Pinyin ו-macOS עובדים; `Shift` ועוד אות עדיין מקלידים אות גדולה. במקלדות יפניות, 全角/半角 מחליף את מצב הקלט, 変換 מפעיל אותו, ו-無変換 מכבה אותו. עם קוריאנית, 한/영 מחליף את Hangul ו-한자 ממיר ל-Hanja, בין אם למקלדת שלך יש מקשים ייעודיים ובין אם היא שולחת עבורם Right Alt ו-Right Ctrl, כפי שמחשבים ניידים רבים עושים, כך ש-Right Alt ו-Right Ctrl אינם מקשי שינוי רגילים שם; ההכתבה מתחלפת במקום זאת עם Alt + Space.‏ `Ctrl + Space` נשאר זמין עבור Tmux ו-Herdr;‏ `Shift + CapsLock` נשאר מקש ה-compose.

מחוון המקלדת מופיע בצד ימין של הסרגל כאשר יש לך מספר פריסות מקלדת או שיטות קלט. לחץ עליו כדי להחליף שפות קלט; יפנית מציגה あ עבור היראגנה. עבור אפשרויות תווים יפניים, עבור ליפנית, הקלד מילה כמו `nihongo`, ואז לחץ על Space פעמיים. לחץ על Enter כדי לאשר את בחירתך. אם יש לך גם מספר פריסות מקלדת, לחץ בלחצן הימני על המחוון כדי לעבור ביניהן.

השתמש ב-_הגדרות > מקלדת > קלטי מקלדת_ כדי לבחור פריסות כמו אנגלית וצרפתית, מאותן אפשרויות המוצעות במהלך ההתקנה. השתמש ב-_הגדרות > מקלדת > שיטות קלט_ כדי לבחור אילו מנועי הרכבה פעילים. שני הבוררים נפתחים בתוך תפריט Omarchy כאשר הבחירות הנוכחיות שלך מסומנות. לחץ או לחץ על Enter כדי להחליף בחירה; כל שינוי חל מיד. ביטול בחירה של שיטת קלט מסיר אותה מהמחזור בלי להסיר את התקנתה; המקלדת נשארת זמינה.

הרץ את `omarchy setup keyboard` או `omarchy setup input` כדי לפתוח את אותם בוררים. כדי להוסיף שפה אחת משורת הפקודה, השתמש ב-`omarchy setup input mozc`,‏ `hangul`,‏ `pinyin`,‏ `chewing` או `cangjie5`.‏ Quick,‏ Boshiamy ו-Array מגיעים באותה חבילה כמו Cangjie ומופיעים בבורר שיטות הקלט. מקשי ההחלפה המותאמים אישית שלך נשמרים. עבור פריסות או מקשים חלופיים של מנוע, התקן את `fcitx5-configtool` עם `omarchy pkg add fcitx5-configtool` והפעל אותו ממסוף. בחירת שפת קלט אינה משנה את שפת שולחן העבודה. בחירת יפנית, קוריאנית או סינית תחת _הגדרות > שפה_ מוסיפה את שיטת הקלט שלה כאשר אין לך עדיין אף אחת.

השתמש ב-`Super + I` כדי לעבור בין שיטות קלט או פריסות מקלדת, וב-`Super + Shift + I` כדי לחזור בכיוון השני, כך שעם שלוש מוגדרות תוכל לנוע בין שני שכנים. מחוון הקלט מופיע בצד ימין של הסרגל רק כאשר מוגדרת יותר משיטת קלט או פריסה אחת. קיצור שולחן עבודה זה עובד לצד מקשי ההחלפה הקיימים של Fcitx; אפשר לעקוף אותו ב-`~/.config/hypr/bindings.lua`. מנועי הקלט ורצפי ה-compose משתמשים בשירות [Fcitx5](https://fcitx-im.org/) שכבר פועל בכל הפעלה.

### שימוש ב-ALT בתור SUPER

בחלק מהמקלדות, לא נוח להשתמש במקש המטא הראשי (מקש Windows/cmd) בתור SUPER. אפשר לשנות זאת ל-ALT במקום זאת באמצעות שינוי זה:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
