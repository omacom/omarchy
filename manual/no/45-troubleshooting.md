# Feilsøking

### Jeg ødela systemet mitt med en oppdatering!

Prøv først å [rulle tilbake systemet ditt](47-system-snapshots.md) til versjonen før den siste oppdateringen din. Hvis det ikke fungerer, bruk `omarchy-debug` til å dele problemet ditt på #omarchy-help på Discord. Og hvis alt annet svikter, kan du installere standardkonfigurasjonene og -pakkene på nytt med `omarchy-reinstall`.

### Hvorfor er noen apper så store på skjermen min?

Omarchy antar at du har en høyoppløselig 2x-skjerm, så den setter `GDK_SCALE` til 2 til du velger en skala i skjermpanelet. Hvis du har en 1x-skjerm og GTK- eller X11-apper blir for store, velg 1x for den i skjermpanelet, eller legg til `hl.env("GDK_SCALE", "1")` i `~/.config/hypr/monitors.lua` (og start deretter alle apper som er for store på nytt). Se [håndboken om skjermer](33-monitors.md).

For Spotify kan du bruke `Ctrl + Minus` til å krympe grensesnittet (og `Ctrl + Plus` til å gjøre det større).

### Hvorfor sluttet alle Super-tastebindingene mine å fungere?

På noen ASUS ROG- og TUF-bærbare er `Fn + Super` en kombinasjon som er lett å overse, og som slår av og på en fastvarelås for Windows-tasten (ment for spilling, så du ikke forlater et spill ved et uhell). Ingenting på skjermen forteller deg at det har skjedd. Mens låsen er på, sender Super ingenting i det hele tatt — så hver eneste Omarchy-binding som bruker Super slutter bare å fungere, og det ser ut som Hyprland har gått i stykker.

Trykk `Fn + Super` én gang før du graver deg ned i `~/.config/hypr/`, og hvis det ikke får Super tilbake, trykk den igjen så du ikke lar låsen stå på. Dette er ikke Fn-lock, som bare endrer hva F-tasteraden gjør.

### Wi-Fi-en, Bluetooth-en, lyden eller styreflaten min sluttet bare å fungere

Før du starter på nytt, prøv å starte det aktuelle delsystemet på nytt på egen hånd. _Update > Hardware_ i Omarchy-menyen har Wi-Fi, Bluetooth, Audio og Trackpad, og å laste inn én av dem på nytt fikser de fleste «det fungerte for fem minutter siden»-situasjonene — et Bluetooth-hodesett som ikke vil koble til igjen, en styreflate som gikk død etter hvilemodus, lyd som forsvant da du koblet fra en skjerm.

### Hvorfor spiller ikke de eksterne høyttalerne mine?

Sannsynligvis fordi de ikke er satt som primærutgang. Klikk på høyttalerikonet på høyre side av linjen, så åpnes volum-popupen der du kan velge utgangsenheten (og mikse volum per app også).

### Høyttalerne på den bærbare PC-en min høres feil ut

På noen bærbare PC-er bruker Omarchy automatisk en høyttalerjustering som korrigerer frekvensresponsen til de innebygde høyttalerne. `omarchy audio tuning status` forteller deg om en er aktiv på maskinen din, og `omarchy audio tuning off` slår den av hvis du heller vil høre høyttalerne rå.

### Hvorfor kan jeg ikke logge inn eller bruke sudo med passordet mitt?

Du har sannsynligvis skrevet det feil for mange ganger og blitt låst ute. Hvis dette skjer på låseskjermen, kan du trykke `CTRL + ALT + F2` for å starte en ny TTY der du kan logge inn som root, og deretter kjøre `faillock --reset --user [your-username]`. Det nullstiller utlåsingen, og du er klar igjen.

### Passordet mitt godtas, men jeg kommer tilbake til innloggingsskjermen

En ødelagt miljøfil for økten kan hindre skrivebordet i å starte selv når passordet ditt er riktig. Dette er spesielt verdt å sjekke etter at du har redigert `~/.config/uwsm/env.d/`.

Trykk `Ctrl + Alt + F2`, logg inn med ditt vanlige brukernavn og passord, og undersøk brukerloggen for gjeldende oppstart:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Se etter en feil som navngir en av miljøfilene dine, for eksempel `bad substitution`, like før en melding om at env output mark ikke ble funnet. Flytt den filen ut av `env.d` før du prøver å logge inn igjen. Hvis feilen for eksempel navngir `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM hopper over en fil med en syntaksfeil, men en fatal feil som bare dukker opp mens filen kjøres, som `bad substitution`, kan fortsatt hindre skrivebordet i å starte. En tilbakerulling av et systemøyeblikksbilde reparerer ikke disse filene, fordi `/home` ikke rulles tilbake.

Når du kan logge inn igjen, fiks den lagrede kopien før du flytter den tilbake. `sh -n` fanger opp syntaksfeil uten å kjøre filen, men kan ikke fange opp alle feil som oppstår når den blir sourced. Hold en fungerende terminal åpen mens du tester endringer.

### Hvorfor vises ikke godkjenningsforespørslene fra 1Password for 1Password SSH Agent / CLI?

Dette kan skje av 2 grunner:

For at den avanserte godkjenningsforespørselen skal vises, må Settings > Advanced > Use Hardware Acceleration være slått på. _Merk: Dette krever en omstart for å begynne å fungere._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password siden du startet opp, vil forespørselen ikke vises.
