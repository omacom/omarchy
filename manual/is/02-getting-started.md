# Að byrja

Omarchy er sett upp með ISO. Þú getur valið á milli uppsetningar á öllum diskinum, sem tekur yfir allt drifið, eða uppsetningar í laust pláss, sem setur Omarchy í óúthlutað pláss á drifi — þannig ræsir þú í tvöfaldri ræsingu við hlið Windows eða annars OS (sjá [uppsetning með tvöfaldri ræsingu](50-dual-boot-install.md) — athugaðu að þú þarft að slökkva á BitLocker í Windows fyrst). Hvort sem er er sjálfgefið að uppsetningin noti fulla dulkóðun, og valkosturinn fyrir allan diskinn mun þurrka út valda drifið, svo vertu viss um að taka öryggisafrit áður en þú notar drif sem þegar er í notkun!

[Sæktu Omarchy ISO-ið](https://omarchy.org/) fyrst, settu það á USB-lykil (notaðu [balenaEtcher](https://etcher.balena.io/) á Mac/Windows eða [caligula](https://github.com/ifd3f/caligula) á Linux) og ræstu af lyklinum.

_Þú verður að slökkva á Secure Boot og/eða TPM í BIOS. Þú verður að slökkva á þessu til að geta sett upp Omarchy. Þetta eru öryggiskerfi frá Microsoft sem eru ætluð fyrir Windows og Linux-dreifingar sem eru tengdar Microsoft._

Svaraðu síðan stillingarspurningunum og staðfestu þær svona:

 ![install-config](images/install-config.webp)

Veldu síðan drif fyrir uppsetninguna þína, lentu þér aftur og horfðu á uppsetningarsýninguna rúlla. Það getur klárast á innan við mínútu á hraðvirkustu nútímavélum, en ætti ekki að taka meira en 5 mínútur jafnvel á eldri tölvu.

 ![install-done](images/install-done.webp)

Nú ertu tilbúinn að Omarchy-a!

### Notaðu lyklaborð með snúru eða 2.4ghz!

Dulkóðunin á öllum diskinum leyfir þér ekki að slá inn lykilorðið af Bluetooth-lyklaborði við ræsingu. Alveg eins og þú getur ekki notað Bluetooth-lyklaborð til að komast í BIOS á PC. Þú þarft lyklaborð sem notar annaðhvort 2.4ghz-dongle eða snúru (sem er hvort sem er miklu betra fyrir seinkun!). Mér finnst [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) persónulega frábært!

### Uppsetning fyrir annan eiganda

Ef þú ert að setja upp vél fyrir einhvern annan — fjölskyldumeðlim, nýjan starfsmann, kaupanda — átt þú ekki að svara persónulegu spurningunum fyrir þeirra hönd. Ýttu á `Ctrl + C` á allra fyrsta skjá uppsetningarforritsins (lyklaborðsvalinu), og Omarchy býðst til að undirbúa vélina fyrir annan eiganda í staðinn. Kerfið setur sig upp samstundis, en allri persónulegu uppsetningunni — lyklaborðsuppsetningu, notendanafni, lykilorði — er frestað þar til vélin ræsir í fyrsta skipti. Drifið er áfram dulkóðað sjálfgefið, og lykilorðið sem nýi eigandinn velur við þessa fyrstu ræsingu verður dulkóðunarlykilorðið líka. (Vél sem þú hefur þegar verið að nota er líka hægt að afhenda án enduruppsetningar — sjá [að endurstilla tölvuna](48-security.md).)

### Uppsetningar án aðstoðar

ISO-ið getur líka sett sig upp alveg sjálft — ekkert lyklaborð, enginn leiðarvísir — þegar því eru afhentar stillingarnar á öðru drifi. Þannig á að meðhöndla Omarchy sem grunnmynd fyrir VMs og vélaflota. Sjá [uppsetningar án aðstoðar](51-unattended-installs.md).

### Uppsetningar án dulkóðunar

Omarchy er sett upp með dulkóðun sjálfgefið. Það er öruggi, ábyrgi kosturinn fyrir hverja þá tölvu sem getur mögulega týnst eða verið stolið. Þú vilt ekki að neinn sem kemst yfir vélbúnaðinn þinn geti náð í gögnin þín!

En við sérstakar aðstæður, eins og við fjaruppsetningar á Omarchy á vernduðum tölvum eða fyrir einnota uppsetningar án viðkvæmra gagna, gætir þú viljað setja upp án dulkóðunar. Þú getur ýtt á `Ctrl + C` við staðfestinguna á formattingu disksins til að skipta yfir í uppsetningu án dulkóðunar.

### Tungumál

Omarchy talar 50 tungumál — sama safn og omarchy.org — og enska er sjálfgefna tungumálið. Til að skipta skaltu opna Omarchy-valmyndina og fara í _Setup > Language_, eða keyra `omarchy language <code>` í terminal (`omarchy language list` sýnir kóðana). Valmyndin, skjáborðið og tilkynningar frá Omarchy sjálfu skipta um tungumál strax, og sérhvert forrit sem þú opnar eftir það fylgir á eftir líka. Forrit sem voru þegar opin skipta þegar þú endurræsir þau.

### Hjálp ef þú festist

Ef þú festist finnurðu yfirleitt einhvern sem er til í að hjálpa í _#omarchy-help_ rásinni á [Discord samfélagsins](https://omarchy.org/discord).
