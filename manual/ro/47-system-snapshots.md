# Instantanee ale sistemului

Creăm instantanee automat la fiecare actualizare Omarchy, dar dacă vrei să-ți creezi propriul instantaneu, poți folosi `omarchy-snapshot create`.

Modul în care pornești și restaurezi un instantaneu depinde de încărcătorul de pornire cu care pornește computerul tău. Instalările noi UEFI folosesc systemd-boot; instalările mai vechi și computerele cu BIOS folosesc Limine. `omarchy-boot-backend` îți spune pe care îl ai.

## Cu systemd-boot

Alege _Sistem > Instantanee_ din meniul Omarchy și alege instantaneul în care vrei să pornești. Computerul repornește în el o singură dată. Sau ține apăsat Space în timp ce computerul pornește pentru a vedea meniul de pornire, unde fiecare instantaneu este listat de la cel mai nou la cel mai vechi, cu versiunea Omarchy și data lui.

Un instantaneu pornește cu un strat temporar deasupra, așa că îl poți folosi ca de obicei, dar orice modifici dispare la următoarea repornire. Pentru a-l păstra, fă-l sistemul tău: dă clic pe notificarea care apare când te autentifici, alege _Sistem > Instantanee > Restaurează acest instantaneu_ sau rulează `omarchy-snapshot restore`. Restaurarea are loc în timp ce computerul repornește. Sistemul, așa cum era înainte, rămâne în meniul de pornire ca _Înainte de restaurare_, iar `omarchy-snapshot restore backup` îl pune la loc.

Din terminal:

- `omarchy-snapshot list` listează instantaneele în care poți porni;
- `omarchy-snapshot boot 12` repornește o singură dată în instantaneul 12;
- `omarchy-snapshot restore 12` face din instantaneul 12 sistemul la următoarea repornire, iar `omarchy-snapshot restore --cancel` te răzgândește înainte de acea repornire.

## Cu Limine

Pentru a porni și restaura un instantaneu, îl selectezi din încărcătorul de pornire Limine. Meniul de pornire rămâne ascuns în mod implicit, așa că apasă orice tastă imediat ce pornește Limine pentru a-l afișa.

Din acel ecran, alege instantaneul în care vrei să pornești în funcție de dată și versiune. Versiunea Omarchy de la momentul instantaneului poate fi văzută în colțul din stânga jos.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Când ajungi înăuntru, va apărea o notificare care te anunță că ești într-un instantaneu pornibil și dacă dai clic pe ea, va începe procesul de restaurare. Alternativ, poți utiliza `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Ce acoperă o restaurare

O restaurare readuce sistemul tău de fișiere rădăcină, dar nu și `/home`-ul tău. Așa că funcționează pentru a anula o actualizare de sistem defectuoasă, dar nu pentru a recupera fișiere personale pierdute.

Asta înseamnă și că directorul tău `~/.config` este păstrat ca atare. Așa că dacă revii la o versiune mai veche a unei biblioteci sau aplicații care stochează fișiere de configurare într-un format nou, va trebui să rezolvi asta manual.

Același lucru este valabil și pentru evidența proprie a Omarchy privind migrările care au rulat deja: ea se află în directorul tău personal, așa că supraviețuiește restaurării. Migrările care au rulat după ce a fost făcut instantaneul rămân marcate ca finalizate, chiar dacă modificările pe care le-au făcut în sistemul de fișiere rădăcină au fost anulate, iar următorul `omarchy update` nu le va rula din nou. Așa că dacă actualizezi din nou după o restaurare și încă lipsește ceva ce configurase o actualizare anterioară, acesta este motivul probabil.
