# Actualitzacions

Omarchy i els teus paquets es mantenen actualitzats mitjançant _Actualitza > Omarchy_ al menú d'Omarchy (`Super + Space`).

Omarchy mateix s'instal·la com a paquets pacman normals des del [Repositori de paquets d'Omarchy](https://github.com/omacom-io/omarchy-pkgs), de manera que una actualització instal·la [l'última versió d'Omarchy](https://github.com/omacom/omarchy/releases), executa qualsevol migració pendent per sincronitzar el teu sistema amb l'última versió i actualitza tots els paquets del sistema des del [Mirall Arch d'Omarchy](https://github.com/omacom-io/omarchy-mirror) i l'[AUR](https://aur.archlinux.org/) (si has instal·lat algun paquet de l'AUR).

Quan es publiquin noves versions, apareixerà una icona de fletxa circular a la dreta del teu rellotge. Fes-hi clic i s'iniciarà el procés d'actualització.

![update-available](images/update-available.webp)

### Quatre canals

Omarchy s'actualitza a través de quatre canals: stable, RC, edge i dev. Les instal·lacions noves comencen al canal stable, que segueix les [versions oficials](https://github.com/omacom/omarchy/releases/), així com el [mirall Arch estable d'Omarchy](https://github.com/omacom-io/omarchy-mirror) que va un mes per darrere de l'última versió, perquè puguem detectar qualsevol incompatibilitat nova que requereixi canvis de configuració abans que causi problemes a la gent.

Però si vols ajudar a detectar aquests possibles problemes, pots fer servir el canal edge. Això mantindrà els teus paquets d'Omarchy seguint les últimes compilacions de desenvolupament i et permetrà actualitzar als últims paquets d'Arch tan aviat com estiguin disponibles. Només ho hauries de fer si tens experiència amb Linux i saps com recuperar un sistema que té problemes.

Abans de qualsevol versió major nova, farem la validació final utilitzant el canal RC. Si t'interessa ajudar amb el poliment final, vine a passar l'estona a #omarchy-release-candidates al Discord.

Finalment, hi ha el canal dev, que enllaça Omarchy directament amb una còpia git del codi font a `~/omarchy`, combinada amb els paquets edge. Només hauries d'utilitzar aquest canal si ets un usuari experimentat de Linux, treballes directament a Omarchy i estàs disposat a tolerar trencaments.

Pots canviar entre canals utilitzant _Actualitza > Canal_ des del menú d'Omarchy (o `omarchy channel set <stable|rc|edge|dev>` al terminal, amb `omarchy channel current` per veure on ets).

### Canviar de nucli

Omarchy arrenca amb el seu propi nucli `linux-omarchy`, però pots mantenir-ne d'altres instal·lats al seu costat, com el nucli estàndard d'Arch `linux` o una compilació experimental que estiguis provant. Quan n'hi ha més d'un, _Actualitza > Nucli_ al menú d'Omarchy els enumera amb una marca al costat del que arrenca per defecte. Tria'n un altre, introdueix la teva contrasenya una vegada i arrencarà després del proper reinici. Els altres nuclis romanen al menú d'arrencada, de manera que encara en pots triar un manualment si el nou per defecte et dona problemes. Al terminal, és `omarchy kernel` per veure el per defecte actual, `omarchy kernel list` per al que està instal·lat i `omarchy kernel set <kernel>` per canviar.

### Actualitzacions de firmware

Els teus paquets no són l'única cosa que queda obsoleta. Molts portàtils i perifèrics distribueixen firmware de BIOS, SSD i dock a través del Linux Vendor Firmware Service, i _Actualitza > Firmware_ al menú d'Omarchy obtindrà i instal·larà allò que el teu maquinari tingui pendent. Instal·la `fwupd` la primera vegada que l'executes. Molt de firmware només es pot escriure durant un reinici, així que no et sorprenguis si te'n demanen un.

Quan necessitis canviar un ajust al mateix BIOS, mantén premuda `Alt` al menú del sistema (`Super + Escape`) i _Reinicia_ es converteix en _Reinicia al BIOS_, que reinicia directament a la configuració del firmware sense haver d'encertar la tecla correcta a l'arrencada. Des del terminal, és `omarchy system firmware`.

### Advertiment sobre les actualitzacions directes amb pacman/yay

Si ja coneixes Arch, potser tindràs la temptació d'executar simplement `pacman -Syu` o `yay -Syu` tu mateix, però si ho fas, et perdràs la instantània, les migracions i les actualitzacions de configuració que Omarchy executa juntament amb els paquets nous. Per això Omarchy aturarà de fet una actualització directa del sistema i t'indicarà `omarchy update` en lloc d'això. (Si realment saps el que fas, la protecció et dirà com ometre-la per a una única transacció.)

### Revertir actualitzacions defectuoses

Si mai tens un problema després de fer una actualització, pots revertir el teu sistema a la instantània presa abans de l'actualització. Només cal que reiniciïs i triïs la instantània al menú de càrrega d'arrencada d'abans que comencessis l'actualització.

![bootloader](images/bootloader.webp)

Si d'alguna manera els teus fitxers de configuració s'han corromput, també pots fer una reinstal·lació d'Omarchy utilitzant `omarchy reinstall` al terminal. Això reinstal·larà tots els paquets per defecte d'Omarchy, et posarà a stable (edge a Apple Silicon) i rebaixarà qualsevol paquet que sigui massa nou, i restablirà tots els fitxers de configuració. Tingues en compte que, en fer això, se sobreescriuran tots els canvis de configuració d'usuari que hagis fet als valors per defecte d'Omarchy!
