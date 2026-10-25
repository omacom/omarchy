# Netwerken

Netwerken in Omarchy wordt afgehandeld door NetworkManager, en je bedient het via het netwerkpictogram in de [bovenbalk](05-the-top-bar.md) of met `Super + Ctrl + N`.

Dat paneel zoekt naar Wi-Fi-netwerken, toont de signaalsterkte en maakt verbinding. Ethernet heeft helemaal niets nodig — steek de kabel erin en het werkt. Als je liever in de terminal blijft, geeft `nmtui` je dezelfde bediening, en er is ook een `omarchy network`-commandogroep.

## Je Wi-Fi delen

In plaats van een lang wachtwoord hardop voor te lezen, voer je _Setup > Network > QR Code_ uit terwijl je op Wi-Fi zit. Dat zet een QR-code op het scherm die elke telefooncamera kan scannen om verbinding te maken. Het is een van die dingen die je vaker zult gebruiken dan je zou verwachten, zodra je weet dat het er is.

Als je het wachtwoord zelf echt nodig hebt, print `omarchy network password <interface>` het.

## DNS

Omarchy gebruikt de DNS die je netwerk via DHCP uitdeelt. Je kunt dat voor de hele machine overschrijven onder _Setup > Network > DNS_, waar Cloudflare en Google één klik verwijderd zijn. Kies _Custom_ om je eigen servers in te typen.

Vanuit de terminal print `omarchy dns` de huidige provider en stelt `omarchy dns Cloudflare` er een in.

## De Wi-Fi-band vastzetten

Als je router 2.4GHz, 5GHz en 6GHz onder dezelfde netwerknaam aanbiedt, blijft je laptop soms hangen aan de trage band. `omarchy network band` toont op welke band je zit, en `omarchy network band 5` zet hem daarop vast. Gebruik `auto` om hem weer zelf te laten kiezen.

Dit zet de band vast in plaats van een specifiek toegangspunt, dus je blijft normaal roamen tussen AP's.

## Hoe snel is het?

_Trigger > Speed Test > Network Speed Test_ meet je werkelijke upload- en downloadsnelheid met een paar wijzerplaten. Vanuit de terminal is het `omarchy network speedtest down` of `up`. (Er zit een schijfsnelheidstest naast in dat menu, als je de andere bottleneck aan het benchmarken bent.)

## De firewall

De firewall staat standaard aan en blokkeert al het inkomende verkeer, met één uitzondering: poort 53317, zodat [LocalSend](22-guis.md) direct werkt.

SSH staat uit tot je het aanzet met _Setup > Security > SSHD_, wat de daemon start, poort 22 opent met snelheidsbeperking tegen brute force en een sleutel autoriseert. Docker is ook dichtgetimmerd, zodat containers zichzelf niet per ongeluk aan de wereld kunnen blootstellen. Zie [beveiliging](48-security.md) voor het hele verhaal.

## Tailscale

[Tailscale](https://tailscale.com/) is een mesh-VPN die het eenvoudig en veilig maakt om al je computers en servers via internet te bereiken. Installeer het met _Install > Service > Tailscale_.

Dat geeft je een Tailscale-paneel in de balk, dat verbinding maakt met het tailnet en die verbreekt, van account wisselt en een exit node kiest — je eigen machines en Mullvad-regio's verschijnen allebei in de lijst. Het bladert ook door je machines, en daar leeft Taildrop: selecteer een machine en druk op `s` om er bestanden naartoe te sturen, of op `c`, `n` en `d` om het IP, de naam of de volledige DNS-naam te kopiëren. Het terminalequivalent is `omarchy tailscale send <machine> [file...]`, en bestanden die naar je worden gestuurd, komen automatisch in `~/Downloads` terecht. De melding die een aankomst aankondigt, wacht tot je hem openklikt of wegdoet, zodat een bestand dat binnenkomt terwijl je niet bij de machine bent er nog steeds is om op te reageren als je terugkomt.

Als je het installeert, wordt er ook een webapp voor de Tailscale-beheerconsole toegevoegd.

## Als het stopt met werken

Probeer voordat je opnieuw opstart het problematische onderdeel op zichzelf opnieuw te starten. _Update > Hardware_ heeft Wi-Fi, Bluetooth, Audio en Trackpad, en het opnieuw laden van een daarvan lost de meeste "het werkte vijf minuten geleden nog"-situaties op. Zie [probleemoplossing](45-troubleshooting.md).
