# Nettverk

Nettverk i Omarchy håndteres av NetworkManager, og du styrer det fra nettverksikonet i [topplinjen](05-the-top-bar.md) eller med `Super + Ctrl + N`.

Det panelet søker etter Wi-Fi-nettverk, viser signalstyrke og kobler til. Ethernet trenger ingenting i det hele tatt — plugg den inn, så virker det. Hvis du heller vil bli i terminalen, gir `nmtui` deg de samme kontrollene, og det finnes også en kommandogruppe `omarchy network`.

## Dele Wi-Fi-en din

I stedet for å lese opp et langt passord høyt, kjører du _Oppsett > Nettverk > QR-kode_ mens du er på Wi-Fi. Da får du en QR-kode på skjermen som ethvert telefonkamera kan skanne for å bli med. Det er en av de tingene du kommer til å bruke mer enn du skulle tro, når du først vet at den er der.

Hvis du faktisk trenger selve passordet, skriver `omarchy network password <interface>` det ut.

## DNS

Omarchy bruker den DNS-en nettverket ditt deler ut over DHCP. Du kan overstyre det for hele maskinen under _Oppsett > Nettverk > DNS_, der Cloudflare og Google er ett klikk unna. Velg _Egendefinert_ for å skrive inn dine egne servere.

Fra terminalen skriver `omarchy dns` ut gjeldende leverandør, og `omarchy dns Cloudflare` setter én.

## Låse Wi-Fi-båndet

Hvis ruteren din legger 2.4GHz, 5GHz og 6GHz på samme nettverksnavn, hender det at den bærbare klamrer seg til det trege. `omarchy network band` viser hvilket bånd du er på, og `omarchy network band 5` låser det. Bruk `auto` for å la den velge igjen.

Dette låser båndet fremfor et bestemt tilgangspunkt, så du fortsetter å roame mellom AP-er som normalt.

## Hvor raskt er det?

_Utløser > Hastighetstest > Nettverkshastighetstest_ måler den faktiske hastigheten din opp og ned med et par visere. Fra terminalen er det `omarchy network speedtest down` eller `up`. Den måler mot Omarchys egen tjeneste og teller bare sine egne testoverføringer. Andre nedlastinger kan konkurrere om båndbredden, men de legges ikke til i resultatet fra hastighetstesten. (Det ligger en diskhastighetstest ved siden av den i den menyen, hvis du måler den andre flaskehalsen.)

## Brannmuren

Brannmuren er på som standard og blokkerer all innkommende trafikk, med ett unntak: port 53317, slik at [LocalSend](22-guis.md) virker rett ut av boksen.

SSH er av til du slår det på med _Oppsett > Sikkerhet > SSHD_. Det starter daemonen, åpner port 22 med hastighetsbegrensning mot brute force og autoriserer en nøkkel. Docker er også låst ned, slik at containere ikke ved et uhell kan eksponere seg for verden. Se [sikkerhet](48-security.md) for hele historien.

## Tailscale

[Tailscale](https://tailscale.com/) er et mesh-VPN som gjør det enkelt og sikkert å nå alle datamaskinene og serverne dine over internett. Installer det med _Installer > Tjeneste > Tailscale_.

Det gir deg et Tailscale-panel i linjen. Der kobler du til og fra tailnet-et, bytter konto og velger en exit node — både dine egne maskiner og Mullvad-regioner dukker opp i listen. Der kan du også bla gjennom maskinene dine, og det er der Taildrop bor: velg en maskin og trykk `s` for å sende den filer, eller `c`, `n` og `d` for å kopiere IP-en, navnet eller det fulle DNS-navnet dens. Tilsvarende i terminalen er `omarchy tailscale send <machine> [file...]`, og filer som sendes til deg, lander automatisk i `~/Downloads`. Varslet som melder om en ankomst, venter til du klikker det åpent eller avviser det, slik at en fil som dukker opp mens du er borte fra maskinen, fortsatt er der å svare på når du kommer tilbake.

Når du installerer det, får du også en webapp for administrasjonskonsollen til Tailscale.

## Når det slutter å virke

Før du starter på nytt, prøv å starte den delen som krangler, på nytt for seg selv. _Oppdater > Maskinvare_ har Wi-Fi, Bluetooth, Audio og Trackpad, og å laste inn én av dem på nytt rydder opp i de fleste «det virket for fem minutter siden»-situasjoner. Se [feilsøking](45-troubleshooting.md).
