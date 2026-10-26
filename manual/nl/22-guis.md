# GUI's

## Bestanden

Bestanden (Nautilus) is de grafische bestandsbeheerder. Met `Super + Shift + F` open je het, en met `Super + Shift + Alt + F` open je het in de map waarin je terminal zich bevindt, wat je een hoop geklik bespaart. Met `Ctrl + L` kun je een pad typen, en als je op `Space` drukt bij een bestand krijg je een snelle preview zonder iets te openen.

Steek een USB-stick of een SD-kaart in en hij wordt automatisch gemount, dus hij verschijnt gewoon in de zijbalk. Voor alles wat ingewikkelder is — een schijf formatteren, de SMART-status controleren, partities aanmaken — start je _Disks_ vanuit de applicatiestarter (`Super + Space`).

Dubbelklikken volgt verstandige standaardinstellingen: afbeeldingen openen in imv, video in mpv, PDF's in Document Viewer en platte tekst in Neovim.

## Disktree

Als de schijf volloopt en je geen idee hebt wat hem opeet, start je [Disktree](https://github.com/tobi/disktree) vanuit de applicatiestarter (`Super + Space`). Het toont een grafische treemap van je home-map. Grotere blokken nemen meer ruimte in; loop met het toetsenbord of de muis door mappen, markeer wat weg moet en controleer je selecties voordat je iets verwijdert. Voer `disktree --disk` uit om de hele schijf te scannen.

## Obsidian

[Obsidian](https://obsidian.md/) is een gratis en zeer uitbreidbare notitie-app die eenvoudige Markdown-bestanden gebruikt voor opslag.

Obsidian is gratis voor alle doeleinden, inclusief persoonlijk, commercieel en non-profitgebruik.

Obsidian biedt ook een [commerciële add-on voor synchronisatie](https://obsidian.md/sync) met mobiele apps op iOS en Android. (https://obsidian.md/pricing).

Je start Obsidian met `Super + Shift + O`. Om themasynchronisatie te gebruiken, moet je het thema `Omarchy` selecteren onder instellingen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) is Omarchy's eigen doodeenvoudige Markdown-schrijfapp. Geen vaults, geen plugins, alleen jij en de woorden.

Je start Omawrite met `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) is een eenvoudige tool voor beeldbewerking die geweldig is voor bijsnijden, formaat wijzigen en andere eenvoudige bewerkingen. Verwacht alleen geen Photoshop-alternatief. Maar hij heeft nog steeds een Magic Wand en lagen!

Je start Pinta via de applicatiestarter (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) is een thema-app die kleuren uit een achtergrondafbeelding kan halen en er een compleet, samenhangend thema van kan maken. Het is de makkelijkste manier om [je eigen thema te maken](43-making-your-own-theme.md).

Je start Aether via de applicatiestarter (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) laat je bestanden sturen naar andere apparaten op hetzelfde netwerk waarop de app draait, zoals Apple's AirDrop. Het is echter cross-platform, dus je kunt bestanden sturen naar en vanaf Windows, macOS, Android, iOS en natuurlijk Linux.

Je opent het menu Delen met `Super + Ctrl + S` of via _Trigger > Share_ in het Omarchy-menu. Het geeft je vier opties:

- **Clipboard** stuurt wat je hebt gekopieerd als een tekstbestand. Geweldig om een link of een snippet op je telefoon te krijgen zonder jezelf te e-mailen.
- **File** opent een bestandsselector waarin je er meerdere tegelijk kunt selecteren.
- **Folder** stuurt een hele map.
- **Receive** opent LocalSend zelf, zodat een ander apparaat iets naar je kan sturen.

Hetzelfde werkt vanuit de terminal met `omarchy share clipboard`, `omarchy share file [path]` en `omarchy share folder [path]`. Laat het pad weg en je krijgt de selector.

Je kunt ook rechtstreeks vanuit de bestandsbeheerder sturen: klik met de rechtermuisknop op een selectie in Nautilus en kies _Send via LocalSend_.

De firewall van Omarchy is standaard gesloten, behalve voor de poort van LocalSend, dus dit werkt direct op een nieuwe installatie. Zie [beveiliging](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) is een compleet officepakket met tekstverwerker, spreadsheet, presentaties, tekenapplicatie en meer. Het is compatibel met bestanden uit Microsoft Office, dus dit is een geweldige manier om die Word-documenten te kunnen openen.

Je start LibreOffice via de applicatiestarter (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) is Omarchy's eigen doodeenvoudige presentatie-app. Je deck is één enkel Markdown-bestand met zijn afbeeldingen en video's ernaast: schrijf elke slide onder een live preview, sleep slides in de juiste volgorde en presenteer daarna fullscreen of exporteer naar PDF en PowerPoint. Het pikt zelfs je Omarchy-thema op.

Je start Hype via de applicatiestarter (`Super + Space`). Druk erbinnen op `?` om elke sneltoets te zien.

## Signed

[Signed](https://github.com/omacom/signed) is Omarchy's eigen doodeenvoudige manier om PDF's te ondertekenen en in te vullen. Plaats je opgeslagen handtekening, tekst en de datum van vandaag waar je wilt op een pagina en sla daarna een ondertekende kopie op naast het origineel. Zie [PDF's invullen](27-filling-out-pdfs.md) voor hoe dat werkt.

Je start Signed via de applicatiestarter (`Super + Space`), of je opent er een PDF mee vanuit de bestandsbeheerder.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) is Omarchy's eigen doodeenvoudige rekenmachine, die opent in een zwevend venster.

Je start Omacalc met `Super + Shift + Q` (of de rekenmachinetoets, als je toetsenbord er een heeft).

## Signal

[Signal](https://signal.org/) is de pionier van E2E-versleutelde berichtgeving en een geweldige communicatieoptie voor iedereen die liever niet via een van de grote techconglomeraten gaat.

Je start Signal met `Super + Shift + G`. Het maakt geen deel uit van de basisinstallatie, dus de eerste keer dat je daarop drukt, biedt Omarchy aan om het voor je te installeren (het staat ook onder _Install > Service_ in het Omarchy-menu).

## mpv

[mpv](https://mpv.io/) is een eenvoudige, snelle mediaspeler die bijna alles uit elke bron afspeelt. Geweldig om video's te bekijken.

Je start mpv via de applicatiestarter (`Super + Space`) of je dubbelklikt gewoon op een video in de bestandsbeheerder.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) is Omarchy's eigen doodeenvoudige videotrimmer. Als je alleen het begin en het einde van een clip hoeft af te knippen, is dit veel handiger dan een volledige video-editor opstarten.

Je start Omacut via de applicatiestarter (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) is Omarchy's eigen doodeenvoudige webcamrecorder. Kies één keer je camera en microfoon, druk daarna op `Space` om op te nemen en nogmaals om dezelfde take te pauzeren en te hervatten. Het neemt altijd op in de hoogste resolutie van je camera, met een live microfoonmeter zodat je je niveaus kunt controleren voordat je begint.

Stop de take en hij opent meteen in een ingebouwde editor. Dubbelklik op een clip om hem te splitsen, sleep aan de handvatten om elk stuk bij te snijden en verwijder de delen die je niet wilt. Sla hem daarna op als een MP4. Je originele opname blijft behouden totdat je hem weggooit, dus je kunt altijd terugkomen en hem anders knippen.

Je start Monologue via de applicatiestarter (`Super + Space`).
