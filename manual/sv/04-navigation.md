# Navigering

Allt i Omarchy sker via tangentbordet — _ALLT!_ När systemet startar för första gången kan du bokstavligen inte göra någonting med bara musen. Men du kan trycka på `Super + Space` för att visa Omarchy-menyn, och härifrån kan du göra nästan allt.

Men Omarchy-menyn är inte ens tänkt att vara det huvudsakliga sättet att styra systemet för det mesta. Vi kan bli snabbare än så! Alla de viktigaste applikationerna är bundna direkt till individuella snabbtangenter. Du startar terminalen med `Super + Return` och en webbläsare med `Super + Shift + Return`. Prova att göra det ena efter det andra, så får du se Hyprlands plattsättning i praktiken:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kan sedan trycka på `Super + J` för att stapla dem ovanpå varandra i stället för sida vid sida:

 ![navigation-stacked](images/navigation-stacked.webp)

Tryck på `Super + J` igen för att återställa dem till positionerna sida vid sida. Prova sedan `Super + Shift + Arrow Right` medan du är i webbläsaren för att byta plats på fönstren.

Prova nu `Super + Shift + T` för att starta Aktivitetsövervakaren. Den visas som ett flytande fönster. Du kan plattsätta den med `Super + T` (och trycka på den igen för att göra den flytande igen). Tryck nu på `Super + Shift + F` för att öppna filhanteraren. Du får en snygg fyrvägsuppställning:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigerar mellan det fönster du vill ska vara aktivt med `Super + Arrow`. Det växlar fokus och flyttar markören till mitten av den nya applikationen. Vid kanten av en skärm fortsätter den till bildskärmen på den sidan.

Om du trycker på `Super + Shift + 2` flyttar du den aktuella fokuserade applikationen till den andra arbetsytan. `Super + Shift + 1` flyttar den tillbaka. (Och `Super + Shift + Alt + 2` flyttar den aktuella fokuserade applikationen till den andra arbetsytan utan att växla till den).

Med mer än en bildskärm har varje bildskärm sina egna arbetsytor 1 till 10. `Super + 2` går till den andra arbetsytan på den bildskärm du är på, och varje bildskärms övre fält visar sina egna arbetsytor och den den visar. `Super + Tab` cyklar genom arbetsytorna på den bildskärm du är på. `Super + Shift + Ctrl + Arrows` flyttar fönstret du är på till bildskärmen i den riktningen, till den arbetsyta den visar, och `Super + Shift + Alt + Arrows` flyttar arbetsytan du är på över till bildskärmen i den riktningen, där den får samma nummer om det är ledigt. En bildskärm behåller sina arbetsytor när du kopplar ur den: de ansluter sig till en annan skärms, numrerade efter dem den redan har, och går tillbaka till sina gamla nummer när bildskärmen återvänder.

Om du håller ner `Super` och använder musen för att klicka på ett fönster kan du ordna om var det sitter. Om du håller ner `Super` och använder höger musknapp kan du ändra fönstrets storlek fritt.

Du stänger ett fönster med `Super + W` eller `Super + Q` (och stänger alla fönster med `Ctrl + Alt + Delete`).

Du kan också gå till fullskärm med `Super + F` eller till och med bara full bredd (med det övre fältet kvar) med `Super + Alt + F` eller fullskärm inuti ett fönster med `Super + Ctrl + F` (bra för YouTube!).

### Dwindle kontra rullande layout

Omarchys standardlayout kallas dwindle. Den håller alla fönster du öppnar på en enda arbetsyta synliga hela tiden, även om den måste krympa dem.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Men du kan också välja att förvandla en arbetsyta till den rullande layouten där fönster radas upp sida vid sida, bortom bildskärmens synliga kant. Du förvandlar en enskild arbetsyta till den här layouten via `Super + L`.

Om du trycker på `Super + L` igen förvandlas arbetsytan till flytande, där fönster överlappar fritt och du placerar dem själv, och en tredje tryckning återställer den till dwindle. `Super + Alt + L` går igenom dem åt andra hållet. Ett fönster som ändå flyter — ett som du har plockat ut med `Super + T`, eller en app som alltid öppnas flytande — fortsätter att flyta när arbetsytan går tillbaka till plattsättning. Det övre fältet markerar arbetsytan du är på med dess layout: en kvadrat för dwindle, en cirkel för rullande och en triangel för flytande. Om du klickar på den markeringen växlar du layouten också.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valet gäller per arbetsyta, och det sitter kvar. Så du kan behålla arbetsyta 1 på dwindle för surfande och arbetsyta 2 på rullande för kod, och de kommer tillbaka så efter en omstart.

Om du vill använda den rullande layouten som standard kan du ställa in det i `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Flytande arbetsytor

En flytande arbetsyta fungerar som ett traditionellt skrivbord: fönster överlappar, och du flyttar och storleksändrar dem själv. Varje fönster får en titellist i ditt temas färger, med knappar för att minimera, maximera och stänga. `Super + M` minimerar också det fokuserade fönstret. Ett minimerat fönster väntar i dockan; klicka på dess app för att ta tillbaka det. Klicka på ett fönster för att föra det framåt. Ändra dess storlek från vilken kant eller vilket hörn som helst. Dubbelklicka på en titellist för att maximera fönstret samtidigt som det övre fältet hålls synligt, och igen för att få tillbaka dess gamla storlek.

En flytande arbetsyta visar också en docka, med dina fästa appar, allt som körs, och ett rutnät med alla appar bakom appknappen, som `Super + Alt + Space` och _Appar_ i Omarchy-menyn också öppnar. Högerklicka på en app i rutnätet, eller tryck på `Delete`, för att avinstallera den. Klicka på en app för att öppna den, eller för att föra dess fönster framåt; klicka igen för att cykla genom dess fönster. Mellanklick öppnar ett nytt fönster. Dra en ikon längs dockan för att flytta den; drar du en körande app in bland de andra behålls den där. Högerklicka för att behålla en app i dockan, ta bort den eller avsluta den. Dockan flyttar sig ur vägen för ett fullskärmsfönster. Högerklicka på appknappen för att flytta dockan till en annan kant eller få den att gömma sig tills pekaren når dess kant. Positionen finns också under _Utseende > Docka > Dockans position_, och `omarchy dock position left` och `omarchy dock autohide on` ställer in båda från en terminal. Appar du behåller i dockan är uttonade medan de inte körs.

Nya arbetsytor, och sådana du inte har gett en egen layout med `Super + L`, använder standardlayouten. Om du ändrar standarden återställs varje arbetsyta utan fönster till den, medan en med fönster på den behåller den layout den har. Ett fönster som minimerats till dockan räknas fortfarande som ett fönster på den arbetsyta det lämnade. Välj den under _Utseende > Arbetsytans layout_: Kaklat, Rullande eller Flytande. `omarchy-hyprland-workspace-layout-default scrolling` ställer in det från en terminal.

### Gruppera fönster

Fönster kan grupperas med `Super + G`. När du väl är i en grupp kommer varje fönster du startar medan den är aktiv att tillhöra gruppen. Du kan flytta mellan dessa grupperade fönster med `Super + Ctrl + Arrow Left/Right` eller `Super + Alt + 1/2/3/4` för att gå direkt till grupperade fönster i ordning.

Du kan flytta ett fönster ut ur grupperingen med `Super + Alt + G` eller ta isär hela gruppen genom att trycka på `Super + G` igen. Till sist kan du flytta fönster utanför gruppen in i den med `Super + Alt + Arrows`.

### Plocka ut fönster

Du kan plocka ut ett fönster från dess arbetsytetilldelning med `Super + O`. Det fäster det som ett flytande fönster som följer med dig till vilken arbetsyta du än går till. Perfekt för videospelare och liknande.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-arbetsyta

Det finns en särskild scratchpad-arbetsyta i full storlek som lägger sig över vilken arbetsyta du än är på för tillfället. Du kommer åt det som finns på den med `Super + S`, och du placerar fönster där med `Super + Alt + S`.

Den fungerar bra för kontroller eller en terminal som du snabbt vill interagera med utan att lämna den aktuella arbetsytan.

### Quake-konsol

Till sist finns det en Quake-konsol med halv höjd som fälls ner över vilken arbetsyta du än är på för tillfället. Växla den med `Super + Grave`, och placera ett fönster där med `Super + Shift + Grave`.

Den öppnas med din standardagent redo att köra. Medan konsolen bara innehåller ett enda fönster fälls den ner som en centrerad panel i stället för att spänna över skärmen. Lägg en andra app på den och den går tillbaka till full bredd, så att de två får plats att sitta sida vid sida.

För att flytta ett fönster från antingen scratchpad-ytan eller konsolen skickar du det direkt till en annan arbetsyta med något i stil med `Super + Shift + 1`.

### Det tar lite tid att vänja sig!

Det tar ett tag att vänja sig vid att navigera skrivbordet på det här sättet, men när du väl gör det kommer det att vara svårt att gå tillbaka till en traditionell musstyrd skrivbordsupplevelse!
