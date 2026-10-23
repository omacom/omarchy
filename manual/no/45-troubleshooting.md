# Feilsøking

### Jeg ødela systemet mitt med en oppdatering!

Prøv først å [rulle tilbake systemet](47-system-snapshots.md) til versjonen før den siste oppdateringen. Hvis det ikke fungerer, bruk `omarchy-debug` til å dele problemet ditt på #omarchy-help på Discorden. Og hvis alt det feiler, kan du installere standardkonfigurasjonene og -pakkene på nytt med `omarchy-reinstall`.

### Hvorfor er noen apper så store på skjermen min?

Omarchy antar en 2x høyoppløselig skjerm, som krever at `GDK_SCALE` settes til 2 i `~/.config/hypr/monitors.lua`. Men hvis du er på en 1x-skjerm, kan du endre `local omarchy_gdk_scale = 2` til 1 (og deretter starte enhver app som er for stor på nytt). Se [manualen om skjermer](33-monitors.md).

For Spotify kan du bruke `Ctrl + Minus` for å krympe brukergrensesnittet (og `Ctrl + Plus` for å gjøre det større).

### Wi-Fi-en, Bluetooth-en, lyden eller styreflaten min sluttet bare å fungere

Før du starter på nytt, prøv å starte det skyldige delsystemet på nytt for seg selv. _Oppdater > Maskinvare_ i Omarchy-menyen har Wi-Fi, Bluetooth, Lyd og Styreflate, og å laste én av dem på nytt rydder opp i flertallet av «det fungerte for fem minutter siden»-situasjoner — et Bluetooth-headsett som ikke vil koble til igjen, en styreflate som ble død etter en hvile, lyd som forsvant da du koblet fra en skjerm.

### Hvorfor spiller ikke de eksterne høyttalerne mine?

Sannsynligvis fordi de ikke er satt som primær utgang. Klikk på høyttalerikonet på høyre side av linjen, så åpner det volum-popupen der du kan velge utdataenheten (og mikse volum per app også).

### Høyttalerne på den bærbare høres feil ut

På noen bærbare bruker Omarchy automatisk en høyttalerstemme som korrigerer frekvensresponsen til de innebygde høyttalerne. `omarchy audio tuning status` forteller deg om én er aktiv på maskinen din, og `omarchy audio tuning off` slår den av hvis du heller vil høre høyttalerne rå.

### Hvorfor kan jeg ikke logge inn eller sudo med passordet mitt?

Du skrev det sannsynligvis feil for mange ganger og ble låst ute. Hvis dette skjer på låseskjermen, kan du trykke `CTRL + ALT + F2` for å starte en ny TTY der du kan logge inn som root, og deretter kjøre `faillock --reset --user [your-username]`. Det nullstiller utestengelsen, og du er klar.

### Hvorfor vises ikke 1Password-autorisasjonsforespørslene mine for 1Password SSH Agent / CLI?

Dette kan skje av 2 grunner:

For at den rike godkjenningsforespørselen skal vises, må Settings > Advanced > Use Hardware Acceleration være slått på. _Merk: Dette krever en omstart for å begynne å fungere._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password siden du startet opp, vil ikke forespørselen vises.
