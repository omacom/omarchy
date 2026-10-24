# System-Snapshots

Wir erstellen bei jedem Omarchy-Update automatisch Snapshots, aber solltest du einen eigenen erstellen wollen, kannst du `omarchy-snapshot create` verwenden.

Um einen Snapshot zu booten und wiederherzustellen, wählst du ihn aus dem Limine-Bootloader. (Wenn du derzeit direkt in den Omarchy-Entschlüsselungsbildschirm bootest, musst du zuerst über das BIOS Limine als Boot-Option auswählen.)

Von diesem Bildschirm aus wählst du den Snapshot, in den du booten willst, anhand von Datum und Version. Die Version von Omarchy zum Zeitpunkt des Snapshots steht unten links.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Wenn du drinnen ankommst, erscheint eine Benachrichtigung, die dich informiert, dass du in einem bootfähigen Snapshot bist, und wenn du sie anklickst, startet der Wiederherstellungsprozess. Alternativ kannst du `omarchy-snapshot restore` nutzen.

 ![snapshots-restore](images/snapshots-restore.webp)

Das stellt dein Root-Dateisystem wieder her, aber nicht dein `/home`. Es funktioniert also, um ein kaputtes Systemupdate rückgängig zu machen, aber nicht, um verlorene persönliche Dateien wiederherzustellen.

Das bedeutet auch, dass dein Verzeichnis `~/.config` so bleibt, wie es ist. Wenn du also zu einer früheren Version einer Bibliothek oder Anwendung zurückgehst, die Konfigurationsdateien in einem neuen Format speichert, musst du das manuell klären.

_Hinweis: Diese Funktion ist nur auf Installationen verfügbar, die den Limine-Bootloader verwenden, der seit Omarchy 2.0 der Standard ist. Sie ist nicht verfügbar, wenn du GRUB oder systemd-boot nutzt._

### Das Boot-Menü überspringen

Wenn du das Boot-Menü nie anfasst und willst, dass der Rechner direkt zum Entschlüsselungsbildschirm geht, starte _Einrichtung > Direct Boot_ im Omarchy-Menü. Das fügt einen EFI-Eintrag hinzu, der direkt auf Omarchy zeigt, sodass die Firmware es bootet, ohne bei Limine anzuhalten.

Der Kompromiss ist der oben genannte: Mit eingeschaltetem Direktstart bedeutet der Weg zu einem Snapshot, zuerst Limine aus deinem BIOS-Boot-Menü zu wählen. Starte _Einrichtung > Direct Boot_ erneut, um den Eintrag zu entfernen und wieder über Limine zu booten. Manche Firmware kommt mit eigenen EFI-Einträgen nicht gut zurecht, weshalb sich die Einrichtung auf American Megatrends- und Apple-Firmware weigert zu laufen.
