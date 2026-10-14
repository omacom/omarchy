# Instal·lació d'arrencada dual

Pots instal·lar Omarchy en una sola partició al costat de Windows o d'altres instal·lacions.

Aquest mètode d'instal·lació encara ve amb xifratge LUKS per a la partició per defecte, de manera que efectivament no és gens diferent d'una unitat completa i simplement requereix que hi hagi espai lliure disponible al disc.

## Fer espai a Windows

Per instal·lar-ho al costat de Windows, escriu `disk management` al menú d'inici i selecciona l'opció **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Troba la partició adequada, fes-hi clic amb el botó dret i tria **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Introdueix la quantitat amb què vols encongir el volum. Tingues en compte que aquesta serà la mida de la teva futura instal·lació d'Omarchy, inclosa la partició d'arrencada.

 ![dual-boot-3](images/dual-boot-3.webp)

Quan hagis acabat, hauries de veure alguna cosa com això, on la secció de 50 GB és on instal·larem Omarchy en aquest exemple.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instal·lar Omarchy

El procés d'instal·lació d'Omarchy és efectivament el mateix que el normal. Després de seleccionar el disc, se't donarà l'opció d'**Free space install**. Selecciona aquesta opció per evitar esborrar tot el disc.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirma que tot té bona pinta i espera que la instal·lació acabi com de costum. Aquí és també on podries triar instal·lar-ho sense xifrar (no recomanat), igual que en una instal·lació d'unitat completa.
 ![dual-boot-6](images/dual-boot-6.webp)

## Afegir altres instal·lacions al carregador d'arrencada

Quan acabis la instal·lació d'Omarchy, notaràs que ara el carregador d'arrencada per defecte és Limine. Amb això, també pots afegir opcions a Limine per a les teves altres instal·lacions, com Windows.

Per fer-ho, executa `limine-scan` i segueix les indicacions per afegir a la teva configuració de Limine els elements que vulguis. Aleshores, quan arrenquis, veuràs les teves opcions normals per a Omarchy, a més de Windows Boot Manager o altres.

## Bitlocker

És important tenir en compte que aquest mètode d'instal·lació no és compatible amb Bitlocker, perquè xifra tota la unitat, no només la partició. Si et trobes amb un error que diu que Bitlocker està activat, arrenca a Windows, vés a **Settings -> Privacy & Security -> Device encryption** i desactiva Bitlocker. Pot trigar una mica a desxifrar la unitat.

 ![dual-boot-7](images/dual-boot-7.webp)
