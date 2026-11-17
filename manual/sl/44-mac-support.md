# Podpora za Mac

Omarchy ima vgrajeno podporo za **Intel Macs**. Trenutno obstaja nekaj znanih omejitev, a dokler se jih zavedate in so vam sprejemljive, lahko z namestitvijo Omarchy svojim starim Macom vdihnete novo življenje.

Upoštevajte, da namestitev na Mac s čipi M-serije trenutno ni neposredno podprta. Več o tem, v kakšnem stanju je to, lahko izveste v #omarchy-on-other v našem [Discord](https://discord.gg/tXFUdasqhY).

V preprostem testu nam je uspelo na MacBook Pro iz leta 2019 doseči 36 % izboljšanje zmogljivosti zgolj z namestitvijo Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Nameščanje Omarchy na Mac

Omarchy trenutno podpira le namestitev kot **edini** OS. Med namestitvijo bo pogon izbrisan in MacOS ne bo več mogoče zagnati.

Če želite, ga lahko pozneje še vedno obnovite prek Internet Recovery.

Za ta del bomo predpostavili, da ste že pregledali [Začetek](02-getting-started.md) in imate pripravljen pogon USB. Če ga še nimate, to storite zdaj.

#### Onemogočanje Secure Boot

Za zagon s pogona USB in OS je treba onemogočiti Applov Secure Boot. Da ga onemogočite, naredite naslednje:

1. Izklopite svoj Mac
2. Vklopite ga in _takoj_ pritisnite in držite Command-R, dokler se ne prikaže zaslon za nalaganje
3. Izberite svojega uporabnika in ob pozivu vnesite geslo
4. Ko ste na zaslonu za obnovitev, v menijski vrstici izberite **Utilities > Startup Security Utility**
5. Ob pozivu za preverjanje pristnosti vnesite geslo
6. Med možnostmi Secure Boot izberite "No Security"
7. Med možnostmi External Boot izberite "Allow booting from external or removable media"

#### Začetek namestitve

1. Vstavite pogon USB
2. Znova zaženite Mac in _takoj_ pritisnite in držite Option, dokler se ne prikaže zaslon z zagonskimi napravami
3. Izberite oranžno napravo EFI Boot
4. Nadaljujte z [namestitvijo kot običajno](02-getting-started.md)

Namestitveni program zazna strojno opremo Mac in samodejno uporabi potrebne popravke: gonilnike in vdelano programsko opremo za Broadcom Wi-Fi, gonilnik tipkovnice SPI na modelih MacBook, ki ga potrebujejo, in popravek za mirovanje NVMe za iste modele.

### Znane omejitve

Člani skupnosti nenehno delajo na rešitvah za te izzive, zato se, če so ti za vas problematični, pridružite #omarchy-on-other v našem [Discord](https://discord.gg/tXFUdasqhY) in preverite, ali obstajajo kakšne posodobljene metode za njihovo reševanje.

#### Naprave s čipom T1

Čip Apple T1 je bil predstavljen konec leta 2016 in se je uporabljal izključno v modelih MacBook Pro prve generacije s Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Znane težave

- Touch Bar ne deluje
- Zvok ne deluje

#### Naprave s čipom T2

Varnostni čip Apple T2 je bil predstavljen leta 2017. Čip T2 je bil ukinjen s prehodom na Apple silicon (čipi M-serije), ki se je začel leta 2020.

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

Na teh modelih namestitveni program samodejno nastavi popravljeno jedro `linux-t2`, konfiguracijo zvoka T2, Applovo vdelano programsko opremo Broadcom Wi-Fi/Bluetooth in nadzor ventilatorja prek `t2fanrd`. Touch Bar deluje na vgrajeni podpori jedra v slogu Boot Camp.

#### iMac Retina 5K (2017)

27-inch iMac iz leta 2017 nima čipa T2, zato ga namestitveni program nastavi kot druge Intel Macs.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Znane težave

- Zaslon ne deluje pri svoji izvorni ločljivosti 5120×2880: plošča je sestavljena iz dveh ploščic in standardni gonilnik osvetli le eno
- Zvok ne deluje
- Nadzor svetlosti nima učinka
- Spanje povzroči zamrznitev naprave; obnovi jo le izklop in ponovni vklop

Skupnostni popravljalnik za ta model popravi zaslon, zvok in svetlost: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
