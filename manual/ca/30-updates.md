# Actualitzacions

Omarchy i els teus paquets es mantenen al dia mitjançant _Actualitza > Omarchy_ al menú d'Omarchy (`Super + Space`).

El mateix Omarchy s'instal·la com a paquets pacman normals des de l'[Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), de manera que una actualització instal·la [la darrera versió d'Omarchy](https://github.com/omacom/omarchy/releases), executa qualsevol migració pendent per posar el sistema en sincronia amb el més recent i actualitza tots els paquets del sistema des de l'[Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) i l'[AUR](https://aur.archlinux.org/) (si has instal·lat cap paquet de l'AUR).

Quan es publiquen versions noves, apareixerà una icona de fletxa circular a la dreta del teu rellotge. Fes-hi clic i començarà el procés d'actualització.

![update-available](images/update-available.webp)

### Quatre canals

Omarchy s'actualitza seguint quatre canals: stable, RC, edge i dev. Les instal·lacions noves comencen al canal stable, que segueix les [versions oficials](https://github.com/omacom/omarchy/releases/), així com el [mirall stable d'Omarchy Arch](https://github.com/omacom-io/omarchy-mirror), que va un mes per darrere del més recent, perquè puguem detectar qualsevol incompatibilitat nova que requereixi canvis de configuració abans que causi problemes a la gent.

Però si vols ajudar a detectar aquests possibles problemes, pots funcionar amb el canal edge. Això farà que els teus paquets d'Omarchy segueixin les darreres versions de desenvolupament i et permetrà actualitzar als paquets d'Arch més recents tan bon punt estiguin disponibles. Només ho hauries de fer si tens experiència amb Linux i saps com recuperar un sistema que tingui problemes.

Abans de qualsevol versió major nova, farem la validació final fent servir el canal RC. Si t'interessa ajudar amb el poliment final, vine a passar l'estona a #omarchy-release-candidates al Discord.

Finalment, hi ha el canal dev, que enllaça Omarchy directament a una còpia git del codi font a `~/omarchy`, combinada amb els paquets edge. Només hauries de fer servir aquest canal si ets un usuari experimentat de Linux, treballes directament a Omarchy i estàs disposat a tolerar trencaments.

Pots canviar entre canals amb _Actualitza > Canal_ des del menú d'Omarchy (o `omarchy-channel-set` al terminal).

### Actualitzacions de microprogramari

Els teus paquets no són l'única cosa que es queda rància. Molts portàtils i perifèrics distribueixen microprogramari de BIOS, SSD i estacions d'acoblament mitjançant el Linux Vendor Firmware Service, i _Actualitza > Microprogramari_ al menú d'Omarchy obtindrà i instal·larà el que el teu maquinari tingui pendent. Instal·la `fwupd` la primera vegada que l'executes. Una bona part del microprogramari només es pot escriure durant un reinici, de manera que no et sorprenguis si te'n demana un.

### Avís sobre les actualitzacions directes amb pacman/yay

Si ja coneixes Arch, potser tindràs la temptació d'executar simplement `pacman -Syu` o `yay -Syu` pel teu compte, però si ho fas et perdràs la instantània, les migracions i les actualitzacions de configuració que Omarchy executa juntament amb els paquets nous. Per això Omarchy en realitat aturarà una actualització directa del sistema i t'assenyalarà cap a `omarchy update` en el seu lloc. (Si realment saps el que fas, la guarda et dirà com saltar-te-la per a una sola transacció.)

### Fer marxa enrere d'actualitzacions dolentes

Si mai tens un problema després de fer una actualització, pots fer marxa enrere del sistema fins a la instantània presa abans de l'actualització. Reinicia simplement i tria la instantània al menú de càrrega d'arrencada d'abans que comencessis l'actualització.

![bootloader](images/bootloader.webp)

Si d'alguna manera els teus fitxers de configuració s'han corromput, també pots fer una reinstal·lació d'Omarchy amb `omarchy reinstall` al terminal. Això reinstal·larà tots els paquets per defecte d'Omarchy, et posarà a stable i baixarà de versió qualsevol paquet que sigui massa nou, i restablirà tots els fitxers de configuració. Tingues en compte que tots els canvis de configuració d'usuari que hagis fet als valors per defecte d'Omarchy se sobreescriuran en fer això!
