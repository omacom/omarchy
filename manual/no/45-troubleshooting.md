# Feilsøking

### Jeg ødela systemet mitt med en oppdatering!

Prøv først å [rulle tilbake systemet](47-system-snapshots.md) til versjonen før den siste oppdateringen din. Hvis det ikke fungerer, bruker du `omarchy-debug` til å dele problemet ditt på #omarchy-help i Discord. Og hvis alt det feiler, kan du installere standardkonfigurasjonene og -pakkene på nytt med `omarchy-reinstall`.

### Hvorfor er noen apper så store på skjermen min?

Omarchy forutsetter en 2x-skjerm med høy oppløsning, noe som krever at `GDK_SCALE` settes til 2 i `~/.config/hypr/monitors.lua`. Men hvis du har en 1x-skjerm, kan du endre `local omarchy_gdk_scale = 2` til 1 (og deretter starte en app som er for stor, på nytt). Se [håndboken om skjermer](33-monitors.md).

For Spotify kan du bruke `Ctrl + Minus` til å krympe brukergrensesnittet (og `Ctrl + Plus` til å gjøre det større).

### Hvorfor sluttet alle Super-tastebindingene mine å fungere?

På noen bærbare ASUS ROG- og TUF-maskiner er `Fn + Super` en tastekombinasjon som er lett å overse, og som slår av og på en fastvarelås for Windows-tasten (ment for spilling, så du ikke forlater et spill ved et uhell). Ingenting på skjermen forteller deg at det har skjedd. Mens låsen er på, sender Super ingenting i det hele tatt — så alle Omarchy-bindinger som bruker Super, slutter bare å fungere, og det ser ut som Hyprland gikk i stykker.

Trykk på `Fn + Super` én gang før du begynner å rote i `~/.config/hypr/`, og hvis det ikke får Super tilbake, trykker du én gang til så du ikke lar låsen stå på. Dette er ikke Fn-lock, som bare endrer hva F-tasteraden gjør.

### Wi-Fi, Bluetooth, lyd eller styreflaten min sluttet bare å fungere

Før du starter på nytt, prøver du å starte det trøblete delsystemet på nytt for seg selv. _Update > Hardware_ i Omarchy-menyen har Wi-Fi, Bluetooth, Audio og Trackpad, og å laste inn én av dem på nytt fikser de fleste «det fungerte for fem minutter siden»-situasjoner — et Bluetooth-headset som ikke vil koble til igjen, en styreflate som gikk død etter hvilemodus, lyd som forsvant da du koblet fra en skjerm.

### Hvorfor spiller ikke de eksterne høyttalerne mine?

Sannsynligvis fordi de ikke er satt som primærutgang. Klikk på høyttalerikonet på høyre side av linjen, så åpnes volumvinduet der du kan velge utgangsenhet (og mikse volumer per app også).

### Høyttalerne på den bærbare maskinen min høres feil ut

På noen bærbare maskiner bruker Omarchy automatisk en høyttalerjustering som korrigerer frekvensresponsen til de innebygde høyttalerne. `omarchy audio tuning status` forteller deg om en slik er aktiv på maskinen din, og `omarchy audio tuning off` slår den av hvis du heller vil høre høyttalerne ubehandlet.

### Hvorfor kan jeg ikke logge inn eller bruke sudo med passordet mitt?

Du skrev det sannsynligvis feil for mange ganger og ble låst ute. Hvis dette skjer på låseskjermen, kan du trykke på `CTRL + ALT + F2` for å starte en ny TTY der du kan logge inn som root, og deretter kjøre `faillock --reset --user [your-username]`. Det nullstiller utlåsingen, og så er du klar.

### Hvorfor vises ikke autoriseringsmeldingene fra 1Password for 1Password SSH Agent / CLI?

Dette kan skje av 2 grunner:

For at den fyldige godkjenningsmeldingen skal vises, må Settings > Advanced > Use Hardware Acceleration være slått på. _Merk: Dette krever en omstart for å begynne å fungere._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password siden du startet maskinen, vises ikke meldingen.
