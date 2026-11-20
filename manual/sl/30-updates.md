# Posodobitve

Omarchy in vaši paketi se posodabljajo prek možnosti _Posodobitev > Omarchy_ v meniju Omarchy (`Super + Space`).

Sam Omarchy je nameščen kot običajni paketi pacman iz [repozitorija paketov Omarchy](https://github.com/omacom-io/omarchy-pkgs), zato posodobitev namesti [najnovejšo izdajo Omarchy](https://github.com/omacom/omarchy/releases), izvede vse čakajoče migracije, da vaš sistem uskladi z najnovejšo različico, in posodobi vse sistemske pakete iz [zrcalnega strežnika Omarchy Arch](https://github.com/omacom-io/omarchy-mirror) in [AUR](https://aur.archlinux.org/) (če ste namestili kakšne pakete AUR).

Ko so na voljo nove izdaje, se desno od ure prikaže ikona krožne puščice. Kliknite jo in postopek posodobitve se bo začel.

![update-available](images/update-available.webp)

### Štirje kanali

Omarchy se posodablja po štirih kanalih: stable, RC, edge in dev. Nove namestitve se začnejo na kanalu stable, ki sledi [uradnim izdajam](https://github.com/omacom/omarchy/releases/) ter [stabilnemu zrcalnemu strežniku Omarchy Arch](https://github.com/omacom-io/omarchy-mirror), ki zaostaja en mesec za najnovejšim, da lahko ujamemo morebitne nove nezdružljivosti, ki zahtevajo spremembe konfiguracije, preden povzročijo težave ljudem.

Če pa želite pomagati odkriti te morebitne težave, lahko uporabljate kanal edge. Tako bodo vaši paketi Omarchy sledili najnovejšim razvojnim gradnjam, pakete Arch pa boste lahko posodobili takoj, ko bodo na voljo. To naredite le, če imate izkušnje z Linuxom in znate obnoviti sistem, ki ima težave.

Pred vsako novo večjo izdajo bomo končno preverjanje izvedli na kanalu RC. Če želite pomagati pri zadnjem brušenju, se oglasite v #omarchy-release-candidates na Discordu.

Nazadnje je tu še kanal dev, ki Omarchy poveže neposredno z git checkoutom izvorne kode v `~/omarchy` v kombinaciji s paketi edge. Ta kanal uporabljajte le, če ste izkušen uporabnik Linuxa, delate neposredno na Omarchyju in ste pripravljeni prenašati okvare.

Med kanali lahko preklapljate z možnostjo _Posodobitev > Kanal_ v meniju Omarchy (ali `omarchy-channel-set` v terminalu).

### Preklapljanje jeder

Omarchy zažene svoje jedro `linux-omarchy`, lahko pa imate ob njem nameščena tudi druga, kot je standardno jedro Arch `linux` ali poskusna gradnja, ki jo preizkušate. Ko jih je več kot eno, jih možnost _Posodobitev > Jedro_ v meniju Omarchy navede s kljukico ob tistem, ki se privzeto zažene. Izberite drugega, enkrat vnesite geslo in po naslednjem ponovnem zagonu se bo zagnal ta. Druga jedra ostanejo v zagonskem meniju, tako da lahko enega še vedno ročno izberete, če vam novi privzeti povzroča težave. V terminalu z `omarchy-kernel` vidite trenutnega privzetega, z `omarchy-kernel list` tisto, kar je nameščeno, in z `omarchy-kernel set <kernel>` preklopite.

### Posodobitve vdelane programske opreme

Vaši paketi niso edina stvar, ki zastara. Številni prenosniki in zunanje naprave dobijo vdelano programsko opremo za BIOS, SSD in priklopne postaje prek Linux Vendor Firmware Service, možnost _Posodobitev > Vdelana programska oprema_ v meniju Omarchy pa bo prenesla in namestila vse, kar čaka na vaši strojni opremi. Ob prvem zagonu namesti `fwupd`. Veliko vdelane programske opreme je mogoče zapisati le med ponovnim zagonom, zato naj vas ne preseneti, če bo zahtevan.

Ko morate spremeniti nastavitev v samem BIOS-u, pridržite `Alt` v sistemskem meniju (`Super + Escape`) in _Ponovni zagon_ se spremeni v _Ponovni zagon v BIOS_, kar vas ponovno zažene naravnost v nastavitve vdelane programske opreme, ne da bi vam bilo treba ob zagonu ujeti pravo tipko. V terminalu je to `omarchy system firmware`.

### Opozorilo o neposrednih posodobitvah pacman/yay

Če Arch že poznate, vas bo morda zamikalo, da sami zaženete `pacman -Syu` ali `yay -Syu`, a če to storite, boste zamudili posnetek stanja, migracije in posodobitve konfiguracije, ki jih Omarchy izvede skupaj z novimi paketi. Zato bo Omarchy neposredno nadgradnjo sistema dejansko ustavil in vas napotil na `omarchy update`. (Če res veste, kaj počnete, vam bo varovalo povedalo, kako ga obiti za eno samo transakcijo.)

### Vrnitev slabih posodobitev

Če boste po posodobitvi kdaj imeli težavo, lahko sistem vrnete na posnetek stanja, narejen pred posodobitvijo. Samo znova zaženite in v meniju zagonskega nalagalnika izberite posnetek stanja iz časa, preden ste začeli posodobitev.

![bootloader](images/bootloader.webp)

Če so se vaše konfiguracijske datoteke nekako poškodovale, lahko z `omarchy reinstall` v terminalu izvedete tudi ponovno namestitev Omarchyja. To bo znova namestilo vse privzete pakete Omarchy, vas postavilo na stable in znižalo vse pakete, ki so preveč novi, ter ponastavilo vse konfiguracijske datoteke. Upoštevajte, da bodo vse vaše uporabniške spremembe konfiguracije privzetih nastavitev Omarchyja pri tem prepisane!
