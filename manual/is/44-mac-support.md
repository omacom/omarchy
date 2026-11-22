# Stuðningur við Mac

## Omarchy fyrir Apple Silicon

Omarchy fyrir Apple Silicon er opinber lausn frá Omacom, fyrst gefin út með Omarchy 4.5. Hún setur upp við hliðina á macOS og þú velur á milli þeirra tveggja þegar Mac-tölvan þín ræsir sig.

Fékkstu tilkynningu um Omarchy Mac? Farðu í [Að koma frá Omarchy Mac](#coming-from-omarchy-mac).

Hún keyrir á þessum Mac-tölvum:

| Mac | Örgjörvar |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Mac-tölvur með M4 og nýrri eru ekki studdar ennþá. Stuðningur við M4 er í prófunum á edge-rásinni og kemur næst. Uppsetningarforritið athugar Mac-tölvuna þína áður en það breytir nokkru.

Á hvaða Apple Silicon Mac sem er, þar á meðal M4 og nýrri, getur þú keyrt Omarchy í sýndarvél með [Try Omarchy](https://github.com/omacom/try-omarchy).

### Það sem þú þarft

- macOS 15 Sequoia eða nýrra, og stjórnandareikning
- Laust diskrými fyrir Omarchy. Uppsetningarforritið stingur upp á stærð og leyfir þér að breyta henni.
- Öryggisafrit af Mac-tölvunni þinni, rafmagn og nettenging. Uppsetningin sækir nokkur gígabæti.

### Uppsetning

Þú setur upp frá macOS. Settu upp Omarchy Installer með [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Eða sæktu nýjasta Omarchy Installer af [útgáfusíðu](https://github.com/omacom/omarchy-mac-installer/releases) þess og opnaðu það.

Uppsetningarforritið athugar Mac-tölvuna þína, sýnir þér áætlunina og býr til rými fyrir Omarchy með því að minnka macOS-skiptinguna. macOS verður áfram á diskinum og enginn USB-lykill er nauðsynlegur. Þegar fyrsta stiginu er lokið leiðir það þig í gegnum að klára uppsetninguna í macOS Recovery: slökktu á tölvunni, haltu aflhnappinum inni þar til "Loading startup options" birtist, veldu Omarchy og fylgdu skrefunum.

Við fyrstu ræsingu biður Omarchy um lykilorð sem dulkóðar diskinn hennar. Það er enginn endurheimtarlykill: ef þú gleymir lykilorðinu er ekki hægt að endurheimta Omarchy-skrárnar þínar.

Til að skipta á milli Omarchy og macOS síðar skaltu slökkva á tölvunni, halda síðan aflhnappinum inni þar til ræsivalkostirnir birtast og velja annan hvorn.

### Að koma frá Omarchy Mac

Omarchy Mac er nú hluti af Omarchy fyrir Apple Silicon og sérhver Mac-tölva sem keyrði það er studd. Núverandi uppsetning þín heldur áfram að keyra og kerfispakkarnir hennar uppfærast enn, en hún fær engar fleiri Omarchy-uppfærslur. Það er enginn frestur og engin uppfærsla á staðnum: þú tekur öryggisafrit, fjarlægir gömlu uppsetninguna, setur upp frá grunni og endurheimtir. Skref 2 til 5 gerast í macOS, svo opnaðu þessa síðu í símanum þínum áður en þú endurræsir.

1. **Taktu öryggisafrit frá Omarchy, utan Mac-tölvunnar.** Að fjarlægja gömlu uppsetninguna eyðir henni og macOS getur ekki lesið Omarchy-diskinn. Afritaðu heimamöppuna þína á ytri drif eða aðra tölvu, þar á meðal SSH- og GPG-lykla, vafrasnið og verk sem þú hefur ekki ýtt út. Vistaðu pakkalistann þinn með `pacman -Qqe > ~/packages.txt`. Taktu líka öryggisafrit af macOS, þar sem bæði að fjarlægja og setja upp breyta stærð disksins þess.
2. **Ræstu Mac-tölvuna þína í macOS.** Slökktu á henni, haltu aflhnappinum inni þar til ræsivalkostirnir birtast og veldu macOS.
3. **Settu upp Omarchy Installer** eins og sýnt er í [Uppsetning](#installing).
4. **Fjarlægðu gömlu uppsetninguna.** Opnaðu Omarchy Installer og veldu Installation > Remove Omarchy. Það sýnir hvað það mun eyða og skilar rýminu til macOS. Ef það þekkir ekki uppsetninguna þína stöðvast það án þess að breyta diskinum. Biddu um hjálp í [Discord](https://discord.gg/tXFUdasqhY) frekar en að eyða skiptingum handvirkt, sem getur eytt macOS.
5. **Settu upp Omarchy fyrir Apple Silicon** með uppsetningarforritinu.
6. **Endurheimtu skrárnar þínar.** Færðu stillingarnar þínar til baka smátt og smátt frekar en að afrita allt `~/.config` yfir nýju sjálfgefnar stillingarnar, þar sem gamlar stillingar geta yfirskrifað þær.

### Gott að vita

- Á M1- og M2-MacBook-tölvum skaltu vekja úr svefni með því að opna lokið eða ýta á aflhnappinn.
- Spurningar eða vandamál: spurðu í [Discord](https://discord.gg/tXFUdasqhY) okkar.

[README uppsetningarforritsins](https://github.com/omacom/omarchy-mac-installer#readme) fjallar um útgáfurásir, uppfærslu uppsetningarforritsins og að fjarlægja Omarchy.

## Intel Mac-tölvur

Í einfaldri prófun náðum við 36% afkastaaukningu á 2019 MacBook Pro bara með því að setja upp Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Að setja upp Omarchy á Mac

Omarchy styður aðeins að vera **eina** stýrikerfið uppsett í augnablikinu. Á meðan á uppsetningunni stendur verður drifið þurrkað út og MacOS verður ekki lengur ræsanlegt.

Þú getur samt endurheimt það síðar í gegnum Internet Recovery ef þú vilt.

Í þessum hluta gerum við ráð fyrir að þú hafir þegar skoðað [Getting Started](02-getting-started.md) og hafir USB-lykilinn þinn tilbúinn. Ef þú hefur ekki gert það skaltu gera það núna.

#### Slökkva á Secure Boot

Nauðsynlegt er að slökkva á Secure Boot frá Apple til að ræsa ræsanlega USB-lykilinn, sem og stýrikerfið. Til að slökkva á því skaltu gera eftirfarandi:

1. Slökktu á Mac-tölvunni þinni
2. Kveiktu á henni og ýttu _strax_ á Command-R og haltu inni þar til þú sérð hleðsluskjáinn birtast
3. Veldu notandann þinn og sláðu inn lykilorðið þitt ef beðið er um það
4. Þegar þú ert komin(n) á endurheimtarskjáinn skaltu velja **Utilities > Startup Security Utility** af valmyndastikunni
5. Sláðu inn lykilorðið þitt þegar beðið er um auðkenningu
6. Veldu "No Security" úr Secure Boot-valkostunum
7. Veldu "Allow booting from external or removable media" úr External Boot-valkostunum

#### Hefja uppsetninguna

1. Settu USB-lykilinn í
2. Endurræstu Mac-tölvuna þína og ýttu _strax_ á Option og haltu inni þar til þú sérð skjá með ræsitækjum
3. Veldu appelsínugula EFI Boot-tækið
4. Haltu áfram með [uppsetninguna eins og venjulega](02-getting-started.md)

Uppsetningarforritið greinir Mac-vélbúnað og beitir nauðsynlegum lagfæringum sjálfkrafa: Broadcom Wi-Fi-reklum og fastbúnaði, SPI-lyklaborðsreklinum á þeim MacBook-gerðum sem þurfa hann og NVMe-svefnlagfæringu fyrir sömu gerðir.

### Þekktar takmarkanir

Meðlimir samfélagsins vinna stöðugt að lausnum á þessum áskorunum, svo ef þær eru vandamál fyrir þig skaltu ganga í #omarchy-on-other í [Discord](https://discord.gg/tXFUdasqhY) okkar og sjá hvort til séu einhverjar uppfærðar aðferðir til að leysa þær.

#### Tæki með T1-kubb

Apple T1-kubburinn var kynntur seint á árinu 2016 og notaður eingöngu í fyrstu kynslóð MacBook Pro-gerða með Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Þekkt vandamál

- Touch Bar virkar ekki
- Hljóð virkar ekki

#### Tæki með T2-kubb

Apple T2 Security Chip var kynntur árið 2017. T2-kubbnum var hætt með skiptunum yfir í Apple silicon (M-series kubba) sem hófust árið 2020.

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

Á þessum gerðum setur uppsetningarforritið sjálfkrafa upp lagfærða `linux-t2`-kjarnann, T2-hljóðstillinguna, Broadcom Wi-Fi/Bluetooth-fastbúnað frá Apple og viftustýringu í gegnum `t2fanrd`. Touch Bar keyrir á innbyggðum Boot Camp-stíl stuðningi kjarnans.

#### iMac Retina 5K (2017)

27-inch iMac frá 2017 er ekki með T2-kubb, svo uppsetningarforritið setur hann upp eins og hinar Intel Mac-tölvurnar.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Þekkt vandamál

- Skjárinn keyrir ekki á innbyggðri 5120×2880 upplausn sinni: skjáborðið er tvær flísar og staðlaði rekillinn kveikir aðeins á annarri
- Hljóð virkar ekki
- Birtustýringin hefur engin áhrif
- Svefn hengir vélina; aðeins að slökkva og kveikja aftur bjargar henni

Samfélagslagfæring fyrir þessa gerð lagar skjáinn, hljóðið og birtuna: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
