# GUI's

## Files

Files (Folio) is het grafische bestandsbeheerprogramma. Met `Super + Shift + F` open je het, en met `Super + Shift + Alt + F` open je het in de map waarin je terminal zit, wat je een hoop geklik bespaart. Met `Ctrl + L` kun je een pad typen, en als je bij een bestand op `Space` drukt, zie je het op volledig formaat in een voorbeeld, zonder het te openen.

Sluit een USB-stick of een SD-kaart aan en hij wordt automatisch aangekoppeld, zodat hij gewoon in de zijbalk verschijnt. Voor wat ingewikkeldere dingen — een schijf formatteren, de SMART-status controleren, partities aanmaken — start je _Disks_ vanuit de app-launcher (`Super + Space`).

Dubbelklikken volgt verstandige standaardinstellingen: foto's, video's en muziek openen in Omaview, PDF's in Document Viewer, Markdown in Omawrite, en platte tekst in je editor, Plain tenzij je onder _Setup > Defaults > Editor_ een andere kiest.

## Disktree

Als de schijf volloopt en je geen idee hebt wat hem opslokt, start je [Disktree](https://github.com/tobi/disktree) vanuit de app-launcher (`Super + Space`). Het toont een grafische treemap van je thuismap. Grotere blokken nemen meer ruimte in; ga met het toetsenbord of de muis mappen binnen, markeer wat weg mag, en controleer je selecties voordat je iets verwijdert. Voer `disktree --disk` uit om de hele schijf te scannen.

## Obsidian

[Obsidian](https://obsidian.md/) is een gratis en zeer uitbreidbare notitie-app die eenvoudige Markdown-bestanden gebruikt voor opslag.

Obsidian is gratis voor alle doeleinden, waaronder persoonlijk, commercieel en non-profitgebruik.

Obsidian biedt ook een [commerciële add-on voor synchronisatie](https://obsidian.md/sync) met mobiele apps op iOS en Android. (https://obsidian.md/pricing).

Je start Obsidian met `Super + Shift + O`. Om themasynchronisatie te gebruiken, moet je onder de instellingen het `Omarchy`-thema selecteren.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) is Omarchy's eigen doodsimpele Markdown-schrijfapp. Geen vaults, geen plugins, gewoon jij en de woorden.

Je start Omawrite met `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) is een eenvoudige tool voor beeldbewerking die geweldig is voor bijsnijden, formaat wijzigen en andere eenvoudige bewerkingen. Verwacht alleen geen Photoshop-alternatief. Maar hij heeft wel een Magic Wand en lagen!

Je start Pinta via de app-launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) is een thema-app die kleuren uit een achtergrondafbeelding kan halen en er een compleet, samenhangend thema van kan maken. Het is de makkelijkste manier om [je eigen thema te maken](43-making-your-own-theme.md).

Je start Aether via de app-launcher (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) laat je bestanden sturen naar andere apparaten op hetzelfde netwerk die de app draaien, zoals Apple's AirDrop. Het is alleen wel cross-platform, dus je kunt bestanden heen en weer sturen tussen Windows, macOS, Android, iOS en natuurlijk Linux.

Je opent het Share-menu met `Super + Ctrl + S` of onder _Trigger > Share_ in het Omarchy-menu. Het geeft je vier opties:

- **Clipboard** stuurt alles wat je hebt gekopieerd als tekstbestand. Geweldig om een link of een fragment op je telefoon te krijgen zonder jezelf te e-mailen.
- **File** opent een bestandskiezer waarin je er meerdere tegelijk kunt selecteren.
- **Folder** stuurt een hele map.
- **Receive** opent LocalSend zelf, zodat een ander apparaat iets naar jou kan sturen.

Hetzelfde werkt vanuit de terminal met `omarchy share clipboard`, `omarchy share file [path]` en `omarchy share folder [path]`. Laat het pad weg en je krijgt de kiezer.

Je kunt ook rechtstreeks vanuit het bestandsbeheer sturen: klik met de rechtermuisknop op een selectie in Files en deel die met LocalSend.

De firewall van Omarchy is standaard gesloten, behalve voor de poort van LocalSend, dus dit werkt meteen op een verse installatie. Zie [beveiliging](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) is een compleet officepakket met tekstverwerker, spreadsheetprogramma, presentaties, tekenapp en meer. Het is compatibel met bestanden uit Microsoft Office, dus dit is een geweldige manier om die Word-documenten te kunnen openen.

Je start LibreOffice via de app-launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) is Omarchy's eigen doodsimpele presentatie-app. Je presentatie is één enkel Markdown-bestand met de afbeeldingen en video's ernaast: schrijf elke dia onder een live voorbeeld, sleep dia's in de juiste volgorde, en presenteer vervolgens op volledig scherm of exporteer naar PDF en PowerPoint. Hij neemt zelfs je Omarchy-thema over.

Je start Hype via de app-launcher (`Super + Space`). Druk erin op `?` om elke sneltoets te zien.

## Signed

[Signed](https://github.com/omacom/signed) is Omarchy's eigen doodsimpele manier om PDF's te ondertekenen en in te vullen. Plaats je opgeslagen handtekening, tekst en de datum van vandaag waar je maar wilt op een pagina, en sla vervolgens een ondertekende kopie op naast het origineel. Zie [PDF's invullen](27-filling-out-pdfs.md) voor hoe dat werkt.

Je start Signed via de app-launcher (`Super + Space`), of opent er een PDF mee vanuit het bestandsbeheer.

## Game Vibes

Game Vibes, in de app-launcher (`Super + Space`), is waar Omarchy's kleine spelletjes wonen: Checkmate, een 3D-schaakspel tegen een vriend of de ingebouwde tegenstander; Cards, Klondike-solitaire; Death Wish, een pixelprecieze platformer van tien kamers vol stekels en zagen; en Neon Swarm, een arcade-shooter. Elk spel is één enkele webpagina die je thema volgt. Kies er een met de pijltjes en `Enter`, en ga terug naar de lijst met `Esc` vanuit het titelscherm van een spel of met `Q` terwijl het gepauzeerd is. Het opent op volledig scherm: met `Super + F` maak je er een venster van, en met `Super + W` sluit je het.

De spellen die je met een agent maakt, verschijnen hier ook: kies _Make something cool → Game_ in het agentpaneel en beschrijf er een, of noem een spel dat al in Game Vibes staat om er verder aan te werken. De agent kopieert het naar `~/Games/vibes`, waar het van jou is om aan te passen, en opent het als het klaar is. Die kopie kun je zelf maken met `omarchy games vibes copy <game>`. Een spel dat iemand anders deelt, installeert als een thema: kies _Install > Gaming > Game Vibes_ en plak het git-adres, of voer `omarchy games vibes install <git-repo-url>` uit. Met _Remove > Gaming_ haal je er weer een weg, en met _Update > Game Vibes Games_ haal je nieuwe versies op. Spellen laden three.js van het web, dus ze hebben een verbinding nodig om te starten.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) is Omarchy's eigen doodsimpele rekenmachine, die in een zwevend venster opent.

Je start Omacalc met `Super + Shift + Q` (of met de rekenmachinetoets, als je toetsenbord die heeft).

## Signal

[Signal](https://signal.org/) is de pionier van E2E-versleutelde berichten, en een geweldige communicatieoptie voor iedereen die liever niet via een van de grote techconglomeraten gaat.

Je start Signal met `Super + Shift + G`. Het maakt geen deel uit van de basisinstallatie, dus de eerste keer dat je die toetsen indrukt, biedt Omarchy aan om het voor je te installeren (het staat ook onder _Install > Service_ in het Omarchy-menu).

## Omaview

[Omaview](https://github.com/omacom/omaview) is Omarchy's eigen doodsimpele fotoviewer en mediaspeler: één venster voor je foto's, video's en muziek. Open een foto en de pijltjestoetsen stappen door de rest van de map, `N` en `P` doen dat voor alles, en `Ctrl + M` toont de hele map als raster. Hij toont ook HEIC-, AVIF- en JPEG XL-foto's, en pakt alles wat lang is weer op waar je gebleven was.

Druk op `F` voor volledig scherm, `E` om een foto te bewerken in Omasnap of een video te trimmen in Omacut, `Ctrl + P` om een foto af te drukken, en `Delete` om een bestand naar de Trash te verplaatsen (`Ctrl + Z` haalt het terug). Druk erin op `?` om elke sneltoets te zien.

Je start Omaview als _Media Viewer_ via de app-launcher (`Super + Space`), of dubbelklikt gewoon op een foto, video of nummer in het bestandsbeheer.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) is Omarchy's eigen doodsimpele videotrimmer. Als je alleen het begin en het einde van een clip hoeft af te knippen, verslaat hij het opstarten van een volledige video-editor.

Je start Omacut via de app-launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) is Omarchy's eigen doodsimpele webcamrecorder. Kies één keer je camera en microfoon, druk vervolgens op `Space` om op te nemen, en nog een keer om dezelfde opname te pauzeren en te hervatten. Hij neemt altijd op in de hoogste resolutie van je camera, met een live microfoonmeter zodat je je niveaus kunt controleren voordat je begint.

Stop de opname en hij opent meteen in een ingebouwde editor. Dubbelklik op een clip om hem te splitsen, sleep aan de handgrepen om elk stuk te trimmen, en verwijder de delen die je niet wilt. Sla hem vervolgens op als MP4. Je originele opname blijft bewaard tot je hem weggooit, zodat je altijd kunt terugkomen en hem anders kunt knippen.

Je start Monologue via de app-launcher (`Super + Space`).
