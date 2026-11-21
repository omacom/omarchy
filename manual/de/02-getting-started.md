# Erste Schritte

Omarchy wird mithilfe einer ISO installiert. Du kannst zwischen einer Installation auf der gesamten Festplatte, die das komplette Laufwerk übernimmt, oder einer Installation im freien Speicherplatz wählen, die Omarchy im nicht zugewiesenen Speicherplatz auf einem Laufwerk ablegt — so dual-bootest du neben Windows oder einem anderen OS (siehe [Dual-Boot-Installation](50-dual-boot-install.md) — beachte, dass du zuerst BitLocker in Windows deaktivieren musst). In beiden Fällen ist die Installation standardmäßig vollständig verschlüsselt, und die Option für die gesamte Festplatte löscht das ausgewählte Laufwerk, also erstelle unbedingt ein Backup, bevor du ein bereits genutztes Laufwerk verwendest!

[Lade die Omarchy-ISO herunter](https://omarchy.org/), bringe sie auf einen USB-Stick (verwende [Rufus](https://rufus.ie/) unter Windows, [balenaEtcher](https://etcher.balena.io/) auf dem Mac oder [caligula](https://github.com/ifd3f/caligula) unter Linux) und boote von dem Stick.

_Du musst Secure Boot und/oder TPM im BIOS deaktivieren. Du musst diese deaktivieren, um Omarchy installieren zu können. Das sind Microsoft-Sicherheitssysteme, die für Windows und mit Microsoft verbundene Linux-Distributionen gedacht sind._

Beantworte dann die Konfigurationsfragen und bestätige sie wie hier:

 ![install-config](images/install-config.webp)

Wähle dann ein Laufwerk für deine Installation aus und lehne dich zurück und sieh dir die Installationsshow an. Auf den schnellsten modernen Rechnern ist sie in unter einer Minute erledigt, aber selbst auf einem älteren Computer sollte sie nicht mehr als 5 Minuten dauern.

 ![install-done](images/install-done.webp)

Jetzt bist du bereit für Omarchy!

### Verwende eine kabelgebundene oder 2.4ghz-Tastatur!

Die Verschlüsselung der gesamten Festplatte erlaubt es dir nicht, das Passwort beim Start über eine Bluetooth-Tastatur einzugeben. Genau wie du keine Bluetooth-Tastatur verwenden kannst, um ins BIOS auf einem PC zu gelangen. Du brauchst eine Tastatur, die entweder einen 2.4ghz-Dongle oder ein Kabel verwendet (was für die Latenz ohnehin viel besser ist!). Ich persönlich liebe die [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Für einen anderen Besitzer installieren

Wenn du einen Rechner für jemand anderen einrichtest — ein Familienmitglied, einen neuen Mitarbeiter, einen Käufer — solltest du die persönlichen Fragen nicht in ihrem Namen beantworten. Drücke `Ctrl + C` auf dem allerersten Bildschirm des Installers (der Tastaturauswahl), und Omarchy wird anbieten, den Rechner stattdessen für einen anderen Besitzer vorzubereiten. Das System wird sofort installiert, aber die gesamte persönliche Einrichtung — Tastaturlayout, Benutzername, Passwort — wird aufgeschoben, bis der Rechner zum ersten Mal bootet. Das Laufwerk ist standardmäßig weiterhin verschlüsselt, und das Passwort, das der neue Besitzer bei diesem ersten Boot wählt, wird auch zum Verschlüsselungspasswort. (Ein Rechner, den du bereits verwendet hast, kann auch ohne Neuinstallation übergeben werden — siehe [Computer zurücksetzen](48-security.md).)

### Unbeaufsichtigte Installationen

Die ISO kann auch völlig eigenständig installieren — keine Tastatur, kein Assistent — wenn ihr ihre Konfiguration auf einem zweiten Laufwerk übergeben wird. So behandelst du Omarchy als Basis-Image für VMs und Flottenrechner. Siehe [unbeaufsichtigte Installationen](51-unattended-installs.md).

### Installationen ohne Verschlüsselung

Omarchy wird standardmäßig mit Verschlüsselung installiert. Das ist die sichere, verantwortungsvolle Wahl für jeden Computer, der möglicherweise verloren gehen oder gestohlen werden kann. Du willst nicht, dass jemand mit Zugriff auf deine Hardware an deine Daten gelangen kann!

Aber unter besonderen Umständen, etwa bei Remote-Omarchy-Installationen auf geschützten Computern oder bei Wegwerf-Installationen ohne sensible Daten, möchtest du vielleicht ohne Verschlüsselung installieren. Du kannst bei der Bestätigung der Festplattenformatierung `Ctrl + C` drücken, um zu einer Installation ohne Verschlüsselung zu wechseln.

### Sprache

Omarchy spricht 50 Sprachen — dieselbe Auswahl wie omarchy.org — und Englisch ist die Standardsprache. Um zu wechseln, öffne das Omarchy-Menü und gehe zu _Einrichtung > Region > Sprache_, oder führe `omarchy language <code>` in einem Terminal aus (`omarchy language list` zeigt die Codes). Das Menü, der Desktop und Omarchys eigene Benachrichtigungen wechseln die Sprache sofort, und jede Anwendung, die du danach öffnest, folgt ebenfalls. Apps, die bereits geöffnet waren, wechseln, sobald du sie neu startest.

Um die Sprache beizubehalten, aber Datumsangaben, Uhrzeiten, Zahlen, Geld, Einheiten und Papierformate so zu schreiben, wie es eine andere Region tut (etwa Englisch mit europäischen Datumsangaben und einer 24-Stunden-Uhr), wähle eine Region unter _Einrichtung > Region > Formate_, wo jede Auswahl ein Beispiel zeigt, oder führe `omarchy region <code>` aus (`omarchy region list` zeigt die Codes). _Wie die Sprache_ kehrt zu den eigenen Formaten der Sprache zurück. Wie ein Sprachwechsel erreicht sie die Apps, die du danach öffnest.

### Hilfe, wenn du nicht weiterkommst

Wenn du nicht weiterkommst, findest du normalerweise jemanden, der dir helfen kann, im Kanal _#omarchy-help_ auf [dem Community-Discord](https://omarchy.org/discord).
