# Felsökning

### Jag förstörde mitt system med en uppdatering!

Försök först att [återställa ditt system](47-system-snapshots.md) till versionen före din senaste uppdatering. Om det inte fungerar, använd `omarchy-debug` för att dela med dig av ditt problem i #omarchy-help på Discord. Och om allt annat misslyckas kan du installera om standardkonfigurationerna och paketen med `omarchy-reinstall`.

### Varför är vissa appar så stora på min skärm?

Omarchy utgår från en 2x-skärm med hög upplösning, så det sätter `GDK_SCALE` till 2 tills du väljer en skala i monitorpanelen. Om du har en 1x-skärm och GTK- eller X11-appar blir för stora, välj 1x för den i monitorpanelen, eller lägg till `hl.env("GDK_SCALE", "1")` i `~/.config/hypr/monitors.lua` (och starta sedan om alla appar som är för stora). Se [manualen om monitorer](33-monitors.md).

För Spotify kan du använda `Ctrl + Minus` för att krympa gränssnittet (och `Ctrl + Plus` för att göra det större).

### Varför slutade alla mina Super-tangentbindningar att fungera?

På vissa ASUS ROG- och TUF-laptops är `Fn + Super` en lättmissad kombination som slår av och på ett Windows-tangentlås i firmwaren (avsett för gaming så att du inte lämnar ett spel av misstag). Ingenting på skärmen talar om att det har hänt. Medan låset är på skickar Super ingenting alls — så varje Omarchy-bindning som använder Super slutar bara fungera, och det ser ut som att Hyprland gick sönder.

Tryck på `Fn + Super` en gång innan du gräver i `~/.config/hypr/`, och om det inte får tillbaka Super, tryck på den igen så att du inte lämnar låset på. Det här är inte Fn-lock, som bara ändrar vad F-tangentraden gör.

### Min Wi-Fi, Bluetooth, ljud eller styrplatta slutade precis fungera

Innan du startar om, försök att starta om det krånglande delsystemet för sig. _Update > Hardware_ i Omarchy-menyn har Wi-Fi, Bluetooth, Audio och Trackpad, och att ladda om ett av dem löser de flesta ”det fungerade för fem minuter sedan”-situationerna — ett Bluetooth-headset som inte vill återansluta, en styrplatta som dog efter viloläge, ljud som försvann när du kopplade ur en monitor.

### Varför spelar inte mina externa högtalare?

Förmodligen för att de inte är inställda som primär utgång. Klicka på högtalarikonen på höger sida av baren, så öppnas volympopupen där du kan välja utenhet (och mixa volymer per app också).

### Mina laptop-högtalare låter konstigt

På vissa laptops tillämpar Omarchy automatiskt en högtalarjustering som korrigerar de inbyggda högtalarnas frekvenssvar. `omarchy audio tuning status` talar om för dig om en är aktiv på din maskin, och `omarchy audio tuning off` stänger av den om du hellre hör högtalarna råa.

### Varför kan jag inte logga in eller sudo med mitt lösenord?

Du skrev förmodligen fel för många gånger och blev utelåst. Om det händer på låsskärmen kan du trycka på `CTRL + ALT + F2` för att starta en ny TTY där du kan logga in som root, och sedan köra `faillock --reset --user [your-username]`. Det återställer utelåsningen, och sedan är det bara att köra.

### Varför visas inte mina auktoriseringsmeddelanden för 1Password för 1Password SSH Agent / CLI?

Det kan hända av 2 anledningar:

För att den utförliga godkännandeprompten ska visas måste Settings > Advanced > Use Hardware Acceleration vara påslagen. _Observera: Detta kräver en omstart för att börja fungera._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller om du inte har startat 1Password sedan du startade upp, kommer prompten inte att visas.
