# System-Snapshots

Wir erstellen bei jedem Omarchy-Update automatisch Snapshots, aber wenn du deinen eigenen erstellen willst, kannst du `omarchy-snapshot create` verwenden.

Wie du einen Snapshot bootest und wiederherstellst, hängt davon ab, mit welchem Bootloader deine Maschine startet. Neue UEFI-Installationen verwenden systemd-boot; ältere Installationen und BIOS-Maschinen verwenden Limine. `omarchy-boot-backend` sagt dir, welchen du hast.

## Mit systemd-boot

Wähle im Omarchy-Menü _System > Snapshots_ und wähle den Snapshot, in den du booten möchtest. Die Maschine startet einmalig in ihn neu. Oder halte Space gedrückt, während die Maschine startet, um das Boot-Menü zu sehen, in dem jeder Snapshot mit seiner Omarchy-Version und seinem Datum aufgelistet ist, der neueste zuerst.

Ein Snapshot bootet mit einer temporären Schicht darüber, sodass du ihn ganz normal verwenden kannst, aber alles, was du änderst, ist beim nächsten Neustart weg. Damit er bleibt, mache ihn zu deinem System: Klicke auf die Benachrichtigung, die erscheint, wenn du dich anmeldest, wähle _System > Snapshots > Restore This Snapshot_ oder führe `omarchy-snapshot restore` aus. Die Wiederherstellung erfolgt, während die Maschine neu startet. Das System, wie es vorher war, bleibt im Boot-Menü als _Before restore_ erhalten, und `omarchy-snapshot restore backup` stellt es wieder her.

Vom Terminal aus:

- `omarchy-snapshot list` listet die Snapshots auf, in die du booten kannst;
- `omarchy-snapshot boot 12` startet einmalig in Snapshot 12 neu;
- `omarchy-snapshot restore 12` macht Snapshot 12 beim nächsten Neustart zum System, und `omarchy-snapshot restore --cancel` macht das vor diesem Neustart wieder rückgängig.

## Mit Limine

Um einen Snapshot zu booten und wiederherzustellen, wählst du ihn aus dem Limine-Bootloader aus. Das Boot-Menü bleibt standardmäßig verborgen, drücke also eine beliebige Taste, sobald Limine startet, um es aufzurufen.

Wähle auf diesem Bildschirm anhand von Datum und Version den Snapshot aus, in den du booten möchtest. Die Omarchy-Version zum Zeitpunkt des Snapshots siehst du in der unteren linken Ecke.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Wenn du darin angekommen bist, poppt eine Benachrichtigung auf, die dich darüber informiert, dass du dich in einem bootfähigen Snapshot befindest, und wenn du sie anklickst, startet der Wiederherstellungsvorgang. Alternativ kannst du `omarchy-snapshot restore` verwenden.

 ![snapshots-restore](images/snapshots-restore.webp)

## Was eine Wiederherstellung abdeckt

Eine Wiederherstellung stellt dein Root-Dateisystem wieder her, aber nicht dein `/home`. Sie eignet sich also, um ein fehlerhaftes System-Update rückgängig zu machen, aber nicht, um verlorene persönliche Dateien wiederherzustellen.

Das bedeutet auch, dass dein `~/.config`-Verzeichnis so bleibt, wie es ist. Wenn du also zu einer früheren Version einer Bibliothek oder Anwendung zurückkehrst, die Konfigurationsdateien in einem neuen Format speichert, musst du das manuell in Ordnung bringen.

Das Gleiche gilt für Omarchys eigene Aufzeichnung darüber, welche Migrationen bereits ausgeführt wurden: Sie liegt in deinem Home-Verzeichnis, übersteht die Wiederherstellung also. Migrationen, die nach dem Erstellen des Snapshots ausgeführt wurden, bleiben als erledigt markiert, obwohl die Änderungen, die sie am Root-Dateisystem vorgenommen haben, rückgängig gemacht wurden, und das nächste `omarchy update` wird sie nicht erneut ausführen. Wenn du also nach einer Wiederherstellung erneut aktualisierst und etwas, das ein früheres Update eingerichtet hatte, immer noch fehlt, ist das der wahrscheinliche Grund.
