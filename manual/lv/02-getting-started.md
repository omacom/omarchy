# Darba sākšana

Omarchy tiek instalēts, izmantojot ISO. Varat izvēlēties starp pilna diska instalēšanu, kas pārņem visu disku, vai brīvās vietas instalēšanu, kas Omarchy ievieto nepiešķirtajā vietā diskā — tā jūs veicat duālo sāknēšanu līdzās Windows vai citai OS (skatiet [duālās sāknēšanas instalēšanu](50-dual-boot-install.md) — ņemiet vērā, ka vispirms Windows būs jāizslēdz BitLocker). Jebkurā gadījumā instalēšana pēc noklusējuma izmanto pilnu šifrēšanu, un pilna diska opcija izdzēsīs atlasīto disku, tāpēc pirms esoša diska izmantošanas noteikti izveidojiet dublējumu!

Vispirms [lejupielādējiet Omarchy ISO](https://omarchy.org/), ierakstiet to USB atmiņā (Windows izmantojiet [Rufus](https://rufus.ie/), Mac — [balenaEtcher](https://etcher.balena.io/), bet Linux — [caligula](https://github.com/ifd3f/caligula)) un sāknējiet no atmiņas.

_BIOS ir jāizslēdz Secure Boot un/vai TPM. Lai varētu instalēt Omarchy, tie ir jāizslēdz. Tās ir Microsoft drošības shēmas, kas paredzētas Windows un ar Microsoft saistītām Linux distribūcijām._

Pēc tam atbildiet uz konfigurācijas jautājumiem un apstipriniet tos šādi:

 ![install-config](images/install-config.webp)

Pēc tam atlasiet disku instalēšanai, atslābstiet un vērojiet instalēšanas izrādi. Ātrākajās mūsdienu iekārtās to var paveikt mazāk nekā minūtē, bet pat vecākā datorā tai nevajadzētu aizņemt vairāk par 5 minūtēm.

 ![install-done](images/install-done.webp)

Tagad esat gatavs Omarchy!

### Izmantojiet vadu vai 2.4ghz tastatūru!

Pilna diska šifrēšana neļaus jums startēšanas laikā ievadīt paroli no Bluetooth tastatūras. Gluži tāpat kā PC nevar izmantot Bluetooth tastatūru, lai iekļūtu BIOS. Jums būs nepieciešama tastatūra, kas izmanto 2.4ghz adapteri vai kabeli (kas jebkurā gadījumā ir daudz patīkamāk aizkaves dēļ!). Man personīgi ļoti patīk [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalēšana citam īpašniekam

Ja iekārtojat datoru kādam citam — ģimenes loceklim, jaunam darbiniekam, pircējam — jums nevajadzētu atbildēt uz personīgajiem jautājumiem viņu vietā. Instalētāja pašā pirmajā ekrānā (tastatūras atlasē) nospiediet `Ctrl + C`, un Omarchy piedāvās tā vietā sagatavot datoru citam īpašniekam. Sistēma tiek instalēta uzreiz, bet visa personīgā iestatīšana — tastatūras izkārtojums, lietotājvārds, parole — tiek atlikta līdz datora pirmajai sāknēšanai. Disks joprojām pēc noklusējuma tiek šifrēts, un parole, ko jaunais īpašnieks izvēlas šajā pirmajā sāknēšanā, kļūst arī par šifrēšanas paroli. (Datoru, ko jau esat lietojis, var nodot citam arī bez pārinstalēšanas — skatiet [datora atiestatīšanu](48-security.md).)

### Instalēšana bez uzraudzības

ISO var instalēt arī pilnībā pats — bez tastatūras, bez vedņa —, ja tam konfigurācija tiek nodota otrajā diskā. Tā Omarchy var izmantot kā bāzes attēlu VM un iekārtu parkiem. Skatiet [instalēšanu bez uzraudzības](51-unattended-installs.md).

### Instalēšana bez šifrēšanas

Omarchy pēc noklusējuma tiek instalēts ar šifrēšanu. Tā ir droša un atbildīga izvēle jebkuram datoram, ko, iespējams, var pazaudēt vai nozagt. Jūs nevēlaties, lai kāds, kam ir piekļuve jūsu aparatūrai, varētu tikt pie jūsu datiem!

Bet īpašos apstākļos, piemēram, attālinātai Omarchy instalēšanai aizsargātos datoros vai vienreiz lietojamām instalācijām bez sensitīviem datiem, jūs, iespējams, vēlēsieties instalēt bez šifrēšanas. Diska formatēšanas apstiprinājumā varat nospiest `Ctrl + C`, lai pārietu uz instalēšanu bez šifrēšanas.

### Valoda

Omarchy runā 50 valodās — tajā pašā kopā kā omarchy.org —, un angļu valoda ir noklusējuma valoda. Lai pārslēgtos, atveriet Omarchy izvēlni un dodieties uz _Iestatīšana > Reģions > Valoda_ vai terminālī palaidiet `omarchy language <code>` (`omarchy language list` parāda kodus). Izvēlne, darbvirsma un paša Omarchy paziņojumi valodu maina nekavējoties, un ikviena lietotne, ko atverat pēc tam, arī seko. Lietotnes, kas jau bija atvērtas, pārslēdzas, tiklīdz tās restartējat.

Lai saglabātu valodu, bet datumus, laikus, skaitļus, naudu, mērvienības un papīra izmērus rakstītu tā, kā to dara citā reģionā (piemēram, angļu valoda ar Eiropas datumiem un 24 stundu pulksteni), izvēlieties reģionu sadaļā _Iestatīšana > Reģions > Formāti_, kur katrai izvēlei tiek rādīts paraugs, vai palaidiet `omarchy region formats <code>` (`omarchy region formats list` parāda kodus). _Tāpat kā valoda_ atgriež valodas formātus. Tāpat kā valodas maiņa, tā attiecas uz lietotnēm, ko atverat pēc tam.

### Palīdzība, ja iestrēgstat

Ja iestrēgstat, parasti varat atrast kādu, kas vēlas palīdzēt, kanālā _#omarchy-help_ [kopienas Discord](https://omarchy.org/discord).
