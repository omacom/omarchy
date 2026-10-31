# Feilsøking

### Jeg ødela systemet mitt med en oppdatering!

Prøv først å [rulle tilbake systemet ditt](47-system-snapshots.md) til versjonen før den siste oppdateringen. Hvis det ikke fungerer, bruker du `omarchy-debug` til å dele problemet ditt på #omarchy-help i Discord. Og hvis alt annet feiler, kan du installere standardkonfigurasjonene og -pakkene på nytt med `omarchy-reinstall`.

### Hvorfor er noen apper så store på skjermen min?

Omarchy forutsetter en høyoppløselig skjerm med 2x, så den setter `GDK_SCALE` til 2 helt til du velger en skalering i skjermpanelet. Hvis du bruker en 1x-skjerm og GTK- eller X11-apper blir altfor store, velger du 1x for den i skjermpanelet, eller legger til `hl.env("GDK_SCALE", "1")` i `~/.config/hypr/monitors.lua` (og starter deretter alle apper som er for store på nytt). Se [håndboken om skjermer](33-monitors.md).

For Spotify kan du bruke `Ctrl + Minus` til å krympe brukergrensesnittet (og `Ctrl + Plus` til å gjøre det større).

### Hvorfor sluttet alle Super-tastebindingene mine å fungere?

På noen bærbare PC-er fra ASUS ROG og TUF er `Fn + Super` en kombinasjon som er lett å overse, og som slår av og på en fastvarelås for Windows-tasten (laget for spilling, så du ikke forlater et spill ved et uhell). Ingenting på skjermen forteller deg at det har skjedd. Mens låsen er på, sender Super ikke ut noe i det hele tatt — så alle Omarchy-bindinger som bruker Super, slutter bare å fungere, og det ser ut som om Hyprland er ødelagt.

Trykk på `Fn + Super` én gang før du begynner å grave i `~/.config/hypr/`, og hvis det ikke får Super tilbake, trykker du én gang til så du ikke lar låsen stå på. Dette er ikke Fn-lås, som bare endrer hva F-tasteraden gjør.

### Wi-Fi, Bluetooth, lyd eller styreflaten min sluttet bare å fungere

Før du starter på nytt, kan du prøve å starte det aktuelle delsystemet på nytt for seg selv. _Update > Hardware_ i Omarchy-menyen har Wi-Fi, Bluetooth, Audio og Trackpad, og å laste inn ett av dem på nytt løser de fleste «det fungerte for fem minutter siden»-situasjonene — et Bluetooth-hodesett som ikke vil koble til igjen, en styreflate som sluttet å fungere etter hvilemodus, lyd som forsvant da du koblet fra en skjerm.

### Hvorfor spiller ikke de eksterne høyttalerne mine?

Sannsynligvis fordi de ikke er satt som primærutgang. Klikk på høyttalerikonet på høyre side av linjen, så åpnes lydvinduet der du kan velge utgangsenhet (og også mikse lydstyrken per app).

### Høyttalerne på den bærbare PC-en min høres feil ut

På noen bærbare PC-er bruker Omarchy automatisk en høyttalerjustering som korrigerer frekvensresponsen til de innebygde høyttalerne. `omarchy audio tuning status` forteller deg om en justering er aktiv på maskinen din, og `omarchy audio tuning off` slår den av hvis du heller vil høre høyttalerne ubehandlet.

### Hvorfor kan jeg ikke logge inn eller bruke sudo med passordet mitt?

Du har sannsynligvis skrevet det feil for mange ganger og blitt låst ute. Hvis dette skjer på låseskjermen, kan du trykke `CTRL + ALT + F2` for å starte en ny TTY der du kan logge inn som root, og deretter kjøre `faillock --reset --user [your-username]`. Det tilbakestiller låsen, og så er du klar.

### Hvorfor vises ikke godkjenningsforespørslene fra 1Password for 1Password SSH Agent / CLI?

Dette kan skje av 2 grunner:

For at den avanserte godkjenningsforespørselen skal vises, må Settings > Advanced > Use Hardware Acceleration være slått på. _Merk: Dette krever en omstart for å begynne å fungere._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password siden du startet maskinen, vil ikke forespørselen vises.
