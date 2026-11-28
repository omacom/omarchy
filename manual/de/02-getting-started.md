# Erste Schritte

Omarchy wird mit einer ISO installiert. Du kannst zwischen einer Installation auf dem gesamten Laufwerk, die das komplette Laufwerk übernimmt, oder einer Installation im freien Speicherplatz wählen, die Omarchy in den nicht zugewiesenen Bereich eines Laufwerks legt — so richtest du ein Dual-Boot-System neben Windows oder einem anderen OS ein (siehe [Dual-Boot-Installation](50-dual-boot-install.md) — beachte, dass du vorher BitLocker in Windows deaktivieren musst). In beiden Fällen ist die Installation standardmäßig vollständig verschlüsselt, und die Option für das gesamte Laufwerk wird das ausgewählte Laufwerk löschen, also mache unbedingt ein Backup, bevor du ein bereits genutztes Laufwerk verwendest!

Auf einem Apple Silicon Mac installierst du stattdessen von macOS aus, ohne ISO oder USB-Stick. Siehe [Omarchy für Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

[Lade zuerst die Omarchy ISO herunter](https://omarchy.org/), lege sie auf einen USB-Stick (nutze [Rufus](https://rufus.ie/) unter Windows, [balenaEtcher](https://etcher.balena.io/) auf dem Mac oder [caligula](https://github.com/ifd3f/caligula) unter Linux) und starte vom Stick.

_Du musst Secure Boot und/oder TPM im BIOS deaktivieren. Du musst diese deaktivieren, um Omarchy installieren zu können. Es sind Microsoft-Sicherheitsmechanismen, die für Windows und mit Microsoft verbundene Linux-Distributionen gedacht sind._

Beantworte dann die Konfigurationsfragen und bestätige sie so:

 ![install-config](images/install-config.webp)

Wähle dann ein Laufwerk für deine Installation aus, lehn dich zurück und sieh dir die Installationsshow an. Auf den schnellsten modernen Rechnern kann das in unter einer Minute erledigt sein, aber selbst auf einem älteren Computer sollte es nicht mehr als 5 Minuten dauern.

 ![install-done](images/install-done.webp)

Jetzt bist du bereit für Omarchy!

### Nutze eine kabelgebundene Tastatur oder eine mit 2.4ghz!

Die Verschlüsselung des gesamten Laufwerks erlaubt es dir nicht, das Passwort beim Start über eine Bluetooth-Tastatur einzugeben. Genauso, wie du keine Bluetooth-Tastatur verwenden kannst, um in das BIOS eines PCs zu gelangen. Du brauchst eine Tastatur, die entweder einen 2.4ghz-Dongle verwendet oder ein Kabel (was für die Latenz ohnehin viel angenehmer ist!). Ich persönlich liebe die [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installation für einen anderen Besitzer

Wenn du einen Rechner für jemand anderen einrichtest — ein Familienmitglied, einen neuen Mitarbeiter, einen Käufer — solltest du die persönlichen Fragen nicht in ihrem Namen beantworten. Drücke auf dem allerersten Bildschirm des Installers (der Tastaturauswahl) `Ctrl + C`, und Omarchy wird anbieten, den Rechner stattdessen für einen anderen Besitzer vorzubereiten. Das System wird sofort installiert, aber die gesamte persönliche Einrichtung — Tastaturlayout, Benutzername, Passwort — wird aufgeschoben, bis der Rechner zum ersten Mal startet. Das Laufwerk ist weiterhin standardmäßig verschlüsselt, und das Passwort, das der neue Besitzer bei diesem ersten Start wählt, wird auch zum Verschlüsselungspasswort. (Einen Rechner, den du bereits verwendet hast, kannst du auch ohne Neuinstallation übergeben — siehe [Computer zurücksetzen](48-security.md).)

### Unbeaufsichtigte Installationen

Die ISO kann auch völlig eigenständig installieren — ohne Tastatur, ohne Assistent —, wenn ihr ihre Konfiguration auf einem zweiten Laufwerk übergeben wird. So behandelst du Omarchy als Basis-Image für VMs und Maschinenflotten. Siehe [unbeaufsichtigte Installationen](51-unattended-installs.md).

### Installationen ohne Verschlüsselung

Omarchy wird standardmäßig mit Verschlüsselung installiert. Das ist die sichere, verantwortungsvolle Wahl für jeden Computer, der möglicherweise verloren gehen oder gestohlen werden kann. Du willst nicht, dass irgendjemand mit Zugriff auf deine Hardware an deine Daten kommen kann!

Aber unter besonderen Umständen, wie bei Remote-Installationen von Omarchy auf geschützten Computern oder bei Wegwerf-Installationen ohne sensible Daten, möchtest du vielleicht ohne Verschlüsselung installieren. Du kannst bei der Bestätigung der Festplattenformatierung `Ctrl + C` drücken, um zu einer Installation ohne Verschlüsselung zu wechseln.

### Sprache

Omarchy spricht 50 Sprachen — dieselbe Auswahl wie omarchy.org — und Englisch ist die Standardeinstellung. Um zu wechseln, öffne das Omarchy-Menü und gehe zu _Setup > Region > Sprache_, oder führe `omarchy language <code>` in einem Terminal aus (`omarchy language list` zeigt die Codes an). Das Menü, der Desktop und Omarchys eigene Benachrichtigungen wechseln sofort die Sprache, und jede Anwendung, die du danach öffnest, folgt ebenfalls. Anwendungen, die bereits geöffnet waren, wechseln, sobald du sie neu startest.

Um die Sprache beizubehalten, aber Daten, Zeiten, Zahlen, Geldbeträge, Einheiten und Papierformate so zu schreiben, wie es eine andere Region tut (zum Beispiel Englisch mit europäischen Daten und einer 24-Stunden-Uhr), wähle eine Region unter _Setup > Region > Formate_, wo jede Auswahl ein Beispiel zeigt, oder führe `omarchy region formats <code>` aus (`omarchy region formats list` zeigt die Codes an). _Wie die Sprache_ kehrt zu den eigenen Formaten der Sprache zurück. Wie ein Sprachwechsel erreicht es die Anwendungen, die du danach öffnest.

### Hilfe, wenn du nicht weiterkommst

Wenn du nicht weiterkommst, findest du normalerweise jemanden, der bereit ist, dir zu helfen, im Kanal _#omarchy-help_ auf [dem Community-Discord](https://omarchy.org/discord).
