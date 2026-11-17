# Darba sākšana

Omarchy tiek instalēta, izmantojot ISO. Varat izvēlēties starp pilna diska instalāciju, kas pārņem visu disku, vai instalāciju brīvajā vietā, kas ievieto Omarchy nepiešķirtajā vietā diskā — tā jūs veicat dubulto palaišanu līdzās Windows vai citai OS (skatiet [dubultās palaišanas instalāciju](50-dual-boot-install.md) — ņemiet vērā, ka vispirms Windows būs jāizslēdz BitLocker). Abos gadījumos instalācija pēc noklusējuma izmanto pilnu šifrēšanu, un pilna diska opcija izdzēsīs atlasīto disku, tāpēc pirms esoša diska izmantošanas noteikti izveidojiet rezerves kopiju!

Vispirms [lejupielādējiet Omarchy ISO](https://omarchy.org/), ievietojiet to USB zibatmiņā (izmantojiet [Rufus](https://rufus.ie/) operētājsistēmā Windows, [balenaEtcher](https://etcher.balena.io/) operētājsistēmā Mac vai [caligula](https://github.com/ifd3f/caligula) operētājsistēmā Linux) un palaidiet no zibatmiņas.

_BIOS ir jāizslēdz Secure Boot un/vai TPM. Tie ir jāizslēdz, lai varētu instalēt Omarchy. Tās ir Microsoft drošības shēmas, kas paredzētas Windows un ar Microsoft saistītajām Linux distribūcijām._

Pēc tam atbildiet uz konfigurācijas jautājumiem un apstipriniet tos šādi:

 ![install-config](images/install-config.webp)

Pēc tam atlasiet disku instalācijai, atsēdieties un vērojiet instalācijas izrādi. Ātrākajās mūsdienu iekārtās to var paveikt mazāk nekā minūtē, bet pat vecākā datorā tam nevajadzētu aizņemt vairāk par 5 minūtēm.

 ![install-done](images/install-done.webp)

Tagad esat gatavs Omarchy!

### Izmantojiet vadu vai 2.4ghz tastatūru!

Pilna diska šifrēšana neļaus jums startēšanas laikā ievadīt paroli no Bluetooth tastatūras. Tieši tāpat kā datorā nevarat izmantot Bluetooth tastatūru, lai ievadītu BIOS. Jums būs nepieciešama tastatūra, kas izmanto vai nu 2.4ghz uztvērēju, vai kabeli (kas jebkurā gadījumā ir daudz patīkamāk aiztures ziņā!). Man personīgi ļoti patīk [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalēšana citam īpašniekam

Ja iestatāt datoru kādam citam — ģimenes loceklim, jaunam darbiniekam, pircējam — jums nevajadzētu atbildēt uz personīgajiem jautājumiem viņu vietā. Nospiediet `Ctrl + C` pašā pirmajā instalētāja ekrānā (tastatūras izvēlē), un Omarchy piedāvās tā vietā sagatavot datoru citam īpašniekam. Sistēma instalējas uzreiz, bet visa personīgā iestatīšana — tastatūras izkārtojums, lietotājvārds, parole — tiek atlikta līdz datora pirmajai palaišanai. Disks joprojām pēc noklusējuma ir šifrēts, un parole, ko jaunais īpašnieks izvēlas šajā pirmajā palaišanā, kļūst arī par šifrēšanas paroli. (Datoru, ko jau esat lietojis, var nodot arī bez atkārtotas instalēšanas — skatiet [datora atiestatīšanu](48-security.md).)

### Instalācijas bez uzraudzības

ISO var arī instalēt pilnīgi patstāvīgi — bez tastatūras, bez vedņa — kad tā konfigurācija tiek nodota otrajā diskā. Tas ir veids, kā izmantot Omarchy kā bāzes attēlu VM un iekārtu parkam. Skatiet [instalācijas bez uzraudzības](51-unattended-installs.md).

### Instalācijas bez šifrēšanas

Omarchy pēc noklusējuma tiek instalēta ar šifrēšanu. Tā ir droša, atbildīga izvēle jebkuram datoram, ko iespējams pazaudēt vai nozagt. Jūs nevēlaties, lai ikviens, kam ir piekļuve jūsu aparatūrai, varētu iegūt jūsu datus!

Bet īpašos apstākļos, piemēram, attālinātām Omarchy instalācijām aizsargātos datoros vai vienreiz lietojamām instalācijām bez sensitīviem datiem, iespējams, vēlēsieties instalēt bez šifrēšanas. Diska formatēšanas apstiprinājumā varat nospiest `Ctrl + C`, lai pārslēgtos uz instalāciju bez šifrēšanas.

### Valoda

Omarchy runā 50 valodās — tajā pašā kopumā kā omarchy.org — un angļu valoda ir noklusējuma valoda. Lai pārslēgtu, atveriet Omarchy izvēlni un dodieties uz _Iestatīšana > Valoda_ vai terminālī palaidiet `omarchy language <code>` (`omarchy language list` parāda kodus). Izvēlne, darbvirsma un Omarchy paša paziņojumi maina valodu nekavējoties, un katra lietotne, ko atverat pēc tam, arī seko līdzi. Lietotnes, kas jau bija atvērtas, pārslēdzas, tiklīdz tās restartējat.

### Palīdzība, ja esat iestrēdzis

Ja esat iestrēdzis, parasti varat atrast kādu, kas vēlas palīdzēt, kanālā _#omarchy-help_ [kopienas Discord](https://omarchy.org/discord).
