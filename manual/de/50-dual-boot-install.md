# Dual-Boot-Installation

Du kannst Omarchy in einer einzelnen Partition neben Windows oder anderen Installationen installieren.

Diese Installationsmethode kommt standardmäßig trotzdem mit LUKS-Verschlüsselung für die Partition, sodass sie sich effektiv nicht von einer kompletten Platteninstallation unterscheidet und einfach freien Speicherplatz auf der Platte braucht.

## Platz unter Windows schaffen

Um neben Windows zu installieren, tippe `disk management` in das Startmenü und wähle die Option **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Finde die passende Partition, klicke mit der rechten Maustaste und wähle **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Gib ein, um wie viel du das Volume verkleinern willst. Beachte, dass das die Größe deiner zukünftigen Omarchy-Installation einschließlich der Boot-Partition ist.

 ![dual-boot-3](images/dual-boot-3.webp)

Wenn du fertig bist, solltest du etwas wie hier sehen, wo der 50-GB-Abschnitt in diesem Beispiel der ist, in dem wir Omarchy installieren.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy installieren

Der Installationsprozess für Omarchy ist effektiv derselbe wie normal. Nachdem du deine Platte ausgewählt hast, bekommst du die Option **Free space install**. Wähle diese Option, um zu verhindern, dass die gesamte Platte gelöscht wird.

 ![dual-boot-5](images/dual-boot-5.webp)

Bestätige, dass alles gut aussieht, und warte wie gewohnt, bis die Installation fertig ist. Hier könntest du dich auch entscheiden, unverschlüsselt zu installieren (nicht empfohlen), genau wie bei einer Installation auf der ganzen Platte.
 ![dual-boot-6](images/dual-boot-6.webp)

## Andere Installationen zum Bootloader hinzufügen

Wenn deine Omarchy-Installation fertig ist, wirst du feststellen, dass jetzt der Limine-Bootloader der Standard ist. Damit kannst du auch Optionen zu Limine für deine anderen Installationen wie Windows hinzufügen.

Führe dazu `limine-scan` aus und folge den Anweisungen, um hinzuzufügen, welche Einträge du in deiner Limine-Konfiguration willst. Beim Booten siehst du dann deine normalen Optionen für Omarchy sowie den Windows Boot Manager oder andere.

## Bitlocker

Wichtig ist, dass diese Installationsmethode nicht mit Bitlocker kompatibel ist, weil es das gesamte Laufwerk verschlüsselt, nicht nur die Partition. Wenn ein Fehler erscheint, der sagt, dass Bitlocker aktiviert ist, boote in Windows, gehe zu **Settings -> Privacy & Security -> Device encryption** und schalte Bitlocker aus. Die Entschlüsselung des Laufwerks kann einige Zeit dauern.

 ![dual-boot-7](images/dual-boot-7.webp)
