# Felsökning

### Jag förstörde mitt system med en uppdatering!

Försök först att [rulla tillbaka ditt system](47-system-snapshots.md) till versionen före din senaste uppdatering. Om det inte fungerar, använd `omarchy-debug` för att dela med dig av ditt problem i #omarchy-help i Discord. Och om allt det misslyckas kan du installera om standardkonfigurationerna och paketen med `omarchy-reinstall`.

### Varför är vissa appar så stora på min skärm?

Omarchy förutsätter en högupplöst skärm med 2x, så det sätter `GDK_SCALE` till 2 tills du väljer en skala i bildskärmspanelen. Om du har en skärm med 1x och GTK- eller X11-appar blir överdimensionerade, välj 1x för den i bildskärmspanelen, eller lägg till `hl.env("GDK_SCALE", "1")` i `~/.config/hypr/monitors.lua` (och starta sedan om alla appar som är överdimensionerade). Se [manualen om bildskärmar](33-monitors.md).

För Spotify kan du använda `Ctrl + Minus` för att förminska gränssnittet (och `Ctrl + Plus` för att förstora det).

### Varför slutade alla mina Super-tangentbindningar att fungera?

På vissa ASUS ROG- och TUF-laptops är `Fn + Super` en kombination som är lätt att missa och som växlar ett firmwarelås för Windows-tangenten (avsett för spel, så att du inte lämnar ett spel av misstag). Inget på skärmen talar om att det har hänt. Medan låset är på skickar Super ingenting alls — så varje Omarchy-bindning som använder Super slutar bara att fungera, och det ser ut som att Hyprland har gått sönder.

Tryck på `Fn + Super` en gång innan du gräver i `~/.config/hypr/`, och om det inte får tillbaka Super, tryck på det igen så att du inte lämnar låset på. Det här är inte Fn-lock, som bara ändrar vad F-tangentraden gör.

### Min Wi-Fi, Bluetooth, ljud eller styrplatta slutade precis att fungera

Innan du startar om, prova att starta om det krånglande delsystemet för sig. _Uppdatera > Hårdvara_ i Omarchy-menyn har Wi-Fi, Bluetooth, Ljud och Styrplatta, och att ladda om ett av dem löser majoriteten av situationerna av typen "det fungerade för fem minuter sedan" — ett Bluetooth-headset som inte vill ansluta igen, en styrplatta som dog efter ett viloläge, ljud som försvann när du kopplade ur en bildskärm.

### Varför spelar inte mina externa högtalare?

Förmodligen för att de inte är inställda som primär utgång. Klicka på högtalarikonen på höger sida av fältet, så öppnas volympopupen där du kan välja utmatningsenhet (och mixa volymer per app också).

### Mina laptophögtalare låter fel

På vissa laptops tillämpar Omarchy automatiskt en högtalarjustering som korrigerar de inbyggda högtalarnas frekvenssvar. `omarchy audio tuning status` talar om för dig om en är aktiv på din maskin, och `omarchy audio tuning off` stänger av den om du hellre vill höra högtalarna obehandlade.

### Varför kan jag inte logga in eller använda sudo med mitt lösenord?

Du skrev förmodligen fel tio gånger och blev utelåst. Utlåsningen försvinner av sig själv efter två minuter. Om du inte kan vänta, och det här händer på låsskärmen, kan du trycka på `CTRL + ALT + F2` för att starta en ny TTY där du kan logga in som root, och sedan köra `faillock --reset --user [your-username]`. Det återställer utlåsningen, och sedan är det bara att köra.

### Mitt lösenord accepteras, men jag kommer tillbaka till inloggningsskärmen

En trasig sessionsmiljöfil kan hindra skrivbordet från att starta även när ditt lösenord är korrekt. Det här är särskilt värt att kontrollera efter att du har redigerat `~/.config/uwsm/env.d/`.

Tryck på `Ctrl + Alt + F2`, logga in med ditt vanliga användarnamn och lösenord, och inspektera den aktuella uppstartens användarjournal:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Leta efter ett fel som namnger en av dina miljöfiler, till exempel `bad substitution`, precis före ett meddelande om att env-utmatningsmärket inte hittades. Flytta ut den filen från `env.d` innan du försöker logga in igen. Till exempel, om felet namnger `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM hoppar över en fil med ett syntaxfel, men ett ödesdigert fel som bara visar sig medan filen körs, som `bad substitution`, kan ändå hindra skrivbordet från att starta. En återställning till en systemögonblicksbild reparerar inte dessa filer, eftersom `/home` inte rullas tillbaka.

När du kan logga in igen, fixa den sparade kopian innan du flyttar tillbaka den. `sh -n` fångar syntaxfel utan att köra filen, men kan inte fånga varje fel som uppstår när den läses in. Ha en fungerande terminal öppen medan du testar ändringar.

### Varför visas inte mina auktoriseringsprompter i 1Password för 1Password SSH Agent / CLI?

Det här kan hända av 2 anledningar:

För att den utförliga godkännandeprompten ska visas måste Inställningar > Avancerat > Use Hardware Acceleration vara påslaget. _Obs: Det här kräver en omstart för att börja fungera._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller om du inte har startat 1Password sedan du startade upp, kommer prompten inte att visas.
