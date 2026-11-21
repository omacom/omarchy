# Navigatie

Alles in Omarchy gebeurt via het toetsenbord — _ALLES!_ Wanneer het systeem voor het eerst start, kun je letterlijk niets doen met alleen de muis. Maar je kunt op `Super + Space` drukken om het Omarchy Menu tevoorschijn te halen en van hieruit kun je zo'n beetje alles doen.

Maar het Omarchy-menu is niet eens bedoeld als de belangrijkste manier om het systeem meestal te bedienen. We kunnen sneller dan dat! Alle belangrijkste applicaties zijn direct gebonden aan afzonderlijke sneltoetsen. Je start de terminal met `Super + Return` en een browser met `Super + Shift + Return`. Probeer het een na het ander te doen, en je ziet de magie van Hyprland's tiling in actie:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Je kunt dan op `Super + J` drukken om ze op elkaar te stapelen in plaats van naast elkaar:

 ![navigation-stacked](images/navigation-stacked.webp)

Druk opnieuw op `Super + J` om ze terug te zetten naar hun posities naast elkaar. Probeer dan `Super + Shift + Arrow Right` terwijl je in de browser bent om de vensters te verwisselen.

Probeer nu `Super + Shift + T` om de Activity monitor te starten. Die verschijnt als een zwevend venster. Je kunt hem tegelen met `Super + T` (en druk daar opnieuw op om hem weer zwevend te maken). Druk nu op `Super + Shift + F` om de bestandsbeheerder te openen. Je krijgt een nette opstelling in vieren:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Je navigeert tussen het venster dat je actief wilt hebben met `Super + Arrow`. Daarmee wissel je de focus en verplaats je de cursor naar het midden van de nieuwe applicatie. Aan de rand van een scherm gaat het verder naar de monitor aan die kant.

Als je op `Super + Shift + 2` drukt, verplaats je de huidige gefocuste applicatie naar de tweede werkruimte. `Super + Shift + 1` verplaatst haar terug. (En `Super + Shift + Alt + 2` verplaatst de huidige gefocuste applicatie naar de tweede werkruimte zonder ernaartoe te schakelen).

Bij meer dan één monitor heeft elke monitor zijn eigen werkruimtes 1 tot en met 10. `Super + 2` gaat naar de tweede werkruimte van de monitor waarop je je bevindt, en de bovenste balk van elke monitor toont zijn eigen werkruimtes en degene die hij weergeeft. `Super + Tab` doorloopt de werkruimtes op de monitor waarop je je bevindt. `Super + Shift + Ctrl + Arrows` verplaatst het venster waarop je je bevindt naar de monitor in die richting, naar de werkruimte die deze weergeeft, en `Super + Shift + Alt + Arrows` verplaatst de werkruimte waarop je je bevindt naar de monitor in die richting, waar deze hetzelfde nummer krijgt als dat vrij is. Een monitor behoudt zijn werkruimtes wanneer je hem loskoppelt: ze voegen zich bij die van een ander scherm, genummerd na de werkruimtes die dat al heeft, en gaan terug naar hun oude nummers wanneer de monitor terugkeert.

Als je `Super` ingedrukt houdt en met de muis op een venster klikt, kun je herschikken waar het staat. Als je `Super` ingedrukt houdt en de rechtermuisknop gebruikt, kun je het venster vrij van grootte veranderen.

Je sluit een venster met `Super + W` of `Super + Q` (en sluit alle vensters met `Ctrl + Alt + Delete`).

Je kunt ook volledig scherm gaan met `Super + F` of zelfs alleen volledige breedte (met behoud van de bovenste balk) met `Super + Alt + F` of volledig scherm binnen een venster met `Super + Ctrl + F` (handig voor YouTube!).

### Dwindle vs scrolling layout

Omarchy's standaardlayout heet dwindle. Deze houdt alle vensters die je op een enkele werkruimte opent te allen tijde zichtbaar, zelfs als hij ze daarvoor moet verkleinen.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Maar je kunt er ook voor kiezen om een werkruimte te veranderen in de scrolling layout, waarin vensters naast elkaar staan opgesteld, voorbij de zichtbare rand van het scherm. Je verandert een enkele werkruimte in deze layout via `Super + L`.

Opnieuw op `Super + L` drukken verandert de werkruimte in zwevend, waarin vensters vrij overlappen en je ze zelf plaatst, en een derde druk brengt haar terug naar dwindle. `Super + Alt + L` doorloopt ze in de andere richting. Een venster dat toch al zweeft — een dat je eruit hebt gehaald met `Super + T`, of een app die altijd zwevend opent — blijft zweven wanneer de werkruimte teruggaat naar tiling. De bovenste balk markeert de werkruimte waarop je je bevindt met haar layout: een vierkant voor dwindle, een cirkel voor scrolling en een driehoek voor zwevend. Klikken op die markering doorloopt de layout ook, en dat doet de display-toets op laptops die er een hebben ook.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

De keuze geldt per werkruimte, en ze blijft behouden. Dus je kunt werkruimte 1 op dwindle houden om te browsen en werkruimte 2 op scrolling voor code, en ze komen na een herstart op die manier terug.

Als je de scrolling layout als standaard wilt gebruiken, kun je dat instellen in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Zwevende werkruimtes

Een zwevende werkruimte werkt als een traditioneel bureaublad: vensters overlappen, en je verplaatst en schaalt ze zelf. Elk venster krijgt een titelbalk in de kleuren van je thema, met knoppen om te minimaliseren, maximaliseren en sluiten. `Super + M` minimaliseert het gefocuste venster ook. Een geminimaliseerd venster wacht in het dock; klik op zijn app om het terug te brengen. Klik op een venster om het naar voren te brengen. Verander de grootte ervan vanaf elke rand of hoek. Dubbelklik op een titelbalk om het venster te maximaliseren terwijl de bovenste balk in zicht blijft, en opnieuw om de oude grootte terug te krijgen. Chrome en andere op Chromium gebaseerde browsers, Disks en Document Viewer slaan de titelbalk over en gebruiken in plaats daarvan hun eigen kopbalk; `Super + Alt + F` maximaliseert ze, en `Super + M` minimaliseert ze.

Een zwevende werkruimte toont ook een dock, met je vastgemaakte apps, alles wat draait, en een raster van elke app achter de apps-knop, die `Super + Alt + Space` en _Apps_ in het Omarchy-menu ook openen. Klik met rechts op een app in het raster, of druk op `Delete`, om haar te verwijderen. Klik op een app om haar te openen, of om haar venster naar voren te brengen; klik opnieuw om door haar vensters te bladeren. Files haalt alleen een venster terug van de werkruimte waarop je je bevindt en opent anders een nieuw venster, en Terminal en Agent starten altijd een ander venster, hoewel een geminimaliseerd venster eerst terugkomt. Klik met de middelste muisknop om een nieuw venster te openen. Sleep een pictogram over het dock om het te verplaatsen; een draaiende app tussen de anderen in slepen houdt haar daar. Klik met rechts om een app in het dock te houden, haar eruit te halen, of haar af te sluiten. Het dock gaat uit de weg voor een venster in volledig scherm. Klik met rechts op de apps-knop om het dock naar een andere rand te verplaatsen of het te laten verbergen totdat de aanwijzer zijn rand bereikt. De positie staat ook onder _Appearance > Dock > Dock Position_, en `omarchy dock position left` en `omarchy dock autohide on` stellen beide in vanaf een terminal. Apps die je in het dock houdt, zijn vervaagd terwijl ze niet draaien.

Nieuwe werkruimtes, en elke werkruimte waaraan je geen eigen layout hebt gegeven met `Super + L`, gebruiken de standaardlayout. Het wijzigen van de standaard stelt elke werkruimte zonder vensters daarop terug, terwijl een werkruimte met vensters erop de layout behoudt die deze heeft. Een venster dat naar het dock is geminimaliseerd telt nog steeds als een venster op de werkruimte die het verliet. Kies het onder _Appearance > Workspace Layout_: Tiling, Scrolling of Floating. `omarchy hyprland workspace layout default scrolling` stelt het in vanaf een terminal.

### Vensters groeperen

Vensters kunnen worden gegroepeerd met `Super + G`. Zodra je in een groep zit, zal elk venster dat je start terwijl die actief is, tot de groep behoren. Je kunt tussen deze gegroepeerde vensters bewegen met `Super + Ctrl + Arrow Left/Right` of `Super + Alt + 1/2/3/4` om direct naar gegroepeerde vensters in volgorde te gaan.

Je kunt een venster uit de groepering halen met `Super + Alt + G` of de hele groep ontbinden door opnieuw op `Super + G` te drukken. Ten slotte kun je vensters buiten de groep erin verplaatsen met `Super + Alt + Arrows`.

### Vensters losmaken

Je kunt een venster uit zijn werkruimtetoewijzing halen met `Super + O`. Dat pint het vast als een zwevend venster dat je volgt naar welke werkruimte je ook gaat. Geweldig voor videospelers en dergelijke.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-werkruimte

Er is een speciale scratchpad-werkruimte op volledige grootte die over de werkruimte heen ligt waarop je je momenteel bevindt. Je krijgt toegang tot wat erop staat met `Super + S`, en je plaatst vensters daar met `Super + Alt + S`.

Het werkt goed voor bedieningselementen of een terminal waarmee je snel wilt werken zonder de huidige werkruimte te verlaten.

### Quake-console

Ten slotte is er een Quake-console op halve hoogte die naar beneden valt over de werkruimte waarop je je momenteel bevindt. Schakel haar in en uit met `Super + Grave`, en plaats een venster daar met `Super + Shift + Grave`.

De eerste keer dat deze opent, start deze je standaardagent, of vraagt hij je er een te kiezen als je er nog geen hebt gekozen. Terwijl de console een enkel venster bevat, valt deze naar beneden als een gecentreerd paneel in plaats van het scherm te overspannen. Zet er een tweede app op en hij gaat terug naar de volledige breedte, zodat de twee ruimte hebben om naast elkaar te staan.

Om een venster van het scratchpad of de console af te verplaatsen, stuur je het direct naar een andere werkruimte met zoiets als `Super + Shift + 1`.

### Het vergt wat gewenning!

Het duurt even om te wennen aan het op deze manier navigeren op je bureaublad, maar als je dat eenmaal doet, zal het moeilijk zijn om terug te gaan naar een traditionele, muisgestuurde bureaubladervaring!
