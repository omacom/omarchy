# Notiser

Du kan snabbt komma åt datum och tid, batteristatus och aktuellt väder med snabbtangentnotiserna.

### Datum & tid

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Väder

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Platsen detekteras från din IP-adress, vilket vanligtvis är tillräckligt nära, men inte alltid. Du kan fästa den med `omarchy weather location --set Malibu`, eller vara exakt genom att lägga till koordinater: `omarchy weather location --set Malibu 34.0259,-118.7798`. Kör `omarchy weather location` på egen hand för att se var den tror att du är, och `--clear` för att gå tillbaka till automatisk detektering.

### Batteri

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
