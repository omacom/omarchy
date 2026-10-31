# Fejlfinding

### Jeg ødelagde mit system med en opdatering!

Prøv først at [rulle dit system tilbage](47-system-snapshots.md) til versionen før din seneste opdatering. Hvis det ikke virker, så brug `omarchy-debug` til at dele dit problem på #omarchy-help i Discord. Og hvis alt det slår fejl, kan du geninstallere standardkonfigurationerne og -pakkerne med `omarchy-reinstall`.

### Hvorfor er nogle apps så store på min skærm?

Omarchy antager en 2x-skærm med høj opløsning, så den sætter `GDK_SCALE` til 2, indtil du vælger en skalering i skærmpanelet. Hvis du er på en 1x-skærm, og GTK- eller X11-apps bliver for store, så vælg 1x til den i skærmpanelet, eller tilføj `hl.env("GDK_SCALE", "1")` til `~/.config/hypr/monitors.lua` (og genstart derefter enhver app, der er for stor). Se [manualen om skærme](33-monitors.md).

Til Spotify kan du bruge `Ctrl + Minus` til at formindske brugerfladen (og `Ctrl + Plus` til at gøre den større).

### Hvorfor holdt alle mine Super-tastebindinger op med at virke?

På nogle ASUS ROG- og TUF-bærbare er `Fn + Super` en akkord, der er nem at overse, og som slår en Windows-tastlås i firmwaren til og fra (beregnet til gaming, så du ikke forlader et spil ved et uheld). Intet på skærmen fortæller dig, at det er sket. Mens låsen er slået til, udsender Super slet ingenting — så holder enhver Omarchy-binding, der bruger Super, bare op med at virke, og det ser ud, som om Hyprland er gået i stykker.

Tryk på `Fn + Super` én gang, før du graver dig ned i `~/.config/hypr/`, og hvis det ikke bringer Super tilbage, så tryk på den igen, så du ikke efterlader låsen slået til. Det er ikke Fn-lock, som kun ændrer, hvad F-tastrækken gør.

### Min Wi-Fi, Bluetooth, lyd eller trackpad holdt bare op med at virke

Før du genstarter, så prøv at genstarte det fejlramte undersystem for sig selv. _Update > Hardware_ i Omarchy-menuen har Wi-Fi, Bluetooth, Audio og Trackpad, og at genindlæse en af dem rydder op i de fleste "det virkede for fem minutter siden"-situationer — et Bluetooth-headset, der ikke vil genoprette forbindelsen, en trackpad, der gik død efter en dvale, lyd, der forsvandt, da du frakoblede en skærm.

### Hvorfor spiller mine eksterne højttalere ikke?

Sandsynligvis fordi de ikke er indstillet som den primære udgang. Klik på højttalerikonet i højre side af bjælken, så åbner den lydstyrke-popup, hvor du kan vælge udgangsenheden (og også justere lydstyrken for hver enkelt app).

### Mine højttalere på den bærbare lyder ikke rigtigt

På nogle bærbare anvender Omarchy automatisk en højttalerjustering, der korrigerer de indbyggede højttaleres frekvensrespons. `omarchy audio tuning status` fortæller dig, om en er aktiv på din maskine, og `omarchy audio tuning off` slår den fra, hvis du hellere vil høre højttalerne råt.

### Hvorfor kan jeg ikke logge ind eller bruge sudo med min adgangskode?

Du har sandsynligvis indtastet den forkert for mange gange og er blevet låst ude. Hvis det sker på låseskærmen, kan du trykke på `CTRL + ALT + F2` for at starte en ny TTY, hvor du kan logge ind som root, og derefter køre `faillock --reset --user [your-username]`. Det nulstiller låsningen, og så er du klar igen.

### Hvorfor vises mine prompter til 1Password-godkendelse for 1Password SSH Agent / CLI ikke?

Det kan ske af 2 grunde:

For at den udvidede godkendelsesprompt kan vises, skal Settings > Advanced > Use Hardware Acceleration være slået til. _Bemærk: Dette kræver en genstart for at begynde at virke._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password, siden du startede op, vises prompten ikke.
