# Alustamine

Omarchy paigaldatakse ISO abil. Saad valida täisketta paigalduse, mis võtab kogu ketta enda alla, või vaba ruumi paigalduse, mis paneb Omarchy ketta jaotamata ruumi — nii saad dual bootida Windowsi või mõne muu OS-i kõrvale (vaata [dual-boot paigaldus](50-dual-boot-install.md) — pane tähele, et pead esmalt Windowsis BitLockeri välja lülitama). Mõlemal juhul on paigalduse vaikesäte täielik krüptimine ja täisketta valik pühib valitud ketta tühjaks, nii et enne olemasoleva ketta kasutamist tee kindlasti varukoopia!

[Laadi alla Omarchy ISO](https://omarchy.org/), pane see USB-mälupulgale (kasuta Macis/Windowsis [balenaEtcherit](https://etcher.balena.io/) või Linuxis [caligulat](https://github.com/ifd3f/caligula)) ja käivita arvuti pulgalt.

_Pead BIOS-is Secure Booti ja/või TPM-i välja lülitama. Omarchy paigaldamiseks pead need välja lülitama. Need on Microsofti turvasüsteemid, mis on mõeldud Windowsi ja Microsoftiga seotud Linuxi distributsioonide jaoks._

Seejärel vasta seadistamise küsimustele ja kinnita need nii:

 ![install-config](images/install-config.webp)

Seejärel vali paigalduseks ketas ning istu maha ja vaata, kuidas paigaldusshow kulgeb. Kõige kiirematel kaasaegsetel masinatel saab see tehtud vähem kui minutiga, aga isegi vanemal arvutil ei tohiks see võtta kauem kui 5 minutit.

 ![install-done](images/install-done.webp)

Nüüd oled Omarchyks valmis!

### Kasuta juhtmega või 2.4ghz klaviatuuri!

Täisketta krüptimine ei lase sul käivitamisel Bluetoothi klaviatuurilt parooli sisestada. Nii nagu sa ei saa PC-l Bluetoothi klaviatuuri kasutada BIOS-isse sisenemiseks. Sul on vaja klaviatuuri, mis kasutab kas 2.4ghz donglit või kaablit (mis on latentsuse poolest nagunii palju parem!). Mulle isiklikult meeldib väga [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Paigaldamine teisele omanikule

Kui seadistad masinat kellelegi teisele — pereliikmele, uuele töötajale, ostjale — ei tohiks sa isiklikele küsimustele tema eest vastata. Vajuta paigaldaja päris esimesel ekraanil (klaviatuuri valik) `Ctrl + C` ja Omarchy pakub selle asemel masina teisele omanikule ette valmistamist. Süsteem paigaldatakse kohe, kuid kogu isiklik seadistamine — klaviatuuripaigutus, kasutajanimi, parool — lükatakse edasi, kuni masin esimest korda käivitub. Ketas on vaikimisi endiselt krüptitud ja paroolist, mille uus omanik sellel esimesel käivitamisel valib, saab ka krüptimisparool. (Masina, mida oled juba kasutanud, saab üle anda ka ilma uuesti paigaldamiseta — vaata [arvuti lähtestamine](48-security.md).)

### Järelevalveta paigaldused

ISO suudab paigaldada ka täiesti iseseisvalt — ilma klaviatuuri ja viisardita — kui sellele antakse seadistus teisel kettal. Nii tuleb Omarchyt käsitleda VM-ide ja masinapargi masinate baaskujutisena. Vaata [järelevalveta paigaldused](51-unattended-installs.md).

### Krüptimata paigaldused

Omarchy paigaldatakse vaikimisi krüptimisega. See on turvaline ja vastutustundlik valik iga arvuti puhul, mis võib kaduda või varastatud saada. Sa ei taha, et keegi, kes pääseb ligi sinu riistvarale, pääseks ligi ka sinu andmetele!

Aga erilistel asjaoludel, näiteks Omarchy kaugpaigaldustel kaitstud arvutitesse või äraviskepaigaldustel ilma tundlike andmeteta, võid soovida paigaldada ilma krüptimata. Krüptimata paigaldusele lülitumiseks saad ketta vormindamise kinnitamisel vajutada `Ctrl + C`.

### Keel

Omarchy räägib 50 keelt — sama komplekt kui omarchy.org — ja vaikekeel on inglise keel. Vahetamiseks ava Omarchy menüü ja mine _Setup > Language_, või käivita terminalis `omarchy language <code>` (`omarchy language list` näitab koode). Menüü, töölaud ja Omarchy enda teavitused vahetavad kohe keelt ja iga rakendus, mille seejärel avad, järgib samuti. Juba avatud rakendused vahetavad keelt, kui need taaskäivitad.

### Abi, kui jääd hätta

Kui jääd hätta, leiad tavaliselt kedagi, kes on nõus aitama, _#omarchy-help_ kanalis [kogukonna Discordis](https://omarchy.org/discord).
