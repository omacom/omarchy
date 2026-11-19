# Grafičke aplikacije

## Files

Files (Nautilus) je grafički upravitelj datoteka. `Super + Shift + F` otvara ga, a `Super + Shift + Alt + F` otvara ga u mapi u kojoj se trenutačno nalazi vaš terminal, što štedi hrpu klikanja. `Ctrl + L` omogućuje vam upisivanje putanje, a pritisak na `Space` na bilo kojoj datoteci daje vam brzi pregled bez otvaranja ičega.

Priključite USB stick ili SD karticu i automatski se montira, pa se jednostavno pojavi u bočnoj traci. Za bilo što složenije — formatiranje diska, provjeru SMART stanja, stvaranje particija — pokrenite _Disks_ iz pokretača aplikacija (`Super + Space`).

Dvoklik slijedi razumne zadane postavke: slike, videozapisi i glazba otvaraju se u Omaview, PDF-ovi u Document Viewer, Markdown u Omawrite, a običan tekst u uređivaču odabranom pod _Setup > Default > Editor_.

## Disktree

Kad se disk napuni i nemate pojma što ga jede, pokrenite [Disktree](https://github.com/tobi/disktree) iz pokretača aplikacija (`Super + Space`). Prikazuje grafičku treemap kartu vaše početne mape. Veći blokovi zauzimaju više prostora; krećite se kroz mape tipkovnicom ili mišem, označite što treba ukloniti i pregledajte svoj odabir prije uklanjanja ičega. Pokrenite `disktree --disk` za skeniranje cijelog diska.

## Obsidian

[Obsidian](https://obsidian.md/) je besplatna i vrlo proširiva aplikacija za bilješke koja za pohranu koristi jednostavne Markdown datoteke.

Obsidian je besplatan za sve namjene, uključujući osobnu, komercijalnu i neprofitnu upotrebu.

Obsidian nudi i [komercijalni dodatak za sinkronizaciju](https://obsidian.md/sync) s mobilnim aplikacijama na iOS-u i Androidu. (https://obsidian.md/pricing).

Obsidian pokrećete sa `Super + Shift + O`. Za korištenje sinkronizacije teme morate odabrati temu `Omarchy` u postavkama.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva vlastita krajnje jednostavna aplikacija za pisanje u Markdownu. Bez trezora, bez dodataka, samo vi i riječi.

Omawrite pokrećete sa `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovni alat za uređivanje slika koji je odličan za obrezivanje, promjenu veličine i druge osnovne manipulacije. Samo ne očekujte alternativu Photoshopu. Ali i dalje ima Magic Wand i slojeve!

Pintu pokrećete putem pokretača aplikacija (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme koja može izvući boje iz pozadinske slike i pretvoriti ih u potpunu, skladnu temu. To je najlakši način da [izradite vlastitu temu](43-making-your-own-theme.md).

Aether pokrećete putem pokretača aplikacija (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) omogućuje vam slanje datoteka na druge uređaje na istoj mreži koji pokreću aplikaciju, poput Appleova AirDropa. Međutim, radi na više platformi, pa datoteke možete slati na Windows, macOS, Android, iOS i, naravno, Linux te ih primati s njih.

Izbornik Share možete otvoriti na `Super + Ctrl + S` ili pod _Trigger > Share_ u izborniku Omarchyja. Nudi vam četiri mogućnosti:

- **Clipboard** šalje sve što ste kopirali kao tekstualnu datoteku. Odlično za prijenos poveznice ili isječka na telefon bez slanja e-pošte samome sebi.
- **File** otvara birač datoteka u kojem ih možete odabrati nekoliko odjednom.
- **Folder** šalje cijelu mapu.
- **Receive** otvara pravi LocalSend kako bi vam drugi uređaj mogao nešto poslati.

Isto radi i iz terminala s `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Izostavite putanju i dobit ćete birač.

Možete slati i izravno iz upravitelja datoteka: desnom tipkom miša kliknite bilo koji odabir u Nautilusu i odaberite _Send via LocalSend_.

Omarchyjev vatrozid zatvoren je prema zadanim postavkama, osim za priključak LocalSenda, pa ovo radi odmah po svježoj instalaciji. Pogledajte [sigurnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je potpuni uredski paket s programom za obradu teksta, proračunskim tablicama, prezentacijama, aplikacijom za crtanje i još mnogo toga. Kompatibilan je s datotekama iz Microsoft Officea, pa je ovo odličan način da možete otvarati te Word dokumente.

LibreOffice pokrećete putem pokretača aplikacija (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva vlastita krajnje jednostavna aplikacija za prezentacije. Vaša je prezentacija jedna Markdown datoteka sa slikama i videozapisima pokraj nje: svaki slajd pišite ispod pregleda uživo, povucite slajdove u redoslijed, zatim prezentirajte preko cijelog zaslona ili izvezite u PDF i PowerPoint. Čak preuzima i vašu Omarchy temu.

Hype pokrećete putem pokretača aplikacija (`Super + Space`). Pritisnite `?` unutar njega da vidite sve prečace.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev vlastiti krajnje jednostavan način za potpisivanje PDF-ova i njihovo ispunjavanje. Postavite spremljeni potpis, tekst i današnji datum bilo gdje na stranicu, zatim spremite potpisanu kopiju pokraj izvornika. Pogledajte [Ispunjavanje PDF-ova](27-filling-out-pdfs.md) za upute.

Signed pokrećete putem pokretača aplikacija (`Super + Space`) ili s njime otvorite PDF iz upravitelja datoteka.

## Game Vibes

Game Vibes, u pokretaču aplikacija (`Super + Space`), mjesto je gdje žive Omarchyjeve male igre: Checkmate, 3D igra šaha protiv prijatelja ili ugrađenog protivnika; Cards, Klondike pasijans; i Neon Swarm, arkadna pucačina. Svaka je jedna web-stranica koja slijedi vašu temu. Odaberite jednu strelicama i `Enter`, a na popis se vratite s `Esc` s naslovnog zaslona igre ili `Q` dok je pauzirana. Otvara se preko cijelog zaslona: `Super + F` pretvara je u prozor, a `Super + W` je zatvara.

Igre koje izradite s agentom također se pojavljuju ovdje: odaberite _Make something cool → Game_ u ploči agenata i opišite jednu ili navedite igru koja je već u Game Vibes da nastavite raditi na njoj. Agent je kopira u `~/Games/vibes`, gdje je vaša da je mijenjate, i otvara je kad završi. Tu kopiju možete napraviti i sami s `omarchy games vibes copy <game>`. Igra koju netko drugi podijeli instalira se poput teme: odaberite _Install > Gaming > Game Vibes_ i zalijepite njezinu git adresu ili pokrenite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ ponovno je uklanja, a _Update > Game Vibes Games_ dohvaća nove verzije. Igre učitavaju three.js s weba, pa im za pokretanje treba veza.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev vlastiti krajnje jednostavan kalkulator, koji se otvara u plutajućem prozoru.

Omacalc pokrećete sa `Super + Shift + Q` (ili tipkom kalkulatora, ako je vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir E2E šifrirane razmjene poruka i odlična komunikacijska mogućnost za svakoga tko radije ne bi išao preko jednog od velikih tehnoloških konglomerata.

Signal pokrećete sa `Super + Shift + G`. Nije dio osnovne instalacije, pa će vam prvi put kad pritisnete tu kombinaciju Omarchy ponuditi da ga instalira za vas (nalazi se i pod _Install > Service_ u izborniku Omarchyja).

## Omaview

[Omaview](https://github.com/omacom/omaview) je Omarchyjev vlastiti krajnje jednostavan preglednik slika i reproduktor medija: jedan prozor za vaše fotografije, videozapise i glazbu. Otvorite fotografiju i tipke sa strelicama kreću se kroz ostatak njezine mape, `N` i `P` rade to za bilo što, a `Ctrl + M` prikazuje cijelu mapu kao mrežu. Prikazuje i HEIC, AVIF i JPEG XL fotografije te nastavlja gdje ste stali u bilo čemu dugom.

Pritisnite `F` za cijeli zaslon, `E` za uređivanje slike u Omasnap ili obrezivanje videozapisa u Omacut, `Ctrl + P` za ispis slike i `Delete` za premještanje datoteke u Smeće (`Ctrl + Z` vraća je natrag). Pritisnite `?` unutar njega da vidite sve prečace.

Omaview pokrećete kao _Media Viewer_ putem pokretača aplikacija (`Super + Space`) ili jednostavno dvokliknite sliku, videozapis ili pjesmu u upravitelju datoteka.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev vlastiti krajnje jednostavan alat za obrezivanje videozapisa. Kad trebate samo odrezati početak i kraj isječka, bolji je od pokretanja potpunog uređivača videozapisa.

Omacut pokrećete putem pokretača aplikacija (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev vlastiti krajnje jednostavan snimač web-kamerom. Odaberite kameru i mikrofon jednom, zatim pritisnite `Space` za snimanje i ponovno za pauziranje i nastavak istog snimanja. Uvijek snima u najvišoj razlučivosti vaše kamere, s mjeračem mikrofona uživo kako biste mogli provjeriti razine prije početka.

Zaustavite snimanje i odmah se otvara u ugrađenom uređivaču. Dvokliknite isječak da ga podijelite, povucite ručke za obrezivanje svakog dijela i uklonite dijelove koje ne želite. Zatim ga spremite kao MP4. Vaša izvorna snimka čuva se dok je ne odbacite, pa se uvijek možete vratiti i izrezati je drugačije.

Monologue pokrećete putem pokretača aplikacija (`Super + Space`).
