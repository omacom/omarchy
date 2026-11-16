# GUIs

## Files

Files (Nautilus) je grafički upravitelj datoteka. `Super + Shift + F` ga otvara, a `Super + Shift + Alt + F` ga otvara u direktoriju u kojem se trenutno nalazi vaš terminal, što štedi puno klikanja. `Ctrl + L` omogućuje vam upisivanje putanje, a pritisak na `Space` na bilo kojoj datoteci daje vam brzi pregled bez otvaranja ičega.

Priključite USB stick ili SD karticu i automatski će se montirati, pa će se jednostavno pojaviti u bočnoj traci. Za bilo što složenije — formatiranje pogona, provjeru SMART zdravlja, izradu particija — pokrenite _Disks_ iz pokretača aplikacija (`Super + Space`).

Dvostruki klik slijedi razumne zadane postavke: slike, videozapisi i glazba otvaraju se u aplikaciji Omaview, PDF-ovi u aplikaciji Document Viewer, Markdown u aplikaciji Omawrite, a običan tekst u uređivaču odabranom pod _Setup > Default > Editor_.

## Disktree

Kad se pogon napuni i nemate pojma što ga jede, pokrenite [Disktree](https://github.com/tobi/disktree) iz pokretača aplikacija (`Super + Space`). Prikazuje grafičku mapu stabla vašeg početnog direktorija. Veći blokovi zauzimaju više prostora; krećite se po direktorijima tipkovnicom ili mišem, označite što treba ukloniti i pregledajte svoje odabire prije uklanjanja bilo čega. Pokrenite `disktree --disk` za skeniranje cijelog diska.

## Obsidian

[Obsidian](https://obsidian.md/) je besplatna i vrlo proširiva aplikacija za bilježenje koja za pohranu koristi jednostavne Markdown datoteke.

Obsidian je besplatan za sve namjene, uključujući osobnu, komercijalnu i neprofitnu upotrebu.

Obsidian nudi i [komercijalni dodatak za sinkronizaciju](https://obsidian.md/sync) s mobilnim aplikacijama na sustavima iOS i Android. (https://obsidian.md/pricing).

Obsidian pokrećete kombinacijom `Super + Shift + O`. Za korištenje sinkronizacije teme morate odabrati temu `Omarchy` u postavkama.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je vlastita iznimno jednostavna aplikacija sustava Omarchy za pisanje u formatu Markdown. Nema trezora, nema dodataka, samo vi i riječi.

Omawrite pokrećete kombinacijom `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovni alat za uređivanje slika koji je izvrstan za izrezivanje, promjenu veličine i druge osnovne obrade. Samo nemojte očekivati alternativu za Photoshop. Ali ipak ima Magic Wand i slojeve!

Aplikaciju Pinta pokrećete putem pokretača aplikacija (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme koja može izvući boje iz pozadinske slike i pretvoriti ih u cjelovitu, skladnu temu. To je najlakši način da [izradite vlastitu temu](43-making-your-own-theme.md).

Aplikaciju Aether pokrećete putem pokretača aplikacija (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) omogućuje vam slanje datoteka na druge uređaje na istoj mreži koji pokreću tu aplikaciju, poput usluge AirDrop tvrtke Apple. Međutim, dostupan je na više platformi, pa datoteke možete slati na Windows, macOS, Android, iOS i, naravno, Linux te ih primati s njih.

Izbornik Share možete otvoriti kombinacijom `Super + Ctrl + S` ili pod _Trigger > Share_ u izborniku sustava Omarchy. Nudi vam četiri opcije:

- **Clipboard** šalje sve što ste kopirali kao tekstualnu datoteku. Izvrsno za prijenos poveznice ili isječka na vaš telefon bez slanja e-pošte samome sebi.
- **File** otvara birač datoteka u kojem ih možete odabrati nekoliko odjednom.
- **Folder** šalje cijeli direktorij.
- **Receive** otvara samu aplikaciju LocalSend kako bi vam drugi uređaj mogao nešto poslati.

Isto funkcionira i iz terminala pomoću naredbi `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Izostavite putanju i dobit ćete birač.

Možete slati i izravno iz upravitelja datoteka: desnom tipkom miša kliknite bilo koji odabir u aplikaciji Nautilus i odaberite _Send via LocalSend_.

Vatrozid sustava Omarchy prema zadanim je postavkama zatvoren, osim priključka aplikacije LocalSend, pa ovo radi odmah nakon svježe instalacije. Pogledajte [sigurnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je cjelovit uredski paket s programom za obradu teksta, proračunskim tablicama, prezentacijama, aplikacijom za crtanje i još mnogo toga. Kompatibilan je s datotekama iz paketa Microsoft Office, pa je ovo izvrstan način za otvaranje tih Word dokumenata.

Aplikaciju LibreOffice pokrećete putem pokretača aplikacija (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je vlastita iznimno jednostavna aplikacija sustava Omarchy za prezentacije. Vaša je prezentacija jedna Markdown datoteka sa slikama i videozapisima pokraj nje: svaki slajd pišite ispod pregleda uživo, povucite slajdove u željeni redoslijed, a zatim prezentirajte preko cijelog zaslona ili izvezite u PDF i PowerPoint. Čak preuzima i vašu Omarchy temu.

Aplikaciju Hype pokrećete putem pokretača aplikacija (`Super + Space`). Pritisnite `?` u njoj da biste vidjeli sve prečace.

## Signed

[Signed](https://github.com/omacom/signed) je vlastiti iznimno jednostavan način sustava Omarchy za potpisivanje PDF-ova i njihovo ispunjavanje. Postavite svoj spremljeni potpis, tekst i današnji datum bilo gdje na stranicu, a zatim spremite potpisanu kopiju pokraj izvornika. Kako to učiniti, pogledajte u odjeljku [Ispunjavanje PDF-ova](27-filling-out-pdfs.md).

Aplikaciju Signed pokrećete putem pokretača aplikacija (`Super + Space`) ili njome otvorite PDF iz upravitelja datoteka.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je vlastita 3D šahovska igra sustava Omarchy. Igrajte protiv prijatelja na istom računalu ili protiv ugrađenog protivnika na tri razine, s četiri oblikovana kompleta figura od kojih se svaki kreće na svoj način: orbitalne letjelice, rezbareno drvo i bjelokost, šumska stvorenja i slatkiši. Partije nemaju sat i spremaju se nakon svakog poteza.

Aplikaciju Checkmate pokrećete putem pokretača aplikacija (`Super + Space`), gdje je navedena kao Chess. Pritisnite `?` u njoj da biste vidjeli sve prečace.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je vlastiti iznimno jednostavan kalkulator sustava Omarchy koji se otvara u plutajućem prozoru.

Omacalc pokrećete kombinacijom `Super + Shift + Q` (ili tipkom za kalkulator, ako je vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) pionir je E2E šifrirane razmjene poruka i izvrsna komunikacijska opcija za sve koji radije ne bi išli preko jednog od velikih tehnoloških konglomerata.

Signal pokrećete kombinacijom `Super + Shift + G`. Nije dio osnovne instalacije, pa će vam Omarchy prvi put kad pritisnete tu kombinaciju ponuditi da ga instalira za vas (nalazi se i pod _Install > Service_ u izborniku sustava Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je vlastiti iznimno jednostavan preglednik slika i reproduktor medija sustava Omarchy: jedan prozor za vaše fotografije, videozapise i glazbu. Otvorite fotografiju i tipke sa strelicama koračaju kroz ostatak njezine mape, `N` i `P` čine to za bilo što, a `Ctrl + M` prikazuje cijelu mapu kao mrežu. Prikazuje i fotografije u formatima HEIC, AVIF i JPEG XL te nastavlja ondje gdje ste stali u bilo čemu dugom.

Pritisnite `F` za cijeli zaslon, `E` za uređivanje slike u aplikaciji Omasnap ili obrezivanje videozapisa u aplikaciji Omacut, `Ctrl + P` za ispis slike i `Delete` za premještanje datoteke u Smeće (`Ctrl + Z` je vraća). Pritisnite `?` u aplikaciji da biste vidjeli sve prečace.

Omaview pokrećete kao _Media Viewer_ putem pokretača aplikacija (`Super + Space`) ili jednostavno dvaput kliknite sliku, videozapis ili pjesmu u upravitelju datoteka.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je vlastiti iznimno jednostavan alat sustava Omarchy za obrezivanje videozapisa. Kad trebate samo odrezati početak i kraj isječka, bolji je od pokretanja potpunog uređivača videozapisa.

Aplikaciju Omacut pokrećete putem pokretača aplikacija (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je vlastiti iznimno jednostavan snimač web-kamere sustava Omarchy. Jednom odaberite kameru i mikrofon, zatim pritisnite `Space` za snimanje te ponovno za pauziranje i nastavak istog snimanja. Uvijek snima u najvišoj razlučivosti vaše kamere, s mjeračem mikrofona uživo kako biste prije početka mogli provjeriti razine.

Zaustavite snimanje i odmah će se otvoriti u ugrađenom uređivaču. Dvaput kliknite isječak da biste ga podijelili, povucite ručke za obrezivanje svakog dijela i uklonite dijelove koje ne želite. Zatim ga spremite kao MP4. Vaša izvorna snimka čuva se dok je ne odbacite, pa se uvijek možete vratiti i izrezati je drugačije.

Aplikaciju Monologue pokrećete putem pokretača aplikacija (`Super + Space`).
