# Suspensió del sistema

Omarchy activa la suspensió per defecte, i la hibernació un cop està configurada, però si tens problemes amb qualsevol de les dues a la teva màquina, les pots desactivar.

A les màquines NVIDIA GB10, com la DGX Spark i l’ASUS Ascent GX10, la suspensió i la hibernació estan desactivades, com a DGX OS de NVIDIA, perquè encara no s’ha demostrat que el repòs funcioni en aquest maquinari. El mateix passa amb l’ASUS Zenbook A16 (UX3607OA), on la suspensió encara no fa que el xip entri completament en repòs i es pot penjar durant la nit. L’opció per activar o desactivar la suspensió i la configuració de la hibernació no s’hi apliquen. Per tornar a activar el repòs, elimina `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` amb `sudo rm`; llavors la suspensió tornarà al menú, i la hibernació es podrà configurar com a les altres màquines. Executar `sudo omarchy apply hardware --install-user "$USER"` torna a posar el fitxer al seu lloc.

### Perfils d’energia

En un portàtil, Omarchy recorda el teu perfil d’energia per separat segons si està endollat o si funciona amb bateria, i canvia entre els dos a mesura que endolles i desendolles. De fàbrica, això vol dir rendiment quan està endollat i equilibrat quan va amb bateria.

Pots veure què ofereix la teva màquina amb `omarchy powerprofiles list`, i definir el que vols per a l’estat en què et trobes ara mateix amb `omarchy powerprofiles set autodetect power-saver`. Per definir l’altre estat sense desendollar res, anomena’l directament: `omarchy powerprofiles set battery power-saver`. Sigui quin sigui el que triïs, serà el que recuperaràs la propera vegada que estiguis en aquest estat.

### Activa o desactiva la suspensió

Actives o desactives la suspensió executant `omarchy toggle suspend` des del terminal. Això només mostra/amaga l’opció a _Sistema_ (o `Super + Esc`), i llavors pots veure si funciona de manera consistent al teu sistema. Si no, la pots tornar a amagar amb la mateixa ordre.

### Activa o desactiva la hibernació

Configures la hibernació executant `omarchy hibernation setup` des del terminal (no està disponible als Macs amb Apple Silicon). La hibernació crea un subvolum /swap a la unitat d’arrencada de la mida de la teva assignació de RAM física, així que assegura’t de tenir molt d’espai de sobres. En una màquina de 32GB, sempre necessitaràs més de 32GB lliures per a aquest volum. La hibernació també requereix el carregador d’arrencada Limine per defecte.

Un cop configurada, veuràs l’opció d’hibernar a _Sistema_ (o `Super + Esc`), i llavors pots veure si funciona de manera consistent al teu sistema. Si no, la pots tornar a treure executant `omarchy hibernation remove`.
