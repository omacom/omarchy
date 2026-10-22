# Suspensió del sistema

Omarchy activa la suspensió i la hibernació per defecte, però si tens problemes amb qualsevol de les dues a la teva màquina, pots desactivar-les.

### Perfils d'energia

En un portàtil, Omarchy recorda el teu perfil d'energia per separat per a quan està endollat i per a quan funciona amb bateria, i canvia entre l'un i l'altre a mesura que endolles i desendolles. Des del primer moment, això vol dir rendiment amb corrent altern i equilibrat amb bateria.

Pots veure què ofereix la teva màquina amb `omarchy powerprofiles list`, i definir el que vols per a l'estat en què et trobes ara amb `omarchy powerprofiles set autodetect power-saver`. Per definir l'altre estat sense desendollar res, anomena'l directament: `omarchy powerprofiles set battery power-saver`. Sigui quin sigui el que triïs, és el que recuperaràs la pròxima vegada que et trobis en aquest estat.

### Commutar la suspensió

La suspensió es commuta executant `omarchy toggle suspend` des del terminal. Això només mostra o amaga l'opció a _Sistema_ (o amb `Super + Esc`), i aleshores pots veure si funciona de manera consistent al teu sistema. Si no, la pots tornar a amagar amb la mateixa ordre.

### Commutar la hibernació

La hibernació es configura executant `omarchy hibernation setup` des del terminal. La hibernació crea un subvolum /swap a la unitat d'arrencada amb la mida de la teva assignació de RAM física, així que assegura't de tenir molt d'espai de sobres. En una màquina de 32 GB, sempre necessitaràs més de 32 GB lliures per a aquest volum. La hibernació també requereix el carregador d'arrencada Limine per defecte.

Un cop configurada, veuràs l'opció d'hibernar a _Sistema_ (o amb `Super + Esc`), i aleshores podràs veure si funciona de manera consistent al teu sistema. Si no, la pots tornar a eliminar executant `omarchy hibernation remove`.
