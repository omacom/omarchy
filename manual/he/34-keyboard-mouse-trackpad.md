# מקלדת, עכבר, משטח מגע

Hyprland מאפשר לכם להגדיר את כל אמצעי הקלט שלכם בפירוט רב. תוכלו לשנות את חזרת המקלדת למהירה בצורה על־קולית, או לגרום למשטח המגע להשתמש בגלילה טבעית. את כל זה משנים ב־`~/.config/hypr/input.lua`, שאפשר להגיע אליו גם דרך _Setup > Input_ בתפריט Omarchy‏ (`Super + Space`). כל מה שתגדירו שם מחליף את ברירות המחדל של Omarchy.

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

תוכלו [לראות את כל אפשרויות הקלט](https://wiki.hypr.land/Configuring/Basics/Variables/#input) בוויקי של Hyprland בנושא קלטים.

CapsLock פועל כמקש Caps Lock רגיל, ו־`Shift + CapsLock` הוא מקש ה־compose עבור [אימוג'ים מהירים](07-hotkeys.md#quick-emojis) ו[השלמות אחרות](07-hotkeys.md#quick-completions). אם אתם מעדיפים שמקש ה־compose יהיה במקום אחר, החליפו את `omarchy:shift_caps_compose` ב־`kb_options`. לדוגמה, כך מעבירים את מקש ה־compose ל־Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### מקשי פונקציה

השורה העליונה של מקלדת מחשב נייד שולחת כברירת מחדל את מקשי המדיה (עוצמת קול, בהירות וכן הלאה), והחזקת `Fn` נותנת את F1-F12;‏ `Fn + Esc` נועל זאת בכיוון ההפוך עד שלוחצים עליו שוב. רוב המקלדות זוכרות את הנעילה הזאת בעצמן. מחשבים ניידים של ASUS ומקלדות בסגנון Apple משאירים זאת ל־Linux, שמפעיל אותם על מקשי המדיה בכל אתחול. כדי שהם יתחילו במקום זאת על F1-F12, הריצו את `omarchy device keyboard toprow fnkeys` (ואת `omarchy device keyboard toprow mediakeys` כדי לחזור); בחלק מהמחשבים הניידים זה נכנס לתוקף לאחר אתחול מחדש. מחשבי Mac עם Apple Silicon שומרים על ההגדרה של עצמם.

### מחוות משטח מגע

החליקו על משטח המגע כדי לנוע ברחבי שולחן העבודה:

| מחווה | פעולה |
| --- | --- |
| שלוש אצבעות שמאלה / ימינה | מרחב העבודה הקודם / הבא, כולל ריקים |
| שלוש אצבעות למעלה | הצגה/הסתרה של מסוף ה־AI |
| שלוש אצבעות למטה | פתיחת תפריט Omarchy |
| ארבע אצבעות שמאלה / ימינה | העברת החלון הפעיל למרחב העבודה הקודם / הבא |
| ארבע אצבעות למטה | הצגה/הסתרה של מסך מלא |

כדי לשנות אחת מהן, בטלו אותה ב־`~/.config/hypr/input.lua` לפני שתוסיפו [מחוות משטח מגע](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) משלכם, כי Hyprland לא יקבל שתי מחוות על אותו מספר אצבעות ובאותו כיוון:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

כדי לכבות את כל המחוות של Omarchy, הגדירו את `omarchy_default_gestures = false` קרוב לראש `~/.config/hypr/hyprland.lua`, לפני שברירות המחדל של Omarchy נטענות.

במחשבים ניידים מדגם Dell XPS עם משטח מגע הפטי, תוכלו גם להגדיר את עוצמת הלחיצה לנמוכה, בינונית או גבוהה תחת _Trigger > Hardware > Touchpad Haptics_.

### הקלדה בסינית, יפנית ושפות אחרות

בחרו יפנית, קוריאנית, סינית (מפושטת, Pinyin), טייוואן (Zhuyin) או הונג קונג (Cangjie) כאשר תוכנית ההתקנה שואלת על המקלדת שלכם. Omarchy מגדיר את המקלדת ואת מנוע הקלט המתאים באופן אוטומטי, כולל במהלך ההגדרה הלא־מקוונת בהפעלה הראשונה. יפנית משתמשת ב־Mozc, קוריאנית משתמשת ב־Hangul הסטנדרטי בשיטת שני הסטים, סינית מפושטת משתמשת ב־Pinyin, טייוואן משתמשת בסידור ה־Zhuyin הסטנדרטי של Chewing, והונג קונג משתמשת ב־Cangjie עם צורות תווים של הונג קונג. יפנית (מקלדת US) מספקת את Mozc עם פריסת מקלדת US. מקשי Hangul,‏ Zhuyin ו־Cangjie נשארים במיקומיהם הסטנדרטיים גם כאשר מקלידים אותיות לטיניות עם Dvorak,‏ Colemak או AZERTY. אם הוספתם את Hangul או Chewing לפני כן, בטלו את בחירתן ובחרו אותן שוב תחת _Setup > Keyboard > Input Methods_ כדי להעביר את המקשים שלהן לשם; Omarchy משאיר בשקט מנוע שכבר מקלידים איתו.

ההקלדה מתחילה במצב לטיני. לחצו על `Super + I` כדי לעבור במחזוריות בין שיטות הקלט שהוגדרו, ועל `Super + Shift + I` כדי לעבור אחורה במחזוריות. הקישו על `Shift` לבדו כדי לצאת משיטת קלט כמו Pinyin לאותיות לטיניות, והקישו עליו שוב כדי לחזור, כפי שעובדים Sogou,‏ Microsoft Pinyin ו־macOS;‏ `Shift` יחד עם אות עדיין מקליד אות גדולה. במקלדות יפניות, 全角/半角 מחליף את מצב הקלט, 変換 מפעיל אותו, ו־無変換 מכבה אותו. עם קוריאנית, 한/영 מחליף את Hangul ו־한자 ממיר ל־Hanja, בין אם למקלדת שלכם יש מקשים ייעודיים ובין אם היא שולחת עבורם את Right Alt ו־Right Ctrl, כפי שעושים מחשבים ניידים רבים, ולכן Right Alt ו־Right Ctrl אינם מקשי שינוי רגילים שם; הכתבה מופעלת ומכובה עם Alt + Space במקום זאת. `Ctrl + Space` נשאר זמין ל־Tmux ו־Herdr;‏ `Shift + CapsLock` נשאר מקש ה־compose.

מחוון המקלדת מופיע בצד ימין של הסרגל כאשר יש לכם כמה פריסות מקלדת או שיטות קלט. לחצו עליו כדי להחליף שפות קלט; יפנית מציגה את あ עבור hiragana. לבחירת תווים יפניים, עברו ליפנית, הקלידו מילה כמו `nihongo`, ואז לחצו על Space פעמיים. לחצו על Enter כדי לאשר את הבחירה שלכם. אם יש לכם גם כמה פריסות מקלדת, לחצו בלחצן הימני על המחוון כדי לעבור ביניהן במחזוריות.

השתמשו ב־_Setup > Keyboard > Keyboard Inputs_ כדי לבחור פריסות כמו אנגלית וצרפתית, מתוך אותן אפשרויות שמוצעות במהלך ההתקנה. השתמשו ב־_Setup > Keyboard > Input Methods_ כדי לבחור אילו מנועי הרכבה פעילים. שני הבוחרים נפתחים בתוך תפריט Omarchy, כשהבחירות הנוכחיות שלכם מסומנות. לחצו או לחצו על Enter כדי לשנות בחירה; כל שינוי חל מיד. ביטול בחירה של שיטת קלט מסיר אותה מהמחזור בלי להסיר את התקנתה; המקלדת נשארת זמינה.

הריצו את `omarchy setup keyboard` או את `omarchy setup input` כדי לפתוח את אותם בוחרים. כדי להוסיף שפה אחת משורת הפקודה, השתמשו ב־`omarchy setup input mozc`,‏ `hangul`,‏ `pinyin`,‏ `chewing` או `cangjie5`.‏ Quick,‏ Boshiamy ו־Array מגיעים באותה חבילה כמו Cangjie ומופיעים בבוחר Input Methods. מקשי ההחלפה המותאמים אישית שלכם נשמרים. עבור פריסות או מקשים חלופיים של מנועים, התקינו את `fcitx5-configtool` עם `omarchy pkg add fcitx5-configtool` והפעילו אותו ממסוף. בחירת שפת קלט אינה משנה את שפת שולחן העבודה. בחירת יפנית, קוריאנית או סינית תחת _Setup > Language_ מוסיפה את שיטת הקלט שלה כאשר עדיין אין לכם אף אחת.

השתמשו ב־`Super + I` כדי לעבור במחזוריות בין שיטות קלט או פריסות מקלדת, וב־`Super + Shift + I` כדי לחזור בכיוון השני, כך שעם שלוש מוגדרות תוכלו לנוע בין שני שכנים. מחוון הקלט מופיע בצד ימין של הסרגל רק כאשר מוגדרת יותר משיטת קלט או פריסה אחת. קיצור שולחן העבודה הזה פועל לצד מקשי ההחלפה הקיימים שלכם ב־Fcitx; תוכלו לעקוף אותו ב־`~/.config/hypr/bindings.lua`. מנועי הקלט ורצפי ה־compose משתמשים בשירות [Fcitx5](https://fcitx-im.org/) שכבר רץ בכל הפעלה.

### שימוש ב־ALT בתור SUPER

במקלדות מסוימות, לא נוח להשתמש במקש ה־meta הראשי (מקש Windows/cmd) בתור SUPER. תוכלו לשנות זאת ל־ALT במקום, באמצעות השינוי הבא:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
