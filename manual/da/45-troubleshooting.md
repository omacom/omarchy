# Fejlfinding

### Jeg ødelagde mit system med en opdatering!

Prøv først at [rulle dit system tilbage](47-system-snapshots.md) til versionen før din seneste opdatering. Hvis det ikke virker, så brug `omarchy-debug` til at dele dit problem på #omarchy-help i Discord. Og hvis alt det slår fejl, kan du geninstallere standardkonfigurationerne og -pakkerne ved hjælp af `omarchy-reinstall`.

### Hvorfor er nogle apps så store på min skærm?

Omarchy går ud fra en skærm med 2x høj opløsning, så den sætter `GDK_SCALE` til 2, indtil du vælger en skalering i monitorpanelet. Hvis du bruger en 1x-skærm, og GTK- eller X11-apps bliver for store, så vælg 1x til den i monitorpanelet, eller tilføj `hl.env("GDK_SCALE", "1")` til `~/.config/hypr/monitors.lua` (og genstart derefter alle apps, der er for store). Se [manualen om monitorer](33-monitors.md).

Til Spotify kan du bruge `Ctrl + Minus` til at gøre brugergrænsefladen mindre (og `Ctrl + Plus` til at gøre den større).

### Hvorfor holdt alle mine Super-tastaturgenveje op med at virke?

På nogle ASUS ROG- og TUF-laptops er `Fn + Super` en akkord, der er nem at overse, og som slår en firmwarelås til Windows-tasten til og fra (beregnet til gaming, så du ikke forlader et spil ved et uheld). Intet på skærmen fortæller dig, at det er sket. Mens låsen er slået til, udsender Super slet ingenting — så alle Omarchy-genveje, der bruger Super, holder bare op med at virke, og det ser ud, som om Hyprland er gået i stykker.

Tryk på `Fn + Super` én gang, før du går i gang med at grave i `~/.config/hypr/`, og hvis det ikke får Super tilbage, så tryk på den igen, så du ikke efterlader låsen slået til. Dette er ikke Fn-lock, som kun ændrer, hvad F-tastrækken gør.

### Min Wi-Fi, Bluetooth, lyd eller trackpad holdt lige pludselig op med at virke

Før du genstarter, så prøv at genstarte det pågældende undersystem for sig selv. _Update > Hardware_ i Omarchy-menuen har Wi-Fi, Bluetooth, Audio og Trackpad, og at genindlæse en af dem klarer de fleste "det virkede for fem minutter siden"-situationer — et Bluetooth-headset, der ikke vil oprette forbindelse igen, en trackpad, der gik død efter en dvaletilstand, lyd, der forsvandt, da du frakoblede en monitor.

### Hvorfor spiller mine eksterne højttalere ikke?

Sandsynligvis fordi de ikke er indstillet som den primære outputenhed. Klik på højttalerikonet i højre side af baren, så åbnes lydstyrke-popup'en, hvor du kan vælge outputenheden (og også mikse lydstyrken pr. app).

### Mine laptop-højttalere lyder forkert

På nogle laptops anvender Omarchy automatisk en højttalerjustering, der korrigerer de indbyggede højttaleres frekvensrespons. `omarchy audio tuning status` fortæller dig, om en sådan er aktiv på din maskine, og `omarchy audio tuning off` slår den fra, hvis du hellere vil høre højttalerne rå.

### Hvorfor kan jeg ikke logge ind eller bruge sudo med min adgangskode?

Du har sandsynligvis tastet den forkert ti gange og er blevet låst ude. Udelåsningen ophæves af sig selv efter to minutter. Hvis du ikke kan vente, og dette sker på låseskærmen, kan du trykke på `CTRL + ALT + F2` for at starte en ny TTY, hvor du kan logge ind som root, og derefter køre `faillock --reset --user [your-username]`. Det nulstiller udelåsningen, og så er du klar igen.

### Min adgangskode accepteres, men jeg vender tilbage til loginskærmen

En ødelagt sessionsmiljøfil kan forhindre skrivebordet i at starte, selv når din adgangskode er korrekt. Det er især værd at tjekke efter redigering af `~/.config/uwsm/env.d/`.

Tryk på `Ctrl + Alt + F2`, log ind med dit normale brugernavn og din adgangskode, og undersøg brugerjournalen for den aktuelle opstart:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Kig efter en fejl, der nævner en af dine miljøfiler, såsom `bad substitution`, lige før en meddelelse om, at env-outputmarkeringen ikke blev fundet. Flyt den fil ud af `env.d`, før du prøver at logge ind igen. Hvis fejlen for eksempel nævner `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM springer en fil med en syntaksfejl over, men en fatal fejl, der først viser sig, mens filen kører, som `bad substitution`, kan stadig forhindre skrivebordet i at starte. En rollback til et systemsnapshot reparerer ikke disse filer, fordi `/home` ikke rulles tilbage.

Når du kan logge ind, skal du rette den gemte kopi, før du flytter den tilbage. `sh -n` fanger syntaksfejl uden at køre filen, men kan ikke fange alle fejl, der opstår, når den sources. Hold en fungerende terminal åben, mens du tester ændringer.

### Hvorfor vises mine 1Password-autorisationsmeddelelser til 1Password SSH Agent / CLI ikke?

Der kan være 2 årsager til dette:

For at den udvidede godkendelsesmeddelelse kan vises, skal Settings > Advanced > Use Hardware Acceleration være slået til. _Bemærk: Dette kræver en genstart, før det begynder at virke._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password, siden du startede op, vises meddelelsen ikke.
