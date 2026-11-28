# Navigasjon

Alt i Omarchy skjer via tastaturet — _ALT SAMMEN!_ Når systemet starter for første gang, kan du bokstavelig talt ikke gjøre en eneste ting med bare musen. Men du kan trykke på `Super + Space` for å få frem Omarchy-menyen, og herfra kan du gjøre omtrent alt.

Men Omarchy-menyen er ikke engang ment å være hovedmåten å betjene systemet på mesteparten av tiden. Vi kan gjøre det fortere enn det! Alle de viktigste applikasjonene er bundet direkte til egne hurtigtaster. Du starter terminalen med `Super + Return` og en nettleser med `Super + Shift + Return`. Prøv å gjøre det ene etter det andre, så ser du magien i Hyprlands flislegging i praksis:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan deretter trykke på `Super + J` for å stable dem oppå hverandre i stedet for side ved side:

 ![navigation-stacked](images/navigation-stacked.webp)

Trykk på `Super + J` igjen for å få dem tilbake til side-ved-side-posisjonene. Prøv deretter `Super + Shift + Arrow Right` mens du er i nettleseren, for å bytte om på vinduene.

Prøv nå `Super + Shift + T` for å starte aktivitetsmonitoren. Den vises som et flytende vindu, med en tittellinje du kan dra den etter, og knapper for å minimere, maksimere og lukke den. Alle flytende vinduer får en, uansett hvor det er. Du kan flislegge det med `Super + T` (og trykke på det igjen for å gjøre det flytende igjen). Trykk nå på `Super + Shift + F` for å åpne filbehandleren. Da får du et ryddig oppsett med fire vinduer:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellom vinduet du vil skal være aktivt, med `Super + Arrow`. Det bytter fokus og flytter markøren til midten av den nye applikasjonen. Ved kanten av en skjerm fortsetter det videre til skjermen på den siden.

Hvis du trykker på `Super + Shift + 2`, flytter du applikasjonen som har fokus, til det andre arbeidsområdet. `Super + Shift + 1` flytter den tilbake. (Og `Super + Shift + Alt + 2` flytter applikasjonen som har fokus, til det andre arbeidsområdet uten å bytte til det).

Med mer enn én skjerm har hver skjerm sine egne arbeidsområder 1 til 10. `Super + 2` går til det andre arbeidsområdet på skjermen du er på, og toppanelet på hver skjerm viser sine egne arbeidsområder og det den viser. `Super + Tab` blar gjennom arbeidsområdene på skjermen du er på. `Super + Shift + Ctrl + Arrows` flytter vinduet du er på, til skjermen i den retningen, til arbeidsområdet den viser, og `Super + Shift + Alt + Arrows` flytter arbeidsområdet du er på, over til skjermen i den retningen, der det får samme nummer hvis det er ledig. En skjerm beholder arbeidsområdene sine når du kobler den fra: de blir med over til en annen skjerm, nummerert etter dem den allerede har, og går tilbake til sine gamle numre når skjermen kommer tilbake.

Hvis du holder nede `Super` og bruker musen til å klikke på et vindu, kan du omorganisere hvor det sitter. Hvis du holder nede `Super` og bruker høyre museknapp, kan du fritt endre størrelsen på vinduet.

Du lukker et vindu med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå til fullskjerm med `Super + F`, eller bare til full bredde (og beholde toppanelet) med `Super + Alt + F`, eller til fullskjerm inne i et vindu med `Super + Ctrl + F` (bra for YouTube!).

### Dwindle vs. rullelayout

Omarchys standardlayout kalles dwindle. Den holder alle vinduene du åpner på et enkelt arbeidsområde, synlige til enhver tid, selv om den må krympe dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også velge å gjøre et arbeidsområde om til rullelayouten, der vinduer er stilt opp side ved side, forbi den synlige kanten av skjermen. Du gjør et enkelt arbeidsområde om til denne layouten med `Super + L`.

Trykker du på `Super + L` igjen, blir arbeidsområdet flytende, der vinduer overlapper fritt og du plasserer dem selv, og et tredje trykk bringer det tilbake til dwindle. `Super + Alt + L` går gjennom dem den andre veien. Et vindu som flyter uansett — ett du har hoppet ut med `Super + T`, eller en app som alltid åpner flytende — fortsetter å flyte når arbeidsområdet går tilbake til flislegging. Toppanelet markerer arbeidsområdet du er på, med layouten dens: en firkant for dwindle, en sirkel for rulling og en trekant for flytende. Å klikke på det merket blar også gjennom layouten, og det gjør også skjermtasten på bærbare datamaskiner som har en slik.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget gjelder per arbeidsområde, og det sitter. Så du kan ha arbeidsområde 1 på dwindle til surfing og arbeidsområde 2 på rulling til kode, og de kommer tilbake slik etter en omstart.

Hvis du ønsker å bruke rullelayouten som standard, kan du sette det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytende arbeidsområder

Et flytende arbeidsområde fungerer som et tradisjonelt skrivebord: vinduer overlapper, og du flytter og endrer størrelse på dem selv. Hvert vindu får en tittellinje i temaets farger, med knapper for å minimere, maksimere og lukke. `Super + M` minimerer også vinduet som har fokus. Et minimert vindu venter i dokken; klikk på appen dens for å hente det tilbake. Klikk på et vindu for å bringe det frem. Endre størrelse på det fra hvilken som helst kant eller hvilket som helst hjørne. Dobbeltklikk på en tittellinje for å maksimere vinduet mens toppanelet fortsatt er synlig, og igjen for å få den gamle størrelsen tilbake. Chrome og andre Chromium-baserte nettlesere, Disks og Document Viewer hopper over tittellinjen og bruker sin egen topptekst i stedet; `Super + Alt + F` maksimerer dem, og `Super + M` minimerer dem.

Alle arbeidsområder har en dokk, med appene du har festet, alt som kjører, og et rutenett med alle apper bak apper-knappen, som `Super + Alt + Space` og _Apps_ i Omarchy-menyen også åpner. Høyreklikk på en app på rutenettet, eller trykk på `Delete`, for å avinstallere den. Klikk på en app for å åpne den, eller for å bringe vinduet dens frem; klikk igjen for å bla gjennom vinduene dens. Files henter bare tilbake et vindu fra arbeidsområdet du er på, og åpner ellers et nytt, og Terminal og Agent starter alltid et nytt, selv om et minimert vindu kommer tilbake først. Midtklikk åpner et nytt vindu. Dra et ikon langs dokken for å flytte det; å dra en app som kjører, inn blant de andre beholder den der. Høyreklikk for å beholde en app i dokken, ta den ut eller avslutte den. Dokken holder seg ute mens et arbeidsområde er tomt, og når arbeidsområdet har et vindu, skjuler den seg til pekeren når kanten dens. Et fullskjermsvindu skjuler den helt. Dra apper-knappen mot en annen kant av skjermen for å flytte dokken dit. Høyreklikk på den for _Position_, for å velge en kant, og _Layout_, for å sette standardlayouten slik _Appearance > Workspace Layout_ gjør. Posisjonen finnes også under _Appearance > Dock > Dock Position_, og `omarchy dock position left` setter den fra en terminal. Apper du beholder i dokken, er nedtonet mens de ikke kjører. For å begrense dokken til flytende arbeidsområder bruker du _Appearance > Dock > Dock Only on Floating_ eller `omarchy dock tiling off`.

Nye arbeidsområder, og alle du ikke har gitt en egen layout med `Super + L`, bruker standardlayouten. Å endre standarden tilbakestiller alle arbeidsområder uten vinduer til den, mens ett med vinduer på beholder layouten det har. Et vindu som er minimert til dokken, teller fortsatt som et vindu på arbeidsområdet det forlot. Velg den under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy hyprland workspace layout default scrolling` setter den fra en terminal.

### Gruppering av vinduer

Vinduer kan grupperes med `Super + G`. Når du er i en gruppe, vil alle vinduer du starter mens den er aktiv, tilhøre gruppen. Du kan bevege deg mellom disse grupperte vinduene med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for å gå direkte til grupperte vinduer i rekkefølge.

Du kan flytte et vindu ut av grupperingen med `Super + Alt + G` eller demontere hele gruppen ved å trykke på `Super + G` igjen. Til slutt kan du flytte vinduer utenfor gruppen inn i den med `Super + Alt + Arrows`.

### Å sprette ut vinduer

Du kan sprette et vindu ut av arbeidsområdeplassen det har fått, med `Super + O`. Det fester det som et flytende vindu som følger deg til uansett hvilket arbeidsområde du går til. Kjempebra for videospillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbeidsområde

Det finnes et spesielt scratchpad-arbeidsområde i full størrelse som legger seg over arbeidsområdet du er på. Du får tilgang til det som er på det, med `Super + S`, og du plasserer vinduer der med `Super + Alt + S`.

Det fungerer godt for kontroller eller en terminal du vil samhandle raskt med, uten å forlate det nåværende arbeidsområdet.

### Quake-konsoll

Til slutt finnes det en Quake-konsoll i halv høyde som faller ned over arbeidsområdet du er på. Slå den av og på med `Super + the key above Tab` (gravaksent på US-layouter), og plasser et vindu der med `Super + Shift + the key above Tab`.

Første gang den åpner, starter den standardagenten din, eller ber deg velge en hvis du ikke har valgt en ennå. Mens konsollen har ett enkelt vindu, faller den ned som et sentrert panel i stedet for å spenne over skjermen. Sett en annen app på den, og den går tilbake til full bredde, så de to har plass til å sitte side ved side.

For å flytte et vindu bort fra enten scratchpad eller konsollen sender du det direkte til et annet arbeidsområde med noe sånt som `Super + Shift + 1`.

### Det tar litt tilvenning!

Det tar litt tid å venne seg til å navigere på skrivebordet slik, men når du først gjør det, blir det vanskelig å gå tilbake til en tradisjonell musdrevet skrivebordsopplevelse!
