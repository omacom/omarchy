# Augnabliksmyndir af kerfinu

Við búum til augnabliksmyndir sjálfkrafa við hverja Omarchy uppfærslu, en ef þú vilt búa til þína eigin geturðu notað `omarchy-snapshot create`.

Til að ræsa og endurheimta augnabliksmynd velurðu hana úr Limine boot loader. Ræsivalmyndin er sjálfgefið falin, svo ýttu á hvaða takka sem er um leið og Limine ræsist til að kalla hana fram.

Á þeim skjá velurðu augnabliksmyndina sem þú vilt ræsa í, eftir dagsetningu og útgáfu. Útgáfu Omarchy á þeim tíma sem augnabliksmyndin var tekin má sjá í neðra vinstra horninu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Þegar þú ert kominn inn birtist tilkynning sem lætur þig vita að þú sért í ræsanlegri augnabliksmynd og ef þú smellir á hana hefst endurheimtarferlið. Að öðrum kosti geturðu notað `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Þetta endurheimtir rótarskráarkerfið þitt, en ekki `/home`. Það virkar því til að afturkalla bilaða kerfisuppfærslu, en ekki til að endurheimta týnd persónuleg skjöl.

Þetta þýðir líka að `~/.config` mappan þín helst óbreytt. Ef þú ert því að fara aftur í eldri útgáfu af safni eða forriti sem geymir stillingarskrár á nýju sniði þarftu að leysa úr því handvirkt.

Sama gildir um eigin skrá Omarchy yfir hvaða flutningar hafa þegar keyrt: hún býr í heimamöppunni þinni, svo hún lifir endurheimtina af. Flutningar sem keyrðu eftir að augnabliksmyndin var tekin haldast merktir sem kláraðir, jafnvel þótt breytingarnar sem þeir gerðu á rótarskráarkerfinu hafi verið afturkallaðar, og næsta `omarchy update` keyrir þá ekki aftur. Ef þú uppfærir því aftur eftir endurheimt og eitthvað sem fyrri uppfærsla hafði sett upp vantar enn, þá er það sennileg ástæða.

_Athugið: Þessi eiginleiki er aðeins í boði á uppsetningum sem nota Limine boot loader, sem hefur verið sjálfgefinn síðan Omarchy 2.0. Hann er ekki í boði ef þú ert á GRUB eða systemd-boot._
