# GUI's

## Files

Files (Folio) is de grafische bestandsbeheerder. `Super + Shift + F` opent hem, en `Super + Shift + Alt + F` opent hem in de map waarin je terminal zich bevindt, wat je een hoop geklik bespaart. Met `Ctrl + L` kun je een pad typen, en als je op `Space` drukt bij een bestand, krijg je er een preview op volledige grootte van zonder het te openen.

Steek een USB-stick of een SD-kaart erin en hij wordt automatisch gemount, dus hij verschijnt gewoon in de zijbalk. Voor alles wat meer omvat — een schijf formatteren, de SMART-status controleren, partities aanmaken — start je _Disks_ vanuit de applicatiestarter (`Super + Space`).

Dubbelklikken volgt verstandige standaardinstellingen: foto's, video's en muziek openen in Omaview, PDF's in Document Viewer, Markdown in Omawrite, en platte tekst in de editor die is gekozen onder _Setup > Default > Editor_.

## Disktree

Als de schijf volloopt en je geen idee hebt wat hem opslokt, start je [Disktree](https://github.com/tobi/disktree) vanuit de applicatiestarter (`Super + Space`). Het toont een grafische treemap van je thuismap. Grotere blokken nemen meer ruimte in; loop met het toetsenbord of de muis mappen in, markeer wat weg moet en controleer je selecties voordat je iets verwijdert. Voer `disktree --disk` uit om de hele schijf te scannen.

## Obsidian

[Obsidian](https://obsidian.md/) is een gratis en zeer uitbreidbare notitie-app die eenvoudige Markdown-bestanden gebruikt voor opslag.

Obsidian is gratis voor alle doeleinden, inclusief persoonlijk, commercieel en non-profitgebruik.

Obsidian biedt ook een [commerciële add-on voor synchronisatie](https://obsidian.md/sync) met mobiele apps op iOS en Android. (https://obsidian.md/pricing).

Je start Obsidian met `Super + Shift + O`. Om themasynchronisatie te gebruiken, moet je het `Omarchy`-thema selecteren onder de instellingen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) is Omarchy's eigen doodeenvoudige Markdown-schrijfapp. Geen kluizen, geen plugins, alleen jij en de woorden.

Je start Omawrite met `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) is een basisprogramma voor beeldbewerking dat geweldig is voor bijsnijden, formaat wijzigen en andere eenvoudige bewerkingen. Verwacht alleen geen Photoshop-alternatief. Maar het heeft nog steeds een Magic Wand en lagen!

Je start Pinta via de applicatiestarter (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) is een thema-applicatie die kleuren uit een achtergrondafbeelding kan halen en ze kan omzetten in een compleet, samenhangend thema. Het is de makkelijkste manier om [je eigen thema te maken](43-making-your-own-theme.md).

Je start Aether via de applicatiestarter (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) laat je bestanden sturen naar andere apparaten op hetzelfde netwerk die de app draaien, zoals Apple's AirDrop. Het is echter cross-platform, dus je kunt bestanden sturen naar en van Windows, macOS, Android, iOS en natuurlijk Linux.

Je kunt het menu Delen openen met `Super + Ctrl + S` of onder _Trigger > Share_ in het Omarchy-menu. Het geeft je vier opties:

- **Clipboard** stuurt wat je hebt gekopieerd als tekstbestand. Geweldig om een link of een fragment op je telefoon te krijgen zonder jezelf te e-mailen.
- **File** opent een bestandskiezer waarin je er meerdere tegelijk kunt selecteren.
- **Folder** stuurt een volledige map.
- **Receive** opent LocalSend zelf, zodat een ander apparaat iets naar je kan sturen.

Hetzelfde werkt vanuit de terminal met `omarchy share clipboard`, `omarchy share file [path]` en `omarchy share folder [path]`. Laat het pad weg en je krijgt de kiezer.

Je kunt ook rechtstreeks vanuit de bestandsbeheerder sturen: klik met de rechtermuisknop op een selectie in Files en deel deze met LocalSend.

Omarchy's firewall is standaard gesloten, behalve voor de poort van LocalSend, dus dit werkt meteen op een verse installatie. Zie [beveiliging](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) is een compleet kantoorpakket met tekstverwerker, spreadsheetprogramma, presentaties, tekenprogramma en meer. Het is compatibel met bestanden van Microsoft Office, dus dit is een geweldige manier om die Word-documenten te kunnen openen.

Je start LibreOffice via de applicatiestarter (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) is Omarchy's eigen doodeenvoudige presentatie-app. Je deck is één enkel Markdown-bestand met zijn afbeeldingen en video's ernaast: schrijf elke dia onder een live preview, sleep dia's in de juiste volgorde en presenteer vervolgens op volledig scherm of exporteer naar PDF en PowerPoint. Het pikt zelfs je Omarchy-thema op.

Je start Hype via de applicatiestarter (`Super + Space`). Druk binnen de app op `?` om elke sneltoets te zien.

## Signed

[Signed](https://github.com/omacom/signed) is Omarchy's eigen doodeenvoudige manier om PDF's te ondertekenen en in te vullen. Plaats je opgeslagen handtekening, tekst en de datum van vandaag waar je wilt op een pagina en sla vervolgens een ondertekende kopie op naast het origineel. Zie [PDF's invullen](27-filling-out-pdfs.md) voor hoe dat moet.

Je start Signed via de applicatiestarter (`Super + Space`), of opent er een PDF mee vanuit de bestandsbeheerder.

## Game Vibes

Game Vibes, in de applicatiestarter (`Super + Space`), is waar Omarchy's kleine games wonen: Checkmate, een 3D-schaakspel tegen een vriend of de ingebouwde tegenstander; Cards, Klondike-solitaire; en Neon Swarm, een arcade-shooter. Elk is één enkele webpagina die je thema volgt. Kies er een met de pijltjes en `Enter`, en ga terug naar de lijst met `Esc` vanaf het titelscherm van een game of `Q` terwijl hij gepauzeerd is. Het opent op volledig scherm: `Super + F` maakt er een venster van en `Super + W` sluit het.

De games die je met een agent maakt, verschijnen hier ook: kies _Make something cool → Game_ in het agentpaneel en beschrijf er een, of noem een game die al in Game Vibes staat om eraan verder te werken. De agent kopieert hem naar `~/Games/vibes`, waar hij van jou is om aan te passen, en opent hem als hij klaar is. Je kunt die kopie zelf maken met `omarchy games vibes copy <game>`. Een game die iemand anders deelt, installeert als een thema: kies _Install > Gaming > Game Vibes_ en plak het git-adres ervan, of voer `omarchy games vibes install <git-repo-url>` uit. _Remove > Gaming_ haalt er weer een uit, en _Update > Game Vibes Games_ haalt nieuwe versies op. Games laden three.js van het web, dus ze hebben een verbinding nodig om te starten.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) is Omarchy's eigen doodeenvoudige rekenmachine, die opent in een zwevend venster.

Je start Omacalc met `Super + Shift + Q` (of de rekenmachinetoets, als je toetsenbord er een heeft).

## Signal

[Signal](https://signal.org/) is de pionier van E2E-versleutelde berichtgeving en een geweldige communicatieoptie voor iedereen die liever niet via een van de grote techconglomeraten gaat.

Je start Signal met `Super + Shift + G`. Het maakt geen deel uit van de basisinstallatie, dus de eerste keer dat je daarop drukt, biedt Omarchy aan om het voor je te installeren (het staat ook onder _Install > Service_ in het Omarchy-menu).

## Omaview

[Omaview](https://github.com/omacom/omaview) is Omarchy's eigen doodeenvoudige fotoviewer en mediaspeler: één venster voor je foto's, video's en muziek. Open een foto en de pijltjestoetsen stappen door de rest van zijn map, `N` en `P` doen dat voor alles, en `Ctrl + M` toont de hele map als raster. Het toont ook HEIC-, AVIF- en JPEG XL-foto's en hervat alles wat lang is op het punt waar je gebleven was.

Druk op `F` voor volledig scherm, `E` om een foto te bewerken in Omasnap of een video bij te snijden in Omacut, `Ctrl + P` om een foto af te drukken en `Delete` om een bestand naar de Prullenbak te verplaatsen (`Ctrl + Z` haalt het terug). Druk binnen de app op `?` om elke sneltoets te zien.

Je start Omaview als _Media Viewer_ via de applicatiestarter (`Super + Space`), of dubbelklikt gewoon op een foto, video of nummer in de bestandsbeheerder.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) is Omarchy's eigen doodeenvoudige videotrimmer. Als je alleen het begin en het einde van een clip hoeft af te knippen, is het beter dan een volledige video-editor opstarten.

Je start Omacut via de applicatiestarter (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) is Omarchy's eigen doodeenvoudige webcamrecorder. Kies één keer je camera en microfoon, druk vervolgens op `Space` om op te nemen en nogmaals om dezelfde take te pauzeren en te hervatten. Het neemt altijd op in de hoogste resolutie van je camera, met een live microfoonmeter zodat je je niveaus kunt controleren voordat je begint.

Stop de take en hij opent meteen in een ingebouwde editor. Dubbelklik op een clip om hem te splitsen, sleep aan de handgrepen om elk stuk bij te snijden en verwijder de delen die je niet wilt. Sla hem vervolgens op als een MP4. Je originele opname blijft bewaard totdat je hem weggooit, dus je kunt altijd terugkomen en hem anders knippen.

Je start Monologue via de applicatiestarter (`Super + Space`).
