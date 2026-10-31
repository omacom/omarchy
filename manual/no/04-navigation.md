# Navigering

Alt i Omarchy skjer via tastaturet — _ALT!_ Når systemet starter for første gang, kan du bokstavelig talt ikke gjøre noe som helst med bare musen. Men du kan trykke `Super + Space` for å vise Omarchy Menu, og herfra kan du gjøre omtrent alt.

Men Omarchy-menyen er ikke engang ment å være hovedmåten å betjene systemet på mesteparten av tiden. Vi kan bli raskere enn det! Alle de viktigste applikasjonene er bundet direkte til egne hurtigtaster. Du starter terminalen med `Super + Return` og en nettleser med `Super + Shift + Return`. Prøv å gjøre det ene etter det andre, så vil du se magien med Hyprlands flislegging i aksjon:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan deretter trykke `Super + J` for å stable dem oppå hverandre i stedet for side ved side:

 ![navigation-stacked](images/navigation-stacked.webp)

Trykk `Super + J` igjen for å få dem tilbake til side-ved-side-posisjonene deres. Prøv deretter `Super + Shift + Arrow Right` mens du er på nettleseren for å bytte om på vinduene.

Prøv nå `Super + Shift + T` for å starte Activity-monitoren. Den vises som et flytende vindu. Du kan flislegge den med `Super + T` (og trykke den igjen for å gjøre den flytende igjen). Trykk nå `Super + Shift + F` for å åpne filbehandleren. Du får et pent oppsett med fire vinduer:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellom vinduet du vil ha aktivt med `Super + Arrow`. Det bytter fokus og flytter markøren til midten av den nye applikasjonen. Ved kanten av en skjerm fortsetter den til skjermen på den siden.

Hvis du trykker `Super + Shift + 2`, flytter du den gjeldende fokuserte applikasjonen til det andre arbeidsområdet. `Super + Shift + 1` flytter den tilbake. (Og `Super + Shift + Alt + 2` flytter den gjeldende fokuserte applikasjonen til det andre arbeidsområdet uten å bytte til det).

Med mer enn én skjerm har hver skjerm sine egne arbeidsområder 1 til 10. `Super + 2` går til det andre arbeidsområdet på skjermen du er på, og den øverste linjen på hver skjerm viser dens egne arbeidsområder og det den viser. `Super + Tab` blar gjennom arbeidsområdene på skjermen du er på. `Super + Shift + Ctrl + Arrows` flytter vinduet du er på til skjermen i den retningen, til arbeidsområdet den viser, og `Super + Shift + Alt + Arrows` flytter arbeidsområdet du er på over til skjermen i den retningen, der det får samme nummer hvis det er ledig. En skjerm beholder arbeidsområdene sine når du kobler den fra: de slutter seg til en annen skjerms, nummerert etter dem den allerede har, og går tilbake til sine gamle numre når skjermen kommer tilbake.

Hvis du holder nede `Super` og bruker musen til å klikke på et vindu, kan du omorganisere hvor det sitter. Hvis du holder `Super` og bruker høyre museknapp, kan du fritt endre størrelsen på vinduet.

Du lukker et vindu med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå til fullskjerm med `Super + F`, eller til og med bare full bredde (og beholde den øverste linjen) med `Super + Alt + F`, eller fullskjerm inne i et vindu med `Super + Ctrl + F` (bra for YouTube!).

### Dwindle kontra scrolling-layout

Omarchys standardlayout heter dwindle. Den holder alle vinduene du åpner på et enkelt arbeidsområde synlige til enhver tid, selv om den må krympe dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også velge å gjøre et arbeidsområde til scrolling-layouten, der vinduer stilles opp side ved side, forbi den synlige kanten av skjermen. Du gjør et enkelt arbeidsområde til denne layouten via `Super + L`.

Å trykke `Super + L` igjen gjør arbeidsområdet flytende, der vinduer overlapper fritt og du plasserer dem selv, og et tredje trykk bringer det tilbake til dwindle. `Super + Alt + L` går gjennom dem den andre veien. Et vindu som flyter uansett — ett du har sprettet ut med `Super + T`, eller en app som alltid åpner flytende — fortsetter å flyte når arbeidsområdet går tilbake til flislegging. Den øverste linjen markerer arbeidsområdet du er på med layouten dets: et kvadrat for dwindle, en sirkel for scrolling og en trekant for flytende. Å klikke på det merket blar også gjennom layoutene.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget gjelder per arbeidsområde, og det blir værende. Så du kan beholde arbeidsområde 1 på dwindle for surfing og arbeidsområde 2 på scrolling for kode, og de vil komme tilbake slik etter en omstart.

Hvis du ønsker å bruke scrolling-layouten som standard, kan du angi det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytende arbeidsområder

Et flytende arbeidsområde fungerer som et tradisjonelt skrivebord: vinduer overlapper, og du flytter og endrer størrelsen på dem selv. Hvert vindu får en tittellinje i temaets farger, med knapper for å minimere, maksimere og lukke. `Super + M` minimerer også det fokuserte vinduet. Et minimert vindu venter i dokken; klikk på appen dets for å hente det tilbake. Klikk på et vindu for å bringe det fremst. Endre størrelsen fra en hvilken som helst kant eller et hvilket som helst hjørne. Dobbeltklikk på en tittellinje for å maksimere vinduet mens den øverste linjen forblir synlig, og igjen for å få den gamle størrelsen tilbake.

Et flytende arbeidsområde viser også en dokk, med festede apper, alt som kjører, og et rutenett med alle apper bak apper-knappen, som `Super + Alt + Space` og _Apps_ i Omarchy-menyen også åpner. Høyreklikk på en app i rutenettet, eller trykk `Delete`, for å avinstallere den. Klikk på en app for å åpne den, eller for å bringe vinduet dens fremst; klikk igjen for å bla gjennom vinduene dens. Midtklikk åpner et nytt vindu. Dra et ikon langs dokken for å flytte det; å dra en kjørende app inn blant de andre beholder den der. Høyreklikk for å beholde en app i dokken, ta den ut, eller avslutte den. Dokken går av veien for et fullskjermsvindu. Høyreklikk på apper-knappen for å flytte dokken til en annen kant eller få den til å skjule seg til pekeren når kanten dens. Posisjonen er også under _Appearance > Dock > Dock Position_, og `omarchy dock position left` og `omarchy dock autohide on` angir begge fra en terminal. Apper du beholder i dokken er falmede mens de ikke kjører.

Nye arbeidsområder, og alle du ikke har gitt en egen layout med `Super + L`, bruker standardlayouten. Å endre standarden tilbakestiller alle arbeidsområder uten vinduer til den, mens ett med vinduer på beholder layouten det har. Et vindu som er minimert til dokken, teller fortsatt som et vindu på arbeidsområdet det forlot. Velg den under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy-hyprland-workspace-layout-default scrolling` angir den fra en terminal.

### Gruppering av vinduer

Vinduer kan grupperes med `Super + G`. Når du er i en gruppe, vil hvert vindu du starter mens den er aktiv, tilhøre gruppen. Du kan flytte mellom disse grupperte vinduene med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for å gå direkte til et gruppert vindu i rekkefølge.

Du kan flytte et vindu ut av grupperingen med `Super + Alt + G`, eller oppløse hele gruppen ved å trykke `Super + G` igjen. Til slutt kan du flytte vinduer utenfor gruppen inn i den med `Super + Alt + Arrows`.

### Sprette ut vinduer

Du kan sprette et vindu ut av arbeidsområdeallokeringen dets med `Super + O`. Det fester det som et flytende vindu som følger deg til uansett hvilket arbeidsområde du går til. Flott for videospillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbeidsområde

Det finnes et spesielt scratchpad-arbeidsområde i full størrelse som legger seg over uansett hvilket arbeidsområde du er på. Du får tilgang til det som er på det med `Super + S`, og du plasserer vinduer der med `Super + Alt + S`.

Det fungerer bra for kontroller eller en terminal du vil samhandle raskt med uten å forlate det gjeldende arbeidsområdet.

### Quake-konsoll

Til slutt finnes det en Quake-konsoll i halv høyde som faller ned over uansett hvilket arbeidsområde du er på. Veksle den med `Super + Grave`, og plasser et vindu der med `Super + Shift + Grave`.

Den åpner med standardagenten din klar til å gå. Mens konsollen inneholder et enkelt vindu, faller den ned som et sentrert panel i stedet for å spenne over skjermen. Legg en andre app på den, så går den tilbake til full bredde, slik at de to har plass til å sitte side ved side.

For å flytte et vindu bort fra enten scratchpad-en eller konsollen, sender du det direkte til et annet arbeidsområde med noe som `Super + Shift + 1`.

### Det krever litt tilvenning!

Det tar litt tid å venne seg til å navigere på skrivebordet ditt på denne måten, men når du først gjør det, blir det vanskelig å gå tilbake til en tradisjonell musdrevet skrivebordsopplevelse!
