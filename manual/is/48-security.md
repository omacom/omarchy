# Öryggi

Omarchy tekur öryggi afar alvarlega. Þetta á að vera stýrikerfi sem þú getur notað til að vinna _Alvöru vinnu_ í _Alvöru heiminum_. Þar sem það að týna fartölvu getur ekki leitt til öryggisneyðarástands. Svona gerum við það:

1. *Dulritun alls disksins er sjálfgefið virk*: Þetta er mikilvægasta skrefið til að tryggja líkamlega vernd gagna þinna. Ef tölvan þín týnist eða henni er stolið eru gögnin að fullu dulrituð með staðlaðri LUKS (Linux Unified Key Setup). Uppsetningarforritið leyfir þér að sleppa þessu fyrir vélar sem má henda (sjá [Að byrja](02-getting-started.md)); uppsetning án dulritunar hefur enga af þessari vernd og hver sem hefur drifið í höndunum getur lesið það.
2. *Eldveggur er sjálfgefið virkur*: Öll umferð inn er sjálfgefið blokkuð, með nokkrum undantekningum: gátt 53317 fyrir [LocalSend](https://localsend.org/); DNS-fyrirspurnir til eigin nafnþjóns tölvunnar á Docker-brúarvistfanginu (172.17.0.1), sem eru samþykktar frá einkavistfangabilunum sem Docker gefur gámum sínum; og multicast DNS (gátt 5353), sem gerir prenturum og öðrum tækjum á netinu þínu kleift að finna hvert annað og tilkynnir einnig nafn tölvunnar þinnar þar. Ofan á það heldur eldveggurinn stöðluðum heimildum UFW fyrir ping, að fá vistfang frá beininum þínum (DHCP) og UPnP-leit. Jafnvel ssh er slökkt þar til þú kveikir á því í gegnum _Uppsetning > Öryggi > SSHD_, sem opnar gátt 22 (með hraðatakmörkun gegn þvingunartilraunum) sem hluta af uppsetningunni. Við læsum meira að segja Docker-aðgangi með [ufw-docker](https://github.com/chaifeng/ufw-docker) uppsetningunni til að koma í veg fyrir að gámarnir þínir verði óvart opnir heiminum.
3. *Arch er alltaf með nýjustu uppfærslurnar*: Arch, undirliggjandi dreifingin sem Omarchy er byggt á, er rúllandi dreifing. Það þýðir að allir öryggisveikleikar sem uppgötvast og eru lagfærðir í einhverjum pakka verða fljótt fáanlegir til uppsetningar með `omarchy-update`. Þannig ertu alltaf að keyra nýjustu og öruggustu útgáfur af öllu.
4. *Omarchy viðheldur eigin pökkum og spegli*: Omarchy reiðir sig sjálfgefið aðeins á pakka úr eigin core/extra/multilib-pakkageymslum Arch og eigin Omarchy Package Repository. Þú getur sett upp hugbúnað beint úr AUR, en grunnuppsetningin gerir það ekki — aðeins nokkrar valfrjálsar uppsetningar, eins og vafrar frá þriðja aðila, sækja úr AUR.
5. *Cloudflare ver okkur gegn DDoS*: Dreifingarinnviðir Omarchy — ISO-skrárnar, Omarchy-pakkarnir, Arch-spegillinn — eru varðir á bak við öflugan DDoS-skjöld Cloudflare og hýstir á CDN þeirra. Þetta veitir framúrskarandi aðgengi.

## Að breyta lykilorðunum þínum

Þú hefur tvö lykilorð í dulritaðri uppsetningu: annað sem opnar drifið við ræsingu og hitt sem þú skráir þig inn og notar `sudo` með. Uppsetningin gerir þau eins. Hægt er að breyta báðum undir _Uppfærsla > Lykilorð_ í Omarchy-valmyndinni — _Dulritun drifs_ fyrir það fyrra, _Notandi_ fyrir það seinna. Þegar þú breytir lykilorði drifsins biður það fyrst um núverandi lykilorð, svo hafðu það við höndina. Ef breyting rofnar skaltu keyra _Dulritun drifs_ aftur: það biður um lykilorðið sem opnar drifið núna og klárar breytinguna.

## Að afhenda vél sem þú hefur þegar notað

Ef þú ert að afhenda einhverjum öðrum vélina þína þarftu ekki að setja hana upp aftur. Keyrðu _Uppsetning > Endurstilla tölvu_ í Omarchy-valmyndinni, sláðu inn `reset` til staðfestingar og endurræstu. Það þurrkar út alla notandareikninga og allt í `/home`, hendir öllum pökkum og kerfisbreytingum sem þú gerðir eftir uppsetningu og hreinsar auðkenni vélarinnar — nettengingar, hýsillykla og allt. Það sem kemur upp er uppsetningarhjálpin frá fyrstu ræsingu, tilbúin fyrir nýjan eiganda að slá inn eigið nafn, lykilorð og dulritunarlykilorð.

Það virkar með því að endurheimta grunnmyndina sem uppsetningarforritið tekur, svo það er aðeins í boði á vélum sem settar eru upp af Omarchy ISO. Og á drifi án dulritunar er endurstilling eyðing frekar en örugg þurrkun, svo ef gögnin voru viðkvæm skaltu í staðinn gera nýja uppsetningu frá grunni.

## Sudo án lykilorðs

Stundum viltu að `sudo` hætti að spyrja, oftast þegar gervigreindarumboðsmaður er að vinna langa lotu kerfisvinnu fyrir þig. _Uppsetning > Öryggi > Sudo án lykilorðs_ spyr hversu lengi eigi að heimila aðgang: **15 mínútur**, **1 klukkustund**, **1 dagur** eða **Til frambúðar**. Rautt viðvörunartákn birtist við hliðina á öðrum vísum valmyndastikunnar á meðan aðgangur er virkur. Smelltu á það eða keyrðu skipunina aftur til að slökkva á aðganginum. Þú getur líka gefið upp þinn eigin fjölda mínútna (frá 1 til 1440) með `omarchy-sudo-passwordless 30`, eða notað `omarchy-sudo-passwordless permanent`.

Tímabundinn aðgangur rennur sjálfkrafa út, þar með talið strax eftir að haldið er áfram úr biðstöðu sem fór yfir frestinn. Að endurræsa tölvuna endar hann fyrr. Aðgangur til frambúðar lifir endurræsingar og helst virkur þar til þú slekkur á honum.

Að uppfæra eða fjarlægja stillingapakka Omarchy endar öll tímabundin leyfi áður en stuðningur við rennslutíma þeirra breytist. Ef skipunin tilkynnir heimildar- eða hreinsunarvillu skaltu leysa hana áður en þú reynir að virkja annað leyfi; villa þýðir ekki að aðgangur án lykilorðs sé óvirkur.

Hafðu það alveg á hreinu varðandi þetta: á meðan þetta er virkt getur allt sem keyrir sem notandinn þinn gert hvað sem er sem root án þess að vera spurt. Það er allur tilgangurinn og það er líka öll áhættan.

## Undirritunarlyklar

Opinberi lykillinn fyrir allar ISO-undirritanir og Omarchy repo-pakka er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([staðfestu á openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakkinn `omarchy/omarchy-keyring` inniheldur þetta einnig og verður notaður til að koma hugsanlegum uppfærslum út óaðfinnanlega.

Þú getur fundið undirritunina fyrir hvaða ISO-útgáfu sem er með því að bæta `.sig` við vefslóð hennar, eins og `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
