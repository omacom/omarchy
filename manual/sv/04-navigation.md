# Navigering

Allt i Omarchy sker via tangentbordet — _ALLT!_ När systemet först startar kan du bokstavligen inte göra någonting med enbart musen. Men du kan trycka på `Super + Space` för att visa Omarchy-menyn, och härifrån kan du göra i stort sett allt.

Men Omarchy-menyn är inte ens tänkt att vara det huvudsakliga sättet att använda systemet för det mesta. Vi kan bli snabbare än så! Alla de viktigaste applikationerna är bundna direkt till enskilda snabbtangenter. Du startar terminalen med `Super + Return` och en webbläsare med `Super + Shift + Return`. Prova att göra det ena efter det andra, så får du se Hyprlands tiling-magi i praktiken:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan sedan trycka på `Super + J` för att stapla dem ovanpå varandra i stället för sida vid sida:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryck på `Super + J` igen för att flytta tillbaka dem till positionerna sida vid sida. Prova sedan `Super + Shift + Arrow Right` medan webbläsaren är aktiv för att byta plats på fönstren.

Prova nu `Super + Ctrl + T` för att starta Aktivitetsmonitorn. Den visas som ett flytande fönster. Du kan lägga den i tiling-läge med `Super + T` (och trycka på det igen för att göra den flytande igen). Tryck nu på `Super + Shift + F` för att öppna filhanteraren. Då får du en snygg fyrdelad uppställning:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerar mellan fönstren för att välja vilket som ska vara aktivt med `Super + Arrow`. Det växlar fokus och flyttar markören till mitten av den nya applikationen.

Om du trycker på `Super + Shift + 2` flyttar du den applikation som för tillfället har fokus till den andra arbetsytan. `Super + Shift + 1` flyttar tillbaka den. (Och `Super + Shift + Alt + 2` flyttar den applikation som för tillfället har fokus till den andra arbetsytan utan att växla till den).

Om du håller nere `Super` och klickar på ett fönster med musen kan du ändra var det sitter. Om du håller nere `Super` och använder höger musknapp kan du fritt ändra storlek på fönstret.

Du stänger ett fönster med `Super + W` eller `Super + Q` (och stänger alla fönster med `Ctrl + Alt + Delete`).

Du kan också gå till helskärm med `Super + F`, eller bara till full bredd (med den övre raden kvar) med `Super + Alt + F`, eller helskärm inuti ett fönster med `Super + Ctrl + F` (bra för YouTube!).

### Dwindle vs. scrollande layout

Omarchys standardlayout heter dwindle. Den håller alla fönster du öppnar på en enda arbetsyta synliga hela tiden, även om den måste krympa dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan också välja att göra en arbetsyta till den scrollande layouten, där fönstren radas upp sida vid sida bortom skärmens synliga kant. Du gör en enskild arbetsyta till den här layouten med `Super + L`.

Att trycka på `Super + L` igen gör arbetsytan flytande, där fönstren överlappar varandra fritt och du placerar dem själv, och ett tredje tryck återställer den till dwindle. `Super + Alt + L` går igenom dem åt andra hållet. Ett fönster som ändå flyter — ett som du poppade ut med `Super + T`, eller en app som alltid öppnas flytande — fortsätter att flyta när arbetsytan går tillbaka till tiling. Den övre raden markerar arbetsytan du befinner dig på med dess layout: en kvadrat för dwindle, en cirkel för scrolling och en triangel för flytande. Att klicka på den markeringen växlar också igenom layouterna.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valet görs per arbetsyta, och det sitter kvar. Så du kan behålla arbetsyta 1 på dwindle för webbläsning och arbetsyta 2 på scrolling för kod, och de kommer tillbaka så efter en omstart.

Om du vill använda den scrollande layouten som standard kan du ställa in det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytande arbetsytor

En flytande arbetsyta fungerar som ett traditionellt skrivbord: fönstren överlappar varandra, och du flyttar och storleksändrar dem själv. Varje fönster får en titelrad i ditt temas färger, med knappar för att minimera, maximera och stänga. `Super + M` minimerar också det fokuserade fönstret. Ett minimerat fönster väntar i dockan; klicka på dess app för att ta tillbaka det. Klicka på ett fönster för att ta fram det. Ändra storlek på det från valfri kant eller valfritt hörn. Dubbelklicka på en titelrad för att maximera fönstret samtidigt som den övre raden fortfarande syns, och dubbelklicka igen för att få tillbaka dess gamla storlek.

En flytande arbetsyta visar också en docka, med dina fästa appar, allt som körs, och ett rutnät med alla appar bakom appknappen, som `Super + Alt + Space` och _Appar_ i Omarchy-menyn också öppnar. Högerklicka på en app i rutnätet, eller tryck på `Delete`, för att avinstallera den. Klicka på en app för att öppna den, eller för att ta fram dess fönster; klicka igen för att växla igenom dess fönster. Ett klick med mittenknappen öppnar ett nytt fönster. Dra en ikon längs dockan för att flytta den; om du drar en app som körs in bland de andra behålls den där. Högerklicka för att behålla en app i dockan, ta bort den därifrån eller avsluta den. Dockan flyttar sig ur vägen för ett helskärmsfönster. Högerklicka på appknappen för att flytta dockan till en annan kant eller låta den dölja sig tills pekaren når dess kant. Positionen finns också under _Trigger > Utseende > Dock > Dockposition_, och `omarchy dock position left` och `omarchy dock autohide on` ställer in båda från en terminal. Appar du behåller i dockan är nedtonade medan de inte körs.

Nya arbetsytor, och alla som du inte har gett en egen layout med `Super + L`, använder standardlayouten. Att ändra standardlayouten återställer varje arbetsyta utan fönster till den, medan en arbetsyta med fönster på behåller layouten den har. Ett fönster som minimerats till dockan räknas fortfarande som ett fönster på arbetsytan det lämnade. Välj den under _Trigger > Utseende > Arbetsytelayout_: Tiling, Scrolling eller Flytande. `omarchy-hyprland-workspace-layout-default scrolling` ställer in den från en terminal.

### Gruppera fönster

Fönster kan grupperas med `Super + G`. När du väl är i en grupp tillhör varje fönster du startar medan den är aktiv gruppen. Du kan flytta mellan dessa grupperade fönster med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` för att gå direkt till ett grupperat fönster i ordning.

Du kan flytta ett fönster ut ur grupperingen med `Super + Alt + G` eller lösa upp hela gruppen genom att trycka på `Super + G` igen. Slutligen kan du flytta fönster utanför gruppen in i den med `Super + Alt + Arrows`.

### Poppa ut fönster

Du kan poppa ut ett fönster ur dess tilldelning på arbetsytan med `Super + O`. Det fäster det som ett flytande fönster som följer med dig till vilken arbetsyta du än går till. Perfekt för videospelare och liknande.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbetsyta

Slutligen finns det en speciell scratchpad-arbetsyta som fälls ner över den arbetsyta du för tillfället befinner dig på, ungefär som en Quake-konsol. Växla den med `Super + Grave` eller `Super + S`, och placera ett fönster där med `Super + Shift + Grave` eller `Super + Alt + S`.

Den fungerar särskilt bra för en terminal som kör en agent, eller för kontroller du vill interagera med snabbt utan att lämna den aktuella arbetsytan. För att flytta ett fönster från scratchpaden skickar du det direkt till en annan arbetsyta med något som `Super + Shift + 1`.

Medan scratchpaden bara innehåller ett enda fönster fälls den ner som en centrerad panel i stället för att spänna över skärmen. Lägg en andra app på den, så går den tillbaka till full bredd, så att de två får plats att sitta sida vid sida.

### Det tar ett tag att vänja sig!

Det tar ett tag att vänja sig vid att navigera på skrivbordet så här, men när du väl har gjort det blir det svårt att gå tillbaka till en traditionell musstyrd skrivbordsupplevelse!
