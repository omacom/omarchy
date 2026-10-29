# מקלדת, עכבר ומשטח מגע

Hyprland מאפשר לך להגדיר את כל הקלטים שלך בפירוט רב. אתה יכול להפוך את חזרת המקשים למהירה בצורה על־קולית או לגרום למשטח המגע להשתמש בגלילה טבעית. אתה משנה את כל זה ב-`~/.config/hypr/input.lua`, שאליו אתה יכול גם להגיע דרך _הגדרה > קלט_ בתפריט Omarchy‏ (`Super + Space`). כל מה שתגדיר שם מחליף את ברירות המחדל של Omarchy.

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

אתה יכול [לראות את כל אפשרויות הקלט](https://wiki.hypr.land/Configuring/Basics/Variables/#input) בוויקי של Hyprland עבור קלטים.

CapsLock עובד כ-Caps Lock רגיל, ו-`Shift + CapsLock` הוא מקש ה-compose עבור [אמוג'ים מהירים](07-hotkeys.md#quick-emojis) ו[השלמות מהירות אחרות](07-hotkeys.md#quick-completions). אם אתה מעדיף את מקש ה-compose במקום אחר, החלף את `omarchy:shift_caps_compose` ב-`kb_options`. לדוגמה, זה מעביר את מקש ה-compose ל-Right Alt:

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
| שלוש אצבעות למעלה | החלפת מצב של קונסולת ה-AI |
| שלוש אצבעות למטה | פתיחת תפריט Omarchy |
| ארבע אצבעות שמאלה / ימינה | העברת החלון הפעיל לסביבת העבודה הקודמת / הבאה |
| ארבע אצבעות למטה | החלפת מצב מסך מלא |

כדי לשנות אחת מהן, בטל אותה ב-`~/.config/hypr/input.lua` לפני הוספת [מחוות משטח המגע](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) משלך, כי Hyprland לא יקבל שתי מחוות על אותן אצבעות ואותו כיוון:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

כדי לכבות את כל מחוות Omarchy, הגדר את `omarchy_default_gestures = false` ליד החלק העליון של `~/.config/hypr/hyprland.lua`, לפני שברירות המחדל של Omarchy נטענות.

במחשבים ניידים של Dell XPS עם משטח מגע הפטי, אתה יכול גם להגדיר את עוצמת הלחיצה לנמוכה, בינונית או גבוהה תחת _Trigger > חומרה > Touchpad Haptics_.

### הקלדה בסינית, ביפנית ובשפות אחרות

בחר יפנית, קוריאנית, סינית (פשוטה, Pinyin), טאיוואן (Zhuyin) או הונג קונג (Cangjie) כשהמתקין שואל על המקלדת שלך. Omarchy מגדיר את המקלדת ומנוע הקלט התואם באופן אוטומטי, כולל במהלך ההגדרה הראשונה במצב לא מקוון. יפנית משתמשת ב-Mozc, קוריאנית משתמשת ב-Hangul סטנדרטי בשתי מערכות, סינית פשוטה משתמשת ב-Pinyin, טאיוואן משתמשת בסידור Zhuyin סטנדרטי של Chewing, והונג קונג משתמשת ב-Cangjie עם צורות תווים של הונג קונג. יפנית (מקלדת US) מספקת את Mozc עם פריסת מקלדת US. מקשי Hangul, ‏Zhuyin ו-Cangjie נשארים במיקומים הסטנדרטיים שלהם גם כשאתה מקליד אותיות לטיניות עם Dvorak, ‏Colemak או AZERTY. אם הוספת Hangul או Chewing לפני כן, בטל את בחירתן ובחר בהן שוב תחת _הגדרה > הקלדה > שיטות קלט_ כדי להעביר את המקשים שלהן לשם; Omarchy לא נוגע במנוע שאתה כבר מקליד איתו.

ההקלדה מתחילה במצב לטיני. הקש `Super + I` כדי לעבור בין שיטות הקלט שהוגדרו, ו-`Super + Shift + I` כדי לעבור בכיוון ההפוך. הקש על `Shift` לבדו כדי לצאת משיטת קלט כמו Pinyin לאותיות לטיניות, והקש עליו שוב כדי לחזור, כמו ש-Sogou, ‏Microsoft Pinyin ו-macOS עובדים; `Shift` יחד עם אות עדיין מקליד אות גדולה. במקלדות יפניות, 全角/半角 מחליף את הקלט, 変換 מפעיל אותו, ו-無変換 מכבה אותו. עם קוריאנית, 한/영 מחליף את Hangul ו-한자 ממיר ל-Hanja, בין אם למקלדת שלך יש מקשים ייעודיים ובין אם היא שולחת Right Alt ו-Right Ctrl עבורם, כפי שמחשבים ניידים רבים עושים, כך ש-Right Alt ו-Right Ctrl אינם מקשי שינוי רגילים שם; הכתבה בלחיצה והחזקה נשארת על F9. ‏`Ctrl + Space` נשאר זמין עבור Tmux ו-Herdr;‏ `Shift + CapsLock` נשאר מקש ה-compose.

מחוון המקלדת מופיע בצד ימין של הסרגל כשיש לך כמה פריסות מקלדת או שיטות קלט. לחץ עליו כדי להחליף שפות קלט; יפנית מציגה あ עבור היראגנה. עבור בחירות תווים ביפנית, עבור ליפנית, הקלד מילה כמו `nihongo`, ואז הקש Space פעמיים. הקש Enter כדי לאשר את הבחירה שלך. אם יש לך גם כמה פריסות מקלדת, לחץ לחיצה ימנית על המחוון כדי לעבור ביניהן.

השתמש ב-_הגדרה > הקלדה > פריסות מקלדת_ כדי לבחור פריסות כמו אנגלית וצרפתית, מאותן בחירות שמוצעות במהלך ההתקנה. השתמש ב-_הגדרה > הקלדה > שיטות קלט_ כדי לבחור אילו מנועי הרכבה פעילים. שני הבוררים נפתחים בתוך תפריט Omarchy כשסימון על הבחירות הנוכחיות שלך. לחץ או הקש Enter כדי להחליף בחירה; כל שינוי חל מיד. ביטול בחירת שיטת קלט מסיר אותה מהמעגל מבלי להסיר את התקנתה; המקלדת נשארת זמינה.

הרץ `omarchy setup keyboard` או `omarchy setup input` כדי לפתוח את אותם בוררים. כדי להוסיף שפה אחת משורת הפקודה, השתמש ב-`omarchy setup input mozc`, ‏`hangul`, ‏`pinyin`, ‏`chewing` או `cangjie5`. ‏Quick, ‏Boshiamy ו-Array מגיעים באותה חבילה כמו Cangjie ומופיעים בבורר שיטות הקלט. מקשי ההחלפה המותאמים אישית שלך נשמרים. עבור פריסות או מקשי מנוע חלופיים, התקן את `fcitx5-configtool` עם `omarchy pkg add fcitx5-configtool` והפעל אותו ממסוף. בחירת שפת קלט אינה משנה את שפת שולחן העבודה. בחירת יפנית, קוריאנית או סינית תחת _הגדרה > שפה_ מוסיפה את שיטת הקלט שלה כשעדיין אין לך אף אחת.

השתמש ב-`Super + I` כדי לעבור בין שיטות קלט או פריסות מקלדת, וב-`Super + Shift + I` כדי לחזור בכיוון השני, כך שעם שלוש שהוגדרו אתה יכול לנוע בין שני שכנים. מחוון הקלט מופיע בצד ימין של הסרגל רק כשיותר משיטת קלט או פריסה אחת מוגדרת. קישור שולחן עבודה זה עובד לצד מקשי ההחלפה הקיימים של Fcitx; אתה יכול לעקוף אותו ב-`~/.config/hypr/bindings.lua`. מנועי הקלט ורצפי ה-compose משתמשים בשירות [Fcitx5](https://fcitx-im.org/) שכבר רץ בכל הפעלה.

### שימוש ב-ALT כ-SUPER

במקלדות מסוימות, לא נוח להשתמש במקש המטא העיקרי (מקש Windows/cmd) כ-SUPER. אתה יכול לשנות זאת ל-ALT במקום זאת באמצעות שינוי זה:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
