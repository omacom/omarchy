# Erste Schritte

Omarchy wird mit einem ISO installiert. Du kannst zwischen einer Installation auf der gesamten Festplatte, die das komplette Laufwerk übernimmt, und einer Installation im freien Speicherplatz wählen, die Omarchy in den nicht zugewiesenen Speicherplatz auf einem Laufwerk legt — so richtest du ein Dual-Boot-System neben Windows oder einem anderen Betriebssystem ein (siehe [Dual-Boot-Installation](50-dual-boot-install.md) — beachte, dass du in Windows zuerst BitLocker deaktivieren musst). In beiden Fällen ist die Installation standardmäßig vollständig verschlüsselt, und die Option für die gesamte Festplatte löscht das ausgewählte Laufwerk, also erstelle unbedingt ein Backup, bevor du ein bereits genutztes Laufwerk verwendest!

[Lade das Omarchy ISO herunter](https://omarchy.org/), kopiere es auf einen USB-Stick (nutze [Rufus](https://rufus.ie/) unter Windows, [balenaEtcher](https://etcher.balena.io/) auf dem Mac oder [caligula](https://github.com/ifd3f/caligula) unter Linux) und boote von dem Stick.

_Du musst Secure Boot und/oder TPM im BIOS deaktivieren. Du musst diese deaktivieren, um Omarchy installieren zu können. Das sind Microsoft-Sicherheitstechnologien, die für Windows und mit Microsoft verbundene Linux-Distributionen gedacht sind._

Beantworte dann die Konfigurationsfragen und bestätige sie so:

 ![install-config](images/install-config.webp)

Wähle dann ein Laufwerk für deine Installation aus, lehn dich zurück und sieh dir die Installationsshow an. Auf den schnellsten modernen Rechnern ist sie in unter einer Minute erledigt, aber selbst auf einem älteren Computer sollte sie nicht mehr als 5 Minuten dauern.

 ![install-done](images/install-done.webp)

Jetzt bist du bereit für Omarchy!

### Verwende eine kabelgebundene oder 2.4ghz Tastatur!

Die Verschlüsselung der gesamten Festplatte erlaubt es dir nicht, das Passwort beim Start von einer Bluetooth-Tastatur einzugeben. Genau wie du keine Bluetooth-Tastatur verwenden kannst, um ins BIOS auf einem PC zu gelangen. Du brauchst eine Tastatur, die entweder einen 2.4ghz-Dongle verwendet oder ein Kabel (was für die Latenz ohnehin viel angenehmer ist!). Ich persönlich liebe die [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Für einen anderen Besitzer installieren

Wenn du einen Rechner für jemand anderen einrichtest — ein Familienmitglied, einen neuen Mitarbeiter, einen Käufer — solltest du die persönlichen Fragen nicht in ihrem Namen beantworten. Drücke `Ctrl + C` auf dem allerersten Bildschirm des Installers (der Tastaturauswahl), und Omarchy wird anbieten, den Rechner stattdessen für einen anderen Besitzer vorzubereiten. Das System installiert sich sofort, aber die gesamte persönliche Einrichtung — Tastaturlayout, Benutzername, Passwort — wird aufgeschoben, bis der Rechner zum ersten Mal bootet. Das Laufwerk ist weiterhin standardmäßig verschlüsselt, und das Passwort, das der neue Besitzer bei diesem ersten Boot wählt, wird auch zum Verschlüsselungspasswort. (Ein Rechner, den du bereits verwendet hast, kann auch ohne Neuinstallation übergeben werden — siehe [Computer zurücksetzen](48-security.md).)

### Unbeaufsichtigte Installationen

Das ISO kann sich auch vollständig von selbst installieren — keine Tastatur, kein Assistent — wenn ihm seine Konfiguration auf einem zweiten Laufwerk übergeben wird. So behandelst du Omarchy als Basis-Image für VMs und Maschinenflotten. Siehe [unbeaufsichtigte Installationen](51-unattended-installs.md).

### Installationen ohne Verschlüsselung

Omarchy wird standardmäßig mit Verschlüsselung installiert. Das ist die sichere, verantwortungsvolle Wahl für jeden Computer, der möglicherweise verloren gehen oder gestohlen werden kann. Du willst nicht, dass jemand mit Zugang zu deiner Hardware an deine Daten kommen kann!

Aber unter besonderen Umständen, etwa bei entfernten Omarchy-Installationen auf geschützten Computern oder bei Wegwerf-Installationen ohne sensible Daten, möchtest du vielleicht ohne Verschlüsselung installieren. Du kannst bei der Bestätigung zur Formatierung der Festplatte `Ctrl + C` drücken, um zu einer Installation ohne Verschlüsselung zu wechseln.

### Sprache

Omarchy spricht 50 Sprachen — die gleiche Auswahl wie omarchy.org — und Englisch ist der Standard. Um zu wechseln, öffne das Omarchy-Menü und gehe zu _Setup > Region > Language_, oder führe `omarchy language <code>` in einem Terminal aus (`omarchy language list` zeigt die Codes). Das Menü, der Desktop und Omarchys eigene Benachrichtigungen wechseln sofort die Sprache, und jede Anwendung, die du danach öffnest, zieht ebenfalls nach. Apps, die bereits geöffnet waren, wechseln, sobald du sie neu startest.

Um die Sprache zu behalten, aber Daten, Uhrzeiten, Zahlen, Geldbeträge, Einheiten und Papierformate so zu schreiben, wie es eine andere Region tut (etwa Englisch mit europäischen Daten und einer 24-Stunden-Uhr), wähle eine Region unter _Setup > Region > Formats_, wo jede Auswahl ein Beispiel zeigt, oder führe `omarchy region formats <code>` aus (`omarchy region formats list` zeigt die Codes). _Same as language_ wechselt zurück zu den eigenen Formaten der Sprache. Wie ein Sprachwechsel erreicht es die Apps, die du danach öffnest.

### Hilfe, wenn du nicht weiterkommst

Wenn du nicht weiterkommst, findest du im Kanal _#omarchy-help_ auf [dem Community-Discord](https://omarchy.org/discord) normalerweise jemanden, der bereit ist zu helfen.
