# Podpora za Mac

## Omarchy za Apple Silicon

Omarchy za Apple Silicon je uradna rešitev Omacom, prvič izdana z Omarchy 4.5. Namesti se poleg macOS, med njima pa izbirate ob zagonu vašega Maca.

Ste prejeli obvestilo o Omarchy Mac? Pojdite na [Prihod iz Omarchy Mac](#coming-from-omarchy-mac).

Deluje na teh Macih:

| Mac | Čipi |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Maci M4 in novejši še niso podprti. Podpora za M4 se testira na kanalu edge in prihaja naslednja. Namestitveni program preveri vaš Mac, preden karkoli spremeni.

Na kateremkoli Macu z Apple Silicon, vključno z M4 in novejšimi, lahko Omarchy poganjate v virtualni napravi z [Try Omarchy](https://github.com/omacom/try-omarchy).

### Kaj potrebujete

- macOS 15 Sequoia ali novejši in skrbniški račun
- Prostor na disku za Omarchy. Namestitveni program predlaga velikost in vam omogoča, da jo spremenite.
- Varnostno kopijo vašega Maca, napajanje in internetno povezavo. Namestitev prenese več gigabajtov.

### Namestitev

Nameščate iz macOS. Omarchy Installer namestite s [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Ali pa prenesite najnovejši Omarchy Installer z njegove [strani z izdajami](https://github.com/omacom/omarchy-mac-installer/releases) in ga odprite.

Namestitveni program preveri vaš Mac, vam pokaže načrt in naredi prostor za Omarchy tako, da skrči particijo macOS. macOS ostane na disku in pogon USB ni potreben. Ko je prva faza končana, vas vodi skozi dokončanje nastavitve v macOS Recovery: zaustavite sistem, držite gumb za vklop, dokler se ne prikaže "Loading startup options", izberite Omarchy in sledite korakom.

Ob prvem zagonu Omarchy zahteva geslo, ki šifrira njegov disk. Obnovitvenega ključa ni: če geslo pozabite, vaših datotek Omarchy ni mogoče obnoviti.

Za kasnejše preklapljanje med Omarchy in macOS zaustavite sistem, nato držite gumb za vklop, dokler se ne prikažejo možnosti zagona, in izberite eno.

### Prihod iz Omarchy Mac

Omarchy Mac je zdaj del Omarchy za Apple Silicon in vsi Maci, ki so ga poganjali, so podprti. Vaša trenutna namestitev še naprej deluje in njeni sistemski paketi se še vedno posodabljajo, vendar ne prejema več posodobitev Omarchy. Roka ni in nadgradnje na mestu ni: naredite varnostno kopijo, odstranite staro namestitev, namestite svežo in obnovite. Koraki od 2 do 5 potekajo v macOS, zato to stran odprite na telefonu, preden znova zaženete sistem.

1. **Varnostno kopirajte iz Omarchy, zunaj Maca.** Odstranitev stare namestitve jo izbriše, macOS pa ne more brati diska Omarchy. Kopirajte svojo domačo mapo na zunanji pogon ali drug računalnik, vključno s ključi SSH in GPG, profili brskalnika in delom, ki še ni bilo potisnjeno. Seznam paketov shranite z `pacman -Qqe > ~/packages.txt`. Varnostno kopirajte tudi macOS, saj odstranjevanje in nameščanje spremenita velikost njegovega diska.
2. **Zaženite svoj Mac v macOS.** Zaustavite sistem, držite gumb za vklop, dokler se ne prikažejo možnosti zagona, in izberite macOS.
3. **Namestite Omarchy Installer**, kot je prikazano v [Namestitev](#installing).
4. **Odstranite staro namestitev.** Odprite Omarchy Installer in izberite Installation > Remove Omarchy. Pokaže, kaj bo izbrisal, in vrne prostor macOS. Če vaše namestitve ne prepozna, se ustavi, ne da bi spremenil disk. Za pomoč prosite v [Discord](https://discord.gg/tXFUdasqhY), namesto da particije brišete ročno, kar lahko izbriše macOS.
5. **Namestite Omarchy za Apple Silicon** z namestitvenim programom.
6. **Obnovite svoje datoteke.** Nastavitve vračajte po delih, namesto da vse `~/.config` kopirate čez nove privzete vrednosti, saj jih lahko stare nastavitve prepišejo.

### Dobro je vedeti

- Na MacBookih M1 in M2 sistem iz spanja zbudite tako, da odprete pokrov ali pritisnete gumb za vklop.
- Vprašanja ali težave: vprašajte v našem [Discord](https://discord.gg/tXFUdasqhY).

[README namestitvenega programa](https://github.com/omacom/omarchy-mac-installer#readme) pokriva kanale izdaj, posodabljanje namestitvenega programa in odstranjevanje Omarchy.

## Maci z Intel

V preprostem testu smo samo z namestitvijo Omarchy na MacBook Pro iz leta 2019 dosegli 36 % boljšo zmogljivost.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Namestitev Omarchy na Mac

Omarchy trenutno podpira samo to, da je **edini** nameščeni OS. Med namestitvijo bo pogon izbrisan in MacOS ne bo več zagonski.

Če želite, ga lahko pozneje še vedno obnovite prek Internet Recovery.

Za ta del bomo predpostavili, da ste že pregledali [Getting Started](02-getting-started.md) in imate pripravljen pogon USB. Če ga niste, to storite zdaj.

#### Onemogočanje Secure Boot

Za zagon zagonskega USB-ja in OS je treba onemogočiti Applov Secure Boot. Če ga želite onemogočiti, storite naslednje:

1. Izklopite svoj Mac
2. Vklopite ga in _takoj_ pritisnite ter držite Command-R, dokler se ne prikaže zaslon za nalaganje
3. Izberite svojega uporabnika in vnesite geslo, če ste k temu pozvani
4. Ko ste na obnovitvenem zaslonu, v menijski vrstici izberite **Utilities > Startup Security Utility**
5. Vnesite geslo, ko ste pozvani k preverjanju pristnosti
6. Med možnostmi Secure Boot izberite "No Security"
7. Med možnostmi External Boot izberite "Allow booting from external or removable media"

#### Začetek namestitve

1. Vstavite pogon USB
2. Znova zaženite svoj Mac in _takoj_ pritisnite ter držite Option, dokler se ne prikaže zaslon z zagonskimi napravami
3. Izberite oranžno napravo EFI Boot
4. Nadaljujte z [običajno namestitvijo](02-getting-started.md)

Namestitveni program zazna strojno opremo Mac in samodejno uporabi potrebne popravke: gonilnike in vdelano programsko opremo za Broadcom Wi-Fi, gonilnik kamere FaceTime HD na napravah z Broadcom 1570 (njena vdelana programska oprema se prenese od Apple, ko je Mac na spletu, saj namestitveni program deluje brez povezave), gonilnik tipkovnice SPI na modelih MacBook, ki ga potrebujejo, in popravek za mirovanje NVMe za te iste modele.

### Znane omejitve

Člani skupnosti nenehno delajo na rešitvah za te izzive, zato se, če so za vas težavni, pridružite #omarchy-on-other v našem [Discord](https://discord.gg/tXFUdasqhY) in preverite, ali obstajajo kakšne posodobljene metode za njihovo reševanje.

#### FaceTime HD Camera

Gonilnik kamere zamrzne napravo, če je naložen, ko Mac preide v hibernacijo, zato se najprej razloži. Ni ga mogoče razložiti, medtem ko ima aplikacija odprto kamero, zato je hibernacija preklicana z obvestilom, ki poimenuje aplikacijo: zaprite jo in znova preidite v hibernacijo. To vključuje samodejno hibernacijo pri kritični ravni baterije in suspend-then-hibernate, ki je zavrnjena, preden preide v mirovanje. Običajno mirovanje sam gonilnik zavrne, medtem ko je kamera odprta, brez obvestila.

Vdelana programska oprema kamere se prenese od Apple, zato kamera deluje šele, ko je bil Mac na spletu. Prenos se začne ob zagonu in se ponovi vsakih 15 minut, dokler je težava omrežje; če se je Applova datoteka spremenila, se ustavi in čaka na posodobitev Omarchy. Če se kamera ne prikaže, `journalctl -u facetimehd-firmware-fetcher` pove, zakaj, `sudo systemctl restart facetimehd-firmware-fetcher` poskusi znova, ponovni zagon pa naloži gonilnik, če se je prenos končal, kamera pa še vedno ni na voljo.

#### Naprave s čipom T1

Čip Apple T1 je bil predstavljen konec leta 2016 in uporabljen izključno v modelih MacBook Pro prve generacije s Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Znane težave

- Touch Bar ne deluje
- Zvok ne deluje

#### Naprave s čipom T2

Varnostni čip Apple T2 je bil predstavljen leta 2017. Čip T2 je bil opuščen s prehodom na Apple silicon (čipe serije M), ki se je začel leta 2020.

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

Na teh modelih namestitveni program samodejno nastavi popravljeno jedro `linux-t2`, zvočno konfiguracijo T2, Applovo vdelano programsko opremo Broadcom Wi-Fi/Bluetooth in nadzor ventilatorja prek `t2fanrd`. Touch Bar deluje na vgrajeni podpori jedra v slogu Boot Camp.

#### iMac Retina 5K (2017)

27-inch iMac iz leta 2017 nima čipa T2, zato ga namestitveni program nastavi kot druge Mace z Intel.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Znane težave

- Zaslon ne deluje pri izvorni ločljivosti 5120×2880: plošča je iz dveh ploščic in standardni gonilnik osvetli samo eno
- Zvok ne deluje
- Nadzor svetlosti nima učinka
- Spanje zamrzne napravo; obnovi jo samo izklop in ponovni vklop

Popravljalnik skupnosti za ta model odpravi težave z zaslonom, zvokom in svetlostjo: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
