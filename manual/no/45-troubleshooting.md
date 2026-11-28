# Feilsøking

### Jeg ødela systemet mitt med en oppdatering!

Prøv først å [rulle tilbake systemet ditt](47-system-snapshots.md) til versjonen før den siste oppdateringen din. Hvis det ikke virker, bruk `omarchy-debug` for å dele problemet ditt på #omarchy-help i Discord. Og hvis alt det feiler, kan du installere standardkonfigurasjonene og -pakkene på nytt med `omarchy-reinstall`.

### Hvorfor er noen apper så store på skjermen min?

Omarchy forutsetter en høyoppløselig skjerm med 2x, så den setter `GDK_SCALE` til 2 til du velger en skalering i skjermpanelet. Hvis du bruker en 1x-skjerm og GTK- eller X11-apper blir for store, velg 1x for den i skjermpanelet, eller legg til `hl.env("GDK_SCALE", "1")` i `~/.config/hypr/monitors.lua` (og start deretter alle apper som er for store, på nytt). Se [håndboken om skjermer](33-monitors.md).

For Spotify kan du bruke `Ctrl + Minus` for å krympe grensesnittet (og `Ctrl + Plus` for å gjøre det større).

### Hvorfor sluttet alle Super-tastebindingene mine å virke?

På noen bærbare datamaskiner fra ASUS ROG og TUF er `Fn + Super` en akkord som er lett å overse, og som slår av og på en fastvarebasert Windows-tastlås (ment for gaming, så du ikke forlater et spill ved et uhell). Ingenting på skjermen forteller deg at det har skjedd. Mens låsen er på, sender Super ingenting i det hele tatt — så alle Omarchy-bindinger som bruker Super, slutter bare å virke, og det ser ut som om Hyprland er ødelagt.

Trykk på `Fn + Super` én gang før du graver i `~/.config/hypr/`, og hvis det ikke får Super tilbake, trykk en gang til så du ikke lar låsen stå på. Dette er ikke Fn-lås, som bare endrer hva F-tasteraden gjør.

### Wi-Fi, Bluetooth, lyd eller styreflaten min sluttet bare å virke

Før du starter på nytt, prøv å starte det trøblete undersystemet på nytt for seg selv. _Update > Hardware_ i Omarchy-menyen har Wi-Fi, Bluetooth, Audio og Trackpad, og å laste inn en av dem på nytt rydder opp i de fleste «det virket for fem minutter siden»-situasjoner — et Bluetooth-hodesett som ikke vil koble til igjen, en styreflate som sluttet å virke etter hvilemodus, lyd som forsvant da du koblet fra en skjerm.

### Hvorfor spiller ikke de eksterne høyttalerne mine?

Sannsynligvis fordi de ikke er satt som primærutgang. Klikk på høyttalerikonet på høyre side av linjen, så åpnes volumvinduet der du kan velge utgangsenheten (og mikse volum per app også).

### Høyttalerne på den bærbare datamaskinen min høres feil ut

På noen bærbare datamaskiner bruker Omarchy automatisk en høyttalerjustering som korrigerer frekvensresponsen til de innebygde høyttalerne. `omarchy audio tuning status` forteller deg om en justering er aktiv på maskinen din, og `omarchy audio tuning off` slår den av hvis du heller vil høre høyttalerne rått.

### Hvorfor kan jeg ikke logge inn eller bruke sudo med passordet mitt?

Du skrev det sannsynligvis feil ti ganger og ble låst ute. Utestengingen oppheves av seg selv etter to minutter. Hvis du ikke kan vente, og dette skjer på låseskjermen, kan du trykke `CTRL + ALT + F2` for å starte en ny TTY der du kan logge inn som root, og deretter kjøre `faillock --reset --user [your-username]`. Det tilbakestiller utestengingen, og så er du klar.

### Passordet mitt blir godtatt, men jeg kommer tilbake til påloggingsskjermen

En ødelagt miljøfil for økten kan hindre skrivebordet i å starte selv når passordet ditt er riktig. Dette er spesielt verdt å sjekke etter at du har redigert `~/.config/uwsm/env.d/`.

Trykk `Ctrl + Alt + F2`, logg inn med ditt vanlige brukernavn og passord, og undersøk brukerjournalen for gjeldende oppstart:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Se etter en feil som navngir en av miljøfilene dine, for eksempel `bad substitution`, rett før en melding om at merket for env-utdata ikke ble funnet. Flytt den filen ut av `env.d` før du prøver å logge inn igjen. Hvis feilen for eksempel navngir `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM hopper over en fil med en syntaksfeil, men en fatal feil som bare dukker opp mens filen kjører, som `bad substitution`, kan fortsatt hindre skrivebordet i å starte. En tilbakerulling til et systemsnapshot reparerer ikke disse filene, fordi `/home` ikke rulles tilbake.

Når du kan logge inn, fikser du den lagrede kopien før du flytter den tilbake. `sh -n` fanger opp syntaksfeil uten å kjøre filen, men kan ikke fange opp alle feil som oppstår når den leses inn. Hold en terminal som virker, åpen mens du tester endringer.

### Hvorfor vises ikke 1Password-autoriseringsvinduene for 1Password SSH Agent / CLI?

Dette kan skje av 2 grunner:

For at det fyldige godkjenningsvinduet skal vises, må Settings > Advanced > Use Hardware Acceleration være slått på. _Merk: Dette krever en omstart for å begynne å virke._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password siden oppstart, vises ikke vinduet.
