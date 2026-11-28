# Dual-Boot-Installation

Du kannst Omarchy auf einer einzelnen Partition neben Windows oder anderen Installationen installieren.

Diese Installationsmethode bietet standardmäßig trotzdem LUKS-Verschlüsselung für die Partition, sodass sie sich effektiv nicht von einer Installation auf der gesamten Festplatte unterscheidet und einfach nur freien Speicherplatz auf der Festplatte erfordert.

## Unter Windows Platz schaffen

Um Omarchy neben Windows zu installieren, gib `disk management` im Startmenü ein und wähle die Option **Festplattenpartitionen erstellen und formatieren** aus.

 ![dual-boot-1](images/dual-boot-1.webp)

Suche die passende Partition, klicke mit der rechten Maustaste darauf und wähle **Volume verkleinern**.

![dual-boot-2](images/dual-boot-2.webp)

Gib den Betrag ein, um den du das Volume verkleinern möchtest. Beachte, dass dies die Größe deiner zukünftigen Omarchy-Installation einschließlich der Boot-Partition sein wird.

 ![dual-boot-3](images/dual-boot-3.webp)

Wenn du fertig bist, solltest du etwas Ähnliches sehen wie hier, wobei der 50GB-Abschnitt in diesem Beispiel der Bereich ist, in dem wir Omarchy installieren werden.

 ![dual-boot-4](images/dual-boot-4.webp)

## Omarchy installieren

Der Installationsprozess für Omarchy ist effektiv derselbe wie normal. Nachdem du deine Festplatte ausgewählt hast, erhältst du die Option **Installation auf freiem Speicherplatz**. Wähle diese Option, um zu verhindern, dass die gesamte Festplatte gelöscht wird.

 ![dual-boot-5](images/dual-boot-5.webp)

Bestätige, dass alles gut aussieht, und warte wie gewohnt, bis die Installation abgeschlossen ist. Hier könntest du dich auch wie bei einer Installation auf der gesamten Festplatte dafür entscheiden, unverschlüsselt zu installieren (nicht empfohlen).
 ![dual-boot-6](images/dual-boot-6.webp)

## Andere Installationen zum Bootloader hinzufügen

Wenn du deine Omarchy-Installation abgeschlossen hast, wirst du bemerken, dass jetzt der Limine-Bootloader der Standard ist. Damit kannst du Limine auch Optionen für deine anderen Installationen wie Windows hinzufügen.

Um andere Betriebssysteme hinzuzufügen, führe `limine-scan` aus und folge den Anweisungen, um die gewünschten Einträge zu deiner Limine-Konfiguration hinzuzufügen. Das Boot-Menü bleibt standardmäßig verborgen und startet Omarchy nach einer Sekunde. Um Windows oder einen anderen Eintrag zu wählen, drücke eine beliebige Taste, sobald Limine startet; wenn das Menü erscheint, wähle mit den Pfeiltasten einen Eintrag aus und drücke Enter. Wenn Omarchy startet, bevor du eine Taste drückst, starte neu und versuche es erneut.

## Bitlocker

Wichtig zu beachten ist, dass diese Installationsmethode nicht mit Bitlocker kompatibel ist, da Bitlocker die gesamte Festplatte verschlüsselt, nicht nur die Partition. Wenn du einen Fehler erhältst, der besagt, dass Bitlocker aktiviert ist, boote Windows, gehe zu **Einstellungen -> Datenschutz & Sicherheit -> Geräteverschlüsselung** und schalte Bitlocker aus. Es kann einige Zeit dauern, die Festplatte zu entschlüsseln.

 ![dual-boot-7](images/dual-boot-7.webp)

## Windows neu installieren

Wenn dieser Computer mit Windows ausgeliefert wurde, ist sein Produktschlüssel in der Firmware gespeichert. Führe `omarchy windows key` aus, um ihn anzuzeigen, damit du Windows wieder aktivieren kannst, falls du es auf diesem Computer jemals neu installierst.
