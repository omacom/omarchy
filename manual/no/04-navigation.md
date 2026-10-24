# Navigasjon

Alt i Omarchy skjer via tastaturet — _ALT!_ Når systemet starter for første gang, kan du bokstavelig talt ikke gjøre noe som helst med bare musen. Men du kan trykke `Super + Space` for å vise Omarchy-menyen, og herfra kan du gjøre så å si alt.

Men Omarchy-menyen er ikke engang ment å være den viktigste måten å betjene systemet på mesteparten av tiden. Vi kan gjøre det raskere enn det! Alle de viktigste applikasjonene er bundet direkte til individuelle hurtigtaster. Du starter terminalen med `Super + Return` og en nettleser med `Super + Shift + Return`. Prøv å gjøre det ene etter det andre, så ser du magien med Hyprlands flislegging i aksjon:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan deretter trykke `Super + J` for å stable dem oppå hverandre i stedet for side ved side:

 ![navigation-stacked](images/navigation-stacked.webp)

Trykk `Super + J` igjen for å returnere dem til posisjonene side ved side. Prøv deretter `Super + Shift + Arrow Right` mens du er i nettleseren for å bytte om vinduene.

Prøv nå `Super + Ctrl + T` for å starte Aktivitetsmonitoren. Den vises som et flytende vindu. Du kan flislegge den med `Super + T` (og trykke det igjen for å gjøre den flytende igjen). Trykk nå `Super + Shift + F` for å åpne filbehandleren. Da får du et ryddig firdelt oppsett:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellom vinduet du vil ha aktivt med `Super + Arrow`. Dette skifter fokus og flytter markøren til midten av den nye applikasjonen.

Hvis du trykker `Super + Shift + 2`, flytter du den aktive applikasjonen til det andre arbeidsområdet. `Super + Shift + 1` flytter den tilbake. (Og `Super + Shift + Alt + 2` flytter den aktive applikasjonen til det andre arbeidsområdet uten å skifte til det).

Hvis du holder nede `Super` og bruker musen til å klikke på et vindu, kan du omorganisere hvor det sitter. Hvis du holder `Super` og bruker høyre knapp på musen, kan du fritt endre størrelsen på vinduet.

Du lukker et vindu med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå til fullskjerm med `Super + F`, eller bare full bredde (med topplinjen beholdt) med `Super + Alt + F`, eller fullskjerm i et vindu med `Super + Ctrl + F` (bra for YouTube!).

### Dwindle kontra rullende oppsett

Omarchys standardoppsett kalles dwindle. Det holder alle vinduene du åpner på et enkelt arbeidsområde synlige til enhver tid, selv om det må krympe dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også velge å gjøre et arbeidsområde om til det rullende oppsettet, der vinduer stilles opp side ved side, forbi skjermens synlige kant. Du gjør et enkelt arbeidsområde om til dette oppsettet via `Super + L`.

Å trykke `Super + L` igjen gjør arbeidsområdet flytende, der vinduer overlapper fritt og du plasserer dem selv, og et tredje trykk returnerer det til dwindle. `Super + Alt + L` går gjennom dem den andre veien. Et vindu som flyter uansett — ett du løsnet med `Super + T`, eller en app som alltid åpnes flytende — fortsetter å flyte når arbeidsområdet går tilbake til flislegging. Topplinjen markerer arbeidsområdet du er på med oppsettet dets: en firkant for dwindle, en sirkel for rulling og en trekant for flytende. Å klikke på det merket sykler også gjennom oppsettene.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget er per arbeidsområde, og det blir værende. Så du kan beholde arbeidsområde 1 på dwindle for nettlesing og arbeidsområde 2 på rulling for kode, og de kommer tilbake slik etter en omstart.

Hvis du ønsker å bruke det rullende oppsettet som standard, kan du angi det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytende arbeidsområder

Et flytende arbeidsområde fungerer som et tradisjonelt skrivebord: vinduer overlapper, og du flytter og endrer størrelse på dem selv. Hvert vindu får en tittellinje i temaets farger, med knapper for å minimere, maksimere og lukke. `Super + M` minimerer også det fokuserte vinduet. Et minimert vindu venter i dokken; klikk på appen for å hente det tilbake. Klikk på et vindu for å bringe det frem. Endre størrelsen fra en hvilken som helst kant eller et hjørne. Dobbeltklikk på en tittellinje for å maksimere vinduet mens topplinjen fortsatt er synlig, og igjen for å få tilbake den gamle størrelsen.

Et flytende arbeidsområde viser også en dokk, med de festede appene dine, alt som kjører, og et rutenett med hver eneste app bak apper-knappen, som `Super + Alt + Space` og _Apper_ i Omarchy-menyen også åpner. Høyreklikk på en app i rutenettet, eller trykk `Delete`, for å avinstallere den. Klikk på en app for å åpne den, eller for å bringe vinduet dens frem; klikk igjen for å sykle gjennom vinduene dens. Midtklikk åpner et nytt vindu. Dra et ikon langs dokken for å flytte det; å dra en kjørende app inn blant de andre beholder den der. Høyreklikk for å beholde en app i dokken, ta den ut eller avslutte den. Dokken går av veien for et fullskjermvindu. Høyreklikk på apper-knappen for å flytte dokken til en annen kant eller la den skjule seg til pekeren når kanten dens. Posisjonen er også under _Trigger > Utseende > Dokk > Dokkposisjon_, og `omarchy dock position left` og `omarchy dock autohide on` angir begge fra en terminal. Apper du beholder i dokken er nedtonet mens de ikke kjører.

Nye arbeidsområder, og alle du ikke har gitt et eget oppsett med `Super + L`, bruker standardoppsettet. Å endre standarden tilbakestiller alle arbeidsområder uten vinduer til den, mens ett med vinduer på beholder oppsettet det har. Et vindu minimert til dokken teller fortsatt som et vindu på arbeidsområdet det forlot. Velg det under _Trigger > Utseende > Oppsett for arbeidsområde_: Flislegging, Rulling eller Flytende. `omarchy-hyprland-workspace-layout-default scrolling` angir det fra en terminal.

### Gruppering av vinduer

Vinduer kan grupperes med `Super + G`. Når du er i en gruppe, vil hvert vindu du starter mens den er aktiv tilhøre gruppen. Du kan flytte mellom disse grupperte vinduene med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for å gå direkte til det grupperte vinduet i rekkefølge.

Du kan flytte et vindu ut av grupperingen med `Super + Alt + G` eller oppløse hele gruppen ved å trykke `Super + G` igjen. Til slutt kan du flytte vinduer utenfor gruppen inn i den med `Super + Alt + Arrows`.

### Løsne vinduer

Du kan løsne et vindu fra arbeidsområdetildelingen med `Super + O`. Det fester det som et flytende vindu som følger deg til det arbeidsområdet du går til. Flott for videospillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbeidsområde

Til slutt finnes det et spesielt scratchpad-arbeidsområde som faller ned over det arbeidsområdet du er på, omtrent som en Quake-konsoll. Slå det av og på med `Super + Grave` eller `Super + S`, og plasser et vindu der med `Super + Shift + Grave` eller `Super + Alt + S`.

Det fungerer spesielt godt for en terminal som kjører en agent, eller for kontroller du vil samhandle raskt med uten å forlate det nåværende arbeidsområdet. For å flytte et vindu av scratchpadden sender du det direkte til et annet arbeidsområde med noe sånt som `Super + Shift + 1`.

Mens scratchpadden holder et enkelt vindu, faller den ned som et sentrert panel i stedet for å strekke seg over skjermen. Legg en andre app på den, og den går tilbake til full bredde, slik at de to har plass til å sitte side ved side.

### Det krever litt tilvenning!

Det tar litt tid å venne seg til å navigere skrivebordet på denne måten, men når du gjør det, blir det vanskelig å gå tilbake til en tradisjonell musedrevet skrivebordsopplevelse!
