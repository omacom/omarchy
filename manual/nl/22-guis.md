# GUI's

## Bestanden

Bestanden (Nautilus) is de grafische bestandsbeheerder. `Super + Shift + F` opent hem, en `Super + Shift + Alt + F` opent hem in de map waarin je terminal zich bevindt, wat je een hoop geklik bespaart. Met `Ctrl + L` kun je een pad typen, en door op een bestand op `Space` te drukken krijg je een snelle voorvertoning zonder iets te openen.

Sluit een USB-stick of een SD-kaart aan en hij wordt automatisch aangekoppeld, zodat hij gewoon in de zijbalk verschijnt. Start voor alles wat meer omvat — een schijf formatteren, de SMART-status controleren, partities aanmaken — _Disks_ vanuit de app launcher (`Super + Space`).

Dubbelklikken volgt verstandige standaardinstellingen: foto's, video's en muziek worden geopend in Omaview, PDF's in Document Viewer en platte tekst in Neovim.

## Disktree

Wanneer de schijf volloopt en je geen idee hebt wat hem opslokt, start je [Disktree](https://github.com/tobi/disktree) vanuit de app launcher (`Super + Space`). Hij toont een grafische treemap van je thuismap. Grotere blokken nemen meer ruimte in; navigeer met het toetsenbord of de muis door mappen, markeer wat weg moet en controleer je selecties voordat je iets verwijdert. Voer `disktree --disk` uit om de hele schijf te scannen.

## Obsidian

[Obsidian](https://obsidian.md/) is een gratis en zeer uitbreidbare notitieapplicatie die eenvoudige Markdown-bestanden gebruikt voor opslag.

Obsidian is gratis voor alle doeleinden, waaronder persoonlijk, commercieel en non-profitgebruik.

Obsidian biedt ook een [commerciële add-on voor synchronisatie](https://obsidian.md/sync) met mobiele apps op iOS en Android. (https://obsidian.md/pricing).

Je start Obsidian met `Super + Shift + O`. Om themasynchronisatie te gebruiken, moet je onder de instellingen het thema `Omarchy` selecteren.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) is Omarchy's eigen doodsimpele Markdown-schrijfapp. Geen kluizen, geen plug-ins, alleen jij en de woorden.

Je start Omawrite met `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) is een eenvoudig hulpmiddel voor beeldbewerking dat geweldig is voor bijsnijden, formaat wijzigen en andere basale bewerkingen. Verwacht alleen geen Photoshop-alternatief. Maar hij heeft nog wel een toverstaf en lagen!

Je start Pinta via de application launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) is een thema-applicatie die kleuren uit een achtergrondafbeelding kan halen en er een compleet, samenhangend thema van kan maken. Het is de makkelijkste manier om [je eigen thema te maken](43-making-your-own-theme.md).

Je start Aether via de application launcher (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) laat je bestanden versturen naar andere apparaten op hetzelfde netwerk waarop de app draait, zoals Apple's AirDrop. Hij is echter cross-platform, dus je kunt bestanden versturen naar en vanaf Windows, macOS, Android, iOS en natuurlijk Linux.

Je kunt het menu Delen openen met `Super + Ctrl + S` of onder _Trigger > Share_ in het Omarchy-menu. Het geeft je vier opties:

- **Clipboard** verstuurt alles wat je hebt gekopieerd als een tekstbestand. Geweldig om een link of een fragment op je telefoon te krijgen zonder jezelf te e-mailen.
- **File** opent een bestandsselector waarin je er meerdere tegelijk kunt selecteren.
- **Folder** verstuurt een volledige map.
- **Receive** opent LocalSend zelf, zodat een ander apparaat iets naar jou kan versturen.

Hetzelfde werkt vanuit de terminal met `omarchy share clipboard`, `omarchy share file [path]` en `omarchy share folder [path]`. Laat het pad weg en je krijgt de selector.

Je kunt ook rechtstreeks vanuit de bestandsbeheerder versturen: klik met de rechtermuisknop op een selectie in Nautilus en kies _Send via LocalSend_.

De firewall van Omarchy is standaard gesloten, behalve voor de poort van LocalSend, dus dit werkt direct bij een verse installatie. Zie [beveiliging](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) is een compleet kantoorpakket met tekstverwerker, spreadsheet, presentaties, tekenapplicatie en meer. Het is compatibel met bestanden uit Microsoft Office, dus dit is een geweldige manier om die Word-documenten te kunnen openen.

Je start LibreOffice via de application launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) is Omarchy's eigen doodsimpele presentatieapp. Je presentatie is één enkel Markdown-bestand met de afbeeldingen en video's ernaast: schrijf elke dia onder een live voorvertoning, sleep dia's in de juiste volgorde en presenteer vervolgens op volledig scherm of exporteer naar PDF en PowerPoint. Hij neemt zelfs je Omarchy-thema over.

Je start Hype via de application launcher (`Super + Space`). Druk erin op `?` om elke sneltoets te zien.

## Signed

[Signed](https://github.com/omacom/signed) is Omarchy's eigen doodsimpele manier om PDF's te ondertekenen en in te vullen. Plaats je opgeslagen handtekening, tekst en de datum van vandaag waar je maar wilt op een pagina en sla vervolgens een ondertekende kopie op naast het origineel. Zie [PDF's invullen](27-filling-out-pdfs.md) voor hoe dat werkt.

Je start Signed via de application launcher (`Super + Space`), of opent er een PDF mee vanuit de bestandsbeheerder.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) is Omarchy's eigen doodsimpele rekenmachine, die in een zwevend venster opent.

Je start Omacalc met `Super + Shift + Q` (of de rekenmachinetoets, als je toetsenbord die heeft).

## Signal

[Signal](https://signal.org/) is de pionier van E2E-versleutelde berichtenuitwisseling, en een geweldige communicatieoptie voor iedereen die liever niet via een van de grote techconglomeraten gaat.

Je start Signal met `Super + Shift + G`. Het maakt geen deel uit van de basisinstallatie, dus de eerste keer dat je daarop drukt, biedt Omarchy aan om het voor je te installeren (het staat ook onder _Install > Service_ in het Omarchy-menu).

## Omaview

[Omaview](https://github.com/omacom/omaview) is Omarchy's eigen doodsimpele afbeeldingenviewer en mediaspeler: één venster voor je foto's, video's en muziek. Open een foto en de pijltjestoetsen stappen door de rest van haar map, `N` en `P` doen dat voor alles, en `Ctrl + M` toont de hele map als een raster. Hij toont ook HEIC-, AVIF- en JPEG XL-foto's, en gaat verder waar je gebleven was in alles wat lang is.

Druk op `F` voor volledig scherm, `E` om een afbeelding te bewerken in Omasnap of een video bij te snijden in Omacut, `Ctrl + P` om een afbeelding af te drukken, en `Delete` om een bestand naar de prullenbak te verplaatsen (`Ctrl + Z` haalt het terug). Druk erin op `?` om elke sneltoets te zien.

Je start Omaview als _Media Viewer_ via de application launcher (`Super + Space`), of dubbelklikt gewoon op een afbeelding, video of nummer in de bestandsbeheerder.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) is Omarchy's eigen doodsimpele videotrimmer. Als je alleen het begin en einde van een clip hoeft af te knippen, verslaat hij het opstarten van een volledige video-editor.

Je start Omacut via de application launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) is Omarchy's eigen doodsimpele webcamrecorder. Kies één keer je camera en microfoon, druk vervolgens op `Space` om op te nemen, en nogmaals om dezelfde opname te pauzeren en te hervatten. Hij neemt altijd op in de hoogste resolutie van je camera, met een live microfoonmeter zodat je je niveaus kunt controleren voordat je begint.

Stop de opname en hij opent meteen in een ingebouwde editor. Dubbelklik op een clip om hem te splitsen, sleep aan de handgrepen om elk stuk bij te snijden en verwijder de delen die je niet wilt. Sla hem vervolgens op als MP4. Je originele opname wordt bewaard totdat je hem weggooit, dus je kunt altijd terugkomen en hem anders knippen.

Je start Monologue via de application launcher (`Super + Space`).
