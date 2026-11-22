# Beveiliging

Omarchy neemt beveiliging uiterst serieus. Dit moet een besturingssysteem zijn dat je kunt gebruiken om _Echt Werk_ te doen in de _Echte Wereld_. Waar het verliezen van een laptop niet tot een beveiligingsnoodgeval kan leiden. Dit is dus wat we doen:

1. *Volledige schijfversleuteling staat standaard aan*: Dit is de belangrijkste stap om je gegevens fysiek te beschermen. Als je computer verloren raakt of wordt gestolen, zijn de gegevens volledig versleuteld met standaard LUKS (Linux Unified Key Setup). Met het installatieprogramma kun je hier voor wegwerpmachines van afzien (zie [Aan de slag](02-getting-started.md)); een installatie zonder versleuteling heeft niets van deze bescherming, en iedereen die de schijf in handen heeft, kan haar lezen.
2. *Firewall staat standaard aan*: Al het inkomende verkeer wordt standaard geblokkeerd, met een paar uitzonderingen: poort 53317 voor [LocalSend](https://localsend.org/); DNS-query's naar de eigen resolver van de computer op het Docker-bridgeadres (172.17.0.1), geaccepteerd vanaf de privé-adresbereiken die Docker aan zijn containers geeft; en multicast DNS (poort 5353), waarmee printers en andere apparaten op je netwerk elkaar kunnen vinden en waarmee ook de naam van je computer daar wordt aangekondigd. Daarbovenop behoudt de firewall de standaardtoestemmingen van UFW voor ping, het verkrijgen van een adres van je router (DHCP) en UPnP-discovery. Zelfs ssh staat uit totdat je het inschakelt via _Setup > Security > SSHD_; dat autoriseert je SSH-sleutel, schakelt aanmeldingen met een wachtwoord uit en opent pas dan poort 22 (met snelheidsbeperking tegen brute force). We vergrendelen zelfs de Docker-toegang met de [ufw-docker](https://github.com/chaifeng/ufw-docker)-configuratie om te voorkomen dat je containers per ongeluk aan de wereld worden blootgesteld.
3. *Arch heeft altijd de nieuwste updates*: Arch, de onderliggende distro waarop Omarchy is gebouwd, is een rolling distribution. Dat betekent dat elke beveiligingskwetsbaarheid die in een willekeurig pakket wordt ontdekt en verholpen, snel beschikbaar is om te installeren met `omarchy-update`. Zo draai je altijd de nieuwste, veiligste versies van alles.
4. *Omarchy onderhoudt zijn eigen pakketten en mirror*: Omarchy vertrouwt standaard alleen op pakketten uit de eigen core/extra/multilib-repositories van Arch (die van Arch Linux ARM op ARM-machines, plus Asahi ALARM op Apple Silicon) en zijn eigen Omarchy Package Repository. Je kunt software rechtstreeks uit de AUR installeren, maar de basisinstallatie doet dat niet — slechts een paar optionele installaties, zoals de browsers van derden, halen iets uit de AUR.
5. *Cloudflare beschermt ons tegen DDoS*: De distributie-infrastructuur van Omarchy — de ISO's, de Omarchy-pakketten, de Arch-mirror — wordt beschermd achter het formidabele DDoS-schild van Cloudflare en gehost op hun CDN. Dat zorgt voor uitstekende beschikbaarheid.

## Je wachtwoorden wijzigen

Op een versleutelde installatie heb je twee wachtwoorden: het wachtwoord waarmee je de schijf ontgrendelt bij het opstarten, en het wachtwoord waarmee je je aanmeldt en `sudo` gebruikt. De Setup maakt ze gelijk. Beide kunnen worden gewijzigd onder _Update > Password_ in het Omarchy-menu — _Drive Encryption_ voor het eerste, _User_ voor het tweede. Voor het wijzigen van het schijfwachtwoord wordt eerst om het huidige wachtwoord gevraagd, dus houd dat bij de hand. Als een wijziging wordt onderbroken, voer _Drive Encryption_ dan opnieuw uit: er wordt gevraagd om het wachtwoord waarmee de schijf nu wordt ontgrendeld en de wijziging wordt voltooid.

## Een machine doorgeven die je al hebt gebruikt

Als je je machine aan iemand anders overdraagt, hoef je haar niet opnieuw te installeren. Voer _Remove > Factory Reset_ uit in het Omarchy-menu, typ `reset` om te bevestigen, voer je schijfversleutelingswachtwoord in als daarom wordt gevraagd en start opnieuw op. Dat wist elk gebruikersaccount en alles in `/home`, gooit alle pakketten en systeemwijzigingen weg die je sinds de installatie hebt aangebracht en wist de identiteit van de machine — netwerkverbindingen, host keys en alles. Wat daarna opstart, is de setup-wizard van de eerste keer opstarten, klaar voor de nieuwe eigenaar om zijn eigen naam, wachtwoord en versleutelingswachtwoord in te voeren.

Het werkt door de baseline-snapshot te herstellen die het installatieprogramma maakt, dus het is alleen beschikbaar op machines die vanaf de Omarchy ISO zijn geïnstalleerd. En op een schijf zonder versleuteling is een reset verwijdering in plaats van een veilige wissing, dus als de gegevens gevoelig waren, doe dan in plaats daarvan een verse installatie.

## Sudo zonder wachtwoord

Soms wil je dat `sudo` stopt met vragen, meestal wanneer een AI-agent voor je een lange reeks systeemwerk doet. _Setup > Security > Passwordless Sudo_ vraagt hoe lang je toegang wilt toestaan: **15 minuten**, **1 uur**, **1 dag** of **Permanent**. Terwijl de toegang actief is, verschijnt er een rood waarschuwingsicoon naast de andere indicatoren van de menubalk. Klik erop of voer de opdracht opnieuw uit om de toegang uit te schakelen. Je kunt ook je eigen aantal minuten (van 1 tot 1440) doorgeven met `omarchy-sudo-passwordless 30`, of `omarchy-sudo-passwordless permanent` gebruiken.

Getimede toegang verloopt automatisch, ook onmiddellijk na het hervatten uit een suspend die de deadline is gepasseerd. Het opnieuw opstarten van de computer beëindigt het vroegtijdig. Permanente toegang blijft behouden na opnieuw opstarten en blijft ingeschakeld totdat je het uitschakelt.

Het bijwerken of verwijderen van het instellingenpakket van Omarchy beëindigt elke tijdelijke toekenning voordat de ondersteuning voor het verlopen ervan verandert. Als de opdracht een autorisatie- of opruimfout meldt, los die dan op voordat je probeert een andere toekenning in te schakelen; een fout betekent niet dat toegang zonder wachtwoord inactief is.

Kijk hier nuchter naar: terwijl het aan staat, kan alles dat als jouw gebruiker draait, alles als root doen zonder dat erom wordt gevraagd. Dat is het hele punt, en het is ook het hele risico.

## Ondertekeningssleutels

De openbare sleutel voor alle ISO-handtekeningen en Omarchy-repo-pakketten is `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([controleren op openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Het pakket `omarchy/omarchy-keyring` bevat deze ook en zal worden gebruikt om eventuele updates naadloos uit te rollen.

Je kunt de handtekening voor elke ISO-release vinden door `.sig` aan haar URL toe te voegen, zoals `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
