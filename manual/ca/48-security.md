# Seguretat

Omarchy es pren la seguretat extremadament seriosament. Això vol ser un sistema operatiu que puguis fer servir per fer _Feina de Veritat_ en el _Món Real_. On perdre un portàtil no pot comportar una emergència de seguretat. Així que això és el que fem:

1. *El xifratge complet del disc és obligatori*: Aquest és el pas més important per assegurar la protecció física de les teves dades. Si perds l'ordinador o te'l roben, les dades estan completament xifrades amb el LUKS estàndard (Linux Unified Key Setup).
2. *El tallafoc està activat per defecte*: Tot el trànsit entrant està bloquejat per defecte excepte el port 53317 per a [LocalSend](https://localsend.org/). Fins i tot l'ssh està desactivat fins que l'actives mitjançant _Setup > Security > SSHD_, la qual cosa obre el port 22 (amb limitació de velocitat contra la força bruta) com a part de la configuració. Fins i tot restringim l'accés a Docker amb la configuració [ufw-docker](https://github.com/chaifeng/ufw-docker) per evitar que els teus contenidors quedin exposats accidentalment al món.
3. *Arch sempre té les últimes actualitzacions*: Arch, la distribució subjacent sobre la qual es construeix Omarchy, és una distribució rolling. Això significa que qualsevol vulnerabilitat de seguretat que es descobreixi i es corregeixi en qualsevol paquet estarà disponible ràpidament per instal·lar-la amb `omarchy-update`. D'aquesta manera, sempre executes les versions més recents i segures de tot.
4. *Omarchy manté els seus propis paquets i rèplica*: Per defecte, Omarchy només depèn de paquets dels repositoris core/extra/multilib del mateix Arch i del seu propi Omarchy Package Repository. Pots instal·lar programari directament des de l'AUR, però la instal·lació base no ho fa — només unes quantes instal·lacions opcionals, com els navegadors de tercers, provenen de l'AUR.
5. *Cloudflare ens protegeix dels DDoS*: La infraestructura de distribució d'Omarchy — les ISO, els paquets d'Omarchy, la rèplica d'Arch — està protegida darrere el formidable escut contra DDoS de Cloudflare i allotjada a la seva CDN. Això proporciona una disponibilitat excel·lent.

## Canviar les contrasenyes

Tens dues contrasenyes en una instal·lació xifrada: la que desbloqueja la unitat en arrencar, i la que fas servir per iniciar sessió i amb `sudo`. La configuració fa que siguin la mateixa. Totes dues es poden canviar a _Update > Password_ al menú d'Omarchy — _Drive Encryption_ per a la primera, _User_ per a la segona. Canviar la contrasenya de la unitat demana primer l'actual, així que tingues-la a mà. Si un canvi s'interromp, executa _Drive Encryption_ una altra vegada: demana la contrasenya que desbloqueja la unitat ara i acaba el canvi.

## Passar a algú altre una màquina que ja has utilitzat

Si passes la teva màquina a algú altre, no cal que la reinstal·lis. Executa _Setup > Reset Computer_ al menú d'Omarchy, escriu `reset` per confirmar-ho i reinicia. Això esborra tots els comptes d'usuari i tot el que hi ha a `/home`, descarta tots els paquets i canvis del sistema que hagis fet des de la instal·lació, i neteja la identitat de la màquina — connexions de xarxa, claus d'amfitrió i tot. El que torna a arrencar és l'assistent de configuració de la primera arrencada, preparat perquè el seu nou propietari introdueixi el seu propi nom, contrasenya i contrasenya de xifratge.

Funciona restaurant la instantània de referència que fa l'instal·lador, de manera que només està disponible en màquines instal·lades des de la ISO d'Omarchy. I en una unitat sense xifratge, un restabliment és una supressió i no un esborrat segur, de manera que si les dades eren sensibles, fes en comptes d'això una instal·lació nova.

## Sudo sense contrasenya

De vegades vols que `sudo` deixi de demanar-la, molt sovint quan un agent d'IA està fent un llarg tram de feina del sistema per tu. _Setup > Security > Passwordless Sudo_ demana quant de temps vols permetre l'accés: **15 minuts**, **1 hora**, **1 dia** o **permanentment**. Apareix una icona d'advertiment vermella al costat dels altres indicadors de la barra de menú mentre l'accés està actiu. Fes-hi clic o executa l'ordre una altra vegada per desactivar l'accés. També pots passar el teu propi nombre de minuts (d'1 a 1440) amb `omarchy-sudo-passwordless 30`, o fer servir `omarchy-sudo-passwordless permanent`.

L'accés temporitzat caduca automàticament, inclòs immediatament després de reprendre d'una suspensió que hagi superat el termini. Reiniciar l'ordinador l'acaba abans d'hora. L'accés permanent sobreviu als reinicis i es manté activat fins que el desactivis.

Actualitzar o eliminar el paquet de configuració d'Omarchy acaba qualsevol concessió temporal abans que canviï el seu suport de caducitat. Si l'ordre informa d'un error d'autorització o de neteja, resol-lo abans d'intentar activar una altra concessió; un error no significa que l'accés sense contrasenya estigui inactiu.

Sigues-ne ben conscient: mentre està activat, qualsevol cosa que s'executi com el teu usuari pot fer qualsevol cosa com a root sense que se li demani. Aquesta és tota la gràcia, i també tot el risc.

## Claus de signatura

La clau pública per a totes les signatures de les ISO i el paquet del repositori d'Omarchy és `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica-la a openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). El paquet `omarchy/omarchy-keyring` també la conté i s'utilitzarà per desplegar sense problemes qualsevol possible actualització.

Pots trobar la signatura de qualsevol versió ISO afegint .sig a l'URL. Com https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
