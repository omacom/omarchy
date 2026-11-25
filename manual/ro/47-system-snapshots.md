# Instantanee de sistem

Creăm instantanee automat la fiecare actualizare Omarchy, dar dacă vrei să-ți creezi propriul instantaneu, poți folosi `omarchy-snapshot create`.

Pentru a porni și a restaura un instantaneu, îl selectezi din încărcătorul de pornire Limine. Meniul de pornire rămâne ascuns în mod implicit, așa că apasă orice tastă imediat ce pornește Limine pentru a-l afișa.

Din acel ecran, alege instantaneul în care vrei să pornești în funcție de dată și versiune. Versiunea Omarchy din momentul instantaneului poate fi văzută în colțul din stânga jos.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Când ajungi înăuntru, va apărea o notificare care te anunță că ești într-un instantaneu bootabil și, dacă dai clic pe ea, va porni procesul de restaurare. Alternativ, poți utiliza `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Aceasta îți va restaura sistemul de fișiere rădăcină, dar nu și `/home`-ul tău. Așa că funcționează pentru a reveni de la o actualizare de sistem stricată, dar nu pentru a recupera fișiere personale pierdute.

Asta înseamnă și că directorul tău `~/.config` este păstrat ca atare. Așa că, dacă revii la o versiune anterioară a unei biblioteci sau aplicații care stochează fișiere de configurare într-un format nou, va trebui să rezolvi asta manual.

Același lucru este valabil și pentru evidența proprie a Omarchy privind migrările care au rulat deja: ea se află în directorul tău personal, așa că supraviețuiește restaurării. Migrările care au rulat după ce a fost luat instantaneul rămân marcate ca finalizate, chiar dacă modificările pe care le-au făcut în sistemul de fișiere rădăcină au fost anulate, iar următoarea `omarchy update` nu le va rula din nou. Așa că, dacă actualizezi din nou după o restaurare și încă lipsește ceva ce configurase o actualizare anterioară, acesta este motivul probabil.

_Notă: Această funcție este disponibilă numai pe instalările care folosesc încărcătorul de pornire Limine, care este implicit începând cu Omarchy 2.0. Nu este disponibilă dacă ești pe GRUB sau systemd-boot._
