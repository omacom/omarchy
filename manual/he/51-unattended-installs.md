# התקנות ללא התערבות

קובץ ה-ISO של Omarchy יכול להתקין את עצמו בלי אף אחד שיושב מול המקלדת. אם המתקין מוצא כונן שני עם התווית `cidata` שמכיל את קובצי התצורה שלו, הוא מעתיק אותם ממנו, מדלג לחלוטין על אשף ההגדרה ומאתחל בעצמו אל תוך המערכת המוכנה. לא צריך בניית ISO מיוחדת, לא צריך ערך נוסף בתפריט האתחול — אם לא מחובר כונן כזה, שום דבר לא משתנה ומקבלים את האשף הרגיל.

זה הופך את Omarchy לתמונת בסיס מעולה לסביבות פיתוח חד-פעמיות: צרו VM ב-Proxmox או בעזרת Packer, אתחלו אותו, לכו משם, והתחברו ב-SSH. `cidata` היא תווית ה-`NoCloud` של cloud-init, כך שכל כלי הווירטואליזציה הנפוצים כבר יודעים איך לחבר כונן כזה.

## קבצי התצורה

הקבצים הם בדיוק מה שאשף ההתקנה עצמו כותב, כך שהדרך הקלה ביותר להשיג סט התחלתי היא להריץ התקנה אינטראקטיבית אחת (ב-VM, למשל) ולהעתיק את מה שהוא כתב אל `/root`:

| קובץ | נדרש | מטרה |
|------|----------|---------|
| `user_configuration.json` | כן | דיסק, שם מארח, אזור זמן, מקלדת |
| `user_credentials.json` | כן | שם משתמש וגיבוב סיסמה |
| `user_encrypt_installation.txt` | לא | `true` כאשר התצורה מכילה בלוק `disk_encryption` |
| `authorized_keys` | לא | מפתחות ציבוריים של SSH, אחד בכל שורה |
| `tailscale_authkey` | לא | מפתח אימות של Tailscale לחיבור ל-tailnet שלך באתחול הראשון |

צרו את גיבוב הסיסמה עבור `user_credentials.json` בעזרת `openssl passwd -6 "yourpassword"`.

השם והאימייל עבור commits ב-git אינם חלק מההתקנה. הגדירו אותם לאחר שהמכונה עולה, באמצעות SSH למשל, בעזרת `omarchy setup git --name "Jane Doe" --email jane@example.com`.

אפשר גם לשים קובץ ריק בשם `defer-provisioning` במקום `user_credentials.json`. זה מריץ את אותה [התקנת הכנה לבעלים אחר](02-getting-started.md) שאפשר להפעיל באופן אינטראקטיבי: המכונה מותקנת ללא פרטים אישיים, ומי שמאתחל אותה ראשון בוחר את המקלדת שלו ויוצר את המשתמש שלו. זה המצב עבור מתקני הדמיה (imaging rigs), שבהם הכונן לא אמור לשאת אישורים של אף אחד.

## גישת SSH

כאשר `authorized_keys` קיים, ההתקנה מגדירה את המפתחות בתור ה-`~/.ssh/authorized_keys` של המשתמש, מפעילה את `sshd`, ופותחת עבורו את חומת האש. (התקנת Omarchy רגילה מגיעה עם openssh כשהשירות מושבת והפורט סגור, כך שמכונה ללא התערבות הייתה בלתי נגישה אחרת.) ההתקנה רק מוסיפה את המפתחות שלכם — היא לא מרופפת אף אחת מהגדרות האימות האחרות של דמון ה-SSH.

כאשר `tailscale_authkey` קיים, המכונה מצטרפת במקום זאת ל-tailnet שלך באתחול הראשון: Tailscale מותקן מהחבילות המצורפות ל-ISO, חומת האש מאפשרת את ממשק ה-tailnet, ומשימת רקע מריצה את ההצטרפות ברגע שלמכונה אכן יש רשת, ומנסה שוב עד שהיא מצליחה. השתמשו במפתח רב-פעמי ומאושר מראש, כדי שתמונת כונן אחת תוכל לשרת מכונות רבות.

## בניית כונן ה-cidata

כל מערכת קבצים עם התווית הנכונה תעבוד. ISO זעיר הוא הדרך הקלה:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

אז חברו אותו ל-VM לצד ה-ISO של Omarchy. הנה דוגמה מלאה ל-Proxmox:

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

סדר האתחול מציג את הדיסק ראשון בכוונה: הדיסק הריק נופל אל ה-ISO באתחול הראשון, והמערכת המותקנת מאתחלת מהדיסק מאז ואילך.

## שני סייגים

התקנות מוצפנות ללא התערבות אינן לגמרי ללא התערבות — מישהו עדיין צריך להקליד את הסיסמה של LUKS באתחול הראשון. ובלוק ה-`disk_encryption` ב-`user_configuration.json` נושא את הסיסמה הזו בטקסט גלוי, אז התייחסו לכונן cidata שנבנה מהתקנה מוצפנת כסוד שהוא באמת.
