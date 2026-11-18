# Uppfærslur

Omarchy og pökkunum þínum er haldið uppfærðum í gegnum _Uppfæra > Omarchy_ í Omarchy-valmyndinni (`Super + Space`).

Omarchy sjálft er sett upp sem venjulegir pacman-pakkar frá [Omarchy-pakkageymslunni](https://github.com/omacom-io/omarchy-pkgs), svo uppfærsla setur upp [nýjustu Omarchy-útgáfuna](https://github.com/omacom/omarchy/releases), keyrir allar flutningsaðgerðir sem bíða til að samstilla kerfið þitt við það nýjasta og uppfærir alla kerfispakka frá [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) og [AUR](https://aur.archlinux.org/) (ef þú hefur sett upp einhverja AUR-pakka).

Þegar nýjar útgáfur koma út birtist hringörvatákn hægra megin við klukkuna þína. Smelltu á það og uppfærsluferlið hefst.

![update-available](images/update-available.webp)

### Fjórar rásir

Omarchy er uppfært eftir fjórum rásum: stable, RC, edge og dev. Nýjar uppsetningar byrja á stable-rásinni, sem fylgir [opinberu útgáfunum](https://github.com/omacom/omarchy/releases/), sem og [stöðuga Omarchy Arch-speglinum](https://github.com/omacom-io/omarchy-mirror) sem er einum mánuði á eftir því nýjasta, svo við getum gripið alla nýja ósamhæfni sem krefst stillingabreytinga áður en hún veldur fólki vandræðum.

En ef þú vilt hjálpa til við að koma auga á þessi hugsanlegu vandamál geturðu keyrt á edge-rásinni. Þá fylgja Omarchy-pakkarnir þínir nýjustu þróunarsmíðunum og þú getur uppfært í nýjustu Arch-pakkana um leið og þeir verða tiltækir. Þú ættir aðeins að gera þetta ef þú hefur reynslu af Linux og veist hvernig á að bjarga kerfi sem lendir í vandræðum.

Fyrir hverja nýja stórútgáfu gerum við lokaprófanir á RC-rásinni. Ef þú hefur áhuga á að hjálpa til við lokafráganginn skaltu koma og hanga með okkur í #omarchy-release-candidates á Discord.

Að lokum er það dev-rásin, sem tengir Omarchy beint við git-úttekt á frumkóðanum í `~/omarchy`, ásamt edge-pökkunum. Þú ættir aðeins að nota þessa rás ef þú ert reyndur Linux-notandi, vinnur beint að Omarchy og þolir að hlutir brotni.

Þú getur skipt á milli rása með _Uppfæra > Rás_ í Omarchy-valmyndinni (eða `omarchy-channel-set` í útstöðinni).

### Að skipta um kjarna

Omarchy ræsir sinn eigin `linux-omarchy`-kjarna, en þú getur haft aðra uppsetta við hliðina á honum, eins og venjulega Arch-`linux`-kjarnann eða tilraunasmíð sem þú ert að prófa. Þegar þeir eru fleiri en einn birtir _Uppfæra > Kjarni_ í Omarchy-valmyndinni þá með hak við þann sem ræsist sjálfgefið. Veldu annan, sláðu inn lykilorðið þitt einu sinni, og hann ræsist eftir næstu endurræsingu. Hinir kjarnarnir verða áfram í ræsivalmyndinni, svo þú getur samt valið einn handvirkt ef nýja sjálfgefna valið veldur þér vandræðum. Í útstöðinni er það `omarchy-kernel` til að sjá núverandi sjálfgefna kjarnann, `omarchy-kernel list` fyrir það sem er uppsett og `omarchy-kernel set <kernel>` til að skipta.

### Uppfærslur á fastbúnaði

Pakkar þínir eru ekki það eina sem úreldist. Margar fartölvur og jaðartæki senda BIOS-, SSD- og tengikvíarfastbúnað í gegnum Linux Vendor Firmware Service, og _Uppfæra > Fastbúnaður_ í Omarchy-valmyndinni sækir og setur upp það sem vélbúnaðurinn þinn á í bið. Það setur upp `fwupd` í fyrsta skipti sem þú keyrir það. Mikið af fastbúnaði er aðeins hægt að skrifa við endurræsingu, svo ekki verða hissa ef þú verður beðinn um eina.

Þegar þú þarft að breyta stillingu í BIOS-inum sjálfum skaltu halda `Alt` inni í kerfisvalmyndinni (`Super + Escape`) og þá breytist _Endurræsa_ í _Endurræsa í BIOS_, sem endurræsir beint inn í uppsetningu fastbúnaðarins án þess að þú þurfir að ná rétta lyklinum við ræsingu. Í útstöðinni er það `omarchy system firmware`.

### Viðvörun um beinar pacman/yay-uppfærslur

Ef þú þekkir Arch nú þegar gætirðu freistast til að keyra bara `pacman -Syu` eða `yay -Syu` sjálfur, en ef þú gerir það missirðu af skyndimyndinni, flutningsaðgerðunum og stillingauppfærslunum sem Omarchy keyrir ásamt nýjum pökkum. Þess vegna stöðvar Omarchy beina kerfisuppfærslu og beinir þér í staðinn á `omarchy update`. (Ef þú veist virkilega hvað þú ert að gera segir vörðurinn þér hvernig á að komast hjá honum fyrir eina færslu.)

### Að afturkalla slæmar uppfærslur

Ef þú lendir einhvern tíma í vandræðum eftir uppfærslu geturðu fært kerfið þitt aftur á skyndimyndina sem tekin var fyrir uppfærsluna. Endurræstu bara og veldu skyndimyndina í ræsivalmyndinni frá því áður en þú hófst uppfærsluna.

![bootloader](images/bootloader.webp)

Ef stillingarskrárnar þínar hafa einhvern veginn skemmst geturðu líka endursett Omarchy upp með `omarchy reinstall` í útstöðinni. Það setur alla sjálfgefna Omarchy-pakkana upp aftur, setur þig á stable, lækkar alla pakka sem eru of nýir og endurstillir allar stillingarskrár. Athugaðu að öllum breytingum þínum á sjálfgefnum stillingum Omarchy verður skrifað yfir við þetta!
