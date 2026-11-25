# Snimke sustava

Snimke izrađujemo automatski pri svakom ažuriranju Omarchyja, ali ako želite izraditi vlastitu, možete upotrijebiti `omarchy-snapshot create`.

Da biste pokrenuli i vratili snimku, odabirete je iz Limine boot loadera. Izbornik za pokretanje prema zadanim je postavkama skriven, pa pritisnite bilo koju tipku čim se Limine pokrene da biste ga prikazali.

Na tom zaslonu odaberite snimku koju želite pokrenuti na temelju datuma i verzije. Verziju Omarchyja u trenutku izrade snimke možete vidjeti u donjem lijevom kutu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kada uđete unutra, pojavit će se obavijest koja vas obavještava da ste u snimci koju je moguće pokrenuti i, ako kliknete na nju, pokrenut će postupak vraćanja. Alternativno, možete upotrijebiti `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Ovo će vratiti vaš korijenski datotečni sustav, ali ne i vaš `/home`. Dakle radi za poništavanje pokvarenog ažuriranja sustava, ali ne i za oporavak izgubljenih osobnih datoteka.

To također znači da vaš direktorij `~/.config` ostaje takav kakav jest. Dakle, ako se vraćate na raniju verziju biblioteke ili aplikacije koja konfiguracijske datoteke pohranjuje u novom formatu, morat ćete to riješiti ručno.

Isto vrijedi i za Omarchyjevu vlastitu evidenciju o tome koje su migracije već pokrenute: ona se nalazi u vašem početnom direktoriju, pa preživljava vraćanje. Migracije koje su pokrenute nakon izrade snimke ostaju označene kao dovršene, iako su promjene koje su napravile u korijenskom datotečnom sustavu poništene, i sljedeći `omarchy update` ih neće ponovno pokrenuti. Dakle, ako nakon vraćanja ponovno ažurirate i i dalje nedostaje nešto što je ranije ažuriranje postavilo, to je vjerojatni razlog.

_Napomena: Ova je značajka dostupna samo na instalacijama koje koriste Limine boot loader, koji je zadani od Omarchyja 2.0. Nije dostupna ako koristite GRUB ili systemd-boot._
