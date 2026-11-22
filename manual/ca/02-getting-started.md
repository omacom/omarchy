# Primers passos

Omarchy s'instal·la amb una ISO. Pots triar entre una instal·lació de disc complet, que ocupa tot el disc, o una instal·lació en espai lliure, que posa Omarchy a l'espai no assignat d'un disc — així és com fas l'arrencada dual al costat de Windows o d'un altre sistema operatiu (consulta [instal·lació amb arrencada dual](50-dual-boot-install.md) — tingues en compte que abans hauràs de desactivar BitLocker a Windows). En qualsevol cas, la instal·lació xifra tot el disc per defecte, i l'opció de disc complet esborrarà el disc seleccionat, així que assegura't de fer una còpia de seguretat abans d'utilitzar-ne un d'existent!

En un Mac amb Apple Silicon, fas la instal·lació des de macOS, sense ISO ni memòria USB. Consulta [Omarchy per a Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Descarrega la ISO d'Omarchy](https://omarchy.org/) primer, posa-la en una memòria USB (utilitza [Rufus](https://rufus.ie/) a Windows, [balenaEtcher](https://etcher.balena.io/) a Mac, o [caligula](https://github.com/ifd3f/caligula) a Linux), i arrenca des de la memòria.

_Has de desactivar Secure Boot i/o TPM a la BIOS. Has de desactivar-los per poder instal·lar Omarchy. Són esquemes de seguretat de Microsoft pensats per a Windows i per a distribucions de Linux afiliades a Microsoft._

Després respon les preguntes de configuració i confirma-les així:

 ![install-config](images/install-config.webp)

Després selecciona un disc per a la instal·lació, relaxa't i mira l'espectacle de la instal·lació. Es pot fer en menys d'un minut als ordinadors moderns més ràpids, però no hauria de trigar més de 5 minuts ni tan sols en un ordinador més antic.

 ![install-done](images/install-done.webp)

Ara ja estàs a punt per a Omarchy!

### Utilitza un teclat amb cable o de 2.4ghz!

El xifratge de disc complet no et permetrà introduir la contrasenya des d'un teclat Bluetooth a l'arrencada. Igual que no pots utilitzar un teclat Bluetooth per entrar a la BIOS d'un PC. Necessitaràs un teclat que utilitzi un adaptador de 2.4ghz o un cable (que de totes maneres és molt millor per a la latència!). Personalment, m'encanta el [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instal·lació per a un altre propietari

Si estàs configurant un ordinador per a algú altre — un familiar, un empleat nou, un comprador — no hauries de respondre les preguntes personals en nom seu. Prem `Ctrl + C` a la primera pantalla de l'instal·lador (la selecció del teclat), i Omarchy t'oferirà preparar l'ordinador per a un altre propietari. El sistema s'instal·la immediatament, però tota la configuració personal — la disposició del teclat, el nom d'usuari, la contrasenya — es posposa fins que l'ordinador arrenca per primera vegada. El disc continua xifrat per defecte, i la contrasenya que el nou propietari tria en aquella primera arrencada també esdevé la contrasenya de xifratge. (Un ordinador que ja has estat utilitzant també es pot lliurar sense reinstal·lar-lo — consulta [restabliment de l'ordinador](48-security.md).)

### Instal·lacions desateses

La ISO també es pot instal·lar completament tota sola — sense teclat, sense assistent — quan rep la seva configuració en un segon disc. Aquesta és la manera de tractar Omarchy com una imatge base per a VM i parcs d'ordinadors. Consulta [instal·lacions desateses](51-unattended-installs.md).

### Instal·lacions sense xifratge

Omarchy s'instal·la amb xifratge per defecte. És l'opció segura i responsable per a qualsevol ordinador que es pugui perdre o que et puguin robar. No vols que ningú que tingui accés al teu maquinari pugui obtenir les teves dades!

Però en circumstàncies especials, com ara instal·lacions remotes d'Omarchy en ordinadors protegits o instal·lacions d'un sol ús sense dades sensibles, potser vols instal·lar sense xifratge. Pots prémer `Ctrl + C` a la confirmació de formatació del disc per canviar a una instal·lació sense xifratge.

### Idioma

Omarchy parla 50 idiomes — el mateix conjunt que omarchy.org — i l'anglès és el predeterminat. Per canviar-lo, obre el menú d'Omarchy i ves a _Setup > Region > Language_, o executa `omarchy language <code>` en un terminal (`omarchy language list` mostra els codis). El menú, l'escriptori i les notificacions pròpies d'Omarchy canvien d'idioma immediatament, i totes les aplicacions que obris després també. Les aplicacions que ja estaven obertes canvien quan les reinicies.

Per mantenir l'idioma però escriure les dates, les hores, els nombres, els diners, les unitats i les mides de paper com ho fa una altra regió (anglès amb dates europees i un rellotge de 24 hores, per exemple), tria una regió a _Setup > Region > Formats_, on cada opció mostra un exemple, o executa `omarchy region formats <code>` (`omarchy region formats list` mostra els codis). _Same as language_ torna als formats propis de l'idioma. Com amb un canvi d'idioma, afecta les aplicacions que obris després.

### Ajuda si et quedes encallat

Si et quedes encallat, normalment pots trobar algú disposat a ajudar-te al canal _#omarchy-help_ de [Discord de la comunitat](https://omarchy.org/discord).
