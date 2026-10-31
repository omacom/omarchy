# Felsökning

### Jag förstörde mitt system med en uppdatering!

Försök först att [återställa systemet](47-system-snapshots.md) till versionen före din senaste uppdatering. Om det inte fungerar, använd `omarchy-debug` för att dela med dig av ditt problem på #omarchy-help i Discord. Och om allt det misslyckas kan du installera om standardkonfigurationerna och paketen med `omarchy-reinstall`.

### Varför är vissa appar så stora på min skärm?

Omarchy förutsätter en högupplöst skärm på 2x, så det sätter `GDK_SCALE` till 2 tills du väljer en skala i bildskärmspanelen. Om du har en 1x-skärm och GTK- eller X11-appar visas för stora, välj 1x för den i bildskärmspanelen, eller lägg till `hl.env("GDK_SCALE", "1")` i `~/.config/hypr/monitors.lua` (och starta sedan om alla appar som är för stora). Se [manualen om bildskärmar](33-monitors.md).

För Spotify kan du använda `Ctrl + Minus` för att förminska gränssnittet (och `Ctrl + Plus` för att göra det större).

### Varför slutade alla mina bindningar med Super-tangenten att fungera?

På vissa bärbara datorer från ASUS ROG och TUF är `Fn + Super` en kombination som är lätt att missa och som växlar ett firmware-lås för Windows-tangenten (till för spel, så att du inte lämnar ett spel av misstag). Ingenting på skärmen talar om att det har hänt. Medan låset är på avger Super ingenting alls — så varje bindning i Omarchy som använder Super slutar bara fungera, och det ser ut som att Hyprland gick sönder.

Tryck på `Fn + Super` en gång innan du gräver i `~/.config/hypr/`, och om det inte får tillbaka Super, tryck en gång till så att du inte lämnar låset på. Det här är inte Fn-lock, som bara ändrar vad F-tangentsraden gör.

### Min Wi-Fi, Bluetooth, mitt ljud eller min styrplatta slutade precis att fungera

Innan du startar om, försök att starta om bara det kränkande delsystemet för sig självt. _Update > Hardware_ i Omarchy-menyn har Wi-Fi, Bluetooth, Audio och Trackpad, och att ladda om en av dem löser majoriteten av ”det fungerade för fem minuter sedan”-situationerna — ett Bluetooth-headset som inte vill återansluta, en styrplatta som dog efter viloläge, ljud som försvann när du kopplade ur en bildskärm.

### Varför spelar mina externa högtalare inte upp något?

Förmodligen för att de inte är inställda som primär utgång. Klicka på högtalarikonen på höger sida av fältet, så öppnar den volympopupen där du kan välja utgångsenhet (och mixa volymer per app också).

### Högtalarna i min bärbara dator låter fel

På vissa bärbara datorer tillämpar Omarchy automatiskt en högtalarjustering som korrigerar frekvensresponsen hos de inbyggda högtalarna. `omarchy audio tuning status` talar om för dig om en sådan är aktiv på din maskin, och `omarchy audio tuning off` stänger av den om du hellre vill höra högtalarna råa.

### Varför kan jag inte logga in eller använda sudo med mitt lösenord?

Du skrev det förmodligen fel för många gånger och blev utelåst. Om det här händer på låsskärmen kan du trycka på `CTRL + ALT + F2` för att starta en ny TTY där du kan logga in som root, och sedan köra `faillock --reset --user [your-username]`. Det återställer utelåsningen, och sedan är du redo att köra.

### Mitt lösenord accepteras, men jag kommer tillbaka till inloggningsskärmen

En trasig fil för sessionsmiljön kan hindra skrivbordet från att starta även när ditt lösenord är korrekt. Det här är särskilt värt att kontrollera efter att du har redigerat `~/.config/uwsm/env.d/`.

Tryck på `Ctrl + Alt + F2`, logga in med ditt vanliga användarnamn och lösenord, och inspektera användarjournalen för den aktuella uppstarten:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Leta efter ett fel som namnger en av dina miljöfiler, till exempel `bad substitution`, precis före ett meddelande om att env-utgångsmärket inte hittades. Flytta ut den filen ur `env.d` innan du försöker logga in igen. Om felet till exempel namnger `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM hoppar över en fil med ett syntaxfel, men ett fatalt fel som bara visar sig medan filen körs, som `bad substitution`, kan fortfarande hindra skrivbordet från att starta. En återställning till en systemsnapshot reparerar inte de här filerna, eftersom `/home` inte återställs.

När du kan logga in, laga den sparade kopian innan du flyttar tillbaka den. `sh -n` fångar syntaxfel utan att köra filen, men kan inte fånga alla fel som uppstår när den sourcas. Ha en fungerande terminal öppen medan du testar ändringar.

### Varför visas inte mina auktoriseringsuppmaningar i 1Password för 1Password SSH Agent / CLI?

Det här kan hända av 2 anledningar:

För att den utförliga godkännandeuppmaningen ska visas måste Settings > Advanced > Use Hardware Acceleration vara påslagen. _Obs: Det här kräver en omstart för att börja fungera._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller om du inte har startat 1Password sedan du startade upp datorn kommer uppmaningen inte att visas.
