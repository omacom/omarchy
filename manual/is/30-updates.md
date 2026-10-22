# Uppfærslur

Omarchy og pökkunum þínum er haldið uppfærðum í gegnum _Uppfæra > Omarchy_ í Omarchy-valmyndinni (`Super + Space`).

Omarchy sjálft er sett upp sem venjulegir pacman-pakkar frá [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), þannig að uppfærsla setur upp [nýjustu Omarchy-útgáfuna](https://github.com/omacom/omarchy/releases), keyrir allar flutninga í bið til að koma kerfinu þínu í samstillingu við það nýjasta, og uppfærir alla kerfispakka frá [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) og [AUR](https://aur.archlinux.org/) (ef þú hefur sett upp einhverja AUR-pakka).

Þegar nýjar útgáfur eru gefnar út mun hringörvartákn birtast hægra megin við klukkuna þína. Smelltu á það og uppfærsluferlið mun hefjast.

![update-available](images/update-available.webp)

### Fjórar rásir

Omarchy er uppfært eftir fjórum rásum: stable, RC, edge og dev. Nýjar uppsetningar byrja á stable-rásinni, sem fylgir [opinberu útgáfunum](https://github.com/omacom/omarchy/releases/), auk [stable Omarchy Arch-spegilsins](https://github.com/omacom-io/omarchy-mirror) sem keyrir einum mánuði á eftir því nýjasta, þannig að við getum gripið ný ósamræmi sem krefjast stillingarbreytinga áður en þau valda fólki vandamálum.

En ef þú vilt hjálpa til við að koma auga á þau hugsanlegu vandamál geturðu keyrt á edge-rásinni. Það mun halda Omarchy-pökkunum þínum í takt við nýjustu þróunarbyggðirnar, og leyfir þér að uppfæra í nýjustu Arch-pakkana um leið og þeir eru fáanlegir. Þú ættir aðeins að gera þetta ef þú ert vanur Linux, og veist hvernig á að endurheimta kerfi sem á í vandræðum.

Fyrir hverja nýja stóra útgáfu munum við gera lokaprófun með RC-rásinni. Ef þú hefur áhuga á að hjálpa við lokafrágang skaltu koma og hanga í #omarchy-release-candidates á Discord.

Loks er dev-rásin, sem tengir Omarchy beint við git-afrit af frumkóðanum í `~/omarchy`, ásamt edge-pökkunum. Þú ættir aðeins að nota þessa rás ef þú ert vanur Linux-notandi, vinnur beint við Omarchy og ert tilbúinn að þola bilanir.

Þú getur skipt á milli rása með _Uppfæra > Rás_ úr Omarchy-valmyndinni (eða `omarchy-channel-set` í terminalinu).

### Fastbúnaðaruppfærslur

Pakkarnir þínir eru ekki það eina sem verður úrelt. Margar fartölvur og jaðartæki senda BIOS-, SSD- og bryggju-fastbúnað í gegnum Linux Vendor Firmware Service, og _Uppfæra > Fastbúnaður_ í Omarchy-valmyndinni mun sækja og setja upp það sem vélbúnaðurinn þinn hefur í bið. Það setur upp `fwupd` í fyrsta skipti sem þú keyrir það. Mikið af fastbúnaði er aðeins hægt að skrifa við endurræsingu, þannig að ekki vera hissa á að verða beðinn um eina.

### Viðvörun um beinar pacman/yay-uppfærslur

Ef þú þekkir Arch nú þegar gætir þú freistast til að keyra bara `pacman -Syu` eða `yay -Syu` sjálfur, en ef þú gerir það munt þú missa af skyndimyndinni, flutningunum og stillingaruppfærslunum sem Omarchy keyrir ásamt nýjum pökkum. Þess vegna mun Omarchy í raun stöðva beina kerfisuppfærslu og benda þér á `omarchy update` í staðinn. (Ef þú veist virkilega hvað þú ert að gera mun vörðurinn segja þér hvernig á að fara framhjá honum fyrir eina færslu.)

### Að bakka með slæmar uppfærslur

Ef þú lentir einhvern tímann í vandræðum eftir uppfærslu geturðu bakkað kerfið þitt í skyndimyndina sem tekin var fyrir uppfærsluna. Endurræstu bara og veldu skyndimyndina í ræsivalmyndinni frá því áður en þú byrjaðir uppfærsluna.

![bootloader](images/bootloader.webp)

Ef stillingarskrárnar þínar hafa á einhvern hátt skemmst geturðu líka framkvæmt Omarchy-enduruppsetningu með `omarchy reinstall` í terminalinu. Þetta mun enduruppsetja alla sjálfgefnu Omarchy-pakkana, setja þig á stable og lækka alla pakka sem eru of nýir, og endurstilla allar stillingarskrárnar. Athugaðu að allar breytingar þínar sem notandi á sjálfgildum Omarchy verða yfirskrifaðar við þetta!
