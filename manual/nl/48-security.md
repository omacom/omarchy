# Beveiliging

Omarchy neemt beveiliging extreem serieus. Dit moet een besturingssysteem zijn dat je kunt gebruiken om _Real Work_ te doen in de _Real World_. Waar een kwijtgeraakte laptop niet tot een beveiligingsnoodgeval kan leiden. Dit is dus wat we doen:

1. *Volledige schijfversleuteling staat standaard aan*: Dit is de belangrijkste stap om je gegevens fysiek te beschermen. Als je computer kwijt of gestolen is, zijn de gegevens volledig versleuteld met standaard LUKS (Linux Unified Key Setup). Met het installatieprogramma kun je dit uitschakelen voor wegwerpmachines (zie [Aan de slag](02-getting-started.md)); een installatie zonder versleuteling heeft deze bescherming niet, en iedereen die de schijf in handen heeft, kan hem uitlezen.
2. *Firewall staat standaard aan*: Al het inkomende verkeer wordt standaard geblokkeerd, met een paar uitzonderingen: poort 53317 voor [LocalSend](https://localsend.org/); DNS-query's naar de eigen resolver van de computer op het Docker-bridgeadres (172.17.0.1), geaccepteerd van de privéadresbereiken die Docker aan zijn containers geeft; en multicast DNS (poort 5353), waarmee printers en andere apparaten op je netwerk elkaar kunnen vinden en waarmee ook de naam van je computer daar wordt aangekondigd. Daarnaast behoudt de firewall de standaardtoestemmingen van UFW voor ping, een adres krijgen van je router (DHCP) en UPnP-discovery. Zelfs ssh staat uit totdat je het inschakelt via _Setup > Security > SSHD_, waarmee je SSH-sleutel wordt geautoriseerd, inloggen met een wachtwoord wordt uitgeschakeld en pas daarna poort 22 wordt geopend (met snelheidsbeperking tegen brute force). We sluiten zelfs de toegang tot Docker af met de [ufw-docker](https://github.com/chaifeng/ufw-docker)-configuratie om te voorkomen dat je containers per ongeluk aan de wereld worden blootgesteld.
3. *Arch heeft altijd de nieuwste updates*: Arch, de onderliggende distro waarop Omarchy is gebouwd, is een rolling distribution. Dit betekent dat elke beveiligingskwetsbaarheid die in een pakket wordt ontdekt en verholpen, snel beschikbaar is om te installeren met `omarchy-update`. Zo draai je altijd de nieuwste, veiligste versies van alles.
4. *Omarchy onderhoudt eigen pakketten en een eigen mirror*: Omarchy vertrouwt standaard alleen op pakketten uit de eigen core/extra/multilib-repositories van Arch (die van Arch Linux ARM op ARM-machines, plus Asahi ALARM op Apple Silicon) en zijn eigen Omarchy Package Repository. Je kunt software rechtstreeks uit de AUR installeren, maar de basisinstallatie doet dat niet — alleen een paar optionele installaties, zoals de browsers van derden, halen iets uit de AUR.
5. *Cloudflare beschermt ons tegen DDoS*: De distributie-infrastructuur van Omarchy — de ISO's, de Omarchy-pakketten, de Arch-mirror — wordt beschermd achter het formidabele DDoS-schild van Cloudflare en gehost op hun CDN. Dit zorgt voor een uitstekende beschikbaarheid.

## Je wachtwoorden wijzigen

Op een versleutelde installatie heb je twee wachtwoorden: het wachtwoord waarmee je de schijf bij het opstarten ontgrendelt, en het wachtwoord waarmee je inlogt en `sudo` gebruikt. De installatie maakt ze gelijk. _Update > Password_ in het Omarchy-menu wijzigt beide tegelijk, zodat ze gelijk blijven: het vraagt om het huidige schijfwachtwoord, daarna om het nieuwe, wijzigt dat van de schijf en stelt vervolgens je inlogwachtwoord zo in dat het daarmee overeenkomt. Zonder schijfversleuteling wijzigt het alleen je inlogwachtwoord. Als een wijziging wordt onderbroken, voer _Update > Password_ opnieuw uit: het vraagt om het wachtwoord waarmee de schijf nu wordt ontgrendeld, voltooit de wijziging en stelt je inlogwachtwoord daarop in. Voer `omarchy-drive-password` in een terminal uit om het wachtwoord van een andere versleutelde schijf te wijzigen.

## Een machine doorgeven die je al hebt gebruikt

Als je je machine aan iemand anders overdraagt, hoef je haar niet opnieuw te installeren. Voer _Remove > Factory Reset_ uit in het Omarchy-menu, typ `reset` om te bevestigen, voer indien gevraagd je wachtwoord voor schijfversleuteling in en start opnieuw op. Daarmee wordt elk gebruikersaccount en alles in `/home` gewist, worden alle pakketten en systeemwijzigingen die je sinds de installatie hebt aangebracht weggegooid en wordt de identiteit van de machine gewist — netwerkverbindingen, hostsleutels en alles. Wat daarna opstart, is de installatiewizard van de eerste opstart, klaar voor de nieuwe eigenaar om een eigen naam, wachtwoord en versleutelingswachtwoord in te voeren.

Dit werkt door de basissnapshot te herstellen die het installatieprogramma maakt, dus het is alleen beschikbaar op machines die vanaf de Omarchy-ISO zijn geïnstalleerd. En op een schijf zonder versleuteling is een reset verwijdering in plaats van veilig wissen, dus als de gegevens gevoelig waren, voer dan in plaats daarvan een schone installatie uit.

## sudo zonder wachtwoord

Soms wil je dat `sudo` stopt met vragen, meestal wanneer een AI-agent lange tijd systeemwerk voor je doet. _Setup > Security > Passwordless Sudo_ vraagt hoe lang je toegang wilt toestaan: **15 minuten**, **1 uur**, **1 dag** of **Permanent**. Er verschijnt een rood waarschuwingspictogram naast de andere indicatoren in de menubalk zolang de toegang actief is. Klik erop of voer de opdracht opnieuw uit om de toegang uit te schakelen. Je kunt ook je eigen aantal minuten (van 1 tot 1440) doorgeven met `omarchy-sudo-passwordless 30`, of `omarchy-sudo-passwordless permanent` gebruiken.

Toegang met een tijdslimiet verloopt automatisch, ook onmiddellijk na het hervatten uit een slaapstand die over de deadline heen ging. De computer opnieuw opstarten beëindigt deze eerder. Permanente toegang blijft behouden na opnieuw opstarten en blijft ingeschakeld totdat je deze uitschakelt.

Het bijwerken of verwijderen van het instellingenpakket van Omarchy beëindigt elke tijdelijke toestemming voordat de ondersteuning voor het verlopen ervan verandert. Als de opdracht een autorisatie- of opruimfout meldt, los die dan op voordat je probeert een andere toestemming in te schakelen; een fout betekent niet dat toegang zonder wachtwoord inactief is.

Wees hier nuchter over: zolang dit aan staat, kan alles wat als jouw gebruiker draait alles als root doen zonder dat erom wordt gevraagd. Dat is precies de bedoeling, en dat is ook precies het risico.

## Ondertekeningssleutels

De openbare sleutel voor alle ISO-handtekeningen en het Omarchy-repo-pakket is `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifieer op openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Het pakket `omarchy/omarchy-keyring` bevat deze ook en wordt gebruikt om eventuele updates naadloos uit te rollen.

Je vindt de handtekening voor elke ISO-release door `.sig` aan de URL toe te voegen, zoals `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
