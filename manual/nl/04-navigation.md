# Navigatie

Alles in Omarchy gebeurt via het toetsenbord — _ALLES!_ Wanneer het systeem voor het eerst opstart, kun je letterlijk niets doen met alleen de muis. Maar je kunt op `Super + Space` drukken om het Omarchy Menu te openen en van hieruit kun je vrijwel alles doen.

Maar het Omarchy-menu is niet eens bedoeld als de belangrijkste manier om het systeem meestal te bedienen. We kunnen sneller dan dat! Alle belangrijkste applicaties zijn direct aan afzonderlijke sneltoetsen gebonden. Je start de terminal met `Super + Return` en een browser met `Super + Shift + Return`. Probeer het een na het ander te doen, en je ziet de magie van Hyprland's tiling in actie:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Je kunt vervolgens op `Super + J` drukken om ze op elkaar te stapelen in plaats van naast elkaar:

 ![navigation-stacked](images/navigation-stacked.webp)

Druk nogmaals op `Super + J` om ze terug te brengen naar hun posities naast elkaar. Probeer vervolgens `Super + Shift + Arrow Right` terwijl je in de browser bent om de vensters te verwisselen.

Probeer nu `Super + Shift + T` om de Activity monitor te starten. Die verschijnt als een zwevend venster. Je kunt hem tegelen met `Super + T` (en druk daar nogmaals op om hem weer te laten zweven). Druk nu op `Super + Shift + F` om de bestandsbeheerder te openen. Je hebt dan een nette opstelling in vieren:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Je navigeert tussen het venster dat je actief wilt hebben met `Super + Arrow`. Dit wisselt de focus en verplaatst de cursor naar het midden van de nieuwe applicatie. Aan de rand van een scherm gaat het verder naar de monitor aan die kant.

Als je op `Super + Shift + 2` drukt, verplaats je de huidige gefocuste applicatie naar de tweede werkruimte. `Super + Shift + 1` verplaatst hem terug. (En `Super + Shift + Alt + 2` verplaatst de huidige gefocuste applicatie naar de tweede werkruimte zonder ernaartoe te schakelen).

Met meer dan één monitor heeft elke monitor zijn eigen werkruimten 1 tot en met 10. `Super + 2` gaat naar de tweede werkruimte van de monitor waarop je je bevindt, en de bovenbalk van elke monitor toont zijn eigen werkruimten en degene die hij weergeeft. `Super + Tab` doorloopt de werkruimten op de monitor waarop je je bevindt. `Super + Shift + Ctrl + Arrows` verplaatst het venster waarop je je bevindt naar de monitor in die richting, naar de werkruimte die deze weergeeft, en `Super + Shift + Alt + Arrows` verplaatst de werkruimte waarop je je bevindt naar de monitor in die richting, waar deze hetzelfde nummer krijgt als dat vrij is. Een monitor behoudt zijn werkruimten wanneer je hem loskoppelt: ze sluiten zich aan bij die van een ander scherm, genummerd na degene die dat al heeft, en keren terug onder hun oude nummers wanneer de monitor terugkeert.

Als je `Super` ingedrukt houdt en met de muis op een venster klikt, kun je herschikken waar het zit. Als je `Super` ingedrukt houdt en de rechtermuisknop gebruikt, kun je het venster vrij vergroten of verkleinen.

Je sluit een venster met `Super + W` of `Super + Q` (en sluit alle vensters met `Ctrl + Alt + Delete`).

Je kunt ook naar volledig scherm gaan met `Super + F` of zelfs alleen naar volledige breedte (met behoud van de bovenbalk) met `Super + Alt + F` of naar volledig scherm binnen een venster met `Super + Ctrl + F` (handig voor YouTube!).

### Dwindle versus scrolling-layout

De standaardindeling van Omarchy heet dwindle. Die houdt alle vensters die je op één werkruimte opent te allen tijde zichtbaar, zelfs als ze daarvoor kleiner moeten worden gemaakt.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Maar je kunt er ook voor kiezen om van een werkruimte de scrolling-layout te maken, waarbij vensters naast elkaar worden opgesteld, voorbij de zichtbare rand van het scherm. Je verandert één enkele werkruimte in deze indeling via `Super + L`.

Nogmaals op `Super + L` drukken maakt de werkruimte zwevend, waarbij vensters vrij overlappen en je ze zelf plaatst, en een derde keer drukken brengt hem terug naar dwindle. `Super + Alt + L` doorloopt ze in de andere richting. Een venster dat toch al zweeft — een dat je met `Super + T` hebt laten zweven, of een app die altijd zwevend opent — blijft zweven wanneer de werkruimte teruggaat naar tiling. De bovenbalk markeert de werkruimte waarop je je bevindt met zijn indeling: een vierkant voor dwindle, een cirkel voor scrolling en een driehoek voor floating. Op die markering klikken doorloopt de indeling ook.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

De keuze geldt per werkruimte, en blijft behouden. Je kunt dus werkruimte 1 op dwindle houden om te browsen en werkruimte 2 op scrolling voor code, en ze komen na een herstart op die manier terug.

Als je de scrolling-layout als standaard wilt gebruiken, kun je dat instellen in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Zwevende werkruimten

Een zwevende werkruimte werkt als een traditioneel bureaublad: vensters overlappen, en je verplaatst en schaalt ze zelf. Elk venster krijgt een titelbalk in de kleuren van je thema, met knoppen om te minimaliseren, maximaliseren en sluiten. `Super + M` minimaliseert het gefocuste venster ook. Een geminimaliseerd venster wacht in het dock; klik op zijn app om het terug te brengen. Klik op een venster om het naar voren te brengen. Schaal het vanaf elke rand of hoek. Dubbelklik op een titelbalk om het venster te maximaliseren terwijl de bovenbalk in zicht blijft, en nogmaals om zijn oude grootte terug te krijgen. Chrome en andere op Chromium gebaseerde browsers, Disks en Document Viewer slaan de titelbalk over en gebruiken in plaats daarvan hun eigen kopbalk; `Super + Alt + F` maximaliseert ze, en `Super + M` minimaliseert ze.

Een zwevende werkruimte toont ook een dock, met je vastgezette apps, alles wat draait, en een raster van elke app achter de apps-knop, dat `Super + Alt + Space` en _Apps_ in het Omarchy-menu ook openen. Klik met de rechtermuisknop op een app in het raster, of druk op `Delete`, om hem te verwijderen. Klik op een app om hem te openen, of om zijn venster naar voren te brengen; klik nogmaals om door zijn vensters te bladeren. Met een middelste muisklik open je een nieuw venster. Sleep een pictogram langs het dock om het te verplaatsen; door een draaiende app tussen de anderen in te slepen, blijft hij daar staan. Klik met de rechtermuisknop om een app in het dock te houden, hem eruit te halen of hem af te sluiten. Het dock gaat uit de weg voor een venster in volledig scherm. Klik met de rechtermuisknop op de apps-knop om het dock naar een andere rand te verplaatsen of het te laten verbergen totdat de aanwijzer zijn rand bereikt. De positie staat ook onder _Appearance > Dock > Dock Position_, en `omarchy dock position left` en `omarchy dock autohide on` stellen beide in vanaf een terminal. Apps die je in het dock houdt, zijn vervaagd zolang ze niet draaien.

Nieuwe werkruimten, en alle werkruimten waaraan je met `Super + L` geen eigen indeling hebt gegeven, gebruiken de standaardindeling. Het wijzigen van de standaard zet elke werkruimte zonder vensters terug naar deze, terwijl een werkruimte met vensters erop de indeling behoudt die hij heeft. Een venster dat naar het dock is geminimaliseerd, telt nog steeds als een venster op de werkruimte die het verliet. Kies hem onder _Appearance > Workspace Layout_: Tiling, Scrolling of Floating. `omarchy-hyprland-workspace-layout-default scrolling` stelt hem in vanaf een terminal.

### Vensters groeperen

Vensters kunnen worden gegroepeerd met `Super + G`. Zodra je in een groep zit, zal elk venster dat je start terwijl die actief is tot de groep behoren. Je kunt tussen deze gegroepeerde vensters bewegen met `Super + Ctrl + Arrow Left/Right` of `Super + Alt + 1/2/3/4` om direct in volgorde naar gegroepeerde vensters te gaan.

Je kunt een venster uit de groepering halen met `Super + Alt + G` of de hele groep ontbinden door nogmaals op `Super + G` te drukken. Ten slotte kun je vensters buiten de groep erin verplaatsen met `Super + Alt + Arrows`.

### Vensters losmaken

Je kunt een venster met `Super + O` uit zijn toewijzing aan een werkruimte losmaken. Dat pint het vast als een zwevend venster dat je volgt naar welke werkruimte je ook gaat. Geweldig voor videospelers en dergelijke.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-werkruimte

Er is een speciale scratchpad-werkruimte op volledige grootte die alles overlapt wat er op de werkruimte staat waarop je je momenteel bevindt. Je opent wat erop staat met `Super + S`, en je plaatst er vensters met `Super + Alt + S`.

Het werkt goed voor bedieningselementen of een terminal waarmee je snel wilt werken zonder de huidige werkruimte te verlaten.

### Quake-console

Ten slotte is er een Quake-console van halve hoogte die naar beneden valt over de werkruimte waarop je je momenteel bevindt. Schakel hem in en uit met `Super + Grave`, en plaats er een venster met `Super + Shift + Grave`.

Hij opent met je standaardagent klaar voor gebruik. Zolang de console één enkel venster bevat, valt hij naar beneden als een gecentreerd paneel in plaats van het scherm te overspannen. Zet er een tweede app op en hij gaat terug naar de volledige breedte, zodat de twee ruimte hebben om naast elkaar te zitten.

Om een venster van hetzij de scratchpad hetzij de console af te verplaatsen, stuur je het direct naar een andere werkruimte met iets als `Super + Shift + 1`.

### Het is even wennen!

Het duurt even om eraan te wennen je bureaublad op deze manier te navigeren, maar zodra je dat doet, zal het moeilijk zijn om terug te gaan naar een traditionele, muisgestuurde bureaubladervaring!
