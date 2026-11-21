# Primers passos

Omarchy s'instal·la amb una ISO. Pots triar entre una instal·lació a tot el disc, que ocupa tota la unitat, o una instal·lació a l'espai lliure, que col·loca Omarchy a l'espai no assignat d'una unitat — així és com fas arrencada dual al costat de Windows o d'un altre sistema operatiu (consulta [instal·lació amb arrencada dual](50-dual-boot-install.md) — tingues en compte que abans hauràs de desactivar BitLocker a Windows). En tots dos casos, la instal·lació activa el xifratge complet per defecte, i l'opció de tot el disc esborrarà la unitat seleccionada, així que assegura't de fer una còpia de seguretat abans d'utilitzar-ne una d'existent!

[Descarrega la ISO d'Omarchy](https://omarchy.org/) primer, posa-la en una memòria USB (utilitza [Rufus](https://rufus.ie/) a Windows, [balenaEtcher](https://etcher.balena.io/) a Mac, o [caligula](https://github.com/ifd3f/caligula) a Linux), i arrenca des de la memòria.

_Has de desactivar Secure Boot i/o TPM a la BIOS. Has de desactivar-los per poder instal·lar Omarchy. Són esquemes de seguretat de Microsoft pensats per a Windows i per a distribucions de Linux afiliades a Microsoft._

Després respon les preguntes de configuració, i confirma-les així:

 ![install-config](images/install-config.webp)

Després selecciona una unitat per a la instal·lació, i seu i gaudeix de l'espectacle de la instal·lació. Es pot fer en menys d'un minut en les màquines modernes més ràpides, però no hauria de trigar més de 5 minuts ni tan sols en un ordinador més antic.

 ![install-done](images/install-done.webp)

Ara ja estàs preparat per a Omarchy!

### Utilitza un teclat amb cable o de 2.4ghz!

El xifratge de tot el disc no et permetrà introduir la contrasenya des d'un teclat Bluetooth a l'inici. Igual que no pots utilitzar un teclat Bluetooth per entrar a la BIOS d'un PC. Necessitaràs un teclat que utilitzi un adaptador de 2.4ghz o un cable (que de tota manera és molt millor per a la latència!). Personalment, m'encanta el [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instal·lació per a un altre propietari

Si estàs configurant una màquina per a una altra persona — un familiar, un empleat nou, un comprador — no hauries de respondre les preguntes personals en nom seu. Prem `Ctrl + C` a la primera pantalla de l'instal·lador (la selecció de teclat), i Omarchy t'oferirà preparar la màquina per a un altre propietari. El sistema s'instal·la immediatament, però tota la configuració personal — disposició del teclat, nom d'usuari, contrasenya — es posposa fins que la màquina arrenca per primera vegada. La unitat continua xifrada per defecte, i la contrasenya que el nou propietari tria en aquesta primera arrencada també esdevé la contrasenya de xifratge. (Una màquina que ja has estat utilitzant també es pot lliurar sense reinstal·lar-la — consulta [restabliment de l'ordinador](48-security.md).)

### Instal·lacions desateses

La ISO també es pot instal·lar completament sola — sense teclat, sense assistent — quan rep la seva configuració en una segona unitat. Aquesta és la manera de tractar Omarchy com una imatge base per a VM i màquines d'una flota. Consulta [instal·lacions desateses](51-unattended-installs.md).

### Instal·lacions sense xifratge

Omarchy s'instal·la amb xifratge per defecte. És l'opció segura i responsable per a qualsevol ordinador que es pugui perdre o robar. No vols que ningú amb accés al teu maquinari pugui accedir a les teves dades!

Però en circumstàncies especials, com instal·lacions remotes d'Omarchy en ordinadors protegits o per a instal·lacions d'un sol ús sense dades sensibles, és possible que vulguis instal·lar sense xifratge. Pots prémer `Ctrl + C` a la confirmació de formatació del disc per canviar a una instal·lació sense xifratge.

### Idioma

Omarchy parla 50 idiomes — el mateix conjunt que omarchy.org — i l'anglès és el predeterminat. Per canviar-lo, obre el menú d'Omarchy i ves a _Configuració > Regió > Idioma_, o executa `omarchy language <code>` en un terminal (`omarchy language list` mostra els codis). El menú, l'escriptori i les notificacions pròpies d'Omarchy canvien d'idioma immediatament, i totes les aplicacions que obris després també ho fan. Les aplicacions que ja estaven obertes canvien quan les reinicies.

Per mantenir l'idioma però escriure dates, hores, nombres, diners, unitats i mides de paper com ho fa una altra regió (anglès amb dates europees i un rellotge de 24 hores, per exemple), tria una regió a _Configuració > Regió > Formats_, on cada opció mostra un exemple, o executa `omarchy region formats <code>` (`omarchy region formats list` mostra els codis). _Igual que l'idioma_ torna als formats propis de l'idioma. Com un canvi d'idioma, arriba a les aplicacions que obris després.

### Ajuda si et quedes encallat

Si et quedes encallat, normalment pots trobar algú disposat a ajudar-te al canal _#omarchy-help_ de [el Discord de la comunitat](https://omarchy.org/discord).
