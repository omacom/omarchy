# Actualitzacions

Omarchy i els teus paquets es mantenen actualitzats mitjançant _Actualització > Omarchy_ al menú d'Omarchy (`Super + Space`).

Omarchy mateix s'instal·la com a paquets normals de pacman des del [repositori de paquets d'Omarchy](https://github.com/omacom-io/omarchy-pkgs), de manera que una actualització instal·la [l'última versió d'Omarchy](https://github.com/omacom/omarchy/releases), executa qualsevol migració pendent per deixar el teu sistema sincronitzat amb l'última versió i actualitza tots els paquets del sistema des del [mirror d'Omarchy per a Arch](https://github.com/omacom-io/omarchy-mirror) i l'[AUR](https://aur.archlinux.org/) (si has instal·lat cap paquet de l'AUR).

Quan es publiquen noves versions, apareixerà una icona de fletxa circular a la dreta del teu rellotge. Fes-hi clic i s'iniciarà el procés d'actualització.

![update-available](images/update-available.webp)

### Quatre canals

Omarchy s'actualitza mitjançant quatre canals: stable, RC, edge i dev. Les instal·lacions noves comencen al canal stable, que segueix les [versions oficials](https://github.com/omacom/omarchy/releases/), així com el [mirror d'Arch estable d'Omarchy](https://github.com/omacom-io/omarchy-mirror) que va un mes per darrere de l'última versió, perquè puguem detectar qualsevol incompatibilitat nova que requereixi canvis de configuració abans que causi problemes a la gent.

Però si vols ajudar a detectar aquests possibles problemes, pots fer servir el canal edge. Això mantindrà els teus paquets d'Omarchy seguint les últimes compilacions de desenvolupament i et permetrà actualitzar als últims paquets d'Arch tan bon punt estiguin disponibles. Només ho hauries de fer si tens experiència amb Linux i saps com recuperar un sistema que té problemes.

Abans de qualsevol nova versió major, farem la validació final mitjançant el canal RC. Si t'interessa ajudar amb el poliment final, vine a passar l'estona a #omarchy-release-candidates al Discord.

Finalment, hi ha el canal dev, que enllaça Omarchy directament amb una còpia git del codi font a `~/omarchy`, combinada amb els paquets edge. Només hauries d'utilitzar aquest canal si ets un usuari experimentat de Linux, treballes directament en Omarchy i estàs disposat a tolerar que les coses es trenquin.

Pots canviar de canal mitjançant _Actualització > Canal_ des del menú d'Omarchy (o `omarchy-channel-set` al terminal).

### Canvi de nucli

Omarchy arrenca amb el seu propi nucli `linux-omarchy`, però en pots tenir d'altres instal·lats al seu costat, com el nucli `linux` estàndard d'Arch o una compilació experimental que estiguis provant. Quan n'hi ha més d'un, _Actualització > Nucli_ al menú d'Omarchy els enumera amb una marca al costat del que arrenca per defecte. Tria'n un altre, introdueix la teva contrasenya una vegada i arrencarà després del proper reinici. Els altres nuclis es queden al menú d'arrencada, de manera que encara en pots triar un manualment si el nou valor per defecte et dona problemes. Al terminal, és `omarchy-kernel` per veure el valor per defecte actual, `omarchy-kernel list` per veure què hi ha instal·lat i `omarchy-kernel set <kernel>` per canviar.

### Actualitzacions de microprogramari

Els teus paquets no són l'única cosa que queda obsoleta. Molts portàtils i perifèrics distribueixen microprogramari de BIOS, SSD i estacions d'acoblament a través del Linux Vendor Firmware Service, i _Actualització > Microprogramari_ al menú d'Omarchy obtindrà i instal·larà tot el que el teu maquinari tingui pendent. Instal·la `fwupd` la primera vegada que l'executes. Una gran quantitat de microprogramari només es pot escriure durant un reinici, així que no t'estranyi que te'n demani un.

Quan hagis de canviar un ajust a la pròpia BIOS, mantén premuda `Alt` al menú del sistema (`Super + Escape`) i _Reinicia_ es converteix en _Reinicia a la BIOS_, que reinicia directament a la configuració del microprogramari sense haver d'encertar la tecla adequada a l'arrencada. Des del terminal, és `omarchy system firmware`.

### Avís sobre les actualitzacions directes amb pacman/yay

Si ja estàs familiaritzat amb Arch, potser tindràs la temptació d'executar simplement `pacman -Syu` o `yay -Syu` pel teu compte, però si ho fas, et saltaràs la instantània, les migracions i les actualitzacions de configuració que Omarchy executa juntament amb els paquets nous. Per això Omarchy aturarà de fet una actualització directa del sistema i t'indicarà que facis servir `omarchy update` en el seu lloc. (Si realment saps què fas, la protecció et dirà com ometre-la per a una sola transacció.)

### Reversió d'actualitzacions problemàtiques

Si mai tens un problema després de fer una actualització, pots revertir el sistema a la instantània feta abans de l'actualització. Només cal que reiniciïs i triïs al menú d'arrencada la instantània d'abans que comencessis l'actualització.

![bootloader](images/bootloader.webp)

Si d'alguna manera els teus fitxers de configuració s'han malmès, també pots fer una reinstal·lació d'Omarchy mitjançant `omarchy reinstall` al terminal. Això reinstal·larà tots els paquets per defecte d'Omarchy, et posarà a stable i baixarà de versió qualsevol paquet que sigui massa nou, i restablirà tots els fitxers de configuració. Tingues en compte que fent això se sobreescriuran tots els canvis de configuració d'usuari que hagis fet als valors per defecte d'Omarchy!
