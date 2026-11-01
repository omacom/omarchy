# Rješavanje problema

### Pokvario sam sustav ažuriranjem!

Prvo pokušajte [vratiti sustav](47-system-snapshots.md) na verziju prije nedavnog ažuriranja. Ako to ne uspije, upotrijebite `omarchy-debug` da biste svoj problem podijelili na #omarchy-help u Discordu. A ako sve to zakaže, možete ponovno instalirati zadane konfiguracije i pakete pomoću `omarchy-reinstall`.

### Zašto su neke aplikacije tako velike na mojem zaslonu?

Omarchy pretpostavlja 2x zaslon visoke razlučivosti, pa `GDK_SCALE` postavlja na 2 dok ne odaberete skaliranje u ploči monitora. Ako ste na 1x zaslonu i GTK ili X11 aplikacije ispadnu prevelike, odaberite 1x za njega u ploči monitora ili dodajte `hl.env("GDK_SCALE", "1")` u `~/.config/hypr/monitors.lua` (a zatim ponovno pokrenite svaku aplikaciju koja je prevelika). Pogledajte [priručnik o monitorima](33-monitors.md).

Za Spotify možete upotrijebiti `Ctrl + Minus` da smanjite sučelje (a `Ctrl + Plus` da ga povećate).

### Zašto su mi sve kombinacije tipki sa Super prestale raditi?

Na nekim ASUS ROG i TUF prijenosnim računalima `Fn + Super` je kombinacija tipki koju je lako previdjeti, a njome se uključuje i isključuje firmversko zaključavanje Windows tipke (zamišljeno za igranje da slučajno ne izađete iz igre). Ništa na zaslonu ne govori vam da se to dogodilo. Dok je zaključavanje uključeno, Super uopće ništa ne šalje — pa svaka Omarchy kombinacija koja koristi Super jednostavno prestane raditi i izgleda kao da se Hyprland pokvario.

Prije nego što krenete kopati po `~/.config/hypr/`, jednom pritisnite `Fn + Super`, a ako to ne vrati Super, pritisnite ga ponovno da zaključavanje ne ostane uključeno. To nije Fn-lock, koji mijenja samo što radi red F-tipki.

### Moji Wi-Fi, Bluetooth, zvuk ili trackpad upravo su prestali raditi

Prije ponovnog pokretanja pokušajte zasebno ponovno pokrenuti podsustav koji pravi probleme. _Ažuriranje > Hardver_ u Omarchy izborniku ima Wi-Fi, Bluetooth, Zvuk i Trackpad, a ponovno učitavanje jednog od njih rješava većinu situacija tipa „radilo je prije pet minuta” — Bluetooth slušalice koje se neće ponovno povezati, trackpad koji je prestao raditi nakon suspendiranja, zvuk koji je nestao kad ste isključili monitor.

### Zašto moji vanjski zvučnici ne sviraju?

Vjerojatno zato što nisu postavljeni kao primarni izlaz. Kliknite ikonu zvučnika na desnoj strani trake i otvorit će se skočni prozor za glasnoću u kojem možete odabrati izlazni uređaj (i miksati glasnoće po aplikaciji).

### Zvučnici mojeg prijenosnog računala zvuče čudno

Na nekim prijenosnim računalima Omarchy automatski primjenjuje ugađanje zvučnika koje ispravlja frekvencijski odziv ugrađenih zvučnika. `omarchy audio tuning status` govori vam je li neko ugađanje aktivno na vašem računalu, a `omarchy audio tuning off` isključuje ga ako radije želite čuti sirov zvuk zvučnika.

### Zašto se ne mogu prijaviti ili koristiti sudo svojom lozinkom?

Vjerojatno ste je previše puta pogrešno upisali i zaključali ste se van. Ako se to događa na zaključanom zaslonu, možete pritisnuti `CTRL + ALT + F2` da pokrenete novi TTY u kojem se možete prijaviti kao root, a zatim pokrenuti `faillock --reset --user [your-username]`. To će resetirati zaključavanje i spremni ste za dalje.

### Lozinka mi je prihvaćena, ali vraćam se na zaslon za prijavu

Neispravna datoteka okruženja sesije može spriječiti pokretanje radne površine čak i kad je vaša lozinka točna. To posebno vrijedi provjeriti nakon uređivanja `~/.config/uwsm/env.d/`.

Pritisnite `Ctrl + Alt + F2`, prijavite se svojim uobičajenim korisničkim imenom i lozinkom i pregledajte korisnički dnevnik trenutnog pokretanja:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Potražite pogrešku koja imenuje jednu od vaših datoteka okruženja, kao što je `bad substitution`, odmah prije poruke da oznaka izlaza okruženja nije pronađena. Prije ponovnog pokušaja prijave premjestite tu datoteku iz `env.d`. Na primjer, ako pogreška imenuje `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM preskače datoteku sa sintaksnom pogreškom, ali fatalna pogreška koja se pojavi tek dok se datoteka izvodi, kao što je `bad substitution`, i dalje može spriječiti pokretanje radne površine. Vraćanje sustava na snimku sustava ne popravlja te datoteke jer se `/home` ne vraća.

Kad se ponovno budete mogli prijaviti, popravite spremljenu kopiju prije nego što je vratite natrag. `sh -n` hvata sintaksne pogreške bez pokretanja datoteke, ali ne može uhvatiti svaku pogrešku koja se pojavi kad se datoteka učitava kao izvor. Dok testirate promjene, držite otvoren terminal koji radi.

### Zašto se ne pojavljuju upiti za autorizaciju 1Passworda za 1Password SSH Agent / CLI?

To se može dogoditi iz 2 razloga:

Da bi se pojavio bogati upit za odobrenje, opcija Postavke > Napredno > Koristi hardversko ubrzanje mora biti uključena. _Napomena: Da bi počelo raditi, potrebno je ponovno pokretanje._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ili ako niste pokrenuli 1Password od podizanja sustava, upit se neće pojaviti.
