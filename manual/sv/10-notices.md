# Aviseringar

Aviseringar hamnar i det övre högra hörnet på den fokuserade skärmen. Du kan också snabbt komma åt datum och tid, batteristatus och aktuellt väder med kortkommandoaviseringarna.

## Aviseringar

Aviseringar från samma app eller webbplats staplas i en kortlek, så att en pratglad Slack-kanal inte knuffar bort meddelandet om ditt misslyckade bygge från skärmen. Hovra över en kortlek för att fälla ut den; inget nytt glider in under pekaren medan du läser. Klicka på ett kort för att hoppa till var det kom ifrån, högerklicka, mittenklicka eller tryck på ✕ för att avfärda det.

Kort erbjuder det de bär med sig: _Kopiera kod_ för verifieringskoder (hålls utanför [urklippshistoriken](08-unified-clipboard-history.md) och rensas efter en minut), plus eventuella knappar som appen tillhandahåller. Länkar i en aviserings text öppnas när du klickar på dem.

För att använda dem utan mus trycker du på `Super + Ctrl + ,`. Den nyaste aviseringen väljs och dess knappar numreras: tryck på en siffra för att använda en, `Enter` för att klicka på aviseringen, `↑` och `↓` för att flytta mellan aviseringar, `Delete` för att avfärda en och `Esc` för att ge tillbaka tangentbordet. Den släpper också taget på egen hand efter några sekunders inaktivitet.

Att tysta aviseringar håller dem tillbaka, förutom Omarchys egna bekräftelser, nödlägesvarningar och verifieringskoder, som du bad om för en stund sedan. Ta fram de senaste få på skärmen igen, oavsett om de hållits tillbaka eller inte, med `Super + Shift + Alt + ,`. Historiken sparas i en dag.

## Kortkommandoaviseringar

### Datum och tid

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Väder

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Platsen upptäcks från din IP-adress, vilket oftast är tillräckligt nära, men inte alltid. Du kan precisera den med `omarchy weather location --set Malibu`, eller vara exakt genom att lägga till koordinater: `omarchy weather location --set Malibu 34.0259,-118.7798`. Kör `omarchy weather location` på egen hand för att se var den tror att du är, och `--clear` för att gå tillbaka till automatisk upptäckt.

### Batteri

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
