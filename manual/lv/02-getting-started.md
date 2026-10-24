# Darba sākšana

Omarchy tiek instalēta, izmantojot ISO. Tu vari izvēlēties starp pilna diska instalāciju, kas pārņem visu disku, vai instalāciju brīvajā vietā, kas Omarchy ievieto diska nepiešķirtajā vietā — tā tu veic divkāršu palaišanu līdzās Windows vai citai OS (sk. [divkāršās palaišanas instalāciju](50-dual-boot-install.md) — ņem vērā, ka tev vispirms Windows būs jāizslēdz BitLocker). Jebkurā gadījumā instalācija pēc noklusējuma izmanto pilnu šifrēšanu, un pilna diska opcija izdzēsīs atlasīto disku, tāpēc pirms esoša diska izmantošanas noteikti izveido rezerves kopiju!

Vispirms [lejupielādē Omarchy ISO](https://omarchy.org/), ieraksti to USB zibatmiņā (izmanto [balenaEtcher](https://etcher.balena.io/) Mac/Windows vai [caligula](https://github.com/ifd3f/caligula) Linux) un palaid datoru no zibatmiņas.

_Tev BIOS ir jāizslēdz Secure Boot un/vai TPM. Tev tie ir jāizslēdz, lai varētu instalēt Omarchy. Tās ir Microsoft drošības shēmas, kas paredzētas Windows un ar Microsoft saistītām Linux distributīvām._

Pēc tam atbildi uz konfigurācijas jautājumiem un apstiprini tos šādi:

 ![install-config](images/install-config.webp)

Pēc tam izvēlies disku instalācijai un atslābinies un skaties, kā norit instalācijas izrāde. Ātrākajos modernajos datoros to var paveikt mazāk nekā minūtē, taču pat vecākā datorā tam nevajadzētu aizņemt vairāk par 5 minūtēm.

 ![install-done](images/install-done.webp)

Tagad tu esi gatavs Omarchy!

### Izmanto vadu vai 2.4ghz tastatūru!

Pilna diska šifrēšana startēšanas laikā neļaus tev ievadīt paroli no Bluetooth tastatūras. Tieši tāpat kā tu nevari izmantot Bluetooth tastatūru, lai PC ieietu BIOS. Tev būs nepieciešama tastatūra, kas izmanto vai nu 2.4ghz dongli, vai kabeli (kas aiztures ziņā jebkurā gadījumā ir daudz patīkamāk!). Man pašam ļoti patīk [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalēšana citam īpašniekam

Ja tu iestati datoru kādam citam — ģimenes loceklim, jaunam darbiniekam, pircējam —, tev nevajadzētu atbildēt uz personīgajiem jautājumiem viņu vārdā. Instalatora pašā pirmajā ekrānā (tastatūras izvēlē) nospied `Ctrl + C`, un Omarchy tā vietā piedāvās sagatavot datoru citam īpašniekam. Sistēma tiek instalēta uzreiz, bet visa personīgā iestatīšana — tastatūras izkārtojums, lietotājvārds, parole — tiek atlikta līdz brīdim, kad dators tiek palaists pirmo reizi. Disks joprojām pēc noklusējuma ir šifrēts, un parole, ko jaunais īpašnieks izvēlas šajā pirmajā palaišanā, kļūst arī par šifrēšanas paroli. (Datoru, ko tu jau esi lietojis, arī var nodot citam bez pārinstalēšanas — sk. [datora atiestatīšanu](48-security.md).)

### Instalācijas bez uzraudzības

ISO var arī instalēties pilnīgi pats — bez tastatūras, bez vedņa —, kad tam konfigurācija tiek nodota otrajā diskā. Tā Omarchy var izmantot kā bāzes attēlu VM un datoru parka ierīcēm. Sk. [instalācijas bez uzraudzības](51-unattended-installs.md).

### Instalācijas bez šifrēšanas

Omarchy pēc noklusējuma tiek instalēta ar šifrēšanu. Tā ir droša un atbildīga izvēle jebkuram datoram, kuru iespējams pazaudēt vai kurš var tikt nozagts. Tu taču nevēlies, lai ikviens, kurš tiek klāt tavai aparatūrai, varētu tikt arī pie taviem datiem!

Taču īpašos apstākļos, piemēram, attālinātām Omarchy instalācijām aizsargātos datoros vai vienreizējām instalācijām bez sensitīviem datiem, tu varētu vēlēties instalēt bez šifrēšanas. Tu vari nospiest `Ctrl + C` diska formatēšanas apstiprinājumā, lai pārslēgtos uz instalāciju bez šifrēšanas.

### Valoda

Omarchy runā 50 valodās — tādā pašā kopumā kā omarchy.org —, un noklusējuma valoda ir angļu. Lai pārslēgtos, atver Omarchy izvēlni un ej uz _Setup > Language_ vai terminālī izpildi `omarchy language <code>` (`omarchy language list` parāda kodus). Izvēlne, darbvirsma un paša Omarchy paziņojumi valodu nomaina nekavējoties, un katra lietotne, ko tu atvērs pēc tam, arī tai sekos. Jau atvērtās lietotnes pārslēgsies, tiklīdz tu tās restartēsi.

### Palīdzība, ja esi iestrēdzis

Ja esi iestrēdzis, tu parasti vari atrast kādu, kurš ir gatavs palīdzēt, _#omarchy-help_ kanālā [kopienas Discord](https://omarchy.org/discord).
