# Alustamine

Omarchy paigaldatakse ISO abil. Saad valida täisketta paigalduse, mis võtab kogu ketta üle, või vaba ruumi paigalduse, mis paneb Omarchy kettale eraldamata ruumi — nii saad dual boot'ida koos Windowsi või mõne muu OS-iga (vt [kahekordse alglaadimise paigaldus](50-dual-boot-install.md) — pane tähele, et enne tuleb Windowsis BitLocker välja lülitada). Mõlemal juhul on paigaldus vaikimisi täielikult krüptitud ja täisketta valik kustutab valitud ketta, seega tee olemasoleva ketta kasutamisel kindlasti enne varukoopia!

Laadi kõigepealt alla [Omarchy ISO](https://omarchy.org/), pane see USB-pulgale (kasuta Windowsis programmi [Rufus](https://rufus.ie/), Macis programmi [balenaEtcher](https://etcher.balena.io/) või Linuxis programmi [caligula](https://github.com/ifd3f/caligula)) ja käivita arvuti pulgalt.

_Pead BIOS-is Secure Boot ja/või TPM välja lülitama. Omarchy paigaldamiseks pead need välja lülitama. Need on Microsofti turvasüsteemid, mis on mõeldud Windowsi ja Microsoftiga seotud Linuxi distributsioonide jaoks._

Seejärel vasta seadistusküsimustele ja kinnita need nii:

 ![install-config](images/install-config.webp)

Seejärel vali paigalduseks ketas ning istu mugavalt ja vaata paigalduse etendust. Kiireimatel tänapäevastel masinatel saab sellega hakkama alla minutiga, kuid isegi vanemal arvutil ei tohiks see võtta üle 5 minuti.

 ![install-done](images/install-done.webp)

Nüüd oled Omarchyks valmis!

### Kasuta juhtmega või 2.4ghz klaviatuuri!

Täisketta krüptimine ei lase sul käivitamisel parooli Bluetooth-klaviatuurilt sisestada. Nii nagu sa ei saa Bluetooth-klaviatuuri kasutada PC-l BIOS-i sisenemiseks. Sul läheb vaja klaviatuuri, mis kasutab kas 2.4ghz dongle'it või kaablit (mis on latentsuse poolest nagunii palju parem!). Mulle isiklikult meeldib väga [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Paigaldamine teisele omanikule

Kui seadistad masinat kellegi teise jaoks — pereliikme, uue töötaja, ostja jaoks — ei peaks sa nende eest isiklikele küsimustele vastama. Vajuta paigaldaja kõige esimesel ekraanil (klaviatuuri valik) `Ctrl + C` ja Omarchy pakub selle asemel võimalust valmistada masin ette teise omaniku jaoks. Süsteem paigaldatakse kohe, kuid kogu isiklik seadistus — klaviatuuripaigutus, kasutajanimi, parool — lükatakse edasi ajani, mil masin esimest korda käivitub. Ketas on endiselt vaikimisi krüptitud ja parool, mille uus omanik sellel esimesel käivitamisel valib, saab ka krüptimisparooliks. (Masina, mida oled juba kasutanud, saab üle anda ka ilma uuesti paigaldamata — vt [arvuti lähtestamine](48-security.md).)

### Järelevalveta paigaldused

ISO saab paigaldada ka täiesti iseseisvalt — ilma klaviatuurita, ilma viisardita — kui sellele antakse seadistus teisel kettal. Nii saab Omarchyt käsitleda VM-ide ja masinapargi masinate baaskujutisena. Vt [järelevalveta paigaldused](51-unattended-installs.md).

### Krüptimiseta paigaldused

Omarchy paigaldatakse vaikimisi krüptimisega. See on turvaline ja vastutustundlik valik iga arvuti puhul, mis võib kaduda või varastatud saada. Sa ei taha, et keegi, kellel on juurdepääs sinu riistvarale, saaks sinu andmetele ligi!

Kuid eriolukordades, näiteks Omarchy kaugpaigaldamisel kaitstud arvutitesse või tundlike andmeteta ühekordsete paigalduste puhul, võid soovida paigaldada ilma krüptimiseta. Krüptimiseta paigaldusele lülitumiseks vajuta ketta vormindamise kinnitamisel `Ctrl + C`.

### Keel

Omarchy räägib 50 keelt — sama komplekt nagu omarchy.org — ja inglise keel on vaikekeel. Vahetamiseks ava Omarchy menüü ja mine jaotisse _Setup > Region > Language_ või käivita terminalis käsk `omarchy language <code>` (`omarchy language list` näitab koode). Menüü, töölaud ja Omarchy enda teavitused vahetavad keelt kohe ning iga rakendus, mille sa pärast avad, järgib seda samuti. Juba avatud rakendused vahetuvad, kui sa need taaskäivitad.

Et keel alles jätta, kuid kirjutada kuupäevad, kellaajad, numbrid, raha, ühikud ja paberiformaadid nii, nagu mõnes teises piirkonnas tehakse (näiteks inglise keel Euroopa kuupäevade ja 24-tunnise kellaga), vali jaotises _Setup > Region > Formats_ piirkond, kus iga valik näitab näidist, või käivita käsk `omarchy region <code>` (`omarchy region list` näitab koode). _Same as language_ naaseb keele enda vormingute juurde. Nagu keelevahetus, jõuab see rakendusteni, mille sa pärast avad.

### Abi, kui jääd hätta

Kui jääd hätta, leiad tavaliselt kellegi, kes on valmis aitama, [kogukonna Discordi](https://omarchy.org/discord) kanalil _#omarchy-help_.
