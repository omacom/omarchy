# Alustamine

Omarchy paigaldatakse ISO abil. Saad valida täisketta paigalduse, mis võtab üle kogu ketta, või vaba ruumi paigalduse, mis paneb Omarchy kettale eraldamata ruumi — nii saad topeltkäivitada Windowsi või mõne muu OS-i kõrval (vt [topeltkäivituse paigaldus](50-dual-boot-install.md) — pane tähele, et pead Windowsis kõigepealt BitLockeri välja lülitama). Mõlemal juhul on paigaldus vaikimisi täielikult krüptitud ja täisketta valik kustutab valitud ketta, nii et tee olemasoleva ketta puhul enne kindlasti varukoopia!

[Laadi alla Omarchy ISO](https://omarchy.org/), pane see USB-mälupulgale (Windowsis kasuta [Rufus](https://rufus.ie/), Macis [balenaEtcher](https://etcher.balena.io/) või Linuxis [caligula](https://github.com/ifd3f/caligula)) ja käivita arvuti sellelt pulgalt.

_Pead BIOS-is Secure Booti ja/või TPM-i välja lülitama. Omarchy paigaldamiseks pead need välja lülitama. Need on Microsofti turvasüsteemid, mis on mõeldud Windowsi ja Microsoftiga seotud Linuxi distributsioonide jaoks._

Seejärel vasta konfiguratsiooniküsimustele ja kinnita need nii:

 ![install-config](images/install-config.webp)

Seejärel vali paigaldamiseks ketas, istu mugavalt ja vaata paigaldusetendust. Kiireimatel tänapäevastel masinatel saab sellega hakkama vähem kui minutiga, kuid isegi vanemal arvutil ei tohiks see võtta kauem kui 5 minutit.

 ![install-done](images/install-done.webp)

Nüüd oled Omarchy jaoks valmis!

### Kasuta juhtmega või 2.4ghz klaviatuuri!

Täisketta krüptimine ei lase sul käivitamisel Bluetoothi klaviatuurilt parooli sisestada. Nii nagu sa ei saa PC-l Bluetoothi klaviatuuriga BIOS-i siseneda. Sul on vaja klaviatuuri, mis kasutab kas 2.4ghz donglit või kaablit (mis on latentsuse poolest niikuinii palju parem!). Mulle isiklikult meeldib väga [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Paigaldamine teisele omanikule

Kui seadistad masinat kellelegi teisele — pereliikmele, uuele töötajale, ostjale — ei tohiks sa isiklikele küsimustele tema eest vastata. Vajuta paigaldaja kõige esimesel ekraanil (klaviatuuri valik) `Ctrl + C` ja Omarchy pakub selle asemel võimalust valmistada masin ette teisele omanikule. Süsteem paigaldatakse kohe, kuid kogu isiklik seadistus — klaviatuuripaigutus, kasutajanimi, parool — lükatakse edasi ajani, mil masin esimest korda käivitub. Ketas on endiselt vaikimisi krüptitud ja uue omaniku poolt sellel esimesel käivitamisel valitud paroolist saab ka krüptimisparool. (Juba kasutatud masina saab samuti ilma uuesti paigaldamata üle anda — vt [arvuti lähtestamine](48-security.md).)

### Järelevalveta paigaldused

ISO saab paigaldada ka täiesti iseseisvalt — ilma klaviatuuri ja viisardita — kui selle konfiguratsioon antakse kätte teisel kettal. Nii tasub Omarchyt käsitleda VM-ide ja masinaparkide baaskujutisena. Vt [järelevalveta paigaldused](51-unattended-installs.md).

### Krüptimiseta paigaldused

Omarchy paigaldatakse vaikimisi krüptimisega. See on turvaline ja vastutustundlik valik iga arvuti jaoks, mis võib kaduma minna või varastatud saada. Sa ei taha, et keegi sinu riistvarale juurde pääsedes saaks sinu andmed kätte!

Kuid eriolukordades, näiteks Omarchy kaugpaigalduste korral kaitstud arvutitesse või tundlike andmeteta ühekordsete paigalduste puhul, võid soovida paigaldada ilma krüptimiseta. Krüptimiseta paigaldusele lülitumiseks saad ketta vormindamise kinnitamisel vajutada `Ctrl + C`.

### Keel

Omarchy räägib 50 keelt — sama valikut nagu omarchy.org — ja vaikimisi keeleks on inglise keel. Vahetamiseks ava Omarchy menüü ja mine _Seadistamine > Piirkond > Keel_ või käivita terminalis `omarchy language <code>` (`omarchy language list` näitab koode). Menüü, töölaud ja Omarchy enda teavitused vahetavad keelt kohe ning iga pärast seda avatav rakendus järgneb samuti. Juba avatud rakendused vahetavad keelt, kui oled need taaskäivitanud.

Kui soovid keele alles jätta, aga kirjutada kuupäevi, kellaaegu, numbreid, raha, ühikuid ja paberiformaate nii, nagu seda teeb mõni muu piirkond (näiteks inglise keel koos Euroopa kuupäevade ja 24-tunnise kellaga), vali piirkond jaotises _Seadistamine > Piirkond > Vormingud_, kus iga valiku juures on näidis, või käivita `omarchy region formats <code>` (`omarchy region formats list` näitab koode). _Sama nagu keel_ läheb tagasi keele enda vormingute juurde. Nagu keelevahetuski, jõuab see rakendusteni, mille pärast seda avad.

### Abi, kui hätta jääd

Kui hätta jääd, leiad tavaliselt kellegi, kes on valmis aitama, [kogukonna Discordi](https://omarchy.org/discord) kanalil _#omarchy-help_.
