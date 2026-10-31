# Beveiliging

Omarchy neemt beveiliging extreem serieus. Dit is bedoeld als een besturingssysteem dat je kunt gebruiken om _Real Work_ te doen in de _Real World_. Waarbij het verliezen van een laptop niet kan leiden tot een beveiligingsnoodgeval. Dus dit is wat we doen:

1. *Volledige schijfversleuteling is verplicht*: Dit is de belangrijkste stap om je gegevens fysiek te beschermen. Als je computer verloren raakt of wordt gestolen, zijn de gegevens volledig versleuteld met het standaard LUKS (Linux Unified Key Setup).
2. *Firewall is standaard ingeschakeld*: Al het inkomende verkeer wordt standaard geblokkeerd, behalve poort 53317 voor [LocalSend](https://localsend.org/). Zelfs ssh staat uit totdat je het inschakelt via _Setup > Security > SSHD_, waardoor poort 22 wordt geopend (met rate limiting tegen brute force) als onderdeel van de configuratie. We beperken zelfs de toegang tot Docker met de [ufw-docker](https://github.com/chaifeng/ufw-docker)-configuratie om te voorkomen dat je containers per ongeluk aan de wereld worden blootgesteld.
3. *Arch heeft altijd de nieuwste updates*: Arch, de onderliggende distro waarop Omarchy is gebouwd, is een rolling distribution. Dat betekent dat elke beveiligingskwetsbaarheid die in een pakket wordt ontdekt en gepatcht, snel beschikbaar is om te installeren met `omarchy-update`. Zo draai je altijd de nieuwste, veiligste versies van alles.
4. *Omarchy onderhoudt zijn eigen pakketten en mirror*: Omarchy vertrouwt standaard alleen op pakketten uit de eigen core/extra/multilib-repositories van Arch en uit zijn eigen Omarchy Package Repository. Je kunt software rechtstreeks uit de AUR installeren, maar de basisinstallatie doet dat niet — slechts een paar optionele installaties, zoals de browsers van derden, halen iets uit de AUR.
5. *Cloudflare beschermt ons tegen DDoS*: De distributie-infrastructuur van Omarchy — de ISO's, de Omarchy-pakketten, de Arch-mirror — is beschermd achter het formidabele DDoS-schild van Cloudflare en wordt gehost op hun CDN. Dit zorgt voor uitstekende beschikbaarheid.

## Je wachtwoorden wijzigen

Je hebt twee wachtwoorden bij een versleutelde installatie: het wachtwoord dat de schijf ontgrendelt bij het opstarten, en het wachtwoord waarmee je inlogt en `sudo` gebruikt. Tijdens de installatie worden ze hetzelfde gemaakt. Beide kun je wijzigen onder _Update > Password_ in het Omarchy-menu — _Drive Encryption_ voor het eerste, _User_ voor het tweede. Om het schijfwachtwoord te wijzigen, wordt eerst om het huidige wachtwoord gevraagd, dus houd het bij de hand. Als een wijziging wordt onderbroken, voer _Drive Encryption_ dan opnieuw uit: het vraagt om het wachtwoord dat de schijf nu ontgrendelt en voltooit de wijziging.

## Een machine doorgeven die je al hebt gebruikt

Als je je machine aan iemand anders overdraagt, hoef je hem niet opnieuw te installeren. Voer _Setup > Reset Computer_ uit in het Omarchy-menu, typ `reset` om te bevestigen en start opnieuw op. Dat wist elk gebruikersaccount en alles in `/home`, gooit alle pakketten en systeemwijzigingen weg die je sinds de installatie hebt aangebracht, en wist de identiteit van de machine — netwerkverbindingen, host keys en alles. Wat weer opstart, is de configuratiewizard van de eerste keer opstarten, klaar voor de nieuwe eigenaar om diens eigen naam, wachtwoord en versleutelingswachtwoord in te voeren.

Het werkt door de baseline-snapshot te herstellen die het installatieprogramma maakt, dus het is alleen beschikbaar op machines die vanaf de Omarchy ISO zijn geïnstalleerd. En op een schijf zonder versleuteling is een reset een verwijdering in plaats van een veilige wissing, dus als de gegevens gevoelig waren, doe dan in plaats daarvan een verse installatie.

## Wachtwoordloze sudo

Soms wil je dat `sudo` stopt met vragen, meestal wanneer een AI-agent een lange reeks systeemwerk voor je doet. _Setup > Security > Passwordless Sudo_ vraagt hoe lang je toegang wilt toestaan: **15 minuten**, **1 uur**, **1 dag** of **Permanent**. Er verschijnt een rood waarschuwingsicoon naast de andere indicatoren in de menubalk zolang de toegang actief is. Klik erop of voer de opdracht opnieuw uit om de toegang uit te schakelen. Je kunt ook je eigen aantal minuten (van 1 tot 1440) doorgeven met `omarchy-sudo-passwordless 30`, of `omarchy-sudo-passwordless permanent` gebruiken.

Toegang met een tijdslimiet verloopt automatisch, ook onmiddellijk na het hervatten uit een slaapstand die de deadline heeft overschreden. De computer opnieuw opstarten beëindigt de toegang vroegtijdig. Permanente toegang overleeft herstarts en blijft ingeschakeld totdat je hem uitschakelt.

Het bijwerken of verwijderen van het instellingenpakket van Omarchy beëindigt elke tijdelijke toekenning voordat de ondersteuning voor het verlopen ervan verandert. Als de opdracht een autorisatie- of opruimfout meldt, los die dan op voordat je probeert een andere toekenning in te schakelen; een fout betekent niet dat wachtwoordloze toegang inactief is.

Wees hier nuchter over: zolang het aanstaat, kan alles wat als jouw gebruiker draait, alles als root doen zonder dat erom wordt gevraagd. Dat is precies de bedoeling, en het is ook precies het risico.

## Ondertekeningssleutels

De openbare sleutel voor alle ISO-handtekeningen en Omarchy repo-pakketten is `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifiëren op openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Het pakket `omarchy/omarchy-keyring` bevat deze ook en zal worden gebruikt om eventuele updates naadloos uit te rollen.

Je kunt de handtekening voor elke ISO-release vinden door `.sig` aan de URL toe te voegen, zoals `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
