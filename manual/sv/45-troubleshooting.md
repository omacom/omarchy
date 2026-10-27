# Felsökning

### Jag förstörde mitt system med en uppdatering!

Prova först att [rulla tillbaka ditt system](47-system-snapshots.md) till versionen före din senaste uppdatering. Om det inte fungerar använder du `omarchy-debug` för att dela med dig av ditt problem på #omarchy-help i Discord. Och om allt det misslyckas kan du ominstallera standardkonfigurationerna och paketen med `omarchy-reinstall`.

### Varför är vissa appar så stora på min skärm?

Omarchy antar en 2x högupplöst skärm, vilket kräver att `GDK_SCALE` ställs in på 2 i `~/.config/hypr/monitors.lua`. Men om du är på en 1x-skärm kan du ändra `local omarchy_gdk_scale = 2` till 1 (och sedan starta om alla appar som är överdimensionerade). Se [manualen om skärmar](33-monitors.md).

För Spotify kan du använda `Ctrl + Minus` för att krympa gränssnittet (och `Ctrl + Plus` för att göra det större).

### Mitt Wi-Fi, Bluetooth, ljud eller styrplatta slutade bara fungera

Innan du startar om, prova att starta om det felande delsystemet på egen hand. Under _Uppdatera > Hardware_ i Omarchy-menyn finns Wi-Fi, Bluetooth, Audio och Trackpad, och att ladda om en av dem löser majoriteten av ”det fungerade för fem minuter sedan”-situationer — ett Bluetooth-headset som inte återansluter, en styrplatta som dog efter ett viloläge, ljud som försvann när du kopplade ur en skärm.

### Varför spelar inte mina externa högtalare?

Förmodligen eftersom de inte är inställda som primär utgång. Klicka på högtalarikonen på högra sidan av fältet, så öppnas volympopupen där du kan välja utgångsenheten (och mixa volymer per app också).

### Mina bärbara högtalare låter fel

På vissa bärbara datorer tillämpar Omarchy automatiskt en högtalarkurvjustering som korrigerar de inbyggda högtalarnas frekvensrespons. `omarchy audio tuning status` berättar om en sådan är aktiv på din dator, och `omarchy audio tuning off` stänger av den om du hellre vill höra högtalarna råa.

### Varför kan jag inte logga in eller använda sudo med mitt lösenord?

Du skrev förmodligen in det fel för många gånger och låstes ute. Om detta händer på låsskärmen kan du trycka på `CTRL + ALT + F2` för att starta en ny TTY där du kan logga in som root, och sedan köra `faillock --reset --user [your-username]`. Det återställer utelåsningen, och du är redo.

### Varför visas inte mina 1Password-auktoriseringsfrågor för 1Password SSH Agent / CLI?

Detta kan hända av två skäl:

För att den avancerade godkännandefrågan ska visas måste Settings > Advanced > Use Hardware Acceleration vara påslagen. _Obs: Detta kräver en omstart för att börja fungera._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller om du inte har startat 1Password sedan du startade datorn kommer frågan inte att visas.
