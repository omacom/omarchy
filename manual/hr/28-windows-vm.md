# Windows VM

Omarchy nudi jednostavan način za pokretanje Windowsa putem Docker VM-a. Možeš ga instalirati koristeći _Instaliraj > Windows_ iz izbornika Omarchy (`Super + Space`).

Tvojem računalu za ovo treba KVM virtualizacija, što većina ima — ali ponekad je isključena u BIOS-u i instalater će ti reći ako je to slučaj. Također ćeš željeti prostor na disku: koliko god daš Windowsu, plus oko 10GB za samu sliku.

Instalater pita koliko RAM-a, koliko CPU jezgri i koliko diska predati (64GB ili više razuman je pod), a zatim Windows korisničko ime i zaporku. Ostavi ih prazne i dobivaš `docker` / `admin`. Preuzimanje traje — 10-15 minuta je normalno — a napredak možeš pratiti u pregledniku na `http://127.0.0.1:8006`. Preglednik traži isto korisničko ime i zaporku prije otvaranja konzole.

 ![windows-vm](images/windows-vm.webp)

## Korištenje

Nakon što je instaliran, pokreni _Windows_ iz pokretača aplikacija. To pokreće VM ako već ne radi i spaja te preko RDP-a, preko cijelog zaslona. Daj mu 15-30 sekundi na hladnom startu.

RDP sesija nosi zvuk, tvoj mikrofon i zajednički međuspremnik, pa kopiranje teksta između Linuxa i Windowsa jednostavno radi. Razlučivost slijedi tvoj prozor, a Omarchy propušta skaliranje tvog zaslona, pa nije mutna zbrka na HiDPI zaslonu.

Kad zatvoriš RDP prozor, VM se automatski gasi. Ako bi ga radije ostavio aktivnim — recimo da imaš nešto što radi u njemu — pokreni ga s `omarchy windows vm launch --keep-alive` umjesto toga.

Ostale kontrole su na istoj naredbi:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Dijeljenje datoteka

Direktorij `~/Windows` u tvom matičnom direktoriju automatski se dijeli s VM-om. Stavi datoteke tamo ako želiš da budu dostupne Windowsu. VM nema pristup nijednom drugom dijelu tvog datotečnog sustava, pa si siguran od bilo čega gadnog na strani Windowsa. Njegov vlastiti virtualni disk dostupan je na `~/.windows`.

Te poznate matične putanje ostaju na vlastitim datotečnim sustavima. Također mogu biti simboličke poveznice na direktorije koji ti pripadaju, što je korisno kad se virtualni disk nalazi na većem pogonu. Instalater mjeri slobodni prostor na datotečnom sustavu koji zapravo sadrži `~/.windows`, a ne nužno na datotečnom sustavu koji sadrži tvoj matični direktorij.

Drži putanje diska i dijeljenja kao zasebne direktorije koji se ne preklapaju. Uklanjanje namjerno prazni direktorij diska, ali čuva dijeljeni direktorij. Neposredno prije brisanja Omarchy izvodi ograničenu provjeru sadržanja i odbija ukloniti bilo što ako ta provjera istekne ili ne može dokazati da su dva stabla odvojena.

Prije nego što se VM pokrene, Omarchy otvara i pričvršćuje ta dva direktorija, a zatim bind-mounta točne inode direktorija na privatna sidra po korisniku ispod `/var/lib/omarchy/windows/mounts`. Docker vidi samo ta sidra zaštićena rootom. To čuva prilagođene lokacije diska, a istovremeno sprječava drugi proces koji se pokreće kao ti da zamijeni provjerenu putanju prije nego što je privilegirani spremnik potroši. Postojeći direktoriji diska i dijeljenja pooštreni su na način `0700` tijekom migracije kako drugi lokalni računi ne bi mogli pregledavati njihov sadržaj.

Portovi VM-a vezani su samo za localhost, pa ništa na tvojoj mreži ne može dosegnuti Windows računalo. Web-konzola također zahtijeva konfigurirano Windows korisničko ime i zaporku, sprječavajući drugi lokalni račun da upravlja VM-om kroz port 8006.

## Ograničenja i licenciranje

S ovom postavom nema GPU passthrougha, pa nije prikladno za gaming ili uređivanje videa. Sjajan je način za pokretanje Microsoft Officea ili čega god drugog što apsolutno moraš imati.

Instalirana verzija je Windows 11 Pro, neaktiviran. Trebat će ti vlastiti licencni ključ za korištenje ograničenih značajki.

Ako je ovo računalo isporučeno s Windowsom, OEM ključ i dalje je u firmwareu čak i nakon instalacije Omarchyja. Ispiši ga s `omarchy windows key`. Taj ključ vezan je za ovo računalo — aktivirat će Windows ponovno instaliran na ovom hardveru, ali obično neće aktivirati VM.

Alokaciju resursa kasnije možeš promijeniti ponovnim pokretanjem `omarchy-windows-vm install`, što ponovno piše konfiguraciju VM-a iz tvojih odgovora. Sama datoteka compose sada se nalazi na `/var/lib/omarchy/windows/docker-compose.yml` i pripada rootu — to je namjerno, pa proces koji se pokreće kao ti ne može je ponovno napisati i natjerati privilegiranog bring-upa da montira cijeli tvoj disk u spremnik. Ako je trebaš ručno uređivati (na primjer za montiranje USB uređaja), uredi je sa `sudo` i pogledaj sve opcije na [projektu Dockur Windows](https://github.com/dockur/windows).

Da se riješiš cijele stvari, koristi _Ukloni > Windows_ iz izbornika Omarchy. To briše disk VM-a i sve njegove podatke, pa se pobrini da sve što ti je važno prvo izađe iz `~/Windows`.
