# Navigation

Alt i Omarchy foregår via tastaturet — _ALT!_ Når systemet starter første gang, kan du bogstaveligt talt ikke foretage dig noget som helst med musen alene. Men du kan trykke på `Super + Space` for at vise Omarchy Menu, og herfra kan du gøre stort set alt.

Men Omarchy Menu er ikke engang tiltænkt som den primære måde at betjene systemet på det meste af tiden. Vi kan komme hurtigere frem end det! Alle de vigtigste programmer er bundet direkte til individuelle genvejstaster. Du starter terminalen med `Super + Return` og en browser med `Super + Shift + Return`. Prøv at gøre det ene efter det andet, og du vil se magien ved Hyprland tiling i aktion:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan derefter trykke på `Super + J` for at stable dem oven på hinanden i stedet for side om side:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryk på `Super + J` igen for at føre dem tilbage til deres positioner side om side. Prøv derefter `Super + Shift + Arrow Right`, mens du er i browseren, for at bytte om på vinduerne.

Prøv nu `Super + Shift + T` for at starte Activity monitor. Den vises som et flydende vindue med en titellinje, du kan trække i, og knapper til at minimere, maksimere og lukke det. Hvert flydende vindue får en, uanset hvor det befinder sig. Du kan tile det med `Super + T` (og trykke på det igen for at gøre det flydende igen). Tryk nu på `Super + Shift + F` for at åbne filhåndteringen. Du får en pæn opsætning i fire felter:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellem det vindue, du vil gøre aktivt, med `Super + Arrow`. Det skifter fokus og flytter markøren til midten af det nye program. Ved kanten af en skærm fortsætter det til skærmen på den side.

Hvis du trykker på `Super + Shift + 2`, flytter du det aktuelt fokuserede program over på det andet arbejdsområde. `Super + Shift + 1` flytter det tilbage. (Og `Super + Shift + Alt + 2` flytter det aktuelt fokuserede program over på det andet arbejdsområde uden at skifte til det).

Med mere end én skærm har hver skærm sine egne arbejdsområder 1 til 10. `Super + 2` går til det andet arbejdsområde på den skærm, du befinder dig på, og hver skærms øverste bjælke viser dens egne arbejdsområder og det, den viser. `Super + Tab` bladrer gennem arbejdsområderne på den skærm, du befinder dig på. `Super + Shift + Ctrl + Arrows` flytter det vindue, du befinder dig på, til skærmen i den retning, over på det arbejdsområde, den viser, og `Super + Shift + Alt + Arrows` flytter det arbejdsområde, du befinder dig på, over til skærmen i den retning, hvor det får det samme nummer, hvis det er ledigt. En skærm beholder sine arbejdsområder, når du trækker den fra: de slutter sig til en anden skærms, nummereret efter dem, den allerede har, og vender tilbage under deres gamle numre, når skærmen kommer tilbage.

Hvis du holder `Super` nede og bruger musen til at klikke på et vindue, kan du omarrangere, hvor det sidder. Hvis du holder `Super` nede og bruger højre knap på musen, kan du frit ændre vinduets størrelse.

Du lukker et vindue med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå i fuld skærm med `Super + F` eller endda bare i fuld bredde (og beholde den øverste bjælke) med `Super + Alt + F` eller i fuld skærm inden i et vindue med `Super + Ctrl + F` (godt til YouTube!).

### Dwindle vs scrolling layout

Omarchy standardlayout hedder dwindle. Det holder alle de vinduer, du åbner på et enkelt arbejdsområde, synlige hele tiden, også selvom det må krympe dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også vælge at gøre et arbejdsområde til scrolling layout, hvor vinduer stilles op side om side, ud over skærmens synlige kant. Du gør et enkelt arbejdsområde til dette layout via `Super + L`.

Et tryk på `Super + L` igen gør arbejdsområdet flydende, hvor vinduer overlapper frit, og du placerer dem selv, og et tredje tryk fører det tilbage til dwindle. `Super + Alt + L` går gennem dem den anden vej. Et vindue, der flyder alligevel — et, du har poppet ud med `Super + T`, eller en app, der altid åbner flydende — bliver ved med at flyde, når arbejdsområdet går tilbage til tiling. Den øverste bjælke markerer det arbejdsområde, du befinder dig på, med dets layout: en firkant for dwindle, en cirkel for scrolling og en trekant for floating. Et klik på det mærke skifter også layoutet, og det gør skærmtasten på bærbare, der har en, også.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget gælder pr. arbejdsområde, og det bliver hængende. Så du kan beholde arbejdsområde 1 på dwindle til browsing og arbejdsområde 2 på scrolling til kode, og de kommer tilbage på den måde efter en genstart.

Hvis du ønsker at bruge scrolling layout som standard, kan du indstille det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flydende arbejdsområder

Et flydende arbejdsområde fungerer som et traditionelt skrivebord: vinduer overlapper, og du flytter og tilpasser dem selv. Hvert vindue får en titellinje i dit temas farver med knapper til at minimere, maksimere og lukke. `Super + M` minimerer også det fokuserede vindue. Et minimeret vindue venter i docken; klik på dets app for at hente det tilbage. Klik på et vindue for at bringe det frem. Tilpas dets størrelse fra enhver kant eller ethvert hjørne. Dobbeltklik på en titellinje for at maksimere vinduet, mens den øverste bjælke stadig er i syne, og igen for at få dets gamle størrelse tilbage. Chrome og andre Chromium-baserede browsere, Disks og Document Viewer springer titellinjen over og bruger i stedet deres eget header; `Super + Alt + F` maksimerer dem, og `Super + M` minimerer dem.

Hvert arbejdsområde har en dock med dine fastgjorte apps, alt det, der kører, og et gitter med hver eneste app bag apps-knappen, som `Super + Alt + Space` og _Apps_ i Omarchy Menu også åbner. Højreklik på en app på gitteret, eller tryk på `Delete`, for at afinstallere den. Klik på en app for at åbne den eller for at bringe dens vindue frem; klik igen for at bladre gennem dens vinduer. Files henter kun et vindue tilbage fra det arbejdsområde, du befinder dig på, og åbner ellers et nyt, og Terminal og Agent starter altid et nyt, selvom et minimeret vindue kommer tilbage først. Mellemklik åbner et nyt vindue. Træk et ikon langs docken for at flytte det; at trække en kørende app ind blandt de andre beholder den der. Højreklik for at beholde en app i docken, tage den ud eller afslutte den. Docken bliver fremme, mens et arbejdsområde er tomt, og når arbejdsområdet har et vindue, skjuler den sig, indtil markøren når dens kant. Et vindue i fuld skærm skjuler den helt. Træk apps-knappen mod en anden kant af skærmen for at flytte docken derhen. Højreklik på den for _Position_ for at vælge en kant og _Layout_ for at indstille standardlayoutet, som _Appearance > Workspace Layout_ gør. Positionen findes også under _Appearance > Dock > Dock Position_, og `omarchy dock position left` indstiller den fra en terminal. Apps, du beholder i docken, er nedtonede, mens de ikke kører. For at begrænse docken til flydende arbejdsområder skal du bruge _Appearance > Dock > Dock Only on Floating_ eller `omarchy dock tiling off`.

Nye arbejdsområder, og alle dem, du ikke har givet deres eget layout med `Super + L`, bruger standardlayoutet. En ændring af standarden nulstiller hvert arbejdsområde uden vinduer til den, mens et med vinduer på beholder det layout, det har. Et vindue, der er minimeret til docken, tæller stadig som et vindue på det arbejdsområde, det forlod. Vælg den under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy hyprland workspace layout default scrolling` indstiller den fra en terminal.

### Gruppering af vinduer

Vinduer kan grupperes med `Super + G`. Når du først er i en gruppe, tilhører hvert vindue, du starter, mens den er aktiv, gruppen. Du kan bevæge dig mellem disse grupperede vinduer med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for at gå direkte til de grupperede vinduer i rækkefølge.

Du kan flytte et vindue ud af grupperingen med `Super + Alt + G` eller opløse hele gruppen ved at trykke på `Super + G` igen. Endelig kan du flytte vinduer uden for gruppen ind i den med `Super + Alt + Arrows`.

### At poppe vinduer ud

Du kan poppe et vindue ud af dets tildeling til et arbejdsområde med `Super + O`. Det fastgør det som et flydende vindue, der følger dig, uanset hvilket arbejdsområde du går til. Fremragende til videoafspillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbejdsområde

Der findes et særligt scratchpad-arbejdsområde i fuld størrelse, som lægger sig over det arbejdsområde, du aktuelt befinder dig på. Du tilgår det, der er på det, med `Super + S`, og du placerer vinduer der med `Super + Alt + S`.

Det fungerer godt til kontroller eller en terminal, du vil interagere hurtigt med uden at forlade det aktuelle arbejdsområde.

### Quake-konsol

Endelig findes der en Quake-konsol i halv højde, som falder ned over det arbejdsområde, du aktuelt befinder dig på. Slå den til og fra med `Super + the key above Tab` (grave på amerikanske layouts), og placer et vindue der med `Super + Shift + the key above Tab`.

Første gang den åbner, starter den din standardagent eller beder dig vælge en, hvis du ikke har valgt en endnu. Mens konsollen kun rummer et enkelt vindue, falder den ned som et centreret panel i stedet for at spænde over skærmen. Sæt en anden app på den, og den går tilbage til fuld bredde, så de to har plads til at sidde side om side.

For at flytte et vindue væk fra enten scratchpad eller konsollen skal du sende det direkte til et andet arbejdsområde med noget i retning af `Super + Shift + 1`.

### Det kræver lidt tilvænning!

Det tager lidt tid at vænne sig til at navigere på sit skrivebord på denne måde, men når du først gør det, bliver det svært at gå tilbage til en traditionel musestyret skrivebordsoplevelse!
