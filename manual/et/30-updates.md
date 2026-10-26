# Uuendused

Omarchyt ja sinu pakette hoitakse ajakohasena Omarchy menüü valiku _Uuenda > Omarchy_ kaudu (`Super + Space`).

Omarchy ise on paigaldatud tavaliste pacman pakettidena [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) hoidlast, nii et uuendus paigaldab [uusima Omarchy väljaande](https://github.com/omacom/omarchy/releases), käivitab kõik ootel migratsioonid, et sinu süsteem uusimaga sünkrooni viia, ja uuendab kõik süsteemipaketid [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) peeglist ja [AUR](https://aur.archlinux.org/) hoidlast (kui oled paigaldanud mõne AUR paketi).

Kui uued väljaanded ilmuvad, ilmub sinu kella paremale poole ringnoole ikoon. Klõpsa seda ja uuendusprotsess algab.

![update-available](images/update-available.webp)

### Neli kanalit

Omarchyt uuendatakse nelja kanali kaudu: stable, RC, edge ja dev. Uued paigaldused alustavad stable kanalil, mis jälgib [ametlikke väljaandeid](https://github.com/omacom/omarchy/releases/), samuti [stabiilset Omarchy Arch peeglit](https://github.com/omacom-io/omarchy-mirror), mis on uusimast ühe kuu võrra maas, et saaksime tabada kõik uued ühildumatused, mis nõuavad konfiguratsioonimuudatusi, enne kui need inimestele probleeme põhjustavad.

Aga kui soovid aidata neid võimalikke probleeme märgata, võid kasutada edge kanalit. See hoiab sinu Omarchy paketid uusimate arendusjärgude juures ja laseb sul uuendada uusimatele Arch pakettidele kohe, kui need kättesaadavaks saavad. Peaksid seda tegema ainult siis, kui oled Linuxiga kogenud ja tead, kuidas probleemidega süsteemi taastada.

Enne iga uut suuremat väljaannet teeme lõpliku kontrolli RC kanali abil. Kui oled huvitatud lõpliku lihvi andmisel aitamisest, tule Discordi kanalile #omarchy-release-candidates.

Lõpuks on olemas dev kanal, mis seob Omarchy otse lähtekoodi git väljavõttega kaustas `~/omarchy`, kombineerituna edge pakettidega. Peaksid seda kanalit kasutama ainult siis, kui oled kogenud Linuxi kasutaja, töötad otse Omarchy kallal ja oled valmis katkestusi taluma.

Kanalite vahel saad vahetada Omarchy menüü valiku _Uuenda > Kanal_ kaudu (või terminalis käsuga `omarchy-channel-set`).

### Kernelite vahetamine

Omarchy käivitub oma `linux-omarchy` kerneliga, aga võid selle kõrvale paigaldatuna hoida teisi, näiteks Arch tavalist `linux` kernelit või katsetatavat eksperimentaalset järku. Kui neid on rohkem kui üks, loetleb Omarchy menüü valik _Uuenda > Kernel_ need üles ja vaikimisi käivituva kõrval on linnuke. Vali teine, sisesta üks kord oma parool ja see käivitub pärast järgmist taaskäivitust. Teised kernelid jäävad käivitusmenüüsse alles, nii et saad ikka käsitsi ühe valida, kui uus vaikevalik sulle probleeme tekitab. Terminalis näitab `omarchy-kernel` praegust vaikevalikut, `omarchy-kernel list` näitab, mis on paigaldatud, ja `omarchy-kernel set <kernel>` vahetab seda.

### Püsivara uuendused

Ainult sinu paketid ei jää vanaks. Paljud sülearvutid ja välisseadmed pakuvad BIOS, SSD ja doki püsivara Linux Vendor Firmware Service kaudu ning Omarchy menüü valik _Uuenda > Püsivara_ toob ja paigaldab kõik, mis sinu riistvara jaoks ootel on. Esimesel käivitamisel paigaldab see `fwupd`. Suurt osa püsivarast saab kirjutada ainult taaskäivituse ajal, nii et ära imesta, kui sinult üht küsitakse.

### Hoiatus otseste pacman/yay uuenduste kohta

Kui oled Archiga juba tuttav, võib tekkida kiusatus käivitada lihtsalt ise `pacman -Syu` või `yay -Syu`, aga kui sa seda teed, jääd ilma hetktõmmisest, migratsioonidest ja konfiguratsiooniuuendustest, mida Omarchy koos uute pakettidega käivitab. Seetõttu peatab Omarchy otsese süsteemiuuenduse ja suunab su hoopis käsu `omarchy update` juurde. (Kui sa tõesti tead, mida teed, ütleb kaitse sulle, kuidas sellest ühe tehingu puhul mööda minna.)

### Halbade uuenduste tagasipööramine

Kui sul tekib pärast uuendamist kunagi probleem, saad oma süsteemi tagasi pöörata enne uuendust tehtud hetktõmmisele. Lihtsalt taaskäivita ja vali käivituslaaduri menüüst hetktõmmis ajast enne uuendamise alustamist.

![bootloader](images/bootloader.webp)

Kui sinu konfiguratsioonifailid on kuidagi rikutud, saad terminalis käsuga `omarchy reinstall` teha ka Omarchy uuesti paigaldamise. See paigaldab uuesti kõik Omarchy vaikepaketid, paneb su stable kanalile ja alandab kõik liiga uued paketid ning lähtestab kõik konfiguratsioonifailid. Pane tähele, et seda tehes kirjutatakse üle kõik sinu kasutajapoolsed muudatused Omarchy vaikeväärtustes!
