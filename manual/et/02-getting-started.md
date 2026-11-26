# Alustamine

Omarchy paigaldatakse ISO abil. Saad valida täisketta paigalduse, mis võtab kogu ketta üle, või vaba ruumi paigalduse, mis paneb Omarchy kettale eraldamata ruumi — nii saad topeltkäivitada Windowsi või mõne muu OS-i kõrvalt (vaata [topeltkäivitusega paigaldus](50-dual-boot-install.md) — pane tähele, et kõigepealt pead Windowsis BitLockeri välja lülitama). Mõlemal juhul on paigaldus vaikimisi täielikult krüptitud ja täisketta valik pühib valitud ketta puhtaks, nii et tee olemasoleva ketta kasutamise korral kindlasti enne varukoopia!

Apple Siliconiga Macil paigaldad selle asemel macOS-ist, ilma ISO või USB-mälupulgata. Vaata [Omarchy Apple Siliconile](44-mac-support.md#omarchy-for-apple-silicon).

[Laadi Omarchy ISO](https://omarchy.org/) esmalt alla, pane see USB-mälupulgale (kasuta Windowsis [Rufus](https://rufus.ie/), Macis [balenaEtcher](https://etcher.balena.io/) või Linuxis [caligula](https://github.com/ifd3f/caligula)) ja käivita arvuti mälupulgalt.

_Pead BIOS-is Secure Booti ja/või TPM-i välja lülitama. Pead need välja lülitama, et saaksid Omarchy paigaldada. Need on Microsofti turvasüsteemid, mis on mõeldud Windowsile ja Microsoftiga seotud Linuxi distributsioonidele._

Seejärel vasta konfiguratsiooniküsimustele ja kinnita need nii:

 ![install-config](images/install-config.webp)

Seejärel vali paigaldamiseks ketas, istu maha ja vaata paigaldusetendust. Kiireimatel tänapäevastel masinatel saab sellega hakkama vähem kui minutiga, kuid isegi vanemal arvutil ei tohiks see võtta rohkem kui 5 minutit.

 ![install-done](images/install-done.webp)

Nüüd oled Omarchyks valmis!

### Kasuta juhtmega või 2.4ghz klaviatuuri!

Täisketta krüptimine ei lase sul käivitamisel Bluetoothi klaviatuurilt parooli sisestada. Nii nagu sa ei saa PC-l Bluetoothi klaviatuuri BIOS-i sisenemiseks kasutada. Vajad klaviatuuri, mis kasutab kas 2.4ghz donglit või kaablit (mis on latentsuse poolest nagunii palju mõnusam!). Mulle endale meeldib väga [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Paigaldamine teisele omanikule

Kui seadistad masinat kellelegi teisele — pereliikmele, uuele töötajale, ostjale — ei peaks sa isiklikele küsimustele tema eest vastama. Vajuta paigaldaja kõige esimesel ekraanil (klaviatuuri valikul) `Ctrl + C` ja Omarchy pakub selle asemel võimalust valmistada masin ette teisele omanikule. Süsteem paigaldatakse kohe, kuid kogu isiklik seadistus — klaviatuuripaigutus, kasutajanimi, parool — lükatakse edasi ajani, mil masin esimest korda käivitub. Ketas on endiselt vaikimisi krüptitud ja paroolist, mille uus omanik sellel esimesel käivitamisel valib, saab ka krüptimisparool. (Juba kasutatud masina saab ka ilma uuesti paigaldamata üle anda — vaata [arvuti lähtestamine](48-security.md).)

### Järelevalveta paigaldused

ISO saab ka täiesti iseseisvalt paigaldada — ilma klaviatuuri ja viisardita — kui sellele antakse konfiguratsioon teisel kettal. Nii tasub Omarchyt käsitleda VM-ide ja masinaparkide baaskujutisena. Vaata [järelevalveta paigaldused](51-unattended-installs.md).

### Krüptimiseta paigaldused

Omarchy paigaldatakse vaikimisi krüptimisega. See on turvaline ja vastutustundlik valik iga arvuti puhul, mis võib kaduma minna või varastatud saada. Sa ei taha, et keegi, kellel on juurdepääs su riistvarale, saaks su andmetele ligi!

Kuid eriolukordades, näiteks Omarchy kaugpaigaldustel kaitstud arvutitesse või ühekordsetesse paigaldustesse ilma tundlike andmeteta, võid tahta paigaldada ilma krüptimiseta. Krüptimiseta paigaldusele lülitumiseks saad ketta vormindamise kinnitusel vajutada `Ctrl + C`.

### Keel

Omarchy räägib 50 keelt — sama valikut nagu omarchy.org — ja vaikekeel on inglise keel. Vahetamiseks ava Omarchy menüü ja mine _Setup > Region > Language_ või käivita terminalis `omarchy language <code>` (`omarchy language list` näitab koode). Menüü, töölaud ja Omarchy enda teavitused vahetavad keelt kohe ning iga rakendus, mille pärast seda avad, järgib seda samuti. Juba avatud rakendused vahetavad keelt, kui oled need taaskäivitanud.

Kui soovid keele alles jätta, kuid kirjutada kuupäevi, kellaaegu, numbreid, raha, ühikuid ja paberiformaate nii, nagu mõni teine piirkond seda teeb (näiteks inglise keel Euroopa kuupäevade ja 24-tunnise kellaga), vali piirkond jaotises _Setup > Region > Formats_, kus iga valiku juures kuvatakse näidis, või käivita `omarchy region formats <code>` (`omarchy region formats list` näitab koode). _Same as language_ viib tagasi keele enda vormingute juurde. Nagu keelevahetuski, jõuab see rakendusteni, mille pärast seda avad.

### Abi, kui jääd hätta

Kui jääd hätta, leiad tavaliselt kellegi, kes on nõus aitama, [kogukonna Discordi](https://omarchy.org/discord) kanalil _#omarchy-help_.
