# Instantànies del sistema

Creem instantànies automàticament a cada actualització d'Omarchy, però si en vols crear una de pròpia, pots fer servir `omarchy-snapshot create`.

La manera d'arrencar i restaurar una instantània depèn del carregador d'arrencada amb què s'inicia la teva màquina. Les instal·lacions UEFI noves fan servir systemd-boot; les instal·lacions més antigues i les màquines amb BIOS fan servir Limine. `omarchy-boot-backend` et diu quin és el teu.

## Amb systemd-boot

Tria _Sistema > Instantànies_ al menú d'Omarchy i tria la instantània en què vols arrencar. La màquina s'hi reinicia una vegada. O mantén premut Space mentre la màquina arrenca per veure el menú d'arrencada, on cada instantània apareix llistada de més nova a més antiga amb la seva versió d'Omarchy i la data.

Una instantània arrenca amb una capa temporal a sobre, així que la pots fer servir com de costum, però tot el que hi canviïs desapareixerà en el següent reinici. Per conservar-la, fes-la el teu sistema: fes clic a la notificació que apareix quan inicies sessió, tria _Sistema > Instantànies > Restaura aquesta instantània_, o executa `omarchy-snapshot restore`. La restauració es fa mentre la màquina es reinicia. El sistema tal com era abans es manté al menú d'arrencada com a _Abans de la restauració_, i `omarchy-snapshot restore backup` el torna a posar.

Des del terminal:

- `omarchy-snapshot list` llista les instantànies en què pots arrencar;
- `omarchy-snapshot boot 12` reinicia a la instantània 12 una vegada;
- `omarchy-snapshot restore 12` fa de la instantània 12 el sistema en el següent reinici, i `omarchy-snapshot restore --cancel` et fa canviar d'idea abans d'aquest reinici.

## Amb Limine

Per arrencar i restaurar una instantània, la selecciones des del carregador d'arrencada Limine. El menú d'arrencada es manté ocult per defecte, així que prem qualsevol tecla tan bon punt s'iniciï Limine per mostrar-lo.

Des d'aquesta pantalla, tria la instantània en què vols arrencar segons la data i la versió. La versió d'Omarchy en el moment de la instantània es pot veure a la cantonada inferior esquerra.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quan hi arribis a dins, apareixerà una notificació que t'avisarà que ets en una instantània arrencable i, si hi fas clic, iniciarà el procés de restauració. Alternativament, pots utilitzar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Què cobreix una restauració

Una restauració recupera el sistema de fitxers arrel, però no el teu `/home`. Així que serveix per revertir una actualització del sistema espatllada, però no per recuperar fitxers personals perduts.

Això també vol dir que el teu directori `~/.config` es manté tal com està. Així que si tornes a una versió anterior d'una biblioteca o aplicació que desa fitxers de configuració en un format nou, ho hauràs de resoldre manualment.

El mateix passa amb el registre propi d'Omarchy de quines migracions ja s'han executat: viu al teu directori personal, així que sobreviu a la restauració. Les migracions que es van executar després que es fes la instantània es mantenen marcades com a fetes, encara que els canvis que van fer al sistema de fitxers arrel s'hagin revertit, i la propera `omarchy update` no les tornarà a executar. Així que si tornes a actualitzar després d'una restauració i encara falta alguna cosa que una actualització anterior havia configurat, aquesta és la raó probable.
