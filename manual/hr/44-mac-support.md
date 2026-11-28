# Podrška za Mac

## Omarchy za Apple Silicon

Omarchy za Apple Silicon službeno je rješenje tvrtke Omacom, prvi put objavljeno s verzijom Omarchy 4.5. Instalira se uz macOS, a prilikom pokretanja Maca birate između ta dva sustava.

Dobili ste obavijest o Omarchy Macu? Idite na [Dolazak s Omarchy Maca](#coming-from-omarchy-mac).

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

Macovi s čipom M4 i noviji još nisu podržani. Podrška za M4 testira se na kanalu edge i stiže sljedeća. Alat za instalaciju provjerava vaš Mac prije nego što išta promijeni.

Na bilo kojem Macu s čipom Apple Silicon, uključujući M4 i novije, Omarchy možete pokrenuti u virtualnom stroju pomoću alata [Try Omarchy](https://github.com/omacom/try-omarchy).

### Što vam je potrebno

- macOS 15 Sequoia ili noviji i administratorski račun
- Slobodan prostor na disku za Omarchy. Alat za instalaciju predlaže veličinu i dopušta vam da je promijenite.
- Sigurnosna kopija vašeg Maca, napajanje i internetska veza. Instalacija preuzima nekoliko gigabajta.

### Instalacija

Instalirate iz macOS-a. Instalirajte Omarchy Installer pomoću alata [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Ili preuzmite najnoviji Omarchy Installer s njegove [stranice s izdanjima](https://github.com/omacom/omarchy-mac-installer/releases) i otvorite ga.

Alat za instalaciju provjerava vaš Mac, pokazuje vam plan i oslobađa prostor za Omarchy smanjivanjem particije sustava macOS. macOS ostaje na disku i nije potreban USB pogon. Kada prva faza završi, vodi vas kroz završetak postavljanja u sustavu macOS Recovery: isključite računalo, držite gumb za uključivanje dok se ne pojavi "Učitavanje opcija pokretanja", odaberite Omarchy i slijedite korake.

Pri prvom pokretanju Omarchy traži lozinku kojom šifrira svoj disk. Nema ključa za oporavak: ako zaboravite lozinku, vaše datoteke u Omarchyju ne mogu se oporaviti.

Za prebacivanje između Omarchyja i macOS-a kasnije, isključite računalo, zatim držite gumb za uključivanje dok se ne pojave opcije pokretanja i odaberite jedan sustav.

### Dolazak s Omarchy Maca

Omarchy Mac sada je dio Omarchyja za Apple Silicon i svaki Mac koji ga je pokretao je podržan. Vaša trenutačna instalacija nastavlja raditi, a njezini se sistemski paketi i dalje ažuriraju, ali više ne dobiva ažuriranja za Omarchy. Nema roka i nema nadogradnje na licu mjesta: napravite sigurnosnu kopiju, uklonite staru instalaciju, instalirate iznova i vratite podatke. Koraci od 2 do 5 odvijaju se u macOS-u, pa otvorite ovu stranicu na telefonu prije ponovnog pokretanja.

1. **Napravite sigurnosnu kopiju iz Omarchyja, izvan Maca.** Uklanjanje stare instalacije briše je, a macOS ne može čitati Omarchyjev disk. Kopirajte svoju početnu mapu na vanjski pogon ili drugo računalo, uključujući SSH i GPG ključeve, profile preglednika i rad koji još nije poslan na udaljeno spremište. Spremite popis paketa naredbom `pacman -Qqe > ~/packages.txt`. Napravite sigurnosnu kopiju i macOS-a, jer uklanjanje i instalacija mijenjaju veličinu njegova diska.
2. **Pokrenite Mac u macOS-u.** Isključite računalo, držite gumb za uključivanje dok se ne pojave opcije pokretanja i odaberite macOS.
3. **Instalirajte Omarchy Installer** kako je prikazano u odjeljku [Instalacija](#installing).
4. **Uklonite staru instalaciju.** Otvorite Omarchy Installer i odaberite Installation > Remove Omarchy. Pokazuje što će izbrisati i vraća prostor macOS-u. Ako ne prepozna vašu instalaciju, zaustavlja se bez ikakvih promjena na disku. Zatražite pomoć na [Discordu](https://discord.gg/tXFUdasqhY) umjesto da particije brišete ručno, što može izbrisati macOS.
5. **Instalirajte Omarchy za Apple Silicon** pomoću alata za instalaciju.
6. **Vratite svoje datoteke.** Vraćajte postavke dio po dio umjesto da cijelu mapu `~/.config` kopirate preko novih zadanih postavki, jer stare postavke mogu nadjačati nove.

### Dobro je znati

- Na MacBookovima s čipovima M1 i M2 probudite računalo iz stanja mirovanja otvaranjem poklopca ili pritiskom gumba za uključivanje.
- Pitanja ili problemi: pitajte na našem [Discordu](https://discord.gg/tXFUdasqhY).

[README alata za instalaciju](https://github.com/omacom/omarchy-mac-installer#readme) pokriva kanale izdanja, ažuriranje alata za instalaciju i uklanjanje Omarchyja.

## Macovi s Intelovim procesorima

U jednostavnom testu uspjeli smo postići 36% bolje performanse na MacBook Prou iz 2019. samo instaliranjem Omarchyja.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instaliranje Omarchyja na Mac

Omarchy trenutačno podržava samo to da bude **jedini** OS instaliran. Tijekom instalacije pogon će biti obrisan i MacOS se više neće moći pokrenuti.

I dalje ga možete kasnije vratiti putem značajke Internet Recovery ako želite.

Za potrebe ovog dijela pretpostavit ćemo da ste već pregledali [Početak rada](02-getting-started.md) i da vam je USB pogon spreman. Ako niste, učinite to sada.

#### Onemogućavanje značajke Secure Boot

Potrebno je onemogućiti Appleov Secure Boot kako bi se mogao pokrenuti USB za pokretanje, kao i OS. Da biste ga onemogućili, učinite sljedeće:

1. Isključite Mac
2. Uključite ga i _odmah_ pritisnite i držite Command-R dok se ne pojavi zaslon za učitavanje
3. Odaberite svog korisnika i unesite lozinku ako se to od vas zatraži
4. Kada se nađete na zaslonu za oporavak, na traci izbornika odaberite **Utilities > Startup Security Utility**
5. Unesite lozinku kada se to zatraži radi autentifikacije
6. Odaberite "No Security" među opcijama za Secure Boot
7. Odaberite "Allow booting from external or removable media" među opcijama za External Boot

#### Pokretanje instalacije

1. Umetnite USB pogon
2. Ponovno pokrenite Mac i _odmah_ pritisnite i držite Option dok ne vidite zaslon s uređajima za pokretanje
3. Odaberite narančasti uređaj EFI Boot
4. Nastavite s [instalacijom kao i obično](02-getting-started.md)

Alat za instalaciju prepoznaje Macov hardver i automatski primjenjuje potrebne popravke: upravljačke programe i firmver za Broadcom Wi-Fi, upravljački program za kameru FaceTime HD na strojevima s čipom Broadcom 1570 (njezin se firmver preuzima od Applea kada Mac dođe na mrežu, jer alat za instalaciju radi izvan mreže), upravljački program za SPI tipkovnicu na modelima MacBooka kojima je potreban te popravak za obustavu NVMe-a za te iste modele.

### Poznata ograničenja

Članovi zajednice neprestano rade na rješenjima za ove izazove, pa ako vam oni predstavljaju problem, pridružite se kanalu #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY) i provjerite postoje li ažurne metode za njihovo rješavanje.

#### Kamera FaceTime HD

Upravljački program kamere zablokira stroj ako je učitan kada Mac hibernira, pa se prije toga istovari. Ne može se istovariti dok neka aplikacija ima kameru otvorenu, pa se hibernacija otkazuje obaviješću u kojoj se navodi aplikacija: zatvorite je i ponovno hibernirajte. To uključuje automatsko hiberniranje pri kritičnoj razini baterije te suspend-then-hibernate, koje se odbija prije nego što se sustav obustavi. Običnu obustavu odbija sam upravljački program dok je kamera otvorena, bez obavijesti.

Firmver kamere preuzima se od Applea, pa kamera radi tek kada Mac bude na mreži. Preuzimanje počinje pri pokretanju i ponavlja se svakih 15 minuta dok je mreža problem; ako se Appleova datoteka promijenila, zaustavlja se i čeka ažuriranje Omarchyja. Ako se kamera ne pojavi, `journalctl -u facetimehd-firmware-fetcher` kaže zašto, `sudo systemctl restart facetimehd-firmware-fetcher` pokušava ponovno, a ponovno pokretanje učitava upravljački program ako je preuzimanje završilo, ali kamere i dalje nema.

#### Uređaji s čipom T1

Appleov čip T1 predstavljen je krajem 2016. i koristio se isključivo u modelima MacBook Pro prve generacije s trakom Touch Bar.
- MacBook Pro 13-inch (2016, dva priključka Thunderbolt 3) – Model: A1706
- MacBook Pro 13-inch (2016, četiri priključka Thunderbolt 3) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Poznati problemi

- Touch Bar ne radi
- Zvuk ne radi

#### Uređaji s čipom T2

Sigurnosni čip Apple T2 predstavljen je 2017. Čip T2 prestao se koristiti prelaskom na Apple silicon (čipove serije M) počevši od 2020.

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

Na ovim modelima alat za instalaciju automatski postavlja zakrpani kernel `linux-t2`, konfiguraciju zvuka za T2, Appleov firmver za Broadcom Wi-Fi/Bluetooth i upravljanje ventilatorom putem alata `t2fanrd`. Touch Bar radi na ugrađenoj podršci kernela u stilu Boot Campa.

#### iMac Retina 5K (2017)

27-inčni iMac iz 2017. nema čip T2, pa ga alat za instalaciju postavlja kao i ostale Macove s Intelovim procesorima.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Poznati problemi

- Zaslon ne radi na svojoj izvornoj razlučivosti 5120×2880: panel se sastoji od dviju pločica, a standardni upravljački program osvjetljava samo jednu
- Zvuk ne radi
- Kontrola svjetline nema učinka
- Stanje mirovanja zablokira stroj; oporaviti ga može samo isključivanje i ponovno uključivanje

Alat zajednice za zakrpe za ovaj model popravlja zaslon, zvuk i svjetlinu: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
