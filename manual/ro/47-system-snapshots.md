# Instantanee de sistem

Creăm instantanee automat la fiecare actualizare Omarchy, dar dacă vrei să creezi unul propriu, poți folosi `omarchy-snapshot create`.

Pentru a porni și a restaura un instantaneu, îl selectezi din încărcătorul de pornire Limine. (Dacă în prezent pornești direct în ecranul de decriptare Omarchy, va trebui mai întâi să selectezi Limine ca opțiune de pornire din BIOS).

Din acel ecran, alege instantaneul în care vrei să pornești, în funcție de dată și versiune. Versiunea Omarchy din momentul instantaneului poate fi văzută în colțul din stânga jos.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Când ajungi în sistem, va apărea o notificare care te anunță că ești într-un instantaneu bootabil și, dacă dai clic pe ea, va porni procesul de restaurare. Alternativ, poți folosi `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Aceasta îți va restaura sistemul de fișiere rădăcină, dar nu și `/home`. Așa că funcționează pentru a reveni de la o actualizare de sistem defectuoasă, dar nu pentru a recupera fișiere personale pierdute.

Asta înseamnă și că directorul tău `~/.config` rămâne așa cum este. Așa că, dacă revii la o versiune anterioară a unei biblioteci sau aplicații care stochează fișiere de configurare într-un format nou, va trebui să rezolvi asta manual.

Același lucru este valabil și pentru evidența proprie a Omarchy privind migrările care au rulat deja: se află în directorul tău personal, așa că supraviețuiește restaurării. Migrările care au rulat după ce a fost făcut instantaneul rămân marcate ca finalizate, chiar dacă modificările pe care le-au făcut în sistemul de fișiere rădăcină au fost anulate, iar următoarea comandă `omarchy update` nu le va rula din nou. Așa că, dacă actualizezi din nou după o restaurare și încă lipsește ceva ce o actualizare anterioară configurase, acesta este probabil motivul.

_Notă: Această funcție este disponibilă doar pe instalările care folosesc încărcătorul de pornire Limine, care este opțiunea implicită începând cu Omarchy 2.0. Nu este disponibilă dacă folosești GRUB sau systemd-boot._

### Omiterea meniului de pornire

Dacă nu atingi niciodată meniul de pornire și vrei pur și simplu ca aparatul să ajungă direct la ecranul de decriptare, rulează _Setup > Direct Boot_ în meniul Omarchy. Asta adaugă o intrare EFI care indică direct spre Omarchy, astfel încât firmware-ul îl pornește fără să se oprească la Limine.

Compromisul este cel menționat la început: cu pornirea directă activată, accesarea unui instantaneu înseamnă să alegi mai întâi Limine din meniul de pornire al BIOS-ului. Rulează din nou _Setup > Direct Boot_ pentru a elimina intrarea și a reveni la pornirea prin Limine. Unele firmware-uri nu acceptă cu plăcere intrările EFI personalizate, așa că configurarea refuză să ruleze pe firmware American Megatrends și Apple.
