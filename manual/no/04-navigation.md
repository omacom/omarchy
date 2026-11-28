# Navigasjon

Alt i Omarchy skjer via tastaturet — _ALT!_ Når systemet starter for første gang, kan du bokstavelig talt ikke gjøre noe som helst med bare musen. Men du kan trykke `Super + Space` for å vise Omarchy-menyen, og herfra kan du gjøre nesten alt.

Men Omarchy-menyen er ikke engang ment å være den viktigste måten å betjene systemet på mesteparten av tiden. Vi kan gjøre det raskere enn det! Alle de viktigste applikasjonene er bundet direkte til egne hurtigtaster. Du starter terminalen med `Super + Return` og en nettleser med `Super + Shift + Return`. Prøv å gjøre det ene etter det andre, så ser du magien med flisleggingen i Hyprland i aksjon:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan deretter trykke `Super + J` for å stable dem oppå hverandre i stedet for side ved side:

 ![navigation-stacked](images/navigation-stacked.webp)

Trykk `Super + J` igjen for å få dem tilbake til plassene sine side ved side. Prøv deretter `Super + Shift + Arrow Right` mens du er i nettleseren, for å bytte om på vinduene.

Prøv nå `Super + Shift + T` for å starte aktivitetsmonitoren. Den vises som et flytende vindu, med en tittellinje du kan dra den etter, og knapper for å minimere, maksimere og lukke den. Hvert flytende vindu får en slik, uansett hvor det er. Du kan flislegge det med `Super + T` (og trykke det igjen for å gjøre det flytende igjen). Trykk nå `Super + Shift + F` for å åpne filbehandleren. Da får du et pent firveis oppsett:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellom vinduet du vil ha aktivt, med `Super + Arrow`. Det bytter fokus og flytter markøren til midten av den nye applikasjonen. Ved kanten av en skjerm fortsetter det til skjermen på den siden.

Hvis du trykker `Super + Shift + 2`, flytter du applikasjonen som for øyeblikket har fokus, til det andre arbeidsområdet. `Super + Shift + 1` flytter den tilbake. (Og `Super + Shift + Alt + 2` flytter applikasjonen som for øyeblikket har fokus, til det andre arbeidsområdet uten å bytte til det).

Med mer enn én skjerm har hver skjerm sine egne arbeidsområder 1 til 10. `Super + 2` går til det andre arbeidsområdet på skjermen du er på, og den øverste linjen på hver skjerm viser sine egne arbeidsområder og det den viser. `Super + Tab` blar gjennom arbeidsområdene på skjermen du er på. `Super + Shift + Ctrl + Arrows` flytter vinduet du er på, til skjermen i den retningen, til arbeidsområdet den viser, og `Super + Shift + Alt + Arrows` flytter arbeidsområdet du er på, over til skjermen i den retningen, der det får samme nummer hvis det er ledig. En skjerm beholder arbeidsområdene sine når du kobler den fra: de slutter seg til en annen skjerms sine, nummerert etter dem den allerede har, og går tilbake til sine gamle numre når skjermen kommer tilbake.

Hvis du holder nede `Super` og bruker musen til å klikke på et vindu, kan du endre hvor det sitter. Hvis du holder `Super` og bruker høyre museknapp, kan du fritt endre størrelsen på vinduet.

Du lukker et vindu med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå til fullskjerm med `Super + F`, eller til og med bare til full bredde (og beholde den øverste linjen) med `Super + Alt + F`, eller til fullskjerm inne i et vindu med `Super + Ctrl + F` (bra for YouTube!).

### Dwindle kontra rullelayout

Standardlayouten i Omarchy heter dwindle. Den holder alle vinduene du åpner på et enkelt arbeidsområde, synlige til enhver tid, selv om den må krympe dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også velge å gjøre et arbeidsområde om til rullelayouten, der vinduer er stilt opp side ved side, forbi den synlige kanten av skjermen. Du gjør et enkelt arbeidsområde om til denne layouten med `Super + L`.

Å trykke `Super + L` igjen gjør arbeidsområdet flytende, der vinduer overlapper fritt og du plasserer dem selv, og et tredje trykk bringer det tilbake til dwindle. `Super + Alt + L` går gjennom dem den andre veien. Et vindu som flyter uansett — ett du har sprettet ut med `Super + T`, eller en app som alltid åpnes flytende — fortsetter å flyte når arbeidsområdet går tilbake til flislegging. Den øverste linjen markerer arbeidsområdet du er på, med layouten dets: en firkant for dwindle, en sirkel for rulling og en trekant for flytende. Å klikke på det merket blar også gjennom layoutene, og det gjør også skjermtasten på bærbare som har en slik.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget gjelder per arbeidsområde, og det blir værende. Så du kan beholde arbeidsområde 1 på dwindle for surfing og arbeidsområde 2 på rulling for kode, og de kommer tilbake slik etter en omstart.

Hvis du vil bruke rullelayouten som standard, kan du sette det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytende arbeidsområder

Et flytende arbeidsområde fungerer som et tradisjonelt skrivebord: vinduer overlapper, og du flytter og endrer størrelse på dem selv. Hvert vindu får en tittellinje i fargene til temaet ditt, med knapper for å minimere, maksimere og lukke. `Super + M` minimerer også vinduet som har fokus. Et minimert vindu venter i dokken; klikk på appen dets for å hente det tilbake. Klikk på et vindu for å bringe det fremst. Endre størrelsen fra en hvilken som helst kant eller et hvilket som helst hjørne. Dobbeltklikk på en tittellinje for å maksimere vinduet mens den øverste linjen fortsatt er synlig, og igjen for å få den gamle størrelsen tilbake. Chrome og andre Chromium-baserte nettlesere, Disks og Document Viewer hopper over tittellinjen og bruker sin egen overskrift i stedet; `Super + Alt + F` maksimerer dem, og `Super + M` minimerer dem.

Hvert arbeidsområde har en dokk, med de festede appene dine, alt som kjører, og et rutenett med hver app bak appknappen, som `Super + Alt + Space` og _Apper_ i Omarchy-menyen også åpner. Høyreklikk på en app på rutenettet, eller trykk `Delete`, for å avinstallere den. Klikk på en app for å åpne den, eller for å bringe vinduet dens fremst; klikk igjen for å bla gjennom vinduene dens. Files henter bare tilbake et vindu fra arbeidsområdet du er på, og åpner ellers et nytt, og Terminal og Agent starter alltid en til, selv om et minimert vindu kommer tilbake først. Midtklikk åpner et nytt vindu. Dra et ikon langs dokken for å flytte det; å dra en kjørende app inn blant de andre beholder den der. Høyreklikk for å beholde en app i dokken, ta den ut eller avslutte den. Dokken blir værende ute mens et arbeidsområde er tomt, og når arbeidsområdet har et vindu, skjuler den seg til pekeren når kanten dens. Et fullskjermsvindu skjuler den helt. Dra appknappen mot en annen kant av skjermen for å flytte dokken dit. Høyreklikk på den for _Posisjon_, for å velge en kant, _Layout_, for å sette standardlayouten slik _Utseende > Arbeidsområdelayout_ gjør, og _Synlighet_, for å beholde dokken alltid på, la den første appen skjule den eller beholde den alltid skjult. `omarchy dock visibility always` setter det fra en terminal. Posisjonen er også under _Utseende > Dock > Dock-posisjon_, og `omarchy dock position left` setter den fra en terminal. Apper du beholder i dokken, er nedtonet mens de ikke kjører. For å begrense dokken til flytende arbeidsområder bruker du _Utseende > Dock > Dock bare på flytende_ eller `omarchy dock tiling off`.

Nye arbeidsområder, og alle du ikke har gitt en egen layout med `Super + L`, bruker standardlayouten. Å endre standarden tilbakestiller hvert arbeidsområde uten vinduer til den, mens ett med vinduer på beholder layouten det har. Et vindu minimert til dokken teller fortsatt som et vindu på arbeidsområdet det forlot. Velg den under _Utseende > Arbeidsområdelayout_: Flislegging, Rulling eller Flytende. `omarchy hyprland workspace layout default scrolling` setter den fra en terminal.

### Gruppering av vinduer

Vinduer kan grupperes med `Super + G`. Når du er i en gruppe, vil hvert vindu du starter mens den er aktiv, tilhøre gruppen. Du kan bevege deg mellom disse grupperte vinduene med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for å gå direkte til grupperte vinduer i rekkefølge.

Du kan flytte et vindu ut av grupperingen med `Super + Alt + G` eller demontere hele gruppen ved å trykke `Super + G` igjen. Til slutt kan du flytte vinduer utenfor gruppen inn i den med `Super + Alt + Arrows`.

### Å sprette ut vinduer

Du kan sprette et vindu ut av arbeidsområdeplasseringen dets med `Super + O`. Det fester det som et flytende vindu som følger deg til uansett hvilket arbeidsområde du går til. Flott for videospillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbeidsområde

Det finnes et spesielt scratchpad-arbeidsområde i full størrelse som legger seg over arbeidsområdet du er på for øyeblikket. Du får tilgang til det som er på det, med `Super + S`, og du plasserer vinduer der med `Super + Alt + S`.

Det fungerer bra for kontroller eller en terminal du vil samhandle raskt med uten å forlate det gjeldende arbeidsområdet.

### Quake-konsoll

Til slutt finnes det en Quake-konsoll i halv høyde som faller ned over arbeidsområdet du er på for øyeblikket. Slå den av og på med `Super + the key above Tab` (grave på amerikanske oppsett), og plasser et vindu der med `Super + Shift + the key above Tab`.

Første gang den åpnes, starter den standardagenten din, eller ber deg velge en hvis du ikke har valgt en ennå. Mens konsollen inneholder et enkelt vindu, faller den ned som et sentrert panel i stedet for å strekke seg over skjermen. Sett en annen app på den, og den går tilbake til full bredde, slik at de to har plass til å sitte side ved side.

For å flytte et vindu bort fra enten scratchpad eller konsollen sender du det direkte til et annet arbeidsområde med noe sånt som `Super + Shift + 1`.

### Det tar litt tid å venne seg til!

Det tar litt tid å venne seg til å navigere på skrivebordet ditt på denne måten, men når du først gjør det, blir det vanskelig å gå tilbake til en tradisjonell musdrevet skrivebordsopplevelse!
