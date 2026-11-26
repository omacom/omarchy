# התקנות ללא התערבות

ה-ISO של Omarchy יכול להתקין את עצמו בלי שאף אחד יושב ליד המקלדת. אם המתקין מוצא כונן שני עם התווית `cidata` שנושא את קבצי התצורה שלו, הוא מעתיק אותם ממנו, מדלג לחלוטין על אשף ההגדרה, ומאתחל בעצמו אל המערכת המוגמרת. אין צורך בבניית ISO מיוחדת, אין צורך בערך נוסף בתפריט האתחול — כשאין כונן כזה מחובר, שום דבר לא משתנה ומקבלים את האשף הרגיל.

זה הופך את Omarchy לתמונת בסיס מצוינת עבור סביבות פיתוח חד-פעמיות: צרו VM ב-Proxmox או עם Packer, אתחלו אותו, לכו משם, והתחברו ב-SSH. ‏`cidata` היא התווית של cloud-init מסוג `NoCloud`, כך שכל כלי הווירטואליזציה הנפוצים כבר יודעים איך לחבר כונן כזה.

## קבצי התצורה

הקבצים הם בדיוק מה שאשף המתקין עצמו כותב, כך שהדרך הקלה ביותר להשיג סט התחלתי היא להריץ התקנה אינטראקטיבית אחת (ב-VM, נניח) ולהעתיק את מה שהוא כתב אל `/root`:

| קובץ | נדרש | מטרה |
|------|----------|---------|
| `user_configuration.json` | כן | דיסק, שם מארח, אזור זמן, מקלדת |
| `user_credentials.json` | כן | שם משתמש ו-hash של הסיסמה, וביטוי הסיסמה של LUKS עבור התקנה מוצפנת |
| `user_encrypt_installation.txt` | לא | `true` כאשר התצורה נושאת בלוק `disk_encryption` |
| `authorized_keys` | לא | מפתחות ציבוריים של SSH, אחד בכל שורה |
| `tailscale_authkey` | לא | מפתח אימות של Tailscale לחיבור ל-tailnet שלך באתחול הראשון |

צרו את ה-hash של הסיסמה עבור `user_credentials.json` באמצעות `openssl passwd -6 "yourpassword"`.

השם והאימייל עבור commits ב-git אינם חלק מההתקנה. הגדירו אותם ברגע שהמכונה עולה, באמצעות SSH לדוגמה, עם `omarchy setup git --name "Jane Doe" --email jane@example.com`.

אפשר גם פשוט להניח קובץ ריק בשם `defer-provisioning` במקום `user_credentials.json`. כך מתבצעת אותה [התקנת הכנה לבעלים אחר](02-getting-started.md) שאפשר להפעיל גם בצורה אינטראקטיבית: המכונה מותקנת ללא פרטים אישיים, ומי שמאתחל אותה ראשון בוחר את המקלדת שלו ויוצר את המשתמש שלו. זהו המצב עבור מערכי imaging, שבהם הכונן לא אמור לשאת פרטי הזדהות של אף אחד.

## גישה באמצעות SSH

כאשר `authorized_keys` קיים, ההתקנה מגדירה את המפתחות כ-`~/.ssh/authorized_keys` של המשתמש, מפעילה את `sshd`, ופותחת עבורו את חומת האש. (התקנת Omarchy רגילה מגיעה עם openssh כשהשירות מושבת והפורט סגור, כך שמכונה ללא התערבות הייתה אחרת בלתי ניתנת להשגה.) ההתקנה רק מוסיפה את המפתחות שלכם — היא לא מרופפת אף אחת מהגדרות האימות האחרות של דמון ה-SSH.

כאשר `tailscale_authkey` קיים, המכונה מצטרפת במקום זאת ל-tailnet שלכם באתחול הראשון: Tailscale מותקן מהחבילות המצורפות ל-ISO, חומת האש מאפשרת את ממשק ה-tailnet, ומשימה ברקע מריצה את ההצטרפות ברגע שלמכונה באמת יש רשת, ומנסה שוב עד שהיא מצליחה. השתמשו במפתח רב-פעמי ומאושר מראש, כך שתמונת כונן אחת תוכל לשרת מכונות רבות.

## בניית כונן ה-cidata

כל מערכת קבצים עם התווית הנכונה תעבוד. ISO קטן הוא הדרך הקלה:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

לאחר מכן חברו אותו ל-VM לצד ה-ISO של Omarchy. הנה דוגמה מלאה של Proxmox:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

סדר האתחול מציין את הדיסק ראשון בכוונה: הדיסק הריק נופל אל ה-ISO באתחול הראשון, והמערכת המותקנת מאותחלת מהדיסק מכאן ואילך.

## שני סייגים

התקנות מוצפנות ללא התערבות אינן לגמרי ללא התערבות — מישהו עדיין צריך להקליד את ביטוי הסיסמה של LUKS באתחול הראשון. וביטוי הסיסמה הזה נכנס ברמה העליונה של `user_credentials.json` בתור `encryption_password` — archinstall קורא אותו משם, ולא מבלוק ה-`disk_encryption` שב-`user_configuration.json` — אז התייחסו לכונן cidata שנבנה מהתקנה מוצפנת כאל הסוד שהוא.
