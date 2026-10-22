# התקנות ללא השגחה

קובץ ISO של Omarchy יכול להתקין את עצמו בלי אף אחד ליד המקלדת. אם המתקין מוצא כונן שני עם התווית `cidata` הנושא את קובצי התצורה שלו, הוא מעתיק אותם, מדלג על אשף ההגדרה לחלוטין, ומאתחל מחדש למערכת המוגמרת בעצמו. אין בניית ISO מיוחדת, אין ערך תפריט אתחול נוסף — כשאין כונן כזה מחובר, שום דבר לא משתנה ואתם מקבלים את האשף הרגיל.

זה הופך את Omarchy למעולה כתמונת בסיס עבור סביבות פיתוח חד-פעמיות: צרו VM ב-Proxmox או עם Packer, אתחלו אותו, לכו, התחברו ב-SSH. `cidata` היא התווית `NoCloud` של cloud-init, כך שכל כלי הוירטואליזציה הנפוצים כבר יודעים איך לחבר כונן כזה.

## קובצי התצורה

הקבצים הם בדיוק מה שאשף המתקין עצמו כותב, כך שהדרך הקלה ביותר להשיג סט התחלתי היא להריץ התקנה אינטראקטיבית אחת (ב-VM, נאמר) ולהעתיק את מה שהוא כתב לתוך `/root`:

| קובץ | חובה | מטרה |
|------|----------|---------|
| `user_configuration.json` | כן | דיסק, שם מארח, אזור זמן, מקלדת |
| `user_credentials.json` | כן | שם משתמש וגיבוב סיסמה |
| `user_full_name.txt` | לא | שם מלא של Git |
| `user_email_address.txt` | לא | דוא"ל של Git |
| `user_encrypt_installation.txt` | לא | `true` כאשר התצורה נושאת בלוק `disk_encryption` |
| `authorized_keys` | לא | מפתחות ציבוריים של SSH, אחד בכל שורה |
| `tailscale_authkey` | לא | מפתח אימות Tailscale להצטרפות ל-tailnet שלכם באתחול הראשון |

צרו את גיבוב הסיסמה עבור `user_credentials.json` עם `openssl passwd -6 "yourpassword"`.

תוכלו גם להשליך קובץ ריק בשם `defer-provisioning` במקום `user_credentials.json`. זה מריץ את אותה [התקנת הכנה לבעלים אחר](02-getting-started.md) שתוכלו להפעיל אינטראקטיבית: המכונה מותקנת ללא פרטים אישיים, ומי שמאתחל אותה ראשונה בוחר את המקלדת שלו ויוצר את המשתמש שלו. זהו המצב עבור מתקני דימות, שבהם הכונן לא צריך לשאת אישורי אף אחד כלל.

## גישת SSH

כאשר `authorized_keys` קיים, ההתקנה מגדירה את המפתחות כ-`~/.ssh/authorized_keys` של המשתמש, מאפשרת `sshd` ופותחת את חומת האש עבורו. (התקנת Omarchy סטנדרטית שולחת openssh עם השירות מושבת והיציאה סגורה, כך שמכונה ללא השגחה אחרת לא תהיה נגישה.) ההתקנה מוסיפה רק את המפתחות שלכם — היא אינה משחררת אף אחת מהגדרות האימות האחרות של דימון SSH.

כאשר `tailscale_authkey` קיים, המכונה מצטרפת ל-tailnet שלכם באתחול הראשון במקום: Tailscale מותקן מחבילות ISO המקובצות, חומת האש מאפשרת את ממשק ה-tailnet, ועבודת רקע מריצה את ההצטרפות ברגע שלמכונה באמת יש רשת, ומנסה שוב עד שתצליח. השתמשו במפתח רב-פעמי ומאושר מראש כך שתמונת כונן אחת תוכל לשרת מכונות רבות.

## בניית כונן cidata

כל מערכת קבצים עם התווית הנכונה עובדת. ISO זעיר הוא הדרך הקלה:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

אז חברו אותו ל-VM לצד ISO של Omarchy. הנה דוגמה מלאה של Proxmox:

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

סדר האתחול מפרט את הדיסק תחילה בכוונה: הדיסק הריק נופל ל-ISO באתחול הראשון, והמערכת המותקנת מאתחלת מהדיסק מאז ואילך.

## שתי הסתייגויות

התקנות מוצפנות ללא השגחה אינן ללא השגחה לחלוטין — מישהו עדיין צריך להקליד את ביטוי הסיסמה של LUKS באתחול הראשון. ובלוק `disk_encryption` ב-`user_configuration.json` נושא את ביטוי הסיסמה הזה בטקסט רגיל, כך שהתייחסו לכונן cidata שנבנה מהתקנה מוצפנת כסוד שהוא.
