# Fejlfinding

### Jeg ødelagde mit system med en opdatering!

Prøv først at [rulle dit system tilbage](47-system-snapshots.md) til versionen før din seneste opdatering. Hvis det ikke virker, så brug `omarchy-debug` til at dele dit problem på #omarchy-help i Discorden. Og hvis alt det fejler, kan du geninstallere standardkonfigurationerne og pakkerne ved hjælp af `omarchy-reinstall`.

### Hvorfor er nogle apps så store på mit display?

Omarchy antager et 2x højopløsningsdisplay, hvilket kræver, at `GDK_SCALE` sættes til 2 i `~/.config/hypr/monitors.lua`. Men hvis du er på et 1x-display, kan du ændre `local omarchy_gdk_scale = 2` til 1 (og derefter genstarte enhver app, der er for stor). Se [manualen om skærme](33-monitors.md).

Til Spotify kan du bruge `Ctrl + Minus` til at skrumpe UI'et (og `Ctrl + Plus` til at gøre det større).

### Mit Wi-Fi, Bluetooth, lyd eller pegefelt holdt bare op med at virke

Før du genstarter, så prøv at genstarte det fejlende undersystem for sig selv. _Opdater > Hardware_ i Omarchy-menuen har Wi-Fi, Bluetooth, Lyd og Pegefelt, og at genindlæse en af dem rydder op i størstedelen af “det virkede for fem minutter siden”-situationer — et Bluetooth-headset, der ikke vil genoprette forbindelsen, et pegefelt, der gik dødt efter en hvile, lyd, der forsvandt, da du trak en skærm ud.

### Hvorfor spiller mine eksterne højttalere ikke?

Sandsynligvis fordi de ikke er sat som det primære output. Klik på højttalerikonet i højre side af linjen, og det åbner volumen-popup'en, hvor du kan vælge outputenheden (og også mikse volumener pr. app).

### Mine bærbare højttalere lyder forkert

På nogle bærbare anvender Omarchy automatisk en højttalertuning, der korrigerer de indbyggede højttaleres frekvensrespons. `omarchy audio tuning status` fortæller dig, om en er aktiv på din maskine, og `omarchy audio tuning off` slukker den, hvis du hellere vil høre højttalerne råt.

### Hvorfor kan jeg ikke logge ind eller sudo med min adgangskode?

Du har sikkert tastet den forkert for mange gange og er blevet låst ude. Hvis det sker på låseskærmen, kan du trykke `CTRL + ALT + F2` for at starte en ny TTY, hvor du kan logge ind som root og derefter køre `faillock --reset --user [your-username]`. Det nulstiller udelåsningen, og så er du klar.

### Hvorfor vises mine 1Password-autorisationsprompter til 1Password SSH Agent / CLI ikke?

Det kan ske af 2 grunde:

For at den rige godkendelsesprompt skal vises, skal Indstillinger > Avanceret > Brug hardwareacceleration være slået til. _Bemærk: Dette kræver en genstart for at begynde at virke._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Eller hvis du ikke har startet 1Password siden opstart, vil prompten ikke vises.
