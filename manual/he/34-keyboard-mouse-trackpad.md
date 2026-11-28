# מקלדת, עכבר, משטח מגע

Hyprland מאפשר לך להגדיר את כל אמצעי הקלט שלך בפירוט רב. אפשר לשנות את חזרת המקלדת כך שתהיה מהירה על-קולית, או לגרום למשטח המגע להשתמש בגלילה טבעית. את כל זה משנים ב-`~/.config/hypr/input.lua`, שאפשר להגיע אליו גם דרך _Setup > Input_ בתפריט Omarchy (`Super + Space`). כל מה שתגדיר שם מחליף את ברירות המחדל של Omarchy.

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

אפשר [לראות את כל אפשרויות הקלט](https://wiki.hypr.land/Configuring/Basics/Variables/#input) בוויקי של Hyprland לקלט.

CapsLock פועל כ-Caps Lock רגיל, ו-`Shift + CapsLock` הוא מקש ה-compose עבור [אימוג'ים מהירים](07-hotkeys.md#quick-emojis) ו[השלמות אחרות](07-hotkeys.md#quick-completions). אם אתה מעדיף שהמקש ה-compose יהיה במקום אחר, החלף את `omarchy:shift_caps_compose` בתוך `kb_options`. לדוגמה, זה מעביר את מקש ה-compose ל-Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### מקשי פונקציה

השורה העליונה במקלדת של מחשב נייד שולחת כברירת מחדל את מקשי המדיה (עוצמת קול, בהירות וכן הלאה), והחזקת `Fn` נותנת F1-F12; `Fn + Esc` נועל את זה בכיוון ההפוך עד שלוחצים עליו שוב. רוב המקלדות זוכרות את הנעילה הזו בעצמן. מחשבים ניידים של ASUS ומקלדות בסגנון Apple משאירים את זה ל-Linux, שמפעיל אותם על מקשי המדיה בכל אתחול. כדי שהם יתחילו על F1-F12 במקום זאת, הרץ את `omarchy device keyboard toprow fnkeys` (ואת `omarchy device keyboard toprow mediakeys` כדי לחזור); בחלק מהמחשבים הניידים זה נכנס לתוקף אחרי אתחול מחדש. מחשבי Apple Silicon Macs שומרים את ההגדרה שלהם.

### מחוות משטח מגע

החלק על משטח המגע כדי לנוע ברחבי שולחן העבודה:

| מחווה | פעולה |
| --- | --- |
| שלוש אצבעות שמאלה / ימינה | סביבת העבודה הקודמת / הבאה, כולל ריקות |
| שלוש אצבעות למעלה | החלפת מצב של מסוף ה-AI |
| שלוש אצבעות למטה | פתיחת תפריט Omarchy |
| ארבע אצבעות שמאלה / ימינה | העברת החלון הפעיל לסביבת העבודה הקודמת / הבאה |
| ארבע אצבעות למטה | החלפת מצב של מסך מלא |

כדי לשנות אחת מהן, בטל אותה ב-`~/.config/hypr/input.lua` לפני הוספת [מחוות משטח מגע](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) משלך, כי Hyprland לא יקבל שתי מחוות על אותו מספר אצבעות ואותו כיוון:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

כדי לכבות את כל המחוות של Omarchy, הגדר `omarchy_default_gestures = false` ליד החלק העליון של `~/.config/hypr/hyprland.lua`, לפני שברירות המחדל של Omarchy נטענות.

במחשבים ניידים Dell XPS עם משטח מגע הפטי, אפשר גם להגדיר את עוצמת הלחיצה לנמוכה, בינונית או גבוהה תחת _Trigger > Hardware > Touchpad Haptics_.

### הקלדה בסינית, ביפנית ובשפות אחרות

בחר יפנית, קוריאנית, סינית (מפושטת, Pinyin), טייוואן (Zhuyin) או הונג קונג (Cangjie) כאשר המתקין שואל על המקלדת שלך. Omarchy מגדיר את המקלדת ואת מנוע הקלט התואם באופן אוטומטי, כולל במהלך ההגדרה הלא מקוונת בהפעלה הראשונה. היפנית משתמשת ב-Mozc, הקוריאנית משתמשת ב-Hangul סטנדרטי של שני סטים, הסינית המפושטת משתמשת ב-Pinyin, טייוואן משתמשת בסידור ה-Zhuyin הסטנדרטי של Chewing, והונג קונג משתמשת ב-Cangjie עם צורות תווים של הונג קונג. יפנית (מקלדת US) מספקת את Mozc עם פריסת מקלדת US. מקשי Hangul, Zhuyin ו-Cangjie נשארים במקומותיהם הסטנדרטיים גם כאשר מקלידים אותיות לטיניות עם Dvorak, Colemak או AZERTY. אם הוספת את Hangul או Chewing לפני כן, בטל את בחירתו ובחר אותו מחדש תחת _Setup > Keyboard > Input Methods_ כדי להעביר את המקשים שלו לשם; Omarchy משאיר בשקט מנוע שאתה כבר מקליד איתו.

ההקלדה מתחילה במצב לטיני. לחץ על `Super + I` כדי לעבור בין שיטות הקלט המוגדרות, ועל `Super + Shift + I` כדי לעבור חזרה. הקש על `Shift` בפני עצמו כדי לצאת משיטת קלט כמו Pinyin לאותיות לטיניות, והקש עליו שוב כדי לחזור, כמו ש-Sogou, Microsoft Pinyin ו-macOS עובדים; `Shift` ועוד אות עדיין מקלידים אות גדולה. במקלדות יפניות, 全角/半角 מחליף את מצב הקלט, 変換 מפעיל אותו, ו-無変換 מכבה אותו. עם קוריאנית, 한/영 מחליף את Hangul ו-한자 ממיר ל-Hanja, בין אם למקלדת שלך יש מקשים ייעודיים או שהיא שולחת עבורם Right Alt ו-Right Ctrl, כפי שמחשבים ניידים רבים עושים, כך ש-Right Alt ו-Right Ctrl אינם שם מקשי שינוי רגילים; ההכתבה מתחלפת עם Alt + Space במקום זאת. `Ctrl + Space` נשאר זמין עבור Tmux ו-Herdr; `Shift + CapsLock` נשאר מקש ה-compose.

מחוון המקלדת מופיע בצד ימין של הסרגל כאשר יש לך כמה פריסות מקלדת או שיטות קלט. לחץ עליו כדי להחליף שפות קלט; היפנית מציגה あ עבור hiragana. עבור בחירת תווים ביפנית, עבור ליפנית, הקלד מילה כמו `nihongo`, ואז לחץ פעמיים על Space. לחץ על Enter כדי לאשר את הבחירה שלך. אם יש לך גם כמה פריסות מקלדת, לחץ לחיצה ימנית על המחוון כדי לעבור ביניהן.

השתמש ב-_Setup > Keyboard > Keyboard Inputs_ כדי לבחור פריסות כמו אנגלית וצרפתית, מאותן בחירות שמציעים במהלך ההתקנה. השתמש ב-_Setup > Keyboard > Input Methods_ כדי לבחור אילו מנועי הרכבה פעילים. שני הבוחרים נפתחים בתוך תפריט Omarchy כאשר הבחירות הנוכחיות שלך מסומנות. לחץ או לחץ על Enter כדי להחליף את מצב הבחירה; כל שינוי חל מיד. ביטול בחירה של שיטת קלט מסיר אותה מהמעגל מבלי להסיר את ההתקנה שלה; המקלדת נשארת זמינה.

הרץ את `omarchy setup keyboard` או את `omarchy setup input` כדי לפתוח את אותם בוחרים. כדי להוסיף שפה אחת משורת הפקודה, השתמש ב-`omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` או `cangjie5`. Quick, Boshiamy ו-Array מגיעים באותה חבילה כמו Cangjie ומופיעים בבוחר Input Methods. מקשי ההחלפה המותאמים אישית שלך נשמרים. עבור פריסות או מקשים חלופיים של מנוע, התקן את `fcitx5-configtool` עם `omarchy pkg add fcitx5-configtool` והפעל אותו מטרמינל. בחירת שפת קלט אינה משנה את שפת שולחן העבודה. בחירת יפנית, קוריאנית או סינית תחת _Setup > Region > Language_ מוסיפה את שיטת הקלט שלה כאשר אין לך עדיין אף אחת.

השתמש ב-`Super + I` כדי לעבור בין שיטות קלט או פריסות מקלדת, וב-`Super + Shift + I` כדי לחזור בכיוון ההפוך, כך שעם שלוש מוגדרות אפשר לנוע בין שני שכנים. מחוון הקלט מופיע בצד ימין של הסרגל רק כאשר מוגדרת יותר משיטת קלט או פריסה אחת. קישור שולחן עבודה זה עובד לצד מקשי ההחלפה הקיימים של Fcitx; אפשר לעקוף אותו ב-`~/.config/hypr/bindings.lua`. מנועי הקלט ורצפי ה-compose משתמשים בשירות [Fcitx5](https://fcitx-im.org/) שכבר רץ בכל הפעלה.

### שימוש ב-ALT כ-SUPER

בחלק מהמקלדות, לא נוח להשתמש במקש ה-meta הראשי (מקש Windows/cmd) בתור SUPER. אפשר לשנות זאת ל-ALT במקום זאת בעזרת השינוי הזה:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
