# Snimke sustava

Automatski stvaramo snimke pri svakom ažuriranju Omarchyja, ali ako želite stvoriti vlastitu, možete upotrijebiti `omarchy-snapshot create`.

Za pokretanje i vraćanje snimke odaberite je iz Limine boot loadera. (Ako se trenutačno pokrećete izravno na zaslon za dešifriranje Omarchyja, prvo ćete morati odabrati Limine kao opciju pokretanja putem BIOS-a).

Na tom zaslonu odaberite snimku u koju se želite pokrenuti na temelju datuma i verzije. Verzija Omarchyja u trenutku snimke vidi se u donjem lijevom kutu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kad uđete unutra, pojavit će se obavijest koja vas obavještava da ste u snimci s koje se može pokrenuti sustav i, ako je kliknete, pokrenut će postupak vraćanja. Alternativno, možete upotrijebiti `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Time ćete vratiti root datotečni sustav, ali ne i `/home`. Dakle, to funkcionira za poništavanje neispravnog ažuriranja sustava, ali ne i za oporavak izgubljenih osobnih datoteka.

To također znači da vaš direktorij `~/.config` ostaje kakav jest. Dakle, ako se vraćate na raniju verziju biblioteke ili aplikacije koja pohranjuje konfiguracijske datoteke u novom formatu, morat ćete to riješiti ručno.

Isto vrijedi i za Omarchyjevu vlastitu evidenciju o tome koje su migracije već pokrenute: ona se nalazi u vašem početnom direktoriju, pa preživljava vraćanje. Migracije koje su pokrenute nakon što je snimka snimljena ostaju označene kao dovršene, iako su promjene koje su napravile u root datotečnom sustavu poništene, a sljedeće `omarchy update` ih neće ponovno pokrenuti. Dakle, ako nakon vraćanja ponovno ažurirate i nešto što je ranije ažuriranje postavilo i dalje nedostaje, to je vjerojatni razlog.

_Napomena: Ova je značajka dostupna samo na instalacijama koje koriste Limine boot loader, koji je zadani od Omarchyja 2.0. Nije dostupna ako koristite GRUB ili systemd-boot._

### Preskakanje izbornika za pokretanje

Ako nikad ne dirate izbornik za pokretanje i samo želite da se računalo pokrene izravno na zaslon za dešifriranje, pokrenite _Setup > Direct Boot_ u izborniku Omarchyja. Time se dodaje EFI unos koji upućuje izravno na Omarchy, pa ga firmware pokreće bez zaustavljanja na Limineu.

Kompromis je onaj spomenut na početku: s uključenim izravnim pokretanjem, dolazak do snimke znači da prvo morate odabrati Limine iz izbornika za pokretanje u BIOS-u. Ponovno pokrenite _Setup > Direct Boot_ da biste uklonili unos i vratili se na pokretanje putem Liminea. Neki firmware ne podnosi dobro prilagođene EFI unose, pa se postavljanje odbija pokrenuti na firmwareu American Megatrends i Apple.
