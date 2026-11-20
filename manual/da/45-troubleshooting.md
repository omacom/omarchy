# Fejlfinding

### Jeg har ødelagt mit system med en opdatering!

Prøv først at [rulle dit system tilbage](47-system-snapshots.md) til versionen før din seneste opdatering. Hvis det ikke virker, så brug `omarchy-debug` til at dele dit problem i #omarchy-help på Discord. Og hvis alt det fejler, kan du geninstallere standardkonfigurationerne og -pakkerne med `omarchy-reinstall`.

### Hvorfor er nogle apps så store på min skærm?

Omarchy antager, at du har en skærm med 2x høj opløsning, så det sætter `GDK_SCALE` til 2, indtil du vælger en skalering i skærmpanelet. Hvis du bruger en 1x-skærm, og GTK- eller X11-apps bliver for store, så vælg 1x til den i skærmpanelet, eller tilføj `hl.env("GDK_SCALE", "1")` til `~/.config/hypr/monitors.lua` (og genstart derefter enhver app, der er for stor). Se [manualen om skærme](33-monitors.md).

Til Spotify kan du bruge `Ctrl + Minus` til at formindske brugerfladen (og `Ctrl + Plus` til at gøre den større).

### Hvorfor holdt alle mine Super-tastaturgenveje op med at virke?

På nogle ASUS ROG- og TUF-bærbare er `Fn + Super` en akkord, der er nem at overse, og som slår en firmwarelås til Windows-tasten til og fra (beregnet til gaming, så du ikke forlader et spil ved et uheld). Intet på skærmen fortæller dig, at det er sket. Mens låsen er slået til, udsender Super slet ingenting — så alle Omarchy-genveje, der bruger Super, holder bare op med at virke, og det ser ud, som om Hyprland er gået i stykker.

Tryk på `Fn + Super` én gang, før du begynder at rode i `~/.config/hypr/`, og hvis det ikke bringer Super tilbage, så tryk på den igen, så du ikke efterlader låsen slået til. Det er ikke Fn-lock, som kun ændrer, hvad F-tast-rækken gør.

### Min Wi-Fi, Bluetooth, lyd eller trackpad holdt bare op med at virke

Før du genstarter, så prøv at genstarte det fejlbehæftede undersystem for sig selv. _Update > Hardware_ i Omarchy-menuen har Wi-Fi, Bluetooth, Audio og Trackpad, og at genindlæse en af dem løser langt de fleste situationer af typen "det virkede for fem minutter siden" — et Bluetooth-headset, der ikke vil oprette forbindelse igen, et trackpad, der gik død efter dvale, lyd, der forsvandt, da du frakoblede en skærm.

### Hvorfor spiller mine eksterne højttalere ikke?

Sandsynligvis fordi de ikke er indstillet som den primære udgang. Klik på højttalerikonet i højre side af bjælken, så åbner den lydstyrke-popup, hvor du kan vælge udgangsenheden (og også mikse lydstyrken pr. app).

### Mine bærbare højttalere lyder forkert

På nogle bærbare anvender Omarchy automatisk en højttalertuning, der korrigerer de indbyggede højttaleres frekvensrespons. `omarchy audio tuning status` fortæller dig, om en er aktiv på din maskine, og `omarchy audio tuning off` slår den fra, hvis du hellere vil høre højttalerne råt.

### Hvorfor kan jeg ikke logge ind eller bruge sudo med min adgangskode?

Du har sandsynligvis indtastet den forkert for mange gange og er blevet låst ude. Hvis det sker på låseskærmen, kan du trykke på `CTRL + ALT + F2` for at starte en ny TTY, hvor du kan logge ind som root, og derefter køre `faillock --reset --user [your-username]`. Det nulstiller lockout'en, og så er du klar igen.

### Min adgangskode accepteres, men jeg vender tilbage til loginskærmen

En ødelagt sessionsmiljøfil kan forhindre skrivebordet i at starte, selv når din adgangskode er korrekt. Det er især værd at tjekke, efter du har redigeret `~/.config/uwsm/env.d/`.

Tryk på `Ctrl + Alt + F2`, log ind med dit normale brugernavn og din normale adgangskode, og inspicér den aktuelle boots brugerjournal:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Se efter en fejl, der navngiver en af dine miljøfiler, såsom `bad substitution`, lige før en besked om, at env output mark ikke blev fundet. Flyt den fil ud af `env.d`, før du prøver at logge ind igen. Hvis fejlen f.eks. navngiver `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM springer en fil med en syntaksfejl over, men en fatal fejl, der først viser sig, mens filen kører, som `bad substitution`, kan stadig forhindre skrivebordet i at starte. En rollback til et system-snapshot reparerer ikke disse filer, fordi `/home` ikke rulles tilbage.

Når du kan logge ind, så ret den gemte kopi, før du flytter den tilbage. `sh -n` fanger syntaksfejl uden at køre filen, men kan ikke fange alle fejl, der opstår, når den sources. Hold en fungerende terminal åben, mens du tester ændringer.

### Hvorfor vises mine 1Password-godkendelsesprompter til 1Password SSH Agent / CLI ikke?

Det kan ske af 2 grunde:

For at den avancerede godkendelsesprompt kan vises, skal Settings > Advanced > Use Hardware Acceleration være slået til. _Bemærk: Dette kræver en genstart for at begynde at virke._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password siden opstart, vises prompten ikke.
