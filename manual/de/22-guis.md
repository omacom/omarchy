# GUIs

## Dateien

Dateien (Nautilus) ist der grafische Dateimanager. `Super + Shift + F` öffnet ihn, und `Super + Shift + Alt + F` öffnet ihn in dem Verzeichnis, in dem sich dein Terminal gerade befindet, was dir viel Klickarbeit erspart. Mit `Ctrl + L` kannst du einen Pfad eintippen, und ein Druck auf `Space` bei einer beliebigen Datei gibt dir eine Schnellvorschau, ohne etwas zu öffnen.

Stecke einen USB-Stick oder eine SD-Karte ein, und sie wird automatisch eingehängt, sodass sie einfach in der Seitenleiste auftaucht. Für alles Aufwendigere — ein Laufwerk formatieren, den SMART-Zustand prüfen, Partitionen erstellen — starte _Disks_ aus dem App-Launcher (`Super + Space`).

Doppelklicks folgen sinnvollen Standards: Bilder öffnen sich in imv, Videos in mpv, PDFs in Document Viewer und einfacher Text in Neovim.

## Disktree

Wenn das Laufwerk voll ist und du keine Ahnung hast, was es frisst, starte [Disktree](https://github.com/tobi/disktree) aus dem App-Launcher (`Super + Space`). Es zeigt eine grafische Treemap deines Home-Verzeichnisses. Größere Blöcke nehmen mehr Platz ein; bewege dich mit Tastatur oder Maus in Verzeichnisse hinein, markiere, was weg soll, und überprüfe deine Auswahl, bevor du etwas entfernst. Führe `disktree --disk` aus, um die ganze Platte zu scannen.

## Obsidian

[Obsidian](https://obsidian.md/) ist eine kostenlose und hochgradig erweiterbare Notizanwendung, die einfache Markdown-Dateien zur Speicherung nutzt.

Obsidian ist für alle Zwecke kostenlos, einschließlich persönlicher, kommerzieller und gemeinnütziger Nutzung.

Obsidian bietet außerdem ein [kommerzielles Add-on zur Synchronisierung](https://obsidian.md/sync) mit mobilen Apps für iOS und Android. (https://obsidian.md/pricing).

Du startest Obsidian mit `Super + Shift + O`. Um die Design-Synchronisierung zu nutzen, musst du in den Einstellungen das Design `Omarchy` auswählen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ist Omarchys eigene, kinderleichte Markdown-Schreib-App. Keine Vaults, keine Plugins, nur du und die Worte.

Du startest Omawrite mit `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ist ein einfaches Bildbearbeitungswerkzeug, das sich hervorragend zum Zuschneiden, Skalieren und für andere grundlegende Bearbeitungen eignet. Erwarte nur keine Photoshop-Alternative. Aber es hat trotzdem einen Zauberstab und Ebenen!

Du startest Pinta über den App-Launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ist eine Design-Anwendung, die Farben aus einem Hintergrundbild extrahieren und in ein vollständiges, stimmiges Design verwandeln kann. Das ist der einfachste Weg, [dein eigenes Design zu erstellen](43-making-your-own-theme.md).

Du startest Aether über den App-Launcher (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lässt dich Dateien an andere Geräte im selben Netzwerk senden, auf denen die App läuft, wie Apples AirDrop. Es ist allerdings plattformübergreifend, sodass du Dateien mit Windows, macOS, Android, iOS und natürlich Linux austauschen kannst.

Das Menü Teilen öffnest du mit `Super + Ctrl + S` oder im Omarchy-Menü unter _Auslösen > Teilen_. Es bietet dir vier Optionen:

- **Zwischenablage** sendet alles, was du kopiert hast, als Textdatei. Ideal, um einen Link oder ein Snippet auf dein Handy zu bekommen, ohne dir selbst eine E-Mail zu schreiben.
- **Datei** öffnet eine Dateiauswahl, in der du mehrere auf einmal auswählen kannst.
- **Ordner** sendet ein ganzes Verzeichnis.
- **Empfangen** öffnet LocalSend selbst, damit ein anderes Gerät dir etwas senden kann.

Dasselbe funktioniert vom Terminal aus mit `omarchy share clipboard`, `omarchy share file [path]` und `omarchy share folder [path]`. Lass den Pfad weg, und du erhältst die Auswahl.

Du kannst auch direkt aus dem Dateimanager senden: Klicke in Nautilus mit der rechten Maustaste auf eine Auswahl und wähle _Send via LocalSend_.

Omarchys Firewall ist standardmäßig geschlossen, außer für den Port von LocalSend, sodass dies bei einer frischen Installation von Haus aus funktioniert. Siehe [Sicherheit](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ist ein komplettes Office-Paket mit Textverarbeitung, Tabellenkalkulation, Präsentationen, Zeichenprogramm und mehr. Es ist kompatibel mit Dateien aus Microsoft Office, sodass dies eine großartige Möglichkeit ist, diese Word-Dokumente zu öffnen.

Du startest LibreOffice über den App-Launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ist Omarchys eigene, kinderleichte Präsentations-App. Dein Deck ist eine einzige Markdown-Datei mit ihren Bildern und Videos daneben: Schreibe jede Folie unter einer Live-Vorschau, ziehe Folien in die richtige Reihenfolge und präsentiere dann im Vollbild oder exportiere nach PDF und PowerPoint. Es übernimmt sogar dein Omarchy-Design.

Du startest Hype über den App-Launcher (`Super + Space`). Drücke `?` darin, um jedes Tastenkürzel zu sehen.

## Signed

[Signed](https://github.com/omacom/signed) ist Omarchys eigener, kinderleichter Weg, PDFs zu unterschreiben und auszufüllen. Platziere deine gespeicherte Unterschrift, Text und das heutige Datum an beliebiger Stelle auf einer Seite und speichere dann eine signierte Kopie neben dem Original. Wie das geht, steht unter [PDFs ausfüllen](27-filling-out-pdfs.md).

Du startest Signed über den App-Launcher (`Super + Space`) oder öffnest ein PDF damit aus dem Dateimanager.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ist Omarchys eigener, kinderleichter Taschenrechner, der sich in einem schwebenden Fenster öffnet.

Du startest Omacalc mit `Super + Ctrl + Q` (oder mit der Taschenrechner-Taste, falls deine Tastatur eine hat).

## Signal

[Signal](https://signal.org/) ist der Pionier der Ende-zu-Ende-verschlüsselten Nachrichten und eine großartige Kommunikationsoption für alle, die lieber nicht über einen der großen Tech-Konzerne gehen möchten.

Du startest Signal mit `Super + Shift + G`. Es ist nicht Teil der Basisinstallation, sodass Omarchy beim ersten Drücken anbietet, es für dich zu installieren (es steht auch im Omarchy-Menü unter _Installieren > Service_).

## mpv

[mpv](https://mpv.io/) ist ein einfacher, schneller Mediaplayer, der fast alles aus fast jeder Quelle abspielt. Ideal zum Videoschauen.

Du startest mpv über den App-Launcher (`Super + Space`) oder per Doppelklick auf ein Video im Dateimanager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ist Omarchys eigener, kinderleichter Video-Trimmer. Wenn du nur Anfang und Ende eines Clips abschneiden musst, schlägt er das Hochfahren eines ausgewachsenen Videoeditors.

Du startest Omacut über den App-Launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ist Omarchys eigener, kinderleichter Webcam-Recorder. Wähle einmal deine Kamera und dein Mikrofon, drücke dann `Space` zum Aufnehmen und erneut zum Pausieren und Fortsetzen derselben Aufnahme. Er zeichnet immer in der höchsten Auflösung deiner Kamera auf, mit einer Live-Mikrofonanzeige, damit du deine Pegel vor dem Start prüfen kannst.

Stoppe die Aufnahme, und sie öffnet sich sofort in einem eingebauten Editor. Doppelklicke einen Clip, um ihn zu teilen, ziehe an den Griffen, um jedes Stück zu trimmen, und entferne die Teile, die du nicht willst. Speichere ihn dann als MP4. Deine Originalaufnahme bleibt erhalten, bis du sie verwirfst, sodass du jederzeit zurückkehren und sie anders schneiden kannst.

Du startest Monologue über den App-Launcher (`Super + Space`).
