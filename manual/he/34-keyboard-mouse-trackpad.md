# מקלדת, עכבר, משטח מגע

Hyprland מאפשרת לך להגדיר את כל אמצעי הקלט שלך בפירוט רב. אתה יכול להפוך את חזרת המקלדת למהירה באופן על-קולי או לגרום למשטח המגע להשתמש בגלילה טבעית. אתה משנה את כל זה ב-`~/.config/hypr/input.lua`, שאליו אתה יכול להגיע גם דרך _הגדרות > קלט_ בתפריט Omarchy (`Super + Space`). כל מה שתגדיר שם מחליף את ברירות המחדל של Omarchy.

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

אתה יכול [לראות את כל אפשרויות הקלט](https://wiki.hypr.land/Configuring/Basics/Variables/#input) בוויקי של Hyprland לקלטים.

CapsLock עובד כ-Caps Lock רגיל, ו-`Shift + CapsLock` הוא מקש ה-compose ל[אימוג'ים מהירים](07-hotkeys.md#quick-emojis) ול[השלמות אחרות](07-hotkeys.md#quick-completions). אם אתה מעדיף שהמקש compose יהיה במקום אחר, החלף את `omarchy:shift_caps_compose` ב-`kb_options`. לדוגמה, זה מעביר את מקש ה-compose ל-Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### מחוות משטח מגע

אתה יכול גם להפעיל [מחוות משטח מגע](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), כמו החלקה בשלוש אצבעות כדי להחליף סביבות עבודה:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

במחשבים ניידים של Dell XPS עם משטח מגע הפטי, אתה יכול גם להגדיר את עוצמת הלחיצה לנמוכה, בינונית או גבוהה תחת _Trigger > Hardware > Touchpad Haptics_.

### הקלדה בסינית, ביפנית ובשפות אחרות

בחר יפנית, קוריאנית, סינית (מפושטת, Pinyin), טאיוואן (Zhuyin) או הונג קונג (Cangjie) כשהמתקין שואל אותך על המקלדת שלך. Omarchy מגדירה את המקלדת ואת מנוע הקלט המתאים באופן אוטומטי, כולל במהלך הגדרת ההפעלה הראשונה הלא מקוונת. יפנית משתמשת ב-Mozc, קוריאנית משתמשת ב-Hangul סטנדרטי בשתי קבוצות, סינית מפושטת משתמשת ב-Pinyin, טאיוואן משתמשת בסידור ה-Zhuyin הסטנדרטי של Chewing, והונג קונג משתמשת ב-Cangjie עם צורות תווים של הונג קונג. יפנית (מקלדת US) מספקת את Mozc עם פריסת מקלדת US. מקשי Hangul, Zhuyin ו-Cangjie נשארים במיקומיהם הסטנדרטיים גם כשאתה מקליד אותיות לטיניות עם Dvorak, Colemak או AZERTY. אם הוספת את Hangul או את Chewing לפני כן, בטל את בחירתן ובחר אותן שוב תחת _הגדרות > הקלדה > שיטות קלט_ כדי להעביר את המקשים שלהן לשם; Omarchy לא נוגעת במנוע שאתה כבר מקליד איתו.

ההקלדה מתחילה במצב לטיני. לחץ על `Super + I` כדי לעבור בין שיטות הקלט שהוגדרו, ועל `Super + Shift + I` כדי לחזור אחורה. הקש על `Shift` לבדו כדי לצאת משיטת קלט כמו Pinyin לאותיות לטיניות, והקש עליו שוב כדי לחזור, כפי ש-Sogou, Microsoft Pinyin ו-macOS עובדות; `Shift` יחד עם אות עדיין מקליד אות גדולה. במקלדות יפניות, 全角/半角 מחליף את הקלט, 変換 מפעיל אותו, ו-無変換 מכבה אותו. עם קוריאנית, 한/영 מחליף את Hangul ו-한자 ממיר ל-Hanja, בין אם למקלדת שלך יש מקשים ייעודיים או שהיא שולחת Right Alt ו-Right Ctrl עבורם, כפי שמחשבים ניידים רבים עושים, ולכן Right Alt ו-Right Ctrl אינם מקשים משנים רגילים שם; הכתבה בלחיצה לדיבור נשארת על F9. `Ctrl + Space` נשאר זמין עבור Tmux ו-Herdr; `Shift + CapsLock` נשאר מקש ה-compose.

מחוון המקלדת מופיע בצד ימין של הסרגל כשיש לך כמה פריסות מקלדת או שיטות קלט. לחץ עליו כדי להחליף שפות קלט; יפנית מציגה あ עבור hiragana. לבחירת תווים יפניים, עבור ליפנית, הקלד מילה כמו `nihongo`, ואז לחץ על Space פעמיים. לחץ על Enter כדי לאשר את בחירתך. אם יש לך גם כמה פריסות מקלדת, לחץ לחיצה ימנית על המחוון כדי לעבור ביניהן.

השתמש ב-_הגדרות > הקלדה > פריסות מקלדת_ כדי לבחור פריסות כמו אנגלית וצרפתית, מאותן בחירות המוצעות במהלך ההתקנה. השתמש ב-_הגדרות > הקלדה > שיטות קלט_ כדי לבחור אילו מנועי הרכבה פעילים. שני הבוררים נפתחים בתוך תפריט Omarchy כשסימון הבחירות הנוכחיות שלך מסומן. לחץ או לחץ על Enter כדי להחליף בחירה; כל שינוי חל מיד. ביטול בחירה של שיטת קלט מסיר אותה מהמחזור בלי להסיר את התקנתה; המקלדת נשארת זמינה.

הרץ את `omarchy setup keyboard` או את `omarchy setup input` כדי לפתוח את אותם בוררים. כדי להוסיף שפה אחת משורת הפקודה, השתמש ב-`omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` או `cangjie5`. Quick, Boshiamy ו-Array מגיעות באותה חבילה כמו Cangjie ומופיעות בבורר שיטות הקלט. מקשי ההחלפה המותאמים אישית שלך נשמרים. לפריסות מנוע או מקשים חלופיים, התקן את `fcitx5-configtool` עם `omarchy pkg add fcitx5-configtool` והפעל אותו ממסוף. בחירת שפת קלט אינה משנה את שפת שולחן העבודה. בחירת יפנית, קוריאנית או סינית תחת _הגדרות > שפה_ מוסיפה את שיטת הקלט שלה כשעדיין אין לך אף אחת.

השתמש ב-`Super + I` כדי לעבור בין שיטות קלט או פריסות מקלדת, ו-`Super + Shift + I` כדי לחזור בכיוון השני, כך שעם שלוש שהוגדרו אתה יכול לנוע בין שתי שכנות. מחוון הקלט מופיע בצד ימין של הסרגל רק כשיותר משיטת קלט או פריסה אחת מוגדרת. קישור שולחן עבודה זה עובד לצד מקשי ההחלפה הקיימים שלך ב-Fcitx; אתה יכול לעקוף אותו ב-`~/.config/hypr/bindings.lua`. מנועי הקלט ורצפי ה-compose משתמשים בשירות [Fcitx5](https://fcitx-im.org/) שכבר פועל בכל הפעלה.

### שימוש ב-ALT כ-SUPER

במקלדות מסוימות, לא נוח להשתמש במקש המטא הראשי (מקש Windows/cmd) כ-SUPER. אתה יכול לשנות זאת ל-ALT במקום זאת באמצעות השינוי הזה:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
