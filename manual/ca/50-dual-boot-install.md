# Instal·lació amb arrencada dual

Pots instal·lar Omarchy en una sola partició al costat de Windows o d'altres instal·lacions.

Aquest mètode d'instal·lació continua incloent el xifratge LUKS per a la partició per defecte, de manera que efectivament no difereix d'una instal·lació a tot el disc i simplement requereix que hi hagi espai lliure disponible al disc.

## Fer espai a Windows

Per instal·lar-lo al costat de Windows, escriu `disk management` al menú d'inici i selecciona l'opció **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Troba la partició adequada, fes-hi clic amb el botó dret i tria **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Introdueix la quantitat en què vols reduir el volum. Tingues en compte que aquesta serà la mida de la teva futura instal·lació d'Omarchy, inclosa la partició d'arrencada.

 ![dual-boot-3](images/dual-boot-3.webp)

Quan hagis acabat, hauries de veure una cosa com aquesta, on la secció de 50GB és on instal·larem Omarchy en aquest exemple.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instal·lar Omarchy

El procés d'instal·lació d'Omarchy és efectivament el mateix que el normal. Després de seleccionar el disc, tindràs l'opció **Free space install**. Selecciona aquesta opció per evitar esborrar tot el disc.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirma que tot sembla correcte i espera que la instal·lació acabi com de costum. Aquí també pots triar instal·lar-lo sense xifrar (no recomanat), igual que en una instal·lació a tot el disc.
 ![dual-boot-6](images/dual-boot-6.webp)

## Afegir altres instal·lacions al carregador d'arrencada

Quan acabis la instal·lació d'Omarchy, veuràs que el carregador d'arrencada Limine ara és el predeterminat. Amb això, també pots afegir opcions a Limine per a les teves altres instal·lacions, com ara Windows.

Per afegir altres sistemes operatius, executa `limine-scan` i segueix les indicacions per afegir les entrades que vulguis a la configuració de Limine. El menú d'arrencada roman ocult per defecte i inicia Omarchy després d'un segon. Per triar Windows o una altra entrada, prem qualsevol tecla tan bon punt s'iniciï Limine; quan aparegui el menú, utilitza les tecles de fletxa per seleccionar una entrada i prem Enter. Si Omarchy s'inicia abans que premis una tecla, reinicia i torna-ho a provar. Si has activat _Setup > Direct Boot_, el microprogramari omet Limine completament, així que tria Limine des del menú d'arrencada de la BIOS o executa _Setup > Direct Boot_ de nou per eliminar l'entrada.

## Bitlocker

És important tenir en compte que aquest mètode d'instal·lació no és compatible amb Bitlocker, ja que xifra tota la unitat, no només la partició. Si trobes un error que indica que Bitlocker està activat, arrenca a Windows, ves a **Settings -> Privacy & Security -> Device encryption** i desactiva Bitlocker. Pot trigar una estona a desxifrar la unitat.

 ![dual-boot-7](images/dual-boot-7.webp)
