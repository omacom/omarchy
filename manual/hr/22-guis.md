# Grafička sučelja

## Datoteke

Datoteke (Folio) grafički je upravitelj datoteka. `Super + Shift + F` ga otvara, a `Super + Shift + Alt + F` otvara ga u direktoriju u kojem se vaš terminal trenutno nalazi, što štedi hrpu klikanja. `Ctrl + L` omogućuje vam upisivanje putanje, a pritisak na `Space` na bilo kojoj datoteci prikazuje njezin pretpregled u punoj veličini bez otvaranja.

Umetnite USB stick ili SD karticu i automatski će se montirati, pa će se jednostavno pojaviti u bočnoj traci. Za bilo što složenije — formatiranje pogona, provjeru SMART zdravlja, stvaranje particija — pokrenite _Disks_ iz pokretača aplikacija (`Super + Space`).

Dvoklik slijedi razumne zadane postavke: slike, videozapisi i glazba otvaraju se u programu Omaview, PDF-ovi u programu Document Viewer, Markdown u programu Omawrite, a običan tekst u uređivaču odabranom pod _Setup > Default > Editor_.

## Disktree

Kad se pogon napuni i nemate pojma što ga jede, pokrenite [Disktree](https://github.com/tobi/disktree) iz pokretača aplikacija (`Super + Space`). Prikazuje grafičku mapu stabla vašeg početnog direktorija. Veći blokovi zauzimaju više prostora; ulazite u direktorije tipkovnicom ili mišem, označite što treba ukloniti i pregledajte svoje odabire prije nego što bilo što uklonite. Pokrenite `disktree --disk` za skeniranje cijelog diska.

## Obsidian

[Obsidian](https://obsidian.md/) besplatna je i vrlo proširiva aplikacija za bilješke koja za pohranu koristi jednostavne Markdown datoteke.

Obsidian je besplatan za sve svrhe, uključujući osobnu, komercijalnu i neprofitnu upotrebu.

Obsidian nudi i [komercijalni dodatak za sinkronizaciju](https://obsidian.md/sync) s mobilnim aplikacijama na sustavima iOS i Android. (https://obsidian.md/pricing).

Obsidian pokrećete kombinacijom `Super + Shift + O`. Za korištenje sinkronizacije teme morate u postavkama odabrati temu `Omarchy`.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) Omarchyjeva je vlastita krajnje jednostavna aplikacija za pisanje u Markdownu. Bez trezora, bez dodataka, samo vi i riječi.

Omawrite pokrećete kombinacijom `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) osnovni je alat za uređivanje slika koji je odličan za obrezivanje, promjenu veličine i druge osnovne manipulacije. Samo nemojte očekivati alternativu Photoshopu. Ali ipak ima čarobni štapić i slojeve!

Pintu pokrećete putem pokretača aplikacija (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) aplikacija je za izradu tema koja može izvući boje iz pozadinske slike i pretvoriti ih u cjelovitu, usklađenu temu. To je najlakši način da [izradite vlastitu temu](43-making-your-own-theme.md).

Aether pokrećete putem pokretača aplikacija (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) omogućuje vam slanje datoteka drugim uređajima na istoj mreži na kojima je pokrenuta aplikacija, poput Appleova AirDropa. Međutim, radi na više platformi, pa datoteke možete slati na Windows, macOS, Android, iOS i, naravno, Linux te ih primati s njih.

Izbornik Share možete otvoriti kombinacijom `Super + Ctrl + S` ili pod _Trigger > Share_ u izborniku Omarchy. Nudi vam četiri mogućnosti:

- **Clipboard** šalje sve što ste kopirali kao tekstualnu datoteku. Odlično za prijenos poveznice ili isječka na vaš telefon bez slanja e-pošte samome sebi.
- **File** otvara birač datoteka u kojem ih možete odabrati nekoliko odjednom.
- **Folder** šalje cijeli direktorij.
- **Receive** otvara sam LocalSend kako bi vam drugi uređaj mogao nešto poslati.

Isto radi i iz terminala s `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Izostavite putanju i dobit ćete birač.

Možete slati i izravno iz upravitelja datoteka: desnom tipkom miša kliknite bilo koji odabir u aplikaciji Datoteke i podijelite ga pomoću programa LocalSend.

Vatrozid sustava Omarchy prema zadanim je postavkama zatvoren, osim za priključak programa LocalSend, pa ovo radi odmah nakon svježe instalacije. Pogledajte [sigurnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) cjelovit je uredski paket s programom za obradu teksta, proračunskim tablicama, prezentacijama, aplikacijom za crtanje i još mnogo toga. Kompatibilan je s datotekama iz paketa Microsoft Office, pa je to odličan način da možete otvoriti te Wordove dokumente.

LibreOffice pokrećete putem pokretača aplikacija (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) Omarchyjeva je vlastita krajnje jednostavna aplikacija za prezentacije. Vaša je prezentacija jedna Markdown datoteka sa slikama i videozapisima pokraj nje: svaki slajd pišete ispod pretpregleda uživo, slajdove povlačenjem slažete u redoslijed, a zatim prezentirate preko cijelog zaslona ili izvozite u PDF i PowerPoint. Čak preuzima i vašu Omarchy temu.

Hype pokrećete putem pokretača aplikacija (`Super + Space`). Pritisnite `?` u njemu da biste vidjeli sve prečace.

## Signed

[Signed](https://github.com/omacom/signed) Omarchyjev je vlastiti krajnje jednostavan način za potpisivanje PDF-ova i njihovo ispunjavanje. Postavite svoj spremljeni potpis, tekst i današnji datum bilo gdje na stranicu, a zatim spremite potpisanu kopiju pokraj izvornika. Pogledajte [Ispunjavanje PDF-ova](27-filling-out-pdfs.md) za upute kako to učiniti.

Signed pokrećete putem pokretača aplikacija (`Super + Space`) ili s njime otvorite PDF iz upravitelja datoteka.

## Game Vibes

Game Vibes, u pokretaču aplikacija (`Super + Space`), mjesto je gdje žive Omarchyjeve male igre: Checkmate, 3D šahovska igra protiv prijatelja ili ugrađenog protivnika; Cards, pasijans Klondike; i Neon Swarm, arkadna pucačina. Svaka je jedna web-stranica koja slijedi vašu temu. Odaberite jednu strelicama i tipkom `Enter`, a na popis se vratite tipkom `Esc` s naslovnog zaslona igre ili tipkom `Q` dok je pauzirana. Otvara se preko cijelog zaslona: `Super + F` pretvara je u prozor, a `Super + W` je zatvara.

Igre koje izradite s agentom također se pojavljuju ovdje: odaberite _Make something cool → Game_ u ploči agenata i opišite jednu ili navedite igru koja je već u Game Vibes da biste nastavili raditi na njoj. Agent je kopira u `~/Games/vibes`, gdje je vaša i možete je mijenjati, te je otvara kad završi. Tu kopiju možete izraditi i sami naredbom `omarchy games vibes copy <game>`. Igra koju netko drugi podijeli instalira se poput teme: odaberite _Install > Gaming > Game Vibes_ i zalijepite njezinu git adresu ili pokrenite `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ uklanja je ponovno, a _Update > Game Vibes Games_ dohvaća nove verzije. Igre učitavaju three.js s weba, pa im je za pokretanje potrebna veza.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) Omarchyjev je vlastiti krajnje jednostavan kalkulator koji se otvara u plutajućem prozoru.

Omacalc pokrećete kombinacijom `Super + Shift + Q` (ili tipkom kalkulatora, ako je vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) pionir je E2E šifrirane razmjene poruka i odlična komunikacijska mogućnost za svakoga tko radije ne bi išao preko jednog od velikih tehnoloških konglomerata.

Signal pokrećete kombinacijom `Super + Shift + G`. Nije dio osnovne instalacije, pa će vam prvi put kad to pritisnete Omarchy ponuditi da ga instalira za vas (nalazi se i pod _Install > Service_ u izborniku Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) Omarchyjev je vlastiti krajnje jednostavan preglednik slika i reproduktor medija: jedan prozor za vaše fotografije, videozapise i glazbu. Otvorite fotografiju i tipke sa strelicama kreću se kroz ostatak njezine mape, `N` i `P` čine to za bilo što, a `Ctrl + M` prikazuje cijelu mapu kao mrežu. Prikazuje i HEIC, AVIF i JPEG XL fotografije te nastavlja gdje ste stali u bilo čemu dugom.

Pritisnite `F` za cijeli zaslon, `E` za uređivanje slike u programu Omasnap ili obrezivanje videozapisa u programu Omacut, `Ctrl + P` za ispis slike i `Delete` za premještanje datoteke u smeće (`Ctrl + Z` je vraća). Pritisnite `?` u njemu da biste vidjeli sve prečace.

Omaview pokrećete kao _Media Viewer_ putem pokretača aplikacija (`Super + Space`) ili jednostavno dvokliknite sliku, videozapis ili pjesmu u upravitelju datoteka.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) Omarchyjev je vlastiti krajnje jednostavan alat za obrezivanje videozapisa. Kad vam treba samo odrezati početak i kraj isječka, bolji je od pokretanja potpunog uređivača videozapisa.

Omacut pokrećete putem pokretača aplikacija (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) Omarchyjev je vlastiti krajnje jednostavan snimač web-kamere. Jednom odaberite kameru i mikrofon, zatim pritisnite `Space` za snimanje i ponovno za pauziranje i nastavak istog snimanja. Uvijek snima u najvišoj razlučivosti vaše kamere, s mjeračem mikrofona uživo kako biste mogli provjeriti razine prije početka.

Zaustavite snimanje i odmah se otvara u ugrađenom uređivaču. Dvokliknite isječak da biste ga podijelili, povucite ručke da biste obrezali svaki dio i uklonite dijelove koje ne želite. Zatim ga spremite kao MP4. Vaša izvorna snimka čuva se dok je ne odbacite, pa se uvijek možete vratiti i izrezati je drugačije.

Monologue pokrećete putem pokretača aplikacija (`Super + Space`).
