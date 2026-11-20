# Windows VM

Omarchy nudi jednostavan način za pokretanje Windowsa putem Docker VM-a na x86_64 računalima. Možete ga instalirati pomoću _Install > Windows_ iz Omarchy izbornika (`Super + Space`).

Vašem računalu za to treba KVM virtualizacija, koju većina ima — ali ponekad je isključena u BIOS-u i instalacijski program će vam reći ako je to slučaj. Trebat će vam i prostor na disku: koliko god dodijelite Windowsu, plus oko 10GB za samu sliku.

Instalacijski program pita koliko RAM-a, koliko CPU jezgri i koliko diska želite predati (64GB ili više razumna je donja granica), zatim Windows korisničko ime i lozinku. Ostavite ih praznima i dobit ćete `docker` / `admin`. Preuzimanje traje — 10-15 minuta je normalno — a napredak možete pratiti u pregledniku na `http://127.0.0.1:8006`. Preglednik prije otvaranja konzole traži isto korisničko ime i lozinku.

 ![windows-vm](images/windows-vm.webp)

## Korištenje

Nakon što je instaliran, pokrenite _Windows_ iz pokretača aplikacija. To pokreće VM ako već ne radi i povezuje vas putem RDP-a, preko cijelog zaslona. Pri hladnom pokretanju dajte mu 15-30 sekundi.

RDP sesija prenosi zvuk, vaš mikrofon i zajednički međuspremnik, pa kopiranje teksta između Linuxa i Windowsa jednostavno radi. Razlučivost prati vaš prozor, a Omarchy prosljeđuje skaliranje vašeg zaslona, pa na HiDPI zaslonu nije mutna zbrka.

Kada zatvorite RDP prozor, VM se automatski gasi. Ako ga radije želite ostaviti da radi — recimo da nešto u njemu i dalje radi — umjesto toga ga pokrenite s `omarchy windows vm launch --keep-alive`.

Ostale kontrole nalaze se na istoj naredbi:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dijeljenje datoteka

Direktorij `~/Windows` u vašem početnom direktoriju automatski se dijeli s VM-om. Stavite datoteke tamo ako želite da budu dostupne Windowsu. VM nema pristup nijednom drugom dijelu vašeg datotečnog sustava, pa ste sigurni od bilo čega zloćudnog s Windows strane. Njegov vlastiti virtualni disk dostupan je na `~/.windows`.

Ti poznati početni putovi ostaju na svojim vlastitim datotečnim sustavima. Mogu biti i simboličke veze na direktorije u vašem vlasništvu, što je korisno kada se virtualni disk nalazi na većem disku. Instalacijski program mjeri slobodan prostor na datotečnom sustavu koji zapravo sadrži `~/.windows`, a ne nužno na datotečnom sustavu koji sadrži vaš početni direktorij.

Držite putove diska i dijeljene putove kao zasebne direktorije koji se ne preklapaju. Uklanjanje namjerno prazni direktorij diska, ali čuva dijeljeni direktorij. Neposredno prije brisanja Omarchy izvodi ograničenu provjeru sadržanosti i odbija ukloniti bilo što ako ta provjera istekne ili ne može dokazati da su dva stabla odvojena.

Prije pokretanja VM-a Omarchy otvara i pričvršćuje ta dva direktorija, zatim bind-mounta točne inode direktorija na privatna sidra po korisniku ispod `/var/lib/omarchy/windows/mounts`. Docker vidi samo ta sidra zaštićena od strane roota. To čuva prilagođene lokacije diska i istovremeno sprječava da drugi proces koji radi pod vašim korisnikom zamijeni provjereni put prije nego što ga privilegirani kontejner upotrijebi. Postojeći direktoriji diska i dijeljeni direktoriji tijekom migracije stežu se na način `0700` kako drugi lokalni računi ne bi mogli pregledavati njihov sadržaj.

Portovi VM-a vezani su samo na localhost, pa ništa na vašoj mreži ne može dosegnuti Windows računalo. Web konzola također zahtijeva konfigurirano Windows korisničko ime i lozinku, čime se sprječava da drugi lokalni račun upravlja VM-om putem porta 8006.

## Ograničenja i licenciranje

S ovom postavkom nema GPU propuštanja, pa nije prikladna za igranje igara ili uređivanje videa. Odličan je način za pokretanje Microsoft Officea ili čega god drugog što apsolutno morate imati.

Instalirana verzija je Windows 11 Pro, neaktivirana. Trebat će vam vlastiti licencni ključ za korištenje ograničenih značajki.

Ako je ovo računalo isporučeno s Windowsom, OEM ključ i dalje je u firmwareu čak i nakon instalacije Omarchyja. Ispišite ga s `omarchy windows key`. Taj je ključ vezan za ovo računalo — aktivirat će Windows ponovno instaliran na ovom hardveru, ali obično neće aktivirati VM.

Dodjelu resursa kasnije možete promijeniti pokretanjem `omarchy windows vm install` u terminalu, čime se konfiguracija VM-a ponovno zapisuje prema vašim odgovorima. Sama compose datoteka sada se nalazi na `/var/lib/omarchy/windows/docker-compose.yml` i u vlasništvu je roota — to je namjerno, kako proces koji radi pod vašim korisnikom ne bi mogao je prepisati i natjerati privilegirano pokretanje da montira cijeli vaš disk u kontejner. Ako je trebate ručno urediti (na primjer za montiranje USB uređaja), uredite je sa `sudo` i pogledajte sve opcije na [projektu Dockur Windows](https://github.com/dockur/windows).

Da biste se riješili svega, upotrijebite _Remove > Windows_ iz Omarchy izbornika. To briše disk VM-a u `~/.windows` i sve instalirano unutar Windowsa, pa prvo kopirajte iz VM-a sve što vam treba. Vaša dijeljena mapa `~/Windows` ostaje netaknuta.
