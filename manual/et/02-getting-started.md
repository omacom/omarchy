# Alustamine

Omarchy installimiseks kasutatakse ISO-t. Saad valida täisketta installi, mis võtab üle kogu ketta, või vaba ruumi installi, mis paigutab Omarchy kettal eraldamata ruumi — nii teed topeltkäivituse koos Windowsi või mõne muu OS-iga (vt [topeltkäivituse installimine](50-dual-boot-install.md) — pane tähele, et pead kõigepealt Windowsis BitLockeri välja lülitama). Mõlemal juhul on install vaikimisi täieliku krüpteerimisega ja täisketta valik pühib valitud ketta tühjaks, nii et tee kindlasti varukoopia, enne kui olemasolevat ketast kasutad!

[Laadi kõigepealt alla Omarchy ISO](https://omarchy.org/), pane see USB-mälupulgale (kasuta Windowsis [Rufus](https://rufus.ie/), Macis [balenaEtcher](https://etcher.balena.io/) või Linuxis [caligula](https://github.com/ifd3f/caligula)) ja käivita arvuti sellelt mälupulgalt.

_Pead BIOS-is Secure Boot ja/või TPM välja lülitama. Pead need välja lülitama, et saaksid Omarchy installida. Need on Microsofti turvasüsteemid, mis on mõeldud Windowsile ja Microsoftiga seotud Linuxi distributsioonidele._

Seejärel vasta konfiguratsiooniküsimustele ja kinnita need nii:

 ![install-config](images/install-config.webp)

Seejärel vali installimiseks ketas ja istu mugavalt sisse ning vaata installietendust. Kiireimatel tänapäevastel masinatel saab sellega hakkama alla minutiga, aga isegi vanemal arvutil ei tohiks see võtta kauem kui 5 minutit.

 ![install-done](images/install-done.webp)

Nüüd oled Omarchyks valmis!

### Kasuta juhtmega või 2.4ghz klaviatuuri!

Täisketta krüpteerimine ei lase sul käivitamisel Bluetoothi klaviatuurilt parooli sisestada. Nii, nagu sa ei saa ka PC-l Bluetoothi klaviatuuri kasutada BIOS-i sisenemiseks. Sul on vaja klaviatuuri, mis kasutab kas 2.4ghz donglit või kaablit (mis on latentsuse poolest niikuinii palju parem!). Mulle isiklikult meeldib väga [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installimine teisele omanikule

Kui seadistad masinat kellelegi teisele — pereliikmele, uuele töötajale, ostjale — ei tohiks sa nende eest isiklikele küsimustele vastata. Vajuta installeri kõige esimesel ekraanil (klaviatuuri valik) `Ctrl + C` ja Omarchy pakub selle asemel võimalust valmistada masin ette teisele omanikule. Süsteem installitakse kohe, kuid kogu isiklik seadistus — klaviatuuripaigutus, kasutajanimi, parool — lükatakse edasi ajani, mil masin esimest korda käivitub. Ketas on endiselt vaikimisi krüpteeritud ja paroolist, mille uus omanik sellel esimesel käivitamisel valib, saab ka krüpteerimisparool. (Masina, mida oled juba kasutanud, saab üle anda ka ilma uuesti installimata — vt [arvuti lähtestamine](48-security.md).)

### Järelevalveta installimised

ISO saab installida ka täiesti iseseisvalt — ilma klaviatuuri ja viisardita — kui selle konfiguratsioon antakse talle teisel kettal. Nii tasub Omarchyt käsitleda VM-ide ja masinaparkide baaskujutisena. Vt [järelevalveta installimised](51-unattended-installs.md).

### Krüpteerimiseta installimised

Omarchy installitakse vaikimisi krüpteerimisega. See on turvaline ja vastutustundlik valik iga arvuti puhul, mis võib kaduda või varastatud saada. Sa ei taha, et keegi, kellel on sinu riistvarale juurdepääs, saaks ligi sinu andmetele!

Ent eriolukordades, näiteks Omarchy kauginstallide puhul kaitstud arvutites või äravisatavate, tundlikke andmeid mittesisaldavate installide puhul, võid tahta installida ilma krüpteerimiseta. Krüpteerimiseta installile lülitumiseks saad ketta vormindamise kinnitusel vajutada `Ctrl + C`.

### Keel

Omarchy räägib 50 keelt — sama valikut nagu omarchy.org — ja vaikekeel on inglise keel. Vahetamiseks ava Omarchy menüü ja mine _Seadistus > Keel_ või käivita terminalis `omarchy language <code>` (`omarchy language list` näitab koode). Menüü, töölaud ja Omarchy enda teatised vahetavad keelt kohe ja iga rakendus, mille sa pärast seda avad, järgib seda samuti. Juba avatud rakendused vahetavad keelt, kui sa need taaskäivitad.

### Abi, kui jääd hätta

Kui jääd hätta, leiad tavaliselt kellegi, kes on nõus aitama, [kogukonna Discordi](https://omarchy.org/discord) _#omarchy-help_ kanalil.
