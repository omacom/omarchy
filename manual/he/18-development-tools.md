# כלי פיתוח

## עורכים חלופיים

Omarchy מגיעה עם [Neovim](https://neovim.io/) כברירת מחדל, אבל אם תרצו משהו קצת יותר מיינסטרימי ומוכר, תוכלו לפתוח את Omarchy Menu (`Super + Space`) ולראות את האפשרויות תחת _Install > Editor_. יש לנו שם את VSCode, Cursor, Zed, Sublime Text, Helix, Vim ו-Emacs. אם לא מצאתם את מה שחיפשתם, בדקו את _Install > Package_, ובדקו אם זה לא נמצא בחבילת Arch (ואם לא, נסו את _Install > AUR_ כדי לבדוק ב-AUR).

גם עורך `vi` המקורי זמין מהקופסה. הריצו `vi filename` כדי לערוך קובץ בטרמינל.

התאמת ערכת נושא מוצעת עבור `VSCode`, `Cursor`, `VSCodium` ו-`Helix`.

תוכלו להגדיר את עורך ברירת המחדל בכל המערכת תחת `Setup > Defaults > Editor`.

## סביבה

Omarchy תומכת בהתקנה של שלל סביבות פיתוח דרך הסעיף _Install > Development_ ב-Omarchy Menu (`Super + Space`). תמצאו שם כמובן את _Ruby on Rails_, אבל גם את כל שלוש סביבות הריצה העיקריות ל-JavaScript (Node.js, Bun, Deno), וגם מסגרות PHP פופולריות כמו Laravel ו-Symfony. אה, ויש גם Go, Rust, Python, Java, Elixir (עם Phoenix), .NET, OCaml, Zig, Clojure ו-Scala. זה מבחר רחב מאוד!

רוב הסביבות האלה מנוהלות על ידי [Mise](https://mise.jdx.dev/). זה כלי שמאפשר לכם להתקין ולהריץ כמה גרסאות של שפת תכנות על אותה מכונה. זה כמו rbenv או rvm ל-Ruby או virtualenv ל-Python, אבל זה עובד עבור שלל סביבות שונות.

כדי להתקין, נגיד, את Ruby, תריצו `mise use -g ruby`, מה שגם יתקין את Ruby וגם יגדיר אותו כברירת המחדל הגלובלית. או, אם לפרויקט שלכם יש קובץ .ruby-version, תוכלו פשוט להריץ `mise i` בשורש הפרויקט הזה.

## כלי CLI מותקנים מראש

Omarchy הופכת כלים כמו `gh`, `uv`, ואת רוב [סוכני הקידוד](17-ai.md) לזמינים דרך [ההתקנה העצלה של mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). בפעם הראשונה שתריצו אחד מהם, mise מתקין אותו. הרצות מאוחרות יותר עושות שימוש חוזר בגרסה המותקנת; הן לא בודקות אם יש עדכון בכל הפעלה.

תוכלו גם לבדוק את ברירות המחדל או להתקין אותם מראש:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

הריצו `omarchy update` כדי לעדכן כלים מותקנים יחד עם שאר Omarchy. הכינוי `mup` מעדכן רק כלים המנוהלים על ידי mise. כדי להוסיף כלי נוסף לתצורה שלכם, השתמשו ב-`mise use -g <tool>`.

התקנת Python מתקינה גם את `uv` דרך mise. הסרת סביבת הפיתוח של Python משאירה את `uv` זמין ככלי עצמאי.

### שימוש בהתקנה משלכם

הפקודות של mise קודמות ל-`~/.local/bin` ב-`PATH`, כך שכלי שהתקנתם בעצמכם, למשל עם המתקין של Claude Code או של Cursor, עדיין מריץ את העותק של mise. גם אפליקציות שמופעלות משולחן העבודה מוצאות את הפקודות של mise לפני חבילות המערכת, כך שאפליקציה שמריצה `gh` מקבלת את העותק של mise גם אם התקנתם `github-cli` עם pacman, ו-mise מתקין את העותק הזה בפעם הראשונה. כדי להשתמש בשלכם במקום זאת, השביתו את העותק של mise ב-`~/.config/mise/config.toml`. למשל, אם התקנתם את Cursor CLI בעצמכם:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

אם כבר יש לכם טבלת `[settings]`, הוסיפו את הערך שם; הרחיבו רשימת `disable_tools` קיימת במקום להחליף אותה. ודאו שההתקנה שלכם נמצאת ב-`PATH`. השתמשו בשם הכלי של mise, שיכול להיות שונה מהפקודה שלו: `oh-my-pi` מספק את `omp`, למשל. גם מפעיל סוכן ברירת המחדל מעדיף Cursor או Muse שהמשתמש התקין ב-`~/.local/bin`.

### הסרה ושחזור של ברירות המחדל

_Remove Preinstalls_ גורם ל-mise לדלג על הכרזות הכלים של Omarchy עבור המשתמש שלכם, על ידי הוספתן ל-`ignored_config_paths` ב-`~/.config/mise/miserc.toml`. _Restore Preinstalls_ מסיר את השורה הזו שוב. כלים שאתם מכריזים עליהם בעצמכם, בתצורה שלכם או ב-`mise.toml` של פרויקט, ממשיכים לעבוד בכל מקרה. אם תבחרו סוכן ברירת מחדל או תתקינו Python אחרי הסרת ההתקנות המותקנות מראש, הכלי הזה מתווסף לתצורה שלכם. שניהם חלים רק על המשתמש שלכם; משתמשים אחרים במכונה שומרים על הבחירה שלהם.

## Docker

[Docker](https://www.docker.com/) כמעט לא צריך שום הקדמה. הוא מאפשר לכם להריץ קונטיינרים מבודדים, ו-Omarchy מתקינה את כל מה שצריך כדי להריץ אותו היטב, כולל Docker עצמו ו-[Docker Compose](https://docs.docker.com/compose/).

כברירת מחדל המשתמש שלכם *לא* נמצא בקבוצת `docker`. הקבוצה הזו היא למעשה root ללא סיסמה — כל מה שבתוכה יכול להריץ `docker run -v /:/host` ולהשתלט על המכונה — כך שסקריפט סורר אחד או תלות אחת שרצים כמשתמש שלכם היו אחרת במרחק פקודה אחת מ-root. לכן בשורת הפקודה אתם מריצים את Docker עם `sudo` (`sudo docker ps`, `sudo docker compose up`), והכלים הגרפיים שמדברים עם ה-daemon — מכונת ה-VM של Windows — מבקשים אישור כשהם צריכים אותו. אם תרצו את הנוחות של מערכת ללא קבוצה בחזרה ואתם מבינים את המחיר, הפעילו אותה מ-**Setup > Security > Sudoless Docker** (או הריצו `omarchy-setup-security-sudoless-docker`), מה שמוסיף אתכם לקבוצת `docker` אחרי אזהרה; אז `docker` רגיל והכינוי `d` עובדים שוב ללא `sudo`.

תוכלו להתקין את מסדי הנתונים הנפוצים לפיתוח מקומי ב-Docker באמצעות _Install > Development > Docker DB_ בתפריט Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) זמין כ-`gh` לעבודה עם מאגרים, issues ו-pull requests מהטרמינל. הריצו `gh auth login` כדי להתקין אותו בשימוש הראשון ולהתחבר, ואז `gh repo clone org/repo` כדי לשכפל מאגר. הריצו `gh --help` כדי לחקור את הפקודות שלו.

לממשק טרמינל ל-pull requests, הריצו `ghui`; גם אותו mise מתקין בשימוש הראשון. [Lazygit](https://github.com/jesseduffield/lazygit) מותקן מראש לעבודה עם Git עצמו.
