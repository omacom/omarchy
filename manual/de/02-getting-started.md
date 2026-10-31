# Erste Schritte

Omarchy wird mit einer ISO installiert. Du hast die Wahl zwischen einer Installation auf der gesamten Festplatte, die das ganze Laufwerk übernimmt, oder einer Installation im freien Speicherplatz, die Omarchy in den nicht zugewiesenen Bereich eines Laufwerks packt — so richtest du ein Dual Boot neben Windows oder einem anderen Betriebssystem ein (siehe [Dual-Boot-Installation](50-dual-boot-install.md) — beachte, dass du vorher BitLocker in Windows ausschalten musst). In beiden Fällen ist standardmäßig die vollständige Verschlüsselung aktiviert, und die Option für die gesamte Festplatte löscht das ausgewählte Laufwerk, also mache unbedingt ein Backup, bevor du ein vorhandenes verwendest!

[Lade die Omarchy ISO herunter](https://omarchy.org/), packe sie auf einen USB-Stick (nutze [balenaEtcher](https://etcher.balena.io/) auf Mac/Windows oder [caligula](https://github.com/ifd3f/caligula) auf Linux) und boote vom Stick.

_Du musst Secure Boot und/oder TPM im BIOS ausschalten. Du musst sie ausschalten, um Omarchy installieren zu können. Das sind Microsoft-Sicherheitsschemata für Windows und Microsoft-nahe Linux-Distributionen._

Beantworte dann die Konfigurationsfragen und bestätige sie so:

 ![install-config](images/install-config.webp)

Wähle dann ein Laufwerk für deine Installation aus, lehne dich zurück und schaue dir die Installationsshow an. Auf den schnellsten modernen Rechnern ist das in unter einer Minute erledigt, aber selbst auf einem älteren Computer sollte es nicht länger als 5 Minuten dauern.

 ![install-done](images/install-done.webp)

Jetzt bist du bereit für Omarchy!

### Nutze eine kabelgebundene oder 2.4ghz-Tastatur!

Mit der vollständigen Festplattenverschlüsselung kannst du das Passwort beim Start nicht über eine Bluetooth-Tastatur eingeben. Genauso wenig wie du eine Bluetooth-Tastatur nutzen kannst, um auf einem PC ins BIOS zu gelangen. Du brauchst eine Tastatur, die entweder einen 2.4ghz-Dongle oder ein Kabel nutzt (was für die Latenz ohnehin viel besser ist!). Ich persönlich liebe die [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Für einen anderen Besitzer installieren

Wenn du einen Rechner für jemand anderen einrichtest — ein Familienmitglied, einen neuen Mitarbeiter, einen Käufer — solltest du die persönlichen Fragen nicht stellvertretend für sie beantworten. Drücke auf dem allerersten Bildschirm des Installers (der Tastaturauswahl) `Ctrl + C`, und Omarchy wird anbieten, den Rechner stattdessen für einen anderen Besitzer vorzubereiten. Das System wird sofort installiert, aber die gesamte persönliche Einrichtung — Tastaturlayout, Benutzername, Passwort — wird auf den ersten Start des Rechners verschoben. Das Laufwerk ist standardmäßig weiterhin verschlüsselt, und das Passwort, das der neue Besitzer bei diesem ersten Start wählt, wird auch zum Verschlüsselungspasswort. (Ein Rechner, den du schon benutzt hast, kann auch ohne Neuinstallation übergeben werden — siehe [den Computer zurücksetzen](48-security.md).)

### Unbeaufsichtigte Installationen

Die ISO kann auch völlig eigenständig installieren — keine Tastatur, kein Assistent — wenn ihr die Konfiguration auf einem zweiten Laufwerk übergeben wird. So behandelst du Omarchy als Basisimage für VMs und Maschinen in einer Flotte. Siehe [unbeaufsichtigte Installationen](51-unattended-installs.md).

### Installationen ohne Verschlüsselung

Omarchy wird standardmäßig mit Verschlüsselung installiert. Das ist die sichere, verantwortungsvolle Entscheidung für jeden Computer, der möglicherweise verloren gehen oder gestohlen werden kann. Du willst nicht, dass irgendjemand mit Zugriff auf deine Hardware an deine Daten kommen kann!

Aber unter besonderen Umständen, etwa bei entfernten Omarchy-Installationen auf geschützten Computern oder bei Wegwerf-Installationen ohne sensible Daten, willst du vielleicht ohne Verschlüsselung installieren. Du kannst bei der Bestätigung zur Festplattenformatierung `Ctrl + C` drücken, um zu einer Installation ohne Verschlüsselung zu wechseln.

### Sprache

Omarchy spricht 50 Sprachen — dieselben wie omarchy.org — und Englisch ist die Standardeinstellung. Um zu wechseln, öffne das Omarchy-Menü und gehe zu _Setup > Sprache_, oder führe `omarchy language <code>` in einem Terminal aus (`omarchy language list` zeigt die Codes). Menü, Desktop und Omarchys eigene Benachrichtigungen wechseln sofort die Sprache, und jede Anwendung, die du danach öffnest, folgt ebenfalls. Apps, die schon offen waren, wechseln, sobald du sie neu startest.

### Hilfe, wenn du feststeckst

Wenn du feststeckst, findest du im Kanal _#omarchy-help_ auf [dem Community-Discord](https://omarchy.org/discord) meist jemanden, der dir helfen will.
