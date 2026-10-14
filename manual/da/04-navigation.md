# Navigation

Alt i Omarchy sker via tastaturet — _ALT!_ Når systemet starter første gang, kan du bogstaveligt talt ikke gøre en eneste ting med musen alene. Men du kan trykke på `Super + Space` for at vise Omarchy-menuen, og herfra kan du gøre stort set alt.

Men Omarchy-menuen er ikke engang tænkt som den primære måde at betjene systemet på det meste af tiden. Vi kan gøre det hurtigere end det! Alle de vigtigste applikationer er bundet direkte til individuelle genvejstaster. Du starter terminalen med `Super + Return` og en browser med `Super + Shift + Return`. Prøv at gøre det ene efter det andet, så ser du magien ved Hyprlands tiling i aktion:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan derefter trykke på `Super + J` for at stable dem oven på hinanden i stedet for side om side:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryk på `Super + J` igen for at bringe dem tilbage til deres positioner side om side. Prøv derefter `Super + Shift + Arrow Right`, mens du er på browseren, for at bytte rundt på vinduerne.

Prøv nu `Super + Ctrl + T` for at starte Aktivitetsmonitoren. Den vises som et flydende vindue. Du kan tile den med `Super + T` (og trykke på det igen for at gøre den flydende igen). Tryk nu på `Super + Shift + F` for at åbne filhåndteringen. Du får en smart opsætning med fire vinduer:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellem det vindue, du vil have aktivt, med `Super + Arrow`. Det skifter fokus og flytter markøren til midten af den nye applikation.

Hvis du trykker på `Super + Shift + 2`, flytter du den aktuelt fokuserede applikation til det andet arbejdsområde. `Super + Shift + 1` flytter den tilbage. (Og `Super + Shift + Alt + 2` flytter den aktuelt fokuserede applikation til det andet arbejdsområde uden at skifte til det).

Hvis du holder `Super` nede og bruger musen til at klikke på et vindue, kan du omarrangere, hvor det sidder. Hvis du holder `Super` nede og bruger højre museknap, kan du frit ændre vinduets størrelse.

Du lukker et vindue med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå i fuld skærm med `Super + F` eller endda bare fuld bredde (med den øverste bar bevaret) med `Super + Alt + F` eller fuld skærm inden i et vindue med `Super + Ctrl + F` (godt til YouTube!).

### Dwindle vs. scrolling-layout

Omarchys standardlayout hedder dwindle. Det holder alle de vinduer, du åbner på et enkelt arbejdsområde, synlige hele tiden, også selvom det må krympe dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også vælge at gøre et arbejdsområde til scrolling-layoutet, hvor vinduer er stillet op side om side, ud over skærmens synlige kant. Du gør et enkelt arbejdsområde til dette layout via `Super + L`.

Hvis du trykker på `Super + L` igen, bliver arbejdsområdet flydende, hvor vinduer overlapper frit, og du placerer dem selv, og et tredje tryk bringer det tilbage til dwindle. `Super + Alt + L` går igennem dem den anden vej. Et vindue, der alligevel flyder — et, du poppede ud med `Super + T`, eller en app, der altid åbner flydende — bliver ved med at flyde, når arbejdsområdet går tilbage til tiling. Den øverste bar markerer det arbejdsområde, du er på, med dets layout: en firkant for dwindle, en cirkel for scrolling og en trekant for flydende. Hvis du klikker på det mærke, skifter layoutet også.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget gælder pr. arbejdsområde, og det bliver hængende. Så du kan beholde arbejdsområde 1 på dwindle til browsing og arbejdsområde 2 på scrolling til kode, og de kommer tilbage på den måde efter en genstart.

Hvis du vil bruge scrolling-layoutet som standard, kan du indstille det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flydende arbejdsområder

Et flydende arbejdsområde fungerer som et traditionelt skrivebord: vinduer overlapper, og du flytter og tilpasser dem selv. Hvert vindue får en titellinje i dit temas farver med knapper til at minimere, maksimere og lukke. `Super + M` minimerer også det fokuserede vindue. Et minimeret vindue venter i docken; klik på dets app for at bringe det tilbage. Klik på et vindue for at bringe det frem. Ændr størrelsen fra enhver kant eller ethvert hjørne. Dobbeltklik på en titellinje for at maksimere vinduet, mens den øverste bar stadig er synlig, og igen for at få dets gamle størrelse tilbage.

Et flydende arbejdsområde viser også en dock med dine fastgjorte apps, alt det, der kører, og et gitter med alle apps bag apps-knappen, som `Super + Alt + Space` og _Apps_ i Omarchy-menuen også åbner. Højreklik på en app i gitteret, eller tryk på `Delete`, for at afinstallere den. Klik på en app for at åbne den eller bringe dens vindue frem; klik igen for at bladre igennem dens vinduer. Midterklik åbner et nyt vindue. Træk et ikon langs docken for at flytte det; hvis du trækker en kørende app ind blandt de andre, bliver den der. Højreklik for at beholde en app i docken, tage den ud eller afslutte den. Docken flytter sig af vejen for et vindue i fuld skærm. Højreklik på apps-knappen for at flytte docken til en anden kant eller få den til at skjule sig, indtil markøren når dens kant. Placeringen findes også under _Trigger > Appearance > Dock > Dock Position_, og `omarchy dock position left` og `omarchy dock autohide on` indstiller begge dele fra en terminal. Apps, du beholder i docken, er nedtonede, mens de ikke kører.

Nye arbejdsområder, og ethvert arbejdsområde du ikke har givet dets eget layout med `Super + L`, bruger standardlayoutet. Hvis du ændrer standarden, nulstilles alle arbejdsområder uden vinduer til den, mens et arbejdsområde med vinduer på beholder det layout, det har. Et vindue, der er minimeret til docken, tæller stadig som et vindue på det arbejdsområde, det forlod. Vælg den under _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy-hyprland-workspace-layout-default scrolling` indstiller den fra en terminal.

### Gruppering af vinduer

Vinduer kan grupperes med `Super + G`. Når du er i en gruppe, vil hvert vindue, du starter, mens den er aktiv, tilhøre gruppen. Du kan flytte mellem disse grupperede vinduer med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for at gå direkte til et grupperet vindue i rækkefølge.

Du kan flytte et vindue ud af grupperingen med `Super + Alt + G` eller opløse hele gruppen ved at trykke på `Super + G` igen. Endelig kan du flytte vinduer uden for gruppen ind i den med `Super + Alt + Arrows`.

### At poppe vinduer ud

Du kan poppe et vindue ud af dets tildeling til arbejdsområdet med `Super + O`. Det fastgør det som et flydende vindue, der følger dig på ethvert arbejdsområde, du går til. Fremragende til videoafspillere og den slags.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbejdsområde

Til sidst er der et særligt scratchpad-arbejdsområde, der falder ned over det arbejdsområde, du aktuelt er på, meget ligesom en Quake-konsol. Slå det til og fra med `Super + Grave` eller `Super + S`, og placér et vindue der med `Super + Shift + Grave` eller `Super + Alt + S`.

Det fungerer særligt godt til en terminal, der kører en agent, eller til kontrolelementer, du vil interagere hurtigt med uden at forlade det aktuelle arbejdsområde. For at flytte et vindue væk fra scratchpadden skal du sende det direkte til et andet arbejdsområde med noget som `Super + Shift + 1`.

Mens scratchpadden indeholder et enkelt vindue, falder den ned som et centreret panel i stedet for at spænde over skærmen. Sæt en anden app på den, så går den tilbage til fuld bredde, så de to har plads til at sidde side om side.

### Det kræver lidt tilvænning!

Det tager lidt tid at vænne sig til at navigere på dit skrivebord på denne måde, men når du først gør det, bliver det svært at gå tilbage til en traditionel musdrevet skrivebordsoplevelse!
