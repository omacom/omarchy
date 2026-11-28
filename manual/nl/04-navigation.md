# Navigatie

Alles in Omarchy gebeurt via het toetsenbord — _ALLES!_ Wanneer het systeem voor het eerst start, kun je letterlijk niets doen met alleen de muis. Maar je kunt op `Super + Space` drukken om het Omarchy Menu tevoorschijn te halen, en van hieruit kun je vrijwel alles doen.

Maar het Omarchy-menu is niet eens bedoeld als de belangrijkste manier om het systeem meestal te bedienen. We kunnen sneller dan dat! Alle belangrijkste toepassingen zijn direct gekoppeld aan afzonderlijke sneltoetsen. Je start de terminal met `Super + Return` en een browser met `Super + Shift + Return`. Probeer het een na het ander te doen, en je ziet de magie van Hyprlands tiling in actie:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Je kunt vervolgens op `Super + J` drukken om ze op elkaar te stapelen in plaats van naast elkaar:

 ![navigation-stacked](images/navigation-stacked.webp)

Druk opnieuw op `Super + J` om ze terug te zetten naar hun posities naast elkaar. Probeer vervolgens `Super + Shift + Arrow Right` terwijl je in de browser bent om de vensters om te wisselen.

Probeer nu `Super + Shift + T` om de Activity-monitor te starten. Die verschijnt als een zwevend venster, met een titelbalk waaraan je het kunt slepen en knoppen om het te minimaliseren, maximaliseren en sluiten. Elk zwevend venster krijgt er een, waar het ook is. Je kunt het tegelen met `Super + T` (en druk daar opnieuw op om het weer zwevend te maken). Druk nu op `Super + Shift + F` om de bestandsbeheerder te openen. Je krijgt een nette opstelling met vier vensters:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Je navigeert tussen het venster dat je actief wilt maken met `Super + Arrow`. Hiermee wisselt de focus en verplaatst de cursor naar het midden van de nieuwe toepassing. Aan de rand van een scherm gaat het verder naar de monitor aan die kant.

Als je op `Super + Shift + 2` drukt, verplaats je de huidige gefocuste toepassing naar de tweede werkruimte. Met `Super + Shift + 1` verplaats je hem terug. (En met `Super + Shift + Alt + 2` verplaats je de huidige gefocuste toepassing naar de tweede werkruimte zonder ernaartoe te schakelen).

Met meer dan één monitor heeft elke monitor zijn eigen werkruimtes 1 tot en met 10. Met `Super + 2` ga je naar de tweede werkruimte van de monitor waarop je je bevindt, en de bovenbalk van elke monitor toont zijn eigen werkruimtes en degene die hij weergeeft. Met `Super + Tab` doorloop je de werkruimtes op de monitor waarop je je bevindt. Met `Super + Shift + Ctrl + Arrows` verplaats je het venster waarop je je bevindt naar de monitor in die richting, naar de werkruimte die die weergeeft, en met `Super + Shift + Alt + Arrows` verplaats je de werkruimte waarop je je bevindt naar de monitor in die richting, waar hij hetzelfde nummer krijgt als dat vrij is. Een monitor behoudt zijn werkruimtes wanneer je hem loskoppelt: ze voegen zich bij die van een ander scherm, genummerd na degene die dat al heeft, en gaan terug onder hun oude nummers wanneer de monitor terugkeert.

Als je `Super` ingedrukt houdt en de muis gebruikt om op een venster te klikken, kun je opnieuw indelen waar het staat. Als je `Super` ingedrukt houdt en de rechtermuisknop gebruikt, kun je het venster vrij van grootte veranderen.

Je sluit een venster met `Super + W` of `Super + Q` (en sluit alle vensters met `Ctrl + Alt + Delete`).

Je kunt ook volledig scherm gaan met `Super + F`, of zelfs gewoon volledige breedte (met behoud van de bovenbalk) met `Super + Alt + F`, of volledig scherm binnen een venster met `Super + Ctrl + F` (handig voor YouTube!).

### Dwindle vs scrolling-layout

De standaardlayout van Omarchy heet dwindle. Die houdt alle vensters die je op een enkele werkruimte opent te allen tijde zichtbaar, zelfs als hij ze daarvoor moet verkleinen.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Maar je kunt er ook voor kiezen om een werkruimte te veranderen in de scrolling-layout, waarbij vensters naast elkaar worden opgelijnd, voorbij de zichtbare rand van het scherm. Je verandert een enkele werkruimte in deze layout via `Super + L`.

Nogmaals op `Super + L` drukken verandert de werkruimte in zwevend, waarbij vensters vrij overlappen en je ze zelf plaatst, en een derde keer drukken brengt hem terug naar dwindle. Met `Super + Alt + L` doorloop je ze de andere kant op. Een venster dat toch al zweeft — een dat je met `Super + T` hebt losgemaakt, of een app die altijd zwevend opent — blijft zweven wanneer de werkruimte teruggaat naar tiling. De bovenbalk markeert de werkruimte waarop je je bevindt met zijn layout: een vierkant voor dwindle, een cirkel voor scrolling en een driehoek voor zwevend. Op dat merk klikken doorloopt de layout ook, en dat geldt ook voor de schermtoets op laptops die er een hebben.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

De keuze is per werkruimte, en hij blijft behouden. Je kunt dus werkruimte 1 op dwindle houden voor browsen en werkruimte 2 op scrolling voor code, en ze komen na een herstart zo terug.

Als je de scrolling-layout als standaard wilt gebruiken, kun je dat instellen in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Zwevende werkruimtes

Een zwevende werkruimte werkt als een traditioneel bureaublad: vensters overlappen, en je verplaatst en schaalt ze zelf. Elk venster krijgt een titelbalk in de kleuren van je thema, met knoppen om te minimaliseren, maximaliseren en sluiten. Met `Super + M` minimaliseer je het gefocuste venster ook. Een geminimaliseerd venster wacht in het dock; klik op zijn app om het terug te halen. Klik op een venster om het naar voren te brengen. Verander de grootte ervan vanaf elke rand of hoek. Dubbelklik op een titelbalk om het venster te maximaliseren terwijl de bovenbalk in beeld blijft, en nogmaals om zijn oude grootte terug te krijgen. Chrome en andere op Chromium gebaseerde browsers, Disks en Document Viewer slaan de titelbalk over en gebruiken in plaats daarvan hun eigen kopbalk; met `Super + Alt + F` maximaliseer je ze, en met `Super + M` minimaliseer je ze.

Elke werkruimte heeft een dock, met je vastgezette apps, alles wat draait, en een raster van elke app achter de apps-knop, die `Super + Alt + Space` en _Apps_ in het Omarchy-menu ook openen. Klik met de rechtermuisknop op een app in het raster, of druk op `Delete`, om hem te deïnstalleren. Klik op een app om hem te openen, of om zijn venster naar voren te brengen; klik opnieuw om door zijn vensters te bladeren. Files haalt alleen een venster terug van de werkruimte waarop je je bevindt en opent anders een nieuw venster, en Terminal en Agent starten altijd een nieuwe, hoewel een geminimaliseerd venster eerst terugkomt. Met de middelste muisknop open je een nieuw venster. Sleep een pictogram langs het dock om het te verplaatsen; een draaiende app tussen de andere slepen houdt hem daar. Klik met de rechtermuisknop om een app in het dock te houden, hem eruit te halen of hem te stoppen. Het dock blijft in beeld zolang een werkruimte leeg is, en zodra de werkruimte een venster heeft, verbergt het zich totdat de aanwijzer zijn rand bereikt. Een venster op volledig scherm verbergt het helemaal. Sleep de apps-knop naar een andere rand van het scherm om het dock daarheen te verplaatsen. Klik er met de rechtermuisknop op voor _Position_, om een rand te kiezen, en _Layout_, om de standaardlayout in te stellen zoals _Appearance > Workspace Layout_ doet. De positie staat ook onder _Appearance > Dock > Dock Position_, en `omarchy dock position left` stelt hem in vanaf een terminal. Apps die je in het dock houdt, zijn vervaagd zolang ze niet draaien. Om het dock te beperken tot zwevende werkruimtes, gebruik je _Appearance > Dock > Dock Only on Floating_ of `omarchy dock tiling off`.

Nieuwe werkruimtes, en elke werkruimte waaraan je geen eigen layout hebt gegeven met `Super + L`, gebruiken de standaardlayout. Het wijzigen van de standaard zet elke werkruimte zonder vensters terug naar die layout, terwijl een werkruimte met vensters erop de layout behoudt die hij heeft. Een naar het dock geminimaliseerd venster telt nog steeds als een venster in de werkruimte die hij verliet. Kies deze onder _Appearance > Workspace Layout_: Tiling, Scrolling of Floating. Met `omarchy hyprland workspace layout default scrolling` stel je hem in vanaf een terminal.

### Vensters groeperen

Vensters kunnen worden gegroepeerd met `Super + G`. Zodra je in een groep zit, behoort elk venster dat je start terwijl die actief is tot de groep. Je kunt tussen deze gegroepeerde vensters bewegen met `Super + Ctrl + Arrow Left/Right` of `Super + Alt + 1/2/3/4` om direct naar gegroepeerde vensters in volgorde te gaan.

Je kunt een venster uit de groepering halen met `Super + Alt + G` of de hele groep uit elkaar halen door opnieuw op `Super + G` te drukken. Tot slot kun je vensters buiten de groep erin verplaatsen met `Super + Alt + Arrows`.

### Vensters loskoppelen

Je kunt een venster met `Super + O` uit zijn toewijzing aan een werkruimte loskoppelen. Daarmee zet je het vast als een zwevend venster dat je volgt naar welke werkruimte je ook gaat. Geweldig voor videospelers en dergelijke.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-werkruimte

Er is een speciale scratchpad-werkruimte op volledige grootte die alles overlapt wat er op de werkruimte staat waarop je je momenteel bevindt. Je opent wat erop staat met `Super + S`, en je plaatst vensters daar met `Super + Alt + S`.

Hij werkt goed voor bedieningselementen of een terminal waarmee je snel wilt werken zonder de huidige werkruimte te verlaten.

### Quake-console

Tot slot is er een Quake-console op halve hoogte die over de werkruimte heen naar beneden valt waarop je je momenteel bevindt. Schakel hem met `Super + the key above Tab` (grave op US-layouts), en plaats daar een venster met `Super + Shift + the key above Tab`.

De eerste keer dat hij opent, start hij je standaardagent, of vraagt hij je er een te kiezen als je er nog geen hebt gekozen. Zolang de console één enkel venster bevat, valt hij naar beneden als een gecentreerd paneel in plaats van het scherm te overspannen. Zet er een tweede app op en hij gaat terug naar de volledige breedte, zodat de twee ruimte hebben om naast elkaar te staan.

Om een venster van de scratchpad of de console af te halen, stuur je het direct naar een andere werkruimte met iets als `Super + Shift + 1`.

### Het is even wennen!

Het duurt even om te wennen aan het op deze manier navigeren op je bureaublad, maar als je het eenmaal gewend bent, zal het moeilijk zijn om terug te gaan naar een traditionele, muisgestuurde bureaubladervaring!
