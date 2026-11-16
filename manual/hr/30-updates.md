# Ažuriranja

Omarchy i vaši paketi održavaju se ažurnima putem _Ažuriranje > Omarchy_ u izborniku Omarchy (`Super + Space`).

Sam Omarchy instaliran je kao obični pacman paketi iz [repozitorija paketa Omarchy](https://github.com/omacom-io/omarchy-pkgs), pa ažuriranje instalira [najnovije izdanje Omarchyja](https://github.com/omacom/omarchy/releases), pokreće sve migracije na čekanju kako bi vaš sustav uskladilo s najnovijim i ažurira sve sistemske pakete iz [Omarchy Arch Mirrora](https://github.com/omacom-io/omarchy-mirror) i [AUR-a](https://aur.archlinux.org/) (ako ste instalirali bilo kakve AUR pakete).

Kada izađu nova izdanja, desno od vašeg sata pojavit će se ikona kružne strelice. Kliknite je i postupak ažuriranja će započeti.

![update-available](images/update-available.webp)

### Četiri kanala

Omarchy se ažurira kroz četiri kanala: stable, RC, edge i dev. Nove instalacije započinju na kanalu stable, koji prati [službena izdanja](https://github.com/omacom/omarchy/releases/), kao i [stabilni Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) koji kasni mjesec dana za najnovijim, kako bismo mogli uhvatiti sve nove nekompatibilnosti koje zahtijevaju promjene konfiguracije prije nego što ljudima stvore probleme.

Ali ako želite pomoći u otkrivanju tih potencijalnih problema, možete koristiti kanal edge. Tako će vaši Omarchy paketi i dalje pratiti najnovije razvojne buildove i moći ćete se ažurirati na najnovije Arch pakete čim postanu dostupni. To biste trebali raditi samo ako ste iskusni s Linuxom i znate kako oporaviti sustav koji ima problema.

Prije svakog novog velikog izdanja završnu provjeru obavljat ćemo pomoću kanala RC. Ako ste zainteresirani za pomoć pri završnom dotjerivanju, svratite na #omarchy-release-candidates na Discordu.

Naposljetku, tu je kanal dev, koji Omarchy izravno povezuje s git checkoutom izvornog koda u `~/omarchy`, u kombinaciji s paketima edge. Ovaj kanal trebali biste koristiti samo ako ste iskusan korisnik Linuxa, radite izravno na Omarchyju i spremni ste tolerirati lomove.

Kanale možete mijenjati pomoću _Ažuriranje > Kanal_ iz izbornika Omarchy (ili `omarchy-channel-set` u terminalu).

### Mijenjanje kernela

Omarchy pokreće vlastiti kernel `linux-omarchy`, ali uz njega možete imati instalirane i druge, poput standardnog Arch kernela `linux` ili eksperimentalnog builda koji testirate. Kada ih ima više od jednog, _Ažuriranje > Kernel_ u izborniku Omarchy navodi ih s kvačicom pokraj onoga koji se prema zadanim postavkama pokreće. Odaberite drugi, jednom unesite lozinku i on će se pokrenuti nakon sljedećeg ponovnog pokretanja. Ostali kerneli ostaju u izborniku za pokretanje, pa i dalje možete ručno odabrati jedan ako vam novi zadani stvara probleme. U terminalu `omarchy-kernel` prikazuje trenutni zadani, `omarchy-kernel list` ono što je instalirano, a `omarchy-kernel set <kernel>` služi za promjenu.

### Ažuriranja firmwarea

Nisu samo vaši paketi ti koji zastarijevaju. Mnogi prijenosnici i periferni uređaji isporučuju firmware za BIOS, SSD i dock putem Linux Vendor Firmware Servicea, a _Ažuriranje > Firmware_ u izborniku Omarchy dohvatit će i instalirati sve što vaš hardver čeka. Pri prvom pokretanju instalira `fwupd`. Mnogi se firmwarei mogu zapisati samo tijekom ponovnog pokretanja, pa se nemojte iznenaditi ako vas se to zatraži.

Kada trebate promijeniti postavku u samom BIOS-u, držite `Alt` u izborniku sustava (`Super + Escape`) i _Ponovno pokretanje_ pretvara se u _Ponovno pokretanje u BIOS_, što se izravno ponovno pokreće u postavke firmwarea, bez potrebe da pri pokretanju hvatate pravu tipku. Iz terminala je to `omarchy system firmware`.

### Upozorenje o izravnim pacman/yay ažuriranjima

Ako već poznajete Arch, možda ćete doći u iskušenje da sami jednostavno pokrenete `pacman -Syu` ili `yay -Syu`, ali ako to učinite, propustit ćete snapshot, migracije i ažuriranja konfiguracije koje Omarchy pokreće zajedno s novim paketima. Zato će Omarchy zapravo zaustaviti izravnu nadogradnju sustava i uputiti vas da umjesto toga upotrijebite `omarchy update`. (Ako doista znate što radite, zaštita će vam reći kako je zaobići za jednu transakciju.)

### Vraćanje nakon loših ažuriranja

Ako ikada imate problem nakon ažuriranja, možete vratiti sustav na snapshot snimljen prije ažuriranja. Samo ponovno pokrenite i u izborniku za pokretanje odaberite snapshot iz vremena prije nego što ste započeli ažuriranje.

![bootloader](images/bootloader.webp)

Ako su vaše konfiguracijske datoteke nekako oštećene, možete i ponovno instalirati Omarchy pomoću `omarchy reinstall` u terminalu. Time ćete ponovno instalirati sve zadane Omarchy pakete, prebaciti se na stable i sniziti verziju svih paketa koji su previše novi te resetirati sve konfiguracijske datoteke. Imajte na umu da će time biti prepisane sve vaše korisničke izmjene konfiguracije u odnosu na zadane postavke Omarchyja!
