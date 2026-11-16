# GUIs

## Files

Files (Nautilus) ist der grafische Dateimanager. Mit `Super + Shift + F` öffnest du ihn, und mit `Super + Shift + Alt + F` öffnest du ihn in dem Verzeichnis, in dem sich dein Terminal gerade befindet, was dir eine Menge Klicks erspart. Mit `Ctrl + L` kannst du einen Pfad eingeben, und wenn du bei einer beliebigen Datei `Space` drückst, erhältst du eine Schnellvorschau, ohne irgendetwas zu öffnen.

Schließe einen USB-Stick oder eine SD-Karte an, und sie wird automatisch eingehängt, sodass sie einfach in der Seitenleiste auftaucht. Für alles Aufwendigere — ein Laufwerk formatieren, den SMART-Zustand prüfen, Partitionen erstellen — starte _Disks_ über den App-Launcher (`Super + Space`).

Beim Doppelklicken gelten sinnvolle Standardeinstellungen: Bilder, Videos und Musik öffnen sich in Omaview, PDFs in Document Viewer, Markdown in Omawrite und einfacher Text in dem Editor, der unter _Setup > Default > Editor_ ausgewählt ist.

## Disktree

Wenn das Laufwerk voll läuft und du keine Ahnung hast, was es auffrisst, starte [Disktree](https://github.com/tobi/disktree) über den App-Launcher (`Super + Space`). Es zeigt eine grafische Treemap deines Home-Verzeichnisses. Größere Blöcke belegen mehr Speicherplatz; navigiere mit Tastatur oder Maus in Verzeichnisse hinein, markiere, was weg soll, und überprüfe deine Auswahl, bevor du irgendetwas entfernst. Führe `disktree --disk` aus, um die gesamte Festplatte zu scannen.

## Obsidian

[Obsidian](https://obsidian.md/) ist eine kostenlose und hochgradig erweiterbare Notiz-App, die einfache Markdown-Dateien zur Speicherung verwendet.

Obsidian ist für alle Zwecke kostenlos, einschließlich persönlicher, kommerzieller und gemeinnütziger Nutzung.

Obsidian bietet außerdem ein [kommerzielles Add-on zur Synchronisierung](https://obsidian.md/sync) mit mobilen Apps auf iOS und Android. (https://obsidian.md/pricing).

Du startest Obsidian mit `Super + Shift + O`. Um die Theme-Synchronisierung zu nutzen, musst du in den Einstellungen das Theme `Omarchy` auswählen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ist Omarchys eigene, denkbar einfache Markdown-Schreib-App. Keine Vaults, keine Plugins, nur du und die Worte.

Du startest Omawrite mit `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ist ein einfaches Bildbearbeitungswerkzeug, das sich hervorragend zum Zuschneiden, Skalieren und für andere grundlegende Bearbeitungen eignet. Erwarte nur keine Photoshop-Alternative. Aber es hat trotzdem einen Zauberstab und Ebenen!

Du startest Pinta über den App-Launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ist eine Theming-Anwendung, die Farben aus einem Hintergrundbild extrahieren und sie in ein komplettes, stimmiges Theme verwandeln kann. Das ist der einfachste Weg, [dein eigenes Theme zu erstellen](43-making-your-own-theme.md).

Du startest Aether über den App-Launcher (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lässt dich Dateien an andere Geräte im selben Netzwerk senden, auf denen die App läuft, ähnlich wie Apples AirDrop. Es ist allerdings plattformübergreifend, sodass du Dateien von und zu Windows, macOS, Android, iOS und natürlich Linux senden kannst.

Du kannst das Share-Menü mit `Super + Ctrl + S` oder unter _Trigger > Share_ im Omarchy-Menü öffnen. Es bietet dir vier Optionen:

- **Clipboard** sendet alles, was du kopiert hast, als Textdatei. Ideal, um einen Link oder ein Snippet auf dein Handy zu bekommen, ohne dir selbst eine E-Mail zu schicken.
- **File** öffnet eine Dateiauswahl, in der du mehrere auf einmal auswählen kannst.
- **Folder** sendet ein gesamtes Verzeichnis.
- **Receive** öffnet LocalSend selbst, damit ein anderes Gerät dir etwas senden kann.

Das Gleiche funktioniert vom Terminal aus mit `omarchy share clipboard`, `omarchy share file [path]` und `omarchy share folder [path]`. Lass den Pfad weg, und du erhältst die Auswahl.

Du kannst auch direkt aus dem Dateimanager senden: Klicke in Nautilus mit der rechten Maustaste auf eine beliebige Auswahl und wähle _Send via LocalSend_.

Omarchys Firewall ist standardmäßig geschlossen, mit Ausnahme des Ports von LocalSend, daher funktioniert das bei einer frischen Installation sofort. Siehe [Sicherheit](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ist ein komplettes Office-Paket mit Textverarbeitung, Tabellenkalkulation, Präsentationen, Zeichenprogramm und mehr. Es ist mit Dateien aus Microsoft Office kompatibel, daher ist das eine großartige Möglichkeit, diese Word-Dokumente öffnen zu können.

Du startest LibreOffice über den App-Launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ist Omarchys eigene, denkbar einfache Präsentations-App. Dein Deck ist eine einzelne Markdown-Datei mit ihren Bildern und Videos daneben: Schreibe jede Folie unter einer Live-Vorschau, ziehe Folien in die richtige Reihenfolge und präsentiere dann im Vollbildmodus oder exportiere nach PDF und PowerPoint. Es übernimmt sogar dein Omarchy-Theme.

Du startest Hype über den App-Launcher (`Super + Space`). Drücke `?` darin, um alle Tastaturkürzel zu sehen.

## Signed

[Signed](https://github.com/omacom/signed) ist Omarchys eigene, denkbar einfache Möglichkeit, PDFs zu signieren und auszufüllen. Platziere deine gespeicherte Unterschrift, Text und das heutige Datum irgendwo auf einer Seite und speichere dann eine signierte Kopie neben dem Original. Siehe [PDFs ausfüllen](27-filling-out-pdfs.md), um zu erfahren, wie das geht.

Du startest Signed über den App-Launcher (`Super + Space`) oder öffnest damit ein PDF aus dem Dateimanager.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) ist Omarchys eigenes 3D-Schachspiel. Spiele gegen einen Freund am selben Computer oder gegen den eingebauten Gegner in drei Stufen, auf vier geformten Sets, die sich jeweils auf ihre eigene Weise bewegen: orbitale Fluggeräte, geschnitztes Holz und Elfenbein, Waldwesen und Bonbons. Die Partien haben keine Schachuhr und werden nach jedem Zug gespeichert.

Du startest Checkmate über den App-Launcher (`Super + Space`), wo es als Chess aufgeführt ist. Drücke `?` darin, um alle Tastaturkürzel zu sehen.

## Cards

[Cards](https://github.com/omacom/cards) ist Omarchys eigenes Klondike-Solitaire. Ziehe drei Karten, ohne Begrenzung der Durchläufe, in vier Kartenserien: eine in den Farben deines Themes gezeichnet und drei mit einem eigenen Aussehen. Klicke auf eine Karte und dann dorthin, wo sie hingehen soll, ziehe sie oder doppelklicke, um sie an die beste Stelle zu schicken. Spiele werden nach jedem Zug gespeichert.

Du startest Cards über den App-Launcher (`Super + Space`). Klicke auf seinen Namen oder drücke `?`, um alle Tastaturkürzel zu sehen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ist Omarchys eigener, denkbar einfacher Taschenrechner, der sich in einem schwebenden Fenster öffnet.

Du startest Omacalc mit `Super + Shift + Q` (oder mit der Taschenrechner-Taste, falls deine Tastatur eine hat).

## Signal

[Signal](https://signal.org/) ist der Pionier der E2E-verschlüsselten Nachrichtenübermittlung und eine großartige Kommunikationsoption für alle, die lieber nicht über einen der großen Tech-Konzerne gehen möchten.

Du startest Signal mit `Super + Shift + G`. Es ist nicht Teil der Basisinstallation, daher wird Omarchy dir beim ersten Drücken anbieten, es für dich zu installieren (es befindet sich auch unter _Install > Service_ im Omarchy-Menü).

## Omaview

[Omaview](https://github.com/omacom/omaview) ist Omarchys eigener, denkbar einfacher Bildbetrachter und Medienplayer: ein Fenster für deine Fotos, Videos und Musik. Öffne ein Foto, und die Pfeiltasten blättern durch den Rest seines Ordners, `N` und `P` tun das für alles, und `Ctrl + M` zeigt den gesamten Ordner als Raster. Es zeigt auch HEIC-, AVIF- und JPEG XL-Fotos und macht dort weiter, wo du bei allem Längeren aufgehört hast.

Drücke `F` für Vollbild, `E`, um ein Bild in Omasnap zu bearbeiten oder ein Video in Omacut zu zuschneiden, `Ctrl + P`, um ein Bild zu drucken, und `Delete`, um eine Datei in den Papierkorb zu verschieben (`Ctrl + Z` holt sie zurück). Drücke `?` darin, um alle Tastaturkürzel zu sehen.

Du startest Omaview als _Media Viewer_ über den App-Launcher (`Super + Space`) oder doppelklickst einfach auf ein Bild, ein Video oder einen Song im Dateimanager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ist Omarchys eigener, denkbar einfacher Video-Trimmer. Wenn du nur Anfang und Ende eines Clips abschneiden musst, schlägt das, einen kompletten Video-Editor zu starten.

Du startest Omacut über den App-Launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ist Omarchys eigener, denkbar einfacher Webcam-Recorder. Wähle deine Kamera und dein Mikrofon einmal aus, drücke dann `Space`, um aufzunehmen, und noch einmal, um dieselbe Aufnahme zu pausieren und fortzusetzen. Er nimmt immer mit der höchsten Auflösung deiner Kamera auf, mit einer Live-Mikrofonanzeige, damit du deine Pegel vor dem Start überprüfen kannst.

Beende die Aufnahme, und sie öffnet sich sofort in einem eingebauten Editor. Doppelklicke auf einen Clip, um ihn zu teilen, ziehe an den Griffen, um jedes Stück zu trimmen, und entferne die Teile, die du nicht willst. Speichere ihn dann als MP4. Deine Originalaufnahme wird aufbewahrt, bis du sie verwirfst, sodass du jederzeit zurückkommen und sie anders schneiden kannst.

Du startest Monologue über den App-Launcher (`Super + Space`).
