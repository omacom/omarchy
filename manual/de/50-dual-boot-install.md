# Dual-Boot-Installation

Du kannst Omarchy auf einer einzelnen Partition neben Windows oder anderen Installationen installieren.

Diese Installationsmethode nutzt standardmäßig weiterhin LUKS-Verschlüsselung für die Partition, sodass sie sich effektiv nicht von einer Installation auf dem gesamten Laufwerk unterscheidet und lediglich freien Speicherplatz auf der Festplatte erfordert.

## Platz auf Windows schaffen

Um Omarchy neben Windows zu installieren, gib `disk management` in das Startmenü ein und wähle die Option **Create and format hard disk partitions** aus.

 ![dual-boot-1](images/dual-boot-1.webp)

Finde die entsprechende Partition, klicke mit der rechten Maustaste darauf und wähle **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Gib den Betrag ein, um den du das Volume verkleinern möchtest. Beachte, dass dies die Größe deiner zukünftigen Omarchy-Installation einschließlich der Boot-Partition sein wird.

 ![dual-boot-3](images/dual-boot-3.webp)

Wenn du fertig bist, solltest du etwas wie dies sehen, wobei der 50GB-Abschnitt in diesem Beispiel der Bereich ist, in dem wir Omarchy installieren werden.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy installieren

Der Installationsprozess für Omarchy ist effektiv derselbe wie normal. Nachdem du deine Festplatte ausgewählt hast, erhältst du die Option **Free space install**. Wähle diese Option aus, um zu verhindern, dass die gesamte Festplatte gelöscht wird.

 ![dual-boot-5](images/dual-boot-5.webp)

Bestätige, dass alles gut aussieht, und warte wie gewohnt, bis die Installation abgeschlossen ist. Hier könntest du dich auch dafür entscheiden, unverschlüsselt zu installieren (nicht empfohlen), genau wie bei einer Installation auf dem gesamten Laufwerk.
 ![dual-boot-6](images/dual-boot-6.webp)

## Andere Installationen zum Bootloader hinzufügen

Wenn du deine Omarchy-Installation abgeschlossen hast, wirst du feststellen, dass der Limine-Bootloader jetzt der Standard ist. Damit kannst du Limine auch Optionen für deine anderen Installationen wie Windows hinzufügen.

Um andere Betriebssysteme hinzuzufügen, führe `limine-scan` aus und folge den Anweisungen, um die gewünschten Einträge zu deiner Limine-Konfiguration hinzuzufügen. Das Boot-Menü bleibt standardmäßig verborgen und startet Omarchy nach einer Sekunde. Um Windows oder einen anderen Eintrag auszuwählen, drücke eine beliebige Taste, sobald Limine startet; wenn das Menü erscheint, verwende die Pfeiltasten, um einen Eintrag auszuwählen, und drücke Enter. Wenn Omarchy startet, bevor du eine Taste drückst, starte neu und versuche es erneut. Wenn du _Setup > Direct Boot_ aktiviert hast, überspringt die Firmware Limine vollständig, also wähle Limine aus deinem BIOS-Boot-Menü aus oder führe _Setup > Direct Boot_ erneut aus, um den Eintrag zu entfernen.

## Bitlocker

Es ist wichtig zu beachten, dass diese Installationsmethode nicht mit Bitlocker kompatibel ist, da Bitlocker das gesamte Laufwerk verschlüsselt, nicht nur die Partition. Wenn du einen Fehler erhältst, der besagt, dass Bitlocker aktiviert ist, starte Windows, gehe zu **Settings -> Privacy & Security -> Device encryption** und schalte Bitlocker aus. Es kann einige Zeit dauern, das Laufwerk zu entschlüsseln.

 ![dual-boot-7](images/dual-boot-7.webp)
