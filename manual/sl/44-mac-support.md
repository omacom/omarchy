# Podpora za Mac

## Omarchy za Apple Silicon

Omarchy za Apple Silicon je uradna rešitev Omacom, prvič izdana z Omarchy 4.5. Namesti se poleg macOS, med njima pa izberete ob zagonu vašega Maca.

Ste prejeli obvestilo o Omarchy Mac? Pojdite na [Prihajate z Omarchy Mac](#coming-from-omarchy-mac).

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

Maci M4 in novejši še niso podprti. Podpora za M4 se testira na kanalu edge in prihaja naslednja. Namestitveni program preveri vaš Mac, preden kar koli spremeni.

Na katerem koli Macu z Apple Silicon, vključno z M4 in novejšimi, lahko Omarchy zaženete v navideznem stroju s [Try Omarchy](https://github.com/omacom/try-omarchy).

### Kaj potrebujete

- macOS 15 Sequoia ali novejši in skrbniški račun
- Prost prostor na disku za Omarchy. Namestitveni program predlaga velikost in vam omogoča, da jo spremenite.
- Varnostno kopijo vašega Maca, napajanje in internetno povezavo. Namestitev prenese več gigabajtov.

### Namestitev

Nameščate iz macOS. Omarchy Installer namestite s [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Ali prenesite najnovejši Omarchy Installer z njegove [strani z izdajami](https://github.com/omacom/omarchy-mac-installer/releases) in ga odprite.

Namestitveni program preveri vaš Mac, vam pokaže načrt in naredi prostor za Omarchy tako, da skrči particijo macOS. macOS ostane na disku in pogon USB ni potreben. Ko je prva faza končana, vas vodi skozi dokončanje nastavitve v macOS Recovery: izklopite, držite gumb za vklop, dokler se ne prikaže "Loading startup options", izberite Omarchy in sledite korakom.

Ob prvem zagonu Omarchy zahteva geslo, ki šifrira njegov disk. Obnovitvenega ključa ni: če geslo pozabite, vaših datotek Omarchy ni mogoče obnoviti.

Za poznejši preklop med Omarchy in macOS izklopite, nato držite gumb za vklop, dokler se ne prikažejo možnosti zagona, in izberite eno.

### Prihajate z Omarchy Mac

Omarchy Mac je zdaj del Omarchy za Apple Silicon in vsak Mac, ki ga je poganjal, je podprt. Vaša trenutna namestitev še naprej deluje in njeni sistemski paketi se še vedno posodabljajo, vendar ne prejema več posodobitev Omarchy. Roka ni in nadgradnje na mestu ni: naredite varnostno kopijo, odstranite staro namestitev, namestite na novo in obnovite. Koraki od 2 do 5 potekajo v macOS, zato odprite to stran na telefonu, preden znova zaženete.

1. **Naredite varnostno kopijo iz Omarchy, zunaj Maca.** Odstranitev stare namestitve jo izbriše, macOS pa ne more brati diska Omarchy. Kopirajte svojo domačo mapo na zunanji pogon ali drug računalnik, vključno s ključi SSH in GPG, profili brskalnika in delom, ki ga še niste potisnili. Seznam paketov shranite z `pacman -Qqe > ~/packages.txt`. Naredite varnostno kopijo tudi macOS, saj odstranjevanje in nameščanje oboje spremenita velikost njegovega diska.
2. **Zaženite svoj Mac v macOS.** Izklopite, držite gumb za vklop, dokler se ne prikažejo možnosti zagona, in izberite macOS.
3. **Namestite Omarchy Installer**, kot je prikazano v [Namestitev](#installing).
4. **Odstranite staro namestitev.** Odprite Omarchy Installer in izberite Installation > Remove Omarchy. Pokaže, kaj bo izbrisal, in vrne prostor macOS. Če vaše namestitve ne prepozna, se ustavi, ne da bi spremenil disk. Za pomoč zaprosite v [Discord](https://discord.gg/tXFUdasqhY), namesto da particije brišete ročno, kar lahko izbriše macOS.
5. **Namestite Omarchy za Apple Silicon** z namestitvenim programom.
6. **Obnovite svoje datoteke.** Nastavitve vračajte po koščkih, namesto da vse iz `~/.config` kopirate čez nove privzete vrednosti, saj jih stare nastavitve lahko prepišejo.

### Dobro je vedeti

- Pri MacBookih z M1 in M2 prebudite iz spanja tako, da odprete pokrov ali pritisnete gumb za vklop.
- Vprašanja ali težave: vprašajte v našem [Discord](https://discord.gg/tXFUdasqhY).

[README namestitvenega programa](https://github.com/omacom/omarchy-mac-installer#readme) pokriva kanale izdaj, posodabljanje namestitvenega programa in odstranjevanje Omarchy.

## Maci z Intel

V preprostem testu nam je samo z namestitvijo Omarchy uspelo doseči 36% boljšo zmogljivost na MacBook Pro iz leta 2019.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Nameščanje Omarchy na Mac

Omarchy trenutno podpira samo to, da je **edini** nameščeni OS. Med namestitvijo bo pogon izbrisan in MacOS ne bo več mogoče zagnati.

Če želite, ga lahko pozneje še vedno obnovite prek Internet Recovery.

Za ta del bomo predpostavili, da ste že pregledali [Začetek](02-getting-started.md) in imate pripravljen pogon USB. Če ga nimate, pojdite in to storite zdaj.

#### Onemogočite Secure Boot

Secure Boot podjetja Apple je treba onemogočiti, da lahko zaženete zagonski USB in tudi OS. Če ga želite onemogočiti, naredite naslednje:

1. Izklopite svoj Mac
2. Vklopite ga in _takoj_ pritisnite in držite Command-R, dokler se ne prikaže zaslon za nalaganje
3. Izberite svojega uporabnika in vnesite geslo, če ste pozvani
4. Ko ste na zaslonu za obnovitev, v menijski vrstici izberite **Utilities > Startup Security Utility**
5. Vnesite geslo, ko ste pozvani k preverjanju pristnosti
6. Med možnostmi Secure Boot izberite "No Security"
7. Med možnostmi External Boot izberite "Allow booting from external or removable media"

#### Začnite namestitev

1. Vstavite pogon USB
2. Znova zaženite svoj Mac in _takoj_ pritisnite in držite Option, dokler se ne prikaže zaslon z zagonskimi napravami
3. Izberite oranžno napravo EFI Boot
4. Nadaljujte z [namestitvijo kot običajno](02-getting-started.md)

Namestitveni program zazna strojno opremo Mac in samodejno uporabi potrebne popravke: gonilnike in vdelano programsko opremo za Broadcom Wi-Fi, gonilnik tipkovnice SPI na modelih MacBook, ki ga potrebujejo, in popravek za prekinitev NVMe za te iste modele.

### Znane omejitve

Člani skupnosti nenehno delajo na rešitvah za te izzive, zato se, če so ti za vas problematični, pridružite #omarchy-on-other v našem [Discord](https://discord.gg/tXFUdasqhY) in preverite, ali obstajajo kakšne posodobljene metode za njihovo reševanje.

#### Naprave s čipom T1

Čip Apple T1 je bil predstavljen konec leta 2016 in uporabljen izključno v modelih MacBook Pro prve generacije s Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Znane težave

- Touch Bar ne deluje
- Zvok ne deluje

#### Naprave s čipom T2

Čip Apple T2 Security Chip je bil predstavljen leta 2017. Čip T2 je bil ukinjen s prehodom na Apple silicon (čipe serije M), ki se je začel leta 2020.

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

Pri teh modelih namestitveni program samodejno nastavi popravljeno jedro `linux-t2`, konfiguracijo zvoka T2, vdelano programsko opremo Broadcom Wi-Fi/Bluetooth podjetja Apple in nadzor ventilatorja prek `t2fanrd`. Touch Bar deluje na vgrajeni podpori jedra v slogu Boot Camp.

#### iMac Retina 5K (2017)

27-inch iMac iz leta 2017 nima čipa T2, zato ga namestitveni program nastavi kot druge Mace z Intel.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Znane težave

- Zaslon ne deluje pri svoji izvorni ločljivosti 5120×2880: plošča je iz dveh ploščic in privzeti gonilnik osvetli samo eno
- Zvok ne deluje
- Nadzor svetlosti nima učinka
- Spanje zaustavi stroj; obnovi ga samo izklop in ponovni vklop

Popravljalnik skupnosti za ta model odpravi zaslon, zvok in svetlost: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
