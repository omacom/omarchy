# GUI-ji

## Files

Files (Nautilus) grafički je upravitelj datoteka. `Super + Shift + F` ga otvara, a `Super + Shift + Alt + F` ga otvara u direktoriju u kojem se nalazi tvoj terminal, što štedi puno klikanja. `Ctrl + L` omogućuje ti upisivanje putanje, a pritiskom na `Space` na bilo kojoj datoteci dobivaš brzi pregled bez otvaranja ičega.

Priključi USB stick ili SD karticu i automatski se montira, pa se samo pojavi u bočnoj traci. Za bilo što složenije — formatiranje pogona, provjera SMART stanja, stvaranje particija — pokreni _Disks_ iz pokretača aplikacija (`Super + Space`).

Dvoklik slijedi razumne zadane postavke: slike se otvaraju u imv-u, video u mpv-u, PDF-ovi u Document Vieweru, a običan tekst u Neovimu.

## Disktree

Kad se pogon napuni i nemaš pojma što ga jede, pokreni [Disktree](https://github.com/tobi/disktree) iz pokretača aplikacija (`Super + Space`). Prikazuje grafičku treemapu tvog matičnog direktorija. Veći blokovi zauzimaju više prostora; kreći se kroz direktorije tipkovnicom ili mišem, označi što treba ukloniti i pregledaj svoje odabire prije nego što bilo što ukloniš. Pokreni `disktree --disk` za skeniranje cijelog diska.

## Obsidian

[Obsidian](https://obsidian.md/) besplatna je i vrlo proširiva aplikacija za bilješke koja za pohranu koristi jednostavne Markdown datoteke.

Obsidian je besplatan u sve svrhe, uključujući osobnu, komercijalnu i neprofitnu upotrebu.

Obsidian nudi i [komercijalni dodatak za sinkronizaciju](https://obsidian.md/sync) s mobilnim aplikacijama na iOS-u i Androidu. (https://obsidian.md/pricing).

Obsidian pokrećeš sa `Super + Shift + O`. Za korištenje sinkronizacije teme moraš odabrati temu `Omarchy` pod postavkama.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) Omarchyjeva je vlastita krajnje jednostavna aplikacija za pisanje u Markdownu. Bez vaultova, bez dodataka, samo ti i riječi.

Omawrite pokrećeš sa `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) osnovni je alat za uređivanje slika koji je odličan za izrezivanje, promjenu veličine i druge osnovne manipulacije. Samo ne očekuj alternativu Photoshopu. Ali ipak ima Magic Wand i slojeve!

Pintu pokrećeš putem pokretača aplikacija (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) aplikacija je za tematiziranje koja može izdvojiti boje iz pozadinske slike i pretvoriti ih u potpunu, koherentnu temu. To je najlakši način da [stvariš vlastitu temu](43-making-your-own-theme.md).

Aether pokrećeš putem pokretača aplikacija (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) omogućuje ti slanje datoteka drugim uređajima na istoj mreži koji pokreću aplikaciju, poput Appleova AirDropa. Međutim, višeplatformski je, pa možeš slati datoteke na i s Windowsa, macOS-a, Androida, iOS-a i naravno Linuxa.

Izbornik Share možeš otvoriti na `Super + Ctrl + S` ili pod _Pokreni > Dijeli_ u izborniku Omarchy. Daje ti četiri opcije:

- **Međuspremnik** šalje sve što si kopirao kao tekstualnu datoteku. Odlično za slanje poveznice ili isječka na telefon bez slanja e-pošte samom sebi.
- **Datoteka** otvara birač datoteka u kojem možeš odabrati nekoliko odjednom.
- **Mapa** šalje cijeli direktorij.
- **Primi** otvara pravi LocalSend tako da ti drugi uređaj može poslati nešto.

Ista stvar radi iz terminala s `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Izostavi putanju i dobivaš birač.

Možeš slati i izravno iz upravitelja datoteka: desnom tipkom miša klikni bilo koji odabir u Nautilusu i odaberi _Send via LocalSend_.

Omarchyjev vatrozid zatvoren je prema zadanim postavkama osim za port LocalSenda, pa ovo radi odmah po instalaciji na svježoj instalaciji. Pogledaj [sigurnost](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) potpun je uredski paket s procesorom teksta, proračunskim tablicama, prezentacijama, aplikacijom za crtanje i još mnogo toga. Kompatibilan je s datotekama iz Microsoft Officea, pa je ovo odličan način da možeš otvoriti te Word dokumente.

LibreOffice pokrećeš putem pokretača aplikacija (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) Omarchyjeva je vlastita krajnje jednostavna aplikacija za prezentacije. Tvoj deck jedna je Markdown datoteka sa svojim slikama i videima pokraj nje: piši svaki slajd ispod pregleda uživo, povuci slajdove u redoslijed, a zatim prezentiraj preko cijelog zaslona ili izvezi u PDF i PowerPoint. Čak preuzima tvoju Omarchy temu.

Hype pokrećeš putem pokretača aplikacija (`Super + Space`). Pritisni `?` unutar njega da vidiš svaki prečac.

## Signed

[Signed](https://github.com/omacom/signed) Omarchyjev je vlastiti krajnje jednostavan način za potpisivanje PDF-ova i njihovo ispunjavanje. Stavi spremljeni potpis, tekst i današnji datum bilo gdje na stranicu, a zatim spremi potpisanu kopiju pokraj izvornika. Pogledaj [Ispunjavanje PDF-ova](27-filling-out-pdfs.md) za upute.

Signed pokrećeš putem pokretača aplikacija (`Super + Space`) ili njime otvori PDF iz upravitelja datoteka.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) Omarchyjev je vlastiti krajnje jednostavan kalkulator, koji se otvara u plutajućem prozoru.

Omacalc pokrećeš sa `Super + Ctrl + Q` (ili tipkom kalkulatora, ako je tvoja tipkovnica ima).

## Signal

[Signal](https://signal.org/) pionir je E2E šifriranog razmjena poruka i sjajna komunikacijska opcija za svakoga tko radije ne bi išao preko jednog od velikih tehnoloških konglomerata.

Signal pokrećeš sa `Super + Shift + G`. Nije dio osnovne instalacije, pa će ti prvi put kad pritisneš to Omarchy ponuditi da ga instalira za tebe (također je pod _Instaliraj > Service_ u izborniku Omarchy).

## mpv

[mpv](https://mpv.io/) jednostavan je i brz medijski player koji će reproducirati gotovo bilo što iz bilo kojeg izvora. Odličan za gledanje videa.

mpv pokrećeš putem pokretača aplikacija (`Super + Space`) ili samo dvoklikni video u upravitelju datoteka.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) Omarchyjev je vlastiti krajnje jednostavan trimer videa. Kad sve što ti treba je odrezati početak i kraj isječka, pobjeđuje pokretanje punog uređivača videa.

Omacut pokrećeš putem pokretača aplikacija (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) Omarchyjev je vlastiti krajnje jednostavan snimač web-kamere. Jednom odaberi kameru i mikrofon, a zatim pritisni `Space` za snimanje i ponovno za pauziranje i nastavak istog kadra. Uvijek snima u najvišoj razlučivosti tvoje kamere, s mjeračem mikrofona uživo kako bi mogao provjeriti razine prije početka.

Zaustavi kadar i odmah se otvara u ugrađenom uređivaču. Dvoklikni isječak da ga podijeliš, povuci ručice za trimanje svakog dijela i ukloni dijelove koje ne želiš. Zatim ga spremi kao MP4. Tvoja izvorna snimka čuva se dok je ne odbaciš, pa se uvijek možeš vratiti i izrezati je drugačije.

Monologue pokrećeš putem pokretača aplikacija (`Super + Space`).
