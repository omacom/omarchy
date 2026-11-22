# Að byrja

Omarchy er sett upp með ISO-skrá. Þú getur valið á milli uppsetningar á öllum diskinum, sem tekur yfir allt drifið, eða uppsetningar í lausu plássi, sem setur Omarchy í óúthlutað pláss á drifi — þannig ræsir þú tvöfalt við hlið Windows eða annars stýrikerfis (sjá [uppsetning með tvöfaldri ræsingu](50-dual-boot-install.md) — athugaðu að þú þarft fyrst að slökkva á BitLocker í Windows). Hvorn veginn sem þú velur er full dulritun sjálfgefin við uppsetningu og uppsetning á öllum diskinum mun þurrka út valda drifið, svo vertu viss um að taka afrit áður en þú notar drif sem þegar er í notkun!

[Sæktu Omarchy ISO-skrána](https://omarchy.org/) fyrst, settu hana á USB-lykil (notaðu [Rufus](https://rufus.ie/) á Windows, [balenaEtcher](https://etcher.balena.io/) á Mac eða [caligula](https://github.com/ifd3f/caligula) á Linux) og ræstu af lyklinum.

_Þú verður að slökkva á Secure Boot og/eða TPM í BIOS. Þú verður að slökkva á þessu til að geta sett upp Omarchy. Þetta eru öryggiskerfi frá Microsoft ætluð fyrir Windows og Linux-dreifingar í samstarfi við Microsoft._

Svaraðu síðan stillingaspurningunum og staðfestu þær svona:

 ![install-config](images/install-config.webp)

Veldu síðan drif fyrir uppsetninguna þína, og sestu til baka og horfðu á uppsetningarsýninguna rúlla. Þetta getur tekið innan við mínútu á hröðustu nútímavélum, en ætti ekki að taka meira en 5 mínútur, jafnvel á eldri tölvu.

 ![install-done](images/install-done.webp)

Nú ertu tilbúinn að nota Omarchy!

### Notaðu lyklaborð með snúru eða 2.4ghz!

Full dulritun disksins leyfir þér ekki að slá inn lykilorðið af Bluetooth-lyklaborði við ræsingu. Rétt eins og þú getur ekki notað Bluetooth-lyklaborð til að fara í BIOS á PC-tölvu. Þú þarft lyklaborð sem notar annaðhvort 2.4ghz-dongle eða snúru (sem er hvort sem er mun betra fyrir töf!). Ég persónulega elska [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Uppsetning fyrir annan eiganda

Ef þú ert að setja upp vél fyrir einhvern annan — fjölskyldumeðlim, nýjan starfsmann, kaupanda — ættir þú ekki að svara persónulegu spurningunum fyrir þeirra hönd. Íttu á `Ctrl + C` á allra fyrsta skjá uppsetningarforritsins (val á lyklaborði), og Omarchy mun bjóða upp á að undirbúa vélina fyrir annan eiganda í staðinn. Kerfið setur sig upp strax, en allri persónulegri uppsetningu — uppröðun lyklaborðs, notendanafni, lykilorði — er frestað þar til vélin ræsir í fyrsta skipti. Drifið er samt dulritað sjálfgefið, og lykilorðið sem nýi eigandinn velur við þá fyrstu ræsingu verður líka dulritunarlykilorðið. (Vél sem þú hefur þegar verið að nota er líka hægt að afhenda án enduruppsetningar — sjá [að endurstilla tölvuna](48-security.md).)

### Uppsetningar án viðveru

ISO-skráin getur líka sett upp alveg sjálf — ekkert lyklaborð, enginn leiðarvísir — þegar henni er afhent stillingin á öðru drifi. Þannig á að meðhöndla Omarchy sem grunnmynd fyrir VMs og vélaflota. Sjá [uppsetningar án viðveru](51-unattended-installs.md).

### Uppsetningar án dulritunar

Omarchy er sett upp með dulritun sjálfgefið. Það er örugga, ábyrga valið fyrir hverja tölvu sem getur hugsanlega týnst eða verið stolið. Þú vilt ekki að neinn sem hefur aðgang að vélbúnaðinum þínum geti komist yfir gögnin þín!

En við sérstakar aðstæður, eins og fjaruppsetningar Omarchy á vernduðum tölvum eða uppsetningar til að fleygja á eftir án viðkvæmra gagna, gætirðu viljað setja upp án dulritunar. Þú getur ítt á `Ctrl + C` við staðfestingu á formattingu disksins til að skipta yfir í uppsetningu án dulritunar.

### Tungumál

Omarchy talar 50 tungumál — sama safn og omarchy.org — og enska er sjálfgefin. Til að skipta skaltu opna Omarchy-valmyndina og fara í _Uppsetning > Svæði > Tungumál_, eða keyra `omarchy language <code>` í skel (`omarchy language list` sýnir kóðana). Valmyndin, skjáborðið og eigin tilkynningar Omarchy skipta um tungumál strax, og hvert forrit sem þú opnar á eftir fylgir líka með. Forrit sem þegar voru opin skipta þegar þú endurræsir þau.

Til að halda tungumálinu en skrifa dagsetningar, tíma, tölur, peninga, einingar og pappírsstærðir eins og gert er á öðru svæði (enska með evrópskum dagsetningum og 24 stunda klukku, til dæmis), veldu svæði undir _Uppsetning > Svæði > Snið_, þar sem hvert val sýnir sýnishorn, eða keyrðu `omarchy region formats <code>` (`omarchy region formats list` sýnir kóðana). _Sama og tungumál_ fer aftur í snið tungumálsins sjálfs. Eins og tungumálaskipti nær þetta til forritanna sem þú opnar á eftir.

### Hjálp ef þú festist

Ef þú festist geturðu yfirleitt fundið einhvern sem er tilbúinn að hjálpa á _#omarchy-help_-rásinni á [Discord-samfélaginu](https://omarchy.org/discord).
