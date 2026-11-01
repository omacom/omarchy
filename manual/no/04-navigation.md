# Navigasjon

Alt i Omarchy skjer via tastaturet — _ALT!_ Når systemet først starter, kan du bokstavelig talt ikke gjøre noen ting med bare musen. Men du kan trykke `Super + Space` for å vise Omarchy-menyen, og herfra kan du gjøre omtrent alt.

Men Omarchy-menyen er ikke engang ment å være den viktigste måten å bruke systemet på mesteparten av tiden. Vi kan gjøre det raskere enn det! Alle de viktigste applikasjonene er bundet direkte til egne hurtigtaster. Du starter terminalen med `Super + Return` og en nettleser med `Super + Shift + Return`. Prøv å gjøre det ene etter det andre, så ser du magien i Hyprlands flislegging i aksjon:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan deretter trykke `Super + J` for å stable dem oppå hverandre i stedet for side ved side:

 ![navigation-stacked](images/navigation-stacked.webp)

Trykk `Super + J` igjen for å få dem tilbake til plassene side ved side. Prøv deretter `Super + Shift + Arrow Right` mens du er i nettleseren, for å bytte plass på vinduene.

Prøv nå `Super + Shift + T` for å starte aktivitetsmonitoren. Den vises som et flytende vindu. Du kan flislegge den med `Super + T` (og trykke det igjen for å gjøre den flytende igjen). Trykk nå `Super + Shift + F` for å åpne filbehandleren. Da får du et ryddig oppsett med fire vinduer:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellom vinduet du vil skal være aktivt, med `Super + Arrow`. Det bytter fokus og flytter markøren til midten av den nye applikasjonen. Ved kanten av en skjerm fortsetter den til skjermen på den siden.

Hvis du trykker `Super + Shift + 2`, flytter du den nåværende fokuserte applikasjonen til det andre arbeidsområdet. `Super + Shift + 1` flytter den tilbake. (Og `Super + Shift + Alt + 2` flytter den nåværende fokuserte applikasjonen til det andre arbeidsområdet uten å bytte til det).

Med mer enn én skjerm har hver skjerm sine egne arbeidsområder 1 til 10. `Super + 2` går til det andre arbeidsområdet på skjermen du er på, og den øverste linjen på hver skjerm viser sine egne arbeidsområder og det den viser. `Super + Tab` blar gjennom arbeidsområdene på skjermen du er på. `Super + Shift + Ctrl + Arrows` flytter vinduet du er på, til skjermen i den retningen, til arbeidsområdet den viser, og `Super + Shift + Alt + Arrows` flytter arbeidsområdet du er på, over til skjermen i den retningen, der det får samme nummer hvis det er ledig. En skjerm beholder arbeidsområdene sine når du kobler den fra: de slår seg sammen med en annen skjerms, nummerert etter dem den allerede har, og går tilbake til de gamle numrene sine når skjermen kommer tilbake.

Hvis du holder nede `Super` og bruker musen til å klikke på et vindu, kan du endre hvor det plasseres. Hvis du holder `Super` og bruker høyre museknapp, kan du fritt endre størrelsen på vinduet.

Du lukker et vindu med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå i fullskjerm med `Super + F`, eller til og med bare i full bredde (og beholde den øverste linjen) med `Super + Alt + F`, eller fullskjerm inne i et vindu med `Super + Ctrl + F` (bra for YouTube!).

### Dwindle kontra rullelayout

Standardlayouten i Omarchy heter dwindle. Den holder alle vinduene du åpner på ett enkelt arbeidsområde, synlige til enhver tid, selv om den må krympe dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også velge å gjøre et arbeidsområde om til rullelayout, der vinduer stilles opp side ved side, utover den synlige kanten av skjermen. Du gjør ett enkelt arbeidsområde om til denne layouten via `Super + L`.

Å trykke `Super + L` igjen gjør arbeidsområdet flytende, der vinduer overlapper fritt og du plasserer dem selv, og et tredje trykk fører det tilbake til dwindle. `Super + Alt + L` går gjennom dem i motsatt retning. Et vindu som flyter uansett — ett du har hoppet ut med `Super + T`, eller en app som alltid åpner flytende — fortsetter å flyte når arbeidsområdet går tilbake til flislegging. Den øverste linjen markerer arbeidsområdet du er på, med layouten dets: en firkant for dwindle, en sirkel for rulling og en trekant for flytende. Å klikke på det merket bytter også layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget gjelder per arbeidsområde, og det blir værende. Så du kan beholde arbeidsområde 1 på dwindle til surfing og arbeidsområde 2 på rulling til koding, og de kommer tilbake slik etter en omstart.

Hvis du vil bruke rullelayouten som standard, kan du angi det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytende arbeidsområder

Et flytende arbeidsområde fungerer som et tradisjonelt skrivebord: vinduer overlapper, og du flytter og tilpasser størrelsen på dem selv. Hvert vindu får en tittellinje i fargene til temaet ditt, med knapper for å minimere, maksimere og lukke. `Super + M` minimerer også det fokuserte vinduet. Et minimert vindu venter i dokken; klikk på appen dets for å hente det tilbake. Klikk på et vindu for å hente det frem. Endre størrelsen fra en hvilken som helst kant eller et hvilket som helst hjørne. Dobbeltklikk på en tittellinje for å maksimere vinduet mens den øverste linjen fortsatt er synlig, og igjen for å få den gamle størrelsen tilbake.

Et flytende arbeidsområde viser også en dokk, med de festede appene dine, alt som kjører, og et rutenett med alle apper bak app-knappen, som `Super + Alt + Space` og _Apps_ i Omarchy-menyen også åpner. Høyreklikk på en app i rutenettet, eller trykk `Delete`, for å avinstallere den. Klikk på en app for å åpne den, eller for å hente vinduet dess frem; klikk igjen for å bla gjennom vinduene dess. Midtklikk åpner et nytt vindu. Dra et ikon langs dokken for å flytte det; å dra en kjørende app inn blant de andre beholder den der. Høyreklikk for å beholde en app i dokken, ta den ut eller avslutte den. Dokken går av veien for et fullskjermsvindu. Høyreklikk på app-knappen for å flytte dokken til en annen kant eller få den til å skjule seg til pekeren når kanten dess. Posisjonen finnes også under _Appearance > Dock > Dock Position_, og `omarchy dock position left` og `omarchy dock autohide on` setter begge fra en terminal. Apper du beholder i dokken, vises nedtonet mens de ikke kjører.

Nye arbeidsområder, og alle du ikke har gitt en egen layout med `Super + L`, bruker standardlayouten. Å endre standarden tilbakestiller alle arbeidsområder uten vinduer til den, mens ett med vinduer på beholder layouten det har. Et vindu minimert til dokken teller fortsatt som et vindu på arbeidsområdet det forlot. Velg den under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy-hyprland-workspace-layout-default scrolling` angir den fra en terminal.

### Gruppering av vinduer

Vinduer kan grupperes med `Super + G`. Når du er i en gruppe, vil alle vinduer du starter mens den er aktiv, tilhøre gruppen. Du kan flytte mellom disse grupperte vinduene med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for å gå direkte til grupperte vinduer i rekkefølge.

Du kan flytte et vindu ut av grupperingen med `Super + Alt + G`, eller oppheve hele gruppen ved å trykke `Super + G` igjen. Til slutt kan du flytte vinduer utenfor gruppen inn i den med `Super + Alt + Arrows`.

### Å hoppe ut vinduer

Du kan hoppe et vindu ut av arbeidsområdet det er tildelt, med `Super + O`. Det fester det som et flytende vindu som følger deg til uansett hvilket arbeidsområde du går til. Flott for videospillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbeidsområde

Det finnes et spesielt scratchpad-arbeidsområde i full størrelse som legger seg over arbeidsområdet du er på. Du får tilgang til det som er på det, med `Super + S`, og du plasserer vinduer der med `Super + Alt + S`.

Det fungerer bra for kontroller eller en terminal du vil samhandle med raskt, uten å forlate det nåværende arbeidsområdet.

### Quake-konsoll

Til slutt finnes det en Quake-konsoll i halv høyde som faller ned over arbeidsområdet du er på. Slå den av og på med `Super + Grave`, og plasser et vindu der med `Super + Shift + Grave`.

Den åpner med standardagenten din klar til å kjøre. Mens konsollen inneholder ett enkelt vindu, faller den ned som et sentrert panel i stedet for å strekke seg over skjermen. Legg en andre app på den, og den går tilbake til full bredde, så de to har plass til å ligge side ved side.

For å flytte et vindu vekk fra enten scratchpad-en eller konsollen sender du det direkte til et annet arbeidsområde med noe som `Super + Shift + 1`.

### Det tar litt tid å venne seg til!

Det tar litt tid å venne seg til å navigere på skrivebordet på denne måten, men når du først gjør det, blir det vanskelig å gå tilbake til en tradisjonell musestyrt skrivebordsopplevelse!
