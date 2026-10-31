# Seguretat

Omarchy es pren la seguretat extremadament seriosament. Això vol ser un sistema operatiu que puguis fer servir per fer _Treball Real_ al _Món Real_. On perdre un portàtil no pot derivar en una emergència de seguretat. Així que això és el que fem:

1. *El xifratge complet del disc està activat per defecte*: Aquest és el pas més important per assegurar la protecció física de les teves dades. Si perds l'ordinador o te'l roben, les dades estan completament xifrades amb LUKS (Linux Unified Key Setup) estàndard. L'instal·lador et permet desactivar-ho per a màquines d'un sol ús (vegeu [Primers passos](02-getting-started.md)); una instal·lació sense xifratge no té gens d'aquesta protecció, i qualsevol que tingui el disc a les mans el pot llegir.
2. *El tallafoc està activat per defecte*: Tot el trànsit entrant està bloquejat per defecte, amb unes quantes excepcions: el port 53317 per a [LocalSend](https://localsend.org/); les consultes DNS al resolver propi de l'ordinador a l'adreça del pont de Docker (172.17.0.1), acceptades des dels intervals d'adreces privades que Docker dona als seus contenidors; i el DNS multicast (port 5353), que permet que les impressores i altres dispositius de la teva xarxa es trobin entre ells i també anuncia el nom del teu ordinador allà. A més d'aquestes, el tallafoc manté les concessions estàndard d'UFW per al ping, per obtenir una adreça del teu router (DHCP) i per al descobriment UPnP. Fins i tot ssh està desactivat fins que l'actives mitjançant _Setup > Security > SSHD_, que obre el port 22 (amb limitació de velocitat contra la força bruta) com a part de la configuració. Fins i tot tanquem l'accés a Docker amb la configuració [ufw-docker](https://github.com/chaifeng/ufw-docker) per evitar que els teus contenidors quedin exposats accidentalment al món.
3. *Arch sempre té les actualitzacions més recents*: Arch, la distribució subjacent sobre la qual es construeix Omarchy, és una distribució rolling. Això significa que qualsevol vulnerabilitat de seguretat que es descobreixi i es corregeixi en qualsevol paquet està disponible ràpidament per instal·lar amb `omarchy-update`. D'aquesta manera sempre executes les versions més recents i més segures de tot.
4. *Omarchy manté els seus propis paquets i mirall*: Per defecte, Omarchy només depèn de paquets dels repositoris core/extra/multilib propis d'Arch i del seu propi Omarchy Package Repository. Pots instal·lar programari directament des de l'AUR, però la instal·lació base no ho fa — només unes quantes instal·lacions opcionals, com els navegadors de tercers, provenen de l'AUR.
5. *Cloudflare ens protegeix dels DDoS*: La infraestructura de distribució d'Omarchy — les ISO, els paquets d'Omarchy, el mirall d'Arch — està protegida darrere del formidable escut contra DDoS de Cloudflare i allotjada a la seva CDN. Això proporciona una disponibilitat excel·lent.

## Canviar les contrasenyes

En una instal·lació xifrada tens dues contrasenyes: la que desbloqueja el disc a l'arrencada i la que fas servir per iniciar sessió i amb `sudo`. La configuració fa que siguin la mateixa. Totes dues es poden canviar a _Update > Password_ al menú d'Omarchy — _Drive Encryption_ per a la primera, _User_ per a la segona. Canviar la contrasenya del disc et demana primer l'actual, així que tingues-la a mà. Si un canvi s'interromp, executa _Drive Encryption_ de nou: et demana la contrasenya que desbloqueja el disc ara i acaba el canvi.

## Passar a algú altre una màquina que ja has fet servir

Si passes la teva màquina a algú altre, no cal que la reinstal·lis. Executa _Setup > Reset Computer_ al menú d'Omarchy, escriu `reset` per confirmar i reinicia. Això esborra tots els comptes d'usuari i tot el que hi ha a `/home`, descarta tots els paquets i canvis del sistema que hagis fet des de la instal·lació i neteja la identitat de la màquina — connexions de xarxa, claus de host i tot. El que torna a arrencar és l'assistent de configuració de la primera arrencada, preparat perquè el seu nou propietari introdueixi el seu propi nom, contrasenya i contrasenya de xifratge.

Funciona restaurant la instantània base que fa l'instal·lador, de manera que només està disponible en màquines instal·lades des de la ISO d'Omarchy. I en un disc sense xifratge, un restabliment és una supressió més que no pas un esborrat segur, així que si les dades eren sensibles, fes una instal·lació nova.

## Sudo sense contrasenya

De vegades vols que `sudo` deixi de demanar-la, molt sovint quan un agent d'IA està fent una llarga tirada de feina del sistema per tu. _Setup > Security > Passwordless Sudo_ et demana quant de temps vols permetre l'accés: **15 minuts**, **1 Hora**, **1 Dia** o **Permanentment**. Apareix una icona d'advertiment vermella al costat dels altres indicadors de la barra de menú mentre l'accés està actiu. Fes-hi clic o executa l'ordre de nou per desactivar l'accés. També pots passar el teu propi nombre de minuts (de l'1 al 1440) amb `omarchy-sudo-passwordless 30`, o fer servir `omarchy-sudo-passwordless permanent`.

L'accés temporitzat caduca automàticament, inclòs immediatament després de reprendre d'una suspensió que hagi creuat el termini. Reiniciar l'ordinador l'acaba abans d'hora. L'accés permanent sobreviu als reinicis i es manté activat fins que el desactivis.

Actualitzar o eliminar el paquet de configuració d'Omarchy acaba qualsevol concessió temporal abans que en canviï el suport de caducitat. Si l'ordre informa d'un error d'autorització o de neteja, resol-lo abans de provar d'activar una altra concessió; un error no significa que l'accés sense contrasenya estigui inactiu.

Tingues-ho clar: mentre està activat, qualsevol cosa que s'executi com el teu usuari pot fer qualsevol cosa com a root sense que se li demani. Aquesta és tota la gràcia, i també tot el risc.

## Claus de signatura

La clau pública per a totes les signatures de les ISO i el paquet del repositori d'Omarchy és `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica a openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). El paquet `omarchy/omarchy-keyring` també conté aquesta clau i s'utilitzarà per desplegar sense problemes qualsevol actualització potencial.

Pots trobar la signatura de qualsevol versió ISO afegint `.sig` a la seva URL, com `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
