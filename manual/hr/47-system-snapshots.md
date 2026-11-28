# Snimke sustava

Snimke stvaramo automatski pri svakoj nadogradnji Omarchyja, ali ako želite stvoriti vlastitu, možete upotrijebiti `omarchy-snapshot create`.

Način na koji pokrećete i vraćate snimku ovisi o učitavaču pokretanja s kojim se vaše računalo pokreće. Nove UEFI instalacije koriste systemd-boot; starije instalacije i BIOS računala koriste Limine. `omarchy-boot-backend` govori vam koji imate.

## Sa systemd-bootom

U izborniku Omarchy odaberite _Sustav > Snimke_ i odaberite snimku u koju se želite pokrenuti. Računalo se jednom ponovno pokreće u nju. Ili držite Space dok se računalo pokreće za prikaz izbornika pokretanja, u kojem je svaka snimka navedena od najnovije prema najstarijoj, sa svojom verzijom Omarchyja i datumom.

Snimka se pokreće s privremenim slojem na vrhu, pa je možete koristiti kao i obično, ali sve što promijenite nestaje pri sljedećem ponovnom pokretanju. Da biste je zadržali, učinite je svojim sustavom: kliknite obavijest koja se pojavi kada se prijavite, odaberite _Sustav > Snimke > Vrati ovu snimku_ ili pokrenite `omarchy-snapshot restore`. Vraćanje se događa dok se računalo ponovno pokreće. Sustav kakav je bio prije ostaje u izborniku pokretanja kao _Prije vraćanja_, a `omarchy-snapshot restore backup` vraća ga natrag.

Iz terminala:

- `omarchy-snapshot list` navodi snimke u koje se možete pokrenuti;
- `omarchy-snapshot boot 12` jednom se ponovno pokreće u snimku 12;
- `omarchy-snapshot restore 12` čini snimku 12 sustavom pri sljedećem ponovnom pokretanju, a `omarchy-snapshot restore --cancel` poništava vašu odluku prije tog ponovnog pokretanja.

## S Limineom

Za pokretanje i vraćanje snimke odabirete je iz učitavača pokretanja Limine. Izbornik pokretanja prema zadanim postavkama ostaje skriven, pa pritisnite bilo koju tipku čim se Limine pokrene da biste ga prikazali.

S tog zaslona odaberite snimku u koju se želite pokrenuti na temelju datuma i verzije. Verzija Omarchyja u vrijeme snimke može se vidjeti u donjem lijevom kutu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kada uđete unutra, pojavit će se obavijest koja vas obavještava da ste u snimci s mogućnošću pokretanja i ako je kliknete, pokrenut će postupak vraćanja. Alternativno, možete upotrijebiti `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Što vraćanje obuhvaća

Vraćanje vraća vaš korijenski datotečni sustav, ali ne i vaš `/home`. Dakle, radi za poništavanje neispravne nadogradnje sustava, ali ne i za oporavak izgubljenih osobnih datoteka.

To također znači da vaš direktorij `~/.config` ostaje kakav jest. Dakle, ako se vraćate na raniju verziju biblioteke ili aplikacije koja konfiguracijske datoteke pohranjuje u novom formatu, morat ćete to riješiti ručno.

Isto vrijedi i za Omarchyjevu vlastitu evidenciju o tome koje su migracije već pokrenute: ona se nalazi u vašem početnom direktoriju, pa preživljava vraćanje. Migracije koje su pokrenute nakon što je snimka snimljena ostaju označene kao dovršene, iako su promjene koje su napravile u korijenskom datotečnom sustavu poništene, a sljedeći `omarchy update` neće ih ponovno pokrenuti. Dakle, ako ponovno nadogradite nakon vraćanja i nešto što je ranija nadogradnja postavila i dalje nedostaje, to je vjerojatni razlog.
