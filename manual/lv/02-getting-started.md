# Darba sākšana

Omarchy tiek instalēts, izmantojot ISO. Varat izvēlēties starp pilna diska instalāciju, kas pārņem visu disku, vai brīvās vietas instalāciju, kas ievieto Omarchy diska nepiešķirtajā vietā — tā jūs veicat duālo sāknēšanu līdzās Windows vai citai OS (skatiet [duālās sāknēšanas instalācija](50-dual-boot-install.md) — ņemiet vērā, ka vispirms Windows būs jāizslēdz BitLocker). Jebkurā gadījumā instalācija pēc noklusējuma izmanto pilnu šifrēšanu, un pilna diska opcija izdzēsīs izvēlēto disku, tāpēc pirms esoša diska izmantošanas noteikti izveidojiet dublējumu!

Apple Silicon Mac datorā instalēšana tā vietā notiek no macOS, bez ISO vai USB atmiņas. Skatiet [Omarchy priekš Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

Vispirms [lejupielādējiet Omarchy ISO](https://omarchy.org/), ierakstiet to USB atmiņā (izmantojiet [Rufus](https://rufus.ie/) operētājsistēmā Windows, [balenaEtcher](https://etcher.balena.io/) operētājsistēmā Mac vai [caligula](https://github.com/ifd3f/caligula) operētājsistēmā Linux) un sāknējiet no atmiņas.

_Jums BIOS ir jāizslēdz Secure Boot un/vai TPM. Lai varētu instalēt Omarchy, tie ir jāizslēdz. Tās ir Microsoft drošības shēmas, kas paredzētas Windows un ar Microsoft saistītām Linux distribūcijām._

Pēc tam atbildiet uz konfigurācijas jautājumiem un apstipriniet tos šādi:

 ![install-config](images/install-config.webp)

Pēc tam izvēlieties instalācijas disku, atsēdieties un vērojiet instalācijas šovu. Ātrākajos mūsdienu datoros to var paveikt mazāk nekā minūtē, bet pat vecākā datorā tai nevajadzētu aizņemt vairāk par 5 minūtēm.

 ![install-done](images/install-done.webp)

Tagad esat gatavs Omarchy!

### Izmantojiet vadu vai 2.4ghz tastatūru!

Pilna diska šifrēšana neļaus startēšanas laikā ievadīt paroli no Bluetooth tastatūras. Gluži tāpat kā nevarat izmantot Bluetooth tastatūru, lai ieietu PC BIOS. Jums būs nepieciešama tastatūra, kas izmanto vai nu 2.4ghz sargspraudni, vai kabeli (kas tik un tā ir daudz patīkamāk aiztures ziņā!). Man personīgi ļoti patīk [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalēšana citam īpašniekam

Ja iekārtojat datoru kādam citam — ģimenes loceklim, jaunam darbiniekam, pircējam — jums nevajadzētu viņu vietā atbildēt uz personīgajiem jautājumiem. Instalētāja pašā pirmajā ekrānā (tastatūras izvēlē) nospiediet `Ctrl + C`, un Omarchy tā vietā piedāvās sagatavot datoru citam īpašniekam. Sistēma tiek instalēta uzreiz, bet visa personīgā iestatīšana — tastatūras izkārtojums, lietotājvārds, parole — tiek atlikta līdz datora pirmajai sāknēšanai. Disks joprojām pēc noklusējuma ir šifrēts, un parole, ko jaunais īpašnieks izvēlas tajā pirmajā sāknēšanā, kļūst arī par šifrēšanas paroli. (Datoru, ko jau esat lietojis, var nodot arī bez atkārtotas instalēšanas — skatiet [datora atiestatīšana](48-security.md).)

### Instalācijas bez uzraudzības

ISO var instalēt arī pilnīgi patstāvīgi — bez tastatūras, bez vedņa —, kad tam otrajā diskā tiek nodota tā konfigurācija. Tas ir veids, kā pret Omarchy attiekties kā pret bāzes attēlu VM un datoru parka iekārtām. Skatiet [instalācijas bez uzraudzības](51-unattended-installs.md).

### Instalācijas bez šifrēšanas

Omarchy pēc noklusējuma tiek instalēts ar šifrēšanu. Tā ir droša, atbildīga izvēle jebkuram datoram, ko iespējams pazaudēt vai nozagt. Jūs nevēlaties, lai kāds, kam ir piekļuve jūsu aparatūrai, varētu tikt pie jūsu datiem!

Bet īpašos apstākļos, piemēram, attālinātām Omarchy instalācijām aizsargātos datoros vai vienreizējām instalācijām bez sensitīviem datiem, iespējams, vēlēsieties instalēt bez šifrēšanas. Diska formatēšanas apstiprinājumā varat nospiest `Ctrl + C`, lai pārslēgtos uz instalāciju bez šifrēšanas.

### Valoda

Omarchy runā 50 valodās — tajā pašā komplektā kā omarchy.org —, un angļu valoda ir noklusējuma valoda. Lai pārslēgtu, atveriet Omarchy izvēlni un dodieties uz _Iestatīšana > Reģions > Valoda_ vai terminālī palaidiet `omarchy language <code>` (`omarchy language list` parāda kodus). Izvēlne, darbvirsma un paša Omarchy paziņojumi maina valodu nekavējoties, un katra lietotne, ko atverat pēc tam, arī seko. Lietotnes, kas jau bija atvērtas, pārslēdzas, tiklīdz tās restartējat.

Lai saglabātu valodu, bet datumus, laikus, skaitļus, naudu, mērvienības un papīra izmērus rakstītu tā, kā to dara cits reģions (teiksim, angļu valoda ar Eiropas datumiem un 24 stundu pulksteni), sadaļā _Iestatīšana > Reģions > Formāti_ izvēlieties reģionu, kur katra izvēle rāda paraugu, vai palaidiet `omarchy region formats <code>` (`omarchy region formats list` parāda kodus). _Tāpat kā valoda_ atgriež valodas pašas formātus. Tāpat kā valodas maiņa, tā sasniedz lietotnes, ko atverat pēc tam.

### Palīdzība, ja esat iestrēdzis

Ja esat iestrēdzis, parasti varat atrast kādu, kas vēlas palīdzēt, kanālā _#omarchy-help_ [kopienas Discord](https://omarchy.org/discord).
