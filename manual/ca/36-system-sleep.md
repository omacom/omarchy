# Repòs del sistema

Omarchy habilita la suspensió i la hibernació per defecte, però si tens problemes amb alguna de les dues a la teva màquina, les pots desactivar.

A les màquines NVIDIA GB10, com ara la DGX Spark i l'ASUS Ascent GX10, la suspensió i la hibernació estan desactivades, com ho estan al DGX OS de NVIDIA, perquè encara no s'ha demostrat que el repòs funcioni en aquest maquinari. El mateix passa amb l'ASUS Zenbook A16 (UX3607OA), on la suspensió encara no posa el xip completament en repòs i es pot penjar durant la nit. L'alternança de la suspensió i la configuració de la hibernació no s'hi apliquen. Per tornar a activar el repòs, elimina `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` amb `sudo rm`; aleshores Suspensió tornarà al menú, i la hibernació es podrà configurar com a les altres màquines. Si executes `sudo omarchy apply hardware --install-user "$USER"`, el fitxer es tornarà a crear.

### Perfils d'energia

En un portàtil, Omarchy recorda el teu perfil d'energia per separat per a quan està endollat i per a quan funciona amb bateria, i canvia entre l'un i l'altre a mesura que endolles i desendolles. De fàbrica, això vol dir rendiment amb corrent altern i equilibrat amb bateria.

Pots veure què ofereix la teva màquina amb `omarchy powerprofiles list`, i establir el que vols per a l'estat en què et trobes actualment amb `omarchy powerprofiles set autodetect power-saver`. Per establir l'altre estat sense desendollar res, anomena'l directament: `omarchy powerprofiles set battery power-saver`. Sigui quin sigui el que triïs, serà el que recuperaràs la propera vegada que estiguis en aquest estat.

### Activa o desactiva la suspensió

Alternatives la suspensió executant `omarchy toggle suspend` des del terminal. Això només mostra/amaga l'opció a _Sistema_ (o `Super + Esc`), i aleshores pots comprovar si funciona de manera consistent al teu sistema. Si no, pots tornar a amagar-la amb la mateixa ordre.

### Activa o desactiva la hibernació

Configures la hibernació executant `omarchy hibernation setup` des del terminal. La hibernació crea un subvolum /swap a la unitat d'arrencada de la mida de la teva assignació de RAM física, així que assegura't de tenir molt d'espai de sobres. En una màquina de 32GB, sempre necessitaràs 32GB+ lliures per a aquest volum. La hibernació també requereix el gestor d'arrencada per defecte Limine.

Un cop configurada, veuràs l'opció d'hibernar a _Sistema_ (o `Super + Esc`), i aleshores pots comprovar si funciona de manera consistent al teu sistema. Si no, pots tornar a eliminar-la executant `omarchy hibernation remove`.
