# Beveiliging

Omarchy neemt beveiliging uitermate serieus. Dit is bedoeld als een besturingssysteem dat je kunt gebruiken om _Echt Werk_ te doen in de _Echte Wereld_. Waar het verliezen van een laptop niet kan leiden tot een beveiligingsnoodsituatie. Dus dit is wat we doen:

1. *Volledige schijfversleuteling is verplicht*: Dit is de belangrijkste stap om de fysieke beveiliging van je gegevens te waarborgen. Als je computer kwijtraakt of wordt gestolen, zijn de gegevens volledig versleuteld met standaard LUKS (Linux Unified Key Setup).
2. *Firewall is standaard ingeschakeld*: Al het inkomende verkeer wordt standaard geblokkeerd, behalve poort 53317 voor [LocalSend](https://localsend.org/). Zelfs ssh staat uit totdat je het aanzet via _Instellen > Security > SSHD_, wat poort 22 opent (met rate limiting tegen brute force) als onderdeel van de setup. We schermen zelfs Docker-toegang af met de [ufw-docker](https://github.com/chaifeng/ufw-docker)-setup om te voorkomen dat je containers per ongeluk aan de wereld worden blootgesteld.
3. *Arch heeft altijd de nieuwste updates*: Arch, de onderliggende distro waarop Omarchy is gebouwd, is een rolling distributie. Dit betekent dat elke beveiligingskwetsbaarheid die wordt ontdekt en gepatcht in welk pakket dan ook snel beschikbaar is om te installeren met `omarchy-update`. Zo draai je altijd de nieuwste, veiligste versies van alles.
4. *Omarchy onderhoudt zijn eigen pakketten en mirror*: Omarchy vertrouwt standaard alleen op pakketten uit Archs eigen core/extra/multilib-repository's en zijn eigen Omarchy Package Repository. Je kunt software direct uit de AUR installeren, maar de basisinstallatie doet dat niet — alleen een paar optionele installaties, zoals de browsers van derden, halen uit de AUR.
5. *Cloudflare beschermt ons tegen DDoS*: Alle Omarchy-distributie-infrastructuur — de ISO's, de Omarchy-pakketten, de Arch-mirror — wordt beschermd achter Cloudflares formidabele DDoS-schild en gehost op hun CDN. Dit zorgt voor uitstekende beschikbaarheid.

## Je wachtwoorden wijzigen

Je hebt twee wachtwoorden op een versleutelde installatie: het wachtwoord dat de schijf ontgrendelt bij het opstarten, en het wachtwoord waarmee je inlogt en `sudo` gebruikt. De setup maakt ze hetzelfde. Beide kunnen worden gewijzigd onder _Bijwerken > Password_ in het Omarchy-menu — _Drive Encryption_ voor het eerste, _User_ voor het tweede. Het wijzigen van het schijfwachtwoord vraagt eerst om het huidige, dus houd het bij de hand. Als een wijziging wordt onderbroken, voer dan _Drive Encryption_ opnieuw uit: het vraagt om het wachtwoord dat de schijf nu ontgrendelt en voltooit de wijziging.

## Een machine doorgeven die je al hebt gebruikt

Als je je machine aan iemand anders overdraagt, hoef je hem niet opnieuw te installeren. Voer _Instellen > Reset Computer_ uit in het Omarchy-menu, typ `reset` om te bevestigen en herstart. Dat wist elk gebruikersaccount en alles in `/home`, gooit alle pakketten en systeemwijzigingen weg die je sinds de installatie hebt aangebracht, en wist de identiteit van de machine — netwerkverbindingen, hostsleutels en alles. Wat er terugkomt is de setupwizard van de eerste opstart, klaar voor de nieuwe eigenaar om een eigen naam, wachtwoord en versleutelingswachtwoord in te voeren.

Het werkt door de baselinesnapshot te herstellen die het installatieprogramma maakt, dus het is alleen beschikbaar op machines die zijn geïnstalleerd vanaf de Omarchy-ISO. En op een schijf zonder versleuteling is een reset verwijdering in plaats van veilig wissen, dus als de gegevens gevoelig waren, doe dan in plaats daarvan een schone installatie.

## Wachtwoordloze sudo

Soms wil je dat `sudo` stopt met vragen, meestal wanneer een AI-agent een lang stuk systeemwerk voor je doet. _Instellen > Security > Passwordless Sudo_ vraagt hoe lang toegang moet worden toegestaan: **15 minutes**, **1 Hour**, **1 Day** of **Permanently**. Er verschijnt een rood waarschuwingspictogram naast de andere indicatoren in de menubalk zolang de toegang actief is. Klik erop of voer het commando opnieuw uit om de toegang uit te schakelen. Je kunt ook je eigen aantal minuten doorgeven (van 1 tot 1440) met `omarchy-sudo-passwordless 30`, of `omarchy-sudo-passwordless permanent` gebruiken.

Getimede toegang verloopt automatisch, ook onmiddellijk na het hervatten uit een suspend die de deadline overschreed. Het herstarten van de computer beëindigt hem vroegtijdig. Permanente toegang overleeft herstarts en blijft ingeschakeld totdat je hem uitschakelt.

Het bijwerken of verwijderen van Omarchys instellingenpakket beëindigt elke tijdelijke toekenning voordat de ondersteuning voor het verlopen ervan verandert. Als het commando een autorisatie- of opschoningsfout meldt, los die dan op voordat je probeert een andere toekenning in te schakelen; een fout betekent niet dat wachtwoordloze toegang inactief is.

Wees hier nuchter over: zolang het aan staat, kan alles wat als jouw gebruiker draait alles doen als root zonder dat erom wordt gevraagd. Dat is precies de bedoeling, en het is ook precies het risico.

## Ondertekeningssleutels

De openbare sleutel voor alle ISO-handtekeningen en Omarchy-repo-pakketten is `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifieer op openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Het pakket `omarchy/omarchy-keyring` bevat dit ook en zal worden gebruikt om eventuele updates naadloos uit te rollen.

Je kunt de handtekening voor elke ISO-release vinden door .sig aan de URL toe te voegen. Zoals https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
