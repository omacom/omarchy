# Instal·lació amb arrencada dual

Pots instal·lar Omarchy en una sola partició al costat de Windows o d'altres instal·lacions.

Aquest mètode d'instal·lació continua incloent per defecte el xifratge LUKS per a la partició, de manera que, en la pràctica, no és diferent de fer-ho en tot el disc i simplement requereix que hi hagi espai lliure disponible al disc.

## Fer espai a Windows

Per instal·lar-lo al costat de Windows, escriu `disk management` al menú d'inici i selecciona l'opció **Crear i formatar particions de disc dur**.

 ![dual-boot-1](images/dual-boot-1.webp)

Troba la partició adequada, fes-hi clic amb el botó dret i tria **Redueix el volum**.

![dual-boot-2](images/dual-boot-2.webp)

 Introdueix la quantitat en què vols reduir el volum. Tingues en compte que aquesta serà la mida de la teva futura instal·lació d'Omarchy, inclosa la partició d'arrencada.

 ![dual-boot-3](images/dual-boot-3.webp)

Quan hagis acabat, hauries de veure una cosa com aquesta, en què la secció de 50GB és on instal·larem Omarchy en aquest exemple.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instal·lar Omarchy

El procés d'instal·lació d'Omarchy és, en la pràctica, el mateix de normal. Després de seleccionar el disc, tindràs l'opció **Instal·lació en l'espai lliure**. Selecciona aquesta opció per evitar esborrar tot el disc.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirma que tot es veu bé i espera que la instal·lació acabi com de normal. Aquí també podries triar instal·lar-ho sense xifrar (no recomanat), igual que en una instal·lació en tot el disc.
 ![dual-boot-6](images/dual-boot-6.webp)

## Afegir altres instal·lacions al carregador d'arrencada

Quan acabis la instal·lació d'Omarchy, notaràs que el carregador d'arrencada Limine és ara el predeterminat. Amb això, també pots afegir opcions a Limine per a les teves altres instal·lacions, com ara Windows.

Per afegir altres sistemes operatius, executa `limine-scan` i segueix les indicacions per afegir les entrades que vulguis a la teva configuració de Limine. El menú d'arrencada es manté ocult per defecte i inicia Omarchy al cap d'un segon. Per triar Windows o una altra entrada, prem qualsevol tecla tan bon punt s'iniciï Limine; quan aparegui el menú, utilitza les tecles de fletxa per seleccionar una entrada i prem Enter. Si Omarchy s'inicia abans que premis una tecla, reinicia i torna-ho a provar.

## Bitlocker

És important tenir en compte que aquest mètode d'instal·lació no és compatible amb Bitlocker, ja que xifra tota la unitat, no només la partició. Si trobes un error que indica que Bitlocker està activat, arrenca a Windows, ves a **Configuració -> Privadesa i seguretat -> Xifratge del dispositiu** i desactiva Bitlocker. Pot trigar una estona a desxifrar la unitat.

 ![dual-boot-7](images/dual-boot-7.webp)
