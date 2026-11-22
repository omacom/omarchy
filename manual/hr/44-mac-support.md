# Podrška za Mac

## Omarchy za Apple Silicon

Omarchy za Apple Silicon službeno je Omacom rješenje, prvi put objavljeno s Omarchyjem 4.5. Instalira se uz macOS, a pri pokretanju Maca birate između njih dvoje.

Dobili ste obavijest o Omarchy Macu? Idite na [Prelazak s Omarchy Maca](#coming-from-omarchy-mac).

Radi na ovim Macovima:

| Mac | Čipovi |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Macovi s M4 i noviji još nisu podržani. Podrška za M4 testira se na kanalu edge i stiže sljedeća. Instalacijski program provjerava vaš Mac prije nego što bilo što promijeni.

Na bilo kojem Macu s Apple Siliconom, uključujući M4 i novije, Omarchy možete pokrenuti u virtualnom stroju pomoću [Try Omarchy](https://github.com/omacom/try-omarchy).

### Što vam treba

- macOS 15 Sequoia ili noviji i administratorski račun
- Slobodan prostor na disku za Omarchy. Instalacijski program predlaže veličinu i omogućuje vam da je promijenite.
- Sigurnosna kopija vašeg Maca, napajanje i internetska veza. Instalacija preuzima nekoliko gigabajta.

### Instalacija

Instalirate iz macOS-a. Instalirajte Omarchy Installer pomoću [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Ili preuzmite najnoviji Omarchy Installer s njegove [stranice izdanja](https://github.com/omacom/omarchy-mac-installer/releases) i otvorite ga.

Instalacijski program provjerava vaš Mac, pokazuje vam plan i oslobađa prostor za Omarchy smanjivanjem particije macOS-a. macOS ostaje na disku i nije potreban USB pogon. Kada prva faza završi, vodi vas kroz dovršetak postavljanja u macOS Recoveryju: isključite računalo, držite tipku za uključivanje dok se ne pojavi "Loading startup options", odaberite Omarchy i slijedite korake.

Pri prvom pokretanju Omarchy traži lozinku koja šifrira njegov disk. Nema ključa za oporavak: ako zaboravite lozinku, vaše Omarchy datoteke ne mogu se oporaviti.

Za kasnije prebacivanje između Omarchyja i macOS-a isključite računalo, zatim držite tipku za uključivanje dok se ne pojave mogućnosti pokretanja i odaberite jednu.

### Prelazak s Omarchy Maca

Omarchy Mac sada je dio Omarchyja za Apple Silicon i svaki Mac koji ga je pokretao je podržan. Vaša trenutna instalacija nastavlja raditi, a njezini se sistemski paketi i dalje ažuriraju, ali više ne dobiva Omarchy ažuriranja. Nema roka i nema nadogradnje na mjestu: napravite sigurnosnu kopiju, uklonite staru instalaciju, instalirate svježe i vratite podatke. Koraci od 2 do 5 odvijaju se u macOS-u, pa otvorite ovu stranicu na telefonu prije ponovnog pokretanja.

1. **Napravite sigurnosnu kopiju iz Omarchyja, izvan Maca.** Uklanjanje stare instalacije briše je, a macOS ne može čitati Omarchy disk. Kopirajte svoju početnu mapu na vanjski pogon ili drugo računalo, uključujući SSH i GPG ključeve, profile preglednika i rad koji nije poslan. Spremite popis paketa pomoću `pacman -Qqe > ~/packages.txt`. Napravite sigurnosnu kopiju i macOS-a jer uklanjanje i instaliranje mijenjaju veličinu njegova diska.
2. **Pokrenite Mac u macOS-u.** Isključite računalo, držite tipku za uključivanje dok se ne pojave mogućnosti pokretanja i odaberite macOS.
3. **Instalirajte Omarchy Installer** kako je prikazano u odjeljku [Instalacija](#installing).
4. **Uklonite staru instalaciju.** Otvorite Omarchy Installer i odaberite Installation > Remove Omarchy. Pokazuje što će izbrisati i vraća prostor macOS-u. Ako ne prepozna vašu instalaciju, zaustavlja se bez mijenjanja diska. Zatražite pomoć na [Discordu](https://discord.gg/tXFUdasqhY) umjesto da ručno brišete particije, što može izbrisati macOS.
5. **Instalirajte Omarchy za Apple Silicon** pomoću instalacijskog programa.
6. **Vratite svoje datoteke.** Vraćajte postavke dio po dio umjesto da kopirate cijeli `~/.config` preko novih zadanih postavki jer stare postavke mogu nadjačati nove.

### Dobro je znati

- Na MacBookovima M1 i M2 probudite računalo iz mirovanja otvaranjem poklopca ili pritiskom na tipku za uključivanje.
- Pitanja ili problemi: pitajte na našem [Discordu](https://discord.gg/tXFUdasqhY).

[README instalacijskog programa](https://github.com/omacom/omarchy-mac-installer#readme) obuhvaća kanale izdanja, ažuriranje instalacijskog programa i uklanjanje Omarchyja.

## Intel Macovi

U jednostavnom testu uspjeli smo postići 36% bolje performanse na MacBooku Pro iz 2019. samo instaliranjem Omarchyja.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instaliranje Omarchyja na Mac

Omarchy trenutačno podržava samo biti **jedini** instalirani OS. Tijekom instalacije pogon će biti izbrisan i MacOS se više neće moći pokrenuti.

Kasnije ga i dalje možete vratiti putem Internet Recoveryja ako želite.

Za ovaj dio pretpostavit ćemo da ste već pregledali [Početak rada](02-getting-started.md) i da vam je USB pogon spreman. Ako niste, učinite to sada.

#### Onemogućite Secure Boot

Potrebno je onemogućiti Appleov Secure Boot kako bi se mogao pokrenuti USB za pokretanje, kao i OS. Da biste ga onemogućili, učinite sljedeće:

1. Isključite Mac
2. Uključite ga i _odmah_ pritisnite i držite Command-R dok se ne pojavi zaslon za učitavanje
3. Odaberite svog korisnika i unesite lozinku ako se to od vas zatraži
4. Kad ste na zaslonu za oporavak, na traci izbornika odaberite **Utilities > Startup Security Utility**
5. Unesite lozinku kada se od vas zatraži autentifikacija
6. Odaberite "No Security" među mogućnostima za Secure Boot
7. Odaberite "Allow booting from external or removable media" među mogućnostima za External Boot

#### Pokrenite instalaciju

1. Umetnite USB pogon
2. Ponovno pokrenite Mac i _odmah_ pritisnite i držite Option dok se ne pojavi zaslon s uređajima za pokretanje
3. Odaberite narančasti uređaj EFI Boot
4. Nastavite s [instalacijom kao i obično](02-getting-started.md)

Instalacijski program prepoznaje Mac hardver i automatski primjenjuje potrebne popravke: upravljačke programe i firmware za Broadcom Wi-Fi, upravljački program za SPI tipkovnicu na modelima MacBooka kojima je potreban i popravak za NVMe suspendiranje za te iste modele.

### Poznata ograničenja

Članovi zajednice neprestano rade na rješenjima za ove izazove, pa ako vam to stvara probleme, pridružite se kanalu #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY) i provjerite postoje li ažurne metode za njihovo rješavanje.

#### Uređaji s čipom T1

Appleov čip T1 predstavljen je krajem 2016. i korišten je isključivo u modelima MacBook Pro prve generacije s Touch Barom.
- MacBook Pro 13-inch (2016, dva priključka Thunderbolt 3) – Model: A1706
- MacBook Pro 13-inch (2016, četiri priključka Thunderbolt 3) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Poznati problemi

- Touch Bar ne radi
- Zvuk ne radi

#### Uređaji s čipom T2

Apple T2 Security Chip predstavljen je 2017. Čip T2 ukinut je s prijelazom na Apple silicon (čipove serije M) počevši od 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, četiri priključka Thunderbolt 3) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, dva priključka Thunderbolt 3) – Model: A2159
- MacBook Pro 13-inch (2019, četiri priključka Thunderbolt 3) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, dva priključka Thunderbolt 3) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Na ovim modelima instalacijski program automatski postavlja zakrpani kernel `linux-t2`, T2 audio konfiguraciju, Appleov Broadcom Wi-Fi/Bluetooth firmware i upravljanje ventilatorom putem `t2fanrd`. Touch Bar radi na ugrađenoj podršci kernela u stilu Boot Campa.

#### iMac Retina 5K (2017)

27-inčni iMac iz 2017. nema čip T2, pa ga instalacijski program postavlja kao i ostale Intel Macove.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Poznati problemi

- Zaslon ne radi na izvornoj razlučivosti 5120×2880: panel čine dvije pločice, a standardni upravljački program osvjetljava samo jednu
- Zvuk ne radi
- Kontrola svjetline nema učinka
- Mirovanje zaglavi računalo; oporavlja ga samo isključivanje i ponovno uključivanje

Zakrpa zajednice za ovaj model popravlja zaslon, zvuk i svjetlinu: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
