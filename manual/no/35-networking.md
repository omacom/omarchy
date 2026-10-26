# Nettverk

Nettverk i Omarchy håndteres av NetworkManager, og du styrer det fra nettverksikonet i [topplinjen](05-the-top-bar.md) eller med `Super + Ctrl + N`.

Det panelet søker etter Wi-Fi-nettverk, viser signalstyrke og kobler til. Ethernet krever ingenting i det hele tatt — koble den til, så fungerer det. Hvis du heller vil bli i terminalen, gir `nmtui` deg de samme kontrollene, og det finnes også en kommandogruppe `omarchy network`.

## Dele Wi-Fi-et ditt

I stedet for å lese et langt passord høyt kan du kjøre _Setup > Network > QR Code_ mens du er på Wi-Fi. Da får du en QR-kode på skjermen som et hvilket som helst telefonkamera kan skanne for å bli med. Det er en av de tingene du kommer til å bruke mer enn du skulle tro når du først vet at den er der.

Hvis du faktisk trenger selve passordet, skriver `omarchy network password <interface>` det ut.

## DNS

Omarchy bruker den DNS-en nettverket ditt deler ut over DHCP. Du kan overstyre det for hele maskinen under _Setup > Network > DNS_, der Cloudflare og Google er ett klikk unna. Velg _Custom_ for å skrive inn dine egne servere.

Fra terminalen skriver `omarchy dns` ut gjeldende leverandør, og `omarchy dns Cloudflare` setter en.

## Låse Wi-Fi-båndet

Hvis ruteren din legger 2.4GHz, 5GHz og 6GHz på samme nettverksnavn, hender det at den bærbare datamaskinen din klamrer seg til det trege. `omarchy network band` viser hvilket bånd du er på, og `omarchy network band 5` låser det. Bruk `auto` for å la den velge igjen.

Dette låser båndet i stedet for et bestemt tilgangspunkt, så du fortsetter å roame normalt mellom AP-er.

## Hvor raskt er det?

_Trigger > Speed Test > Network Speed Test_ måler den faktiske hastigheten din opp og ned med et par målere. Fra terminalen er det `omarchy network speedtest down` eller `up`. (Det ligger en diskhastighetstest ved siden av den i den menyen, hvis du tester den andre flaskehalsen.)

## Brannmuren

Brannmuren er på som standard og blokkerer all innkommende trafikk, med ett unntak: port 53317, slik at [LocalSend](22-guis.md) fungerer rett ut av boksen.

SSH er av til du slår den på med _Setup > Security > SSHD_, som starter daemonen, åpner port 22 med hastighetsbegrensning mot brute force og autoriserer en nøkkel. Docker er også låst ned, slik at containere ikke ved et uhell kan eksponere seg for verden. Se [sikkerhet](48-security.md) for hele historien.

## Tailscale

[Tailscale](https://tailscale.com/) er et mesh-VPN som gjør det enkelt og sikkert å nå alle datamaskinene og serverne dine over internett. Installer det med _Install > Service > Tailscale_.

Da får du et Tailscale-panel i linjen, som kobler til og kobler fra tailnet, bytter kontoer og velger en exit node — både dine egne maskiner og Mullvad-regioner vises i listen. Det lar deg også bla gjennom maskinene dine, og det er der Taildrop bor: velg en maskin og trykk på `s` for å sende den filer, eller `c`, `n` og `d` for å kopiere IP-en, navnet eller det fullstendige DNS-navnet dens. Tilsvarende i terminalen er `omarchy tailscale send <machine> [file...]`, og filer som sendes til deg, havner automatisk i `~/Downloads`. Varslet som melder om en ankomst, venter til du klikker det åpent eller avviser det, slik at en fil som dukker opp mens du er borte fra maskinen, fortsatt er der å svare på når du kommer tilbake.

Når du installerer det, legges det også til en webapp for administrasjonskonsollen til Tailscale.

## Når det slutter å virke

Før du starter på nytt, prøv å starte den delen som krangler, på nytt for seg selv. _Update > Hardware_ har Wi-Fi, Bluetooth, Audio og Trackpad, og å laste en av dem inn på nytt fikser de fleste «det fungerte for fem minutter siden»-situasjoner. Se [feilsøking](45-troubleshooting.md).
