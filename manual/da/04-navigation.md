# Navigation

Alt i Omarchy foregår via tastaturet — _ALT!_ Når systemet starter første gang, kan du bogstaveligt talt ikke gøre noget med musen alene. Men du kan trykke på `Super + Space` for at åbne Omarchy-menuen, og herfra kan du gøre stort set alt.

Men Omarchy-menuen er ikke engang tænkt som den primære måde at betjene systemet på det meste af tiden. Vi kan gøre det hurtigere end det! Alle de vigtigste programmer er bundet direkte til individuelle genvejstaster. Du starter terminalen med `Super + Return` og en browser med `Super + Shift + Return`. Prøv at gøre det ene efter det andet, og du vil se magien ved Hyprland's tiling i aktion:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan derefter trykke på `Super + J` for at stable dem oven på hinanden i stedet for side om side:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryk på `Super + J` igen for at vende dem tilbage til deres side-om-side-positioner. Prøv derefter `Super + Shift + Arrow Right`, mens du er i browseren, for at bytte vinduerne.

Prøv nu `Super + Shift + T` for at starte Activity-monitoren. Den vises som et flydende vindue. Du kan tile den med `Super + T` (og trykke på det igen for at gøre den flydende igen). Tryk nu på `Super + Shift + F` for at åbne filhåndteringen. Du får en pæn opsætning med fire vinduer:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerer mellem det vindue, du vil have aktivt, med `Super + Arrow`. Det skifter fokus og flytter markøren til midten af det nye program. Ved kanten af en skærm fortsætter det til skærmen på den side.

Hvis du trykker på `Super + Shift + 2`, flytter du det aktuelt fokuserede program til det andet arbejdsområde. `Super + Shift + 1` flytter det tilbage. (Og `Super + Shift + Alt + 2` flytter det aktuelt fokuserede program til det andet arbejdsområde uden at skifte til det).

Med mere end én skærm har hver skærm sine egne arbejdsområder 1 til 10. `Super + 2` går til det andet arbejdsområde på den skærm, du er på, og hver skærms øverste bjælke viser sine egne arbejdsområder og det, den viser. `Super + Tab` skifter mellem arbejdsområderne på den skærm, du er på. `Super + Shift + Ctrl + Arrows` flytter det vindue, du er på, til skærmen i den retning, til det arbejdsområde, den viser, og `Super + Shift + Alt + Arrows` flytter det arbejdsområde, du er på, over til skærmen i den retning, hvor det får samme nummer, hvis det er ledigt. En skærm beholder sine arbejdsområder, når du frakobler den: de slutter sig til en anden skærms, nummereret efter dem, den allerede har, og går tilbage under deres gamle numre, når skærmen vender tilbage.

Hvis du holder `Super` nede og bruger musen til at klikke på et vindue, kan du omarrangere, hvor det sidder. Hvis du holder `Super` nede og bruger højre museknap, kan du frit ændre vinduets størrelse.

Du lukker et vindue med `Super + W` eller `Super + Q` (og lukker alle vinduer med `Ctrl + Alt + Delete`).

Du kan også gå i fuldskærm med `Super + F` eller endda bare fuld bredde (med den øverste bjælke bevaret) med `Super + Alt + F` eller fuldskærm i et vindue med `Super + Ctrl + F` (godt til YouTube!).

### Dwindle vs. rullelayout

Omarchy's standardlayout kaldes dwindle. Det holder alle de vinduer, du åbner på et enkelt arbejdsområde, synlige hele tiden, selv hvis det skal krympe dem ned.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan også vælge at lave et arbejdsområde om til rullelayoutet, hvor vinduer stilles op side om side, ud over skærmens synlige kant. Du laver et enkelt arbejdsområde om til dette layout via `Super + L`.

Hvis du trykker på `Super + L` igen, bliver arbejdsområdet flydende, hvor vinduer overlapper frit, og du placerer dem selv, og et tredje tryk vender det tilbage til dwindle. `Super + Alt + L` går igennem dem den anden vej. Et vindue, der flyder alligevel — et, du poppede ud med `Super + T`, eller en app, der altid åbner flydende — forbliver flydende, når arbejdsområdet går tilbage til tiling. Den øverste bjælke markerer det arbejdsområde, du er på, med dets layout: en firkant for dwindle, en cirkel for scrolling og en trekant for floating. Et klik på det mærke skifter også layoutet.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valget er per arbejdsområde, og det bevares. Så du kan beholde arbejdsområde 1 på dwindle til browsing og arbejdsområde 2 på scrolling til kode, og de kommer tilbage på den måde efter en genstart.

Hvis du ønsker at bruge rullelayoutet som standard, kan du indstille det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flydende arbejdsområder

Et flydende arbejdsområde fungerer som et traditionelt skrivebord: vinduer overlapper, og du flytter og tilpasser dem selv. Hvert vindue får en titellinje i dit temas farver med knapper til at minimere, maksimere og lukke. `Super + M` minimerer også det fokuserede vindue. Et minimeret vindue venter i docken; klik på dets app for at hente det tilbage. Klik på et vindue for at bringe det frem. Ændr størrelsen fra enhver kant eller hjørne. Dobbeltklik på en titellinje for at maksimere vinduet, mens den øverste bjælke stadig er i syne, og igen for at få dets gamle størrelse tilbage.

Et flydende arbejdsområde viser også en dock med dine fastgjorte apps, alt, hvad der kører, og et gitter med alle apps bag apps-knappen, som `Super + Alt + Space` og _Apps_ i Omarchy-menuen også åbner. Højreklik på en app på gitteret, eller tryk på `Delete`, for at afinstallere den. Klik på en app for at åbne den eller for at bringe dens vindue frem; klik igen for at skifte mellem dens vinduer. Mellemklik åbner et nyt vindue. Træk et ikon langs docken for at flytte det; at trække en kørende app ind blandt de andre beholder den der. Højreklik for at beholde en app i docken, tage den ud eller afslutte den. Docken går af vejen for et fuldskærmsvindue. Højreklik på apps-knappen for at flytte docken til en anden kant eller få den til at skjule sig, indtil markøren når dens kant. Positionen findes også under _Appearance > Dock > Dock Position_, og `omarchy dock position left` og `omarchy dock autohide on` indstiller begge dele fra en terminal. Apps, du beholder i docken, er falmede, mens de ikke kører.

Nye arbejdsområder, og alle, du ikke har givet et eget layout med `Super + L`, bruger standardlayoutet. Ændring af standarden nulstiller ethvert arbejdsområde uden vinduer til det, mens et med vinduer på beholder det layout, det har. Et vindue, der er minimeret til docken, tæller stadig som et vindue på det arbejdsområde, det forlod. Vælg det under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy-hyprland-workspace-layout-default scrolling` indstiller det fra en terminal.

### Gruppering af vinduer

Vinduer kan grupperes med `Super + G`. Når du er i en gruppe, tilhører ethvert vindue, du starter, mens den er aktiv, gruppen. Du kan flytte mellem disse grupperede vinduer med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` for at gå direkte til grupperede vinduer i rækkefølge.

Du kan flytte et vindue ud af grupperingen med `Super + Alt + G` eller opløse hele gruppen ved at trykke på `Super + G` igen. Endelig kan du flytte vinduer uden for gruppen ind i den med `Super + Alt + Arrows`.

### At poppe vinduer ud

Du kan poppe et vindue ud af dets arbejdsområdetildeling med `Super + O`. Det fastholder det som et flydende vindue, der følger dig på ethvert arbejdsområde, du går til. Fantastisk til videoafspillere og lignende.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbejdsområde

Der er et særligt scratchpad-arbejdsområde i fuld størrelse, der lægger sig over ethvert arbejdsområde, du aktuelt er på. Du får adgang til, hvad der er på det, med `Super + S`, og du placerer vinduer der med `Super + Alt + S`.

Det fungerer godt til kontroller eller en terminal, du vil interagere med hurtigt uden at forlade det aktuelle arbejdsområde.

### Quake-konsol

Endelig er der en Quake-konsol i halv højde, der falder ned over ethvert arbejdsområde, du aktuelt er på. Slå den til og fra med `Super + Grave`, og placer et vindue der med `Super + Shift + Grave`.

Den åbner med din standardagent klar til at gå. Mens konsollen indeholder et enkelt vindue, falder den ned som et centreret panel i stedet for at spænde over skærmen. Sæt en anden app på den, og den går tilbage til fuld bredde, så de to har plads til at sidde side om side.

For at flytte et vindue væk fra enten scratchpadden eller konsollen skal du sende det direkte til et andet arbejdsområde med noget som `Super + Shift + 1`.

### Det kræver lidt tilvænning!

Det tager lidt tid at vænne sig til at navigere på sit skrivebord på denne måde, men når du gør det, bliver det svært at gå tilbage til en traditionel musestyret skrivebordsoplevelse!
