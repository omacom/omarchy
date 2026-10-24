# Nettverk

Nettverket i Omarchy håndteres av NetworkManager, og du styrer det fra nettverksikonet i [menylinjen](05-the-top-bar.md) eller med `Super + Ctrl + W`.

Det panelet skanner etter Wi-Fi-nettverk, viser signalstyrke og kobler til. Ethernet krever ingenting i det hele tatt — plugg det inn, så fungerer det. Hvis du heller vil bli i terminalen, gir `nmtui` deg de samme kontrollene, og det finnes også en `omarchy network`-kommandogruppe.

## Dele Wi-Fi-en din

I stedet for å lese et langt passord høyt, kjør _Oppsett > Nettverk > QR-kode_ mens du er på Wi-Fi. Det setter en QR-kode på skjermen som ethvert telefonkamera kan skanne for å bli med. Det er en av de tingene du kommer til å bruke mer enn du skulle tro, når du først vet at den er der.

Hvis du faktisk trenger selve passordet, skriver `omarchy network password <interface>` det ut.

## DNS

Omarchy bruker den DNS-en nettverket ditt deler ut via DHCP. Du kan overstyre det for hele maskinen under _Oppsett > Nettverk > DNS_, der Cloudflare og Google er ett klikk unna. Velg _Egendefinert_ for å skrive inn dine egne servere.

Fra terminalen skriver `omarchy dns` ut gjeldende leverandør, og `omarchy dns Cloudflare` setter én.

## Feste Wi-Fi-båndet

Hvis ruteren din legger 2.4GHz, 5GHz og 6GHz på samme nettverksnavn, vil den bærbare noen ganger klamre seg til det trege. `omarchy network band` viser hvilket bånd du er på, og `omarchy network band 5` fester det. Bruk `auto` for å la den velge igjen.

Dette fester båndet i stedet for et bestemt aksesspunkt, så du fortsetter å roame mellom AP-er som normalt.

## Hvor raskt er det?

_Utløs > Hastighetstest > Nettverkshastighetstest_ måler den faktiske opp- og nedhastigheten din med et par visere. Fra terminalen er det `omarchy network speedtest down` eller `up`. (Det sitter en diskhastighetstest ved siden av i den menyen, hvis du benchmarker den andre flaskehalsen.)

## Brannmuren

Brannmuren er på som standard og blokkerer all innkommende trafikk, med ett unntak: port 53317, slik at [LocalSend](22-guis.md) fungerer rett ut av boksen.

SSH er av til du slår det på med _Oppsett > Sikkerhet > SSHD_, som starter daemonen, åpner port 22 med hastighetsbegrensning mot brute force og godkjenner en nøkkel. Docker er også låst ned, slik at containere ikke ved et uhell kan eksponere seg for verden. Se [sikkerhet](48-security.md) for hele historien.

## Tailscale

[Tailscale](https://tailscale.com/) er et mesh-VPN som gjør det enkelt og sikkert å nå alle datamaskinene og serverne dine over internett. Installer det med _Installer > Tjeneste > Tailscale_.

Det gir deg et Tailscale-panel i linjen, som kobler til og fra tailnet-et, bytter konto og velger en exit node — både dine egne maskiner og Mullvad-regioner dukker opp i listen. Det blar også i maskinene dine, og det er der Taildrop bor: velg en maskin og trykk `s` for å sende den filer, eller `c`, `n` og `d` for å kopiere IP-en, navnet eller det fulle DNS-navnet. Tilsvarende i terminalen er `omarchy tailscale send <machine> [file...]`, og filer som sendes til deg, lander automatisk i `~/Downloads`. Varslet som kunngjør en ankomst, venter til du klikker det åpent eller avviser det, så en fil som dukker opp mens du er borte fra maskinen, fortsatt er der å svare på når du kommer tilbake.

Når du installerer det, får du også en nettapp for Tailscale-administrasjonskonsollen.

## Når det slutter å fungere

Før du starter på nytt, prøv å starte den skyldige delen på nytt for seg selv. _Oppdater > Maskinvare_ har Wi-Fi, Bluetooth, Lyd og Styreflate, og å laste én av dem på nytt rydder opp i de fleste «det fungerte for fem minutter siden»-situasjoner. Se [feilsøking](45-troubleshooting.md).
