# Instantanee de sistem

Creăm instantanee automat la fiecare actualizare Omarchy, dar, dacă ai vrea să-ți creezi propriile instantanee, poți folosi `omarchy-snapshot create`.

Ca să pornești și să restaurezi un instantaneu, îl selectezi din încărcătorul de pornire Limine. (Dacă în prezent pornești direct în ecranul de decriptare Omarchy, va trebui mai întâi să selectezi Limine ca opțiune de pornire prin BIOS).

Din acel ecran, alege instantaneul în care ai vrea să pornești pe baza datei și a versiunii. Versiunea Omarchy la momentul instantaneului poate fi văzută în colțul din stânga jos.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Când ajungi înăuntru, va apărea o notificare care te anunță că ești într-un instantaneu bootabil și, dacă faci clic pe ea, va porni procesul de restaurare. Alternativ, poți utiliza `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Asta îți va restaura sistemul de fișiere rădăcină, dar nu și `/home`. Așa că funcționează pentru revenirea dintr-o actualizare de sistem stricată, dar nu pentru recuperarea fișierelor personale pierdute.

Asta înseamnă și că directorul tău `~/.config` este păstrat ca atare. Așa că, dacă revii la o versiune anterioară a unei biblioteci sau a unei aplicații care stochează fișiere de configurare într-un format nou, va trebui să rezolvi asta manual.

_Notă: Această funcționalitate este disponibilă doar pe instalările care folosesc încărcătorul de pornire Limine, care este implicitul de la Omarchy 2.0. Nu este disponibilă dacă ești pe GRUB sau systemd-boot._

### Omiterea meniului de pornire

Dacă nu atingi niciodată meniul de pornire și vrei doar ca mașina să meargă direct la ecranul de decriptare, rulează _Configurare > Pornire directă_ în meniul Omarchy. Asta adaugă o intrare EFI care indică direct către Omarchy, astfel încât firmware-ul îl pornește fără să se oprească la Limine.

Compromisul este cel menționat la început: cu pornirea directă activată, ajungerea la un instantaneu înseamnă mai întâi să alegi Limine din meniul de pornire BIOS. Rulează din nou _Configurare > Pornire directă_ ca să elimini intrarea și să revii la pornirea prin Limine. Unele firmware-uri nu acceptă cu plăcere intrări EFI personalizate, așa că instalarea refuză să ruleze pe firmware American Megatrends și Apple.
