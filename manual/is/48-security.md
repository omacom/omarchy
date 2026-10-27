# Öryggi

Omarchy tekur öryggi gífurlega alvarlega. Þetta á að vera stýrikerfi sem þú getur notað til að vinna _Raunveruleg verk_ í _Raunverulega heiminum_. Þar sem það að týna fartölvu getur ekki leitt til öryggisneyðar. Svo hér er það sem við gerum:

1. *Dulritun á öllum diskinum er skylda*: Þetta er mikilvægasta skrefið til að tryggja líkamlegt öryggi gagnanna þinna. Ef tölvan þín týnist eða henni er stolið eru gögnin að fullu dulrituð með stöðluðu LUKS (Linux Unified Key Setup).
2. *Eldveggur er virkur sjálfgefið*: Öll umferð inn er stöðvuð sjálfgefið nema á gátt 53317 fyrir [LocalSend](https://localsend.org/). Jafnvel ssh er slökkt þar til þú kveikir á því í _Uppsetning > Öryggi > SSHD_, sem opnar gátt 22 (með hraðatakmörkun gegn þvingunartilraunum) sem hluta af uppsetningunni. Við lokum jafnvel á aðgang Docker með [ufw-docker](https://github.com/chaifeng/ufw-docker) uppsetningunni til að koma í veg fyrir að gámarnir þínir verði óvart opnir heiminum.
3. *Arch er alltaf með nýjustu uppfærslurnar*: Arch, grunndreifingin sem Omarchy er byggt á, er rúllandi dreifing. Það þýðir að allir öryggisveikleikar sem uppgötvast og eru lagfærðir í einhverjum pakka verða fljótt fáanlegir til uppsetningar með `omarchy-update`. Þannig ertu alltaf að keyra nýjustu og öruggustu útgáfur af öllu.
4. *Omarchy viðheldur sínum eigin pökkum og spegilsþjóni*: Omarchy reiðir sig sjálfgefið aðeins á pakka úr eigin core/extra/multilib hugbúnaðarsöfnum Arch og sínu eigin Omarchy Package Repository. Þú getur sett upp hugbúnað beint úr AUR, en grunnuppsetningin gerir það ekki — aðeins fáar valfrjálsar uppsetningar, eins og vafrar frá þriðja aðila, sækja úr AUR.
5. *Cloudflare ver okkur gegn DDoS*: Dreifingarinnviðir Omarchy — ISO-myndirnar, Omarchy-pakkarnir, Arch-spegillinn — eru varðir á bak við formíðulegan DDoS-skjöld Cloudflare og hýstir á CDN þeirra. Þetta veitir framúrskarandi aðgengi.

## Að breyta lykilorðunum þínum

Þú ert með tvö lykilorð á dulritaðri uppsetningu: annað sem opnar drifið við ræsingu og hitt sem þú skráir þig inn og notar `sudo` með. Uppsetningin gerir þau eins. Hægt er að breyta báðum undir _Uppfærsla > Lykilorð_ í Omarchy-valmyndinni — _Dulritun disks_ fyrir það fyrra, _Notandi_ fyrir það síðara. Til að breyta lykilorði disksins þarftu fyrst að slá inn núverandi lykilorð, svo hafðu það við höndina. Ef breytingunni er truflað skaltu keyra _Dulritun disks_ aftur: þá er spurt um lykilorðið sem opnar drifið núna og breytingunni er lokið.

## Að afhenda vél sem þú hefur þegar notað

Ef þú ert að afhenda einhverjum öðrum vélina þína þarftu ekki að setja hana upp aftur. Keyrðu _Uppsetning > Endurstilla tölvu_ í Omarchy-valmyndinni, skrifaðu `reset` til að staðfesta og endurræstu. Það þurrkar út alla notandareikninga og allt í `/home`, fleygir öllum pökkum og kerfisbreytingum sem þú hefur gert frá uppsetningu og hreinsar auðkenni vélarinnar — nettengingar, hýsil-lykla og allt. Það sem kemur upp er uppsetningarhjálpin frá fyrstu ræsingu, tilbúin fyrir nýja eigandann til að slá inn eigið nafn, lykilorð og dulritunarlykilorð.

Þetta virkar með því að endurheimta grunnmyndina sem uppsetningarforritið tekur, svo þetta er aðeins í boði á vélum sem settar eru upp af Omarchy ISO. Og á drifi án dulritunar er endurstilling eyðing frekar en örugg þurrkun, svo ef gögnin voru viðkvæm skaltu í staðinn gera ferska uppsetningu.

## Sudo án lykilorðs

Stundum viltu að `sudo` hætti að spyrja, oftast þegar gervigreindarumboðsmaður er að vinna langa lotu kerfisvinnu fyrir þig. _Uppsetning > Öryggi > Sudo án lykilorðs_ spyr hversu lengi eigi að leyfa aðgang: **15 mínútur**, **1 klukkustund**, **1 dagur** eða **Til frambúðar**. Rautt viðvörunartákn birtist við hliðina á hinum vísunum á valmyndastikunni á meðan aðgangur er virkur. Smelltu á það eða keyrðu skipunina aftur til að slökkva á aðganginum. Þú getur líka gefið upp þinn eigin fjölda mínútna (frá 1 til 1440) með `omarchy-sudo-passwordless 30`, eða notað `omarchy-sudo-passwordless permanent`.

Tímasettur aðgangur rennur út sjálfkrafa, þar á meðal strax eftir að haldið er áfram úr svæfingu sem fór yfir frestinn. Endurræsing tölvunnar lýkur honum fyrr. Varanlegur aðgangur lifir endurræsingar af og helst virkur þar til þú slekkur á honum.

Uppfærsla eða fjarlæging á stillingapakka Omarchy lýkur öllum tímabundnum aðgangi áður en stuðningur við útfall hans breytist. Ef skipunin tilkynnir heimildar- eða hreinsunarvillu skaltu leysa hana áður en þú reynir að virkja annan aðgang; villa þýðir ekki að aðgangur án lykilorðs sé óvirkur.

Hafðu augun opin fyrir þessu: á meðan þetta er á getur allt sem keyrir sem notandinn þinn gert hvað sem er sem root án þess að vera spurt. Það er allur tilgangurinn, og það er líka öll áhættan.

## Undirritunarlyklar

Opinberi lykillinn fyrir allar ISO-undirritanir og Omarchy repo-pakka er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([staðfestu á openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakkinn `omarchy/omarchy-keyring` inniheldur þetta líka og verður notaður til að koma öllum hugsanlegum uppfærslum út óaðfinnanlega.

Þú getur fundið undirritunina fyrir hvaða ISO-útgáfu sem er með því að bæta `.sig` við slóð hennar, eins og `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
