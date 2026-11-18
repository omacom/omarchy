# GUI-ji

## Files

Files (Nautilus) je grafički upravitelj datoteka. `Super + Shift + F` ga otvara, a `Super + Shift + Alt + F` ga otvara u direktoriju u kojem se vaš terminal trenutačno nalazi, što štedi puno klikanja. `Ctrl + L` omogućuje vam upisivanje putanje, a pritisak na `Space` na bilo kojoj datoteci daje vam brzi pregled bez otvaranja ičega.

Priključite USB stick ili SD karticu i ona se automatski montira, pa se jednostavno pojavi u bočnoj traci. Za bilo što složenije — formatiranje pogona, provjeru SMART zdravlja, stvaranje particija — pokrenite _Disks_ iz pokretača aplikacija (`Super + Space`).

Dvoklik slijedi razumne zadane postavke: slike, videozapisi i glazba otvaraju se u Omaview, PDF-ovi u Document Viewer, Markdown u Omawrite, a običan tekst u uređivaču odabranom pod _Setup > Default > Editor_.

## Disktree

Kad se pogon napuni i nemate pojma što ga jede, pokrenite [Disktree](https://github.com/tobi/disktree) iz pokretača aplikacija (`Super + Space`). Prikazuje grafičku kartu stabla vašeg početnog direktorija. Veći blokovi zauzimaju više prostora; krećite se kroz direktorije tipkovnicom ili mišem, označite što treba ukloniti i pregledajte svoje odabire prije uklanjanja bilo čega. Pokrenite `disktree --disk` za skeniranje cijelog diska.

## Obsidian

[Obsidian](https://obsidian.md/) je besplatna i vrlo proširiva aplikacija za bilješke koja za pohranu koristi jednostavne Markdown datoteke.

Obsidian je besplatan za sve namjene, uključujući osobnu, komercijalnu i neprofitnu upotrebu.

Obsidian nudi i [komercijalni dodatak za sinkronizaciju](https://obsidian.md/sync) s mobilnim aplikacijama na iOS-u i Androidu. (https://obsidian.md/pricing).

Obsidian pokrećete s `Super + Shift + O`. Da biste koristili sinkronizaciju teme, morate odabrati temu `Omarchy` u postavkama.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva vlastita krajnje jednostavna aplikacija za pisanje u Markdownu. Nema trezora, nema dodataka, samo vi i riječi.

Omawrite pokrećete s `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovni alat za uređivanje slika koji je izvrstan za obrezivanje, promjenu veličine i druge osnovne manipulacije. Samo nemojte očekivati alternativu Photoshopu. Ali i dalje ima Magic Wand i slojeve!

Pintu pokrećete putem pokretača aplikacija (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme koja može izvući boje iz pozadinske slike i pretvoriti ih u cjelovitu, usklađenu temu. To je najlakši način da [izradite vlastitu temu](43-making-your-own-theme.md).

Aether pokrećete putem pokretača aplikacija (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) omogućuje vam slanje datoteka drugim uređajima na istoj mreži koji pokreću aplikaciju, poput Appleova AirDropa. Međutim, radi na više platformi, pa datoteke možete slati na Windows, macOS, Android, iOS i, naravno, Linux te ih primati s njih.

Izbornik Share možete otvoriti na `Super + Ctrl + S` ili pod _Trigger > Share_ u izborniku Omarchy. Nudi vam četiri mogućnosti:

- **Clipboard** šalje sve što ste kopirali kao tekstualnu datoteku. Izvrsno za prebacivanje poveznice ili isječka na telefon bez slanja e-pošte samome sebi.
- **File** otvara birač datoteka u kojem možete odabrati nekoliko odjednom.
- **Folder** šalje cijeli direktorij.
- **Receive** otvara pravi LocalSend kako bi vam drugi uređaj mogao nešto poslati.

Isto radi i iz terminala s `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Izostavite putanju i dobit ćete birač.

Možete slati i izravno iz upravitelja datoteka: desnom tipkom kliknite bilo koji odabir u Nautilusu i odaberite _Send via LocalSend_.

Vatrozid u Omarchyju zatvoren je prema zadanim postavkama, osim porta za LocalSend, pa ovo radi odmah nakon svježe instalacije. Pogledajte [sigurnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je cjelovit uredski paket s programom za obradu teksta, proračunskim tablicama, prezentacijama, aplikacijom za crtanje i još toga. Kompatibilan je s datotekama iz Microsoft Officea, pa je ovo izvrstan način da možete otvarati te Word dokumente.

LibreOffice pokrećete putem pokretača aplikacija (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva vlastita krajnje jednostavna aplikacija za prezentacije. Vaša prezentacija je jedna Markdown datoteka sa slikama i videozapisima pokraj nje: svaki slajd pišete ispod pregleda uživo, slajdove povlačenjem slažete u redoslijed, a zatim prezentirate preko cijelog zaslona ili izvozite u PDF i PowerPoint. Čak preuzima i vašu Omarchy temu.

Hype pokrećete putem pokretača aplikacija (`Super + Space`). Pritisnite `?` u njemu da biste vidjeli sve prečace.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev vlastiti krajnje jednostavan način za potpisivanje PDF-ova i njihovo ispunjavanje. Postavite spremljeni potpis, tekst i današnji datum bilo gdje na stranicu, a zatim spremite potpisanu kopiju pokraj izvornika. Pogledajte [Ispunjavanje PDF-ova](27-filling-out-pdfs.md) da biste saznali kako.

Signed pokrećete putem pokretača aplikacija (`Super + Space`) ili njime otvorite PDF iz upravitelja datoteka.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) je Omarchyjeva vlastita 3D šahovska igra. Igrajte protiv prijatelja na istom računalu ili protiv ugrađenog protivnika na tri razine, na četiri izrezbarena kompleta koji se svaki kreću na svoj način: orbitalne letjelice, rezbareno drvo i bjelokost, šumska stvorenja i bomboni. Igre nemaju sat i spremaju se nakon svakog poteza.

Checkmate pokrećete putem pokretača aplikacija (`Super + Space`), gdje je naveden kao Chess. Pritisnite `?` u njemu da biste vidjeli sve prečace.

## Cards

[Cards](https://github.com/omacom/cards) je Omarchyjev vlastiti Klondike solitaire. Vucite po tri, bez ograničenja broja prolaza, u četiri serije karata: jedna je nacrtana u bojama vaše teme, a tri imaju vlastiti izgled. Kliknite kartu, a zatim mjesto kamo ide, povucite je ili je dvokliknite da biste je poslali na najbolje mjesto. Igre se spremaju nakon svakog poteza.

Cards pokrećete putem pokretača aplikacija (`Super + Space`). Kliknite njegovo ime ili pritisnite `?` da biste vidjeli sve prečace.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev vlastiti krajnje jednostavan kalkulator koji se otvara u plutajućem prozoru.

Omacalc pokrećete s `Super + Shift + Q` (ili tipkom kalkulatora, ako je vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir E2E šifrirane razmjene poruka i izvrsna komunikacijska mogućnost za svakoga tko radije ne bi išao preko jednog od velikih tehnoloških konglomerata.

Signal pokrećete s `Super + Shift + G`. Nije dio osnovne instalacije, pa će vam Omarchy prvi put kad to pritisnete ponuditi da ga instalira za vas (također je pod _Install > Service_ u izborniku Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev vlastiti krajnje jednostavan preglednik slika i reproduktor medija: jedan prozor za vaše fotografije, videozapise i glazbu. Otvorite fotografiju i tipke sa strelicama kreću se kroz ostatak njezine mape, `N` i `P` to rade za bilo što, a `Ctrl + M` prikazuje cijelu mapu kao mrežu. Prikazuje i HEIC, AVIF i JPEG XL fotografije, a u svemu dugom nastavlja tamo gdje ste stali.

Pritisnite `F` za cijeli zaslon, `E` za uređivanje slike u Omasnap ili obrezivanje videozapisa u Omacut, `Ctrl + P` za ispis slike i `Delete` za premještanje datoteke u Smeće (`Ctrl + Z` je vraća). Pritisnite `?` u njemu da biste vidjeli sve prečace.

Omaview pokrećete kao _Media Viewer_ putem pokretača aplikacija (`Super + Space`) ili jednostavno dvokliknite sliku, videozapis ili pjesmu u upravitelju datoteka.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev vlastiti krajnje jednostavan alat za obrezivanje videozapisa. Kad vam treba samo odrezati početak i kraj isječka, bolji je od pokretanja potpunog uređivača videozapisa.

Omacut pokrećete putem pokretača aplikacija (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev vlastiti krajnje jednostavan snimač web-kamere. Jednom odaberite kameru i mikrofon, zatim pritisnite `Space` za snimanje te ponovno za pauziranje i nastavljanje iste snimke. Uvijek snima u najvišoj razlučivosti vaše kamere, s mjeračem mikrofona uživo kako biste prije početka mogli provjeriti razine.

Zaustavite snimku i ona se odmah otvara u ugrađenom uređivaču. Dvokliknite isječak da biste ga podijelili, povucite ručke da biste obrezali svaki dio i uklonite dijelove koje ne želite. Zatim ga spremite kao MP4. Vaša izvorna snimka čuva se dok je ne odbacite, pa se uvijek možete vratiti i izrezati je drukčije.

Monologue pokrećete putem pokretača aplikacija (`Super + Space`).
