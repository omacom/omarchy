# Darba sākšana

Omarchy tiek instalēta, izmantojot ISO. Tu vari izvēlēties starp instalāciju uz visa diska, kas pārņem visu disku, vai instalāciju brīvajā vietā, kas ievieto Omarchy neiedalītajā diska vietā — tā tu vari palaist divas sistēmas līdzās Windows vai citai OS (skatiet [dubultās palaišanas instalācija](50-dual-boot-install.md) — ņem vērā, ka vispirms Windows būs jāizslēdz BitLocker). Jebkurā gadījumā instalācija pēc noklusējuma izmanto pilnu šifrēšanu, un visa diska opcija izdzēsīs izvēlēto disku, tāpēc pirms esoša diska izmantošanas noteikti izveido rezerves kopiju!

Vispirms [lejupielādē Omarchy ISO](https://omarchy.org/), ieraksti to USB zibatmiņā (izmanto [Rufus](https://rufus.ie/) sistēmā Windows, [balenaEtcher](https://etcher.balena.io/) sistēmā Mac vai [caligula](https://github.com/ifd3f/caligula) sistēmā Linux) un palaid sistēmu no zibatmiņas.

_BIOS ir jāizslēdz Secure Boot un/vai TPM. Tev tie ir jāizslēdz, lai varētu instalēt Omarchy. Tās ir Microsoft drošības shēmas, kas paredzētas Windows un ar Microsoft saistītām Linux distribūcijām._

Tad atbildi uz konfigurācijas jautājumiem un apstiprini tos šādi:

 ![install-config](images/install-config.webp)

Tad izvēlies disku instalācijai, atsēdies un skaties instalācijas izrādi. Ātrākajās modernajās ierīcēs to var paveikt mazāk nekā minūtē, bet pat uz vecāka datora tam nevajadzētu aizņemt vairāk par 5 minūtēm.

 ![install-done](images/install-done.webp)

Tagad esi gatavs Omarchy!

### Izmanto vadu vai 2.4ghz tastatūru!

Visa diska šifrēšana neļaus tev ievadīt paroli no Bluetooth tastatūras startēšanas laikā. Tieši tāpat kā tu nevari izmantot Bluetooth tastatūru, lai ievadītu BIOS PC. Tev būs vajadzīga tastatūra, kas izmanto vai nu 2.4ghz uztvērēju, vai kabeli (kas jebkurā gadījumā ir daudz patīkamāk latentuma dēļ!). Man personīgi ļoti patīk [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalēšana citam īpašniekam

Ja tu uzstādi datoru kādam citam — ģimenes loceklim, jaunam darbiniekam, pircējam — tev nevajadzētu atbildēt uz personīgajiem jautājumiem viņu vārdā. Nospied `Ctrl + C` pašā pirmajā instalētāja ekrānā (tastatūras izvēlē), un Omarchy tā vietā piedāvās sagatavot datoru citam īpašniekam. Sistēma tiek instalēta uzreiz, bet visa personīgā iestatīšana — tastatūras izkārtojums, lietotājvārds, parole — tiek atlikta līdz datora pirmajai palaišanai. Disks joprojām pēc noklusējuma ir šifrēts, un parole, ko jaunais īpašnieks izvēlas tajā pirmajā palaišanā, kļūst arī par šifrēšanas paroli. (Datoru, ko tu jau esi lietojis, var nodot arī bez atkārtotas instalēšanas — skatiet [datora atiestatīšana](48-security.md).)

### Instalācijas bez uzraudzības

ISO var arī instalēt pilnīgi pats — bez tastatūras, bez vedņa — kad tam konfigurācija tiek nodota otrajā diskā. Tas ir veids, kā pret Omarchy izturēties kā pret bāzes attēlu VM un datoru parkiem. Skatiet [instalācijas bez uzraudzības](51-unattended-installs.md).

### Instalācijas bez šifrēšanas

Omarchy pēc noklusējuma tiek instalēta ar šifrēšanu. Tā ir droša, atbildīga izvēle jebkuram datoram, ko iespējams pazaudēt vai kas var tikt nozagts. Tu nevēlies, lai kāds, kam ir piekļuve tavai aparatūrai, varētu tikt pie taviem datiem!

Bet īpašos apstākļos, piemēram, attālinātām Omarchy instalācijām aizsargātos datoros vai vienreiz lietojamām instalācijām bez sensitīviem datiem, tu, iespējams, vēlēsies instalēt bez šifrēšanas. Tu vari nospiest `Ctrl + C` diska formatēšanas apstiprinājumā, lai pārslēgtos uz instalāciju bez šifrēšanas.

### Valoda

Omarchy runā 50 valodās — tajā pašā komplektā kā omarchy.org — un angļu valoda ir noklusējuma valoda. Lai pārslēgtu, atver Omarchy izvēlni un dodies uz _Setup > Region > Language_ vai palaid `omarchy language <code>` terminālī (`omarchy language list` parāda kodus). Izvēlne, darbvirsma un paša Omarchy paziņojumi maina valodu nekavējoties, un katra lietotne, ko tu atver pēc tam, seko arī. Lietotnes, kas jau bija atvērtas, pārslēdzas, tiklīdz tu tās restartē.

Lai saglabātu valodu, bet rakstītu datumus, laikus, skaitļus, naudu, mērvienības un papīra izmērus tā, kā to dara citā reģionā (piemēram, angļu valodā ar Eiropas datumiem un 24 stundu pulksteni), izvēlies reģionu sadaļā _Setup > Region > Formats_, kur katra izvēle rāda paraugu, vai palaid `omarchy region <code>` (`omarchy region list` parāda kodus). _Same as language_ atgriež valodas pašas formātus. Tāpat kā valodas pārslēgšana, tā sasniedz lietotnes, ko tu atver pēc tam.

### Palīdzība, ja esi iestrēdzis

Ja esi iestrēdzis, parasti tu vari atrast kādu, kurš vēlas palīdzēt, _#omarchy-help_ kanālā [kopienas Discord](https://omarchy.org/discord).
