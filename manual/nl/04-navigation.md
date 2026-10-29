# Navigatie

Alles in Omarchy gebeurt via het toetsenbord — _ALLES!_ Wanneer het systeem voor het eerst opstart, kun je letterlijk niets doen met alleen de muis. Maar je kunt op `Super + Space` drukken om het Omarchy Menu tevoorschijn te halen en vanaf daar kun je vrijwel alles doen.

Maar het Omarchy-menu is niet eens bedoeld als de belangrijkste manier om het systeem meestal te bedienen. We kunnen sneller dan dat! Alle belangrijkste applicaties zijn direct aan individuele sneltoetsen gebonden. Je start de terminal met `Super + Return` en een browser met `Super + Shift + Return`. Probeer ze na elkaar te doen, en je ziet de magie van Hyprland's tiling in actie:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Je kunt vervolgens op `Super + J` drukken om ze op elkaar te stapelen in plaats van naast elkaar:

 ![navigation-stacked](images/navigation-stacked.webp)

Druk opnieuw op `Super + J` om ze terug te zetten naar hun posities naast elkaar. Probeer vervolgens `Super + Shift + Arrow Right` terwijl je op de browser zit om de vensters te verwisselen.

Probeer nu `Super + Shift + T` om de Activity-monitor te starten. Die verschijnt als een zwevend venster. Je kunt hem tegelen met `Super + T` (en druk daar nogmaals op om hem weer zwevend te maken). Druk nu op `Super + Shift + F` om de bestandsbeheerder te openen. Je krijgt een nette opstelling in vieren:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Je navigeert tussen het venster dat je actief wilt hebben met `Super + Arrow`. Daarmee wissel je van focus en beweeg je de cursor naar het midden van de nieuwe applicatie. Aan de rand van een scherm gaat het verder naar de monitor aan die kant.

Als je op `Super + Shift + 2` drukt, verplaats je de huidige gefocuste applicatie naar de tweede werkruimte. `Super + Shift + 1` verplaatst hem terug. (En `Super + Shift + Alt + 2` verplaatst de huidige gefocuste applicatie naar de tweede werkruimte zonder ernaartoe te wisselen).

Met meer dan één monitor heeft elke monitor zijn eigen werkruimtes 1 tot en met 10. `Super + 2` gaat naar de tweede werkruimte van de monitor waarop je zit, en de bovenste balk van elke monitor toont zijn eigen werkruimtes en de werkruimte die hij weergeeft. `Super + Tab` doorloopt de werkruimtes op de monitor waarop je zit. `Super + Shift + Ctrl + Arrows` verplaatst het venster waarop je zit naar de monitor in die richting, naar de werkruimte die die weergeeft, en `Super + Shift + Alt + Arrows` verplaatst de werkruimte waarop je zit naar de monitor in die richting, waar hij hetzelfde nummer krijgt als dat vrij is. Een monitor behoudt zijn werkruimtes wanneer je hem loskoppelt: ze voegen zich bij een ander scherm, genummerd na de werkruimtes die dat al heeft, en gaan terug onder hun oude nummers wanneer de monitor terugkeert.

Als je `Super` ingedrukt houdt en met de muis op een venster klikt, kun je opnieuw ordenen waar het zit. Als je `Super` ingedrukt houdt en de rechtermuisknop gebruikt, kun je het formaat van het venster vrij aanpassen.

Je sluit een venster met `Super + W` of `Super + Q` (en sluit alle vensters met `Ctrl + Alt + Delete`).

Je kunt ook volledig scherm gaan met `Super + F` of zelfs gewoon volledige breedte (met behoud van de bovenste balk) met `Super + Alt + F` of volledig scherm binnen een venster met `Super + Ctrl + F` (ideaal voor YouTube!).

### Dwindle versus scrolling-layout

De standaardlayout van Omarchy heet dwindle. Die houdt alle vensters die je op een enkele werkruimte opent te allen tijde zichtbaar, zelfs als hij ze daarvoor moet verkleinen.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Maar je kunt er ook voor kiezen om een werkruimte te veranderen in de scrolling-layout, waarbij vensters naast elkaar op een rij staan, voorbij de zichtbare rand van het scherm. Je verandert een enkele werkruimte in deze layout via `Super + L`.

Opnieuw op `Super + L` drukken maakt de werkruimte zwevend, waarbij vensters vrij overlappen en je ze zelf plaatst, en een derde druk brengt hem terug naar dwindle. `Super + Alt + L` doorloopt ze de andere kant op. Een venster dat toch al zweeft — een dat je eruit hebt gepopt met `Super + T`, of een app die altijd zwevend opent — blijft zweven wanneer de werkruimte teruggaat naar tiling. De bovenste balk markeert de werkruimte waarop je zit met zijn layout: een vierkant voor dwindle, een cirkel voor scrolling en een driehoek voor zwevend. Op dat teken klikken doorloopt de layout ook.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

De keuze is per werkruimte, en hij blijft behouden. Je kunt werkruimte 1 dus op dwindle houden om te browsen en werkruimte 2 op scrolling voor code, en ze komen na een herstart op die manier terug.

Als je de scrolling-layout als standaard wilt gebruiken, kun je dat instellen in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Zwevende werkruimtes

Een zwevende werkruimte werkt als een traditioneel bureaublad: vensters overlappen, en je verplaatst ze en past hun formaat zelf aan. Elk venster krijgt een titelbalk in de kleuren van je thema, met knoppen om te minimaliseren, te maximaliseren en te sluiten. `Super + M` minimaliseert het gefocuste venster ook. Een geminimaliseerd venster wacht in de dock; klik op zijn app om het terug te brengen. Klik op een venster om het naar voren te brengen. Pas het formaat aan vanaf elke rand of hoek. Dubbelklik op een titelbalk om het venster te maximaliseren terwijl de bovenste balk in beeld blijft, en nogmaals om het oude formaat terug te krijgen.

Een zwevende werkruimte toont ook een dock, met je vastgezette apps, alles wat draait, en een raster van elke app achter de apps-knop, die `Super + Alt + Space` en _Apps_ in het Omarchy-menu ook openen. Rechtsklik op een app op het raster, of druk op `Delete`, om hem te verwijderen. Klik op een app om hem te openen, of om zijn venster naar voren te brengen; klik nogmaals om door zijn vensters te doorlopen. Middelklik opent een nieuw venster. Sleep een pictogram langs de dock om het te verplaatsen; een draaiende app tussen de anderen in slepen houdt hem daar. Rechtsklik om een app in de dock te houden, hem eruit te halen of hem af te sluiten. De dock maakt plaats voor een venster in volledig scherm. Rechtsklik op de apps-knop om de dock naar een andere rand te verplaatsen of hem te laten verbergen totdat de aanwijzer zijn rand bereikt. De positie staat ook onder _Appearance > Dock > Dock Position_, en `omarchy dock position left` en `omarchy dock autohide on` stellen beide in vanaf een terminal. Apps die je in de dock houdt zijn vervaagd zolang ze niet draaien.

Nieuwe werkruimtes, en elke werkruimte waaraan je geen eigen layout hebt gegeven met `Super + L`, gebruiken de standaardlayout. De standaard wijzigen zet elke werkruimte zonder vensters terug naar hem, terwijl een werkruimte met vensters erop de layout behoudt die hij heeft. Een venster dat naar de dock is geminimaliseerd, telt nog steeds als een venster op de werkruimte die hij verliet. Kies hem onder _Appearance > Workspace Layout_: Tiling, Scrolling of Floating. `omarchy-hyprland-workspace-layout-default scrolling` stelt hem in vanaf een terminal.

### Vensters groeperen

Vensters kunnen worden gegroepeerd met `Super + G`. Zodra je in een groep zit, behoort elk venster dat je start terwijl die actief is tot de groep. Je kunt tussen deze gegroepeerde vensters bewegen met `Super + Ctrl + Arrow Left/Right` of `Super + Alt + 1/2/3/4` om direct naar een gegroepeerd venster in volgorde te gaan.

Je kunt een venster uit de groepering halen met `Super + Alt + G` of de hele groep ontmantelen door opnieuw op `Super + G` te drukken. Tot slot kun je vensters buiten de groep erin verplaatsen met `Super + Alt + Arrows`.

### Vensters eruit poppen

Je kunt een venster uit zijn werkruimtetoewijzing poppen met `Super + O`. Dat zet hem vast als een zwevend venster dat je volgt naar welke werkruimte je ook gaat. Ideaal voor videospelers en dergelijke.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-werkruimte

Er is een speciale scratchpad-werkruimte op volledige grootte die over de werkruimte heen ligt waarop je momenteel zit. Je krijgt toegang tot wat erop staat met `Super + S`, en je plaatst vensters daar met `Super + Alt + S`.

Hij werkt goed voor bedieningselementen of een terminal waarmee je snel wilt werken zonder de huidige werkruimte te verlaten.

### Quake-console

Tot slot is er een Quake-console van halve hoogte die over de werkruimte heen naar beneden komt waarop je momenteel zit. Schakel hem in en uit met `Super + Grave`, en plaats een venster daar met `Super + Shift + Grave`.

Hij opent met je standaard-agent klaar voor gebruik. Zolang de console een enkel venster bevat, komt hij naar beneden als een gecentreerd paneel in plaats van de breedte van het scherm te beslaan. Zet er een tweede app op en hij gaat terug naar de volledige breedte, zodat de twee ruimte hebben om naast elkaar te zitten.

Om een venster van hetzij de scratchpad hetzij de console af te halen, stuur je hem direct naar een andere werkruimte met iets als `Super + Shift + 1`.

### Het is even wennen!

Het duurt even om te wennen aan het op deze manier navigeren op je bureaublad, maar zodra je dat doet, wordt het moeilijk om terug te gaan naar een traditionele, muisgestuurde bureaubladervaring!
