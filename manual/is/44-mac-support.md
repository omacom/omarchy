# Stuðningur við Mac

## Omarchy fyrir Apple Silicon

Omarchy fyrir Apple Silicon er opinber Omacom-lausn, fyrst gefin út með Omarchy 4.5. Það setur upp við hliðina á macOS, og þú velur á milli þeirra tveggja þegar Mac-tölvan þín ræsir.

Fékkstu tilkynningu um Omarchy Mac? Farðu á [Að koma frá Omarchy Mac](#coming-from-omarchy-mac).

Það keyrir á þessum Mac-tölvum:

| Mac | Kubbar |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 og nýrri Mac-tölvur eru ekki studdar ennþá. Stuðningur við M4 er í prófunum á edge-rásinni og kemur næst. Uppsetningarforritið athugar Mac-tölvuna þína áður en það breytir nokkru.

Á hvaða Apple Silicon Mac sem er, þar á meðal M4 og nýrri, geturðu keyrt Omarchy í sýndarvél með [Try Omarchy](https://github.com/omacom/try-omarchy).

### Hvað þú þarft

- macOS 15 Sequoia eða nýrra, og stjórnandareikning
- Laust diskpláss fyrir Omarchy. Uppsetningarforritið leggur til stærð og leyfir þér að breyta henni.
- Afrit af Mac-tölvunni þinni, rafmagn og nettenging. Uppsetningin sækir nokkur gígabæt.

### Uppsetning

Þú setur upp frá macOS. Settu upp Omarchy Installer með [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Eða sæktu nýjasta Omarchy Installer af [útgáfusíðu](https://github.com/omacom/omarchy-mac-installer/releases) þess og opnaðu það.

Uppsetningarforritið athugar Mac-tölvuna þína, sýnir þér áætlunina og býr til pláss fyrir Omarchy með því að minnka macOS-skiptinguna. macOS verður áfram á diskinum og enginn USB-lykill þarf. Þegar fyrsta stiginu er lokið leiðir það þig í gegnum að klára uppsetninguna í macOS Recovery: slökktu á tölvunni, haltu aflrofanum inni þar til "Loading startup options" birtist, veldu Omarchy og fylgdu skrefunum.

Við fyrstu ræsingu biður Omarchy um lykilorð sem dulkóðar diskinn þess. Það er enginn endurheimtarlykill: ef þú gleymir lykilorðinu er ekki hægt að endurheimta Omarchy-skrárnar þínar.

Til að skipta á milli Omarchy og macOS síðar skaltu slökkva á tölvunni, halda síðan aflrofanum inni þar til ræsivalkostirnir birtast og velja annan hvorn.

### Að koma frá Omarchy Mac

Omarchy Mac er nú hluti af Omarchy fyrir Apple Silicon, og sérhver Mac sem keyrði það er studdur. Núverandi uppsetningin þín heldur áfram að keyra, og kerfispakkarnir hennar uppfærast áfram, en hún fær engar fleiri Omarchy-uppfærslur. Það er enginn frestur og engin uppfærsla á staðnum: þú tekur afrit, fjarlægir gömlu uppsetninguna, setur upp upp á nýtt og endurheimtir. Skref 2 til 5 gerast í macOS, svo opnaðu þessa síðu í símanum þínum áður en þú endurræsir.

1. **Taktu afrit úr Omarchy, af Mac-tölvunni.** Að fjarlægja gömlu uppsetninguna þurrkar hana út, og macOS getur ekki lesið Omarchy-diskinn. Afritaðu heimamöppuna þína á ytri drif eða aðra tölvu, þar á meðal SSH- og GPG-lykla, vafrasnið og vinnu sem ekki er búið að ýta upp. Vistaðu pakkalistann þinn með `pacman -Qqe > ~/packages.txt`. Taktu líka afrit af macOS, þar sem bæði að fjarlægja og setja upp breyta stærð disksins þess.
2. **Ræstu Mac-tölvuna þína í macOS.** Slökktu á tölvunni, haltu aflrofanum inni þar til ræsivalkostirnir birtast, og veldu macOS.
3. **Settu upp Omarchy Installer** eins og sýnt er í [Uppsetning](#installing).
4. **Fjarlægðu gömlu uppsetninguna.** Opnaðu Omarchy Installer og veldu Installation > Remove Omarchy. Það sýnir hvað það mun eyða og skilar plássinu til macOS. Ef það þekkir ekki uppsetninguna þína hættir það án þess að breyta diskinum. Biddu um hjálp á [Discord](https://discord.gg/tXFUdasqhY) frekar en að eyða skiptingum handvirkt, sem getur þurrkað út macOS.
5. **Settu upp Omarchy fyrir Apple Silicon** með uppsetningarforritinu.
6. **Endurheimtu skrárnar þínar.** Komdu stillingunum þínum til baka smátt og smátt frekar en að afrita allt `~/.config` yfir nýju sjálfgefnar stillingarnar, þar sem gamlar stillingar geta hnekkt þeim.

### Gott að vita

- Á M1 og M2 MacBook-tölvum skaltu vakna úr svefni með því að opna lokið eða ýta á aflrofann.
- Spurningar eða vandamál: spurðu á [Discord](https://discord.gg/tXFUdasqhY) okkar.

[README uppsetningarforritsins](https://github.com/omacom/omarchy-mac-installer#readme) fjallar um útgáfurásir, að uppfæra uppsetningarforritið og að fjarlægja Omarchy.

## Intel Mac-tölvur

Í einfaldri prófun náðum við 36% afkastabót á 2019 MacBook Pro bara með því að setja upp Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Uppsetning Omarchy á Mac

Omarchy styður í augnablikinu aðeins að vera eina stýrikerfið sem er uppsett. Meðan á uppsetningunni stendur verður drifið þurrkað út og MacOS verður ekki lengur ræsanlegt.

Þú getur samt endurheimt það síðar í gegnum Internet Recovery ef þú vilt.

Í þessum hluta gerum við ráð fyrir að þú hafir þegar skoðað [Komast af stað](02-getting-started.md) og hafir USB-lykilinn þinn tilbúinn. Ef þú hefur ekki gert það skaltu gera það núna.

#### Slökkva á Secure Boot

Nauðsynlegt er að slökkva á Secure Boot frá Apple til að geta ræst af ræsanlega USB-lyklinum, sem og stýrikerfið. Til að slökkva á því skaltu gera eftirfarandi:

1. Slökktu á Mac-tölvunni þinni
2. Kveiktu á henni og ýttu _strax_ á og haltu inni Command-R þar til þú sérð hleðsluskjáinn birtast
3. Veldu notandann þinn og sláðu inn lykilorðið þitt ef beðið er um það
4. Þegar þú ert á endurheimtarskjánum skaltu velja **Utilities > Startup Security Utility** úr valmyndastikunni
5. Sláðu inn lykilorðið þitt þegar beðið er um auðkenningu
6. Veldu "No Security" úr Secure Boot-valkostunum
7. Veldu "Allow booting from external or removable media" úr External Boot-valkostunum

#### Byrja uppsetninguna

1. Settu USB-lykilinn í
2. Endurræstu Mac-tölvuna þína og ýttu _strax_ á og haltu inni Option þar til þú sérð skjá með ræsitækjum
3. Veldu appelsínugula EFI Boot-tækið
4. Haltu áfram með [uppsetninguna eins og venjulega](02-getting-started.md)

Uppsetningarforritið finnur Mac-vélbúnað og beitir nauðsynlegum lagfæringum sjálfkrafa: Broadcom Wi-Fi-reklum og fastbúnaði, FaceTime HD-myndavélarekli á vélum með Broadcom 1570 (fastbúnaður hans er sóttur frá Apple þegar Mac-tölvan er komin á netið, þar sem uppsetningarforritið virkar án nettengingar), SPI-lyklaborðsrekli á þeim MacBook-gerðum sem þurfa hann, og NVMe-svefnlagfæringu fyrir sömu gerðir.

### Þekktar takmarkanir

Meðlimir samfélagsins vinna stöðugt að lausnum á þessum áskorunum, svo ef þetta veldur þér vandræðum skaltu koma á #omarchy-on-other á [Discord](https://discord.gg/tXFUdasqhY) okkar og sjá hvort til séu einhverjar nýjustu aðferðir til að leysa þetta.

#### FaceTime HD Camera

Myndavélarekullinn hengir vélina ef hann er hlaðinn þegar Mac-tölvan fer í dvala, svo honum er aflað fyrst. Ekki er hægt að afla honum á meðan forrit hefur myndavélina opna, svo dvalanum er aflýst með tilkynningu sem nefnir forritið: lokaðu því og farðu aftur í dvala. Það á einnig við um að fara sjálfkrafa í dvala við hættulega lága rafhlöðu, og svefn-síðan-dvala, sem er hafnað áður en vélin fer í svefn. Venjulegum svefni er hafnað af reklinum sjálfum á meðan myndavélin er opin, án tilkynningar.

Fastbúnaður myndavélarinnar er sóttur frá Apple, svo myndavélin virkar aðeins þegar Mac-tölvan hefur verið á netinu. Niðurhalið byrjar við ræsingu og er reynt aftur á 15 mínútna fresti á meðan netið er vandamálið; ef skrá Apple hefur breyst hættir það og bíður eftir Omarchy-uppfærslu. Ef myndavélin birtist ekki segir `journalctl -u facetimehd-firmware-fetcher` af hverju, `sudo systemctl restart facetimehd-firmware-fetcher` reynir aftur, og endurræsing hleður reklinum ef niðurhalinu lauk en myndavélin er samt ekki þar.

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

Á þessum gerðum setur uppsetningarforritið sjálfkrafa upp lagfærða `linux-t2` kjarnann, T2-hljóðstillinguna, Broadcom Wi-Fi/Bluetooth-fastbúnað frá Apple, og viftustýringu í gegnum `t2fanrd`. Touch Bar keyrir á innbyggðum Boot Camp-stíl stuðningi kjarnans.

#### iMac Retina 5K (2017)

27 tommu iMac frá 2017 er ekki með T2-kubb, svo uppsetningarforritið setur hann upp eins og aðrar Intel Mac-tölvur.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Þekkt vandamál

- Skjárinn keyrir ekki á innfæddu 5120×2880 upplausninni sinni: skjárinn er tvær flísar, og staðlaði rekullinn lýsir aðeins aðra
- Hljóð virkar ekki
- Birtustigsstýringin hefur engin áhrif
- Svefn hengir vélina; aðeins að slökkva og kveikja aftur bjargar henni

Samfélagslagfæring fyrir þessa gerð lagar skjáinn, hljóðið og birtustigið: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
