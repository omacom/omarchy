# Erste Schritte

Omarchy wird mithilfe einer ISO installiert. Du kannst zwischen einer Installation auf der gesamten Festplatte, die das gesamte Laufwerk übernimmt, oder einer Installation im freien Speicherplatz wählen, die Omarchy in den nicht zugewiesenen Speicherplatz auf einem Laufwerk legt — so richtest du ein Dual-Boot-System neben Windows oder einem anderen OS ein (siehe [Dual-Boot-Installation](50-dual-boot-install.md) — beachte, dass du zuerst BitLocker in Windows deaktivieren musst). In beiden Fällen verwendet die Installation standardmäßig eine vollständige Verschlüsselung, und die Option für die gesamte Festplatte löscht das ausgewählte Laufwerk, also erstelle unbedingt ein Backup, bevor du ein vorhandenes Laufwerk verwendest!

[Lade die Omarchy ISO herunter](https://omarchy.org/), kopiere sie auf einen USB-Stick (verwende [Rufus](https://rufus.ie/) unter Windows, [balenaEtcher](https://etcher.balena.io/) auf dem Mac oder [caligula](https://github.com/ifd3f/caligula) unter Linux) und boote von dem Stick.

_Du musst Secure Boot und/oder TPM im BIOS deaktivieren. Du musst diese deaktivieren, um Omarchy installieren zu können. Das sind Microsoft-Sicherheitssysteme, die für Windows und mit Microsoft verbundene Linux-Distributionen gedacht sind._

Beantworte dann die Konfigurationsfragen und bestätige sie wie folgt:

 ![install-config](images/install-config.webp)

Wähle dann ein Laufwerk für deine Installation aus, lehne dich zurück und sieh dir die Installationsshow an. Auf den schnellsten modernen Rechnern ist sie in weniger als einer Minute erledigt, aber selbst auf einem älteren Computer sollte sie nicht mehr als 5 Minuten dauern.

 ![install-done](images/install-done.webp)

Jetzt bist du bereit für Omarchy!

### Verwende eine kabelgebundene oder 2.4ghz-Tastatur!

Die vollständige Festplattenverschlüsselung erlaubt es dir nicht, das Passwort beim Start von einer Bluetooth-Tastatur einzugeben. Genau wie du keine Bluetooth-Tastatur verwenden kannst, um auf einem PC ins BIOS zu gelangen. Du benötigst eine Tastatur, die entweder einen 2.4ghz-Dongle oder ein Kabel verwendet (was ohnehin viel angenehmer für die Latenz ist!). Ich persönlich liebe die [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installation für einen anderen Besitzer

Wenn du einen Rechner für jemand anderen einrichtest — ein Familienmitglied, einen neuen Mitarbeiter, einen Käufer — solltest du die persönlichen Fragen nicht in deren Namen beantworten. Drücke auf dem allerersten Bildschirm des Installers (der Tastaturauswahl) `Ctrl + C`, und Omarchy wird anbieten, den Rechner stattdessen für einen anderen Besitzer vorzubereiten. Das System wird sofort installiert, aber die gesamte persönliche Einrichtung — Tastaturlayout, Benutzername, Passwort — wird aufgeschoben, bis der Rechner zum ersten Mal startet. Das Laufwerk wird weiterhin standardmäßig verschlüsselt, und das Passwort, das der neue Besitzer bei diesem ersten Start wählt, wird auch zum Verschlüsselungspasswort. (Ein Rechner, den du bereits verwendet hast, kann auch ohne Neuinstallation übergeben werden — siehe [Zurücksetzen des Computers](48-security.md).)

### Unbeaufsichtigte Installationen

Die ISO kann auch vollständig eigenständig installieren — ohne Tastatur, ohne Assistent — wenn ihr ihre Konfiguration auf einem zweiten Laufwerk übergeben wird. So behandelst du Omarchy als Basis-Image für VMs und Maschinenflotten. Siehe [unbeaufsichtigte Installationen](51-unattended-installs.md).

### Installationen ohne Verschlüsselung

Omarchy wird standardmäßig mit Verschlüsselung installiert. Das ist die sichere, verantwortungsvolle Wahl für jeden Computer, der möglicherweise verloren gehen oder gestohlen werden kann. Du willst nicht, dass jemand mit Zugriff auf deine Hardware an deine Daten gelangen kann!

Aber unter besonderen Umständen, wie bei entfernten Omarchy-Installationen auf geschützten Computern oder bei Wegwerf-Installationen ohne sensible Daten, möchtest du vielleicht ohne Verschlüsselung installieren. Du kannst bei der Bestätigung der Festplattenformatierung `Ctrl + C` drücken, um zu einer Installation ohne Verschlüsselung zu wechseln.

### Sprache

Omarchy spricht 50 Sprachen — dieselbe Auswahl wie omarchy.org — und Englisch ist die Standardeinstellung. Um zu wechseln, öffne das Omarchy-Menü und gehe zu _Setup > Sprache_, oder führe `omarchy language <code>` in einem Terminal aus (`omarchy language list` zeigt die Codes an). Das Menü, der Desktop und Omarchys eigene Benachrichtigungen wechseln sofort die Sprache, und jede Anwendung, die du danach öffnest, zieht ebenfalls nach. Anwendungen, die bereits geöffnet waren, wechseln, sobald du sie neu startest.

### Hilfe, wenn du nicht weiterkommst

Wenn du nicht weiterkommst, findest du im Kanal _#omarchy-help_ auf [dem Community-Discord](https://omarchy.org/discord) normalerweise jemanden, der bereit ist zu helfen.
