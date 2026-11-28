# Rješavanje problema

### Pokvario sam sustav ažuriranjem!

Prvo pokušajte [vratiti sustav](47-system-snapshots.md) na verziju prije nedavnog ažuriranja. Ako to ne uspije, upotrijebite `omarchy-debug` da podijelite svoj problem na #omarchy-help na Discordu. A ako sve to ne uspije, možete ponovno instalirati zadane konfiguracije i pakete pomoću `omarchy-reinstall`.

### Zašto su neke aplikacije tako velike na mom zaslonu?

Omarchy pretpostavlja zaslon visoke rezolucije s faktorom 2x, pa postavlja `GDK_SCALE` na 2 dok ne odaberete faktor skaliranja na ploči monitora. Ako ste na zaslonu s faktorom 1x, a GTK ili X11 aplikacije ispadnu prevelike, odaberite 1x za njega na ploči monitora ili dodajte `hl.env("GDK_SCALE", "1")` u `~/.config/hypr/monitors.lua` (a zatim ponovno pokrenite svaku aplikaciju koja je prevelika). Pogledajte [priručnik o monitorima](33-monitors.md).

Za Spotify možete koristiti `Ctrl + Minus` da smanjite sučelje (a `Ctrl + Plus` da ga povećate).

### Zašto su sve moje kombinacije tipki sa Super prestale raditi?

Na nekim prijenosnim računalima ASUS ROG i TUF, `Fn + Super` kombinacija je koju je lako previdjeti, a uključuje i isključuje zaključavanje tipke Windows u firmwareu (namijenjeno igranju kako slučajno ne biste izašli iz igre). Ništa na zaslonu ne govori vam da se to dogodilo. Dok je zaključavanje uključeno, Super uopće ništa ne emitira — pa svaka Omarchy kombinacija koja koristi Super jednostavno prestaje raditi i izgleda kao da se Hyprland pokvario.

Pritisnite `Fn + Super` jednom prije nego što počnete kopati po `~/.config/hypr/`, a ako to ne vrati Super, pritisnite ga ponovno kako ne biste ostavili zaključavanje uključeno. To nije Fn-lock, koji mijenja samo ono što radi red F-tipki.

### Moj Wi-Fi, Bluetooth, zvuk ili trackpad upravo su prestali raditi

Prije ponovnog pokretanja pokušajte zasebno ponovno pokrenuti problematični podsustav. _Update > Hardware_ u izborniku Omarchy ima Wi-Fi, Bluetooth, Audio i Trackpad, a ponovno učitavanje jednog od njih rješava većinu situacija „radilo je prije pet minuta“ — Bluetooth slušalice koje se ne žele ponovno povezati, trackpad koji je prestao raditi nakon obustave, zvuk koji je nestao kada ste isključili monitor.

### Zašto moji vanjski zvučnici ne sviraju?

Vjerojatno zato što nisu postavljeni kao primarni izlaz. Kliknite ikonu zvučnika na desnoj strani trake i otvorit će se skočni prozor za glasnoću u kojem možete odabrati izlazni uređaj (i miješati i glasnoću po aplikaciji).

### Zvučnici mog prijenosnog računala zvuče čudno

Na nekim prijenosnim računalima Omarchy automatski primjenjuje ugađanje zvučnika koje ispravlja frekvencijski odziv ugrađenih zvučnika. `omarchy audio tuning status` govori vam je li neko ugađanje aktivno na vašem računalu, a `omarchy audio tuning off` isključuje ga ako radije želite čuti zvučnike sirovo.

### Zašto se ne mogu prijaviti ni koristiti sudo sa svojom lozinkom?

Vjerojatno ste je deset puta pogrešno upisali i zaključali ste se van. Zaključavanje se samo od sebe uklanja nakon dvije minute. Ako ne možete čekati, a ovo se događa na zaključanom zaslonu, možete pritisnuti `CTRL + ALT + F2` da pokrenete novi TTY u kojem se možete prijaviti kao root, a zatim pokrenite `faillock --reset --user [your-username]`. To će resetirati zaključavanje i spremni ste za dalje.

### Lozinka mi je prihvaćena, ali vraćam se na zaslon za prijavu

Pokvarena datoteka okruženja sesije može spriječiti pokretanje radne površine čak i kada je vaša lozinka ispravna. To posebno vrijedi provjeriti nakon uređivanja `~/.config/uwsm/env.d/`.

Pritisnite `Ctrl + Alt + F2`, prijavite se svojim uobičajenim korisničkim imenom i lozinkom i pregledajte korisnički dnevnik trenutnog pokretanja:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Potražite pogrešku koja imenuje jednu od vaših datoteka okruženja, kao što je `bad substitution`, neposredno prije poruke da oznaka izlaza okruženja nije pronađena. Premjestite tu datoteku iz `env.d` prije nego što se ponovno pokušate prijaviti. Na primjer, ako pogreška imenuje `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM preskače datoteku sa sintaksnom pogreškom, ali fatalna pogreška koja se pojavljuje tek dok se datoteka izvodi, kao što je `bad substitution`, i dalje može spriječiti pokretanje radne površine. Vraćanje snimke sustava ne popravlja ove datoteke jer se `/home` ne vraća.

Kada se budete mogli prijaviti, popravite spremljenu kopiju prije nego što je vratite natrag. `sh -n` hvata sintaksne pogreške bez pokretanja datoteke, ali ne može uhvatiti svaku pogrešku koja se pojavi kada se datoteka učitava. Držite ispravan terminal otvoren dok testirate promjene.

### Zašto se ne pojavljuju upiti za autorizaciju aplikacije 1Password za 1Password SSH Agent / CLI?

To se može dogoditi iz 2 razloga:

Da bi se pojavio bogati upit za odobrenje, Settings > Advanced > Use Hardware Acceleration mora biti uključeno. _Napomena: Da bi počelo raditi, potrebno je ponovno pokretanje._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ili ako niste pokrenuli 1Password od pokretanja sustava, upit se neće pojaviti.
