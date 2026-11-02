# Podpora za Mac

Omarchy ima vgrajeno podporo za **računalnike Intel Mac**. Trenutno obstaja nekaj znanih omejitev, a dokler se jih zavedate in so vam sprejemljive, lahko svojim starim računalnikom Mac vdihnete novo življenje z nalaganjem Omarchyja.

Upoštevajte, da namestitev na računalnik Mac serije M trenutno ni neposredno podprta. Več o stanju tega lahko izveste v #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY).

V preprostem preizkusu nam je uspelo doseči 36-% povečanje zmogljivosti na MacBook Pro iz leta 2019 zgolj z namestitvijo Omarchyja.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Namestitev Omarchyja na Mac

Omarchy trenutno podpira samo to, da je **edini** nameščeni OS. Med namestitvijo bo pogon izbrisan in MacOS ne bo več mogoče zagnati.

Pozneje ga lahko še vedno obnovite prek Internet Recovery, če želite.

Za ta del bomo predpostavili, da ste že pregledali [Hitri začetek](02-getting-started.md) in imate pripravljen pogon USB. Če ne, to storite zdaj.

#### Onemogoči Secure Boot

Secure Boot podjetja Apple je treba onemogočiti, da lahko zaženete zagonski USB in OS. Če ga želite onemogočiti, storite naslednje:

1. Izklopite svoj Mac
2. Vklopite ga in _takoj_ pritisnite in držite Command-R, dokler se ne prikaže zaslon za nalaganje
3. Izberite svojega uporabnika in po pozivu vnesite geslo
4. Ko ste na zaslonu za obnovitev, v menijski vrstici izberite **Utilities > Startup Security Utility**
5. Vnesite geslo, ko vas sistem pozove k preverjanju pristnosti
6. Med možnostmi Secure Boot izberite "No Security"
7. Med možnostmi External Boot izberite "Allow booting from external or removable media"

#### Začni namestitev

1. Vstavite pogon USB
2. Znova zaženite svoj Mac in _takoj_ pritisnite in držite Option, dokler ne vidite zaslona zagonskih naprav
3. Izberite oranžno napravo EFI Boot
4. Nadaljujte z [namestitvijo kot običajno](02-getting-started.md)

Namestitveni program zazna strojno opremo Mac in samodejno uporabi potrebne popravke: gonilnike in strojno programsko opremo Broadcom Wi-Fi, gonilnik tipkovnice SPI na modelih MacBook, ki ga potrebujejo, in popravek Spanja NVMe za iste modele.

### Znane omejitve

Člani skupnosti nenehno delajo na rešitvah za te izzive, tako da če so ti za vas problematični, se pridružite #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY) in preverite, ali obstajajo kakšne najnovejše metode za njihovo reševanje.

#### Naprave s čipom T1

Čip Apple T1 je bil uveden konec leta 2016 in uporabljen izključno v modelih MacBook Pro prve generacije s Touch Barom.
- MacBook Pro 13-palčni (2016, dva Thunderbolt 3 vhoda) – Model: A1706
- MacBook Pro 13-palčni (2016, štirje Thunderbolt 3 vhodi) – Model: A1708
- MacBook Pro 15-palčni (2016) – Model: A1707

#### Znane težave

- Touch Bar ne deluje
- Zvok ne deluje

#### Naprave s čipom T2

Varnostni čip Apple T2 je bil uveden leta 2017. Čip T2 je bil ukinjen s prehodom na Apple silicon (čipi serije M), ki se je začel leta 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-palčni (2018, štirje Thunderbolt 3 vhodi) – Model: A1989
- MacBook Pro 15-palčni (2018) – Model: A1990
- MacBook Air (Retina, 13-palčni, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-palčni (2019, dva Thunderbolt 3 vhoda) – Model: A2159
- MacBook Pro 13-palčni (2019, štirje Thunderbolt 3 vhodi) – Model: A2178
- MacBook Pro 15-palčni (2019) – Model: A1990
- iMac (Retina 5K, 27-palčni, 2020) – Model: A2115 (iMac20,1 in iMac20,2)
- MacBook Pro 13-palčni (2020, dva Thunderbolt 3 vhoda) – Model: A2265
- MacBook Pro 15-palčni (2020) – Model: A1990

Na teh modelih namestitveni program samodejno nastavi popravljeno jedro `linux-t2`, konfiguracijo zvoka T2, strojno programsko opremo Apple Broadcom Wi-Fi/Bluetooth in nadzor ventilatorja prek `t2fanrd`. Touch Bar deluje na vgrajeni podpori jedra v slogu Boot Camp.
