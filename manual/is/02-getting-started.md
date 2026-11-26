# Að byrja

Omarchy er sett upp með ISO. Þú getur valið á milli uppsetningar á öllum diskinum, sem tekur yfir allan diskinn, eða uppsetningar í laust pláss, sem setur Omarchy í óúthlutaða plássið á diski — þannig tvíræsir þú við hlið Windows eða annars stýrikerfis (sjá [uppsetningu fyrir tvíræsingu](50-dual-boot-install.md) — athugaðu að þú þarft fyrst að slökkva á BitLocker í Windows). Í báðum tilvikum er sjálfgefið að nota fulla dulkóðun og valkosturinn fyrir allan diskinn mun þurrka út valda diskinn, svo vertu viss um að taka öryggisafrit áður en þú notar disk sem þegar er í notkun!

Á Apple Silicon Mac setur þú upp úr macOS í staðinn, án ISO eða USB-lykils. Sjá [Omarchy fyrir Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Sæktu Omarchy ISO](https://omarchy.org/) fyrst, settu það á USB-lykil (notaðu [Rufus](https://rufus.ie/) á Windows, [balenaEtcher](https://etcher.balena.io/) á Mac eða [caligula](https://github.com/ifd3f/caligula) á Linux) og ræstu af lyklinum.

_Þú verður að slökkva á Secure Boot og/eða TPM í BIOS. Þú verður að slökkva á þessu til að geta sett upp Omarchy. Þetta eru öryggiskerfi frá Microsoft ætluð fyrir Windows og Linux-dreifingar tengdar Microsoft._

Svaraðu síðan stillingaspurningunum og staðfestu þær svona:

 ![install-config](images/install-config.webp)

Veldu síðan disk fyrir uppsetninguna þína, hallaðu þér aftur og horfðu á uppsetningarsýninguna. Það getur klárast á innan við mínútu á hraðvirkustu nútímavélunum, en ætti ekki að taka meira en 5 mínútur jafnvel á eldri tölvu.

 ![install-done](images/install-done.webp)

Nú ertu tilbúinn í Omarchy!

### Notaðu lyklaborð með snúru eða 2.4ghz!

Full dulkóðun disksins leyfir þér ekki að slá inn lykilorðið af Bluetooth-lyklaborði við ræsingu. Rétt eins og þú getur ekki notað Bluetooth-lyklaborð til að fara inn í BIOS á PC-tölvu. Þú þarft lyklaborð sem notar annaðhvort 2.4ghz-dongle eða snúru (sem er hvort sem er miklu betra hvað varðar töf!). Ég persónulega elska [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Að setja upp fyrir annan eiganda

Ef þú ert að setja upp vél fyrir einhvern annan — fjölskyldumeðlim, nýjan starfsmann, kaupanda — ættirðu ekki að svara persónulegu spurningunum fyrir þeirra hönd. Ýttu á `Ctrl + C` á allra fyrsta skjá uppsetningarforritsins (valinu á lyklaborði) og Omarchy mun bjóða upp á að undirbúa vélina fyrir annan eiganda í staðinn. Kerfið setur upp strax, en allri persónulegri uppsetningu — uppsetningu lyklaborðs, notandanafni, lykilorði — er frestað þar til vélin ræsir í fyrsta sinn. Diskurinn er samt dulkóðaður sjálfgefið og lykilorðið sem nýi eigandinn velur við þá fyrstu ræsingu verður dulkóðunarlykilorðið líka. (Vél sem þú hefur þegar verið að nota er líka hægt að afhenda án enduruppsetningar — sjá [að endurstilla tölvuna](48-security.md).)

### Uppsetningar án eftirlits

ISO-ið getur líka sett upp alveg sjálft — ekkert lyklaborð, enginn leiðarvísir — þegar því er afhent stillingin á öðrum diski. Þannig á að meðhöndla Omarchy sem grunnmynd fyrir VMs og vélaflota. Sjá [uppsetningar án eftirlits](51-unattended-installs.md).

### Uppsetningar án dulkóðunar

Omarchy er sett upp með dulkóðun sjálfgefið. Það er örugga, ábyrga valið fyrir hverja tölvu sem getur hugsanlega týnst eða verið stolið. Þú vilt ekki að neinn sem hefur aðgang að vélbúnaðinum þínum geti komist yfir gögnin þín!

En við sérstakar aðstæður, eins og við fjaruppsetningar Omarchy á vernduðum tölvum eða fyrir uppsetningar sem er hent án viðkvæmra gagna, gætirðu viljað setja upp án dulkóðunar. Þú getur ýtt á `Ctrl + C` við staðfestinguna á formattingu disksins til að skipta yfir í uppsetningu án dulkóðunar.

### Tungumál

Omarchy talar 50 tungumál — sama safn og omarchy.org — og enska er sjálfgefin. Til að skipta skaltu opna Omarchy-valmyndina og fara í _Uppsetning > Svæði > Tungumál_, eða keyra `omarchy language <code>` í skel (`omarchy language list` sýnir kóðana). Valmyndin, skjáborðið og tilkynningar Omarchy sjálfs skipta strax um tungumál og hvert forrit sem þú opnar á eftir fylgir með. Forrit sem þegar voru opin skipta þegar þú endurræsir þau.

Til að halda tungumálinu en skrifa dagsetningar, tíma, tölur, peninga, einingar og pappírsstærðir eins og gert er á öðru svæði (enska með evrópskum dagsetningum og 24 stunda klukku, til dæmis), veldu svæði undir _Uppsetning > Svæði > Snið_, þar sem hvert val sýnir dæmi, eða keyrðu `omarchy region formats <code>` (`omarchy region formats list` sýnir kóðana). _Sama og tungumál_ fer aftur í snið tungumálsins sjálfs. Eins og tungumálaskipti nær það til forritanna sem þú opnar á eftir.

### Hjálp ef þú festist

Ef þú festist geturðu yfirleitt fundið einhvern sem er tilbúinn að hjálpa á _#omarchy-help_ rásinni á [Discord samfélagsins](https://omarchy.org/discord).
