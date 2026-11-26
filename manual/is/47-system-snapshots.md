# Kerfisskyndimyndir

Við búum til skyndimyndir sjálfkrafa við hverja Omarchy-uppfærslu, en ef þú vilt búa til þína eigin geturðu notað `omarchy-snapshot create`.

Hvernig þú ræsir og endurheimtir skyndimynd fer eftir því hvaða ræsiforrit vélin þín byrjar með. Nýjar UEFI-uppsetningar nota systemd-boot; eldri uppsetningar og BIOS-vélar nota Limine. `omarchy-boot-backend` segir þér hvort þeirra þú ert með.

## Með systemd-boot

Veldu _Kerfi > Skyndimyndir_ í Omarchy-valmyndinni og veldu skyndimyndina sem þú vilt ræsa í. Vélin endurræsir sig í hana einu sinni. Eða haltu Space inni á meðan vélin ræsir sig til að sjá ræsivalmyndina, þar sem hver skyndimynd er skráð með þeirri nýjustu fyrst ásamt Omarchy-útgáfu hennar og dagsetningu.

Skyndimynd ræsir með tímabundnu lagi ofan á, svo þú getur notað hana eins og venjulega, en allt sem þú breytir er horfið við næstu endurræsingu. Til að halda henni skaltu gera hana að kerfinu þínu: smelltu á tilkynninguna sem birtist þegar þú skráir þig inn, veldu _Kerfi > Skyndimyndir > Endurheimta þessa skyndimynd_, eða keyrðu `omarchy-snapshot restore`. Endurheimtin á sér stað á meðan vélin endurræsir sig. Kerfið eins og það var áður verður áfram í ræsivalmyndinni sem _Fyrir endurheimt_, og `omarchy-snapshot restore backup` setur það aftur til baka.

Frá skipanalínunni:

- `omarchy-snapshot list` listar skyndimyndirnar sem þú getur ræst;
- `omarchy-snapshot boot 12` endurræsir í skyndimynd 12 einu sinni;
- `omarchy-snapshot restore 12` gerir skyndimynd 12 að kerfinu við næstu endurræsingu, og `omarchy-snapshot restore --cancel` lætur þig skipta um skoðun fyrir þá endurræsingu.

## Með Limine

Til að ræsa og endurheimta skyndimynd velur þú hana úr Limine-ræsiforritinu. Ræsivalmyndin helst falin sjálfgefið, svo ýttu á hvaða takka sem er um leið og Limine ræsir til að kalla hana fram.

Á þeim skjá skaltu velja skyndimyndina sem þú vilt ræsa í út frá dagsetningu og útgáfu. Útgáfu Omarchy á þeim tíma sem skyndimyndin var tekin má sjá í vinstra horni að neðan.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Þegar þú ert kominn inn mun tilkynning birtast sem lætur þig vita að þú sért í ræsanlegri skyndimynd og ef þú smellir á hana hefst endurheimtarferlið. Að öðrum kosti geturðu notað `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Hvað endurheimt nær yfir

Endurheimt færir rótarskráarkerfið þitt til baka, en ekki `/home` þitt. Svo hún virkar til að afturkalla bilaða kerfisuppfærslu, en ekki til að endurheimta glataðar persónulegar skrár.

Þetta þýðir líka að `~/.config` mappan þín helst óbreytt. Svo ef þú ert að færa þig til baka í eldri útgáfu af safni eða forriti sem geymir stillingarskrár á nýju sniði þarftu að laga það handvirkt.

Sama gildir um eigin skrá Omarchy yfir hvaða tilfærslur hafa þegar verið keyrðar: hún býr í heimasvæðinu þínu, svo hún lifir endurheimtina af. Tilfærslur sem voru keyrðar eftir að skyndimyndin var tekin haldast merktar sem loknar, jafnvel þótt breytingarnar sem þær gerðu á rótarskráarkerfinu hafi verið afturkallaðar, og næsta `omarchy update` mun ekki keyra þær aftur. Svo ef þú uppfærir aftur eftir endurheimt og eitthvað sem fyrri uppfærsla hafði sett upp vantar enn, þá er það líklega ástæðan.
