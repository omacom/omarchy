# Felsökning

### Jag förstörde mitt system med en uppdatering!

Försök först att [återställa ditt system](47-system-snapshots.md) till versionen före din senaste uppdatering. Om det inte fungerar använder du `omarchy-debug` för att dela ditt problem i #omarchy-help på Discord. Och om allt annat misslyckas kan du installera om standardkonfigurationerna och paketen med `omarchy-reinstall`.

### Varför är vissa appar så stora på min skärm?

Omarchy antar en 2x högupplöst skärm, vilket kräver att `GDK_SCALE` sätts till 2 i `~/.config/hypr/monitors.lua`. Men om du har en 1x-skärm kan du ändra `local omarchy_gdk_scale = 2` till 1 (och sedan starta om alla appar som är för stora). Se [manualen om skärmar](33-monitors.md).

För Spotify kan du använda `Ctrl + Minus` för att förminska gränssnittet (och `Ctrl + Plus` för att förstora det).

### Varför slutade alla mina Super-tangentbindningar att fungera?

På vissa ASUS ROG- och TUF-bärbara datorer är `Fn + Super` en lättmissad kombination som växlar ett Windows-tangentlås i den fasta programvaran (tänkt för spel så att du inte lämnar ett spel av misstag). Inget på skärmen talar om för dig att det har hänt. Medan låset är på skickar Super ingenting alls — så varje Omarchy-bindning som använder Super slutar bara fungera, och det ser ut som att Hyprland har gått sönder.

Tryck på `Fn + Super` en gång innan du börjar gräva i `~/.config/hypr/`, och om det inte ger tillbaka Super trycker du en gång till så att du inte lämnar låset på. Detta är inte Fn-låset, som bara ändrar vad F-tangentraden gör.

### Min Wi-Fi, Bluetooth, ljud eller styrplatta slutade precis fungera

Innan du startar om provar du att starta om det krånglande delsystemet för sig. _Update > Hardware_ i Omarchy-menyn har Wi-Fi, Bluetooth, Audio och Trackpad, och att ladda om ett av dem löser de flesta ”det fungerade för fem minuter sedan”-situationer — ett Bluetooth-headset som inte vill återansluta, en styrplatta som dog efter ett viloläge, ljud som försvann när du kopplade ur en skärm.

### Varför spelar inte mina externa högtalare?

Förmodligen för att de inte är inställda som primär utgång. Klicka på högtalarikonen på höger sida av fältet, så öppnas volymrutan där du kan välja utenhet (och mixa volymen per app också).

### Högtalarna på min bärbara dator låter konstigt

På vissa bärbara datorer tillämpar Omarchy automatiskt en högtalarjustering som korrigerar de inbyggda högtalarnas frekvenssvar. `omarchy audio tuning status` talar om för dig om en är aktiv på din dator, och `omarchy audio tuning off` stänger av den om du hellre vill höra högtalarna obehandlade.

### Varför kan jag inte logga in eller använda sudo med mitt lösenord?

Du skrev förmodligen fel för många gånger och blev utelåst. Om detta händer på låsskärmen kan du trycka på `CTRL + ALT + F2` för att starta en ny TTY där du kan logga in som root och sedan köra `faillock --reset --user [your-username]`. Det återställer utelåsningen, och sedan är du redo att köra.

### Varför visas inte mina auktoriseringsfrågor från 1Password för 1Password SSH Agent / CLI?

Detta kan hända av 2 skäl:

För att den utförliga godkännandefrågan ska visas måste Settings > Advanced > Use Hardware Acceleration vara påslagen. _Obs: Detta kräver en omstart för att börja fungera._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller om du inte har startat 1Password sedan du startade datorn visas inte frågan.
