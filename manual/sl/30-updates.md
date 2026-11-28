# Posodobitve

Omarchy in tvoje pakete posodabljaš prek _Posodobitev > Omarchy_ v meniju Omarchy (`Super + Space`).

Sam Omarchy je nameščen kot običajni paketi pacman iz [repozitorija paketov Omarchy](https://github.com/omacom-io/omarchy-pkgs), zato posodobitev namesti [najnovejšo izdajo Omarchy](https://github.com/omacom/omarchy/releases), zažene vse čakajoče migracije, da tvoj sistem uskladi z najnovejšo različico, in posodobi vse sistemske pakete iz [zrcala Omarchy Arch](https://github.com/omacom-io/omarchy-mirror) in [AUR](https://aur.archlinux.org/) (če si namestil kakšne pakete AUR).

Ko izidejo nove izdaje, se bo desno od tvoje ure prikazala ikona krožne puščice. Klikni jo in postopek posodobitve se bo začel.

![update-available](images/update-available.webp)

### Štirje kanali

Omarchy se posodablja po štirih kanalih: stable, RC, edge in dev. Nove namestitve se začnejo na kanalu stable, ki sledi [uradnim izdajam](https://github.com/omacom/omarchy/releases/) ter [stabilnemu zrcalu Omarchy Arch](https://github.com/omacom-io/omarchy-mirror), ki za najnovejšo različico zaostaja en mesec, da lahko ujamemo morebitne nove nezdružljivosti, ki zahtevajo spremembe konfiguracije, preden ljudem povzročijo težave.

Če pa želiš pomagati odkriti te morebitne težave, lahko uporabljaš kanal edge. Tako bodo tvoji paketi Omarchy sledili najnovejšim razvojnim gradnjam, pakete Arch pa boš lahko posodobil na najnovejše takoj, ko bodo na voljo. To naredi le, če imaš izkušnje z Linuxom in znaš obnoviti sistem, ki ima težave.

Pred vsako novo večjo izdajo bomo končno preverjanje opravili na kanalu RC. Če želiš pomagati pri zadnjem poliranju, se pridi družiti v #omarchy-release-candidates na Discordu.

Na koncu je tu še kanal dev, ki Omarchy poveže neposredno z git izvodom izvorne kode v `~/omarchy`, v kombinaciji s paketi edge. Ta kanal uporabljaj le, če si izkušen uporabnik Linuxa, delaš neposredno na Omarchyju in si pripravljen sprejeti, da se lahko stvari pokvarijo.

Med kanali lahko preklapljaš prek _Posodobitev > Kanal_ v meniju Omarchy (ali z `omarchy channel set <stable|rc|edge|dev>` v terminalu, s `omarchy channel current` pa preveriš, kje si).

### Preklapljanje med jedri

Omarchy zažene svoje jedro `linux-omarchy`, zraven pa imaš lahko nameščena tudi druga, kot je privzeto jedro Arch `linux` ali poskusna gradnja, ki jo preizkušaš. Ko jih je več kot eno, jih _Posodobitev > Jedro_ v meniju Omarchy prikaže s kljukico ob tistem, ki se zažene privzeto. Izberi drugo, enkrat vnesi svoje geslo in po naslednjem ponovnem zagonu se bo zagnalo to. Druga jedra ostanejo v zagonskem meniju, zato lahko eno še vedno izbereš ročno, če ti novo privzeto povzroča težave. V terminalu z `omarchy kernel` vidiš trenutno privzeto jedro, z `omarchy kernel list` tista, ki so nameščena, z `omarchy kernel set <kernel>` pa preklopiš.

### Posodobitve vdelane programske opreme

Tvoji paketi niso edino, kar zastara. Številni prenosniki in periferne naprave ponujajo vdelano programsko opremo za BIOS, SSD in priklopne postaje prek Linux Vendor Firmware Service, _Posodobitev > Vdelana programska oprema_ v meniju Omarchy pa bo prenesla in namestila vse, kar za tvojo strojno opremo čaka. Ob prvem zagonu namesti `fwupd`. Veliko vdelane programske opreme je mogoče zapisati le med ponovnim zagonom, zato ne bodi presenečen, če ga bo zahtevala.

Ko moraš spremeniti nastavitev v samem BIOS-u, drži `Alt` v sistemskem meniju (`Super + Escape`) in _Ponovni zagon_ se bo spremenil v _Ponovni zagon v BIOS_, ki se znova zažene naravnost v nastavitve vdelane programske opreme, ne da bi moral ob zagonu ujeti pravo tipko. Iz terminala je to `omarchy system firmware`.

### Opozorilo o neposrednih posodobitvah s pacman/yay

Če Arch že poznaš, te bo morda zamikalo, da bi sam zagnal kar `pacman -Syu` ali `yay -Syu`, a če to narediš, boš izpustil posnetek stanja, migracije in posodobitve konfiguracije, ki jih Omarchy zažene skupaj z novimi paketi. Zato bo Omarchy neposredno nadgradnjo sistema dejansko ustavil in te namesto tega napotil na `omarchy update`. (Če res veš, kaj počneš, ti bo varovalo povedalo, kako ga obideš za eno samo transakcijo.)

### Povrnitev po slabih posodobitvah

Če imaš po posodobitvi kdaj težave, lahko sistem povrneš na posnetek stanja, narejen pred posodobitvijo. Preprosto znova zaženi računalnik in v zagonskem meniju izberi posnetek stanja iz časa, preden si začel posodobitev.

![bootloader](images/bootloader.webp)

Če so se tvoje konfiguracijske datoteke nekako poškodovale, lahko z `omarchy reinstall` v terminalu izvedeš tudi ponovno namestitev Omarchyja. To bo znova namestilo vse privzete pakete Omarchy, te postavilo na stable (edge na Apple Silicon), znižalo različico vseh paketov, ki so prenovi, in ponastavilo vse konfiguracijske datoteke. Upoštevaj, da bodo pri tem prepisane vse tvoje uporabniške spremembe konfiguracije privzetih nastavitev Omarchyja!
