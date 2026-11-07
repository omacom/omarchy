# Að byrja

Omarchy er sett upp með ISO-skrá. Þú getur valið á milli uppsetningar á öllum diskinum, sem tekur yfir allan diskinn, eða uppsetningar í lausu plássi, sem setur Omarchy í óúthlutaða plássið á diski — þannig geturðu ræst tvöfalt samhliða Windows eða öðru stýrikerfi (sjá [uppsetning fyrir tvöfalda ræsingu](50-dual-boot-install.md) — athugaðu að þú þarft fyrst að slökkva á BitLocker í Windows). Í báðum tilvikum er sjálfgefið að nota fulla dulritun og valkosturinn fyrir allan diskinn mun þurrka út valda diskinn, svo vertu viss um að taka öryggisafrit áður en þú notar disk sem þegar er í notkun!

[Sæktu Omarchy ISO-skrána](https://omarchy.org/) fyrst, settu hana á USB-lykil (notaðu [Rufus](https://rufus.ie/) á Windows, [balenaEtcher](https://etcher.balena.io/) á Mac, eða [caligula](https://github.com/ifd3f/caligula) á Linux), og ræstu af lyklinum.

_Þú verður að slökkva á Secure Boot og/eða TPM í BIOS. Þú verður að slökkva á þessu til að geta sett upp Omarchy. Þetta eru öryggiskerfi frá Microsoft sem eru ætluð fyrir Windows og Linux-dreifingar sem tengjast Microsoft._

Því næst svararðu stillingarspurningunum og staðfestir þær svona:

 ![install-config](images/install-config.webp)

Veldu síðan disk fyrir uppsetninguna þína, og slakaðu á og fylgstu með uppsetningunni rúlla. Það getur tekið innan við mínútu á hraðvirkustu nútímavélum, en ætti ekki að taka meira en 5 mínútur, jafnvel á eldri tölvu.

 ![install-done](images/install-done.webp)

Nú ertu tilbúinn í Omarchy!

### Notaðu lyklaborð með snúru eða 2.4ghz lyklaborð!

Með fullri dulritun disksins geturðu ekki slegið inn lykilorðið af Bluetooth-lyklaborði við ræsingu. Rétt eins og þú getur ekki notað Bluetooth-lyklaborð til að opna BIOS á PC-tölvu. Þú þarft lyklaborð sem notar annaðhvort 2.4ghz móttakara eða snúru (sem er hvort eð er mun betra hvað varðar töf!). Ég er persónulega hrifinn af [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Uppsetning fyrir annan eiganda

Ef þú ert að setja upp vél fyrir einhvern annan — fjölskyldumeðlim, nýjan starfsmann, kaupanda — ættirðu ekki að svara persónulegu spurningunum fyrir þeirra hönd. Ýttu á `Ctrl + C` á allra fyrsta skjá uppsetningarforritsins (val á lyklaborði) og Omarchy mun bjóðast til að undirbúa vélina fyrir annan eiganda í staðinn. Kerfið setur sig upp strax, en öll persónuleg uppsetning — lyklaborðsútlit, notandanafn, lykilorð — bíður þar til vélin er ræst í fyrsta skipti. Diskurinn er áfram dulritaður sjálfgefið og lykilorðið sem nýi eigandinn velur við fyrstu ræsingu verður einnig dulritunarlykilorðið. (Vél sem þú hefur þegar verið að nota er líka hægt að afhenda án þess að setja upp aftur — sjá [að endurstilla tölvuna](48-security.md).)

### Uppsetningar án eftirlits

ISO-skráin getur líka sett upp alveg sjálf — ekkert lyklaborð, enginn leiðarvísir — þegar stillingarnar eru afhentar henni á öðrum diski. Þannig á að meðhöndla Omarchy sem grunnmynd fyrir VM-vélar og vélaflota. Sjá [uppsetningar án eftirlits](51-unattended-installs.md).

### Uppsetningar án dulritunar

Omarchy er sett upp með dulritun sjálfgefið. Það er öruggi og ábyrgi kosturinn fyrir allar tölvur sem geta hugsanlega týnst eða verið stolið. Þú vilt ekki að neinn sem hefur aðgang að vélbúnaðinum þínum geti komist yfir gögnin þín!

En við sérstakar aðstæður, eins og við fjaruppsetningar á Omarchy á vernduðum tölvum eða fyrir einnota uppsetningar án viðkvæmra gagna, gætirðu viljað setja upp án dulritunar. Þú getur ýtt á `Ctrl + C` við staðfestingu á forsníðingu disksins til að skipta yfir í uppsetningu án dulritunar.

### Tungumál

Omarchy talar 50 tungumál — sama safn og omarchy.org — og enska er sjálfgefin. Til að skipta skaltu opna Omarchy-valmyndina og fara í _Uppsetning > Tungumál_, eða keyra `omarchy language <code>` í skipanalínu (`omarchy language list` sýnir kóðana). Valmyndin, skjáborðið og tilkynningar frá Omarchy sjálfu skipta strax um tungumál og öll forrit sem þú opnar eftir það fylgja með. Forrit sem voru þegar opin skipta þegar þú endurræsir þau.

### Hjálp ef þú festist

Ef þú festist geturðu yfirleitt fundið einhvern sem er tilbúinn að hjálpa á _#omarchy-help_ rásinni á [Discord samfélagsins](https://omarchy.org/discord).
