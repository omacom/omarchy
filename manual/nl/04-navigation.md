# Navigatie

Alles in Omarchy gebeurt via het toetsenbord — _ALLES!_ Wanneer het systeem voor het eerst start, kun je letterlijk niets doen met alleen de muis. Maar je kunt op `Super + Space` drukken om het Omarchy Menu te onthullen en van hieruit kun je zo ongeveer alles doen.

Maar het Omarchy-menu is niet eens bedoeld om meestal de belangrijkste manier te zijn om het systeem te bedienen. We kunnen sneller dan dat! Alle belangrijkste applicaties zijn direct gebonden aan individuele sneltoetsen. Je start de terminal met `Super + Return` en een browser met `Super + Shift + Return`. Probeer het een na het ander te doen, en je zult de magie van Hyprland's tiling in actie zien:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Je kunt dan op `Super + J` drukken om ze op elkaar te stapelen in plaats van naast elkaar:

 ![navigation-stacked](images/navigation-stacked.webp)

Druk opnieuw op `Super + J` om ze terug te brengen naar hun posities naast elkaar. Probeer dan `Super + Shift + Arrow Right` terwijl je in de browser bent om de vensters te verwisselen.

Probeer nu `Super + Shift + T` om de Activity-monitor te starten. Die verschijnt als een zwevend venster. Je kunt hem tegelen met `Super + T` (en druk daar opnieuw op om hem weer zwevend te maken). Druk nu op `Super + Shift + F` om de bestandsbeheerder te openen. Je hebt een nette opstelling met vier vensters:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Je navigeert tussen het venster dat je actief wilt hebben met `Super + Arrow`. Dit schakelt de focus en verplaatst de cursor naar het midden van de nieuwe applicatie. Aan de rand van een scherm gaat het verder naar de monitor aan die kant.

Als je op `Super + Shift + 2` drukt, verplaats je de huidige gefocuste applicatie naar de tweede werkruimte. `Super + Shift + 1` verplaatst hem terug. (En `Super + Shift + Alt + 2` verplaatst de huidige gefocuste applicatie naar de tweede werkruimte zonder ernaartoe te schakelen).

Met meer dan één monitor heeft elke monitor zijn eigen werkruimtes 1 tot en met 10. `Super + 2` gaat naar de tweede werkruimte van de monitor waarop je je bevindt, en de bovenbalk van elke monitor toont zijn eigen werkruimtes en degene die hij weergeeft. `Super + Tab` doorloopt de werkruimtes op de monitor waarop je je bevindt. `Super + Shift + Ctrl + Arrows` verplaatst het venster waarop je je bevindt naar de monitor in die richting, naar de werkruimte die hij weergeeft, en `Super + Shift + Alt + Arrows` verplaatst de werkruimte waarop je je bevindt naar de monitor in die richting, waar hij hetzelfde nummer krijgt als dat vrij is. Een monitor behoudt zijn werkruimtes wanneer je hem loskoppelt: ze sluiten zich aan bij die van een ander scherm, genummerd na degene die het al heeft, en gaan terug onder hun oude nummers wanneer de monitor terugkeert.

Als je `Super` ingedrukt houdt en de muis gebruikt om op een venster te klikken, kun je herschikken waar het zit. Als je `Super` ingedrukt houdt en de rechtermuisknop gebruikt, kun je het venster vrij vergroten of verkleinen.

Je sluit een venster met `Super + W` of `Super + Q` (en sluit alle vensters met `Ctrl + Alt + Delete`).

Je kunt ook volledig scherm gaan met `Super + F` of zelfs alleen volledige breedte (met behoud van de bovenbalk) met `Super + Alt + F` of volledig scherm binnen een venster met `Super + Ctrl + F` (goed voor YouTube!).

### Dwindle vs scrollende indeling

De standaardindeling van Omarchy heet dwindle. Die houdt alle vensters die je op een enkele werkruimte opent te allen tijde zichtbaar, zelfs als hij ze daarvoor moet verkleinen.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Maar je kunt er ook voor kiezen om een werkruimte te veranderen in de scrollende indeling, waarbij vensters naast elkaar worden opgesteld, voorbij de zichtbare rand van het scherm. Je verandert een enkele werkruimte in deze indeling via `Super + L`.

Nogmaals op `Super + L` drukken verandert de werkruimte in zwevend, waarbij vensters vrij overlappen en je ze zelf plaatst, en een derde keer drukken brengt hem terug naar dwindle. `Super + Alt + L` doorloopt ze de andere kant op. Een venster dat toch al zweeft — een dat je eruit hebt gehaald met `Super + T`, of een app die altijd zwevend opent — blijft zweven wanneer de werkruimte teruggaat naar tegelen. De bovenbalk markeert de werkruimte waarop je je bevindt met zijn indeling: een vierkant voor dwindle, een cirkel voor scrollen, en een driehoek voor zwevend. Klikken op dat teken doorloopt ook de indeling.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

De keuze geldt per werkruimte, en blijft behouden. Dus je kunt werkruimte 1 op dwindle houden voor browsen en werkruimte 2 op scrollen voor code, en ze komen zo terug na een herstart.

Als je de scrollende indeling als standaard wilt gebruiken, kun je dat instellen in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Zwevende werkruimtes

Een zwevende werkruimte werkt als een traditioneel bureaublad: vensters overlappen, en je verplaatst en schaalt ze zelf. Elk venster krijgt een titelbalk in de kleuren van je thema, met knoppen om te minimaliseren, maximaliseren en sluiten. `Super + M` minimaliseert ook het gefocuste venster. Een geminimaliseerd venster wacht in het dock; klik op zijn app om hem terug te halen. Klik op een venster om het naar voren te brengen. Pas de grootte aan vanaf elke rand of hoek. Dubbelklik op een titelbalk om het venster te maximaliseren terwijl de bovenbalk in beeld blijft, en nogmaals om zijn oude grootte terug te krijgen.

Een zwevende werkruimte toont ook een dock, met je vastgepinde apps, alles wat draait, en een raster van elke app achter de apps-knop, die `Super + Alt + Space` en _Apps_ in het Omarchy-menu ook openen. Klik met de rechtermuisknop op een app op het raster, of druk op `Delete`, om hem te deïnstalleren. Klik op een app om hem te openen, of om zijn venster naar voren te brengen; klik nogmaals om door zijn vensters te bladeren. Middelklik opent een nieuw venster. Sleep een pictogram langs het dock om het te verplaatsen; een draaiende app tussen de anderen slepen houdt hem daar. Klik met de rechtermuisknop om een app in het dock te houden, hem eruit te halen, of hem af te sluiten. Het dock gaat uit de weg voor een venster in volledig scherm. Klik met de rechtermuisknop op de apps-knop om het dock naar een andere rand te verplaatsen of hem te laten verbergen totdat de aanwijzer zijn rand bereikt. De positie staat ook onder _Appearance > Dock > Dock Position_, en `omarchy dock position left` en `omarchy dock autohide on` stellen beide in vanaf een terminal. Apps die je in het dock houdt, zijn vervaagd terwijl ze niet draaien.

Nieuwe werkruimtes, en elke waaraan je geen eigen indeling hebt gegeven met `Super + L`, gebruiken de standaardindeling. Het wijzigen van de standaard zet elke werkruimte zonder vensters terug naar die indeling, terwijl een met vensters erop de indeling behoudt die hij heeft. Een venster dat naar het dock is geminimaliseerd, telt nog steeds als een venster op de werkruimte die het verliet. Kies hem onder _Appearance > Workspace Layout_: Tiling, Scrolling, of Floating. `omarchy-hyprland-workspace-layout-default scrolling` stelt hem in vanaf een terminal.

### Vensters groeperen

Vensters kunnen worden gegroepeerd met `Super + G`. Zodra je in een groep zit, zal elk venster dat je start terwijl die actief is, tot de groep behoren. Je kunt tussen deze gegroepeerde vensters bewegen met `Super + Ctrl + Arrow Left/Right` of `Super + Alt + 1/2/3/4` om direct naar gegroepeerde vensters in volgorde te gaan.

Je kunt een venster uit de groepering halen met `Super + Alt + G` of de hele groep ontbinden door nogmaals op `Super + G` te drukken. Ten slotte kun je vensters buiten de groep erin verplaatsen met `Super + Alt + Arrows`.

### Vensters losmaken

Je kunt een venster uit zijn werkruimtetoewijzing losmaken met `Super + O`. Dat pint hem vast als een zwevend venster dat je volgt naar welke werkruimte je ook gaat. Geweldig voor videospelers en dergelijke.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-werkruimte

Er is een speciale scratchpad-werkruimte op volledige grootte die over de werkruimte heen ligt waarop je je momenteel bevindt. Je opent wat erop staat met `Super + S`, en je plaatst vensters daar met `Super + Alt + S`.

Het werkt goed voor bedieningselementen of een terminal waarmee je snel wilt werken zonder de huidige werkruimte te verlaten.

### Quake-console

Ten slotte is er een Quake-console van halve hoogte die naar beneden valt over de werkruimte waarop je je momenteel bevindt. Schakel hem met `Super + Grave`, en plaats daar een venster met `Super + Shift + Grave`.

Hij opent met je standaardagent klaar voor gebruik. Terwijl de console een enkel venster bevat, valt hij naar beneden als een gecentreerd paneel in plaats van het scherm te overspannen. Zet er een tweede app op en hij gaat terug naar de volledige breedte, zodat de twee ruimte hebben om naast elkaar te zitten.

Om een venster van hetzij de scratchpad hetzij de console te verplaatsen, stuur hem direct naar een andere werkruimte met iets als `Super + Shift + 1`.

### Het vergt wat gewenning!

Het duurt even om eraan te wennen je bureaublad zo te navigeren, maar zodra je dat doet, zal het moeilijk zijn om terug te gaan naar een traditionele muisgestuurde bureaubladervaring!
