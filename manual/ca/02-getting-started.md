# Primers passos

Omarchy s'instal·la amb una ISO. Pots triar entre una instal·lació en disc complet, que ocupa tot el disc, o una instal·lació en espai lliure, que posa Omarchy a l'espai no assignat d'un disc — així és com fas una arrencada dual al costat de Windows o d'un altre sistema operatiu (consulta [instal·lació amb arrencada dual](50-dual-boot-install.md) — tingues en compte que abans hauràs de desactivar BitLocker a Windows). Sigui com sigui, la instal·lació fa servir xifratge complet per defecte, i l'opció de disc complet esborrarà el disc seleccionat, així que assegura't de fer una còpia de seguretat abans de fer servir un disc existent!

[Descarrega la ISO d'Omarchy](https://omarchy.org/) primer, posa-la en una memòria USB (fes servir [Rufus](https://rufus.ie/) a Windows, [balenaEtcher](https://etcher.balena.io/) a Mac, o [caligula](https://github.com/ifd3f/caligula) a Linux), i arrenca des de la memòria.

_Has de desactivar Secure Boot i/o TPM a la BIOS. Has de desactivar-los per poder instal·lar Omarchy. Són esquemes de seguretat de Microsoft pensats per a Windows i per a distribucions de Linux afiliades a Microsoft._

Després respon les preguntes de configuració i confirma-les així:

 ![install-config](images/install-config.webp)

Després selecciona un disc per a la teva instal·lació, i seu i mira l'espectacle de la instal·lació. Es pot fer en menys d'un minut en les màquines modernes més ràpides, però no hauria de trigar més de 5 minuts ni tan sols en un ordinador més antic.

 ![install-done](images/install-done.webp)

Ara ja estàs a punt per fer Omarchy!

### Fes servir un teclat amb cable o de 2.4ghz!

El xifratge complet del disc no et permetrà introduir la contrasenya des d'un teclat Bluetooth a l'arrencada. Igual que no pots fer servir un teclat Bluetooth per entrar a la BIOS d'un PC. Necessitaràs un teclat que faci servir o bé un dongle de 2.4ghz o bé un cable (que de totes maneres és molt millor per a la latència!). Personalment, m'encanta el [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instal·lació per a un altre propietari

Si estàs preparant una màquina per a algú altre — un familiar, un nou empleat, un comprador — no hauries de respondre les preguntes personals en nom seu. Prem `Ctrl + C` a la primera pantalla de l'instal·lador (la de selecció del teclat), i Omarchy t'oferirà preparar la màquina per a un altre propietari. El sistema s'instal·la immediatament, però tota la configuració personal — distribució del teclat, nom d'usuari, contrasenya — es posposa fins que la màquina arrenca per primera vegada. El disc continua xifrat per defecte, i la contrasenya que el nou propietari tria en aquesta primera arrencada es converteix també en la contrasenya de xifratge. (Una màquina que ja has estat fent servir també es pot lliurar sense reinstal·lar-la — consulta [restablir l'ordinador](48-security.md).)

### Instal·lacions desateses

La ISO també es pot instal·lar completament sola — sense teclat, sense assistent — quan rep la seva configuració en un segon disc. Aquesta és la manera de tractar Omarchy com una imatge base per a VM i màquines de flota. Consulta [instal·lacions desateses](51-unattended-installs.md).

### Instal·lacions sense xifratge

Omarchy s'instal·la amb xifratge per defecte. És l'opció segura i responsable per a qualsevol ordinador que pugui perdre's o ser robat. No vols que ningú que tingui accés al teu maquinari pugui obtenir les teves dades!

Però en circumstàncies especials, com instal·lacions remotes d'Omarchy en ordinadors protegits o per a instal·lacions d'usar i llençar sense dades sensibles, potser vols instal·lar sense xifratge. Pots prémer `Ctrl + C` a la confirmació de formatació del disc per canviar a una instal·lació sense xifratge.

### Idioma

Omarchy parla 50 idiomes — el mateix conjunt que omarchy.org — i l'anglès és el predeterminat. Per canviar-ho, obre el menú d'Omarchy i vés a _Setup > Language_, o executa `omarchy language <code>` en un terminal (`omarchy language list` mostra els codis). El menú, l'escriptori i les notificacions pròpies d'Omarchy canvien d'idioma immediatament, i totes les aplicacions que obris després també. Les aplicacions que ja estaven obertes canvien quan les reinicies.

### Ajuda si et quedes encallat

Si et quedes encallat, normalment pots trobar algú disposat a ajudar-te al canal _#omarchy-help_ del [Discord de la comunitat](https://omarchy.org/discord).
