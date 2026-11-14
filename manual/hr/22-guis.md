# Grafičke aplikacije

## Datoteke

Files (Nautilus) je grafički upravitelj datoteka. `Super + Shift + F` ga otvara, a `Super + Shift + Alt + F` ga otvara u direktoriju u kojem se nalazi vaš terminal, što štedi puno klikanja. `Ctrl + L` omogućuje vam upisivanje putanje, a pritisak na `Space` na bilo kojoj datoteci daje vam brzi pregled bez otvaranja ičega.

Priključite USB memoriju ili SD karticu i automatski se montira, pa se jednostavno pojavi u bočnoj traci. Za bilo što složenije — formatiranje pogona, provjeru SMART zdravlja, izradu particija — pokrenite _Disks_ iz pokretača aplikacija (`Super + Space`).

Dvoklik slijedi razumne zadane postavke: slike se otvaraju u imv, video u mpv, PDF-ovi u Document Viewer, a običan tekst u Neovim.

## Disktree

Kad se pogon napuni i nemate pojma što ga jede, pokrenite [Disktree](https://github.com/tobi/disktree) iz pokretača aplikacija (`Super + Space`). Prikazuje grafičku mapu stabla vašeg početnog direktorija. Veći blokovi zauzimaju više prostora; krećite se kroz direktorije tipkovnicom ili mišem, označite što treba ukloniti i pregledajte svoje odabire prije nego što bilo što uklonite. Pokrenite `disktree --disk` za skeniranje cijelog diska.

## Obsidian

[Obsidian](https://obsidian.md/) je besplatna i vrlo proširiva aplikacija za bilješke koja za pohranu koristi jednostavne Markdown datoteke.

Obsidian je besplatan za sve namjene, uključujući osobnu, komercijalnu i neprofitnu upotrebu.

Obsidian nudi i [komercijalni dodatak za sinkronizaciju](https://obsidian.md/sync) s mobilnim aplikacijama na iOS-u i Androidu. (https://obsidian.md/pricing).

Obsidian pokrećete sa `Super + Shift + O`. Da biste koristili sinkronizaciju teme, morate odabrati temu `Omarchy` u postavkama.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) je Omarchyjeva vlastita krajnje jednostavna aplikacija za pisanje u Markdownu. Bez trezora, bez dodataka, samo vi i riječi.

Omawrite pokrećete sa `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) je osnovni alat za uređivanje slika koji je odličan za obrezivanje, promjenu veličine i druge osnovne manipulacije. Samo nemojte očekivati alternativu Photoshopu. Ali i dalje ima Magic Wand i slojeve!

Pintu pokrećete putem pokretača aplikacija (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) je aplikacija za teme koja može izvući boje iz pozadinske slike i pretvoriti ih u cjelovitu, skladnu temu. To je najlakši način da [izradite vlastitu temu](43-making-your-own-theme.md).

Aether pokrećete putem pokretača aplikacija (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) omogućuje vam slanje datoteka na druge uređaje na istoj mreži koji pokreću aplikaciju, poput Appleova AirDropa. Međutim, radi na više platformi, pa možete slati datoteke na Windows, macOS, Android, iOS i, naravno, Linux te ih primati s njih.

Izbornik Share možete otvoriti sa `Super + Ctrl + S` ili pod _Trigger > Share_ u Omarchy izborniku. Nudi vam četiri opcije:

- **Clipboard** šalje sve što ste kopirali kao tekstualnu datoteku. Odlično za slanje poveznice ili isječka na telefon bez slanja e-pošte samome sebi.
- **File** otvara birač datoteka u kojem ih možete odabrati nekoliko odjednom.
- **Folder** šalje cijeli direktorij.
- **Receive** otvara pravi LocalSend kako bi vam drugi uređaj mogao nešto poslati.

Isto funkcionira iz terminala s `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Izostavite putanju i dobit ćete birač.

Možete slati i izravno iz upravitelja datoteka: desnom tipkom miša kliknite bilo koji odabir u Nautilusu i odaberite _Send via LocalSend_.

Omarchyjev vatrozid zatvoren je prema zadanim postavkama, osim za port LocalSenda, pa ovo radi odmah nakon svježe instalacije. Pogledajte [sigurnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) je cjelovit uredski paket s programom za obradu teksta, proračunskim tablicama, prezentacijama, aplikacijom za crtanje i još mnogo toga. Kompatibilan je s datotekama iz Microsoft Officea, pa je ovo odličan način da možete otvarati te Word dokumente.

LibreOffice pokrećete putem pokretača aplikacija (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) je Omarchyjeva vlastita krajnje jednostavna aplikacija za prezentacije. Vaša prezentacija je jedna Markdown datoteka sa slikama i videozapisima pokraj nje: svaki slajd pišete ispod pregleda uživo, povlačite slajdove u redoslijed, zatim prezentirate preko cijelog zaslona ili izvozite u PDF i PowerPoint. Čak preuzima i vašu Omarchy temu.

Hype pokrećete putem pokretača aplikacija (`Super + Space`). Pritisnite `?` unutar njega da biste vidjeli sve prečace.

## Signed

[Signed](https://github.com/omacom/signed) je Omarchyjev vlastiti krajnje jednostavan način za potpisivanje PDF-ova i njihovo ispunjavanje. Postavite svoj spremljeni potpis, tekst i današnji datum bilo gdje na stranicu, zatim spremite potpisanu kopiju pokraj izvornika. Pogledajte [Ispunjavanje PDF-ova](27-filling-out-pdfs.md) za upute.

Signed pokrećete putem pokretača aplikacija (`Super + Space`) ili s njim otvorite PDF iz upravitelja datoteka.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) je Omarchyjev vlastiti krajnje jednostavan kalkulator, koji se otvara u plutajućem prozoru.

Omacalc pokrećete sa `Super + Shift + Q` (ili tipkom kalkulatora, ako je vaša tipkovnica ima).

## Signal

[Signal](https://signal.org/) je pionir E2E šifriranih poruka i odlična komunikacijska opcija za svakoga tko radije ne bi išao preko jednog od velikih tehnoloških konglomerata.

Signal pokrećete sa `Super + Shift + G`. Nije dio osnovne instalacije, pa će vam Omarchy prvi put kad to pritisnete ponuditi da ga instalira za vas (nalazi se i pod _Install > Service_ u Omarchy izborniku).

## mpv

[mpv](https://mpv.io/) je jednostavan, brz multimedijski reproduktor koji će reproducirati gotovo sve iz bilo kojeg izvora. Odličan za gledanje videozapisa.

mpv pokrećete putem pokretača aplikacija (`Super + Space`) ili jednostavno dvokliknite videozapis u upravitelju datoteka.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) je Omarchyjev vlastiti krajnje jednostavan alat za obrezivanje videozapisa. Kad vam treba samo odrezati početak i kraj isječka, bolje je od pokretanja potpunog uređivača videozapisa.

Omacut pokrećete putem pokretača aplikacija (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) je Omarchyjev vlastiti krajnje jednostavan snimač web-kamerom. Odaberite kameru i mikrofon jednom, zatim pritisnite `Space` za snimanje, i ponovno za pauziranje i nastavak istog snimanja. Uvijek snima u najvišoj razlučivosti vaše kamere, s mjeračem mikrofona uživo kako biste mogli provjeriti razine prije početka.

Zaustavite snimanje i odmah se otvara u ugrađenom uređivaču. Dvokliknite isječak da biste ga podijelili, povucite ručke za obrezivanje svakog dijela i uklonite dijelove koje ne želite. Zatim ga spremite kao MP4. Vaša izvorna snimka čuva se dok je ne odbacite, pa se uvijek možete vratiti i izrezati je drugačije.

Monologue pokrećete putem pokretača aplikacija (`Super + Space`).
