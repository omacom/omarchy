# Öryggi

Omarchy tekur öryggi afar alvarlega. Þetta á að vera stýrikerfi sem þú getur notað til að vinna _raunverulega vinnu_ í _raunheimum_. Þar sem það að týna fartölvu getur ekki leitt til öryggisneyðar. Svo þetta er það sem við gerum:

1. *Dulkóðun alls disksins er skylda*: Þetta er mikilvægasta skrefið til að tryggja líkamlega vernd gagna þinna. Ef tölvan þín týnist eða henni er stolið eru gögnin að fullu dulkóðuð með hefðbundinni LUKS (Linux Unified Key Setup).
2. *Eldveggur er virkur sjálfgefið*: Öll umferð inn er blokkuð sjálfgefið, nema á porti 53317 fyrir [LocalSend](https://localsend.org/). Jafnvel ssh er slökkt þar til þú kveikir á því í gegnum _Uppsetning > Öryggi > SSHD_, sem opnar port 22 (með hraðatakmörkun gegn hráaflsárásum) sem hluta af uppsetningunni. Við læsum meira að segja aðgang Docker með [ufw-docker](https://github.com/chaifeng/ufw-docker) uppsetningunni til að koma í veg fyrir að gámarnir þínir verði óvart opnir heiminum.
3. *Arch er alltaf með nýjustu uppfærslurnar*: Arch, dreifingin sem Omarchy byggir á, er rúllandi dreifing. Það þýðir að allir öryggisgallar sem uppgötvast og er lagfært í einhverjum pakka verður fljótt hægt að setja upp með `omarchy-update`. Þannig keyrir þú alltaf nýjustu og öruggustu útgáfur af öllu.
4. *Omarchy viðheldur sínum eigin pökkum og spegli*: Omarchy reiðir sig sjálfgefið aðeins á pakka úr eigin core/extra/multilib hugbúnaðarsöfnum Arch og sínu eigin Omarchy Package Repository. Þú getur sett upp hugbúnað beint úr AUR, en grunnuppsetningin gerir það ekki — aðeins örfáar valfrjálsar uppsetningar, eins og vafrarnir frá þriðju aðilum, sækja úr AUR.
5. *Cloudflare verndar okkur gegn DDoS*: Dreifingarinnviðir Omarchy — ISO-skrárnar, Omarchy-pakkarnir, Arch-spegillinn — eru varðir á bak við ógnarsterkan DDoS-skjöld Cloudflare og hýstir á CDN þeirra. Það veitir afburða aðgengi.

## Að breyta lykilorðunum þínum

Þú ert með tvö lykilorð á dulkóðaðri uppsetningu: annað sem opnar drifið við ræsingu og hitt sem þú skráir þig inn og notar `sudo` með. Uppsetningin gerir þau eins. Hægt er að breyta báðum undir _Uppfærsla > Lykilorð_ í Omarchy-valmyndinni — _Drifdulkóðun_ fyrir það fyrra, _Notandi_ fyrir það síðara. Þegar driflykilorðinu er breytt er fyrst beðið um það núverandi, svo hafðu það við höndina. Ef breyting rofnar skaltu keyra _Drifdulkóðun_ aftur: þá er beðið um lykilorðið sem opnar drifið núna og breytingunni er lokið.

## Að afhenda vél sem þú hefur þegar notað

Ef þú ert að afhenda einhverjum öðrum vélina þína þarftu ekki að setja hana upp aftur. Keyrðu _Uppsetning > Endurstilla tölvu_ í Omarchy-valmyndinni, sláðu inn `reset` til staðfestingar og endurræstu. Það þurrkar út alla notendareikninga og allt í `/home`, hendir öllum pökkum og kerfisbreytingum sem þú gerðir eftir uppsetningu og hreinsar auðkenni vélarinnar — nettengingar, hýsilkla og allt. Það sem kemur upp er uppsetningarhjálpin frá fyrstu ræsingu, tilbúin fyrir nýja eigandann að slá inn sitt eigið nafn, lykilorð og dulkóðunarlykilorð.

Þetta virkar með því að endurheimta grunnmyndina sem uppsetningarforritið tekur, svo þetta er aðeins í boði á vélum sem settar voru upp af Omarchy ISO. Og á drifi án dulkóðunar er endurstilling eyðing frekar en örugg þurrkun, svo ef gögnin voru viðkvæm skaltu frekar gera ferska uppsetningu.

## Lykilorðslaust sudo

Stundum vilt þú að `sudo` hætti að spyrja, oftast þegar AI-umboðsmaður er að vinna langt verk á kerfinu fyrir þig. _Uppsetning > Öryggi > Lykilorðslaust Sudo_ spyr hversu lengi eigi að leyfa aðgang: **15 mínútur**, **1 klukkustund**, **1 dagur** eða **Varanlega**. Rautt viðvörunartákn birtist við hliðina á hinum vísunum á valmyndastikunni á meðan aðgangur er virkur. Smelltu á það eða keyrðu skipunina aftur til að slökkva á aðganginum. Þú getur líka gefið upp þína eigin tölu mínútna (frá 1 til 1440) með `omarchy-sudo-passwordless 30`, eða notað `omarchy-sudo-passwordless permanent`.

Tímabundinn aðgangur rennur út sjálfkrafa, þar á meðal strax eftir að haldið er áfram úr biðstöðu sem fór yfir tímamörkin. Að endurræsa tölvuna lýkur honum fyrr. Varanlegur aðgangur lifir endurræsingar og helst virkur þar til þú slekkur á honum.

Að uppfæra eða fjarlægja stillingapakka Omarchy lýkur öllum tímabundnum heimildum áður en stuðningur við rennslutíma þeirra breytist. Ef skipunin tilkynnir heimildar- eða hreinsunarvillu skaltu leysa hana áður en þú reynir að virkja aðra heimild; villa þýðir ekki að lykilorðslaus aðgangur sé óvirkur.

Vertu með augun opin fyrir þessu: á meðan þetta er virkt getur allt sem keyrir sem notandinn þinn gert hvað sem er sem root án þess að vera spurt. Það er allur tilgangurinn, og það er líka öll áhættan.

## Undirritunarlyklar

Opinberi lykillinn fyrir allar ISO-undirritanir og Omarchy repo-pakkann er `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([staðfestu á openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Pakkinn `omarchy/omarchy-keyring` inniheldur þetta líka og verður notaður til að koma hugsanlegum uppfærslum út óaðfinnanlega.

Þú finnur undirritunina fyrir hvaða ISO-útgáfu sem er með því að bæta .sig við URL-slóðina. Eins og https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
