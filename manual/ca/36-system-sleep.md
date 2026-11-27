# Suspensió del sistema

L'Omarchy activa la suspensió per defecte, i la hibernació un cop està configurada, però si tens problemes amb alguna de les dues a la teva màquina, les pots desactivar.

A les màquines NVIDIA GB10, com la DGX Spark i l'ASUS Ascent GX10, la suspensió i la hibernació estan desactivades, com al DGX OS de NVIDIA, perquè encara no s'ha demostrat que la suspensió funcioni en aquest maquinari. L'opció per activar/desactivar la suspensió i la configuració de la hibernació no s'hi apliquen. Per tornar a activar la suspensió, elimina `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` amb `sudo rm`; llavors la suspensió tornarà al menú i la hibernació es podrà configurar com a les altres màquines. Si executes `sudo omarchy apply hardware --install-user "$USER"`, el fitxer es tornarà a crear.

### Perfils d'energia

En un portàtil, l'Omarchy recorda el teu perfil d'energia per separat per a quan està endollat i per a quan funciona amb bateria, i canvia entre l'un i l'altre quan endolles i desendolles. De fàbrica, això vol dir rendiment amb corrent altern i equilibrat amb bateria.

Pots veure què ofereix la teva màquina amb `omarchy powerprofiles list`, i definir el que vols per a l'estat en què et trobes ara amb `omarchy powerprofiles set autodetect power-saver`. Per definir l'altre estat sense desendollar res, anomena'l directament: `omarchy powerprofiles set battery power-saver`. El que triïs serà el que recuperaràs la pròxima vegada que estiguis en aquest estat.

### Activa/desactiva la suspensió

Pots activar/desactivar la suspensió executant `omarchy toggle suspend` des del terminal. Això només mostra/amaga l'opció a _System_ (o `Super + Esc`), i així pots comprovar si funciona de manera consistent al teu sistema. Si no, la pots tornar a amagar amb la mateixa ordre.

### Activa/desactiva la hibernació

Configures la hibernació executant `omarchy hibernation setup` des del terminal (no està disponible als Mac amb Apple Silicon). La hibernació crea un subvolum /swap a la unitat d'arrencada de la mida de la teva assignació de RAM física, així que assegura't de tenir-hi molt d'espai lliure de sobres. En una màquina de 32GB, sempre necessitaràs més de 32GB lliures per a aquest volum. La hibernació també requereix el gestor d'arrencada Limine per defecte.

Un cop configurada, veuràs l'opció d'hibernar a _System_ (o `Super + Esc`), i així pots comprovar si funciona de manera consistent al teu sistema. Si no, la pots tornar a eliminar executant `omarchy hibernation remove`.
