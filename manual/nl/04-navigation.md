# Navigatie

Alles in Omarchy gebeurt via het toetsenbord — _ALLES!_ Wanneer het systeem voor het eerst opstart, kun je letterlijk niets doen met alleen de muis. Maar je kunt op `Super + Space` drukken om het Omarchy Menu tevoorschijn te halen en van daaruit kun je vrijwel alles doen.

Maar het Omarchy-menu is niet eens bedoeld als de belangrijkste manier om het systeem meestal te bedienen. We kunnen sneller dan dat! Alle belangrijkste applicaties zijn direct gekoppeld aan afzonderlijke sneltoetsen. Je start de terminal met `Super + Return` en een browser met `Super + Shift + Return`. Probeer ze achter elkaar te doen, en je zult de magie van Hyprlands tiling in actie zien:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Je kunt vervolgens op `Super + J` drukken om ze boven op elkaar te stapelen in plaats van naast elkaar:

 ![navigation-stacked](images/navigation-stacked.webp)

Druk nogmaals op `Super + J` om ze terug te brengen naar hun posities naast elkaar. Probeer dan `Super + Shift + Arrow Right` terwijl je in de browser zit om de vensters te verwisselen.

Probeer nu `Super + Ctrl + T` om de Activity-monitor te starten. Die verschijnt als een zwevend venster. Je kunt hem tegelen met `Super + T` (en druk daar nogmaals op om hem weer zwevend te maken). Druk nu op `Super + Shift + F` om de bestandsbeheerder te openen. Je krijgt een nette opstelling in vieren:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Je navigeert tussen de vensters die je actief wilt hebben met `Super + Arrow`. Hiermee wissel je de focus en verplaats je de cursor naar het midden van de nieuwe applicatie.

Als je op `Super + Shift + 2` drukt, verplaats je de huidige gefocuste applicatie naar het tweede werkblad. `Super + Shift + 1` verplaatst hem terug. (En `Super + Shift + Alt + 2` verplaatst de huidige gefocuste applicatie naar het tweede werkblad zonder ernaar over te schakelen).

Als je `Super` ingedrukt houdt en met de muis op een venster klikt, kun je herschikken waar het staat. Als je `Super` ingedrukt houdt en de rechtermuisknop gebruikt, kun je het venster vrij van grootte veranderen.

Je sluit een venster met `Super + W` of `Super + Q` (en sluit alle vensters met `Ctrl + Alt + Delete`).

Je kunt ook naar volledig scherm gaan met `Super + F` of zelfs gewoon naar volledige breedte (met behoud van de bovenbalk) met `Super + Alt + F` of volledig scherm binnen een venster met `Super + Ctrl + F` (handig voor YouTube!).

### Dwindle vs scrollende layout

De standaardlayout van Omarchy heet dwindle. Die houdt alle vensters die je op een enkel werkblad opent te allen tijde zichtbaar, zelfs als hij ze daarvoor moet verkleinen.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Maar je kunt er ook voor kiezen om een werkblad te veranderen in de scrollende layout, waarbij vensters naast elkaar worden opgesteld, voorbij de zichtbare rand van het scherm. Je verandert een enkel werkblad in deze layout via `Super + L`.

Nogmaals op `Super + L` drukken maakt het werkblad zwevend, waarbij vensters vrij overlappen en je ze zelf plaatst, en een derde keer drukken brengt het terug naar dwindle. `Super + Alt + L` doorloopt ze de andere kant op. Een venster dat sowieso zweeft — een dat je eruit hebt gehaald met `Super + T`, of een app die altijd zwevend opent — blijft zweven wanneer het werkblad teruggaat naar tiling. De bovenbalk markeert het werkblad waarop je zit met zijn layout: een vierkant voor dwindle, een cirkel voor scrollen en een driehoek voor zwevend. Klikken op die markering doorloopt de layout ook.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

De keuze is per werkblad, en hij blijft behouden. Dus je kunt werkblad 1 op dwindle houden voor browsen en werkblad 2 op scrollen voor code, en ze komen na een herstart zo terug.

Als je de scrollende layout als standaard wilt gebruiken, kun je dat instellen in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Zwevende werkbladen

Een zwevend werkblad werkt als een traditioneel bureaublad: vensters overlappen, en je verplaatst en vergroot of verkleint ze zelf. Elk venster krijgt een titelbalk in de kleuren van je thema, met knoppen om te minimaliseren, maximaliseren en sluiten. `Super + M` minimaliseert het gefocuste venster ook. Een geminimaliseerd venster wacht in het dock; klik op de bijbehorende app om het terug te halen. Klik op een venster om het naar voren te halen. Verander de grootte vanaf elke rand of hoek. Dubbelklik op een titelbalk om het venster te maximaliseren terwijl de bovenbalk in beeld blijft, en nogmaals om de oude grootte terug te krijgen.

Een zwevend werkblad toont ook een dock, met je vastgezette apps, alles wat draait, en een raster van elke app achter de apps-knop, die `Super + Alt + Space` en _Apps_ in het Omarchy-menu ook openen. Klik met rechts op een app in het raster, of druk op `Delete`, om hem te deïnstalleren. Klik op een app om hem te openen, of om zijn venster naar voren te halen; klik nogmaals om door zijn vensters te bladeren. Middelklik opent een nieuw venster. Sleep een pictogram langs het dock om het te verplaatsen; een draaiende app tussen de anderen slepen houdt hem daar. Klik met rechts om een app in het dock te houden, hem eruit te halen, of hem af te sluiten. Het dock gaat uit de weg voor een venster op volledig scherm. Klik met rechts op de apps-knop om het dock naar een andere rand te verplaatsen of het te laten verbergen totdat de aanwijzer zijn rand bereikt. De positie staat ook onder _Trigger > Appearance > Dock > Dock Position_, en `omarchy dock position left` en `omarchy dock autohide on` stellen beide in vanaf een terminal. Apps die je in het dock houdt, zijn vervaagd zolang ze niet draaien.

Nieuwe werkbladen, en elk werkblad dat je met `Super + L` geen eigen layout hebt gegeven, gebruiken de standaardlayout. De standaard veranderen reset elk werkblad zonder vensters daarnaar, terwijl een werkblad met vensters erop de layout behoudt die het heeft. Een venster dat naar het dock is geminimaliseerd telt nog steeds als een venster op het werkblad dat het verliet. Kies hem onder _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling, of Floating. `omarchy-hyprland-workspace-layout-default scrolling` stelt hem in vanaf een terminal.

### Vensters groeperen

Vensters kunnen worden gegroepeerd met `Super + G`. Zodra je in een groep zit, zal elk venster dat je start terwijl die actief is tot de groep behoren. Je kunt tussen deze gegroepeerde vensters bewegen met `Super + Ctrl + Arrow Left/Right` of `Super + Alt + 1/2/3/4` om direct in volgorde naar een gegroepeerd venster te gaan.

Je kunt een venster uit de groepering verplaatsen met `Super + Alt + G` of de hele groep ontbinden door nogmaals op `Super + G` te drukken. Ten slotte kun je vensters buiten de groep erin verplaatsen met `Super + Alt + Arrows`.

### Vensters losmaken

Je kunt een venster uit zijn werkbladtoewijzing laten springen met `Super + O`. Dat zet het vast als een zwevend venster dat je volgt naar welk werkblad je ook gaat. Geweldig voor videospelers en dergelijke.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-werkblad

Ten slotte is er een speciaal scratchpad-werkblad dat naar beneden klapt over welk werkblad je je ook bevindt, net als een Quake-console. Schakel het in en uit met `Super + Grave` of `Super + S`, en plaats er een venster met `Super + Shift + Grave` of `Super + Alt + S`.

Het werkt bijzonder goed voor een terminal waarin een agent draait, of voor bedieningselementen waarmee je snel wilt werken zonder het huidige werkblad te verlaten. Om een venster van de scratchpad af te verplaatsen, stuur je het direct naar een ander werkblad met iets als `Super + Shift + 1`.

Zolang de scratchpad één enkel venster bevat, klapt hij naar beneden als een gecentreerd paneel in plaats van het scherm te overspannen. Zet er een tweede app op en hij gaat terug naar de volledige breedte, zodat de twee ruimte hebben om naast elkaar te zitten.

### Het is even wennen!

Het duurt even om eraan te wennen je bureaublad zo te navigeren, maar als je het eenmaal doet, zal het moeilijk zijn om terug te gaan naar een traditionele muisgestuurde bureaubladervaring!
