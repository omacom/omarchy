# Öryggi

Omarchy tekur öryggi af ákafri alvöru. Þetta á að vera stýrikerfi sem þú getur notað til að vinna _Alvöru Vinnu_ í _Alvöru Heiminum_. Þar sem að týna fartölvu getur ekki leitt til öryggisneyðar. Svo hér er það sem við gerum:

1. *Full disksdulritun er skylda*: Þetta er mikilvægasta skrefið til að tryggja líkamlega vernd gagna þinna. Ef tölvan þín týnist eða er stolið eru gögnin fulldulrituð með stöðluðu LUKS (Linux Unified Key Setup).
2. *Eldveggur er sjálfgefið virkur*: Öll umferð inn er lokuð sjálfgefið nema fyrir tengi 53317 fyrir [LocalSend](https://localsend.org/). Jafnvel ssh er slökkt þar til þú kveikir á því með _Uppsetning > Öryggi > SSHD_, sem opnar tengi 22 (með hraðatakmörkun gegn brute force) sem hluti af uppsetningunni. Við læsum jafnvel Docker-aðgangi með [ufw-docker](https://github.com/chaifeng/ufw-docker) uppsetningunni til að koma í veg fyrir að gámarnir þínir opnist óvart fyrir heiminum.
3. *Arch hefur alltaf nýjustu uppfærslurnar*: Arch, undirliggjandi dreifingin sem Omarchy er byggð á, er rúllandi dreifing. Það þýðir að sérhver öryggisveikleiki sem uppgötvast og er lagfærður í einhverjum pakka verður fljótt tiltækur til uppsetningar með `omarchy-update`. Þú keyrir alltaf nýjustu, öruggustu útgáfur af öllu á þann hátt.
4. *Omarchy viðheldur sínum eigin pökkum og spegli*: Omarchy treystir aðeins á pakka úr eigin core/extra/multilib geymslum Arch og eigin Omarchy pakkageymslu sjálfgefið. Þú getur sett upp hugbúnað beint úr AUR, en grunnuppsetningin gerir það ekki — aðeins nokkrar valkvæðar uppsetningar, eins og þriðja aðila vafrarnir, draga úr AUR.
5. *Cloudflare verndar okkur gegn DDoS*: Öll Omarchy dreifingarinnviður — ISO-in, Omarchy pakkarnir, Arch spegillinn — eru varin á bak við ægilegan DDoS skjöld Cloudflare og hýst á CDN þeirra. Þetta veitir frábæra tiltækileika.

## Að breyta lykilorðunum þínum

Þú hefur tvö lykilorð á dulritaðri uppsetningu: það sem opnar drifið við ræsingu og það sem þú skráir þig inn og notar `sudo` með. Uppsetningin gerir þau eins. Báðum má breyta undir _Uppfæra > Lykilorð_ í Omarchy-valmyndinni — _Drifdulkóðun_ fyrir það fyrra, _Notandi_ fyrir það síðara. Að breyta driflykilorðinu biður fyrst um núverandi, svo hafðu það við höndina. Ef breyting er trufluð skaltu keyra _Drifdulkóðun_ aftur: það biður um lykilorðið sem opnar drifið núna og klárar breytinguna.

## Að láta öðrum vél sem þú hefur þegar notað

Ef þú ert að afhenda vélina þína einhverjum öðrum þarftu ekki að setja hana upp aftur. Keyrðu _Uppsetning > Endurstilla tölvu_ í Omarchy-valmyndinni, sláðu inn `reset` til að staðfesta og endurræstu. Það þurrkar út sérhvern notandareikning og allt í `/home`, hendir öllum pökkunum og kerfisbreytingunum sem þú gerðir frá uppsetningu, og hreinsar auðkenni vélarinnar — nettengingar, hýsilýkla og allt. Það sem kemur til baka er uppsetningarhjálpin frá fyrstu ræsingu, tilbúin fyrir nýja eiganda sinn til að slá inn eigið nafn, lykilorð og dulritunarlykilorð.

Það virkar með því að endurheimta grunnaugnablikið sem uppsetningarforritið tekur, svo það er aðeins tiltækt á vélum uppsettum úr Omarchy ISO. Og á drifi án dulritunar er endurstilling eyðing frekar en örugg þurrkun, svo ef gögnin voru viðkvæm skaltu gera ferska uppsetningu í staðinn.

## Sudo án lykilorðs

Stundum viltu að `sudo` hætti að spyrja, oftast þegar gervigreindarfulltrúi er að vinna langa lotu af kerfisvinnu fyrir þig. _Uppsetning > Öryggi > Sudo án lykilorðs_ spyr hversu lengi eigi að leyfa aðgang: **15 minutes**, **1 Hour**, **1 Day** eða **Permanently**. Rautt viðvörunartákn birtist við hlið hinna vísanna á valmyndastikunni á meðan aðgangur er virkur. Smelltu á það eða keyrðu skipunina aftur til að slökkva á aðgangi. Þú getur líka gefið þína eigin mínútutölu (frá 1 til 1440) með `omarchy-sudo-passwordless 30`, eða notað `omarchy-sudo-passwordless permanent`.

Tímasettur aðgangur rennur út sjálfkrafa, þar á meðal strax eftir að hafa vaknað úr svefni sem fór yfir tímamörkin. Að endurræsa tölvuna endar hann snemma. Varanlegur aðgangur lifir endurræsingar af og helst virkur þar til þú slekkur á honum.

Að uppfæra eða fjarlægja stillingarpakka Omarchy endar sérhvert tímabundið leyfi áður en stuðningur við fyrningu þess breytist. Ef skipunin tilkynnir heimildar- eða hreinsunarvillu skaltu leysa hana áður en þú reynir að virkja annað leyfi; villa þýðir ekki að aðgangur án lykilorðs sé óvirkur.

Vertu hreinskilinn um þetta: á meðan það er á getur allt sem keyrir sem notandinn þinn gert hvað sem er sem root án þess að vera spurt. Það er allur tilgangurinn, og það er líka öll áhættan.

## Undirritunarlyklar

Opinber lykill fyrir allar ISO-undirritanir og Omarchy geymslupakka er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([staðfestu á openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). `omarchy/omarchy-keyring` pakkinn inniheldur þetta líka og verður notaður til að rúlla út hugsanlegum uppfærslum óaðfinnanlega.

Þú getur fundið undirritunina fyrir sérhverja ISO-útgáfu með því að bæta .sig við slóðina. Eins og https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
