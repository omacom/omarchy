# Stuðningur við Mac

Omarchy er með innbyggðan stuðning við **Intel Macs**. Það eru nokkrar þekktar takmarkanir í augnablikinu, en svo lengi sem þú veist af þeim og sættir þig við þær getur þú blásið nýju lífi í gömlu Mac-tölvurnar þínar með því að setja upp Omarchy.

Athugaðu að uppsetning á M-series Mac er ekki studd beint eins og er. Þú getur fengið frekari upplýsingar um stöðu þess í #omarchy-on-other í [Discord](https://discord.gg/tXFUdasqhY) okkar.

Í einföldu prófi náðum við 36% betri afköstum á 2019 MacBook Pro bara með því að setja upp Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Að setja Omarchy upp á Mac

Omarchy styður aðeins að vera **eina** stýrikerfið sem er uppsett í augnablikinu. Við uppsetninguna verður drifið þurrkað út og ekki lengur verður hægt að ræsa MacOS.

Þú getur samt endurheimt það síðar í gegnum Internet Recovery ef þú vilt.

Í þessum hluta gerum við ráð fyrir að þú hafir þegar skoðað [Komast af stað](02-getting-started.md) og sért með USB-drifið þitt tilbúið. Ef ekki skaltu gera það núna.

#### Slökkva á Secure Boot

Nauðsynlegt er að slökkva á Secure Boot hjá Apple til að geta ræst af ræsanlega USB-drifið, sem og stýrikerfið. Til að slökkva á því skaltu gera eftirfarandi:

1. Slökktu á Mac-tölvunni þinni
2. Kveiktu á henni og ýttu _strax_ á Command-R og haltu inni þar til þú sérð hleðsluskjáinn birtast
3. Veldu notandann þinn og sláðu inn lykilorðið þitt ef beðið er um það
4. Þegar þú ert kominn á endurheimtarskjáinn skaltu velja **Utilities > Startup Security Utility** í valmyndastikunni
5. Sláðu inn lykilorðið þitt þegar beðið er um auðkenningu
6. Veldu "No Security" úr valkostunum fyrir Secure Boot
7. Veldu "Allow booting from external or removable media" úr valkostunum fyrir External Boot

#### Hefja uppsetninguna

1. Settu USB-drifið í
2. Endurræstu Mac-tölvuna þína og ýttu _strax_ á Option og haltu inni þar til þú sérð skjá með ræsibúnaði
3. Veldu appelsínugula EFI Boot-búnaðinn
4. Haltu áfram með [uppsetninguna eins og venjulega](02-getting-started.md)

Uppsetningarforritið greinir Mac-vélbúnað og setur sjálfkrafa upp þær lagfæringar sem þarf: Broadcom Wi-Fi rekla og fastbúnað, SPI-lyklaborðsrekilinn á þeim MacBook-gerðum sem þurfa á honum að halda og NVMe-lagfæringu fyrir svefnham á sömu gerðum.

### Þekktar takmarkanir

Meðlimir samfélagsins vinna stöðugt að lausnum á þessum áskorunum, svo ef þetta veldur þér vandræðum skaltu koma í #omarchy-on-other í [Discord](https://discord.gg/tXFUdasqhY) okkar og sjá hvort til séu einhverjar nýjustu aðferðir til að leysa þetta.

#### Tæki með T1-kubb

Apple T1-kubburinn kom fram síðla árs 2016 og var eingöngu notaður í fyrstu kynslóð MacBook Pro-gerðanna með Touch Bar.
- MacBook Pro 13 tommu (2016, tvö Thunderbolt 3 tengi) – Gerð: A1706
- MacBook Pro 13 tommu (2016, fjögur Thunderbolt 3 tengi) – Gerð: A1708
- MacBook Pro 15 tommu (2016) – Gerð: A1707

#### Þekkt vandamál

- Touch Bar virkar ekki
- Hljóð virkar ekki

#### Tæki með T2-kubb

Apple T2 Security Chip kom fram árið 2017. Hætt var að nota T2-kubbinn með skiptunum yfir í Apple silicon (M-series kubba) sem hófust árið 2020.

- iMac Pro (2017) – Gerð: A1862
- MacBook Pro 13 tommu (2018, fjögur Thunderbolt 3 tengi) – Gerð: A1989
- MacBook Pro 15 tommu (2018) – Gerð: A1990
- MacBook Air (Retina, 13 tommu, 2018) – Gerð: A1932
- Mac mini (2018) – Gerð: A1998
- MacBook Pro 13 tommu (2019, tvö Thunderbolt 3 tengi) – Gerð: A2159
- MacBook Pro 13 tommu (2019, fjögur Thunderbolt 3 tengi) – Gerð: A2178
- MacBook Pro 15 tommu (2019) – Gerð: A1990
- iMac (Retina 5K, 27 tommu, 2020) – Gerð: A2115 (iMac20,1 og iMac20,2)
- MacBook Pro 13 tommu (2020, tvö Thunderbolt 3 tengi) – Gerð: A2265
- MacBook Pro 15 tommu (2020) – Gerð: A1990

Á þessum gerðum setur uppsetningarforritið sjálfkrafa upp lagfærða `linux-t2` kjarnann, T2-hljóðstillinguna, Broadcom Wi-Fi/Bluetooth fastbúnað frá Apple og viftustýringu í gegnum `t2fanrd`. Touch Bar keyrir á innbyggðum stuðningi kjarnans í Boot Camp-stíl.

#### iMac Retina 5K (2017)

27 tommu iMac frá 2017 er ekki með T2-kubb, svo uppsetningarforritið setur hann upp eins og aðrar Intel Macs.

- iMac (Retina 5K, 27 tommu, 2017) – Gerð: A1419

#### Þekkt vandamál

- Skjárinn keyrir ekki á innbyggðri 5120×2880 upplausn sinni: skjárinn samanstendur af tveimur flísum og sjálfgefni rekillinn virkjar aðeins aðra þeirra
- Hljóð virkar ekki
- Birtustýringin hefur engin áhrif
- Svefn hengir vélina; aðeins það að slökkva og kveikja aftur kemur henni í gang á ný

Lagfæring frá samfélaginu fyrir þessa gerð lagar skjáinn, hljóðið og birtuna: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
