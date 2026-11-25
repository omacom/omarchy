# Navigatie

Alles in Omarchy gebeurt via het toetsenbord — _ALLES!_ Wanneer het systeem voor het eerst start, kun je letterlijk niets doen met alleen de muis. Maar je kunt op `Super + Space` drukken om het Omarchy Menu te onthullen en van hieruit kun je vrijwel alles doen.

Maar het Omarchy-menu is niet eens bedoeld als de belangrijkste manier om het systeem meestal te bedienen. We kunnen sneller dan dat! Alle belangrijkste applicaties zijn direct gebonden aan afzonderlijke sneltoetsen. Je start de terminal met `Super + Return` en een browser met `Super + Shift + Return`. Probeer het een na het ander te doen, en je ziet de magie van Hyprland's tiling in actie:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Je kunt dan op `Super + J` drukken om ze op elkaar te stapelen in plaats van naast elkaar:

 ![navigation-stacked](images/navigation-stacked.webp)

Druk nogmaals op `Super + J` om ze terug te zetten naar hun posities naast elkaar. Probeer dan `Super + Shift + Arrow Right` terwijl je in de browser zit om de vensters te verwisselen.

Probeer nu `Super + Shift + T` om de Activity monitor te starten. Die verschijnt als een zwevend venster. Je kunt hem tegelen met `Super + T` (en druk daar nogmaals op om hem weer zwevend te maken). Druk nu op `Super + Shift + F` om de bestandsbeheerder te openen. Je hebt dan een nette opstelling in vier richtingen:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Je navigeert tussen het venster dat je actief wilt hebben met `Super + Arrow`. Dit wisselt de focus en verplaatst de cursor naar het midden van de nieuwe applicatie. Aan de rand van een scherm gaat het verder naar de monitor aan die kant.

Als je op `Super + Shift + 2` drukt, verplaats je de huidige gefocuste applicatie naar de tweede werkruimte. `Super + Shift + 1` verplaatst hem terug. (En `Super + Shift + Alt + 2` verplaatst de huidige gefocuste applicatie naar de tweede werkruimte zonder ernaartoe te wisselen).

Met meer dan één monitor heeft elke monitor zijn eigen werkruimtes 1 tot en met 10. `Super + 2` gaat naar de tweede werkruimte van de monitor waarop je zit, en de bovenbalk van elke monitor toont zijn eigen werkruimtes en degene die hij weergeeft. `Super + Tab` bladert door de werkruimtes op de monitor waarop je zit. `Super + Shift + Ctrl + Arrows` verplaatst het venster waarop je zit naar de monitor in die richting, naar de werkruimte die die weergeeft, en `Super + Shift + Alt + Arrows` verplaatst de werkruimte waarop je zit naar de monitor in die richting, waar hij hetzelfde nummer krijgt als dat vrij is. Een monitor behoudt zijn werkruimtes wanneer je hem loskoppelt: ze voegen zich bij die van een ander scherm, genummerd na degene die dat al heeft, en keren terug onder hun oude nummers wanneer de monitor terugkeert.

Als je `Super` ingedrukt houdt en met de muis op een venster klikt, kun je herschikken waar het staat. Als je `Super` ingedrukt houdt en de rechtermuisknop gebruikt, kun je het venster vrij vergroten of verkleinen.

Je sluit een venster met `Super + W` of `Super + Q` (en sluit alle vensters met `Ctrl + Alt + Delete`).

Je kunt ook naar volledig scherm gaan met `Super + F` of zelfs alleen naar volledige breedte (met behoud van de bovenbalk) met `Super + Alt + F` of naar volledig scherm binnen een venster met `Super + Ctrl + F` (handig voor YouTube!).

### Dwindle vs. scrollende indeling

De standaardindeling van Omarchy heet dwindle. Die houdt alle vensters die je op één werkruimte opent te allen tijde zichtbaar, zelfs als hij ze daarvoor moet verkleinen.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Maar je kunt er ook voor kiezen om een werkruimte te veranderen in de scrollende indeling, waarin vensters naast elkaar op een rij staan, tot voorbij de zichtbare rand van het scherm. Je verandert één werkruimte in deze indeling via `Super + L`.

Nogmaals op `Super + L` drukken verandert de werkruimte in zwevend, waarin vensters vrij overlappen en je ze zelf plaatst, en een derde keer drukken brengt hem terug naar dwindle. `Super + Alt + L` doorloopt ze in de andere richting. Een venster dat toch al zweeft — een dat je eruit hebt gehaald met `Super + T`, of een app die altijd zwevend opent — blijft zweven wanneer de werkruimte teruggaat naar tegelen. De bovenbalk markeert de werkruimte waarop je zit met zijn indeling: een vierkant voor dwindle, een cirkel voor scrollend en een driehoek voor zwevend. Klikken op dat merkteken doorloopt de indeling ook, en de schermtoets op laptops die er een hebben doet dat ook.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

De keuze is per werkruimte, en hij blijft behouden. Je kunt dus werkruimte 1 op dwindle houden om te browsen en werkruimte 2 op scrollend voor code, en ze komen na een herstart op die manier terug.

Als je de scrollende indeling als standaard wilt gebruiken, kun je dat instellen in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Zwevende werkruimtes

Een zwevende werkruimte werkt als een traditioneel bureaublad: vensters overlappen, en je verplaatst en schaalt ze zelf. Elk venster krijgt een titelbalk in de kleuren van je thema, met knoppen om te minimaliseren, maximaliseren en sluiten. `Super + M` minimaliseert het gefocuste venster ook. Een geminimaliseerd venster wacht in het dock; klik op zijn app om hem terug te halen. Klik op een venster om hem naar voren te halen. Schaal hem vanaf elke rand of hoek. Dubbelklik op een titelbalk om het venster te maximaliseren terwijl de bovenbalk in beeld blijft, en nogmaals om zijn oude grootte terug te krijgen. Chrome en andere op Chromium gebaseerde browsers, Disks en Document Viewer slaan de titelbalk over en gebruiken in plaats daarvan hun eigen kopbalk; `Super + Alt + F` maximaliseert ze, en `Super + M` minimaliseert ze.

Een zwevende werkruimte toont ook een dock, met je vastgezette apps, alles wat er draait, en een raster van elke app achter de apps-knop, dat `Super + Alt + Space` en _Apps_ in het Omarchy-menu ook openen. Klik met de rechtermuisknop op een app in het raster, of druk op `Delete`, om hem te deïnstalleren. Klik op een app om hem te openen, of om zijn venster naar voren te halen; klik nogmaals om door zijn vensters te bladeren. Files haalt alleen een venster terug van de werkruimte waarop je zit en opent anders een nieuwe, en Terminal en Agent starten altijd een nieuwe, hoewel een geminimaliseerd venster eerst terugkomt. Met de middelste muisknop open je een nieuw venster. Sleep een pictogram langs het dock om het te verplaatsen; een draaiende app tussen de anderen in slepen houdt hem daar. Klik met de rechtermuisknop om een app in het dock te houden, hem eruit te halen of hem af te sluiten. Het dock gaat uit de weg voor een venster in volledig scherm. Klik met de rechtermuisknop op de apps-knop om het dock naar een andere rand te verplaatsen of hem te laten verbergen totdat de aanwijzer zijn rand bereikt. De positie staat ook onder _Uiterlijk > Dock > Dockpositie_, en `omarchy dock position left` en `omarchy dock autohide on` stellen beide in vanaf een terminal. Apps die je in het dock houdt, zijn vervaagd zolang ze niet draaien.

Nieuwe werkruimtes, en elke werkruimte waaraan je geen eigen indeling hebt gegeven met `Super + L`, gebruiken de standaardindeling. Het wijzigen van de standaard stelt elke werkruimte zonder vensters in op die indeling, terwijl een werkruimte met vensters erop de indeling behoudt die hij heeft. Een naar het dock geminimaliseerd venster telt nog steeds als een venster op de werkruimte die het verliet. Kies hem onder _Uiterlijk > Werkruimte-indeling_: Tegelen, Scrollen of Zwevend. `omarchy hyprland workspace layout default scrolling` stelt hem in vanaf een terminal.

### Vensters groeperen

Vensters kunnen worden gegroepeerd met `Super + G`. Zodra je in een groep zit, behoort elk venster dat je start terwijl die actief is tot de groep. Je kunt tussen deze gegroepeerde vensters bewegen met `Super + Ctrl + Arrow Left/Right` of `Super + Alt + 1/2/3/4` om direct naar gegroepeerde vensters in volgorde te gaan.

Je kunt een venster uit de groepering halen met `Super + Alt + G` of de hele groep ontmantelen door nogmaals op `Super + G` te drukken. Ten slotte kun je vensters buiten de groep erin verplaatsen met `Super + Alt + Arrows`.

### Vensters losmaken

Je kunt een venster uit zijn toegewezen werkruimte halen met `Super + O`. Dat zet hem vast als een zwevend venster dat je volgt naar welke werkruimte je ook gaat. Geweldig voor videospelers en dergelijke.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-werkruimte

Er is een speciale scratchpad-werkruimte op volledige grootte die alles overlapt wat er op de werkruimte staat waarop je je momenteel bevindt. Je opent wat erop staat met `Super + S`, en je plaatst vensters daar met `Super + Alt + S`.

Het werkt goed voor bedieningselementen of een terminal waarmee je snel wilt werken zonder de huidige werkruimte te verlaten.

### Quake-console

Ten slotte is er een Quake-console op halve hoogte die naar beneden valt over de werkruimte waarop je je momenteel bevindt. Schakel hem in of uit met `Super + the key above Tab` (grave op Amerikaanse indelingen), en plaats daar een venster met `Super + Shift + the key above Tab`.

De eerste keer dat hij opent, start hij je standaardagent, of vraagt hij je er een te kiezen als je er nog geen hebt gekozen. Zolang de console één venster bevat, valt hij naar beneden als een gecentreerd paneel in plaats van het scherm te overspannen. Zet er een tweede app op en hij gaat terug naar de volledige breedte, zodat de twee ruimte hebben om naast elkaar te zitten.

Om een venster van het scratchpad of de console af te halen, stuur je het direct naar een andere werkruimte met bijvoorbeeld `Super + Shift + 1`.

### Het is even wennen!

Het duurt even om te wennen aan het op deze manier navigeren op je bureaublad, maar zodra je dat doet, zal het moeilijk zijn om terug te gaan naar een traditionele, muisgestuurde bureaubladervaring!
