# Netwerken

Netwerken in Omarchy wordt afgehandeld door NetworkManager, en je bedient het via het netwerkpictogram in de [bovenste balk](05-the-top-bar.md) of met `Super + Ctrl + W`.

Dat paneel scant naar wifi-netwerken, toont de signaalsterkte en maakt verbinding. Ethernet heeft helemaal niets nodig — plug de kabel in en het werkt. Als je liever in de terminal blijft, geeft `nmtui` je dezelfde bediening, en er is ook een `omarchy network`-commandogroep.

## Je wifi delen

In plaats van een lang wachtwoord hardop voor te lezen, voer je _Instellen > Network > QR Code_ uit terwijl je op wifi zit. Dat zet een QR-code op het scherm die elke telefooncamera kan scannen om verbinding te maken. Het is een van die dingen die je vaker zult gebruiken dan je denkt zodra je weet dat het er is.

Als je echt het wachtwoord zelf nodig hebt, drukt `omarchy network password <interface>` het af.

## DNS

Omarchy gebruikt de DNS die je netwerk via DHCP uitdeelt. Je kunt dat voor de hele machine overschrijven onder _Instellen > Network > DNS_, waar Cloudflare en Google één klik verwijderd zijn. Kies _Custom_ om je eigen servers in te typen.

Vanuit de terminal drukt `omarchy dns` de huidige provider af en stelt `omarchy dns Cloudflare` er een in.

## De wifi-band vastpinnen

Als je router 2,4 GHz, 5 GHz en 6 GHz onder dezelfde netwerknaam zet, blijft je laptop soms hangen op de trage band. `omarchy network band` toont op welke band je zit, en `omarchy network band 5` pint hem vast. Gebruik `auto` om hem weer zelf te laten kiezen.

Dit pint de band vast in plaats van een specifiek toegangspunt, zodat je normaal tussen toegangspunten blijft roamen.

## Hoe snel is het?

_Activeren > Speed Test > Network Speed Test_ meet je werkelijke up- en downloadsnelheid met een paar wijzerplaten. Vanuit de terminal is het `omarchy network speedtest down` of `up`. (Er zit een schijfsnelheidstest naast in dat menu, als je de andere bottleneck aan het benchmarken bent.)

## De firewall

De firewall staat standaard aan en blokkeert al het inkomende verkeer, met één uitzondering: poort 53317, zodat [LocalSend](22-guis.md) meteen uit de doos werkt.

SSH staat uit totdat je het aanzet met _Instellen > Security > SSHD_, wat de daemon start, poort 22 opent met rate limiting tegen brute force, en een sleutel autoriseert. Docker is ook afgeschermd, zodat containers zichzelf niet per ongeluk aan de wereld kunnen blootstellen. Zie [beveiliging](48-security.md) voor het hele verhaal.

## Tailscale

[Tailscale](https://tailscale.com/) is een mesh-VPN die het eenvoudig en veilig maakt om al je computers en servers via internet te bereiken. Installeer het met _Installeren > Service > Tailscale_.

Dat geeft je een Tailscale-paneel in de balk, waarmee je het tailnet verbindt en verbreekt, van account wisselt en een exit-node kiest — zowel je eigen machines als Mullvad-regio's verschijnen in de lijst. Het bladert ook door je machines, en daar woont Taildrop: selecteer een machine en druk op `s` om er bestanden naartoe te sturen, of op `c`, `n` en `d` om het IP-adres, de naam of de volledige DNS-naam te kopiëren. Het terminal-equivalent is `omarchy tailscale send <machine> [file...]`, en bestanden die naar jou worden gestuurd belanden automatisch in `~/Downloads`. De melding die een aankomst aankondigt wacht totdat je erop klikt om hem te openen of hem wegklikt, zodat een bestand dat arriveert terwijl je niet achter de machine zit er nog steeds is om te beantwoorden als je terugkomt.

Het installeren ervan voegt ook een webapp toe voor de Tailscale-beheerconsole.

## Als het stopt met werken

Probeer voordat je herstart eerst het storende onderdeel op zichzelf te herstarten. _Bijwerken > Hardware_ heeft Wi-Fi, Bluetooth, Audio en Trackpad, en het herladen van een daarvan ruimt de meeste "het werkte vijf minuten geleden nog"-situaties op. Zie [probleemoplossing](45-troubleshooting.md).
