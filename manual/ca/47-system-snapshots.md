# Instantànies del sistema

Creem instantànies automàticament a cada actualització d'Omarchy, però si en vols crear una de pròpia, pots fer servir `omarchy-snapshot create`.

Per arrencar i restaurar una instantània, la selecciones des del carregador d'arrencada Limine. (Si ara arrenques directament a la pantalla de desxifratge d'Omarchy, primer hauràs de seleccionar Limine com a opció d'arrencada a través de la BIOS).

Des d'aquesta pantalla, tria la instantània que vols arrencar en funció de la data i la versió. La versió d'Omarchy en el moment de la instantània es pot veure a l'angle inferior esquerre.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quan hi arribis a dins, apareixerà una notificació que t'avisarà que ets en una instantània arrencable i, si hi fas clic, iniciarà el procés de restauració. Alternativament, pots utilitzar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Això restaurarà el sistema de fitxers arrel, però no el teu `/home`. Així que serveix per revertir una actualització del sistema defectuosa, però no per recuperar fitxers personals perduts.

Això també vol dir que el teu directori `~/.config` es manté tal com és. Així que si tornes a una versió anterior d'una biblioteca o una aplicació que desa fitxers de configuració en un format nou, ho hauràs de resoldre manualment.

El mateix passa amb el registre propi d'Omarchy de quines migracions ja s'han executat: viu al teu directori d'inici, així que sobreviu a la restauració. Les migracions que es van executar després que es fes la instantània es queden marcades com a fetes, encara que els canvis que van fer al sistema de fitxers arrel s'hagin revertit, i la propera `omarchy update` no les tornarà a executar. Així que si tornes a actualitzar després d'una restauració i encara falta alguna cosa que una actualització anterior havia configurat, aquesta n'és la raó probable.

_Nota: Aquesta funció només està disponible en instal·lacions que facin servir el carregador d'arrencada Limine, que és el predeterminat des d'Omarchy 2.0. No està disponible si fas servir GRUB o systemd-boot._

### Saltar-se el menú d'arrencada

Si mai toques el menú d'arrencada i només vols que la màquina vagi directament a la pantalla de desxifratge, executa _Setup > Direct Boot_ al menú d'Omarchy. Això afegeix una entrada EFI que apunta directament a Omarchy, de manera que el microprogramari l'arrenca sense aturar-se a Limine.

La contrapartida és la que s'esmenta al principi: amb l'arrencada directa activada, arribar a una instantània vol dir triar primer Limine des del menú d'arrencada de la BIOS. Torna a executar _Setup > Direct Boot_ per eliminar l'entrada i tornar a arrencar a través de Limine. Alguns microprogramaris no accepten gaire bé les entrades EFI personalitzades, així que la configuració es nega a executar-se en microprogramari d'American Megatrends i d'Apple.
