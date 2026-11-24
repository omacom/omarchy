# Ažuriranja

Omarchy i vaši paketi održavaju se ažurnima putem _Ažuriranje > Omarchy_ u izborniku Omarchy (`Super + Space`).

Sam Omarchy instaliran je kao obični pacman paketi iz [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), pa ažuriranje instalira [najnovije izdanje Omarchyja](https://github.com/omacom/omarchy/releases), pokreće sve migracije na čekanju kako bi vaš sustav uskladio s najnovijim, i ažurira sve sistemske pakete iz [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) i [AUR](https://aur.archlinux.org/) (ako ste instalirali bilo kakve AUR pakete).

Kada budu objavljena nova izdanja, desno od vašeg sata pojavit će se ikona kružne strelice. Kliknite je i postupak ažuriranja će započeti.

![update-available](images/update-available.webp)

### Četiri kanala

Omarchy se ažurira kroz četiri kanala: stable, RC, edge i dev. Nove instalacije započinju na kanalu stable, koji prati [službena izdanja](https://github.com/omacom/omarchy/releases/), kao i [stabilni Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) koji kasni jedan mjesec za najnovijim, kako bismo mogli uhvatiti sve nove nekompatibilnosti koje zahtijevaju promjene konfiguracije prije nego što ljudima prouzroče probleme.

Ali ako želite pomoći u uočavanju tih potencijalnih problema, možete koristiti kanal edge. To će vaše Omarchy pakete održavati na najnovijim razvojnim buildovima i omogućuje vam ažuriranje na najnovije Arch pakete čim postanu dostupni. To biste trebali činiti samo ako ste iskusni s Linuxom i znate kako oporaviti sustav koji ima problema.

Prije svakog novog većeg izdanja, završnu ćemo validaciju provoditi pomoću kanala RC. Ako ste zainteresirani pomoći u završnom dotjerivanju, dođite družiti se u #omarchy-release-candidates na Discordu.

Na kraju, tu je kanal dev, koji Omarchy povezuje izravno s git checkoutom izvornog koda u `~/omarchy`, u kombinaciji s paketima edge. Ovaj kanal trebali biste koristiti samo ako ste iskusan korisnik Linuxa, radite izravno na Omarchyju i spremni ste tolerirati lomove.

Između kanala možete se prebacivati pomoću _Ažuriranje > Kanal_ iz izbornika Omarchy (ili `omarchy channel set <stable|rc|edge|dev>` u terminalu, uz `omarchy channel current` da vidite gdje ste).

### Prebacivanje kernela

Omarchy podiže vlastiti kernel `linux-omarchy`, ali uz njega možete imati instalirane i druge, poput standardnog Arch kernela `linux` ili eksperimentalnog builda koji testirate. Kada ih ima više od jednog, _Ažuriranje > Kernel_ u izborniku Omarchy navodi ih s kvačicom pored onoga koji se podiže prema zadanim postavkama. Odaberite drugi, jednom unesite lozinku i on će se podići nakon sljedećeg ponovnog pokretanja. Ostali kerneli ostaju u izborniku za podizanje sustava, pa i dalje možete ručno odabrati jedan ako vam novi zadani stvara probleme. U terminalu, `omarchy kernel` prikazuje trenutni zadani, `omarchy kernel list` što je instalirano, a `omarchy kernel set <kernel>` služi za prebacivanje.

### Ažuriranja firmwarea

Nisu samo vaši paketi ono što zastarijeva. Mnogi prijenosnici i periferni uređaji isporučuju BIOS, SSD i firmware za dock putem Linux Vendor Firmware Service, a _Ažuriranje > Firmware_ u izborniku Omarchy dohvatit će i instalirati sve što vaš hardver čeka. Pri prvom pokretanju instalira `fwupd`. Dosta firmwarea može se zapisati samo tijekom ponovnog pokretanja, pa se nemojte iznenaditi ako vas zatraži jedno.

Kada trebate promijeniti postavku u samom BIOS-u, držite `Alt` u izborniku sustava (`Super + Escape`) i _Ponovno pokretanje_ pretvara se u _Ponovno pokretanje u BIOS_, što ponovno pokreće izravno u postavke firmwarea bez potrebe da hvatate pravu tipku pri podizanju sustava. Iz terminala, to je `omarchy system firmware`.

### Upozorenje o izravnim pacman/yay ažuriranjima

Ako ste već upoznati s Archom, možda ćete doći u iskušenje da sami samo pokrenete `pacman -Syu` ili `yay -Syu`, ali ako to učinite, propustit ćete snapshot, migracije i ažuriranja konfiguracije koje Omarchy pokreće zajedno s novim paketima. Zato će Omarchy zapravo zaustaviti izravnu nadogradnju sustava i uputiti vas na `omarchy update`. (Ako doista znate što radite, zaštita će vam reći kako je zaobići za jednu transakciju.)

### Vraćanje loših ažuriranja

Ako ikada imate problem nakon što napravite ažuriranje, možete vratiti sustav na snapshot snimljen prije ažuriranja. Samo ponovno pokrenite i odaberite snapshot u izborniku za podizanje sustava iz vremena prije nego što ste započeli ažuriranje.

![bootloader](images/bootloader.webp)

Ako su vaše konfiguracijske datoteke nekako oštećene, možete također izvršiti ponovnu instalaciju Omarchyja pomoću `omarchy reinstall` u terminalu. To će ponovno instalirati sve zadane Omarchy pakete, staviti vas na stable (edge na Apple Silicon) i vratiti na stariju verziju sve pakete koji su previše novi, te resetirati sve konfiguracijske datoteke. Imajte na umu da će sve vaše korisničke promjene konfiguracije zadanih postavki Omarchyja pri tome biti prepisane!
