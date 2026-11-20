# Navigering

Allt i Omarchy sker via tangentbordet — _ALLT!_ När systemet startar för första gången kan du bokstavligen inte göra ett dugg med bara musen. Men du kan trycka på `Super + Space` för att få fram Omarchy Menu, och härifrån kan du göra i stort sett allt.

Men Omarchy-menyn är inte ens avsedd att vara det huvudsakliga sättet att styra systemet för det mesta. Vi kan bli snabbare än så! Alla de viktigaste programmen är knutna direkt till egna snabbtangenter. Du startar terminalen med `Super + Return` och en webbläsare med `Super + Shift + Return`. Prova att göra det ena efter det andra, så får du se magin med Hyprlands tiling i praktiken:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Sedan kan du trycka på `Super + J` för att stapla dem ovanpå varandra i stället för sida vid sida:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryck på `Super + J` igen för att återställa dem till positionerna sida vid sida. Prova sedan `Super + Shift + Arrow Right` medan du är i webbläsaren för att byta plats på fönstren.

Prova nu `Super + Shift + T` för att starta Activity monitor. Den visas som ett flytande fönster. Du kan lägga den i tiling med `Super + T` (och trycka på det igen för att göra den flytande igen). Tryck nu på `Super + Shift + F` för att öppna filhanteraren. Du får en snygg fyrvägsuppställning:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerar mellan det fönster du vill ska vara aktivt med `Super + Arrow`. Det växlar fokus och flyttar markören till mitten av det nya programmet. Vid kanten av en skärm fortsätter den till bildskärmen på den sidan.

Om du trycker på `Super + Shift + 2` flyttar du det program som för närvarande har fokus till den andra arbetsytan. `Super + Shift + 1` flyttar tillbaka det. (Och `Super + Shift + Alt + 2` flyttar det program som för närvarande har fokus till den andra arbetsytan utan att växla till den).

Med mer än en bildskärm har varje bildskärm sina egna arbetsytor 1 till 10. `Super + 2` går till den andra arbetsytan på den bildskärm du befinner dig på, och varje bildskärms översta fält visar sina egna arbetsytor och den som den visar. `Super + Tab` växlar mellan arbetsytorna på den bildskärm du befinner dig på. `Super + Shift + Ctrl + Arrows` flyttar fönstret du befinner dig på till bildskärmen i den riktningen, till den arbetsyta som den visar, och `Super + Shift + Alt + Arrows` flyttar arbetsytan du befinner dig på till bildskärmen i den riktningen, där den får samma nummer om det är ledigt. En bildskärm behåller sina arbetsytor när du kopplar ur den: de ansluter till en annan skärms arbetsytor, numrerade efter de som den redan har, och går tillbaka till sina gamla nummer när bildskärmen kommer tillbaka.

Om du håller ned `Super` och använder musen för att klicka på ett fönster kan du ordna om var det sitter. Om du håller ned `Super` och använder höger musknapp kan du fritt ändra storlek på fönstret.

Du stänger ett fönster med `Super + W` eller `Super + Q` (och stänger alla fönster med `Ctrl + Alt + Delete`).

Du kan också gå till helskärm med `Super + F` eller till och med bara full bredd (med det översta fältet kvar) med `Super + Alt + F`, eller helskärm i ett fönster med `Super + Ctrl + F` (bra för YouTube!).

### Dwindle jämfört med scrolling-layout

Omarchys standardlayout kallas dwindle. Den håller alla fönster du öppnar på en enda arbetsyta synliga hela tiden, även om den måste krympa dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan också välja att göra en arbetsyta till scrolling-layouten där fönster radas upp sida vid sida, bortom skärmens synliga kant. Du gör en enskild arbetsyta till den här layouten via `Super + L`.

Om du trycker på `Super + L` igen blir arbetsytan flytande, där fönster överlappar fritt och du placerar dem själv, och ett tredje tryck återställer den till dwindle. `Super + Alt + L` går igenom dem åt andra hållet. Ett fönster som ändå flyter — ett som du har plockat ut med `Super + T`, eller en app som alltid öppnas flytande — fortsätter att flyta när arbetsytan går tillbaka till tiling. Det översta fältet markerar den arbetsyta du befinner dig på med dess layout: en fyrkant för dwindle, en cirkel för scrolling och en triangel för flytande. Att klicka på den markeringen växlar också layouten.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valet gäller per arbetsyta, och det består. Så du kan behålla arbetsyta 1 på dwindle för surfning och arbetsyta 2 på scrolling för kod, och de kommer tillbaka på det viset efter en omstart.

Om du vill använda scrolling-layouten som standard kan du ställa in det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytande arbetsytor

En flytande arbetsyta fungerar som ett traditionellt skrivbord: fönster överlappar, och du flyttar och storleksändrar dem själv. Varje fönster får en titelrad i ditt temas färger, med knappar för att minimera, maximera och stänga. `Super + M` minimerar också det fokuserade fönstret. Ett minimerat fönster väntar i dockan; klicka på dess app för att ta tillbaka det. Klicka på ett fönster för att lyfta fram det. Ändra storlek på det från valfri kant eller valfritt hörn. Dubbelklicka på en titelrad för att maximera fönstret samtidigt som det översta fältet förblir synligt, och igen för att få tillbaka dess gamla storlek. Chrome och andra Chromium-baserade webbläsare, Disks och Document Viewer hoppar över titelraden och använder sin egen sidhuvudsrad i stället; `Super + Alt + F` maximerar dem, och `Super + M` minimerar dem.

En flytande arbetsyta visar också en docka, med dina fästa appar, allt som körs, och ett rutnät med alla appar bakom appar-knappen, som `Super + Alt + Space` och _Apps_ i Omarchy-menyn också öppnar. Högerklicka på en app i rutnätet, eller tryck på `Delete`, för att avinstallera den. Klicka på en app för att öppna den, eller för att lyfta fram dess fönster; klicka igen för att växla mellan dess fönster. Files tar bara tillbaka ett fönster från den arbetsyta du befinner dig på och öppnar annars ett nytt, och Terminal och Agent startar alltid ytterligare ett, även om ett minimerat fönster kommer tillbaka först. Mellanklicka för att öppna ett nytt fönster. Dra en ikon längs dockan för att flytta den; att dra en app som körs in bland de andra behåller den där. Högerklicka för att behålla en app i dockan, ta bort den eller avsluta den. Dockan flyttar sig ur vägen för ett helskärmsfönster. Högerklicka på appar-knappen för att flytta dockan till en annan kant eller låta den dölja sig tills pekaren når dess kant. Positionen finns också under _Appearance > Dock > Dock Position_, och `omarchy dock position left` och `omarchy dock autohide on` ställer in båda från en terminal. Appar som du behåller i dockan är nedtonade medan de inte körs.

Nya arbetsytor, och alla som du inte har gett en egen layout med `Super + L`, använder standardlayouten. Att ändra standarden återställer varje arbetsyta utan fönster till den, medan en med fönster på sig behåller den layout den har. Ett fönster som minimerats till dockan räknas fortfarande som ett fönster på den arbetsyta det lämnade. Välj den under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy-hyprland-workspace-layout-default scrolling` ställer in den från en terminal.

### Gruppera fönster

Fönster kan grupperas med `Super + G`. När du väl är i en grupp kommer varje fönster du startar medan den är aktiv att tillhöra gruppen. Du kan flytta mellan dessa grupperade fönster med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` för att gå direkt till grupperade fönster i ordning.

Du kan flytta ett fönster ut ur grupperingen med `Super + Alt + G` eller montera isär hela gruppen genom att trycka på `Super + G` igen. Slutligen kan du flytta fönster utanför gruppen in i den med `Super + Alt + Arrows`.

### Plocka ut fönster

Du kan plocka ut ett fönster ur dess arbetsytetilldelning med `Super + O`. Det fäster det som ett flytande fönster som följer med dig till vilken arbetsyta du än går till. Perfekt för videospelare och liknande.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbetsyta

Det finns en särskild scratchpad-arbetsyta i full storlek som lägger sig över den arbetsyta du för närvarande befinner dig på. Du kommer åt det som finns på den med `Super + S`, och du placerar fönster där med `Super + Alt + S`.

Den fungerar bra för kontroller eller en terminal som du vill interagera med snabbt utan att lämna den aktuella arbetsytan.

### Quake-konsol

Slutligen finns det en Quake-konsol på halv höjd som fälls ned över den arbetsyta du för närvarande befinner dig på. Växla den med `Super + Grave`, och placera ett fönster där med `Super + Shift + Grave`.

Den öppnas med din standardagent redo att köra. Medan konsolen innehåller ett enda fönster fälls den ned som en centrerad panel i stället för att spänna över skärmen. Lägg en andra app på den och den går tillbaka till full bredd, så att de två får plats sida vid sida.

För att flytta ett fönster från antingen scratchpad eller konsolen, skicka det direkt till en annan arbetsyta med något som `Super + Shift + 1`.

### Det tar ett tag att vänja sig!

Det tar lite tid att vänja sig vid att navigera på skrivbordet så här, men när du väl gör det blir det svårt att gå tillbaka till en traditionell musdriven skrivbordsupplevelse!
