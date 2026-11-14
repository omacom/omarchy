# Beveiliging

Omarchy neemt beveiliging extreem serieus. Dit moet een besturingssysteem zijn waarmee je _Echt Werk_ kunt doen in de _Echte Wereld_. Waar het verliezen van een laptop niet kan leiden tot een beveiligingsnoodgeval. Dus dit is wat we doen:

1. *Volledige schijfversleuteling staat standaard aan*: Dit is de belangrijkste stap om je gegevens fysiek te beveiligen. Als je computer verloren raakt of wordt gestolen, zijn de gegevens volledig versleuteld met standaard LUKS (Linux Unified Key Setup). Met het installatieprogramma kun je hiervan afzien voor wegwerpmachines (zie [Aan de slag](02-getting-started.md)); een installatie zonder versleuteling heeft niets van deze bescherming, en iedereen die de schijf in handen heeft, kan deze uitlezen.
2. *Firewall staat standaard ingeschakeld*: Al het inkomende verkeer wordt standaard geblokkeerd, met een paar uitzonderingen: poort 53317 voor [LocalSend](https://localsend.org/); DNS-aanvragen aan de eigen resolver van de computer op het Docker-bridgeadres (172.17.0.1), geaccepteerd vanuit de privéadresbereiken die Docker aan zijn containers geeft; en multicast DNS (poort 5353), waarmee printers en andere apparaten op je netwerk elkaar kunnen vinden en waarmee ook de naam van je computer daar wordt aangekondigd. Daarbovenop behoudt de firewall de standaardtoestemmingen van UFW voor ping, het verkrijgen van een adres bij je router (DHCP) en UPnP-detectie. Zelfs ssh staat uit totdat je het inschakelt via _Instellen > Beveiliging > SSHD_, waarmee poort 22 wordt geopend (met snelheidsbeperking tegen brute force) als onderdeel van het instellen. We sluiten zelfs de Docker-toegang af met de [ufw-docker](https://github.com/chaifeng/ufw-docker)-configuratie om te voorkomen dat je containers per ongeluk aan de wereld worden blootgesteld.
3. *Arch heeft altijd de nieuwste updates*: Arch, de onderliggende distro waarop Omarchy is gebouwd, is een rolling distribution. Dit betekent dat elke beveiligingskwetsbaarheid die in een pakket wordt ontdekt en verholpen, snel beschikbaar is om te installeren met `omarchy-update`. Op die manier draai je altijd de nieuwste, veiligste versies van alles.
4. *Omarchy onderhoudt zijn eigen pakketten en mirror*: Omarchy vertrouwt standaard alleen op pakketten uit Arch' eigen core/extra/multilib-repositories en zijn eigen Omarchy Package Repository. Je kunt software rechtstreeks uit de AUR installeren, maar de basisinstallatie doet dat niet — slechts een paar optionele installaties, zoals de browsers van derden, halen iets uit de AUR.
5. *Cloudflare beschermt ons tegen DDoS*: De distributie-infrastructuur van Omarchy — de ISO's, de Omarchy-pakketten, de Arch-mirror — wordt beschermd achter het formidabele DDoS-schild van Cloudflare en gehost op hun CDN. Dit zorgt voor uitstekende beschikbaarheid.

## Je wachtwoorden wijzigen

Je hebt twee wachtwoorden op een versleutelde installatie: het wachtwoord waarmee je de schijf bij het opstarten ontgrendelt, en het wachtwoord waarmee je inlogt en `sudo` gebruikt. Bij het instellen worden ze aan elkaar gelijk gemaakt. Beide kunnen worden gewijzigd onder _Bijwerken > Wachtwoord_ in het Omarchy-menu — _Schijfversleuteling_ voor het eerste, _Gebruiker_ voor het tweede. Voor het wijzigen van het schijfwachtwoord wordt eerst om het huidige wachtwoord gevraagd, dus houd dat bij de hand. Als een wijziging wordt onderbroken, voer _Schijfversleuteling_ dan opnieuw uit: er wordt gevraagd om het wachtwoord waarmee de schijf nu wordt ontgrendeld, en de wijziging wordt voltooid.

## Een machine doorgeven die je al hebt gebruikt

Als je je machine aan iemand anders overdraagt, hoef je deze niet opnieuw te installeren. Voer _Instellen > Computer resetten_ uit in het Omarchy-menu, typ `reset` om te bevestigen en start opnieuw op. Daarmee wordt elk gebruikersaccount en alles in `/home` gewist, worden alle pakketten en systeemwijzigingen die je sinds de installatie hebt aangebracht weggegooid en wordt de identiteit van de machine gewist — netwerkverbindingen, hostsleutels, alles. Wat weer opstart, is de installatiewizard van de eerste keer opstarten, klaar voor de nieuwe eigenaar om hun eigen naam, wachtwoord en versleutelingswachtwoord in te voeren.

Het werkt door de basissnapshot te herstellen die het installatieprogramma maakt, dus het is alleen beschikbaar op machines die vanaf de Omarchy ISO zijn geïnstalleerd. En op een schijf zonder versleuteling is een reset verwijdering in plaats van veilig wissen, dus als de gegevens gevoelig waren, doe dan in plaats daarvan een schone installatie.

## Sudo zonder wachtwoord

Soms wil je dat `sudo` stopt met vragen, meestal wanneer een AI-agent een lang stuk systeemwerk voor je doet. _Instellen > Beveiliging > Sudo zonder wachtwoord_ vraagt hoe lang je toegang wilt toestaan: **15 minuten**, **1 uur**, **1 dag** of **Permanent**. Er verschijnt een rood waarschuwingspictogram naast de andere indicatoren in de menubalk zolang de toegang actief is. Klik erop of voer de opdracht opnieuw uit om de toegang uit te schakelen. Je kunt ook je eigen aantal minuten (van 1 tot 1440) doorgeven met `omarchy-sudo-passwordless 30`, of `omarchy-sudo-passwordless permanent` gebruiken.

Getimede toegang verloopt automatisch, inclusief onmiddellijk na het hervatten uit een slaapstand die de deadline heeft overschreden. Het opnieuw opstarten van de computer beëindigt de toegang vroegtijdig. Permanente toegang overleeft herstarts en blijft ingeschakeld totdat je deze uitschakelt.

Het bijwerken of verwijderen van het instellingenpakket van Omarchy beëindigt elke tijdelijke toekenning voordat de ondersteuning voor het verlopen ervan verandert. Als de opdracht een autorisatie- of opruimfout meldt, los deze dan op voordat je probeert een nieuwe toekenning in te schakelen; een fout betekent niet dat toegang zonder wachtwoord inactief is.

Wees hier nuchter over: zolang dit aanstaat, kan alles wat als jouw gebruiker draait, alles als root doen zonder dat erom wordt gevraagd. Dat is precies de bedoeling, en het is ook precies het risico.

## Ondertekeningssleutels

De publieke sleutel voor alle ISO-handtekeningen en het Omarchy-repo-pakket is `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifieer op openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Het pakket `omarchy/omarchy-keyring` bevat deze ook en zal worden gebruikt om eventuele updates naadloos uit te rollen.

Je kunt de handtekening voor elke ISO-release vinden door `.sig` aan de URL toe te voegen, zoals `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
