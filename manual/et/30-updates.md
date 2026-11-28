# Uuendused

Omarchy ja sinu paketid hoitakse ajakohasena Omarchy menüü valiku _Uuendus > Omarchy_ kaudu (`Super + Space`).

Omarchy ise on paigaldatud tavaliste pacman pakettidena [Omarchy pakettide hoidlast](https://github.com/omacom-io/omarchy-pkgs), nii et uuendus paigaldab [uusima Omarchy väljaande](https://github.com/omacom/omarchy/releases), käivitab kõik ootel migratsioonid, et sinu süsteem uusimaga sünkroonis hoida, ja uuendab kõik süsteemipaketid [Omarchy Archi peeglist](https://github.com/omacom-io/omarchy-mirror) ja [AUR](https://aur.archlinux.org/)-ist (kui oled mõne AUR paketi paigaldanud).

Kui uued väljaanded ilmuvad, ilmub sinu kellast paremale ringikujulise noole ikoon. Klõpsa seda ja uuendusprotsess käivitub.

![update-available](images/update-available.webp)

### Neli kanalit

Omarchyt uuendatakse nelja kanali kaudu: stable, RC, edge ja dev. Uued paigaldused alustavad stable kanalil, mis järgib [ametlikke väljaandeid](https://github.com/omacom/omarchy/releases/), samuti [stabiilset Omarchy Archi peeglit](https://github.com/omacom-io/omarchy-mirror), mis on uusimast ühe kuu võrra maas, et saaksime kinni püüda kõik uued ühildumatused, mis nõuavad konfiguratsioonimuudatusi, enne kui need inimestele probleeme tekitavad.

Aga kui soovid aidata neid võimalikke probleeme märgata, võid kasutada edge kanalit. See hoiab sinu Omarchy paketid uusimate arendusversioonide jälil ja laseb sul uuendada uusimatele Arch pakettidele kohe, kui need saadaval on. Peaksid seda tegema ainult siis, kui oled Linuxiga kogenud ja tead, kuidas probleemidega süsteemi taastada.

Enne iga uut suuremat väljaannet teeme lõplikku valideerimist RC kanali abil. Kui oled huvitatud lõpliku lihvimisega aitamisest, tule veeda aega Discordi kanalis #omarchy-release-candidates.

Lõpuks on dev kanal, mis seob Omarchy otse lähtekoodi git väljavõttega kaustas `~/omarchy`, koos edge pakettidega. Peaksid seda kanalit kasutama ainult siis, kui oled kogenud Linuxi kasutaja, töötad otse Omarchy kallal ja oled valmis purunemist taluma.

Kanalite vahel saad vahetada Omarchy menüü valiku _Uuendus > Kanal_ abil (või terminalis käsuga `omarchy channel set <stable|rc|edge|dev>`, kusjuures `omarchy channel current` näitab, kus sa oled).

### Kernelite vahetamine

Omarchy käivitab oma `linux-omarchy` kerneli, aga võid selle kõrvale paigaldatuna hoida teisi, nagu Archi standardse `linux` kerneli või katsetatava eksperimentaalse versiooni. Kui neid on rohkem kui üks, loetleb Omarchy menüü valik _Uuendus > Kernel_ need üles koos linnukesega selle kõrval, mis vaikimisi käivitub. Vali teine, sisesta üks kord oma parool ja see käivitub pärast järgmist taaskäivitust. Teised kernelid jäävad alglaadimismenüüsse, nii et saad ikka käsitsi ühe valida, kui uus vaikesäte sulle probleeme tekitab. Terminalis on `omarchy kernel` praeguse vaikesätte nägemiseks, `omarchy kernel list` selleks, mis on paigaldatud, ja `omarchy kernel set <kernel>` vahetamiseks.

### Püsivara uuendused

Sinu paketid pole ainsad asjad, mis aeguvad. Paljud sülearvutid ja välisseadmed edastavad BIOS-i, SSD ja doki püsivara Linux Vendor Firmware Service kaudu ning Omarchy menüü valik _Uuendus > Püsivara_ toob ja paigaldab ära kõik, mis sinu riistvara ootab. See paigaldab `fwupd` esimesel korral, kui seda käivitad. Palju püsivara saab kirjutada ainult taaskäivituse ajal, nii et ära imesta, kui sinult üht küsitakse.

Kui pead BIOS-is endas mõnda sätet muutma, hoia süsteemimenüüs (`Super + Escape`) all klahvi `Alt` ja _Taaskäivita_ muutub valikuks _Taaskäivita BIOS-i_, mis taaskäivitub otse püsivara häälestusse, ilma et peaksid alglaadimisel õiget klahvi tabama. Terminalist on see `omarchy system firmware`.

### Hoiatus otseste pacman/yay uuenduste kohta

Kui oled Archiga juba tuttav, võib sul tekkida kiusatus käivitada lihtsalt ise `pacman -Syu` või `yay -Syu`, aga kui sa seda teed, jääd ilma hetktõmmisest, migratsioonidest ja konfiguratsiooniuuendustest, mida Omarchy koos uute pakettidega käivitab. Seepärast peatab Omarchy tegelikult otsese süsteemiuuenduse ja suunab sind hoopis käsu `omarchy update` juurde. (Kui sa tõesti tead, mida teed, ütleb valve sulle, kuidas sellest ühe tehingu korral mööda pääseda.)

### Vigaste uuenduste tagasivõtmine

Kui sul kunagi pärast uuendamist probleem tekib, saad oma süsteemi taastada uuenduse eel tehtud hetktõmmisele. Lihtsalt taaskäivita ja vali alglaadimismenüüst hetktõmmis ajast enne uuenduse alustamist.

![bootloader](images/bootloader.webp)

Kui sinu konfiguratsioonifailid on kuidagi rikutud, saad terminalis käsuga `omarchy reinstall` teha ka Omarchy uuesti paigaldamise. See paigaldab uuesti kõik Omarchy vaikepaketid, paneb sind stable kanalile (Apple Siliconil edge kanalile) ja alandab kõik liiga uued paketid ning lähtestab kõik konfiguratsioonifailid. Pane tähele, et kõik sinu kasutaja konfiguratsioonimuudatused Omarchy vaikesätetele kirjutatakse seda tehes üle!
