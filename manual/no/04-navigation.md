# Navigasjon

Alt i Omarchy skjer via tastaturet — _ALT!_ Når systemet starter for første gang, kan du bokstavelig talt ikke gjøre noen ting med bare musen. Men du kan trykke `Super + Space` for å vise Omarchy-menyen, og herfra kan du gjøre omtrent alt.

Men Omarchy-menyen er ikke engang ment å være hovedmåten å betjene systemet på mesteparten av tiden. Vi kan gjøre det raskere enn det! Alle de viktigste applikasjonene er bundet direkte til egne hurtigtaster. Du starter terminalen med `Super + Return` og en nettleser med `Super + Shift + Return`. Prøv å gjøre det ene etter det andre, så ser du magien i Hyprlands flislegging i aksjon:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Deretter kan du trykke `Super + J` for å stable dem oppå hverandre i stedet for side ved side:

 ![navigation-stacked](images/navigation-stacked.webp)

Trykk `Super + J` igjen for å få dem tilbake til side-ved-side-posisjonene. Prøv deretter `Super + Shift + Arrow Right` mens du er i nettleseren for å bytte om på vinduene.

Prøv nå `Super + Shift + T` for å starte aktivitetsmonitoren. Den vises som et flytende vindu. Du kan flislegge det med `Super + T` (og trykke det igjen for å gjøre det flytende igjen). Trykk nå `Super + Shift + F` for å åpne filbehandleren. Da får du et pent oppsett med fire vinduer:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellom vinduet du vil ha aktivt med `Super + Arrow`. Det bytter fokus og flytter markøren til midten av den nye applikasjonen. Ved kanten av en skjerm fortsetter det til skjermen på den siden.

Hvis du trykker `Super + Shift + 2`, flytter du den gjeldende fokuserte applikasjonen til det andre arbeidsområdet. `Super + Shift + 1` flytter den tilbake. (Og `Super + Shift + Alt + 2` flytter den gjeldende fokuserte applikasjonen til det andre arbeidsområdet uten å bytte til det).

Med mer enn én skjerm har hver skjerm sine egne arbeidsområder 1 til 10. `Super + 2` går til det andre arbeidsområdet på skjermen du er på, og topplinjen på hver skjerm viser dens egne arbeidsområder og det den viser. `Super + Tab` blar gjennom arbeidsområdene på skjermen du er på. `Super + Shift + Ctrl + Arrows` flytter vinduet du er på til skjermen i den retningen, til arbeidsområdet den viser, og `Super + Shift + Alt + Arrows` flytter arbeidsområdet du er på over til skjermen i den retningen, der det får samme nummer hvis det er ledig. En skjerm beholder arbeidsområdene sine når du kobler den fra: de slutter seg til arbeidsområdene på en annen skjerm, nummerert etter dem den allerede har, og går tilbake til de gamle numrene sine når skjermen kommer tilbake.

Hvis du holder nede `Super` og bruker musen til å klikke på et vindu, kan du endre hvor det sitter. Hvis du holder nede `Super` og bruker høyre museknapp, kan du endre størrelsen på vinduet fritt.

Du lukker et vindu med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå til fullskjerm med `Super + F`, eller bare til full bredde (og beholde topplinjen) med `Super + Alt + F`, eller fullskjerm inne i et vindu med `Super + Ctrl + F` (bra for YouTube!).

### Dwindle kontra rulleoppsett

Omarchys standardoppsett heter dwindle. Det holder alle vinduene du åpner på ett enkelt arbeidsområde synlige til enhver tid, selv om det må krympe dem ned.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også velge å gjøre et arbeidsområde om til rulleoppsettet, der vinduene står på rad side ved side, forbi den synlige kanten av skjermen. Du gjør ett enkelt arbeidsområde om til dette oppsettet via `Super + L`.

Å trykke `Super + L` igjen gjør arbeidsområdet flytende, der vinduene overlapper fritt og du plasserer dem selv, og et tredje trykk fører det tilbake til dwindle. `Super + Alt + L` går gjennom dem den andre veien. Et vindu som flyter uansett — ett du har spratt ut med `Super + T`, eller en app som alltid åpnes flytende — fortsetter å flyte når arbeidsområdet går tilbake til flislegging. Topplinjen markerer arbeidsområdet du er på med oppsettet dets: en firkant for dwindle, en sirkel for rulling og en trekant for flytende. Å klikke på det merket blar også gjennom oppsettene.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget gjelder per arbeidsområde, og det blir værende. Så du kan beholde arbeidsområde 1 på dwindle til nettlesing og arbeidsområde 2 på rulling til kode, og de kommer tilbake slik etter en omstart.

Hvis du ønsker å bruke rulleoppsettet som standard, kan du angi det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytende arbeidsområder

Et flytende arbeidsområde fungerer som et tradisjonelt skrivebord: vinduene overlapper, og du flytter og endrer størrelsen på dem selv. Hvert vindu får en tittellinje i fargene til temaet ditt, med knapper for å minimere, maksimere og lukke. `Super + M` minimerer også det fokuserte vinduet. Et minimert vindu venter i dokken; klikk på appen dets for å hente det tilbake. Klikk på et vindu for å hente det frem. Endre størrelsen fra en hvilken som helst kant eller et hvilket som helst hjørne. Dobbeltklikk på en tittellinje for å maksimere vinduet mens topplinjen fortsatt er synlig, og igjen for å få den gamle størrelsen tilbake. Chrome og andre Chromium-baserte nettlesere, Disks og Document Viewer hopper over tittellinjen og bruker sin egen overskrift i stedet; `Super + Alt + F` maksimerer dem, og `Super + M` minimerer dem.

Et flytende arbeidsområde viser også en dokk, med de festede appene dine, alt som kjører, og et rutenett med alle apper bak apps-knappen, som `Super + Alt + Space` og _Apps_ i Omarchy-menyen også åpner. Høyreklikk på en app i rutenettet, eller trykk `Delete`, for å avinstallere den. Klikk på en app for å åpne den, eller for å hente vinduet dens frem; klikk igjen for å bla gjennom vinduene dens. Midtklikk åpner et nytt vindu. Dra et ikon langs dokken for å flytte det; å dra en app som kjører inn blant de andre beholder den der. Høyreklikk for å beholde en app i dokken, ta den ut, eller avslutte den. Dokken viker for et fullskjermsvindu. Høyreklikk på apps-knappen for å flytte dokken til en annen kant eller la den skjule seg til pekeren når kanten dens. Posisjonen er også under _Appearance > Dock > Dock Position_, og `omarchy dock position left` og `omarchy dock autohide on` angir begge deler fra en terminal. Apper du beholder i dokken er nedtonet mens de ikke kjører.

Nye arbeidsområder, og alle du ikke har gitt et eget oppsett med `Super + L`, bruker standardoppsettet. Å endre standarden tilbakestiller alle arbeidsområder uten vinduer til den, mens ett med vinduer på beholder oppsettet det har. Et vindu minimert til dokken teller fortsatt som et vindu på arbeidsområdet det forlot. Velg det under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy-hyprland-workspace-layout-default scrolling` angir det fra en terminal.

### Gruppering av vinduer

Vinduer kan grupperes med `Super + G`. Når du er i en gruppe, vil alle vinduer du starter mens den er aktiv tilhøre gruppen. Du kan flytte mellom disse grupperte vinduene med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for å gå direkte til grupperte vinduer i rekkefølge.

Du kan flytte et vindu ut av grupperingen med `Super + Alt + G` eller demontere hele gruppen ved å trykke `Super + G` igjen. Til slutt kan du flytte vinduer utenfor gruppen inn i den med `Super + Alt + Arrows`.

### Å sprette ut vinduer

Du kan sprette et vindu ut av arbeidsområdetildelingen dets med `Super + O`. Det fester det som et flytende vindu som følger deg til hvilket arbeidsområde du enn går til. Flott for videospillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbeidsområde

Det finnes et spesielt scratchpad-arbeidsområde i full størrelse som legger seg over arbeidsområdet du er på for øyeblikket. Du får tilgang til det som er på det med `Super + S`, og du plasserer vinduer der med `Super + Alt + S`.

Det fungerer godt for kontroller eller en terminal du vil samhandle raskt med uten å forlate det gjeldende arbeidsområdet.

### Quake-konsoll

Til slutt finnes det en Quake-konsoll i halv høyde som faller ned over arbeidsområdet du er på for øyeblikket. Slå den av og på med `Super + Grave`, og plasser et vindu der med `Super + Shift + Grave`.

Den åpnes med standardagenten din klar til bruk. Mens konsollen inneholder ett enkelt vindu, faller den ned som et midtstilt panel i stedet for å spenne over skjermen. Sett en annen app på den, så går den tilbake til full bredde, slik at de to får plass til å sitte side ved side.

For å flytte et vindu bort fra enten scratchpad-en eller konsollen sender du det direkte til et annet arbeidsområde med noe sånt som `Super + Shift + 1`.

### Det krever litt tilvenning!

Det tar litt tid å venne seg til å navigere på skrivebordet slik, men når du først gjør det, blir det vanskelig å gå tilbake til en tradisjonell musdrevet skrivebordsopplevelse!
