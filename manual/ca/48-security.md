# Seguretat

Omarchy es pren la seguretat extremadament seriosament. Això vol ser un sistema operatiu que pots fer servir per fer _Feina de Veritat_ al _Món Real_. On perdre un portàtil no pot dur a una emergència de seguretat. Així que això és el que fem:

1. *El xifratge complet del disc és obligatori*: aquest és el pas més important per assegurar la protecció física de les teves dades. Si el teu ordinador es perd o te'l roben, les dades estan completament xifrades fent servir LUKS (Linux Unified Key Setup) estàndard.
2. *El tallafoc està activat per defecte*: tot el trànsit entrant es bloqueja per defecte excepte el port 53317 per a [LocalSend](https://localsend.org/). Fins i tot ssh està desactivat fins que l'actives via _Configuració > Seguretat > SSHD_, que obre el port 22 (amb limitació de taxa contra la força bruta) com a part de la configuració. Fins i tot tanquem l'accés a Docker fent servir la configuració [ufw-docker](https://github.com/chaifeng/ufw-docker) per impedir que els teus contenidors s'exposin accidentalment al món.
3. *Arch sempre té les últimes actualitzacions*: Arch, la distribució subjacent sobre la qual està construït Omarchy, és una distribució en continu. Això vol dir que qualsevol vulnerabilitat de seguretat que es descobreixi i es pedaci en qualsevol paquet està disponible ràpidament per instal·lar fent servir `omarchy-update`. D'aquesta manera sempre executes les versions més recents i més segures de tot.
4. *Omarchy manté els seus propis paquets i rèplica*: Omarchy només es basa per defecte en paquets dels dipòsits core/extra/multilib del mateix Arch i del seu propi Omarchy Package Repository. Pots instal·lar programari directament des d'AUR, però la instal·lació base no: només unes poques instal·lacions opcionals, com els navegadors de tercers, provenen d'AUR.
5. *Cloudflare ens protegeix dels DDoS*: tota la infraestructura de distribució d'Omarchy —les ISO, els paquets d'Omarchy, la rèplica d'Arch— està protegida darrere del formidable escut DDoS de Cloudflare i allotjada a la seva CDN. Això proporciona una disponibilitat excel·lent.

## Canviar les teves contrasenyes

En una instal·lació xifrada tens dues contrasenyes: la que desbloqueja la unitat en arrencar i la que fas servir per iniciar sessió i per a `sudo`. La configuració les fa coincidir. Totes dues es poden canviar a _Actualitza > Contrasenya_ al menú d'Omarchy: _Xifratge de la unitat_ per a la primera, _Usuari_ per a la segona. Canviar la contrasenya de la unitat demana primer l'actual, així que tingues-la a mà. Si un canvi s'interromp, executa _Xifratge de la unitat_ una altra vegada: demanarà la contrasenya que ara desbloqueja la unitat i acabarà el canvi.

## Passar a algú més una màquina que ja has fet servir

Si estàs entregant la teva màquina a algú altre, no l'has de reinstal·lar. Executa _Configuració > Restableix l'ordinador_ al menú d'Omarchy, escriu `reset` per confirmar-ho i reinicia. Això esborra tots els comptes d'usuari i tot el que hi ha a `/home`, llença tots els paquets i els canvis del sistema que has fet des de la instal·lació, i neteja la identitat de la màquina: connexions de xarxa, claus d'amfitrió i tot. El que torna a aparèixer és l'assistent de configuració de la primera arrencada, a punt perquè el seu nou propietari introdueixi el seu propi nom, contrasenya i contrasenya de xifratge.

Funciona restaurant la instantània de referència que fa l'instal·lador, de manera que només està disponible a les màquines instal·lades des de la ISO d'Omarchy. I en una unitat sense xifratge, un restabliment és una supressió i no un esborrament segur, de manera que si les dades eren sensibles, fes en comptes d'això una instal·lació nova.

## Sudo sense contrasenya

De vegades vols que `sudo` deixi de demanar, molt sovint quan un agent d'IA està fent una llarga tongada de feina de sistema per tu. _Configuració > Seguretat > Sudo sense contrasenya_ pregunta quant de temps s'ha de permetre l'accés: **15 minutes**, **1 Hour**, **1 Day** o **Permanently**. Apareix una icona d'avís vermella al costat dels altres indicadors de la barra de menú mentre l'accés és actiu. Clica-la o torna a executar l'ordre per desactivar l'accés. També pots passar el teu propi nombre de minuts (d'1 a 1440) amb `omarchy-sudo-passwordless 30`, o fer servir `omarchy-sudo-passwordless permanent`.

L'accés temporitzat caduca automàticament, fins i tot immediatament després de reprendre d'una suspensió que ha travessat la data límit. Reiniciar l'ordinador l'acaba abans. L'accés permanent sobreviu als reinicis i continua activat fins que el desactivis.

Actualitzar o eliminar el paquet de configuració d'Omarchy acaba qualsevol concessió temporal abans que canviï el seu suport de caducitat. Si l'ordre informa d'un error d'autorització o de neteja, resol-lo abans de provar d'activar una altra concessió; un error no vol dir que l'accés sense contrasenya sigui inactiu.

Que quedi clar: mentre això està activat, qualsevol cosa que s'executi com el teu usuari pot fer qualsevol cosa com a root sense que se li demani. D'això es tracta exactament, i també és tot el risc.

## Claus de signatura

La clau pública per a totes les signatures de les ISO i els paquets del dipòsit d'Omarchy és `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica-la a openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). El paquet `omarchy/omarchy-keyring` també la conté i es farà servir per desplegar sense problemes qualsevol possible actualització.

Pots trobar la signatura de qualsevol llançament d'ISO afegint .sig a l'URL. Com https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
