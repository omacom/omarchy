# System-Snapshots

Wir erstellen bei jedem Omarchy-Update automatisch Snapshots, aber falls du deinen eigenen erstellen möchtest, kannst du `omarchy-snapshot create` verwenden.

Um einen Snapshot zu booten und wiederherzustellen, wählst du ihn im Limine-Bootloader aus. Das Boot-Menü bleibt standardmäßig verborgen, drücke also eine beliebige Taste, sobald Limine startet, um es aufzurufen.

Wähle auf diesem Bildschirm anhand von Datum und Version den Snapshot aus, in den du booten möchtest. Die Version von Omarchy zum Zeitpunkt des Snapshots siehst du in der unteren linken Ecke.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Wenn du darin angekommen bist, erscheint eine Benachrichtigung, die dich darüber informiert, dass du dich in einem bootfähigen Snapshot befindest, und wenn du sie anklickst, startet der Wiederherstellungsprozess. Alternativ kannst du `omarchy-snapshot restore` verwenden.

 ![snapshots-restore](images/snapshots-restore.webp)

Dies stellt dein Root-Dateisystem wieder her, aber nicht dein `/home`. Es eignet sich also dazu, ein fehlerhaftes System-Update rückgängig zu machen, aber nicht dazu, verlorene persönliche Dateien wiederherzustellen.

Das bedeutet auch, dass dein `~/.config`-Verzeichnis unverändert bleibt. Wenn du also zu einer früheren Version einer Bibliothek oder Anwendung zurückkehrst, die Konfigurationsdateien in einem neuen Format speichert, musst du das manuell klären.

Dasselbe gilt für Omarchys eigene Aufzeichnung darüber, welche Migrationen bereits gelaufen sind: Sie liegt in deinem Home-Verzeichnis, überlebt die Wiederherstellung also. Migrationen, die nach der Erstellung des Snapshots gelaufen sind, bleiben als erledigt markiert, obwohl die Änderungen, die sie am Root-Dateisystem vorgenommen haben, rückgängig gemacht wurden, und das nächste `omarchy update` wird sie nicht erneut ausführen. Wenn du nach einer Wiederherstellung also erneut aktualisierst und etwas, das ein früheres Update eingerichtet hatte, immer noch fehlt, ist das der wahrscheinliche Grund.

_Hinweis: Diese Funktion ist nur auf Installationen verfügbar, die den Limine-Bootloader verwenden, der seit Omarchy 2.0 der Standard ist. Sie ist nicht verfügbar, wenn du GRUB oder systemd-boot verwendest._
