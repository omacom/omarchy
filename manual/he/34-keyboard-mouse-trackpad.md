# מקלדת, עכבר, משטח מגע

Hyprland מאפשרת לכם להגדיר את כל הקלטים שלכם בפרוט רב. תוכלו לשנות את חזרת המקלדת שתהיה מהירה על-קולית או לגרום למשטח המגע להשתמש בגלילה טבעית. אתם משנים את הכול ב-`~/.config/hypr/input.lua`, שאליו תוכלו להגיע גם דרך _הגדרה > קלט_ בתפריט Omarchy (`Super + Space`). כל מה שתגדירו שם מחליף את ברירות המחדל של Omarchy.

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

תוכלו [לראות את כל אפשרויות הקלט](https://wiki.hypr.land/Configuring/Basics/Variables/#input) בוויקי של Hyprland עבור קלטים.

CapsLock עובד כ-Caps Lock רגיל, ו-`Shift + CapsLock` הוא מקש ההרכבה עבור [אימוג'י מהירים](07-hotkeys.md#quick-emojis) ו[השלמות אחרות](07-hotkeys.md#quick-completions). אם תעדיפו שמקש ההרכבה יהיה במקום אחר, החליפו את `omarchy:shift_caps_compose` ב-`kb_options`. לדוגמה, זה מעביר את מקש ההרכבה ל-Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### מחוות משטח מגע

תוכלו גם להפעיל [מחוות משטח מגע](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), כמו החלקה בשלוש אצבעות כדי לשנות סביבות עבודה:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

על מחשבי Dell XPS ניידים עם משטח מגע הפטי, תוכלו גם להגדיר את עוצמת הלחיצה לנמוך, בינוני, או גבוה תחת _הפעלה > חומרה > רטט משטח מגע_.

### הקלדה בסינית, יפנית ושפות אחרות

בחרו יפנית, קוריאנית, סינית (מפושטת, פין-יין), או סינית (מסורתית, ג'ו-יין) כאשר המתקין שואל על המקלדת שלכם. Omarchy מגדירה את המקלדת ומנוע הקלט התואם באופן אוטומטי, כולל במהלך הגדרת האתחול הראשון הלא מקוונת. יפנית משתמשת ב-Mozc, קוריאנית משתמשת בהנגול סטנדרטי דו-ערכתי, סינית מפושטת משתמשת בפין-יין, וסינית מסורתית משתמשת בסידור ג'ו-יין הסטנדרטי של Chewing. יפנית (מקלדת US) מספקת Mozc עם פריסת מקלדת US.

הקלדה מתחילה במצב לטיני. לחצו על `Super + I` כדי לעבור בין שיטות קלט מוגדרות, ועל `Super + Shift + I` כדי לחזור אחורה. הקישו על `Shift` לבדו כדי לצאת משיטת קלט כמו פין-יין לאותיות לטיניות, והקישו עליו שוב כדי לחזור, כפי ש-Sogou, Microsoft Pinyin ו-macOS עובדים; `Shift` בתוספת אות עדיין מקליד אות גדולה. על מקלדות יפניות, 全角/半角 מחליף קלט, 変換 מפעיל אותו, ו-無変換 מכבה אותו. על פריסת מקלדת קוריאנית, מקשי 한/영 ו-한자 ייעודיים מחליפים הנגול וממירים להנג'ה. `Ctrl + Space` נשאר זמין עבור Tmux ו-Herdr; `Shift + CapsLock` נשאר מקש ההרכבה.

מחוון המקלדת מופיע מימין לשורה כשיש לכם פריסות מקלדת או שיטות קלט מרובות. לחצו עליו כדי להחליף שפות קלט; יפנית מציגה あ עבור היראגאנה. עבור בחירות תווים יפניים, עברו ליפנית, הקלידו מילה כמו `nihongo`, ולאחר מכן לחצו על Space פעמיים. לחצו על Enter כדי לקבל את בחירתכם. אם יש לכם גם פריסות מקלדת מרובות, לחצו לחיצה ימנית על המחוון כדי לעבור ביניהן.

השתמשו ב_הגדרה > הקלדה > פריסות מקלדת_ כדי לבחור פריסות כמו אנגלית וצרפתית, מאותן בחירות המוצעות במהלך ההתקנה. השתמשו ב_הגדרה > הקלדה > שיטות קלט_ כדי לבחור אילו מנועי הרכבה פעילים. שני הבוררים נפתחים בתוך תפריט Omarchy עם הבחירות הנוכחיות שלכם מסומנות. לחצו או לחצו על Enter כדי להחליף בחירה; כל שינוי חל מיד. ביטול בחירת שיטת קלט מסיר אותה מהמחזור מבלי להסיר את התקנתה; המקלדת נשארת זמינה.

הריצו `omarchy setup keyboard` או `omarchy setup input` כדי לפתוח את אותם בוררים. כדי להוסיף שפה אחת משורת הפקודה, השתמשו ב-`omarchy setup input mozc`, `hangul`, `pinyin`, או `chewing`. מקשי ההחלפה המותאמים אישית שלכם נשמרים. עבור פריסות מנוע חלופיות או מקשים, התקינו את `fcitx5-configtool` עם `omarchy pkg add fcitx5-configtool` והפעילו אותו ממסוף. בחירת שפת קלט אינה משנה את שפת שולחן העבודה.

השתמשו ב-`Super + I` כדי לעבור בין שיטות קלט או פריסות מקלדת, ועל `Super + Shift + I` כדי ללכת בכיוון ההפוך, כך שעם שלושה מוגדרים תוכלו לנוע בין שני שכנים. מחוון הקלט מופיע מימין לשורה רק כאשר יותר משיטת קלט או פריסה אחת מוגדרות. קישור שולחן עבודה זה עובד לצד מקשי ההחלפה הקיימים של Fcitx; תוכלו לדרוס אותו ב-`~/.config/hypr/bindings.lua`. מנועי קלט ורצפי ההרכבה משתמשים בשירות [Fcitx5](https://fcitx-im.org/) שכבר פועל בכל מושב.

### שימוש ב-ALT כ-SUPER

על מקלדות מסוימות, לא נוח להשתמש במקש המטא העיקרי (מקש Windows/cmd) כ-SUPER. תוכלו לשנות זאת ל-ALT במקום זאת באמצעות שינוי זה:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
