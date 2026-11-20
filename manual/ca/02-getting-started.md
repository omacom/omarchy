# Primers passos

Omarchy s'instal·la amb una ISO. Pots triar entre una instal·lació a tot el disc, que ocupa tota la unitat, o una instal·lació a l'espai lliure, que posa Omarchy a l'espai no assignat d'una unitat — així és com fas una arrencada dual al costat de Windows o d'un altre sistema operatiu (consulta [instal·lació amb arrencada dual](50-dual-boot-install.md) — tingues en compte que abans hauràs de desactivar BitLocker a Windows). Sigui com sigui, la instal·lació xifra tot el disc per defecte, i l'opció de tot el disc esborrarà la unitat seleccionada, així que assegura't de fer una còpia de seguretat abans d'utilitzar-ne una d'existent!

[Descarrega la ISO d'Omarchy](https://omarchy.org/) primer, posa-la en una memòria USB (utilitza [Rufus](https://rufus.ie/) a Windows, [balenaEtcher](https://etcher.balena.io/) a Mac, o [caligula](https://github.com/ifd3f/caligula) a Linux), i arrenca des de la memòria.

_Has de desactivar Secure Boot i/o TPM a la BIOS. Has de desactivar-los per poder instal·lar Omarchy. Són esquemes de seguretat de Microsoft pensats per a Windows i per a distribucions de Linux afiliades a Microsoft._

Després respon les preguntes de configuració, i confirma-les així:

 ![install-config](images/install-config.webp)

Després selecciona una unitat per a la instal·lació, i seu i gaudeix de l'espectacle de la instal·lació. Es pot fer en menys d'un minut a les màquines modernes més ràpides, però no hauria de trigar més de 5 minuts ni tan sols en un ordinador més antic.

 ![install-done](images/install-done.webp)

Ara ja estàs a punt per a Omarchy!

### Fes servir un teclat amb cable o de 2.4ghz!

El xifratge de tot el disc no et permetrà introduir la contrasenya des d'un teclat Bluetooth a l'arrencada. Igual que no pots fer servir un teclat Bluetooth per entrar a la BIOS en un PC. Necessitaràs un teclat que utilitzi un adaptador de 2.4ghz o un cable (que de tota manera és molt millor per a la latència!). Personalment, m'encanta el [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instal·lació per a un altre propietari

Si estàs configurant una màquina per a algú altre — un familiar, un empleat nou, un comprador — no hauries de respondre les preguntes personals en nom seu. Prem `Ctrl + C` a la primera pantalla de l'instal·lador (la de selecció del teclat), i Omarchy t'oferirà preparar la màquina per a un altre propietari. El sistema s'instal·la immediatament, però tota la configuració personal — la disposició del teclat, el nom d'usuari, la contrasenya — es deixa per a quan la màquina arrenqui per primera vegada. La unitat continua xifrada per defecte, i la contrasenya que triï el nou propietari en aquesta primera arrencada esdevé també la contrasenya de xifratge. (Una màquina que ja has estat utilitzant també es pot lliurar sense reinstal·lar-la — consulta [restablir l'ordinador](48-security.md).)

### Instal·lacions desateses

La ISO també es pot instal·lar completament sola — sense teclat, sense assistent — quan rep la seva configuració en una segona unitat. Aquesta és la manera de tractar Omarchy com una imatge base per a VM i màquines d'una flota. Consulta [instal·lacions desateses](51-unattended-installs.md).

### Instal·lacions sense xifratge

Omarchy s'instal·la amb xifratge per defecte. És l'opció segura i responsable per a qualsevol ordinador que es pugui perdre o robar. No vols que ningú que tingui accés al teu maquinari pugui accedir a les teves dades!

Però en circumstàncies especials, com instal·lacions remotes d'Omarchy en ordinadors protegits o per a instal·lacions d'un sol ús sense dades sensibles, potser voldràs instal·lar sense xifratge. Pots prémer `Ctrl + C` a la confirmació de formatació del disc per canviar a una instal·lació sense xifratge.

### Idioma

Omarchy parla 50 idiomes — el mateix conjunt que omarchy.org — i l'anglès és el predeterminat. Per canviar-lo, obre el menú d'Omarchy i ves a _Setup > Region > Language_, o executa `omarchy language <code>` en un terminal (`omarchy language list` mostra els codis). El menú, l'escriptori i les notificacions pròpies d'Omarchy canvien d'idioma immediatament, i totes les aplicacions que obris després també. Les aplicacions que ja estaven obertes canvien quan les reinicies.

Per mantenir l'idioma però escriure les dates, les hores, els nombres, els diners, les unitats i les mides de paper com es fa en una altra regió (anglès amb dates europees i un rellotge de 24 hores, per exemple), tria una regió a _Setup > Region > Formats_, on cada opció mostra un exemple, o executa `omarchy region <code>` (`omarchy region list` mostra els codis). _Same as language_ torna als formats propis de l'idioma. Com un canvi d'idioma, arriba a les aplicacions que obris després.

### Ajuda si t'encalles

Si t'encalles, normalment pots trobar algú disposat a ajudar-te al canal _#omarchy-help_ de [Discord de la comunitat](https://omarchy.org/discord).
