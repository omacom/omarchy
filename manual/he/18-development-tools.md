# כלי פיתוח

## עורכים חלופיים

Omarchy מגיעה עם Plain כעורך ברירת המחדל בהתקנות חדשות ועם [Neovim](https://neovim.io/) מותקן מראש, אבל אם תרצו משהו קצת יותר מיינסטרימי ומוכר, תוכלו להפעיל את Omarchy Menu (`Super + Space`) ולראות את האפשרויות תחת _Install > Editor_. תמצאו שם את VSCode, Cursor, Zed, Sublime Text, Helix, Vim ו-Emacs. אם לא מצאתם את מה שחיפשתם, בדקו את _Install > Package_, ובדקו אם הוא לא נמצא בחבילת Arch (ואם לא, נסו את _Install > AUR_ כדי לבדוק ב-AUR).

עורך `vi` המקורי זמין גם הוא מיד מהקופסה. הריצו `vi filename` כדי לערוך קובץ בטרמינל.

התאמת ערכת נושא מוצעת עבור `VSCode`, `Cursor`, `VSCodium` ו-`Helix`.

תוכלו להגדיר את עורך ברירת המחדל בכל המערכת תחת `Setup > Defaults > Editor`.

## סביבה

Omarchy תומכת בהקמת מגוון שלם של סביבות פיתוח דרך הסעיף _Install > Development_ ב-Omarchy Menu (`Super + Space`). כמובן שתמצאו שם את _Ruby on Rails_, אבל גם את כל שלוש סביבות הריצה המרכזיות ל-JavaScript (Node.js, Bun, Deno), וגם פריימוורקים פופולריים של PHP כמו Laravel ו-Symfony. אה, ויש גם Go, Rust, Python, Java, Elixir (עם Phoenix), .NET, OCaml, Zig, Clojure ו-Scala. זה מבחר רחב מאוד!

רוב הסביבות האלה מנוהלות על ידי [Mise](https://mise.jdx.dev/). זה כלי שמאפשר לכם להתקין ולהריץ גרסאות מרובות של שפת תכנות על אותה מכונה. זה כמו rbenv או rvm עבור Ruby או virtualenv עבור Python, אבל זה עובד עבור מגוון סביבות שונות.

כדי להתקין, נניח, את Ruby, תריצו `mise use -g ruby`, מה שגם יתקין את Ruby וגם יגדיר אותו כברירת המחדל הגלובלית. או, אם לפרויקט שלכם יש קובץ .ruby-version, תוכלו פשוט להריץ `mise i` בשורש הפרויקט הזה.

## כלי CLI מותקנים מראש

`uv`, Node.js ו-`playwright-cli` (כדי שסוכנים יוכלו להפעיל דפדפן, באמצעות Chrome המותקן) מגיעים מותקנים כחבילות, ו-`omarchy update` שומר אותם מעודכנים יחד עם שאר המערכת. `ghui`, [Hunk](https://github.com/modem-dev/hunk) וה-CLI של Basecamp, Cloudflare ו-HEY נמצאים במרחק בחירה אחת תחת _Install > CLI_, ו[סוכני קידוד](17-ai.md) תחת _Install > AI > CLI_.

mise מנהל רק את סביבות הריצה שהגדרתם מ-_Install > Development_; Omarchy לא מתקינה דרכו שום דבר מעצמה. הריצו `omarchy update` כדי לעדכן אותן יחד עם שאר Omarchy; הכינוי `mup` מעדכן רק כלים המנוהלים על ידי mise. כדי להוסיף כלי נוסף לתצורה שלכם, השתמשו ב-`mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) בקושי צריך היכרות. הוא מאפשר לכם להריץ קונטיינרים מבודדים, ו-Omarchy מתקינה כל מה שצריך כדי להריץ אותו היטב, כולל Docker עצמו ו-[Docker Compose](https://docs.docker.com/compose/).

כברירת מחדל, המשתמש שלכם *אינו* בקבוצת `docker`. הקבוצה הזו היא למעשה root ללא סיסמה — כל דבר שנמצא בה יכול להריץ `docker run -v /:/host` ולהשתלט על המכונה — כך שסקריפט זדוני אחד או תלות אחת שפועלים כמשתמש שלכם היו אחרת במרחק פקודה אחת מ-root. לכן בשורת הפקודה אתם מריצים את Docker עם `sudo` (`sudo docker ps`, `sudo docker compose up`), והכלים הגרפיים שמדברים עם ה-daemon — ה-Windows VM — מבקשים הרשאה כשהם צריכים אותה. אם אתם רוצים בחזרה את הנוחות של הגדרה ללא קבוצה ומבינים את הפשרה, הפעילו זאת מ-**Setup > Security > Sudoless Docker** (או הריצו `omarchy-setup-security-sudoless-docker`), מה שמוסיף אתכם לקבוצת `docker` לאחר אזהרה; אז `docker` רגיל והכינוי `d` יעבדו שוב ללא `sudo`.

תוכלו להגדיר את מסדי הנתונים הנפוצים לפיתוח מקומי ב-Docker באמצעות _Install > Development > Docker DB_ בתפריט Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) הוא `gh`, לעבודה עם מאגרים, issues ובקשות משיכה מהטרמינל. _Setup > Git_ מתקין אותו כשתבחרו להתחבר שם ל-GitHub, ואז `gh repo clone org/repo` משכפל מאגר. הריצו `gh --help` כדי לחקור את הפקודות שלו.

_Install > CLI > GitHub_ מתקין את GitHub CLI, `gh`, יחד עם `ghui`, ממשק טרמינל לבקשות משיכה. [Lazygit](https://github.com/jesseduffield/lazygit) מותקן מראש לעבודה עם Git עצמו.
