# Uppfærslur

Omarchy og pakkarnir þínir eru haldnir uppfærðum í gegnum _Update > Omarchy_ í Omarchy-valmyndinni (`Super + Space`).

Omarchy sjálft er sett upp sem venjulegir pacman-pakkar frá [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), svo uppfærsla setur upp [nýjustu Omarchy-útgáfuna](https://github.com/omacom/omarchy/releases), keyrir alla flutninga sem eru í bið til að samstilla kerfið þitt við það nýjasta, og uppfærir alla kerfispakka frá [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) og [AUR](https://aur.archlinux.org/) (ef þú hefur sett upp einhverja AUR-pakka).

Þegar nýjar útgáfur koma út birtist tákn með hringör hægra megin við klukkuna þína. Smelltu á það og uppfærsluferlið hefst.

![update-available](images/update-available.webp)

### Fjórar rásir

Omarchy er uppfært eftir fjórum rásum: stable, RC, edge og dev. Nýjar uppsetningar byrja á stable-rásinni, sem fylgir [opinberum útgáfum](https://github.com/omacom/omarchy/releases/), sem og [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) sem er einum mánuði á eftir því nýjasta, svo við getum gripið öll ný ósamrýmanleikavandamál sem krefjast stillingabreytinga áður en þau valda fólki vandræðum.

En ef þú vilt hjálpa til við að koma auga á þessi hugsanlegu vandamál geturðu keyrt á edge-rásinni. Það heldur Omarchy-pökkunum þínum í takt við nýjustu þróunarútgáfur og gerir þér kleift að uppfæra í nýjustu Arch-pakkana um leið og þeir verða fáanlegir. Þú ættir aðeins að gera þetta ef þú hefur reynslu af Linux og veist hvernig á að endurheimta kerfi sem lendir í vandræðum.

Fyrir hverja nýja stóra útgáfu munum við framkvæma lokaúttekt með RC-rásinni. Ef þú hefur áhuga á að hjálpa til við lokafráganginn, komdu þá og vertu með í #omarchy-release-candidates á Discord.

Að lokum er dev-rásin, sem tengir Omarchy beint við git-úttekt á frumkóðanum í `~/omarchy`, ásamt edge-pökkunum. Þú ættir aðeins að nota þessa rás ef þú ert reyndur Linux-notandi, vinnur beint að Omarchy og ert tilbúinn að þola bilanir.

Þú getur skipt á milli rása með _Update > Channel_ í Omarchy-valmyndinni (eða `omarchy channel set <stable|rc|edge|dev>` í skelinni, með `omarchy channel current` til að sjá hvar þú ert).

### Að skipta um kjarna

Omarchy ræsir sinn eigin `linux-omarchy` kjarna, en þú getur haft aðra uppsetta við hliðina á honum, eins og staðlaða Arch `linux` kjarnann eða tilraunaútgáfu sem þú ert að prófa. Þegar það er fleiri en einn listar _Update > Kernel_ í Omarchy-valmyndinni þá upp með hak við þann sem ræsist sjálfgefið. Veldu annan, sláðu inn lykilorðið þitt einu sinni, og hann ræsist eftir næstu endurræsingu. Hinir kjarnarnir eru áfram í ræsivalmyndinni, svo þú getur samt valið einn handvirkt ef nýja sjálfgefna valið veldur þér vandræðum. Í skelinni er það `omarchy kernel` til að sjá núverandi sjálfgefna kjarnann, `omarchy kernel list` fyrir það sem er uppsett, og `omarchy kernel set <kernel>` til að skipta.

### Fastbúnaðaruppfærslur

Pakkarnir þínir eru ekki það eina sem verður úrelt. Margar fartölvur og jaðartæki senda frá sér BIOS-, SSD- og tengikvíarfastbúnað í gegnum Linux Vendor Firmware Service, og _Update > Firmware_ í Omarchy-valmyndinni sækir og setur upp allt sem vélbúnaðurinn þinn á í bið. Það setur upp `fwupd` í fyrsta skipti sem þú keyrir það. Mikið af fastbúnaði er aðeins hægt að skrifa við endurræsingu, svo vertu ekki hissa ef þú verður beðinn um eina slíka.

Þegar þú þarft að breyta stillingu í BIOS-inu sjálfu skaltu halda `Alt` inni í kerfisvalmyndinni (`Super + Escape`) og _Reboot_ breytist í _Reboot to BIOS_, sem endurræsir beint inn í uppsetningu fastbúnaðarins án þess að þú þurfir að ná réttum takka við ræsingu. Í skelinni er það `omarchy system firmware`.

### Viðvörun um beinar pacman/yay-uppfærslur

Ef þú þekkir Arch nú þegar gætir þú freistast til að keyra bara `pacman -Syu` eða `yay -Syu` sjálfur, en ef þú gerir það missir þú af skyndimyndinni, flutningunum og stillingauppfærslunum sem Omarchy keyrir ásamt nýjum pökkum. Þess vegna mun Omarchy í raun stöðva beina kerfisuppfærslu og benda þér á `omarchy update` í staðinn. (Ef þú veist virkilega hvað þú ert að gera mun vörðurinn segja þér hvernig þú getur sniðgengið hann fyrir eina einstaka aðgerð.)

### Að afturkalla slæmar uppfærslur

Ef þú lendir einhvern tíma í vandræðum eftir að hafa uppfært geturðu afturkallað kerfið þitt í skyndimyndina sem tekin var fyrir uppfærsluna. Endurræstu bara og veldu skyndimyndina í ræsivalmyndinni frá því áður en þú byrjaðir uppfærsluna.

![bootloader](images/bootloader.webp)

Ef stillingarskrárnar þínar hafa einhvern veginn skemmst geturðu líka endursett Omarchy með `omarchy reinstall` í skelinni. Þetta mun endursetja alla sjálfgefna Omarchy-pakka, setja þig á stable (edge á Apple Silicon) og lækka útgáfu allra pakka sem eru of nýir, og endurstilla allar stillingarskrár. Athugaðu að allar breytingar þínar á notandastillingum á sjálfgefnum stillingum Omarchy verða yfirskrifaðar þegar þetta er gert!
