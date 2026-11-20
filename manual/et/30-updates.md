# Uuendused

Omarchy ja sinu paketid hoitakse ajakohasena Omarchy menüüs oleva valiku _Uuendus > Omarchy_ kaudu (`Super + Space`).

Omarchy ise on installitud tavaliste pacman pakettidena [Omarchy pakihoidlast](https://github.com/omacom-io/omarchy-pkgs), nii et uuendus installib [uusima Omarchy väljaande](https://github.com/omacom/omarchy/releases), käivitab kõik ootel migratsioonid, et sinu süsteem oleks uusimaga sünkroonis, ja uuendab kõik süsteemipaketid [Omarchy Archi peeglist](https://github.com/omacom-io/omarchy-mirror) ja [AUR](https://aur.archlinux.org/) kaudu (kui oled installinud mõne AUR paketi).

Kui uued väljaanded ilmuvad, ilmub sinu kella paremale poole ringnoole ikoon. Klõpsa seda ja uuendusprotsess käivitub.

![update-available](images/update-available.webp)

### Neli kanalit

Omarchyt uuendatakse nelja kanali kaudu: stable, RC, edge ja dev. Uued installid alustavad stable kanalil, mis jälgib [ametlikke väljaandeid](https://github.com/omacom/omarchy/releases/) ning samuti [stabiilset Omarchy Archi peeglit](https://github.com/omacom-io/omarchy-mirror), mis käib uusimast ühe kuu võrra maas, et saaksime kinni püüda kõik uued ühildumatused, mis nõuavad konfiguratsioonimuudatusi, enne kui need inimestele probleeme tekitavad.

Aga kui tahad aidata neid võimalikke probleeme märgata, võid kasutada edge kanalit. See hoiab sinu Omarchy paketid uusimate arendusjärgudega kursis ja laseb sul uuendada uusimatele Archi pakettidele kohe, kui need saadaval on. Peaksid seda tegema ainult siis, kui oled Linuxiga kogenud ja tead, kuidas probleemidega süsteemi taastada.

Enne iga uut suuremat väljaannet teeme lõpliku kontrolli RC kanali abil. Kui oled huvitatud lõpliku lihvi andmisel aitamisest, tule veeda aega Discordis kanalis #omarchy-release-candidates.

Lõpuks on olemas dev kanal, mis ühendab Omarchy otse lähtekoodi git checkout'iga asukohas `~/omarchy` koos edge pakettidega. Peaksid seda kanalit kasutama ainult siis, kui oled kogenud Linuxi kasutaja, töötad otse Omarchy kallal ja oled valmis taluma katkiminekut.

Kanalite vahel saad vahetada Omarchy menüüst valikuga _Uuendus > Kanal_ (või terminalis käsuga `omarchy-channel-set`).

### Kernelite vahetamine

Omarchy käivitub oma `linux-omarchy` kerneliga, aga võid selle kõrvale installituna hoida ka teisi, näiteks Archi tavalise `linux` kerneli või katsetatava eksperimentaalse järgu. Kui neid on rohkem kui üks, loetleb Omarchy menüüs olev _Uuendus > Kernel_ need üles koos linnukesega selle kõrval, mis käivitub vaikimisi. Vali teine, sisesta üks kord oma parool ja see käivitub pärast järgmist taaskäivitust. Teised kernelid jäävad alglaadimismenüüsse, nii et saad ikka käsitsi ühe valida, kui uus vaikevalik sulle probleeme tekitab. Terminalis näitab `omarchy-kernel` praegust vaikevalikut, `omarchy-kernel list` näitab, mis on installitud, ja `omarchy-kernel set <kernel>` vahetab seda.

### Püsivara uuendused

Sinu paketid pole ainus asi, mis vananeb. Paljud sülearvutid ja välisseadmed saavad BIOSi, SSD ja doki püsivara Linux Vendor Firmware Service'i kaudu ning Omarchy menüüs olev _Uuendus > Püsivara_ toob ja installib ära kõik, mis sinu riistvara ootab. Esimesel käivitamisel installib see `fwupd`. Palju püsivara saab kirjutada ainult taaskäivituse ajal, nii et ära imesta, kui sul palutakse see teha.

Kui pead muutma mõnda sätet BIOSis endas, hoia süsteemimenüüs (`Super + Escape`) all klahvi `Alt` ja _Taaskäivita_ muutub valikuks _Taaskäivita BIOSisse_, mis taaskäivitab otse püsivara seadistusse, ilma et peaksid alglaadimisel õiget klahvi taga ajama. Terminalist on selleks `omarchy system firmware`.

### Hoiatus otse tehtavate pacman/yay uuenduste kohta

Kui oled Archiga juba tuttav, võib tekkida kiusatus käivitada lihtsalt ise `pacman -Syu` või `yay -Syu`, aga kui seda teed, jääd ilma hetktõmmisest, migratsioonidest ja konfiguratsiooniuuendustest, mille Omarchy koos uute pakettidega käivitab. Seetõttu peatab Omarchy otsese süsteemiuuenduse tegelikult ära ja suunab su hoopis käsu `omarchy update` juurde. (Kui tõesti tead, mida teed, ütleb valvur sulle, kuidas sellest üheks tehinguks mööda minna.)

### Halbade uuenduste tagasikeeramine

Kui sul tekib pärast uuendamist kunagi probleem, saad oma süsteemi tagasi keerata uuendamise eel tehtud hetktõmmisele. Lihtsalt taaskäivita ja vali alglaadimismenüüst hetktõmmis ajast enne uuendamise alustamist.

![bootloader](images/bootloader.webp)

Kui sinu konfiguratsioonifailid on kuidagi rikutud, saad terminalis käsuga `omarchy reinstall` teha ka Omarchy uuesti installimise. See installib uuesti kõik Omarchy vaikepaketid, paneb su stable kanalile ja viib kõik liiga uued paketid vanemale versioonile ning lähtestab kõik konfiguratsioonifailid. Pane tähele, et kõik sinu kasutaja tehtud konfiguratsioonimuudatused Omarchy vaikeväärtustes kirjutatakse seda tehes üle!
