# Navigering

Allt i Omarchy sker via tangentbordet — _ALLT!_ När systemet startar för första gången kan du bokstavligen inte göra någonting med bara musen. Men du kan trycka på `Super + Space` för att visa Omarchy Menu, och härifrån kan du göra i stort sett allt.

Men Omarchy-menyn är inte ens tänkt att vara det huvudsakliga sättet att använda systemet för det mesta. Vi kan göra det snabbare än så! Alla de viktigaste programmen är bundna direkt till enskilda snabbtangenter. Du startar terminalen med `Super + Return` och en webbläsare med `Super + Shift + Return`. Prova att göra det ena efter det andra, så får du se Hyprlands tiling-magi i aktion:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan sedan trycka på `Super + J` för att stapla dem ovanpå varandra i stället för sida vid sida:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryck på `Super + J` igen för att återställa dem till positionerna sida vid sida. Prova sedan `Super + Shift + Arrow Right` medan du är i webbläsaren för att byta plats på fönstren.

Prova nu `Super + Shift + T` för att starta aktivitetsövervakaren. Den visas som ett flytande fönster. Du kan lägga den i tiling med `Super + T` (och trycka på det igen för att göra den flytande igen). Tryck nu på `Super + Shift + F` för att öppna filhanteraren. Du får en snygg fyrvägsuppställning:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerar mellan det fönster du vill ska vara aktivt med `Super + Arrow`. Det flyttar fokus och flyttar markören till mitten av det nya programmet. Vid kanten av en skärm fortsätter det till bildskärmen på den sidan.

Om du trycker på `Super + Shift + 2` flyttar du det aktuella fokuserade programmet till den andra arbetsytan. `Super + Shift + 1` flyttar tillbaka det. (Och `Super + Shift + Alt + 2` flyttar det aktuella fokuserade programmet till den andra arbetsytan utan att växla till den).

Med mer än en bildskärm har varje bildskärm sina egna arbetsytor 1 till 10. `Super + 2` går till den andra arbetsytan på den bildskärm du befinner dig på, och varje bildskärms översta fält visar dess egna arbetsytor och den som den visar. `Super + Tab` cyklar genom arbetsytorna på den bildskärm du befinner dig på. `Super + Shift + Ctrl + Arrows` flyttar fönstret du befinner dig på till bildskärmen i den riktningen, till den arbetsyta den visar, och `Super + Shift + Alt + Arrows` flyttar arbetsytan du befinner dig på till bildskärmen i den riktningen, där den tar samma nummer om det är ledigt. En bildskärm behåller sina arbetsytor när du kopplar ur den: de ansluter till en annan skärms, numrerade efter dem den redan har, och går tillbaka till sina gamla nummer när bildskärmen återvänder.

Om du håller ned `Super` och använder musen för att klicka på ett fönster kan du ordna om var det sitter. Om du håller ned `Super` och använder höger musknapp kan du ändra storlek på fönstret fritt.

Du stänger ett fönster med `Super + W` eller `Super + Q` (och stänger alla fönster med `Ctrl + Alt + Delete`).

Du kan också gå till helskärm med `Super + F` eller till och med bara till full bredd (med det övre fältet kvar) med `Super + Alt + F` eller helskärm i ett fönster med `Super + Ctrl + F` (bra för YouTube!).

### Dwindle kontra rullande layout

Omarchys standardlayout kallas dwindle. Den håller alla fönster du öppnar på en enskild arbetsyta synliga hela tiden, även om den måste krympa dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan också välja att förvandla en arbetsyta till den rullande layouten där fönster radas upp sida vid sida, bortom skärmens synliga kant. Du förvandlar en enskild arbetsyta till den här layouten via `Super + L`.

Att trycka på `Super + L` igen gör arbetsytan flytande, där fönster överlappar fritt och du placerar dem själv, och ett tredje tryck återställer den till dwindle. `Super + Alt + L` går igenom dem åt andra hållet. Ett fönster som flyter ändå — ett som du har lyft ut med `Super + T`, eller en app som alltid öppnas flytande — fortsätter att flyta när arbetsytan går tillbaka till tiling. Det övre fältet markerar arbetsytan du befinner dig på med dess layout: en fyrkant för dwindle, en cirkel för rullande och en triangel för flytande. Att klicka på det märket cyklar också layouten, och det gör även displaytangenten på bärbara datorer som har en sådan.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valet gäller per arbetsyta, och det sitter kvar. Så du kan behålla arbetsyta 1 på dwindle för surfning och arbetsyta 2 på rullande för kod, och de kommer tillbaka på det sättet efter en omstart.

Om du vill använda den rullande layouten som standard kan du ställa in det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytande arbetsytor

En flytande arbetsyta fungerar som ett traditionellt skrivbord: fönster överlappar, och du flyttar och ändrar storlek på dem själv. Varje fönster får en titelrad i ditt temas färger, med knappar för att minimera, maximera och stänga. `Super + M` minimerar också det fokuserade fönstret. Ett minimerat fönster väntar i dockan; klicka på dess app för att ta tillbaka det. Klicka på ett fönster för att föra det framåt. Ändra storlek på det från valfri kant eller valfritt hörn. Dubbelklicka på en titelrad för att maximera fönstret samtidigt som det övre fältet hålls i sikte, och igen för att få tillbaka dess gamla storlek. Chrome och andra Chromium-baserade webbläsare, Disks och Document Viewer hoppar över titelraden och använder sin egen sidhuvudrad i stället; `Super + Alt + F` maximerar dem, och `Super + M` minimerar dem.

En flytande arbetsyta visar också en docka, med dina fästa appar, allt som körs, och ett rutnät med varje app bakom appar-knappen, som `Super + Alt + Space` och _Apps_ i Omarchy-menyn också öppnar. Högerklicka på en app i rutnätet, eller tryck på `Delete`, för att avinstallera den. Klicka på en app för att öppna den, eller för att föra dess fönster framåt; klicka igen för att cykla genom dess fönster. Files tar bara tillbaka ett fönster från den arbetsyta du befinner dig på och öppnar annars ett nytt, och Terminal och Agent startar alltid ett till, fast ett minimerat fönster kommer tillbaka först. Mellanklick öppnar ett nytt fönster. Dra en ikon längs dockan för att flytta den; att dra en körande app in bland de andra behåller den där. Högerklicka för att behålla en app i dockan, ta bort den därifrån eller avsluta den. Dockan flyttar sig ur vägen för ett helskärmsfönster. Högerklicka på appar-knappen för att flytta dockan till en annan kant eller låta den gömma sig tills pekaren når dess kant. Positionen finns också under _Appearance > Dock > Dock Position_, och `omarchy dock position left` och `omarchy dock autohide on` ställer in båda från en terminal. Appar du behåller i dockan är tonade medan de inte körs.

Nya arbetsytor, och alla som du inte har gett en egen layout med `Super + L`, använder standardlayouten. Att ändra standarden återställer varje arbetsyta utan fönster till den, medan en med fönster på behåller layouten den har. Ett fönster som minimerats till dockan räknas fortfarande som ett fönster på den arbetsyta det lämnade. Välj den under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy hyprland workspace layout default scrolling` ställer in den från en terminal.

### Gruppera fönster

Fönster kan grupperas med `Super + G`. När du väl är i en grupp kommer varje fönster du startar medan den är aktiv att tillhöra gruppen. Du kan flytta mellan dessa grupperade fönster med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` för att gå direkt till grupperade fönster i ordning.

Du kan flytta ett fönster ur grupperingen med `Super + Alt + G` eller demontera hela gruppen genom att trycka på `Super + G` igen. Slutligen kan du flytta fönster utanför gruppen in i den med `Super + Alt + Arrows`.

### Lyfta ut fönster

Du kan lyfta ut ett fönster ur dess arbetsytetilldelning med `Super + O`. Det fäster det som ett flytande fönster som följer med dig till vilken arbetsyta du än går till. Perfekt för videospelare och liknande.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbetsyta

Det finns en särskild scratchpad-arbetsyta i full storlek som lägger sig över vilken arbetsyta du än befinner dig på för tillfället. Du kommer åt det som finns på den med `Super + S`, och du placerar fönster där med `Super + Alt + S`.

Den fungerar bra för kontroller eller en terminal som du vill interagera med snabbt utan att lämna den aktuella arbetsytan.

### Quake-konsol

Slutligen finns det en Quake-konsol på halv höjd som fälls ned över vilken arbetsyta du än befinner dig på för tillfället. Växla den med `Super + Grave`, och placera ett fönster där med `Super + Shift + Grave`.

Första gången den öppnas startar den din standardagent, eller ber dig välja en om du inte har valt en ännu. Medan konsolen innehåller ett enda fönster fälls den ned som en centrerad panel i stället för att spänna över skärmen. Sätt en andra app på den och den går tillbaka till full bredd, så att de två får plats att sitta sida vid sida.

För att flytta ett fönster från vare sig scratchpaden eller konsolen skickar du det direkt till en annan arbetsyta med något som `Super + Shift + 1`.

### Det kräver lite tillvänjning!

Det tar ett tag att vänja sig vid att navigera på skrivbordet så här, men när du väl gör det blir det svårt att gå tillbaka till en traditionell musdriven skrivbordsupplevelse!
