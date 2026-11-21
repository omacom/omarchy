# Að byrja

Omarchy er sett upp með ISO. Þú getur valið á milli uppsetningar á öllum diskinum, sem tekur yfir allan diskinn, eða uppsetningar í laust pláss, sem setur Omarchy í óúthlutað pláss á diski — þannig tvíræsir þú ásamt Windows eða öðru stýrikerfi (sjá [uppsetning fyrir tvíræsingu](50-dual-boot-install.md) — athugaðu að þú þarft fyrst að slökkva á BitLocker í Windows). Hvorn veginn sem er er full dulritun sjálfgefin í uppsetningunni, og valkosturinn fyrir allan diskinn mun þurrka út valda diskinn, svo vertu viss um að taka öryggisafrit áður en þú notar disk sem þegar er í notkun!

[Sæktu Omarchy ISO](https://omarchy.org/) fyrst, settu það á USB-lykil (notaðu [Rufus](https://rufus.ie/) í Windows, [balenaEtcher](https://etcher.balena.io/) á Mac, eða [caligula](https://github.com/ifd3f/caligula) í Linux), og ræstu af lyklinum.

_Þú verður að slökkva á Secure Boot og/eða TPM í BIOS. Þú verður að slökkva á þessu til að geta sett upp Omarchy. Þetta eru öryggiskerfi frá Microsoft sem ætluð eru fyrir Windows og Linux-dreifingar í samstarfi við Microsoft._

Svaraðu síðan stillingaspurningunum og staðfestu þær svona:

 ![install-config](images/install-config.webp)

Veldu síðan disk fyrir uppsetninguna þína, og leggstu til baka og fylgstu með uppsetningarsýningunni. Það getur tekið innan við mínútu á hröðustu nútímavélunum, en ætti ekki að taka meira en 5 mínútur jafnvel á eldri tölvu.

 ![install-done](images/install-done.webp)

Nú ertu tilbúinn fyrir Omarchy!

### Notaðu lyklaborð með snúru eða 2.4ghz!

Full dulritun disksins leyfir þér ekki að slá inn lykilorðið af Bluetooth-lyklaborði við ræsingu. Rétt eins og þú getur ekki notað Bluetooth-lyklaborð til að opna BIOS á PC-tölvu. Þú þarft lyklaborð sem annaðhvort notar 2.4ghz-móttakara eða snúru (sem er hvort eð er mun þægilegra vegna töfar!). Persónulega elska ég [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Uppsetning fyrir annan eiganda

Ef þú ert að setja upp vél fyrir einhvern annan — fjölskyldumeðlim, nýjan starfsmann, kaupanda — ættir þú ekki að svara persónulegu spurningunum fyrir þeirra hönd. Ýttu á `Ctrl + C` á allra fyrsta skjá uppsetningarforritsins (val á lyklaborði), og Omarchy mun bjóða upp á að undirbúa vélina fyrir annan eiganda í staðinn. Kerfið setur upp strax, en allri persónulegri uppsetningu — uppsetningu lyklaborðs, notendanafni, lykilorði — er frestað þar til vélin ræsir í fyrsta skipti. Diskurinn er áfram dulritaður sjálfgefið, og lykilorðið sem nýi eigandinn velur við þá fyrstu ræsingu verður líka dulritunarlykilorðið. (Vél sem þú hefur þegar verið að nota er líka hægt að afhenda án enduruppsetningar — sjá [að endurstilla tölvuna](48-security.md).)

### Uppsetningar án viðveru

ISO-ið getur líka sett upp alveg sjálft — ekkert lyklaborð, enginn leiðarvísir — þegar því er afhent stillingin á öðrum diski. Það er leiðin til að meðhöndla Omarchy sem grunnmynd fyrir VMs og vélaflota. Sjá [uppsetningar án viðveru](51-unattended-installs.md).

### Uppsetningar án dulritunar

Omarchy er sett upp með dulritun sjálfgefið. Það er öruggi, ábyrgi kosturinn fyrir hverja tölvu sem getur hugsanlega týnst eða verið stolið. Þú vilt ekki að neinn sem hefur aðgang að vélbúnaðinum þínum geti komist yfir gögnin þín!

En við sérstakar aðstæður, eins og fjaruppsetningar Omarchy á vernduðum tölvum eða fyrir uppsetningar til að henda eftir á án viðkvæmra gagna, gætir þú viljað setja upp án dulritunar. Þú getur ýtt á `Ctrl + C` við staðfestingu á sniði disks til að skipta yfir í uppsetningu án dulritunar.

### Tungumál

Omarchy talar 50 tungumál — sama safn og omarchy.org — og enska er sjálfgefin. Til að skipta skaltu opna Omarchy-valmyndina og fara í _Uppsetning > Svæði > Tungumál_, eða keyra `omarchy language <code>` í skel (`omarchy language list` sýnir kóðana). Valmyndin, skjáborðið og eigin tilkynningar Omarchy skipta um tungumál strax, og hvert forrit sem þú opnar á eftir fylgir líka. Forrit sem þegar voru opin skipta þegar þú endurræsir þau.

Til að halda tungumálinu en skrifa dagsetningar, tíma, tölur, peninga, einingar og pappírsstærðir eins og annað svæði gerir (enska með evrópskum dagsetningum og 24 stunda klukku, til dæmis), veldu svæði undir _Uppsetning > Svæði > Snið_, þar sem hver valkostur sýnir dæmi, eða keyrðu `omarchy region <code>` (`omarchy region list` sýnir kóðana). _Sama og tungumál_ fer aftur í snið tungumálsins sjálfs. Líkt og tungumálaskipti nær það til forritanna sem þú opnar á eftir.

### Hjálp ef þú festist

Ef þú festist geturðu venjulega fundið einhvern sem er tilbúinn að hjálpa á _#omarchy-help_ rásinni á [Discord samfélagsins](https://omarchy.org/discord).
