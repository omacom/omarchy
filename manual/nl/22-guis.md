# GUIs

## Files

Files (Nautilus) is de grafische bestandsbeheerder. Met `Super + Shift + F` open je het, en met `Super + Shift + Alt + F` open je het in de map waarin je terminal zich bevindt, wat je een hoop geklik scheelt. Met `Ctrl + L` kun je een pad typen, en als je op `Space` drukt bij een bestand krijg je een snelle preview zonder iets te openen.

Steek een USB-stick of een SD-kaart erin en die wordt automatisch aangekoppeld, dus hij verschijnt gewoon in de zijbalk. Voor alles wat verder gaat — een schijf formatteren, de SMART-status controleren, partities aanmaken — start je _Disks_ vanuit de app-launcher (`Super + Space`).

Dubbelklikken volgt verstandige standaardinstellingen: afbeeldingen, video's en muziek openen in Omaview, PDF's in Document Viewer, Markdown in Omawrite en platte tekst in de editor die je hebt gekozen onder _Setup > Default > Editor_.

## Disktree

Als de schijf volloopt en je geen idee hebt wat alle ruimte opslokt, start je [Disktree](https://github.com/tobi/disktree) vanuit de app-launcher (`Super + Space`). Het toont een grafische treemap van je thuismap. Grotere blokken nemen meer ruimte in; navigeer met het toetsenbord of de muis door mappen, markeer wat weg moet en controleer je selecties voordat je iets verwijdert. Voer `disktree --disk` uit om de hele schijf te scannen.

## Obsidian

[Obsidian](https://obsidian.md/) is een gratis en zeer uitbreidbare notitie-app die eenvoudige Markdown-bestanden gebruikt voor opslag.

Obsidian is gratis voor alle doeleinden, waaronder persoonlijk, commercieel en non-profitgebruik.

Obsidian biedt ook een [commerciële add-on voor synchronisatie](https://obsidian.md/sync) met mobiele apps op iOS en Android. (https://obsidian.md/pricing).

Je start Obsidian met `Super + Shift + O`. Om themasynchronisatie te gebruiken, moet je het `Omarchy`-thema selecteren onder instellingen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) is Omarchy's eigen doodeenvoudige Markdown-schrijfapp. Geen kluizen, geen plugins, alleen jij en de woorden.

Je start Omawrite met `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) is een eenvoudig programma voor beeldbewerking dat prima is voor bijsnijden, formaat wijzigen en andere eenvoudige bewerkingen. Verwacht alleen geen Photoshop-alternatief. Maar het heeft wel een Magic Wand en lagen!

Je start Pinta via de app-launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) is een thema-app die kleuren kan extraheren uit een achtergrondafbeelding en ze kan omzetten in een compleet, samenhangend thema. Het is de makkelijkste manier om [je eigen thema te maken](43-making-your-own-theme.md).

Je start Aether via de app-launcher (`Super + Space`).

## LocalSend

Met [LocalSend](https://localsend.org/) kun je bestanden sturen naar andere apparaten op hetzelfde netwerk waarop de app draait, zoals Apple's AirDrop. Het is echter cross-platform, dus je kunt bestanden sturen naar en vanaf Windows, macOS, Android, iOS en natuurlijk Linux.

Je kunt het Share-menu openen met `Super + Ctrl + S` of onder _Trigger > Share_ in het Omarchy-menu. Je krijgt vier opties:

- **Clipboard** stuurt alles wat je hebt gekopieerd als tekstbestand. Ideaal om een link of een fragment op je telefoon te krijgen zonder jezelf te e-mailen.
- **File** opent een bestandskiezer waarin je er meerdere tegelijk kunt selecteren.
- **Folder** stuurt een hele map.
- **Receive** opent LocalSend zelf, zodat een ander apparaat iets naar je kan sturen.

Hetzelfde werkt vanuit de terminal met `omarchy share clipboard`, `omarchy share file [path]` en `omarchy share folder [path]`. Laat je het pad weg, dan krijg je de kiezer.

Je kunt ook rechtstreeks vanuit de bestandsbeheerder sturen: klik met de rechtermuisknop op een selectie in Nautilus en kies _Send via LocalSend_.

Omarchy's firewall is standaard gesloten, behalve voor de poort van LocalSend, dus dit werkt direct bij een verse installatie. Zie [beveiliging](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) is een compleet kantoorpakket met tekstverwerker, spreadsheet, presentaties, tekenprogramma en meer. Het is compatibel met bestanden uit Microsoft Office, dus dit is een prima manier om die Word-documenten te kunnen openen.

Je start LibreOffice via de app-launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) is Omarchy's eigen doodeenvoudige presentatie-app. Je presentatie is één enkel Markdown-bestand met de afbeeldingen en video's ernaast: schrijf elke dia onder een live preview, sleep dia's in de juiste volgorde en presenteer vervolgens in volledig scherm of exporteer naar PDF en PowerPoint. Hij neemt zelfs je Omarchy-thema over.

Je start Hype via de app-launcher (`Super + Space`). Druk erin op `?` om elke sneltoets te zien.

## Signed

[Signed](https://github.com/omacom/signed) is Omarchy's eigen doodeenvoudige manier om PDF's te ondertekenen en in te vullen. Plaats je opgeslagen handtekening, tekst en de datum van vandaag waar je maar wilt op een pagina en sla vervolgens een ondertekende kopie op naast het origineel. Zie [PDF's invullen](27-filling-out-pdfs.md) voor hoe dat werkt.

Je start Signed via de app-launcher (`Super + Space`), of opent er een PDF mee vanuit de bestandsbeheerder.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) is Omarchy's eigen 3D-schaakspel. Speel tegen een vriend op dezelfde computer of tegen de ingebouwde tegenstander op drie niveaus, met vier gebeeldhouwde sets die elk op hun eigen manier bewegen: orbitale vaartuigen, gesneden hout en ivoor, boswezens en snoep. Partijen hebben geen klok en worden na elke zet opgeslagen.

Je start Checkmate via de app-launcher (`Super + Space`), waar hij als Chess in de lijst staat. Druk erin op `?` om elke sneltoets te zien.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) is Omarchy's eigen doodeenvoudige rekenmachine, die in een zwevend venster opent.

Je start Omacalc met `Super + Shift + Q` (of de rekenmachinetoets, als je toetsenbord die heeft).

## Signal

[Signal](https://signal.org/) is de pionier op het gebied van E2E-versleutelde berichten en een prima communicatieoptie voor iedereen die liever niet via een van de grote techconglomeraten gaat.

Je start Signal met `Super + Shift + G`. Het maakt geen deel uit van de basisinstallatie, dus de eerste keer dat je die combinatie indrukt, biedt Omarchy aan om het voor je te installeren (het staat ook onder _Install > Service_ in het Omarchy-menu).

## Omaview

[Omaview](https://github.com/omacom/omaview) is Omarchy's eigen doodeenvoudige afbeeldingenviewer en mediaspeler: één venster voor je foto's, video's en muziek. Open een foto en de pijltjestoetsen bladeren door de rest van de map, `N` en `P` doen dat voor alles, en `Ctrl + M` toont de hele map als een raster. Het toont ook HEIC-, AVIF- en JPEG XL-foto's en gaat bij lange media verder waar je was gebleven.

Druk op `F` voor volledig scherm, `E` om een afbeelding te bewerken in Omasnap of een video bij te snijden in Omacut, `Ctrl + P` om een afbeelding af te drukken en `Delete` om een bestand naar de Trash te verplaatsen (`Ctrl + Z` haalt het terug). Druk erin op `?` om elke sneltoets te zien.

Je start Omaview als _Media Viewer_ via de app-launcher (`Super + Space`), of dubbelklikt gewoon op een afbeelding, video of nummer in de bestandsbeheerder.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) is Omarchy's eigen doodeenvoudige videotrimmer. Als je alleen het begin en einde van een clip hoeft te knippen, wint dit het van een volledige video-editor opstarten.

Je start Omacut via de app-launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) is Omarchy's eigen doodeenvoudige webcamrecorder. Kies één keer je camera en microfoon, druk vervolgens op `Space` om op te nemen en nogmaals om dezelfde opname te pauzeren en te hervatten. Hij neemt altijd op in de hoogste resolutie van je camera, met een live microfoonmeter zodat je je niveaus kunt controleren voordat je begint.

Stop de opname en hij opent meteen in een ingebouwde editor. Dubbelklik op een clip om hem te splitsen, sleep aan de grepen om elk stuk bij te snijden en verwijder de delen die je niet wilt. Sla hem vervolgens op als MP4. Je originele opname blijft bewaard totdat je hem weggooit, dus je kunt altijd terugkomen en hem anders knippen.

Je start Monologue via de app-launcher (`Super + Space`).
