# Netværk

Netværk i Omarchy håndteres af NetworkManager, og du styrer det fra netværksikonet i [menulinjen](05-the-top-bar.md) eller med `Super + Ctrl + W`.

Det panel scanner efter Wi-Fi-netværk, viser signalstyrke og opretter forbindelse. Ethernet kræver slet ingenting — sæt kablet i, så virker det. Hvis du hellere vil blive i terminalen, giver `nmtui` dig de samme kontroller, og der er også en `omarchy network`-kommandogruppe.

## Del dit Wi-Fi

I stedet for at læse en lang adgangskode højt kan du køre _Opsætning > Netværk > QR-kode_, mens du er på Wi-Fi. Det sætter en QR-kode på skærmen, som ethvert telefonkamera kan scanne for at komme på. Det er en af de ting, du kommer til at bruge mere, end du tror, når først du ved, at den er der.

Hvis du rent faktisk har brug for selve adgangskoden, udskriver `omarchy network password <interface>` den.

## DNS

Omarchy bruger den DNS, dit netværk uddeler via DHCP. Du kan tilsidesætte det for hele maskinen under _Opsætning > Netværk > DNS_, hvor Cloudflare og Google er ét klik væk. Vælg _Brugerdefineret_ for at indtaste dine egne servere.

Fra terminalen udskriver `omarchy dns` den aktuelle udbyder, og `omarchy dns Cloudflare` sætter en.

## Fastlåsning af Wi-Fi-båndet

Hvis din router lægger 2.4GHz, 5GHz og 6GHz på samme netværksnavn, vil din bærbare nogle gange klamre sig til det langsomme. `omarchy network band` viser, hvilket bånd du er på, og `omarchy network band 5` fastlåser det. Brug `auto` for at lade den vælge igen.

Det fastlåser båndet frem for et specifikt access point, så du fortsat roamer mellem AP'er som normalt.

## Hvor hurtigt er det?

_Udløs > Hastighedstest > Netværkshastighedstest_ måler din faktiske op- og nedhastighed med et par visere. Fra terminalen er det `omarchy network speedtest down` eller `up`. (Der sidder en diskhastighedstest ved siden af i den menu, hvis du benchmarker den anden flaskehals.)

## Firewallen

Firewallen er tændt som standard og blokerer al indgående trafik, med én undtagelse: port 53317, så [LocalSend](22-guis.md) virker ud af boksen.

SSH er slukket, indtil du tænder det med _Opsætning > Sikkerhed > SSHD_, som starter dæmonen, åbner port 22 med hastighedsbegrænsning mod brute force og autoriserer en nøgle. Docker er også låst ned, så containere ikke ved et uheld kan eksponere sig selv for verden. Se [security](48-security.md) for hele historien.

## Tailscale

[Tailscale](https://tailscale.com/) er et mesh-VPN, der gør det enkelt og sikkert at nå alle dine computere og servere over internettet. Installer det med _Installer > Tjeneste > Tailscale_.

Det giver dig et Tailscale-panel i linjen, som forbinder og afbryder tailnettet, skifter konto og vælger en exit node — både dine egne maskiner og Mullvad-regioner vises på listen. Det browser også dine maskiner, og det er der, Taildrop bor: vælg en maskine og tryk `s` for at sende den filer, eller `c`, `n` og `d` for at kopiere dens IP, navn eller fulde DNS-navn. Terminalækvivalenten er `omarchy tailscale send <machine> [file...]`, og filer sendt til dig lander automatisk i `~/Downloads`. Notifikationen, der annoncerer en ankomst, venter, indtil du klikker den åben eller afviser den, så en fil, der dukker op, mens du er væk fra maskinen, stadig er der at svare på, når du kommer tilbage.

Installationen tilføjer også en webapp til Tailscale-administrationskonsollen.

## Når det holder op med at virke

Før du genstarter, så prøv at genstarte den fejlende del for sig selv. _Opdater > Hardware_ har Wi-Fi, Bluetooth, Lyd og Pegefelt, og at genindlæse en af dem rydder op i de fleste “det virkede for fem minutter siden”-situationer. Se [troubleshooting](45-troubleshooting.md).
