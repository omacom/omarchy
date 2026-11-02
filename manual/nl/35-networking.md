# Netwerken

Netwerken in Omarchy wordt afgehandeld door NetworkManager, en je bedient het vanuit het netwerkpictogram in de [bovenbalk](05-the-top-bar.md) of met `Super + Ctrl + N`.

Dat paneel scant naar Wi-Fi-netwerken, toont de signaalsterkte en maakt verbinding. Ethernet heeft helemaal niets nodig — plug het in en het werkt. Als je liever in de terminal blijft, geeft `nmtui` je dezelfde bediening, en er is ook een `omarchy network`-commandogroep.

## Je Wi-Fi delen

In plaats van een lang wachtwoord hardop voor te lezen, voer je _Setup > Network > QR Code_ uit terwijl je op Wi-Fi zit. Dat zet een QR-code op het scherm die elke telefooncamera kan scannen om verbinding te maken. Het is een van die dingen die je vaker zult gebruiken dan je zou verwachten zodra je weet dat het er is.

Als je echt het wachtwoord zelf nodig hebt, geeft `omarchy network password <interface>` het weer.

## DNS

Omarchy gebruikt de DNS die je netwerk via DHCP uitdeelt. Je kunt dat voor de hele machine overschrijven onder _Setup > Network > DNS_, waar Cloudflare en Google één klik verwijderd zijn. Kies _Custom_ om je eigen servers in te typen.

Vanuit de terminal geeft `omarchy dns` de huidige provider weer en stelt `omarchy dns Cloudflare` er een in.

## De Wi-Fi-band vastzetten

Als je router 2.4GHz, 5GHz en 6GHz onder dezelfde netwerknaam aanbiedt, klampt je laptop zich soms vast aan de trage band. `omarchy network band` toont op welke band je zit, en `omarchy network band 5` zet die vast. Gebruik `auto` om hem weer zelf te laten kiezen.

Dit zet de band vast in plaats van een specifiek toegangspunt, dus je blijft normaal tussen APs roamen.

## Hoe snel is het?

_Trigger > Speed Test > Network Speed Test_ meet je werkelijke upload- en downloadsnelheid met een paar wijzerplaten. Vanuit de terminal is het `omarchy network speedtest down` of `up`. Het meet tegen Omarchy's eigen dienst en telt alleen zijn testoverdrachten. Andere downloads kunnen concurreren om bandbreedte, maar ze worden niet opgeteld bij het resultaat van de snelheidstest. (Er zit een schijfsnelheidstest naast in dat menu, als je de andere bottleneck aan het benchmarken bent.)

## De firewall

De firewall staat standaard aan en blokkeert al het inkomende verkeer, met één uitzondering: poort 53317, zodat [LocalSend](22-guis.md) meteen werkt.

SSH staat uit totdat je het aanzet met _Setup > Security > SSHD_, wat de daemon start, poort 22 opent met snelheidsbeperking tegen brute force en een sleutel autoriseert. Docker is ook afgeschermd, zodat containers zichzelf niet per ongeluk aan de wereld kunnen blootstellen. Zie [beveiliging](48-security.md) voor het hele verhaal.

## Tailscale

[Tailscale](https://tailscale.com/) is een mesh VPN die het simpel en veilig maakt om al je computers en servers via het internet te bereiken. Installeer het met _Install > Service > Tailscale_.

Dat geeft je een Tailscale-paneel in de balk, waarmee je verbinding maakt met het tailnet en die verbreekt, van account wisselt en een exit node kiest — je eigen machines en Mullvad-regio's verschijnen allebei in de lijst. Je bladert er ook mee door je machines, en daar leeft Taildrop: selecteer een machine en druk op `s` om er bestanden naartoe te sturen, of op `c`, `n` en `d` om het IP, de naam of de volledige DNS-naam te kopiëren. Het terminalequivalent is `omarchy tailscale send <machine> [file...]`, en bestanden die naar jou worden gestuurd belanden automatisch in `~/Downloads`. De melding die een aankomst aankondigt wacht totdat je erop klikt om hem te openen of hem wegklikt, zodat een bestand dat binnenkomt terwijl je niet bij de machine bent er nog steeds is om op te reageren als je terugkomt.

Het installeren ervan voegt ook een webapp toe voor de Tailscale-beheerconsole.

## Wanneer het stopt met werken

Probeer voordat je opnieuw opstart het problematische onderdeel op zichzelf opnieuw te starten. _Update > Hardware_ heeft Wi-Fi, Bluetooth, Audio en Trackpad, en een daarvan opnieuw laden lost de meeste "het werkte vijf minuten geleden nog"-situaties op. Zie [probleemoplossing](45-troubleshooting.md).
