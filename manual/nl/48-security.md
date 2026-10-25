# Beveiliging

Omarchy neemt beveiliging extreem serieus. Dit moet een besturingssysteem zijn dat je kunt gebruiken om _Echt Werk_ te doen in de _Echte Wereld_. Waar het verliezen van een laptop niet kan leiden tot een beveiligingsnoodgeval. Dus dit is wat we doen:

1. *Volledige schijfversleuteling is verplicht*: Dit is de belangrijkste stap om je gegevens fysiek te beschermen. Als je computer kwijtraakt of wordt gestolen, zijn de gegevens volledig versleuteld met standaard LUKS (Linux Unified Key Setup).
2. *Firewall is standaard ingeschakeld*: Al het inkomende verkeer wordt standaard geblokkeerd, behalve poort 53317 voor [LocalSend](https://localsend.org/). Zelfs ssh staat uit totdat je het inschakelt via _Setup > Security > SSHD_, waarmee poort 22 wordt geopend (met snelheidsbeperking tegen brute force) als onderdeel van de setup. We sluiten zelfs de toegang tot Docker af met de [ufw-docker](https://github.com/chaifeng/ufw-docker)-setup, om te voorkomen dat je containers per ongeluk aan de wereld worden blootgesteld.
3. *Arch heeft altijd de nieuwste updates*: Arch, de onderliggende distro waarop Omarchy is gebouwd, is een rolling distribution. Dat betekent dat elke beveiligingskwetsbaarheid die in een pakket wordt ontdekt en gedicht, snel beschikbaar is om te installeren met `omarchy-update`. Zo draai je altijd de nieuwste, veiligste versies van alles.
4. *Omarchy onderhoudt zijn eigen pakketten en mirror*: Omarchy vertrouwt standaard alleen op pakketten uit Arch' eigen core/extra/multilib-repositories en zijn eigen Omarchy Package Repository. Je kunt software rechtstreeks uit de AUR installeren, maar de basisinstallatie doet dat niet — slechts een paar optionele installaties, zoals de browsers van derden, halen iets uit de AUR.
5. *Cloudflare beschermt ons tegen DDoS*: De distributie-infrastructuur van Omarchy — de ISO's, de Omarchy-pakketten, de Arch-mirror — wordt beschermd achter Cloudflare's formidabele DDoS-schild en gehost op hun CDN. Dit zorgt voor uitstekende beschikbaarheid.

## Je wachtwoorden wijzigen

Je hebt twee wachtwoorden op een versleutelde installatie: het wachtwoord dat de schijf ontgrendelt bij het opstarten, en het wachtwoord waarmee je inlogt en `sudo` gebruikt. Setup maakt ze hetzelfde. Beide kun je wijzigen onder _Update > Password_ in het Omarchy-menu — _Drive Encryption_ voor het eerste, _User_ voor het tweede. Bij het wijzigen van het schijfwachtwoord wordt eerst naar het huidige wachtwoord gevraagd, dus houd dat bij de hand. Als een wijziging wordt onderbroken, voer _Drive Encryption_ dan opnieuw uit: dat vraagt naar het wachtwoord waarmee de schijf nu wordt ontgrendeld en voltooit de wijziging.

## Een machine doorgeven die je al hebt gebruikt

Als je je machine aan iemand anders overdraagt, hoef je hem niet opnieuw te installeren. Voer _Setup > Reset Computer_ uit in het Omarchy-menu, typ `reset` om te bevestigen en start opnieuw op. Dat wist elk gebruikersaccount en alles in `/home`, gooit alle pakketten en systeemwijzigingen weg die je sinds de installatie hebt aangebracht, en wist de identiteit van de machine — netwerkverbindingen, host keys, alles. Wat daarna weer opstart, is de setup-wizard van de eerste opstart, klaar voor de nieuwe eigenaar om een eigen naam, wachtwoord en versleutelingswachtwoord in te voeren.

Het werkt door de baseline-snapshot terug te zetten die het installatieprogramma maakt, dus het is alleen beschikbaar op machines die vanaf de Omarchy ISO zijn geïnstalleerd. En op een schijf zonder versleuteling is een reset een verwijdering in plaats van een veilige wissing, dus doe in plaats daarvan een verse installatie als de gegevens gevoelig waren.

## sudo zonder wachtwoord

Soms wil je dat `sudo` stopt met vragen, meestal wanneer een AI agent een lange reeks systeemwerk voor je doet. _Setup > Security > Passwordless Sudo_ vraagt hoe lang je toegang wilt toestaan: **15 minutes**, **1 Hour**, **1 Day** of **Permanently**. Er verschijnt een rood waarschuwingsicoon naast de andere indicatoren in de menubalk zolang de toegang actief is. Klik erop of voer de opdracht opnieuw uit om de toegang uit te schakelen. Je kunt ook je eigen aantal minuten (van 1 tot 1440) doorgeven met `omarchy-sudo-passwordless 30`, of `omarchy-sudo-passwordless permanent` gebruiken.

Toegang met een tijdslimiet verloopt automatisch, ook onmiddellijk na het hervatten uit een slaapstand waarmee de deadline is overschreden. De computer opnieuw opstarten beëindigt de toegang voortijdig. Permanente toegang overleeft herstarts en blijft ingeschakeld totdat je hem uitschakelt.

Het bijwerken of verwijderen van het instellingenpakket van Omarchy beëindigt elke tijdelijke toekenning voordat de ondersteuning voor het verlopen ervan verandert. Als de opdracht een autorisatie- of opruimfout meldt, los die dan op voordat je probeert een andere toekenning in te schakelen; een fout betekent niet dat toegang zonder wachtwoord inactief is.

Wees hier nuchter over: zolang dit aanstaat, kan alles wat als jouw gebruiker draait, alles als root doen zonder dat erom wordt gevraagd. Dat is precies de bedoeling, en dat is ook precies het risico.

## Ondertekeningssleutels

De openbare sleutel voor alle ISO-handtekeningen en Omarchy repo-pakketten is `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifieer op openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Het pakket `omarchy/omarchy-keyring` bevat deze sleutel ook en wordt gebruikt om eventuele updates naadloos uit te rollen.

Je vindt de handtekening voor elke ISO-release door .sig aan de URL toe te voegen. Zoals https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
