# Navigering

Allt i Omarchy sker via tangentbordet — _ALLT!_ När systemet startar första gången kan du bokstavligen inte göra någonting med bara musen. Men du kan trycka på `Super + Space` för att visa Omarchy-menyn, och härifrån kan du göra nästan allt.

Men Omarchy-menyn är inte ens tänkt att vara det huvudsakliga sättet att använda systemet för det mesta. Vi kan bli snabbare än så! Alla de viktigaste programmen är bundna direkt till egna snabbtangenter. Du startar terminalen med `Super + Return` och en webbläsare med `Super + Shift + Return`. Prova att göra det ena efter det andra, så får du se magin med Hyprlands tiling i praktiken:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan sedan trycka på `Super + J` för att stapla dem ovanpå varandra i stället för sida vid sida:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryck på `Super + J` igen för att återställa dem till sina positioner sida vid sida. Prova sedan `Super + Shift + Arrow Right` medan du är i webbläsaren för att byta plats på fönstren.

Prova nu `Super + Shift + T` för att starta Activity monitor. Den visas som ett flytande fönster, med en titelrad att dra den i och knappar för att minimera, maximera och stänga den. Varje flytande fönster får en sådan, var det än befinner sig. Du kan lägga den i tiling med `Super + T` (och trycka på samma tangent igen för att göra den flytande igen). Tryck nu på `Super + Shift + F` för att öppna filhanteraren. Du får en prydlig uppställning med fyra fönster:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerar till det fönster du vill ska vara aktivt med `Super + Arrow`. Det växlar fokus och flyttar markören till mitten av det nya programmet. Vid kanten av en skärm fortsätter det till skärmen på den sidan.

Om du trycker på `Super + Shift + 2` flyttar du det program som för närvarande har fokus till den andra arbetsytan. `Super + Shift + 1` flyttar tillbaka det. (Och `Super + Shift + Alt + 2` flyttar det program som för närvarande har fokus till den andra arbetsytan utan att växla till den).

Med mer än en skärm har varje skärm sina egna arbetsytor 1 till 10. `Super + 2` går till den andra arbetsytan på den skärm du befinner dig på, och varje skärms översta rad visar dess egna arbetsytor och den som den visar. `Super + Tab` växlar mellan arbetsytorna på den skärm du befinner dig på. `Super + Shift + Ctrl + Arrows` flyttar det fönster du befinner dig i till skärmen i den riktningen, till den arbetsyta som den visar, och `Super + Shift + Alt + Arrows` flyttar den arbetsyta du befinner dig på över till skärmen i den riktningen, där den får samma nummer om det är ledigt. En skärm behåller sina arbetsytor när du kopplar bort den: de ansluter till en annan skärms arbetsytor, numrerade efter dem som den redan har, och går tillbaka till sina gamla nummer när skärmen kommer tillbaka.

Om du håller nere `Super` och använder musen för att klicka på ett fönster kan du ändra var det sitter. Om du håller nere `Super` och använder höger musknapp kan du ändra storlek på fönstret helt fritt.

Du stänger ett fönster med `Super + W` eller `Super + Q` (och stänger alla fönster med `Ctrl + Alt + Delete`).

Du kan också gå till helskärm med `Super + F`, eller till och med bara till full bredd (med den översta raden kvar) med `Super + Alt + F`, eller till helskärm inuti ett fönster med `Super + Ctrl + F` (bra för YouTube!).

### Dwindle jämfört med scrolling-layout

Omarchys standardlayout kallas dwindle. Den håller alla fönster du öppnar på en enda arbetsyta synliga hela tiden, även om den måste krympa dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan också välja att göra en arbetsyta till scrolling-layouten, där fönster står uppradade sida vid sida bortom skärmens synliga kant. Du gör en enskild arbetsyta till den här layouten med `Super + L`.

Om du trycker på `Super + L` igen blir arbetsytan flytande, där fönster överlappar fritt och du placerar dem själv, och ett tredje tryck återställer den till dwindle. `Super + Alt + L` går igenom dem åt andra hållet. Ett fönster som ändå är flytande — ett som du har poppat ut med `Super + T`, eller en app som alltid öppnas flytande — förblir flytande när arbetsytan går tillbaka till tiling. Den översta raden markerar den arbetsyta du befinner dig på med dess layout: en fyrkant för dwindle, en cirkel för scrolling och en triangel för flytande. Att klicka på den markeringen växlar också layout, och det gör även displaytangenten på bärbara datorer som har en sådan.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valet gäller per arbetsyta, och det stannar kvar. Så du kan behålla arbetsyta 1 på dwindle för surfande och arbetsyta 2 på scrolling för kod, och de kommer tillbaka på det sättet efter en omstart.

Om du vill använda scrolling-layouten som standard kan du ställa in det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytande arbetsytor

En flytande arbetsyta fungerar som ett traditionellt skrivbord: fönster överlappar, och du flyttar och storleksändrar dem själv. Varje fönster får en titelrad i ditt temas färger, med knappar för att minimera, maximera och stänga. `Super + M` minimerar också det fokuserade fönstret. Ett minimerat fönster väntar i dockan; klicka på dess app för att ta tillbaka det. Klicka på ett fönster för att föra det längst fram. Ändra storlek på det från valfri kant eller valfritt hörn. Dubbelklicka på en titelrad för att maximera fönstret samtidigt som den översta raden förblir synlig, och igen för att få tillbaka dess gamla storlek. Chrome och andra Chromium-baserade webbläsare, Disks och Document Viewer hoppar över titelraden och använder sin egen rubrikrad i stället; `Super + Alt + F` maximerar dem, och `Super + M` minimerar dem.

Varje arbetsyta har en docka, med dina fästa appar, allt som körs, och ett rutnät med varje app bakom appar-knappen, som `Super + Alt + Space` och _Apps_ i Omarchy-menyn också öppnar. Högerklicka på en app i rutnätet, eller tryck på `Delete`, för att avinstallera den. Klicka på en app för att öppna den, eller för att föra dess fönster längst fram; klicka igen för att växla mellan dess fönster. Files tar bara tillbaka ett fönster från den arbetsyta du befinner dig på och öppnar annars ett nytt, och Terminal och Agent startar alltid ett till, även om ett minimerat fönster kommer tillbaka först. Mellanklick öppnar ett nytt fönster. Dra en ikon längs dockan för att flytta den; att dra en app som körs in bland de andra behåller den där. Högerklicka för att behålla en app i dockan, ta bort den därifrån eller avsluta den. Dockan förblir framme medan en arbetsyta är tom, och när arbetsytan har ett fönster gömmer den sig tills pekaren når dess kant. Ett fönster i helskärm gömmer den helt. Dra appar-knappen mot en annan kant av skärmen för att flytta dockan dit. Högerklicka på den för _Position_, för att välja en kant, och _Layout_, för att ställa in standardlayouten så som _Appearance > Workspace Layout_ gör. Positionen finns också under _Appearance > Dock > Dock Position_, och `omarchy dock position left` ställer in den från en terminal. Appar du behåller i dockan är nedtonade medan de inte körs. För att behålla dockan endast på flytande arbetsytor använder du _Appearance > Dock > Dock Only on Floating_ eller `omarchy dock tiling off`.

Nya arbetsytor, och sådana som du inte har gett en egen layout med `Super + L`, använder standardlayouten. Att ändra standarden återställer varje arbetsyta utan fönster till den, medan en arbetsyta med fönster på behåller den layout den har. Ett fönster som minimerats till dockan räknas fortfarande som ett fönster på den arbetsyta det lämnade. Välj den under _Appearance > Workspace Layout_: Tiling, Scrolling eller Floating. `omarchy hyprland workspace layout default scrolling` ställer in den från en terminal.

### Gruppera fönster

Fönster kan grupperas med `Super + G`. När du väl befinner dig i en grupp kommer varje fönster du startar medan den är aktiv att tillhöra gruppen. Du kan flytta mellan dessa grupperade fönster med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` för att gå direkt till grupperade fönster i ordning.

Du kan flytta ut ett fönster ur grupperingen med `Super + Alt + G` eller ta isär hela gruppen genom att trycka på `Super + G` igen. Slutligen kan du flytta fönster utanför gruppen in i den med `Super + Alt + Arrows`.

### Poppa ut fönster

Du kan poppa ut ett fönster ur dess tilldelning till en arbetsyta med `Super + O`. Det fäster det som ett flytande fönster som följer med dig till vilken arbetsyta du än går till. Perfekt för videospelare och liknande.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbetsyta

Det finns en speciell scratchpad-arbetsyta i full storlek som lägger sig över den arbetsyta du för närvarande befinner dig på. Du kommer åt det som finns på den med `Super + S`, och du placerar fönster där med `Super + Alt + S`.

Den fungerar bra för kontroller eller en terminal som du vill interagera med snabbt utan att lämna den aktuella arbetsytan.

### Quake-konsol

Slutligen finns det en Quake-konsol i halv höjd som fälls ner över den arbetsyta du för närvarande befinner dig på. Växla den med `Super + the key above Tab` (grave på US-layouter), och placera ett fönster där med `Super + Shift + the key above Tab`.

Första gången den öppnas startar den din standardagent, eller ber dig välja en om du inte har valt någon än. Medan konsolen bara innehåller ett enda fönster fälls den ner som en centrerad panel i stället för att sträcka sig över hela skärmen. Lägg en andra app på den, så går den tillbaka till full bredd, så att de två får plats sida vid sida.

För att flytta ett fönster från antingen scratchpad-arbetsytan eller konsolen skickar du det direkt till en annan arbetsyta med något i stil med `Super + Shift + 1`.

### Det tar lite tid att vänja sig vid!

Det tar ett tag att vänja sig vid att navigera skrivbordet så här, men när du väl har gjort det blir det svårt att gå tillbaka till en traditionell musstyrd skrivbordsupplevelse!
