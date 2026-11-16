# Systemsnapshots

Wir erstellen bei jedem Omarchy-Update automatisch Snapshots, aber wenn du einen eigenen erstellen möchtest, kannst du `omarchy-snapshot create` verwenden.

Um einen Snapshot zu booten und wiederherzustellen, wählst du ihn im Limine-Bootloader aus. (Wenn du aktuell direkt zum Omarchy-Entschlüsselungsbildschirm bootest, musst du zuerst Limine als Boot-Option über das BIOS auswählen).

Wähle auf diesem Bildschirm anhand von Datum und Version den Snapshot aus, in den du booten möchtest. Die Omarchy-Version zum Zeitpunkt des Snapshots siehst du in der unteren linken Ecke.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Wenn du drin bist, erscheint eine Benachrichtigung, die dich darüber informiert, dass du dich in einem bootfähigen Snapshot befindest, und wenn du sie anklickst, wird der Wiederherstellungsprozess gestartet. Alternativ kannst du `omarchy-snapshot restore` verwenden.

 ![snapshots-restore](images/snapshots-restore.webp)

Dadurch wird dein Root-Dateisystem wiederhergestellt, aber nicht dein `/home`. Das funktioniert also, um ein fehlerhaftes Systemupdate rückgängig zu machen, aber nicht, um verlorene persönliche Dateien wiederherzustellen.

Das bedeutet auch, dass dein Verzeichnis `~/.config` unverändert bleibt. Wenn du also zu einer früheren Version einer Bibliothek oder Anwendung zurückkehrst, die Konfigurationsdateien in einem neuen Format speichert, musst du das manuell in Ordnung bringen.

Das Gleiche gilt für Omarchys eigene Aufzeichnung darüber, welche Migrationen bereits ausgeführt wurden: Sie liegt in deinem Home-Verzeichnis und übersteht daher die Wiederherstellung. Migrationen, die nach dem Erstellen des Snapshots ausgeführt wurden, bleiben als erledigt markiert, obwohl die Änderungen, die sie am Root-Dateisystem vorgenommen haben, rückgängig gemacht wurden, und das nächste `omarchy update` wird sie nicht erneut ausführen. Wenn du also nach einer Wiederherstellung erneut ein Update durchführst und etwas, das ein früheres Update eingerichtet hatte, immer noch fehlt, ist das der wahrscheinliche Grund.

_Hinweis: Diese Funktion ist nur auf Installationen verfügbar, die den Limine-Bootloader verwenden, der seit Omarchy 2.0 der Standard ist. Sie ist nicht verfügbar, wenn du GRUB oder systemd-boot verwendest._

### Das Boot-Menü überspringen

Wenn du das Boot-Menü nie anrührst und einfach möchtest, dass der Rechner direkt zum Entschlüsselungsbildschirm geht, führe _Setup > Direct Boot_ im Omarchy-Menü aus. Dadurch wird ein EFI-Eintrag hinzugefügt, der direkt auf Omarchy zeigt, sodass die Firmware es bootet, ohne bei Limine anzuhalten.

Der Kompromiss ist der oben erwähnte: Wenn Direct Boot aktiviert ist, bedeutet das Erreichen eines Snapshots, dass du zuerst Limine aus deinem BIOS-Boot-Menü auswählen musst. Führe _Setup > Direct Boot_ erneut aus, um den Eintrag zu entfernen und wieder über Limine zu booten. Manche Firmware kommt mit benutzerdefinierten EFI-Einträgen nicht gut klar, daher weigert sich das Setup, auf American Megatrends und Apple Firmware zu laufen.
