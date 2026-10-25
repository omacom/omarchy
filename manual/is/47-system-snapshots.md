# Kerfisaugnablik

Við búum til augnablik sjálfkrafa við hverja Omarchy-uppfærslu, en ef þú vilt búa til þín eigin geturðu notað `omarchy-snapshot create`.

Til að ræsa og endurheimta augnablik velurðu það í Limine ræsiforritinu. (Ef þú ert núna að ræsa beint inn á Omarchy afkóðunarskjáinn þarftu fyrst að velja Limine sem ræsivalkost í BIOS).

Á þeim skjá skaltu velja augnablikið sem þú vilt ræsa í, byggt á dagsetningu og útgáfu. Útgáfu Omarchy á tíma augnabliksins má sjá neðst í vinstra horni.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Þegar þú kemur inn mun tilkynning birtast sem lætur þig vita að þú sért í ræsanlegu augnabliki og ef þú smellir á hana mun hún byrja endurheimtarferlið. Að öðrum kosti geturðu notað `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Þetta mun endurheimta rótaskráarkerfið þitt, en ekki `/home` þitt. Svo það virkar til að snúa við bilaðri kerfisuppfærslu, en ekki til að endurheimta tapaðar persónulegar skrár.

Þetta þýðir líka að `~/.config` möppan þín helst óbreytt. Svo ef þú ert að snúa aftur í eldri útgáfu af bókasafni eða forriti sem geymir stillingarskrár á nýju sniði þarftu að leysa það handvirkt.

_Athugaðu: Þessi eiginleiki er aðeins tiltækur á uppsetningum sem nota Limine ræsiforritið, sem hefur verið sjálfgildið frá Omarchy 2.0. Hann er ekki tiltækur ef þú ert á GRUB eða systemd-boot._

### Að sleppa ræsivalmyndinni

Ef þú snertir aldrei ræsivalmyndina og vilt bara að vélin fari beint á afkóðunarskjáinn skaltu keyra _Uppsetning > Bein ræsing_ í Omarchy-valmyndinni. Það bætir við EFI-færslu sem bendir beint á Omarchy, svo fastbúnaðurinn ræsir það án þess að stoppa við Limine.

Gagnkvæmnið er það sem nefnt er efst: með beina ræsingu á þýðir það að ná til augnabliks að velja Limine úr BIOS ræsivalmyndinni þinni fyrst. Keyrðu _Uppsetning > Bein ræsing_ aftur til að fjarlægja færsluna og fara aftur að ræsa gegnum Limine. Sumir fastbúnaðar taka ekki vel í sérsniðnar EFI-færslur, svo uppsetningin neitar að keyra á American Megatrends og Apple fastbúnaði.
