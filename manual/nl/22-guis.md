# GUI's

## Files

Files (Nautilus) is de grafische bestandsbeheerder. `Super + Shift + F` opent hem, en `Super + Shift + Alt + F` opent hem in de map waar je terminal zich in bevindt, wat veel klikken bespaart. Met `Ctrl + L` kun je een pad typen, en door op `Space` te drukken op een bestand krijg je een snel voorbeeld zonder iets te openen.

Steek een USB-stick of een SD-kaart erin en deze wordt automatisch aangekoppeld, zodat hij gewoon in de zijbalk verschijnt. Voor alles wat ingewikkelder is — een schijf formatteren, de SMART-gezondheid controleren, partities maken — start je _Disks_ vanuit de app-launcher (`Super + Space`).

Dubbelklikken volgt verstandige standaardwaarden: afbeeldingen openen in imv, video in mpv, pdf's in Document Viewer, en platte tekst in Neovim.

## Disktree

Wanneer de schijf vol raakt en je geen idee hebt wat hem opvreet, start je [Disktree](https://github.com/tobi/disktree) vanuit de app-launcher (`Super + Space`). Het toont een grafische treemap van je thuismap. Grotere blokken nemen meer ruimte in; loop met het toetsenbord of de muis door mappen, markeer wat weg moet, en controleer je selecties voordat je iets verwijdert. Voer `disktree --disk` uit om de hele schijf te scannen.

## Obsidian

[Obsidian](https://obsidian.md/) is een gratis en zeer uitbreidbare notitie-applicatie die eenvoudige Markdown-bestanden gebruikt voor opslag.

Obsidian is gratis voor alle doeleinden, inclusief persoonlijk, commercieel en non-profit gebruik.

Obsidian biedt ook een [commerciële add-on voor synchroniseren](https://obsidian.md/sync) met mobiele apps op iOS en Android. (https://obsidian.md/pricing).

Je start Obsidian met `Super + Shift + O`. Om themasynchronisatie te gebruiken, moet je het `Omarchy`-thema selecteren onder instellingen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) is Omarchy's eigen doodsimpele Markdown-schrijfapp. Geen vaults, geen plugins, alleen jij en de woorden.

Je start Omawrite met `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) is een eenvoudige tool voor beeldbewerking die geweldig is voor bijsnijden, formaat wijzigen en andere eenvoudige manipulaties. Verwacht alleen geen Photoshop-alternatief. Maar het heeft nog steeds een Toverstaf en lagen!

Je start Pinta via de applicatie-launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) is een thema-applicatie die kleuren uit een achtergrondafbeelding kan extraheren en er een compleet, samenhangend thema van kan maken. Het is de gemakkelijkste manier om [je eigen thema te maken](43-making-your-own-theme.md).

Je start Aether via de applicatie-launcher (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) laat je bestanden sturen naar andere apparaten op hetzelfde netwerk die de app draaien, zoals Apple's AirDrop. Het is echter cross-platform, dus je kunt bestanden sturen van en naar Windows, macOS, Android, iOS en natuurlijk Linux.

Je kunt het Delen-menu openen met `Super + Ctrl + S` of onder _Activeren > Delen_ in het Omarchy-menu. Het geeft je vier opties:

- **Clipboard** stuurt wat je hebt gekopieerd als een tekstbestand. Geweldig om een link of een snippet op je telefoon te krijgen zonder jezelf te e-mailen.
- **File** opent een bestandsselectie waar je er meerdere tegelijk kunt selecteren.
- **Folder** stuurt een hele map.
- **Receive** opent LocalSend zelf, zodat een ander apparaat iets naar jou kan sturen.

Hetzelfde werkt vanuit de terminal met `omarchy share clipboard`, `omarchy share file [path]` en `omarchy share folder [path]`. Laat het pad weg en je krijgt de selectie.

Je kunt ook direct vanuit de bestandsbeheerder sturen: klik met de rechtermuisknop op een selectie in Nautilus en kies _Send via LocalSend_.

Omarchy's firewall is standaard gesloten, behalve voor de poort van LocalSend, dus dit werkt direct op een verse installatie. Zie [beveiliging](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) is een compleet office-pakket met tekstverwerker, spreadsheet, presentaties, tekenapplicatie en meer. Het is compatibel met bestanden van Microsoft Office, dus dit is een geweldige manier om die Word-documenten te kunnen openen.

Je start LibreOffice via de applicatie-launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) is Omarchy's eigen doodsimpele presentatie-app. Je deck is een enkel Markdown-bestand met de afbeeldingen en video's ernaast: schrijf elke dia onder een live voorbeeld, sleep dia's in volgorde, en presenteer dan fullscreen of exporteer naar PDF en PowerPoint. Het neemt zelfs je Omarchy-thema over.

Je start Hype via de applicatie-launcher (`Super + Space`). Druk erin op `?` om elke sneltoets te zien.

## Signed

[Signed](https://github.com/omacom/signed) is Omarchy's eigen doodsimpele manier om pdf's te ondertekenen en in te vullen. Zet je opgeslagen handtekening, tekst en de datum van vandaag overal op een pagina, en sla dan een ondertekende kopie op naast het origineel. Zie [Pdf's invullen](27-filling-out-pdfs.md) voor hoe dat moet.

Je start Signed via de applicatie-launcher (`Super + Space`), of open er een pdf mee vanuit de bestandsbeheerder.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) is Omarchy's eigen doodsimpele rekenmachine, die opent in een zwevend venster.

Je start Omacalc met `Super + Ctrl + Q` (of de rekenmachinetoets, als je toetsenbord er een heeft).

## Signal

[Signal](https://signal.org/) is de pionier van E2E-versleutelde berichtgeving, en een geweldige communicatieoptie voor iedereen die liever niet via een van de grote techconglomeraten gaat.

Je start Signal met `Super + Shift + G`. Het maakt geen deel uit van de basisinstallatie, dus de eerste keer dat je daarop drukt, biedt Omarchy aan om het voor je te installeren (het staat ook onder _Installeren > Dienst_ in het Omarchy-menu).

## mpv

[mpv](https://mpv.io/) is een eenvoudige, snelle mediaspeler die bijna alles van elke bron afspeelt. Geweldig om video's te bekijken.

Je start mpv via de applicatie-launcher (`Super + Space`) of dubbelklik gewoon op een video in de bestandsbeheerder.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) is Omarchy's eigen doodsimpele video-trimmer. Wanneer je alleen het begin en einde van een clip hoeft te knippen, verslaat het het opstarten van een volledige video-editor.

Je start Omacut via de applicatie-launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) is Omarchy's eigen doodsimpele webcamrecorder. Kies één keer je camera en microfoon, druk dan op `Space` om op te nemen, en nogmaals om dezelfde take te pauzeren en te hervatten. Het neemt altijd op op de hoogste resolutie van je camera, met een live microfoonmeter zodat je je niveaus kunt controleren voordat je begint.

Stop de take en hij opent direct in een ingebouwde editor. Dubbelklik op een clip om hem te splitsen, sleep de handvatten om elk stuk te trimmen, en verwijder de delen die je niet wilt. Sla het daarna op als MP4. Je originele opname wordt bewaard totdat je hem weggooit, dus je kunt altijd terugkomen en hem anders knippen.

Je start Monologue via de applicatie-launcher (`Super + Space`).
