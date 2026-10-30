# Rješavanje problema

### Pokvario sam sustav ažuriranjem!

Prvo pokušajte [vratiti sustav](47-system-snapshots.md) na verziju prije nedavnog ažuriranja. Ako to ne uspije, pomoću `omarchy-debug` podijelite svoj problem na #omarchy-help u Discordu. A ako sve to ne uspije, možete ponovno instalirati zadane konfiguracije i pakete pomoću `omarchy-reinstall`.

### Zašto su neke aplikacije tako velike na mom zaslonu?

Omarchy pretpostavlja 2x zaslon visoke razlučivosti, što zahtijeva postavljanje `GDK_SCALE` na 2 u `~/.config/hypr/monitors.lua`. No ako ste na 1x zaslonu, možete promijeniti `local omarchy_gdk_scale = 2` u 1 (a zatim ponovno pokrenite svaku aplikaciju koja je prevelika). Pogledajte [priručnik o monitorima](33-monitors.md).

Za Spotify možete koristiti `Ctrl + Minus` za smanjivanje sučelja (i `Ctrl + Plus` za povećavanje).

### Zašto su sve moje kombinacije tipki sa Super prestale raditi?

Na nekim prijenosnim računalima ASUS ROG i TUF, `Fn + Super` lako je previdjeti kao kombinaciju koja uključuje i isključuje zaključavanje Windows tipke u firmveru (namijenjeno za igranje, da slučajno ne izađete iz igre). Ništa na zaslonu ne govori vam da se to dogodilo. Dok je zaključavanje uključeno, Super uopće ništa ne šalje — pa svaka Omarchy kombinacija koja koristi Super jednostavno prestane raditi i izgleda kao da se Hyprland pokvario.

Pritisnite `Fn + Super` jednom prije nego što počnete kopati po `~/.config/hypr/`, a ako to ne vrati Super, pritisnite je ponovno da ne ostavite zaključavanje uključeno. To nije Fn-lock, koji mijenja samo ono što radi red F-tipki.

### Moj Wi-Fi, Bluetooth, zvuk ili trackpad upravo je prestao raditi

Prije ponovnog pokretanja pokušajte zasebno ponovno pokrenuti podsustav koji stvara probleme. _Update > Hardware_ u izborniku Omarchy ima Wi-Fi, Bluetooth, Audio i Trackpad, a ponovno učitavanje jednog od njih rješava većinu situacija tipa „radilo je prije pet minuta“ — Bluetooth slušalice koje se ne žele ponovno povezati, trackpad koji je prestao raditi nakon suspendiranja, zvuk koji je nestao kad ste isključili monitor.

### Zašto moji vanjski zvučnici ne sviraju?

Vjerojatno zato što nisu postavljeni kao primarni izlaz. Kliknite ikonu zvučnika na desnoj strani trake i otvorit će se skočni prozor za glasnoću u kojem možete odabrati izlazni uređaj (i miješati glasnoću za svaku aplikaciju).

### Zvučnici mog prijenosnog računala zvuče čudno

Na nekim prijenosnim računalima Omarchy automatski primjenjuje ugađanje zvučnika koje ispravlja frekvencijski odziv ugrađenih zvučnika. `omarchy audio tuning status` govori vam je li neko ugađanje aktivno na vašem računalu, a `omarchy audio tuning off` isključuje ga ako radije želite čuti zvučnike bez obrade.

### Zašto se ne mogu prijaviti ili koristiti sudo svojom lozinkom?

Vjerojatno ste je previše puta pogrešno upisali i zaključali ste se van. Ako se to događa na zaslonu za zaključavanje, možete pritisnuti `CTRL + ALT + F2` za pokretanje novog TTY-ja u kojem se možete prijaviti kao root, zatim pokrenuti `faillock --reset --user [your-username]`. To će poništiti zaključavanje i spremni ste za dalje.

### Zašto se ne pojavljuju moji upiti za autorizaciju 1Passworda za 1Password SSH Agent / CLI?

To se može dogoditi iz 2 razloga:

Da bi se pojavio bogati upit za odobrenje, Settings > Advanced > Use Hardware Acceleration mora biti uključen. _Napomena: Da bi počelo raditi, potrebno je ponovno pokretanje._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ili ako niste pokrenuli 1Password od pokretanja sustava, upit se neće pojaviti.
