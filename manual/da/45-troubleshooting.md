# Fejlfinding

### Jeg ødelagde mit system med en opdatering!

Prøv først at [rulle dit system tilbage](47-system-snapshots.md) til versionen før din seneste opdatering. Hvis det ikke virker, så brug `omarchy-debug` til at dele dit problem på #omarchy-help på Discord. Og hvis alt andet fejler, kan du geninstallere standardkonfigurationerne og -pakkerne med `omarchy-reinstall`.

### Hvorfor er nogle apps så store på min skærm?

Omarchy forudsætter en 2x-skærm med høj opløsning, hvilket kræver, at `GDK_SCALE` sættes til 2 i `~/.config/hypr/monitors.lua`. Men hvis du har en 1x-skærm, kan du ændre `local omarchy_gdk_scale = 2` til 1 (og derefter genstarte alle apps, der er for store). Se [manualen om skærme](33-monitors.md).

Til Spotify kan du bruge `Ctrl + Minus` til at formindske brugerfladen (og `Ctrl + Plus` til at gøre den større).

### Hvorfor holdt alle mine Super-tastebindinger op med at virke?

På nogle ASUS ROG- og TUF-bærbare er `Fn + Super` en tastekombination, der er nem at overse, og som slår en Windows-tastlås i firmwaren til og fra (beregnet til gaming, så du ikke forlader et spil ved et uheld). Intet på skærmen fortæller dig, at det er sket. Mens låsen er slået til, udsender Super slet ingenting — så alle Omarchy-bindinger, der bruger Super, holder bare op med at virke, og det ser ud, som om Hyprland er gået i stykker.

Tryk på `Fn + Super` én gang, før du går i gang med `~/.config/hypr/`, og hvis det ikke får Super tilbage, så tryk på den igen, så du ikke efterlader låsen slået til. Dette er ikke Fn-lock, som kun ændrer, hvad F-tastrækken gør.

### Min Wi-Fi, Bluetooth, lyd eller trackpad holdt lige op med at virke

Før du genstarter, så prøv at genstarte det pågældende undersystem for sig selv. _Update > Hardware_ i Omarchy-menuen har Wi-Fi, Bluetooth, Audio og Trackpad, og genindlæsning af et af dem løser de fleste "det virkede for fem minutter siden"-situationer — et Bluetooth-headset, der ikke vil forbinde igen, en trackpad, der gik død efter dvale, lyd, der forsvandt, da du tog stikket til en skærm ud.

### Hvorfor spiller mine eksterne højttalere ikke?

Sandsynligvis fordi de ikke er indstillet som primær udgang. Klik på højttalerikonet i højre side af bjælken, så åbner den lydstyrke-popup, hvor du kan vælge outputenheden (og også mikse lydstyrken for hver enkelt app).

### Mine højttalere på den bærbare lyder underlige

På nogle bærbare anvender Omarchy automatisk en højttalertuning, der korrigerer de indbyggede højttaleres frekvensrespons. `omarchy audio tuning status` fortæller dig, om en er aktiv på din maskine, og `omarchy audio tuning off` slår den fra, hvis du hellere vil høre højttalerne råt.

### Hvorfor kan jeg ikke logge ind eller bruge sudo med min adgangskode?

Du har sandsynligvis indtastet den forkert for mange gange og er blevet låst ude. Hvis det sker på låseskærmen, kan du trykke på `CTRL + ALT + F2` for at starte en ny TTY, hvor du kan logge ind som root, og derefter køre `faillock --reset --user [your-username]`. Det nulstiller låsningen, og så er du klar igen.

### Hvorfor vises mine 1Password-godkendelsesprompter til 1Password SSH Agent / CLI ikke?

Det kan ske af 2 grunde:

For at den udvidede godkendelsesprompt kan vises, skal Settings > Advanced > Use Hardware Acceleration være slået til. _Bemærk: Dette kræver en genstart for at begynde at virke._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password, siden du startede op, vises prompten ikke.
