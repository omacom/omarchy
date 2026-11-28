# Navigation

Alt i Omarchy foregår via tastaturet — _ALT!_ Når systemet starter første gang, kan du bogstaveligt talt ikke gøre noget som helst med musen alene. Men du kan trykke på `Super + Space` for at vise Omarchy-menuen, og herfra kan du gøre stort set alt.

Men Omarchy-menuen er ikke engang ment som den primære måde at betjene systemet på det meste af tiden. Vi kan gøre det hurtigere end det! Alle de vigtigste programmer er bundet direkte til individuelle genvejstaster. Du starter terminalen med `Super + Return` og en browser med `Super + Shift + Return`. Prøv at gøre det ene efter det andet, så vil du se Hyprlands tiling-magi i aktion:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan derefter trykke på `Super + J` for at stable dem oven på hinanden i stedet for side om side:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryk på `Super + J` igen for at føre dem tilbage til deres side-om-side-positioner. Prøv derefter `Super + Shift + Arrow Right`, mens du er i browseren, for at bytte vinduerne om.

Prøv nu `Super + Shift + T` for at starte Aktivitetsovervågningen. Den vises som et svævende vindue med en titellinje, du kan trække i, og knapper til at minimere, maksimere og lukke det. Hvert svævende vindue får en, uanset hvor det er. Du kan sætte det i tiling med `Super + T` (og trykke på den igen for at gøre det svævende igen). Tryk nu på `Super + Shift + F` for at åbne filhåndteringen. Du får en pæn opsætning med fire veje:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellem det vindue, du vil have aktivt, med `Super + Arrow`. Det skifter fokus og flytter markøren til midten af det nye program. Ved kanten af en skærm fortsætter det til skærmen på den side.

Hvis du trykker på `Super + Shift + 2`, flytter du det aktuelt fokuserede program over på det andet arbejdsområde. `Super + Shift + 1` flytter det tilbage. (Og `Super + Shift + Alt + 2` flytter det aktuelt fokuserede program over på det andet arbejdsområde uden at skifte til det).

Med mere end én skærm har hver skærm sine egne arbejdsområder 1 til 10. `Super + 2` går til det andet arbejdsområde på den skærm, du er på, og hver skærms øverste bjælke viser sine egne arbejdsområder og det, den viser. `Super + Tab` skifter mellem arbejdsområderne på den skærm, du er på. `Super + Shift + Ctrl + Arrows` flytter det vindue, du er på, til skærmen i den retning, over på det arbejdsområde, den viser, og `Super + Shift + Alt + Arrows` flytter det arbejdsområde, du er på, over til skærmen i den retning, hvor det får det samme nummer, hvis det er ledigt. En skærm beholder sine arbejdsområder, når du tager den ud: de slutter sig til en anden skærms, nummereret efter dem, den allerede har, og går tilbage til deres gamle numre, når skærmen vender tilbage.

Hvis du holder `Super` nede og bruger musen til at klikke på et vindue, kan du omarrangere, hvor det sidder. Hvis du holder `Super` nede og bruger højre museknap, kan du frit ændre vinduets størrelse.

Du lukker et vindue med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå i fuldskærm med `Super + F` eller endda kun i fuld bredde (mens du beholder den øverste bjælke) med `Super + Alt + F` eller fuldskærm inden i et vindue med `Super + Ctrl + F` (godt til YouTube!).

### Dwindle vs scrolling layout

Omarchys standardlayout kaldes dwindle. Det holder alle de vinduer, du åbner på et enkelt arbejdsområde, synlige hele tiden, selv hvis det må krympe dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også vælge at gøre et arbejdsområde til scrolling-layoutet, hvor vinduer er stillet op side om side ud over skærmens synlige kant. Du gør et enkelt arbejdsområde til dette layout via `Super + L`.

Tryk på `Super + L` igen gør arbejdsområdet svævende, hvor vinduer overlapper frit, og du placerer dem selv, og et tredje tryk fører det tilbage til dwindle. `Super + Alt + L` går igennem dem den anden vej. Et vindue, der alligevel svæver — et, du har poppet ud med `Super + T`, eller en app, der altid åbner svævende — bliver ved med at svæve, når arbejdsområdet går tilbage til tiling. Den øverste bjælke markerer det arbejdsområde, du er på, med dets layout: en firkant for dwindle, en cirkel for scrolling og en trekant for svævende. Klik på dette mærke skifter også layoutet, og det gør skærmtasten på bærbare, der har en, også.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget gælder pr. arbejdsområde, og det bliver hængende. Så du kan beholde arbejdsområde 1 på dwindle til browsing og arbejdsområde 2 på scrolling til kode, og de kommer tilbage på den måde efter en genstart.

Hvis du ønsker at bruge scrolling-layoutet som standard, kan du indstille det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Svævende arbejdsområder

Et svævende arbejdsområde fungerer som et traditionelt skrivebord: vinduer overlapper, og du flytter og tilpasser selv deres størrelse. Hvert vindue får en titellinje i dit temas farver med knapper til at minimere, maksimere og lukke. `Super + M` minimerer også det fokuserede vindue. Et minimeret vindue venter i docken; klik på dets app for at hente det tilbage. Klik på et vindue for at bringe det frem. Tilpas dets størrelse fra enhver kant eller hjørne. Dobbeltklik på en titellinje for at maksimere vinduet, mens den øverste bjælke stadig er i syne, og igen for at få dets gamle størrelse tilbage. Chrome og andre Chromium-baserede browsere, Disks og Document Viewer springer titellinjen over og bruger deres eget hoved i stedet; `Super + Alt + F` maksimerer dem, og `Super + M` minimerer dem.

Hvert arbejdsområde har en dock med dine fastgjorte apps, alt det, der kører, og et gitter med alle apps bag apps-knappen, som `Super + Alt + Space` og _Apps_ i Omarchy-menuen også åbner. Højreklik på en app i gitteret, eller tryk på `Delete`, for at afinstallere den. Klik på en app for at åbne den eller for at bringe dens vindue frem; klik igen for at skifte mellem dens vinduer. Files henter kun et vindue tilbage fra det arbejdsområde, du er på, og åbner ellers et nyt, og Terminal og Agent starter altid et nyt, dog kommer et minimeret vindue tilbage først. Mellemklik åbner et nyt vindue. Træk et ikon langs docken for at flytte det; at trække en kørende app ind blandt de andre beholder den der. Højreklik for at beholde en app i docken, fjerne den eller afslutte den. Docken bliver fremme, mens et arbejdsområde er tomt, og når arbejdsområdet har et vindue, skjuler den sig, indtil markøren når dens kant. Et fuldskærmsvindue skjuler den helt. Træk apps-knappen mod en anden kant af skærmen for at flytte docken derhen. Højreklik på den for _Position_, for at vælge en kant, _Layout_, for at indstille standardlayoutet, som _Appearance > Workspace Layout_ gør, og _Visibility_, for at beholde docken altid tændt, lade den første app skjule den eller beholde den altid skjult. `omarchy dock visibility always` indstiller det fra en terminal. Positionen er også under _Appearance > Dock > Dock Position_, og `omarchy dock position left` indstiller den fra en terminal. Apps, du beholder i docken, er falmede, mens de ikke kører. For at begrænse docken til svævende arbejdsområder skal du bruge _Appearance > Dock > Dock Only on Floating_ eller `omarchy dock tiling off`.

Nye arbejdsområder, og alle dem, du ikke har givet deres eget layout med `Super + L`, bruger standardlayoutet. Ændring af standarden nulstiller alle arbejdsområder uden vinduer til den, mens et med vinduer på beholder det layout, det har. Et vindue, der er minimeret til docken, tæller stadig som et vindue på det arbejdsområde, det forlod. Vælg den under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy hyprland workspace layout default scrolling` indstiller den fra en terminal.

### Gruppering af vinduer

Vinduer kan grupperes med `Super + G`. Når du først er i en gruppe, vil hvert vindue, du starter, mens den er aktiv, tilhøre gruppen. Du kan flytte mellem disse grupperede vinduer med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for at gå direkte til de grupperede vinduer i rækkefølge.

Du kan flytte et vindue ud af grupperingen med `Super + Alt + G` eller opløse hele gruppen ved at trykke på `Super + G` igen. Endelig kan du flytte vinduer uden for gruppen ind i den med `Super + Alt + Arrows`.

### At poppe vinduer ud

Du kan poppe et vindue ud af dets tildeling til et arbejdsområde med `Super + O`. Det fastgør det som et svævende vindue, der følger dig på hvilket arbejdsområde du end går til. Perfekt til videoafspillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbejdsområde

Der er et særligt scratchpad-arbejdsområde i fuld størrelse, som lægger sig over det arbejdsområde, du aktuelt er på. Du tilgår det, der er på det, med `Super + S`, og du placerer vinduer der med `Super + Alt + S`.

Det fungerer godt til betjeningselementer eller en terminal, du hurtigt vil interagere med uden at forlade det aktuelle arbejdsområde.

### Quake-konsol

Endelig er der en Quake-konsol i halv højde, som falder ned over det arbejdsområde, du aktuelt er på. Slå den til og fra med `Super + the key above Tab` (grave på US-layouts), og placer et vindue der med `Super + Shift + the key above Tab`.

Første gang den åbner, starter den din standardagent eller beder dig vælge en, hvis du ikke har valgt en endnu. Mens konsollen kun indeholder ét vindue, falder den ned som et centreret panel i stedet for at spænde over skærmen. Sæt en anden app på den, så går den tilbage til fuld bredde, så de to har plads til at sidde side om side.

For at flytte et vindue væk fra enten scratchpadden eller konsollen skal du sende det direkte til et andet arbejdsområde med noget i retning af `Super + Shift + 1`.

### Det tager lidt tid at vænne sig til!

Det tager lidt tid at vænne sig til at navigere rundt på dit skrivebord på denne måde, men når du først gør det, bliver det svært at gå tilbage til en traditionel musestyret skrivebordsoplevelse!
