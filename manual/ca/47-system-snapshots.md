# Instantànies del sistema

Creem instantànies automàticament a cada actualització d'Omarchy, però si vols crear-ne una de pròpia, pots fer servir `omarchy-snapshot create`.

Per arrencar i restaurar una instantània, la selecciones des del carregador d'arrencada Limine. (Si actualment arrenques directament a la pantalla de desxifratge d'Omarchy, primer hauràs de seleccionar Limine com a opció d'arrencada via la BIOS).

Des d'aquesta pantalla, tria la instantània que vols arrencar segons la data i la versió. La versió d'Omarchy en el moment de la instantània es pot veure a la cantonada inferior esquerra.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quan hi arribis a dins, apareixerà una notificació que t'avisarà que ets en una instantània d'arrencada i que, si la cliques, iniciarà el procés de restauració. Alternativament, pots fer servir `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Això restaurarà el sistema de fitxers arrel, però no el teu `/home`. D'aquesta manera funciona per revertir una actualització del sistema trencada, però no per recuperar fitxers personals perduts.

Això també vol dir que el teu directori `~/.config` es conserva tal com està. De manera que, si estàs retrocedint a una versió anterior d'una biblioteca o aplicació que desa fitxers de configuració en un format nou, t'ho hauràs de resoldre manualment.

_Nota: aquesta funcionalitat només està disponible a les instal·lacions que fan servir el carregador d'arrencada Limine, que és el per defecte des d'Omarchy 2.0. No està disponible si ets a GRUB o a systemd-boot._

### Saltar-se el menú d'arrencada

Si no toques mai el menú d'arrencada i només vols que la màquina vagi directa a la pantalla de desxifratge, executa _Configuració > Arrencada directa_ al menú d'Omarchy. Això afegeix una entrada EFI que apunta directament a Omarchy, de manera que el microprogramari l'arrenca sense aturar-se a Limine.

La contrapartida és la que s'esmenta a dalt: amb l'arrencada directa activada, arribar a una instantània vol dir triar primer Limine des del menú d'arrencada de la BIOS. Executa _Configuració > Arrencada directa_ una altra vegada per eliminar l'entrada i tornar a arrencar a través de Limine. Hi ha microprogramaris als quals les entrades EFI personalitzades no els fan gaire gràcia, de manera que la configuració es nega a executar-se al microprogramari d'American Megatrends i d'Apple.
