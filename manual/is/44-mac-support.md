# Mac stuðningur

Omarchy hefur innbyggðan stuðning fyrir **Intel Mac**. Það eru nokkrar þekktar takmarkanir í augnablikinu, en svo framarlega sem þú ert meðvitaður um þær og sættir þig við þær geturðu blásið nýju lífi í gömlu Mac-tölvurnar þínar með því að hlaða inn Omarchy.

Athugaðu að uppsetning á M-röð Mac er ekki studd beint eins og er. Þú getur fengið meira að vita um stöðu þess í #omarchy-on-other á [Discord](https://discord.gg/tXFUdasqhY) okkar.

Í einföldu prófi náðum við 36% afkastaaukningu á 2019 MacBook Pro eingöngu með því að setja upp Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Að setja upp Omarchy á Mac

Omarchy styður aðeins að vera **eina** uppsetta stýrikerfið í augnablikinu. Við uppsetningu verður drifinu þurrkað út og MacOS verður ekki lengur ræsanlegt.

Þú getur samt endurheimt það síðar með Internet Recovery ef þú vilt.

Í þágu þessa hluta gerum við ráð fyrir að þú hafir þegar skoðað [Að byrja](02-getting-started.md) og hafir USB-drifið þitt tilbúið. Ef þú hefur það ekki, gerðu það núna.

#### Slökkva á Secure Boot

Nauðsynlegt er að slökkva á Secure Boot frá Apple til að ræsa ræsanlega USB-drifið, sem og stýrikerfið. Til að slökkva á því skaltu gera eftirfarandi:

1. Slökktu á Mac-tölvunni þinni
2. Kveiktu á henni og ýttu _strax_ á og haltu Command-R þar til þú sérð hleðsluskjáinn birtast
3. Veldu notandann þinn og sláðu inn lykilorðið þitt ef beðið er um það
4. Þegar þú ert kominn á endurheimtarskjáinn skaltu velja **Utilities > Startup Security Utility** í valmyndastikunni
5. Sláðu inn lykilorðið þitt þegar beðið er um auðkenningu
6. Veldu „No Security“ úr Secure Boot valkostunum
7. Veldu „Allow booting from external or removable media“ úr External Boot valkostunum

#### Byrja uppsetninguna

1. Settu USB-drifið inn
2. Endurræstu Mac-tölvuna þína og ýttu _strax_ á og haltu Option þar til þú sérð skjá með ræsitækjum
3. Veldu appelsínugula EFI Boot tækið
4. Haltu áfram með [venjulega uppsetningu](02-getting-started.md)

Uppsetningarforritið greinir Mac-vélbúnað og beitir nauðsynlegum lagfæringum sjálfkrafa: Broadcom Wi-Fi reklum og fastbúnaði, SPI lyklaborðsreklinum á MacBook gerðunum sem þurfa hann, og NVMe svefnlagfæringu fyrir sömu gerðir.

### Þekktar takmarkanir

Meðlimir samfélagsins vinna stöðugt að lausnum á þessum áskorunum, svo ef þetta er vandamál fyrir þig skaltu ganga til liðs við #omarchy-on-other á [Discord](https://discord.gg/tXFUdasqhY) okkar og sjá hvort til eru einhverjar nýlegar aðferðir til að leysa þau.

#### Tæki með T1 kubb

Apple T1 kubburinn var kynntur seint árið 2016 og notaður eingöngu í fyrstu kynslóð MacBook Pro gerða með Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Þekkt vandamál

- Touch Bar virkar ekki
- Hljóð virkar ekki

#### Tæki með T2 kubb

Apple T2 öryggiskubburinn var kynntur árið 2017. T2 kubbnum var hætt með umskiptunum yfir í Apple silicon (M-röð kubba) frá og með 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Á þessum gerðum setur uppsetningarforritið sjálfkrafa upp lagfærða `linux-t2` kjarnann, T2 hljóðstillingu, Broadcom Wi-Fi/Bluetooth fastbúnað frá Apple og viftustýringu með `t2fanrd`. Touch Bar keyrir á innbyggðum Boot Camp-stíls stuðningi kjarnans.
