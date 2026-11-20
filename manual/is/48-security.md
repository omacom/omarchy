# Öryggi

Omarchy tekur öryggi afar alvarlega. Þetta á að vera stýrikerfi sem þú getur notað til að vinna _Raunverulega vinnu_ í _Raunverulegum heimi_. Þar sem það að týna fartölvu getur ekki leitt til öryggisneyðar. Svona gerum við það:

1. *Dulritun á öllum diskinum er sjálfgefið virk*: Þetta er mikilvægasta skrefið til að tryggja efnislega vernd gagna þinna. Ef tölvan týnist eða henni er stolið eru gögnin að fullu dulrituð með stöðluðu LUKS (Linux Unified Key Setup). Uppsetningarforritið leyfir þér að sleppa þessu fyrir vélar sem má henda (sjá [Byrjað](02-getting-started.md)); uppsetning án dulritunar hefur enga af þessari vernd, og hver sá sem heldur á drifinu getur lesið það.
2. *Eldveggur er sjálfgefið virkur*: Öll umferð inn er sjálfgefið blokkuð, með nokkrum undantekningum: port 53317 fyrir [LocalSend](https://localsend.org/); DNS-fyrirspurnir til eigin nafnamiðlara tölvunnar á Docker-brúarvistfanginu (172.17.0.1), sem eru samþykktar frá einkavistfangasviðunum sem Docker gefur gámum sínum; og multicast DNS (port 5353), sem gerir prenturum og öðrum tækjum á netinu þínu kleift að finna hvert annað og tilkynnir einnig nafn tölvunnar þinnar þar. Auk þeirra heldur eldveggurinn stöðluðum heimildum UFW fyrir ping, að fá vistfang frá beininum þínum (DHCP) og UPnP-leit. Jafnvel ssh er slökkt þar til þú kveikir á því í gegnum _Setup > Security > SSHD_, sem opnar port 22 (með takmörkun á tíðni til að verjast þvingunartilraunum) sem hluta af uppsetningunni. Við læsum meira að segja aðgangi Docker niður með [ufw-docker](https://github.com/chaifeng/ufw-docker) uppsetningunni til að koma í veg fyrir að gámarnir þínir verði óvart opnir fyrir umheiminum.
3. *Arch er alltaf með nýjustu uppfærslurnar*: Arch, undirliggjandi dreifingin sem Omarchy er byggð á, er rúllandi dreifing. Það þýðir að allir öryggisveikleikar sem uppgötvast og eru lagfærðir í einhverjum pakka verða fljótt aðgengilegir til uppsetningar með `omarchy-update`. Þannig ertu alltaf að keyra nýjustu og öruggustu útgáfur af öllu.
4. *Omarchy viðheldur sínum eigin pökkum og spegli*: Omarchy reiðir sig sjálfgefið aðeins á pakka frá eigin core/extra/multilib-pakkageymslum Arch og sinni eigin Omarchy Package Repository. Þú getur sett upp hugbúnað beint frá AUR, en grunnuppsetningin gerir það ekki — aðeins nokkrar valfrjálsar uppsetningar, eins og vafrar frá þriðja aðila, sækja frá AUR.
5. *Cloudflare ver okkur gegn DDoS*: Dreifingarinnviðir Omarchy — ISO-skrárnar, Omarchy-pakkarnir, Arch-spegillinn — eru varðir á bak við formíðabæran DDoS-sköld Cloudflare og hýstir á CDN þeirra. Þetta tryggir framúrskarandi aðgengi.

## Að breyta lykilorðunum þínum

Þú hefur tvö lykilorð í dulritaðri uppsetningu: eitt sem aflæsir drifinu við ræsingu, og eitt sem þú skráir þig inn og notar `sudo` með. Uppsetningin gerir þau að sama lykilorðinu. Hægt er að breyta báðum undir _Update > Password_ í Omarchy-valmyndinni — _Drive Encryption_ fyrir það fyrra, _User_ fyrir það síðara. Til að breyta lykilorði drifsins þarftu fyrst að slá inn núverandi lykilorð, svo hafðu það við höndina. Ef breytingunni er truflað skaltu keyra _Drive Encryption_ aftur: það biður um lykilorðið sem aflæsir drifinu núna og klárar breytinguna.

## Að afhenda vél sem þú hefur þegar notað

Ef þú ert að afhenda einhverjum öðrum vélina þína þarftu ekki að setja hana upp aftur. Keyrðu _Remove > Factory Reset_ í Omarchy-valmyndinni, skrifaðu `reset` til að staðfesta og endurræstu. Það þurrkar út alla notandareikninga og allt í `/home`, hendir öllum pökkum og kerfisbreytingum sem þú gerðir eftir uppsetningu og hreinsar auðkenni vélarinnar — nettengingar, hýsillykla og allt. Það sem ræsist upp er uppsetningarhjálpin frá fyrstu ræsingu, tilbúin fyrir nýja eigandann til að slá inn sitt eigið nafn, lykilorð og dulritunarlykilorð.

Það virkar með því að endurheimta grunnmyndina sem uppsetningarforritið tekur, svo það er aðeins í boði á vélum sem settar eru upp frá Omarchy ISO. Og á drifi án dulritunar er endurstilling eyðing frekar en örugg þurrkun, svo ef gögnin voru viðkvæm skaltu í staðinn gera nýja uppsetningu frá grunni.

## Sudo án lykilorðs

Stundum viltu að `sudo` hætti að spyrja, oftast þegar AI-fulltrúi vinnur að kerfisvinnu fyrir þig í langan tíma í einu. _Setup > Security > Passwordless Sudo_ spyr hversu lengi eigi að leyfa aðgang: **15 mínútur**, **1 klukkustund**, **1 dagur** eða **Varanlega**. Rautt viðvörunartákn birtist við hliðina á öðrum vísum á valmyndastikunni á meðan aðgangurinn er virkur. Smelltu á það eða keyrðu skipunina aftur til að slökkva á aðganginum. Þú getur líka gefið upp þinn eigin fjölda mínútna (frá 1 til 1440) með `omarchy-sudo-passwordless 30`, eða notað `omarchy-sudo-passwordless permanent`.

Tímabundinn aðgangur rennur sjálfkrafa út, þar á meðal strax eftir að haldið er áfram úr svefnham sem fór yfir frestinn. Að endurræsa tölvuna endar hann fyrr. Varanlegur aðgangur lifir endurræsingar og helst virkur þar til þú slekkur á honum.

Að uppfæra eða fjarlægja stillingapakka Omarchy endar allan tímabundinn veittan aðgang áður en stuðningur við útfall hans breytist. Ef skipunin tilkynnir heimildar- eða hreinsunarvillu skaltu leysa hana áður en þú reynir að virkja annan veittan aðgang; villa þýðir ekki að aðgangur án lykilorðs sé óvirkur.

Sjáðu þetta með augunum opnum: á meðan þetta er virkt getur allt sem keyrir sem notandinn þinn gert allt sem root án þess að vera spurt. Það er allur tilgangurinn, og það er líka öll áhættan.

## Undirritunarlyklar

Opinberi lykillinn fyrir allar ISO-undirritanir og Omarchy-pakkageymslupakkann er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([staðfestu á openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakkinn `omarchy/omarchy-keyring` inniheldur hann líka og verður notaður til að koma öllum hugsanlegum uppfærslum út óaðfinnanlega.

Þú getur fundið undirritunina fyrir hvaða ISO-útgáfu sem er með því að bæta `.sig` við vefslóð hennar, eins og `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
