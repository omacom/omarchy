# Primers passos

Omarchy s'instal·la fent servir una ISO. Pots triar entre una instal·lació de disc complet, que s'apodera de tota la unitat, o una instal·lació en l'espai lliure, que posa Omarchy a l'espai no assignat d'una unitat — així és com arrenques en dual boot al costat de Windows o d'un altre OS (consulta [instal·lació en dual boot](50-dual-boot-install.md) — tingues en compte que primer hauràs de desactivar BitLocker a Windows). Sigui com sigui, la instal·lació fa servir per defecte el xifratge complet, i l'opció de disc complet esborrarà la unitat seleccionada, així que assegura't de fer una còpia de seguretat abans de fer servir una unitat existent!

[Descarrega primer la ISO d'Omarchy](https://omarchy.org/), posa-la en una memòria USB (fes servir [balenaEtcher](https://etcher.balena.io/) a Mac/Windows o [caligula](https://github.com/ifd3f/caligula) a Linux), i arrenca des de la memòria.

_Has de desactivar Secure Boot i/o TPM a la BIOS. Has de desactivar-los per poder instal·lar Omarchy. Són esquemes de seguretat de Microsoft pensats per a Windows i per a distribucions de Linux afiliades a Microsoft._

Després respon les preguntes de configuració, i confirma-les així:

 ![install-config](images/install-config.webp)

Després selecciona una unitat per a la teva instal·lació, relaxa't i mira com passa l'espectacle de la instal·lació. Es pot fer en menys d'un minut en les màquines modernes més ràpides, però no hauria de trigar més de 5 minuts ni tan sols en un ordinador més vell.

 ![install-done](images/install-done.webp)

Ara ja estàs llest per fer Omarchy!

### Fes servir un teclat amb cable o de 2.4ghz!

El xifratge de disc complet no et permetrà introduir la contrasenya des d'un teclat Bluetooth en arrencar. Igual que no pots fer servir un teclat Bluetooth per entrar a la BIOS en un PC. Necessitaràs un teclat que faci servir un dongle de 2.4ghz o un cable (que de totes maneres és molt millor per a la latència!). Personalment, m'encanta el [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instal·lar per a un altre propietari

Si estàs preparant una màquina per a una altra persona — un familiar, un empleat nou, un comprador — no hauries de respondre les preguntes personals en nom seu. Prem `Ctrl + C` a la primera pantalla de l'instal·lador (la selecció de teclat), i Omarchy s'oferirà a preparar la màquina per a un altre propietari. El sistema s'instal·la de seguida, però tota la configuració personal — distribució de teclat, nom d'usuari, contrasenya — es posposa fins que la màquina arrenca per primera vegada. La unitat continua xifrada per defecte, i la contrasenya que el nou propietari triï en aquesta primera arrencada es converteix també en la contrasenya de xifratge. (Una màquina que ja hagis fet servir també es pot lliurar sense reinstal·lar-la — consulta [restablir l'ordinador](48-security.md).)

### Instal·lacions desateses

La ISO també es pot instal·lar completament sola — sense teclat, sense assistent — quan se li lliura la configuració en una segona unitat. Així és com es tracta Omarchy com a imatge base per a VMs i màquines d'una flota. Consulta [instal·lacions desateses](51-unattended-installs.md).

### Instal·lacions sense xifratge

Omarchy s'instal·la amb xifratge per defecte. És l'opció segura i responsable per a qualsevol ordinador que possiblement es pugui perdre o ser robat. No vols que ningú amb accés al teu maquinari pugui obtenir les teves dades!

Però en circumstàncies especials, com ara instal·lacions remotes d'Omarchy en ordinadors protegits o per a instal·lacions d'un sol ús sense dades sensibles, potser vols instal·lar sense xifratge. Pots prémer `Ctrl + C` a la confirmació de formatatge del disc per passar a una instal·lació sense xifratge.

### Idioma

Omarchy parla 50 idiomes — el mateix conjunt que omarchy.org — i l'anglès és el predeterminat. Per canviar-lo, obre el menú d'Omarchy i ves a _Setup > Language_, o executa `omarchy language <code>` en un terminal (`omarchy language list` mostra els codis). El menú, l'escriptori i les notificacions pròpies d'Omarchy canvien d'idioma immediatament, i totes les aplicacions que obris després també hi segueixen. Les aplicacions que ja estaven obertes canvien un cop les reinicies.

### Ajuda si t'encalles

Si t'encalles, normalment pots trobar algú disposat a ajudar al canal _#omarchy-help_ del [Discord de la comunitat](https://omarchy.org/discord).
