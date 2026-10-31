# Rješavanje problema

### Pokvario sam sustav ažuriranjem!

Najprije pokušajte [vratiti sustav](47-system-snapshots.md) na verziju prije nedavnog ažuriranja. Ako to ne uspije, upotrijebite `omarchy-debug` da svoj problem podijelite na kanalu #omarchy-help na Discordu. A ako ni to ne uspije, zadane konfiguracije i pakete možete ponovno instalirati pomoću `omarchy-reinstall`.

### Zašto su neke aplikacije tako velike na mojem zaslonu?

Omarchy pretpostavlja 2x zaslon visoke razlučivosti pa postavlja `GDK_SCALE` na 2 dok ne odaberete mjerilo na ploči za monitor. Ako imate 1x zaslon, a GTK ili X11 aplikacije ispadnu prevelike, odaberite 1x za njega na ploči za monitor ili dodajte `hl.env("GDK_SCALE", "1")` u `~/.config/hypr/monitors.lua` (a zatim ponovno pokrenite svaku aplikaciju koja je prevelika). Pogledajte [priručnik o monitorima](33-monitors.md).

Za Spotify možete upotrijebiti `Ctrl + Minus` za smanjivanje korisničkog sučelja (i `Ctrl + Plus` za povećavanje).

### Zašto su sve moje prečice s tipkom Super prestale raditi?

Na nekim prijenosnim računalima ASUS ROG i TUF `Fn + Super` kombinacija je koju je lako previdjeti, a njome se uključuje i isključuje firmversko zaključavanje tipke Windows (namijenjeno igranju da slučajno ne izađete iz igre). Ništa na zaslonu ne govori vam da se to dogodilo. Dok je zaključavanje uključeno, Super ne šalje baš ništa — pa svaka Omarchy prečica koja upotrebljava Super jednostavno prestane raditi i izgleda kao da se Hyprland pokvario.

Pritisnite `Fn + Super` jednom prije nego što počnete kopati po `~/.config/hypr/`, a ako vam to ne vrati Super, pritisnite je ponovno da zaključavanje ne ostane uključeno. To nije Fn-lock, koji mijenja samo što radi red F-tipki.

### Moji Wi-Fi, Bluetooth, zvuk ili trackpad upravo su prestali raditi

Prije ponovnog pokretanja računala pokušajte samostalno ponovno pokrenuti problematični podsustav. U Omarchy izborniku pod _Update > Hardware_ nalaze se Wi-Fi, Bluetooth, Audio i Trackpad, a ponovno učitavanje jednog od njih rješava većinu situacija tipa „radilo je prije pet minuta“ — Bluetooth slušalice koje se neće ponovno povezati, trackpad koji je prestao raditi nakon suspendiranja, zvuk koji je nestao kad ste isključili monitor.

### Zašto moji vanjski zvučnici ne sviraju?

Vjerojatno zato što nisu postavljeni kao primarni izlaz. Kliknite ikonu zvučnika na desnoj strani trake i otvorit će se skočni prozor za glasnoću u kojem možete odabrati izlazni uređaj (i podešavati glasnoću za svaku aplikaciju zasebno).

### Zvučnici mojeg prijenosnog računala zvuče čudno

Na nekim prijenosnim računalima Omarchy automatski primjenjuje podešavanje zvučnika koje ispravlja frekvencijski odziv ugrađenih zvučnika. `omarchy audio tuning status` govori vam je li neko podešavanje aktivno na vašem računalu, a `omarchy audio tuning off` isključuje ga ako zvučnike radije slušate bez ikakve obrade.

### Zašto se ne mogu prijaviti ni koristiti sudo sa svojom lozinkom?

Vjerojatno ste je previše puta pogrešno upisali pa ste zaključani. Ako se to događa na zaključanom zaslonu, možete pritisnuti `CTRL + ALT + F2` da pokrenete novi TTY na kojem se možete prijaviti kao root, a zatim pokrenuti `faillock --reset --user [your-username]`. Time ćete poništiti zaključavanje i možete nastaviti.

### Zašto se moji upiti za autorizaciju aplikacije 1Password za 1Password SSH Agent / CLI ne pojavljuju?

To se može dogoditi iz 2 razloga:

Da bi se pojavio bogati upit za odobrenje, opcija Settings > Advanced > Use Hardware Acceleration mora biti uključena. _Napomena: Da bi počela raditi, potrebno je ponovno pokretanje računala._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ili, ako od pokretanja računala niste pokrenuli 1Password, upit se neće pojaviti.
