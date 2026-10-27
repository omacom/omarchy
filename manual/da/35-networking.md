# Netværk

Netværk i Omarchy håndteres af NetworkManager, og du styrer det fra netværksikonet i [den øverste bjælke](05-the-top-bar.md) eller med `Super + Ctrl + N`.

Det panel scanner efter Wi-Fi-netværk, viser signalstyrke og opretter forbindelse. Ethernet kræver slet ingenting — sæt det i, og det virker. Hvis du hellere vil blive i terminalen, giver `nmtui` dig de samme kontroller, og der findes også en kommandogruppe, `omarchy network`.

## Deling af dit Wi-Fi

I stedet for at læse en lang adgangskode højt skal du køre _Opsætning > Netværk > QR Code_, mens du er på Wi-Fi. Det viser en QR-kode på skærmen, som ethvert telefonkamera kan scanne for at komme på. Det er en af de ting, du kommer til at bruge mere, end du ville forvente, når først du ved, at den er der.

Hvis du faktisk har brug for selve adgangskoden, udskriver `omarchy network password <interface>` den.

## DNS

Omarchy bruger den DNS, dit netværk udleverer via DHCP. Du kan tilsidesætte det for hele maskinen under _Opsætning > Netværk > DNS_, hvor Cloudflare og Google er ét klik væk. Vælg _Custom_ for at indtaste dine egne servere.

Fra terminalen udskriver `omarchy dns` den aktuelle udbyder, og `omarchy dns Cloudflare` indstiller en.

## Fastlåsning af Wi-Fi-båndet

Hvis din router lægger 2.4GHz, 5GHz og 6GHz på det samme netværksnavn, vil din bærbare nogle gange klynge sig til det langsomme. `omarchy network band` viser, hvilket bånd du er på, og `omarchy network band 5` fastlåser det. Brug `auto` for at lade det vælge igen.

Det fastlåser båndet frem for et bestemt adgangspunkt, så du fortsat roamer normalt mellem AP'er.

## Hvor hurtigt er det?

_Udløser > Hastighedstest > Netværkshastighedstest_ måler din faktiske op- og nedhastighed med et par skiver. Fra terminalen er det `omarchy network speedtest down` eller `up`. Den måler mod Omarchys egen tjeneste og tæller kun dens testoverførsler. Andre downloads kan konkurrere om båndbredden, men de føjes ikke til hastighedstestresultatet. (Der ligger en diskhastighedstest ved siden af den i den menu, hvis du benchmarker den anden flaskehals.)

## Firewallen

Firewallen er slået til som standard og blokerer al indgående trafik med én undtagelse: port 53317, så [LocalSend](22-guis.md) virker lige ud af æsken.

SSH er slået fra, indtil du slår det til med _Opsætning > Sikkerhed > SSHD_, hvilket starter dæmonen, åbner port 22 med hastighedsbegrænsning mod brute force og godkender en nøgle. Docker er også låst ned, så containere ikke ved et uheld kan eksponere sig selv for verden. Se [sikkerhed](48-security.md) for hele historien.

## Tailscale

[Tailscale](https://tailscale.com/) er en mesh-VPN, der gør det enkelt og sikkert at nå alle dine computere og servere over internettet. Installér det med _Installér > Tjeneste > Tailscale_.

Det giver dig et Tailscale-panel i bjælken, som opretter og afbryder forbindelse til tailnettet, skifter konto og vælger en exit node — både dine egne maskiner og Mullvad-regioner vises på listen. Det gennemser også dine maskiner, og det er dér, Taildrop bor: vælg en maskine og tryk på `s` for at sende den filer, eller `c`, `n` og `d` for at kopiere dens IP, navn eller fulde DNS-navn. Det tilsvarende i terminalen er `omarchy tailscale send <machine> [file...]`, og filer, der sendes til dig, lander automatisk i `~/Downloads`. Notifikationen, der annoncerer en ankomst, venter, indtil du klikker den åben eller afviser den, så en fil, der dukker op, mens du er væk fra maskinen, stadig er der at svare på, når du kommer tilbage.

Installationen af det tilføjer også en webapp til Tailscale-administrationskonsollen.

## Når det holder op med at virke

Før du genstarter, så prøv at genstarte det fejlbehæftede stykke for sig selv. _Opdater > Hardware_ har Wi-Fi, Bluetooth, Audio og Trackpad, og en genindlæsning af en af dem rydder op i de fleste "det virkede for fem minutter siden"-situationer. Se [fejlfinding](45-troubleshooting.md).
