# Podrška za Mac

Omarchy ima ugrađenu podršku za **Intel Mac računala**. Trenutačno postoji nekoliko poznatih ograničenja, ali sve dok ste ih svjesni i u redu s njima, svojim starim Mac računalima možete udahnuti novi život instalacijom Omarchyja.

Imajte na umu da instalacija na Mac s M-serijom trenutačno nije izravno podržana. Više o stanju toga možete saznati u #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY).

U jednostavnom testu uspjeli smo postići 36% dobitka performansi na MacBook Pro računalu iz 2019. samo instalacijom Omarchyja.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalacija Omarchyja na Mac

Omarchy trenutačno podržava samo da bude **jedini** instalirani OS. Tijekom instalacije pogon će biti obrisan i MacOS se više neće moći pokrenuti.

Kasnije ga i dalje možete vratiti putem Internet Recovery ako želite.

Radi ovog dijela, pretpostavit ćemo da ste već pregledali [Upute za početak](02-getting-started.md) i da vam je USB pogon spreman. Ako niste, učinite to sada.

#### Onemogućivanje Secure Boota

Potrebno je onemogućiti Appleov Secure Boot kako biste pokrenuli USB za pokretanje, kao i OS. Da biste ga onemogućili, učinite sljedeće:

1. Isključite svoj Mac
2. Uključite ga i _odmah_ pritisnite i držite Command-R dok ne ugledate zaslon za učitavanje
3. Odaberite svog korisnika i unesite lozinku ako se zatraži
4. Kad ste na zaslonu za oporavak, odaberite **Utilities > Startup Security Utility** iz trake izbornika
5. Unesite lozinku kad se zatraži autentifikacija
6. Odaberite „No Security“ iz opcija Secure Boot
7. Odaberite „Allow booting from external or removable media“ iz opcija External Boot

#### Pokretanje instalacije

1. Umetnite USB pogon
2. Ponovno pokrenite svoj Mac i _odmah_ pritisnite i držite Option dok ne ugledate zaslon s uređajima za pokretanje
3. Odaberite narančasti EFI Boot uređaj
4. Nastavite s [instalacijom kao i obično](02-getting-started.md)

Instalacijski program prepoznaje Mac hardver i automatski primjenjuje potrebne ispravke: Broadcom Wi-Fi upravljačke programe i firmver, SPI upravljački program tipkovnice na modelima MacBook koji ga trebaju i ispravak NVMe obustave za te iste modele.

### Poznata ograničenja

Članovi zajednice stalno rade na rješenjima ovih izazova, pa ako su vam oni problematični, pridružite se #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY) i provjerite postoje li ažurne metode za njihovo rješavanje.

#### Uređaji s T1 čipom

Apple T1 čip uveden je krajem 2016. i korišten isključivo u modelima MacBook Pro prve generacije s Touch Barom.
- MacBook Pro 13-inčni (2016., dva Thunderbolt 3 priključka) – Model: A1706
- MacBook Pro 13-inčni (2016., četiri Thunderbolt 3 priključka) – Model: A1708
- MacBook Pro 15-inčni (2016.) – Model: A1707

#### Poznati problemi

- Touch Bar ne radi
- Zvuk ne radi

#### Uređaji s T2 čipom

Apple T2 Security Chip uveden je 2017. T2 čip ukinut je prijelazom na Apple silicon (čipove M-serije) počevši od 2020.

- iMac Pro (2017.) – Model: A1862
- MacBook Pro 13-inčni (2018., četiri Thunderbolt 3 priključka) – Model: A1989
- MacBook Pro 15-inčni (2018.) – Model: A1990
- MacBook Air (Retina, 13-inčni, 2018.) – Model: A1932
- Mac mini (2018.) – Model: A1998
- MacBook Pro 13-inčni (2019., dva Thunderbolt 3 priključka) – Model: A2159
- MacBook Pro 13-inčni (2019., četiri Thunderbolt 3 priključka) – Model: A2178
- MacBook Pro 15-inčni (2019.) – Model: A1990
- iMac (Retina 5K, 27-inčni, 2020.) – Model: A2115 (iMac20,1 i iMac20,2)
- MacBook Pro 13-inčni (2020., dva Thunderbolt 3 priključka) – Model: A2265
- MacBook Pro 15-inčni (2020.) – Model: A1990

Na tim modelima instalacijski program automatski postavlja zakrpani `linux-t2` kernel, T2 audio konfiguraciju, Appleov Broadcom Wi-Fi/Bluetooth firmver i upravljanje ventilatorom putem `t2fanrd`. Touch Bar radi na kernelovoj ugrađenoj podršci u stilu Boot Campa.
