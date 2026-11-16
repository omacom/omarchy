# GUI's

## Bestanden

Files (Nautilus) is de grafische bestandsbeheerder. `Super + Shift + F` opent hem, en `Super + Shift + Alt + F` opent hem in de map waar je terminal zich bevindt, wat je een hoop geklik bespaart. Met `Ctrl + L` kun je een pad typen, en met `Space` op een bestand krijg je een snelle preview zonder iets te openen.

Sluit een USB-stick of een SD-kaart aan en hij wordt automatisch gemount, dus hij verschijnt gewoon in de zijbalk. Voor alles wat ingewikkelder is — een schijf formatteren, de SMART-gezondheid controleren, partities aanmaken — start je _Disks_ vanuit de app launcher (`Super + Space`).

Dubbelklikken volgt verstandige standaardinstellingen: foto's, video's en muziek openen in Omaview, PDF's in Document Viewer, Markdown in Omawrite en platte tekst in de editor die is gekozen onder _Setup > Default > Editor_.

## Disktree

Als de schijf volloopt en je geen idee hebt wat hem opslokt, start je [Disktree](https://github.com/tobi/disktree) vanuit de app launcher (`Super + Space`). Het toont een grafische treemap van je home-map. Grotere blokken nemen meer ruimte in; loop met het toetsenbord of de muis door mappen, markeer wat weg moet en controleer je selecties voordat je iets verwijdert. Voer `disktree --disk` uit om de hele schijf te scannen.

## Obsidian

[Obsidian](https://obsidian.md/) is een gratis en zeer uitbreidbare notitie-app die eenvoudige Markdown-bestanden gebruikt voor opslag.

Obsidian is gratis voor alle doeleinden, inclusief persoonlijk, commercieel en non-profitgebruik.

Obsidian biedt ook een [commerciële add-on voor synchronisatie](https://obsidian.md/sync) met mobiele apps op iOS en Android. (https://obsidian.md/pricing).

Je start Obsidian met `Super + Shift + O`. Om themasynchronisatie te gebruiken, moet je het thema `Omarchy` selecteren in de instellingen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) is Omarchy's eigen doodeenvoudige Markdown-schrijfapp. Geen vaults, geen plugins, alleen jij en de woorden.

Je start Omawrite met `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) is een eenvoudige tool voor beeldbewerking die geweldig is voor bijsnijden, formaat wijzigen en andere basale bewerkingen. Verwacht alleen geen Photoshop-alternatief. Maar hij heeft nog wel een Magic Wand en lagen!

Je start Pinta via de application launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) is een theming-app die kleuren uit een achtergrondafbeelding kan halen en er een compleet, samenhangend thema van kan maken. Het is de makkelijkste manier om [je eigen thema te maken](43-making-your-own-theme.md).

Je start Aether via de application launcher (`Super + Space`).

## LocalSend

Met [LocalSend](https://localsend.org/) kun je bestanden sturen naar andere apparaten op hetzelfde netwerk waarop de app draait, zoals Apple's AirDrop. Hij is alleen cross-platform, dus je kunt bestanden sturen naar en vanaf Windows, macOS, Android, iOS en natuurlijk Linux.

Je opent het menu Share met `Super + Ctrl + S` of onder _Trigger > Share_ in het Omarchy-menu. Het geeft je vier opties:

- **Clipboard** stuurt wat je hebt gekopieerd als tekstbestand. Geweldig om een link of een fragment op je telefoon te krijgen zonder jezelf te e-mailen.
- **File** opent een bestandsselector waarin je er meerdere tegelijk kunt selecteren.
- **Folder** stuurt een hele map.
- **Receive** opent LocalSend zelf, zodat een ander apparaat iets naar jou kan sturen.

Hetzelfde werkt vanuit de terminal met `omarchy share clipboard`, `omarchy share file [path]` en `omarchy share folder [path]`. Laat je het pad weg, dan krijg je de selector.

Je kunt ook rechtstreeks vanuit de bestandsbeheerder sturen: klik met de rechtermuisknop op een selectie in Nautilus en kies _Send via LocalSend_.

De firewall van Omarchy is standaard gesloten, behalve voor de poort van LocalSend, dus dit werkt direct bij een verse installatie. Zie [security](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) is een compleet officepakket met tekstverwerker, spreadsheet, presentaties, tekenapplicatie en meer. Het is compatibel met bestanden van Microsoft Office, dus dit is een geweldige manier om die Word-documenten te kunnen openen.

Je start LibreOffice via de application launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) is Omarchy's eigen doodeenvoudige presentatie-app. Je deck is één enkel Markdown-bestand met de afbeeldingen en video's ernaast: schrijf elke slide onder een live preview, sleep slides in de juiste volgorde en presenteer vervolgens fullscreen of exporteer naar PDF en PowerPoint. Hij neemt zelfs je Omarchy-thema over.

Je start Hype via de application launcher (`Super + Space`). Druk in de app op `?` om elke sneltoets te zien.

## Signed

[Signed](https://github.com/omacom/signed) is Omarchy's eigen doodeenvoudige manier om PDF's te ondertekenen en in te vullen. Plaats je opgeslagen handtekening, tekst en de datum van vandaag waar je wilt op een pagina en sla vervolgens een ondertekend exemplaar op naast het origineel. Zie [Filling out PDFs](27-filling-out-pdfs.md) voor hoe dat werkt.

Je start Signed via de application launcher (`Super + Space`), of opent er een PDF mee vanuit de bestandsbeheerder.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) is Omarchy's eigen doodeenvoudige rekenmachine, die in een zwevend venster opent.

Je start Omacalc met `Super + Shift + Q` (of de rekenmachinetoets, als je toetsenbord die heeft).

## Signal

[Signal](https://signal.org/) is de pionier van E2E-versleutelde berichtenuitwisseling, en een geweldige communicatieoptie voor iedereen die liever niet via een van de grote techconglomeraten gaat.

Je start Signal met `Super + Shift + G`. Het maakt geen deel uit van de basisinstallatie, dus de eerste keer dat je daarop drukt, zal Omarchy aanbieden het voor je te installeren (het staat ook onder _Install > Service_ in het Omarchy-menu).

## Omaview

[Omaview](https://github.com/omacom/omaview) is Omarchy's eigen doodeenvoudige fotoviewer en mediaspeler: één venster voor je foto's, video's en muziek. Open een foto en blader met de pijltjestoetsen door de rest van de map, `N` en `P` doen dat voor alles, en `Ctrl + M` toont de hele map als raster. Hij toont ook HEIC-, AVIF- en JPEG XL-foto's, en gaat verder waar je was gebleven bij alles wat lang is.

Druk op `F` voor fullscreen, `E` om een foto te bewerken in Omasnap of een video te trimmen in Omacut, `Ctrl + P` om een foto af te drukken en `Delete` om een bestand naar de Trash te verplaatsen (`Ctrl + Z` haalt het terug). Druk in de app op `?` om elke sneltoets te zien.

Je start Omaview als _Media Viewer_ via de application launcher (`Super + Space`), of dubbelklikt gewoon op een foto, video of nummer in de bestandsbeheerder.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) is Omarchy's eigen doodeenvoudige videotrimmer. Als je alleen het begin en einde van een clip hoeft te knippen, is dat beter dan een volledige video-editor opstarten.

Je start Omacut via de application launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) is Omarchy's eigen doodeenvoudige webcamrecorder. Kies één keer je camera en microfoon, druk dan op `Space` om op te nemen, en nog een keer om dezelfde take te pauzeren en te hervatten. Hij neemt altijd op in de hoogste resolutie van je camera, met een live microfoonmeter zodat je je niveaus kunt controleren voordat je begint.

Stop de take en hij opent meteen in een ingebouwde editor. Dubbelklik op een clip om hem te splitsen, sleep aan de handvatten om elk stuk te trimmen en verwijder de delen die je niet wilt. Sla hem vervolgens op als MP4. Je originele opname blijft bewaard totdat je hem weggooit, dus je kunt altijd terugkomen en hem anders knippen.

Je start Monologue via de application launcher (`Super + Space`).
