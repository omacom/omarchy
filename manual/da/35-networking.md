# Netværk

Netværk i Omarchy håndteres af NetworkManager, og du styrer det fra netværksikonet i [topbjælken](05-the-top-bar.md) eller med `Super + Ctrl + N`.

Det panel scanner efter Wi-Fi-netværk, viser signalstyrke og opretter forbindelse. Ethernet behøver slet ingenting — sæt stikket i, og det virker. Hvis du hellere vil blive i terminalen, giver `nmtui` dig de samme kontroller, og der findes også en `omarchy network`-kommandogruppe.

## Deling af dit Wi-Fi

I stedet for at læse en lang adgangskode højt kan du køre _Setup > Network > QR Code_, mens du er på Wi-Fi. Det sætter en QR-kode på skærmen, som ethvert telefonkamera kan scanne for at komme på. Det er en af de ting, du vil bruge mere, end du skulle tro, når først du ved, at den er der.

Hvis du faktisk har brug for selve adgangskoden, udskriver `omarchy network password <interface>` den.

## DNS

Omarchy bruger den DNS, dit netværk uddeler over DHCP. Du kan tilsidesætte det for hele maskinen under _Setup > Network > DNS_, hvor Cloudflare og Google er ét klik væk. Vælg _Custom_ for at indtaste dine egne servere.

Fra terminalen udskriver `omarchy dns` den aktuelle udbyder, og `omarchy dns Cloudflare` indstiller en.

## Låsning af Wi-Fi-båndet

Hvis din router lægger 2.4GHz, 5GHz og 6GHz på det samme netværksnavn, vil din bærbare nogle gange klamre sig til det langsomme. `omarchy network band` viser, hvilket bånd du er på, og `omarchy network band 5` låser det fast. Brug `auto` for at lade det vælge igen.

Det låser båndet fast i stedet for et bestemt adgangspunkt, så du fortsat roamer normalt mellem AP'er.

## Hvor hurtigt er det?

_Trigger > Speed Test > Network Speed Test_ måler din faktiske op- og nedhastighed med et par visere. Fra terminalen er det `omarchy network speedtest down` eller `up`. (Der sidder en diskhastighedstest ved siden af den i den menu, hvis du benchmarker den anden flaskehals.)

## Firewallen

Firewallen er slået til som standard og blokerer al indgående trafik med én undtagelse: port 53317, så [LocalSend](22-guis.md) virker lige ud af boksen.

SSH er slået fra, indtil du slår det til med _Setup > Security > SSHD_, som starter daemonen, åbner port 22 med hastighedsbegrænsning mod brute force og autoriserer en nøgle. Docker er også låst ned, så containere ikke ved et uheld kan blotlægge sig selv for verden. Se [sikkerhed](48-security.md) for hele historien.

## Tailscale

[Tailscale](https://tailscale.com/) er en mesh-VPN, der gør det enkelt og sikkert at nå alle dine computere og servere over internettet. Installer den med _Install > Service > Tailscale_.

Det giver dig et Tailscale-panel i bjælken, som opretter og afbryder forbindelsen til tailnet, skifter konto og vælger en exit node — både dine egne maskiner og Mullvad-regioner vises på listen. Det gennemser også dine maskiner, og det er dér, Taildrop bor: vælg en maskine, og tryk på `s` for at sende den filer, eller `c`, `n` og `d` for at kopiere dens IP, navn eller fulde DNS-navn. Tilsvarende i terminalen er `omarchy tailscale send <machine> [file...]`, og filer sendt til dig lander automatisk i `~/Downloads`. Notifikationen, der annoncerer en ankomst, venter, indtil du klikker den åben eller afviser den, så en fil, der dukker op, mens du er væk fra maskinen, stadig er der til at svare på, når du kommer tilbage.

Installationen tilføjer også en webapp til Tailscale-administrationskonsollen.

## Når det holder op med at virke

Før du genstarter, så prøv at genstarte den skyldige del for sig selv. _Update > Hardware_ har Wi-Fi, Bluetooth, Audio og Trackpad, og en genindlæsning af en af dem klarer de fleste "det virkede for fem minutter siden"-situationer. Se [fejlfinding](45-troubleshooting.md).
