# Öryggi

Omarchy tekur öryggi gífurlega alvarlega. Þetta á að vera stýrikerfi sem þú getur notað til að vinna _Raunverulega vinnu_ í _Raunverulega heiminum_. Þar sem það getur ekki leitt til öryggisneyðarástands að týna fartölvu. Svo hér er það sem við gerum:

1. *Dulritun alls disksins er sjálfgefið virk*: Þetta er mikilvægasta skrefið til að tryggja líkamlega vernd gagna þinna. Ef tölvan þín týnist eða henni er stolið eru gögnin að fullu dulrituð með stöðluðu LUKS (Linux Unified Key Setup). Uppsetningarforritið leyfir þér að sleppa þessu fyrir einnota vélar (sjá [Að hefjast handa](02-getting-started.md)); uppsetning án dulritunar hefur enga af þessari vernd og hver sem heldur á drifinu getur lesið það.
2. *Eldveggur er sjálfgefið virkur*: Öll umferð inn er sjálfgefið blokkuð, með nokkrum undantekningum: port 53317 fyrir [LocalSend](https://localsend.org/); DNS-fyrirspurnir til eigin nafnþjóns tölvunnar á Docker-brúarvistfanginu (172.17.0.1), sem eru samþykktar frá einkavistfangasviðunum sem Docker gefur gámum sínum; og multicast DNS (port 5353), sem leyfir prenturum og öðrum tækjum á netinu þínu að finna hvert annað og tilkynnir einnig nafn tölvunnar þinnar þar. Ofan á það heldur eldveggurinn stöðluðum heimildum UFW fyrir ping, að fá vistfang frá beininum þínum (DHCP) og UPnP-leit. Jafnvel ssh er slökkt þar til þú kveikir á því í gegnum _Uppsetning > Öryggi > SSHD_, sem heimilar SSH-lykilinn þinn, slekkur á innskráningum með lykilorði og opnar aðeins þá port 22 (með takmörkun á tíðni til varnar gegn þvingunarárásum). Við læsum meira að segja Docker-aðgangi með [ufw-docker](https://github.com/chaifeng/ufw-docker) uppsetningunni til að koma í veg fyrir að gámarnir þínir verði óvart opnir heiminum.
3. *Arch er alltaf með nýjustu uppfærslurnar*: Arch, undirliggjandi dreifingin sem Omarchy er byggt á, er rúllandi dreifing. Þetta þýðir að sérhver öryggisveila sem uppgötvast og er lagfærð í einhverjum pakka verður fljótt tiltæk til uppsetningar með `omarchy-update`. Þannig ertu alltaf að keyra nýjustu og öruggustu útgáfur af öllu.
4. *Omarchy viðheldur sínum eigin pökkum og spegli*: Omarchy reiðir sig sjálfgefið aðeins á pakka úr eigin core/extra/multilib-hugbúnaðarsöfnum Arch (Arch Linux ARM á ARM-vélum, auk Asahi ALARM á Apple Silicon) og sínu eigin Omarchy Package Repository. Þú getur sett upp hugbúnað beint frá AUR, en grunnuppsetningin gerir það ekki — aðeins nokkrar valfrjálsar uppsetningar, eins og vafrar frá þriðja aðila, sækja frá AUR.
5. *Cloudflare ver okkur gegn DDoS*: Innviðir fyrir dreifingu Omarchy — ISO-skrárnar, Omarchy-pakkarnir, Arch-spegillinn — eru varðir á bak við öflugan DDoS-skjöld Cloudflare og hýstir á CDN þeirra. Þetta veitir framúrskarandi tiltækileika.

## Að breyta lykilorðunum þínum

Þú hefur tvö lykilorð á dulritaðri uppsetningu: eitt sem aflæsir drifinu við ræsingu og eitt sem þú skráir þig inn og notar `sudo` með. Uppsetningin gerir þau að sama lykilorði. _Uppfærsla > Lykilorð_ í Omarchy-valmyndinni breytir báðum í einu, svo þau haldast eins: það biður um núverandi lykilorð drifsins, síðan það nýja, breytir því á drifinu og stillir síðan innskráningarlykilorðið þitt svo það passi. Án dulritunar drifs breytir það aðeins innskráningarlykilorðinu þínu. Ef breytingunni er truflað skaltu keyra _Uppfærsla > Lykilorð_ aftur: það biður um lykilorðið sem aflæsir drifinu núna, lýkur breytingunni og stillir innskráningarlykilorðið þitt á það. Til að breyta lykilorði annars dulritaðs drifs skaltu keyra `omarchy-drive-password` í útstöð.

## Að afhenda vél sem þú hefur þegar notað

Ef þú ert að afhenda einhverjum öðrum vélina þína þarftu ekki að setja hana upp aftur. Keyrðu _Fjarlægja > Verksmiðjuendurstilling_ í Omarchy-valmyndinni, skrifaðu `reset` til að staðfesta, sláðu inn dulritunarlykilorð drifsins ef beðið er um það og endurræstu. Það þurrkar út sérhvern notandareikning og allt í `/home`, hendir öllum pökkum og kerfisbreytingum sem þú gerðir frá uppsetningu og hreinsar auðkenni vélarinnar — nettengingar, host-lykla og allt saman. Það sem ræsist upp aftur er uppsetningarhjálpin frá fyrstu ræsingu, tilbúin fyrir nýjan eiganda sinn að slá inn eigið nafn, lykilorð og dulritunarlykilorð.

Það virkar með því að endurheimta grunnmyndina sem uppsetningarforritið tekur, svo það er aðeins tiltækt á vélum sem settar voru upp frá Omarchy ISO. Og á drifi án dulritunar er endurstilling eyðing frekar en örugg þurrkun, svo ef gögnin voru viðkvæm skaltu frekar gera nýja uppsetningu frá grunni.

## Sudo án lykilorðs

Stundum viltu að `sudo` hætti að spyrja, oftast þegar gervigreindarfulltrúi vinnur langa lotu kerfisvinnu fyrir þig. _Uppsetning > Öryggi > Sudo án lykilorðs_ spyr hversu lengi eigi að leyfa aðgang: **15 mínútur**, **1 klukkustund**, **1 dagur** eða **Til frambúðar**. Rautt viðvörunartákn birtist við hliðina á öðrum vísum valmyndastikunnar á meðan aðgangur er virkur. Smelltu á það eða keyrðu skipunina aftur til að slökkva á aðganginum. Þú getur líka gefið upp þinn eigin fjölda mínútna (frá 1 til 1440) með `omarchy-sudo-passwordless 30`, eða notað `omarchy-sudo-passwordless permanent`.

Tímabundinn aðgangur rennur sjálfkrafa út, þar á meðal strax eftir að haldið er áfram úr svefnham sem fór yfir frestinn. Endurræsing tölvunnar lýkur honum fyrr. Varanlegur aðgangur lifir endurræsingar af og helst virkur þar til þú slekkur á honum.

Að uppfæra eða fjarlægja stillingapakka Omarchy lýkur sérhverri tímabundinni veitingu áður en stuðningur við rennslutíma hennar breytist. Ef skipunin tilkynnir heimildar- eða hreinsunarvillu skaltu leysa hana áður en þú reynir að virkja aðra veitingu; villa þýðir ekki að aðgangur án lykilorðs sé óvirkur.

Vertu með augun opin varðandi þetta: á meðan þetta er virkt getur allt sem keyrir sem notandinn þinn gert hvað sem er sem root án þess að vera spurt. Það er allur tilgangurinn, og það er líka öll áhættan.

## Undirritunarlyklar

Opinberi lykillinn fyrir allar undirritanir ISO og pakka í Omarchy-safninu er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([staðfestu hjá openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakkinn `omarchy/omarchy-keyring` inniheldur þetta líka og verður notaður til að koma öllum hugsanlegum uppfærslum út á óaðfinnanlegan hátt.

Þú getur fundið undirritunina fyrir sérhverja ISO-útgáfu með því að bæta `.sig` við vefslóð hennar, eins og `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
