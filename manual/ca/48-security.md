# Seguretat

Omarchy es pren la seguretat extremadament seriosament. Això vol ser un sistema operatiu que puguis fer servir per fer _Feina de Veritat_ en el _Món Real_. On perdre un portàtil no pugui derivar en una emergència de seguretat. Així que això és el que fem:

1. *El xifratge de disc complet està activat per defecte*: Aquest és el pas més important per assegurar la protecció física de les teves dades. Si perds l'ordinador o te'l roben, les dades estan completament xifrades fent servir LUKS (Linux Unified Key Setup) estàndard. L'instal·lador et permet desactivar-ho per a màquines d'un sol ús (consulta [Primers passos](02-getting-started.md)); una instal·lació sense xifratge no té gens d'aquesta protecció, i qualsevol que tingui la unitat la pot llegir.
2. *El tallafocs està activat per defecte*: Tot el trànsit entrant està bloquejat per defecte, amb unes quantes excepcions: el port 53317 per a [LocalSend](https://localsend.org/); les consultes DNS al resolutor propi de l'ordinador a l'adreça del pont de Docker (172.17.0.1), acceptades des dels intervals d'adreces privades que Docker dona als seus contenidors; i el DNS de multidifusió (port 5353), que permet que les impressores i altres dispositius de la teva xarxa es trobin entre ells i també hi anuncia el nom del teu ordinador. A més d'aquestes, el tallafocs manté els permisos estàndard d'UFW per a ping, obtenir una adreça del teu encaminador (DHCP) i la descoberta UPnP. Fins i tot ssh està desactivat fins que l'actives via _Configuració > Seguretat > SSHD_, que obre el port 22 (amb limitació de velocitat contra la força bruta) com a part de la configuració. Fins i tot bloquegem l'accés a Docker fent servir la configuració [ufw-docker](https://github.com/chaifeng/ufw-docker) per evitar que els teus contenidors quedin exposats al món accidentalment.
3. *Arch sempre té les actualitzacions més recents*: Arch, la distribució subjacent sobre la qual està construït Omarchy, és una distribució de llançament continu. Això vol dir que qualsevol vulnerabilitat de seguretat que es descobreixi i es corregeixi en qualsevol paquet estarà disponible ràpidament per instal·lar amb `omarchy-update`. D'aquesta manera, sempre executes les versions més recents i segures de tot.
4. *Omarchy manté els seus propis paquets i mirall*: Per defecte, Omarchy només depèn de paquets dels repositoris core/extra/multilib propis d'Arch i del seu propi Repositori de Paquets d'Omarchy. Pots instal·lar programari directament des de l'AUR, però la instal·lació base no ho fa — només unes quantes instal·lacions opcionals, com els navegadors de tercers, recorren a l'AUR.
5. *Cloudflare ens protegeix dels DDoS*: La infraestructura de distribució d'Omarchy — les ISO, els paquets d'Omarchy, el mirall d'Arch — està protegida darrere del formidable escut contra DDoS de Cloudflare i allotjada a la seva CDN. Això proporciona una disponibilitat excel·lent.

## Canviar les teves contrasenyes

Tens dues contrasenyes en una instal·lació xifrada: la que desbloqueja la unitat en arrencar, i la que fas servir per iniciar sessió i amb `sudo`. La configuració fa que siguin la mateixa. Totes dues es poden canviar a _Actualitza > Contrasenya_ al menú d'Omarchy — _Xifratge de la unitat_ per a la primera, _Usuari_ per a la segona. Canviar la contrasenya de la unitat et demana primer l'actual, així que tingues-la a mà. Si un canvi s'interromp, executa _Xifratge de la unitat_ una altra vegada: et demana la contrasenya que desbloqueja la unitat ara i acaba el canvi.

## Cedir una màquina que ja has fet servir

Si cedeixes la teva màquina a algú altre, no cal que la reinstal·lis. Executa _Elimina > Restabliment de fàbrica_ al menú d'Omarchy, escriu `reset` per confirmar-ho, i reinicia. Això esborra tots els comptes d'usuari i tot el que hi ha a `/home`, llença tots els paquets i canvis del sistema que hagis fet des de la instal·lació, i neteja la identitat de la màquina — connexions de xarxa, claus d'amfitrió i tot. El que torna a arrencar és l'assistent de configuració de la primera arrencada, preparat perquè el seu nou propietari hi introdueixi el seu propi nom, contrasenya i contrasenya de xifratge.

Funciona restaurant la instantània de referència que fa l'instal·lador, així que només està disponible en màquines instal·lades des de la ISO d'Omarchy. I en una unitat sense xifratge, un restabliment és una eliminació i no un esborrat segur, així que si les dades eren sensibles, fes una instal·lació nova.

## sudo sense contrasenya

De vegades vols que `sudo` deixi de demanar-te-la, més sovint quan un agent d'IA està fent un llarg tram de feina del sistema per tu. _Configuració > Seguretat > Sudo sense contrasenya_ et demana quanta estona vols permetre l'accés: **15 minuts**, **1 Hora**, **1 Dia** o **Permanentment**. Apareix una icona d'avís vermella al costat dels altres indicadors de la barra de menús mentre l'accés està actiu. Fes-hi clic o executa l'ordre una altra vegada per desactivar l'accés. També pots passar el teu propi nombre de minuts (d'1 a 1440) amb `omarchy-sudo-passwordless 30`, o fer servir `omarchy-sudo-passwordless permanent`.

L'accés temporal caduca automàticament, inclòs immediatament després de reprendre d'una suspensió que hagi creuat el termini. Reiniciar l'ordinador l'acaba abans d'hora. L'accés permanent sobreviu als reinicis i es manté activat fins que el desactivis.

Actualitzar o eliminar el paquet de configuració d'Omarchy acaba qualsevol concessió temporal abans que canviï el seu suport de caducitat. Si l'ordre informa d'un error d'autorització o de neteja, resol-lo abans de provar d'activar una altra concessió; un error no vol dir que l'accés sense contrasenya estigui inactiu.

Sigues lúcid amb això: mentre està activat, qualsevol cosa que s'executi com el teu usuari pot fer qualsevol cosa com a root sense que se li demani. Aquesta és tota la gràcia, i també és tot el risc.

## Claus de signatura

La clau pública per a totes les signatures d'ISO i el paquet del repositori d'Omarchy és `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica-ho a openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). El paquet `omarchy/omarchy-keyring` també la conté i es farà servir per desplegar qualsevol possible actualització sense problemes.

Pots trobar la signatura de qualsevol llançament d'ISO afegint `.sig` a la seva URL, com `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
