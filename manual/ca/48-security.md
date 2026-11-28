# Seguretat

Omarchy es pren la seguretat molt seriosament. Això vol ser un sistema operatiu que pots fer servir per fer _Feina de Veritat_ en el _Món Real_. On perdre un portàtil no pot comportar una emergència de seguretat. Així que això és el que fem:

1. *El xifratge de disc complet està activat per defecte*: Aquest és el pas més important per garantir la protecció física de les teves dades. Si perds l'ordinador o te'l roben, les dades estan totalment xifrades amb el LUKS estàndard (Linux Unified Key Setup). L'instal·lador et permet desactivar-ho per a màquines d'un sol ús (consulta [Primers passos](02-getting-started.md)); una instal·lació sense xifratge no té res d'aquesta protecció, i qualsevol que tingui el disc a les mans el pot llegir.
2. *El tallafoc està activat per defecte*: Tot el trànsit entrant està bloquejat per defecte, amb unes quantes excepcions: el port 53317 per a [LocalSend](https://localsend.org/); les consultes DNS al resolutor propi de l'ordinador a l'adreça del pont de Docker (172.17.0.1), acceptades des dels intervals d'adreces privades que Docker assigna als seus contenidors; i el DNS multicast (port 5353), que permet que les impressores i altres dispositius de la teva xarxa es trobin entre ells i també hi anuncia el nom del teu ordinador. A més d'aquestes, el tallafoc manté els permisos estàndard d'UFW per al ping, per a obtenir una adreça del teu encaminador (DHCP) i per a la descoberta UPnP. Fins i tot ssh està desactivat fins que l'actives amb _Configuració > Seguretat > SSHD_, que autoritza la teva clau SSH, desactiva els inicis de sessió amb contrasenya i només llavors obre el port 22 (amb limitació de velocitat contra la força bruta). Fins i tot restringim l'accés a Docker amb la configuració [ufw-docker](https://github.com/chaifeng/ufw-docker) per evitar que els teus contenidors quedin exposats accidentalment al món.
3. *Arch sempre té les últimes actualitzacions*: Arch, la distribució subjacent sobre la qual es construeix Omarchy, és una distribució de publicació contínua. Això vol dir que qualsevol vulnerabilitat de seguretat que es descobreixi i es corregeixi en qualsevol paquet està disponible ràpidament per instal·lar-la amb `omarchy-update`. D'aquesta manera sempre executes les versions més recents i més segures de tot.
4. *Omarchy manté els seus propis paquets i la seva pròpia rèplica*: Per defecte, Omarchy només es basa en paquets dels repositoris core/extra/multilib propis d'Arch (els d'Arch Linux ARM a les màquines ARM, més Asahi ALARM a Apple Silicon) i en el seu propi Omarchy Package Repository. Pots instal·lar programari directament des de l'AUR, però la instal·lació base no ho fa: només unes quantes instal·lacions opcionals, com els navegadors de tercers, treuen paquets de l'AUR.
5. *Cloudflare ens protegeix dels DDoS*: La infraestructura de distribució d'Omarchy — les ISO, els paquets d'Omarchy, la rèplica d'Arch — està protegida darrere l'impressionant escut contra DDoS de Cloudflare i allotjada a la seva CDN. Això ofereix una disponibilitat excel·lent.

## Canviar les contrasenyes

En una instal·lació xifrada tens dues contrasenyes: la que desbloqueja el disc a l'arrencada i la que fas servir per iniciar sessió i per a `sudo`. La configuració inicial fa que siguin la mateixa. _Actualització > Contrasenya_ al menú d'Omarchy canvia totes dues alhora, de manera que es mantenen iguals: demana la contrasenya actual del disc, després la nova, canvia la del disc i després estableix la teva contrasenya d'inici de sessió perquè hi coincideixi. Sense xifratge de disc, només canvia la teva contrasenya d'inici de sessió. Si un canvi s'interromp, torna a executar _Actualització > Contrasenya_: demana la contrasenya que desbloqueja el disc ara, acaba el canvi i hi estableix la teva contrasenya d'inici de sessió. Per canviar la contrasenya d'un altre disc xifrat, executa `omarchy-drive-password` en un terminal.

## Passar una màquina que ja has fet servir

Si passes la teva màquina a algú altre, no cal que la reinstal·lis. Executa _Elimina > Restabliment de fàbrica_ al menú d'Omarchy, escriu `reset` per confirmar-ho, introdueix la contrasenya de xifratge del disc si te la demana i reinicia. Això esborra tots els comptes d'usuari i tot el que hi ha a `/home`, descarta tots els paquets i canvis del sistema que has fet des de la instal·lació i neteja la identitat de la màquina: connexions de xarxa, claus d'amfitrió i tot. El que torna a arrencar és l'assistent de configuració de la primera arrencada, a punt perquè el seu nou propietari introdueixi el seu propi nom, contrasenya i contrasenya de xifratge.

Funciona restaurant la instantània de referència que fa l'instal·lador, de manera que només està disponible en màquines instal·lades des de la ISO d'Omarchy. I en un disc sense xifratge, un restabliment és una supressió més que no pas un esborrat segur, de manera que si les dades eren sensibles, fes en comptes d'això una instal·lació des de zero.

## sudo sense contrasenya

De vegades vols que `sudo` deixi de demanar, molt sovint quan un agent d'IA fa una llarga estona de treball de sistema per tu. _Configuració > Seguretat > Sudo sense contrasenya_ demana quant de temps vols permetre l'accés: **15 minuts**, **1 hora**, **1 dia** o **Permanentment**. Mentre l'accés està actiu, apareix una icona d'advertiment vermella al costat dels altres indicadors de la barra de menú. Fes-hi clic o torna a executar l'ordre per desactivar l'accés. També pots passar el teu propi nombre de minuts (d'1 a 1440) amb `omarchy-sudo-passwordless 30`, o fer servir `omarchy-sudo-passwordless permanent`.

L'accés temporal caduca automàticament, també immediatament després de reprendre d'una suspensió que hagi superat el termini. Reiniciar l'ordinador l'acaba abans d'hora. L'accés permanent sobreviu als reinicis i es manté activat fins que el desactivis.

Actualitzar o eliminar el paquet de configuració d'Omarchy acaba qualsevol concessió temporal abans que canviï el seu suport de caducitat. Si l'ordre informa d'un error d'autorització o de neteja, resol-lo abans de provar d'activar una altra concessió; un error no vol dir que l'accés sense contrasenya estigui inactiu.

Tingues els ulls ben oberts amb això: mentre està activat, qualsevol cosa que s'executi com el teu usuari pot fer el que sigui com a root sense que se li demani. Aquesta és tota la gràcia, i també és tot el risc.

## Claus de signatura

La clau pública per a totes les signatures d'ISO i el paquet del repositori d'Omarchy és `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica-la a openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). El paquet `omarchy/omarchy-keyring` també la conté i es farà servir per desplegar sense problemes qualsevol possible actualització.

Pots trobar la signatura de qualsevol versió d'ISO afegint `.sig` a la seva URL, com ara `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
