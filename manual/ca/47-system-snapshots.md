# Instantànies del sistema

Creem instantànies automàticament a cada actualització d'Omarchy, però si en voleu crear una de vostra, podeu utilitzar `omarchy-snapshot create`.

Per arrencar i restaurar una instantània, la seleccioneu des del carregador d'arrencada Limine. El menú d'arrencada roman ocult per defecte, així que premeu qualsevol tecla tan bon punt s'iniciï Limine per fer-lo aparèixer.

Des d'aquesta pantalla, trieu la instantània en què voleu arrencar segons la data i la versió. La versió d'Omarchy en el moment de la instantània es pot veure a la cantonada inferior esquerra.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quan hi arribeu, apareixerà una notificació que us avisarà que sou en una instantània arrencable i, si hi feu clic, iniciarà el procés de restauració. Alternativament, podeu utilitzar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Això restaurarà el vostre sistema de fitxers arrel, però no el vostre `/home`. Així que funciona per revertir una actualització del sistema defectuosa, però no per recuperar fitxers personals perduts.

Això també significa que el vostre directori `~/.config` es manté tal com és. Així que si torneu a una versió anterior d'una biblioteca o aplicació que emmagatzema fitxers de configuració en un format nou, ho haureu de resoldre manualment.

El mateix passa amb el registre propi d'Omarchy de quines migracions ja s'han executat: resideix al vostre directori d'inici, així que sobreviu a la restauració. Les migracions que es van executar després de fer la instantània romanen marcades com a fetes, encara que els canvis que van fer al sistema de fitxers arrel s'hagin revertit, i la pròxima `omarchy update` no les tornarà a executar. Així que si torneu a actualitzar després d'una restauració i encara falta alguna cosa que una actualització anterior havia configurat, aquest és el motiu probable.

_Nota: Aquesta funció només està disponible en instal·lacions que utilitzen el carregador d'arrencada Limine, que ha estat el predeterminat des d'Omarchy 2.0. No està disponible si utilitzeu GRUB o systemd-boot._
