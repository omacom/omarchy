# Navigation

Alt i Omarchy foregår via tastaturet — _ALT!_ Når systemet starter første gang, kan du bogstaveligt talt ikke gøre noget som helst med musen alene. Men du kan trykke på `Super + Space` for at vise Omarchy Menu, og herfra kan du gøre stort set alt.

Men Omarchy-menuen er ikke engang ment som den primære måde at betjene systemet på det meste af tiden. Vi kan gøre det hurtigere end det! Alle de vigtigste applikationer er bundet direkte til individuelle genvejstaster. Du starter terminalen med `Super + Return` og en browser med `Super + Shift + Return`. Prøv at gøre det ene efter det andet, og du vil se magien ved Hyprlands tiling i aktion:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan derefter trykke på `Super + J` for at stable dem oven på hinanden i stedet for side om side:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryk på `Super + J` igen for at føre dem tilbage til deres positioner side om side. Prøv derefter `Super + Shift + Arrow Right`, mens du er i browseren, for at bytte om på vinduerne.

Prøv nu `Super + Shift + T` for at starte Activity monitor. Den vises som et flydende vindue. Du kan tile den ved hjælp af `Super + T` (og trykke på den igen for at gøre den flydende igen). Tryk nu på `Super + Shift + F` for at åbne filhåndteringen. Du får en pæn opsætning med fire vinduer:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellem det vindue, du vil have aktivt, med `Super + Arrow`. Det skifter fokus og flytter markøren til midten af den nye applikation. Ved kanten af en skærm fortsætter den til skærmen på den side.

Hvis du trykker på `Super + Shift + 2`, flytter du den aktuelt fokuserede applikation over på det andet arbejdsområde. `Super + Shift + 1` flytter den tilbage. (Og `Super + Shift + Alt + 2` flytter den aktuelt fokuserede applikation over på det andet arbejdsområde uden at skifte til det).

Med mere end én skærm har hver skærm sine egne arbejdsområder 1 til 10. `Super + 2` går til det andet arbejdsområde på den skærm, du er på, og hver skærms øverste bjælke viser sine egne arbejdsområder og det, den viser. `Super + Tab` bladrer gennem arbejdsområderne på den skærm, du er på. `Super + Shift + Ctrl + Arrows` flytter det vindue, du er på, til skærmen i den retning, over på det arbejdsområde, den viser, og `Super + Shift + Alt + Arrows` flytter det arbejdsområde, du er på, over til skærmen i den retning, hvor det får samme nummer, hvis det er ledigt. En skærm beholder sine arbejdsområder, når du trækker stikket ud: de slutter sig til en anden skærms, nummereret efter dem, den allerede har, og går tilbage under deres gamle numre, når skærmen vender tilbage.

Hvis du holder `Super` nede og bruger musen til at klikke på et vindue, kan du omarrangere, hvor det sidder. Hvis du holder `Super` nede og bruger højre museknap, kan du frit ændre størrelsen på vinduet.

Du lukker et vindue med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå i fuldskærm med `Super + F` eller endda bare i fuld bredde (så den øverste bjælke bevares) med `Super + Alt + F` eller fuldskærm inden i et vindue med `Super + Ctrl + F` (godt til YouTube!).

### Dwindle vs. rullelayout

Omarchys standardlayout hedder dwindle. Det holder alle de vinduer, du åbner på et enkelt arbejdsområde, synlige hele tiden, selv hvis det er nødt til at krympe dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også vælge at gøre et arbejdsområde til rullelayoutet, hvor vinduer er stillet op side om side, ud over skærmens synlige kant. Du gør et enkelt arbejdsområde til dette layout via `Super + L`.

Et tryk på `Super + L` igen gør arbejdsområdet flydende, hvor vinduer overlapper frit, og du placerer dem selv, og et tredje tryk fører det tilbage til dwindle. `Super + Alt + L` går gennem dem den anden vej. Et vindue, der alligevel flyder — et, du har poppet ud med `Super + T`, eller en app, der altid åbner flydende — bliver ved med at flyde, når arbejdsområdet går tilbage til tiling. Den øverste bjælke markerer det arbejdsområde, du er på, med dets layout: en firkant for dwindle, en cirkel for rullelayout og en trekant for flydende. Et klik på det mærke bladrer også layoutet.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget gælder pr. arbejdsområde, og det bliver hængende. Så du kan beholde arbejdsområde 1 på dwindle til browsing og arbejdsområde 2 på rullelayout til kode, og de vil komme tilbage på den måde efter en genstart.

Hvis du ønsker at bruge rullelayoutet som standard, kan du indstille det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flydende arbejdsområder

Et flydende arbejdsområde fungerer som et traditionelt skrivebord: vinduer overlapper, og du flytter og tilpasser størrelsen på dem selv. Hvert vindue får en titellinje i dit temas farver med knapper til at minimere, maksimere og lukke. `Super + M` minimerer også det fokuserede vindue. Et minimeret vindue venter i docken; klik på dets app for at bringe det tilbage. Klik på et vindue for at bringe det forrest. Tilpas størrelsen fra en hvilken som helst kant eller et hvilket som helst hjørne. Dobbeltklik på en titellinje for at maksimere vinduet, mens den øverste bjælke stadig kan ses, og igen for at få dets gamle størrelse tilbage. Chrome og andre Chromium-baserede browsere, Disks og Document Viewer springer titellinjen over og bruger i stedet deres egen header; `Super + Alt + F` maksimerer dem, og `Super + M` minimerer dem.

Et flydende arbejdsområde viser også en dock med dine fastgjorte apps, alt det, der kører, og et gitter med alle apps bag apps-knappen, som `Super + Alt + Space` og _Apps_ i Omarchy-menuen også åbner. Højreklik på en app på gitteret, eller tryk på `Delete`, for at afinstallere den. Klik på en app for at åbne den eller for at bringe dens vindue forrest; klik igen for at bladre gennem dens vinduer. Midterklik åbner et nyt vindue. Træk et ikon langs docken for at flytte det; at trække en kørende app ind blandt de andre beholder den der. Højreklik for at beholde en app i docken, fjerne den eller afslutte den. Docken går af vejen for et fuldskærmsvindue. Højreklik på apps-knappen for at flytte docken til en anden kant eller få den til at skjule sig, indtil markøren når dens kant. Positionen findes også under _Appearance > Dock > Dock Position_, og `omarchy dock position left` og `omarchy dock autohide on` indstiller begge fra en terminal. Apps, du beholder i docken, er nedtonede, mens de ikke kører.

Nye arbejdsområder, og alle dem, du ikke har givet deres eget layout med `Super + L`, bruger standardlayoutet. Ændring af standarden nulstiller ethvert arbejdsområde uden vinduer til den, mens et med vinduer på beholder det layout, det har. Et vindue minimeret til docken tæller stadig som et vindue på det arbejdsområde, det forlod. Vælg det under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy-hyprland-workspace-layout-default scrolling` indstiller det fra en terminal.

### Gruppering af vinduer

Vinduer kan grupperes ved hjælp af `Super + G`. Når du først er i en gruppe, vil ethvert vindue, du starter, mens den er aktiv, tilhøre gruppen. Du kan bevæge dig mellem disse grupperede vinduer ved hjælp af `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for at gå direkte til grupperede vinduer i rækkefølge.

Du kan flytte et vindue ud af grupperingen med `Super + Alt + G` eller skille hele gruppen ad ved at trykke på `Super + G` igen. Endelig kan du flytte vinduer uden for gruppen ind i den med `Super + Alt + Arrows`.

### At poppe vinduer ud

Du kan poppe et vindue ud af dets arbejdsområdetildeling med `Super + O`. Det fastgør det som et flydende vindue, der følger dig, uanset hvilket arbejdsområde du går til. Fantastisk til videoafspillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbejdsområde

Der er et særligt scratchpad-arbejdsområde i fuld størrelse, der lægger sig oven på det arbejdsområde, du aktuelt er på. Du får adgang til det, der er på det, ved hjælp af `Super + S`, og du placerer vinduer der ved hjælp af `Super + Alt + S`.

Det fungerer godt til kontroller eller en terminal, du hurtigt vil interagere med uden at forlade det aktuelle arbejdsområde.

### Quake-konsol

Endelig er der en Quake-konsol i halv højde, der falder ned over det arbejdsområde, du aktuelt er på. Slå den til eller fra med `Super + Grave`, og placer et vindue der ved hjælp af `Super + Shift + Grave`.

Den åbner med din standardagent klar til at gå i gang. Mens konsollen kun indeholder et enkelt vindue, falder den ned som et centreret panel i stedet for at spænde over skærmen. Sæt en anden app på den, og den går tilbage til fuld bredde, så de to har plads til at sidde side om side.

For at flytte et vindue væk fra enten scratchpad eller konsollen skal du sende det direkte til et andet arbejdsområde med noget i retning af `Super + Shift + 1`.

### Det kræver lidt tilvænning!

Det tager lidt tid at vænne sig til at navigere på dit skrivebord på denne måde, men når du først gør det, bliver det svært at gå tilbage til en traditionel musdrevet skrivebordsoplevelse!
