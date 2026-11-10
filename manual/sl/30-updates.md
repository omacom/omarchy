# Posodobitve

Omarchy in vaši paketi se posodabljajo prek _Posodobitev > Omarchy_ v meniju Omarchy (`Super + Space`).

Sam Omarchy je nameščen kot običajni paketi pacman iz [skladišča paketov Omarchy](https://github.com/omacom-io/omarchy-pkgs), zato posodobitev namesti [najnovejšo izdajo Omarchy](https://github.com/omacom/omarchy/releases), zažene vse čakajoče migracije, da vaš sistem uskladi z najnovejšo različico, in posodobi vse sistemske pakete iz [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) in [AUR](https://aur.archlinux.org/) (če ste namestili kakšne pakete AUR).

Ko bodo na voljo nove izdaje, se bo desno od vaše ure prikazala ikona s krožno puščico. Kliknite nanjo in postopek posodobitve se bo začel.

![update-available](images/update-available.webp)

### Štirje kanali

Omarchy se posodablja po štirih kanalih: stable, RC, edge in dev. Nove namestitve se začnejo na kanalu stable, ki sledi [uradnim izdajam](https://github.com/omacom/omarchy/releases/) ter [stabilnemu Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror), ki za najnovejšim zaostaja en mesec, da lahko ujamemo vse nove nezdružljivosti, ki zahtevajo spremembe konfiguracije, preden povzročijo težave ljudem.

Če pa želite pomagati odkriti te morebitne težave, lahko uporabljate kanal edge. Tako bodo vaši paketi Omarchy sledili najnovejšim razvojnim gradnjam, pakete Arch pa boste lahko posodobili takoj, ko bodo na voljo. To storite le, če imate izkušnje z Linuxom in znate obnoviti sistem, ki ima težave.

Pred vsako novo večjo izdajo bomo končno preverjanje opravili z uporabo kanala RC. Če želite pomagati pri končnem piljenju, se nam pridružite v #omarchy-release-candidates na Discordu.

Nazadnje je tu še kanal dev, ki Omarchy poveže neposredno z git izvozom izvorne kode v `~/omarchy`, v kombinaciji s paketi edge. Ta kanal uporabljajte le, če ste izkušen uporabnik Linuxa, delate neposredno na Omarchyju in ste pripravljeni prenašati okvare.

Med kanali lahko preklapljate z _Posodobitev > Kanal_ v meniju Omarchy (ali `omarchy-channel-set` v terminalu).

### Preklapljanje jeder

Omarchy zaganja svoje jedro `linux-omarchy`, ob njem pa lahko obdržite nameščena tudi druga, na primer privzeto jedro Arch `linux` ali poskusno gradnjo, ki jo preizkušate. Ko je nameščenih več jeder, jih _Posodobitev > Jedro_ v meniju Omarchy prikaže s kljukico ob tistem, ki se privzeto zažene. Izberite drugo, enkrat vnesite geslo in po naslednjem ponovnem zagonu se bo zagnalo to jedro. Druga jedra ostanejo v zagonskem meniju, zato lahko eno še vedno izberete ročno, če vam novo privzeto jedro povzroča težave. V terminalu z `omarchy-kernel` vidite trenutno privzeto jedro, z `omarchy-kernel list`, kaj je nameščeno, z `omarchy-kernel set <kernel>` pa preklopite.

### Posodobitve vdelane programske opreme

Vaši paketi niso edina stvar, ki zastara. Številni prenosniki in zunanje naprave ponujajo vdelano programsko opremo za BIOS, SSD in priklopne postaje prek storitve Linux Vendor Firmware Service, _Posodobitev > Vdelana programska oprema_ v meniju Omarchy pa bo prenesla in namestila vse, kar čaka na vašo strojno opremo. Ob prvem zagonu namesti `fwupd`. Veliko vdelane programske opreme je mogoče zapisati le med ponovnim zagonom, zato ne bodite presenečeni, če boste morali to storiti.

### Opozorilo o neposrednih posodobitvah s pacman/yay

Če Arch že poznate, vas bo morda zamikalo, da bi sami zagnali `pacman -Syu` ali `yay -Syu`, a če to storite, boste zamudili posnetek stanja, migracije in posodobitve konfiguracije, ki jih Omarchy zažene skupaj z novimi paketi. Zato bo Omarchy neposredno nadgradnjo sistema dejansko ustavil in vas namesto tega napotil na `omarchy update`. (Če res veste, kaj počnete, vam bo varovalo povedalo, kako ga obiti za eno samo transakcijo.)

### Povrnitev slabih posodobitev

Če boste po posodobitvi kdaj imeli težavo, lahko sistem povrnete na posnetek stanja, ustvarjen pred posodobitvijo. Preprosto znova zaženite računalnik in v zagonskem meniju izberite posnetek stanja iz časa pred začetkom posodobitve.

![bootloader](images/bootloader.webp)

Če so vaše konfiguracijske datoteke nekako poškodovane, lahko Omarchy tudi znova namestite z `omarchy reinstall` v terminalu. S tem boste znova namestili vse privzete pakete Omarchy, preklopili na stable in znižali vse pakete, ki so preveč novi, ter ponastavili vse konfiguracijske datoteke. Upoštevajte, da bodo vse vaše uporabniške spremembe konfiguracije privzetih nastavitev Omarchy pri tem prepisane!
