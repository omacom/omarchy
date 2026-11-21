# Öryggi

Omarchy tekur öryggi afar alvarlega. Þetta á að vera stýrikerfi sem þú getur notað til að vinna _alvöru vinnu_ í _alvöru heiminum_. Þar sem það að týna fartölvu getur ekki leitt til neyðarástands í öryggismálum. Svona gerum við þetta:

1. *Dulritun á öllum diski er sjálfgefið virk*: Þetta er mikilvægasta skrefið til að tryggja líkamlega vernd gagnanna þinna. Ef tölvan þín týnist eða henni er stolið eru gögnin að fullu dulrituð með stöðluðu LUKS (Linux Unified Key Setup). Uppsetningarforritið leyfir þér að afþakka þetta fyrir einnota vélar (sjá [Byrjað](02-getting-started.md)); uppsetning án dulritunar hefur enga af þessari vernd og hver sem heldur á drifinu getur lesið það.
2. *Eldveggur er sjálfgefið virkur*: Öll umferð inn er sjálfgefið blokkuð, með nokkrum undantekningum: port 53317 fyrir [LocalSend](https://localsend.org/); DNS fyrirspurnir til eigin nafnþjóns tölvunnar á Docker bridge vistfanginu (172.17.0.1), samþykktar frá einkavistfangasviðunum sem Docker gefur gámunum sínum; og multicast DNS (port 5353), sem leyfir prenturum og öðrum tækjum á netinu þínu að finna hvert annað og tilkynnir einnig nafn tölvunnar þinnar þar. Ofan á þetta heldur eldveggurinn stöðluðum heimildum UFW fyrir ping, að fá vistfang frá beininum þínum (DHCP) og UPnP uppgötvun. Jafnvel ssh er slökkt þar til þú kveikir á því í gegnum _Setup > Security > SSHD_, sem heimilar SSH lykilinn þinn, slekkur á innskráningu með lykilorði og opnar aðeins þá port 22 (með hraðatakmörkun gegn brute force). Við læsum meira að segja Docker aðgangi með [ufw-docker](https://github.com/chaifeng/ufw-docker) uppsetningunni til að koma í veg fyrir að gámarnir þínir verði óvart opnir fyrir heiminum.
3. *Arch hefur alltaf nýjustu uppfærslurnar*: Arch, undirliggjandi dreifingin sem Omarchy er byggt á, er rolling dreifing. Þetta þýðir að hvaða öryggisveikleika sem uppgötvast og lagfærður er í einhverjum pakka er fljótt hægt að setja upp með `omarchy-update`. Þannig ertu alltaf að keyra nýjustu, öruggustu útgáfur af öllu.
4. *Omarchy viðheldur sínum eigin pökkum og spegli*: Omarchy reiðir sig sjálfgefið aðeins á pakka frá eigin core/extra/multilib hugbúnaðarsöfnum Arch (Arch Linux ARM á ARM vélum, auk Asahi ALARM á Apple Silicon) og sínu eigin Omarchy Package Repository. Þú getur sett upp hugbúnað beint frá AUR, en grunnuppsetningin gerir það ekki — aðeins nokkrar valfrjálsar uppsetningar, eins og vafrarnir frá þriðja aðila, sækja frá AUR.
5. *Cloudflare verndar okkur gegn DDoS*: Innviðir Omarchy dreifingarinnar — ISO skrárnar, Omarchy pakkarnir, Arch spegillinn — eru varðir á bak við öflugan DDoS skjöld Cloudflare og hýstir á CDN þeirra. Þetta tryggir frábært aðgengi.

## Að breyta lykilorðunum þínum

Þú ert með tvö lykilorð á dulritaðri uppsetningu: annað sem opnar drifið við ræsingu og hitt sem þú skráir þig inn og notar `sudo` með. Uppsetningin gerir þau að sama lykilorðinu. Hægt er að breyta báðum undir _Update > Password_ í Omarchy valmyndinni — _Drive Encryption_ fyrir það fyrra, _User_ fyrir það síðara. Að breyta lykilorði drifsins biður fyrst um núverandi lykilorð, svo hafðu það við höndina. Ef breyting er trufluð skaltu keyra _Drive Encryption_ aftur: það biður um lykilorðið sem opnar drifið núna og klárar breytinguna.

## Að láta öðrum vél sem þú hefur þegar notað

Ef þú ert að afhenda einhverjum öðrum vélina þína þarftu ekki að setja hana upp aftur. Keyrðu _Remove > Factory Reset_ í Omarchy valmyndinni, sláðu inn `reset` til að staðfesta, sláðu inn dulritunarlykilorð drifsins ef beðið er um það og endurræstu. Það þurrkar út alla notandareikninga og allt í `/home`, hendir öllum pökkum og kerfisbreytingum sem þú gerðir frá uppsetningu og hreinsar auðkenni vélarinnar — nettengingar, host keys og allt. Það sem ræsist aftur er uppsetningarhjálpin frá fyrstu ræsingu, tilbúin fyrir nýja eigandann að slá inn sitt eigið nafn, lykilorð og dulritunarlykilorð.

Það virkar með því að endurheimta grunnskyndimyndina sem uppsetningarforritið tekur, svo það er aðeins í boði á vélum sem settar eru upp frá Omarchy ISO. Og á drifi án dulritunar er endurstilling eyðing frekar en örugg þurrkun, svo ef gögnin voru viðkvæm skaltu gera ferska uppsetningu í staðinn.

## Sudo án lykilorðs

Stundum viltu að `sudo` hætti að spyrja, oftast þegar AI agent er að vinna langt stretch af kerfisvinnu fyrir þig. _Setup > Security > Passwordless Sudo_ spyr hversu lengi eigi að heimila aðgang: **15 mínútur**, **1 Hour**, **1 Day** eða **Permanently**. Rautt viðvörunartákn birtist við hliðina á öðrum vísum valmyndastikunnar á meðan aðgangur er virkur. Smelltu á það eða keyrðu skipunina aftur til að slökkva á aðganginum. Þú getur líka sent inn þinn eigin mínútufjölda (frá 1 til 1440) með `omarchy-sudo-passwordless 30`, eða notað `omarchy-sudo-passwordless permanent`.

Tímabundinn aðgangur rennur út sjálfkrafa, þar á meðal strax eftir að haldið er áfram úr biðstöðu sem fór yfir tímamörkin. Endurræsing tölvunnar endar hann fyrr. Varanlegur aðgangur lifir endurræsingar af og helst virkur þar til þú slekkur á honum.

Að uppfæra eða fjarlægja stillingapakka Omarchy endar allar tímabundnar heimildir áður en stuðningur þeirra við að renna út breytist. Ef skipunin tilkynnir heimildar- eða hreinsunarvillu skaltu leysa hana áður en þú reynir að virkja aðra heimild; villa þýðir ekki að aðgangur án lykilorðs sé óvirkur.

Gerðu þér fulla grein fyrir þessu: á meðan þetta er virkt getur allt sem keyrir sem notandinn þinn gert hvað sem er sem root án þess að vera spurt. Það er allur tilgangurinn, og það er líka öll áhættan.

## Undirritunarlyklar

Opinberi lykillinn fyrir allar ISO undirritanir og Omarchy repo pakka er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([staðfestu á openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakkinn `omarchy/omarchy-keyring` inniheldur þennan líka og verður notaður til að koma hugsanlegum uppfærslum út óaðfinnanlega.

Þú getur fundið undirritunina fyrir hvaða ISO útgáfu sem er með því að bæta `.sig` við slóð hennar, eins og `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
