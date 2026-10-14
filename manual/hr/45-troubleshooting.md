# Rješavanje problema

### Pokvario sam sustav ažuriranjem!

Prvo pokušajte [vratiti svoj sustav](47-system-snapshots.md) na inačicu prije nedavnog ažuriranja. Ako to ne uspije, upotrijebite `omarchy-debug` da svoj problem podijelite na #omarchy-help na Discordu. A ako sve to zakaže, zadane konfiguracije i pakete možete ponovno instalirati pomoću `omarchy-reinstall`.

### Zašto su neke aplikacije tako velike na mojem zaslonu?

Omarchy pretpostavlja zaslon visoke razlučivosti 2x, što zahtijeva postavljanje `GDK_SCALE` na 2 u `~/.config/hypr/monitors.lua`. Ali ako ste na zaslonu 1x, možete promijeniti `local omarchy_gdk_scale = 2` u 1 (a zatim ponovno pokrenuti svaku aplikaciju koja je prevelika). Pogledajte [priručnik o monitorima](33-monitors.md).

Za Spotify možete koristiti `Ctrl + Minus` za smanjenje korisničkog sučelja (i `Ctrl + Plus` za povećanje).

### Moj Wi-Fi, Bluetooth, zvuk ili dodirna pločica upravo su prestali raditi

Prije nego što ponovno pokrenete računalo, pokušajte samostalno ponovno pokrenuti problematični podsustav. _Ažuriraj > Hardware_ u Omarchy izborniku ima Wi-Fi, Bluetooth, Audio i Trackpad, a ponovno učitavanje jednog od njih rješava većinu situacija tipa „radilo je prije pet minuta“ — Bluetooth slušalice koje se ne žele ponovno povezati, dodirnu pločicu koja je umrla nakon obustave, zvuk koji je nestao kad ste isključili monitor.

### Zašto moji vanjski zvučnici ne sviraju?

Vjerojatno zato što nisu postavljeni kao primarni izlaz. Kliknite ikonu zvučnika na desnoj strani trake i otvorit će se skočni prozor za glasnoću u kojem možete odabrati izlazni uređaj (i miješati glasnoće po aplikaciji također).

### Zvučnici mojeg prijenosnog računala zvuče čudno

Na nekim prijenosnim računalima Omarchy automatski primjenjuje ugađanje zvučnika koje ispravlja frekvencijski odziv ugrađenih zvučnika. `omarchy audio tuning status` govori vam je li neko aktivno na vašem računalu, a `omarchy audio tuning off` ga isključuje ako zvučnike radije slušate sirove.

### Zašto se ne mogu prijaviti ili koristiti sudo sa svojom lozinkom?

Vjerojatno ste je previše puta pogrešno upisali i zaključali ste se. Ako se to događa na zaslonu za zaključavanje, možete pritisnuti `CTRL + ALT + F2` za pokretanje novog TTY-ja u kojem se možete prijaviti kao root, a zatim pokrenuti `faillock --reset --user [your-username]`. Time se resetira zaključavanje i spremni ste.

### Zašto se moji 1Password upiti za odobrenje za 1Password SSH Agent / CLI ne pojavljuju?

To se može dogoditi iz 2 razloga:

Kako bi se pojavio bogati upit za odobrenje, Settings > Advanced > Use Hardware Acceleration mora biti uključen. _Napomena: Za početak rada potrebno je ponovno pokretanje._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ili ako niste pokrenuli 1Password od pokretanja računala, upit se neće pojaviti.
