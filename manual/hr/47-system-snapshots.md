# Snimke sustava

Snimke automatski stvaramo pri svakom Omarchy ažuriranju, ali ako želite izraditi vlastitu, možete koristiti `omarchy-snapshot create`.

Za pokretanje i vraćanje snimke odaberite je iz Limine bootloadera. (Ako se trenutačno pokrećete izravno u Omarchy zaslon za dešifriranje, prvo ćete morati odabrati Limine kao opciju pokretanja putem BIOS-a).

S tog zaslona odaberite snimku u koju se želite pokrenuti na temelju datuma i inačice. Inačica Omarchyja u vrijeme snimke može se vidjeti u donjem lijevom kutu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kad stignete unutra, pojavit će se obavijest koja vas obavještava da ste u snimci koja se može pokrenuti i, ako je kliknete, započet će postupak vraćanja. Alternativno možete koristiti `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Time će se vratiti vaš korijenski datotečni sustav, ali ne i vaš `/home`. Pa radi za vraćanje pokvarenog ažuriranja sustava, ali ne i za oporavak izgubljenih osobnih datoteka.

To također znači da vaš direktorij `~/.config` ostaje kakav jest. Pa ako se vraćate na stariju inačicu biblioteke ili aplikacije koja pohranjuje konfiguracijske datoteke u novom formatu, to ćete morati riješiti ručno.

_Napomena: Ova je značajka dostupna samo na instalacijama koje koriste Limine bootloader, koji je zadani od Omarchyja 2.0. Nije dostupna ako ste na GRUB-u ili systemd-bootu._

### Preskakanje izbornika za pokretanje

Ako nikada ne dirate izbornik za pokretanje i samo želite da računalo ide izravno na zaslon za dešifriranje, pokrenite _Postavke > Direct Boot_ u Omarchy izborniku. Time se dodaje EFI zapis koji upućuje izravno na Omarchy, pa ga firmver pokreće bez zaustavljanja na Limineu.

Kompromis je onaj spomenut na vrhu: s uključenim izravnim pokretanjem, dolazak do snimke znači prvo odabrati Limine iz izbornika za pokretanje vašeg BIOS-a. Ponovno pokrenite _Postavke > Direct Boot_ za uklanjanje zapisa i povratak na pokretanje kroz Limine. Neki firmver ne voli prilagođene EFI zapise, pa postavljanje odbija pokretanje na American Megatrends i Apple firmveru.
