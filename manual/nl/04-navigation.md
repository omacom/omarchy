# Navigatie

Alles in Omarchy gebeurt via het toetsenbord — _ALLES!_ Wanneer het systeem voor het eerst start, kun je letterlijk niets doen met alleen de muis. Maar je kunt op `Super + Space` drukken om het Omarchy-menu te tonen en vanaf hier kun je vrijwel alles doen.

Maar het Omarchy-menu is niet eens bedoeld als de belangrijkste manier om het systeem meestal te bedienen. We kunnen sneller dan dat! Alle belangrijkste applicaties zijn rechtstreeks gebonden aan afzonderlijke sneltoetsen. Je start de terminal met `Super + Return` en een browser met `Super + Shift + Return`. Probeer het een na het ander te doen en je ziet de magie van Hyprlands tegelen in actie:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Je kunt daarna op `Super + J` drukken om ze op elkaar te stapelen in plaats van naast elkaar:

 ![navigation-stacked](images/navigation-stacked.webp)

Druk opnieuw op `Super + J` om ze terug te zetten in hun posities naast elkaar. Probeer daarna `Super + Shift + Arrow Right` terwijl je in de browser bent om de vensters te wisselen.

Probeer nu `Super + Shift + T` om de Activity-monitor te starten. Die verschijnt als een zwevend venster, met een titelbalk om hem aan te slepen en knoppen om hem te minimaliseren, maximaliseren en sluiten. Elk zwevend venster krijgt er een, waar het ook is. Je kunt hem tegelen met `Super + T` (en druk daar nogmaals op om hem weer zwevend te maken). Druk nu op `Super + Shift + F` om de bestandsbeheerder te openen. Je krijgt een nette opstelling in vieren:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Je navigeert tussen het venster dat je actief wilt maken met `Super + Arrow`. Dit wisselt de focus en verplaatst de cursor naar het midden van de nieuwe applicatie. Aan de rand van een scherm gaat het verder naar de monitor aan die kant.

Als je op `Super + Shift + 2` drukt, verplaats je de applicatie met de huidige focus naar de tweede werkruimte. `Super + Shift + 1` verplaatst hem terug. (En `Super + Shift + Alt + 2` verplaatst de applicatie met de huidige focus naar de tweede werkruimte zonder ernaartoe te schakelen).

Met meer dan één monitor heeft elke monitor zijn eigen werkruimtes 1 tot en met 10. `Super + 2` gaat naar de tweede werkruimte van de monitor waarop je je bevindt, en de bovenste balk van elke monitor toont zijn eigen werkruimtes en degene die hij weergeeft. `Super + Tab` doorloopt de werkruimtes op de monitor waarop je je bevindt. `Super + Shift + Ctrl + Arrows` verplaatst het venster waarop je je bevindt naar de monitor in die richting, naar de werkruimte die die weergeeft, en `Super + Shift + Alt + Arrows` verplaatst de werkruimte waarop je je bevindt naar de monitor in die richting, waar hij hetzelfde nummer krijgt als dat vrij is. Een monitor behoudt zijn werkruimtes wanneer je hem loskoppelt: ze sluiten zich aan bij die van een ander scherm, genummerd na degene die dat al heeft, en gaan terug onder hun oude nummers wanneer de monitor terugkeert.

Als je `Super` ingedrukt houdt en met de muis op een venster klikt, kun je herschikken waar het staat. Als je `Super` ingedrukt houdt en de rechtermuisknop gebruikt, kun je het formaat van het venster vrij aanpassen.

Je sluit een venster met `Super + W` of `Super + Q` (en sluit alle vensters met `Ctrl + Alt + Delete`).

Je kunt ook naar volledig scherm gaan met `Super + F` of zelfs alleen naar volledige breedte (met behoud van de bovenste balk) met `Super + Alt + F` of naar volledig scherm binnen een venster met `Super + Ctrl + F` (handig voor YouTube!).

### Dwindle versus scrolling-indeling

De standaardindeling van Omarchy heet dwindle. Die houdt alle vensters die je op één werkruimte opent te allen tijde zichtbaar, zelfs als hij ze daarvoor moet verkleinen.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Maar je kunt er ook voor kiezen om een werkruimte te veranderen in de scrolling-indeling, waarbij vensters naast elkaar worden opgesteld, voorbij de zichtbare rand van het beeldscherm. Je verandert een enkele werkruimte in deze indeling via `Super + L`.

Opnieuw op `Super + L` drukken maakt de werkruimte zwevend, waarbij vensters vrij overlappen en je ze zelf plaatst, en een derde druk brengt hem terug naar dwindle. `Super + Alt + L` doorloopt ze de andere kant op. Een venster dat toch al zweeft — een dat je met `Super + T` hebt losgemaakt, of een app die altijd zwevend opent — blijft zweven wanneer de werkruimte teruggaat naar tegelen. De bovenste balk markeert de werkruimte waarop je je bevindt met zijn indeling: een vierkant voor dwindle, een cirkel voor scrolling en een driehoek voor zwevend. Klikken op die markering doorloopt de indeling ook, en dat geldt ook voor de beeldschermtoets op laptops die er een hebben.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

De keuze geldt per werkruimte en blijft behouden. Dus je kunt werkruimte 1 op dwindle houden om te browsen en werkruimte 2 op scrolling voor code, en ze komen na een herstart zo terug.

Als je de scrolling-indeling als standaard wilt gebruiken, kun je dat instellen in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Zwevende werkruimtes

Een zwevende werkruimte werkt als een traditioneel bureaublad: vensters overlappen en je verplaatst en schaalt ze zelf. Elk venster krijgt een titelbalk in de kleuren van je thema, met knoppen om te minimaliseren, maximaliseren en sluiten. `Super + M` minimaliseert ook het venster met de focus. Een geminimaliseerd venster wacht in het dock; klik op zijn app om hem terug te brengen. Klik op een venster om het naar voren te brengen. Pas het formaat aan vanaf elke rand of hoek. Dubbelklik op een titelbalk om het venster te maximaliseren terwijl de bovenste balk in zicht blijft, en nogmaals om zijn oude formaat terug te krijgen. Chrome en andere op Chromium gebaseerde browsers, Disks en Document Viewer slaan de titelbalk over en gebruiken in plaats daarvan hun eigen kopbalk; `Super + Alt + F` maximaliseert ze en `Super + M` minimaliseert ze.

Elke werkruimte heeft een dock, met je vastgezette apps, alles wat draait, en een raster van elke app achter de apps-knop, die `Super + Alt + Space` en _Apps_ in het Omarchy-menu ook openen. Klik met rechts op een app in het raster, of druk op `Delete`, om hem te verwijderen. Klik op een app om hem te openen, of om zijn venster naar voren te brengen; klik opnieuw om door zijn vensters te bladeren. Files brengt alleen een venster terug van de werkruimte waarop je je bevindt en opent anders een nieuwe, en Terminal en Agent starten altijd een andere, hoewel een geminimaliseerd venster eerst terugkomt. Klikken met de middelste muisknop opent een nieuw venster. Sleep een pictogram langs het dock om het te verplaatsen; een draaiende app tussen de anderen slepen houdt hem daar. Klik met rechts om een app in het dock te houden, hem eruit te halen of hem af te sluiten. Het dock blijft zichtbaar zolang een werkruimte leeg is, en zodra de werkruimte een venster heeft, verbergt het zich totdat de aanwijzer zijn rand bereikt. Een venster in volledig scherm verbergt het helemaal. Sleep de apps-knop naar een andere rand van het scherm om het dock daarheen te verplaatsen. Klik er met rechts op voor _Position_, om een rand te kiezen, _Layout_, om de standaardindeling in te stellen zoals _Appearance > Workspace Layout_ dat doet, en _Visibility_, om het dock altijd aan te houden, het door de eerste app te laten verbergen, of het altijd verborgen te houden. `omarchy dock visibility always` stelt dat in vanaf een terminal. De positie staat ook onder _Appearance > Dock > Dock Position_, en `omarchy dock position left` stelt hem in vanaf een terminal. Apps die je in het dock houdt, zijn vervaagd zolang ze niet draaien. Om het dock te beperken tot zwevende werkruimtes, gebruik je _Appearance > Dock > Dock Only on Floating_ of `omarchy dock tiling off`.

Nieuwe werkruimtes, en elke waaraan je geen eigen indeling hebt gegeven met `Super + L`, gebruiken de standaardindeling. Het wijzigen van de standaard zet elke werkruimte zonder vensters terug naar deze indeling, terwijl een met vensters erop de indeling behoudt die hij heeft. Een venster dat naar het dock is geminimaliseerd telt nog steeds als een venster op de werkruimte die het verliet. Kies deze onder _Appearance > Workspace Layout_: Tiling, Scrolling, or Floating. `omarchy hyprland workspace layout default scrolling` stelt hem in vanaf een terminal.

### Vensters groeperen

Vensters kunnen worden gegroepeerd met `Super + G`. Zodra je in een groep zit, zal elk venster dat je start terwijl die actief is tot de groep behoren. Je kunt tussen deze gegroepeerde vensters bewegen met `Super + Ctrl + Arrow Left/Right` of `Super + Alt + 1/2/3/4` om rechtstreeks in volgorde naar gegroepeerde vensters te gaan.

Je kunt een venster uit de groepering halen met `Super + Alt + G` of de hele groep ontbinden door opnieuw op `Super + G` te drukken. Ten slotte kun je vensters buiten de groep erin verplaatsen met `Super + Alt + Arrows`.

### Vensters losmaken

Je kunt een venster met `Super + O` uit zijn toewijzing aan een werkruimte losmaken. Dat zet hem vast als een zwevend venster dat je volgt naar welke werkruimte je ook gaat. Geweldig voor videospelers en dergelijke.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-werkruimte

Er is een speciale scratchpad-werkruimte op volledige grootte die over de werkruimte heen ligt waarop je je momenteel bevindt. Je opent wat erop staat met `Super + S`, en je plaatst vensters daar met `Super + Alt + S`.

Het werkt goed voor bedieningselementen of een terminal waarmee je snel wilt werken zonder de huidige werkruimte te verlaten.

### Quake-console

Ten slotte is er een Quake-console op halve hoogte die over de werkruimte heen naar beneden komt waarop je je momenteel bevindt. Schakel hem met `Super + the key above Tab` (grave op US-indelingen), en plaats een venster daar met `Super + Shift + the key above Tab`.

De eerste keer dat hij opent, start hij je standaardagent, of vraagt hij je er een te kiezen als je er nog geen hebt gekozen. Terwijl de console een enkel venster bevat, komt hij naar beneden als een gecentreerd paneel in plaats van het scherm te overspannen. Zet er een tweede app op en hij gaat terug naar de volledige breedte, zodat de twee ruimte hebben om naast elkaar te zitten.

Om een venster van hetzij de scratchpad hetzij de console te verplaatsen, stuur je hem rechtstreeks naar een andere werkruimte met iets als `Super + Shift + 1`.

### Het is even wennen!

Het duurt even om te wennen aan het op deze manier navigeren op je bureaublad, maar zodra je dat doet, zal het moeilijk zijn om terug te gaan naar een traditionele, muisgestuurde bureaubladervaring!
