# GUIs

## Files

Files (Nautilus) ist der grafische Dateimanager. `Super + Shift + F` öffnet ihn, und `Super + Shift + Alt + F` öffnet ihn in dem Verzeichnis, in dem sich dein Terminal gerade befindet, was dir eine Menge Klickerei erspart. Mit `Ctrl + L` kannst du einen Pfad eingeben, und ein Druck auf `Space` bei einer beliebigen Datei zeigt dir eine Schnellvorschau, ohne irgendetwas zu öffnen.

Steck einen USB-Stick oder eine SD-Karte ein, und sie wird automatisch eingehängt, sodass sie einfach in der Seitenleiste auftaucht. Für alles Aufwendigere — ein Laufwerk formatieren, den SMART-Zustand prüfen, Partitionen erstellen — starte _Disks_ über den App-Launcher (`Super + Space`).

Beim Doppelklicken gelten sinnvolle Voreinstellungen: Bilder, Videos und Musik öffnen sich in Omaview, PDFs in Document Viewer, Markdown in Omawrite und einfacher Text in dem Editor, der unter _Setup > Default > Editor_ ausgewählt ist.

## Disktree

Wenn das Laufwerk voll läuft und du keine Ahnung hast, was es auffrisst, starte [Disktree](https://github.com/tobi/disktree) über den App-Launcher (`Super + Space`). Es zeigt eine grafische Treemap deines Home-Verzeichnisses. Größere Blöcke belegen mehr Platz; bewege dich mit Tastatur oder Maus in Verzeichnisse hinein, markiere, was weg soll, und überprüfe deine Auswahl, bevor du irgendetwas entfernst. Führe `disktree --disk` aus, um die gesamte Festplatte zu scannen.

## Obsidian

[Obsidian](https://obsidian.md/) ist eine kostenlose und stark erweiterbare Notiz-App, die einfache Markdown-Dateien zur Speicherung verwendet.

Obsidian ist für alle Zwecke kostenlos, einschließlich persönlicher, kommerzieller und gemeinnütziger Nutzung.

Obsidian bietet außerdem ein [kommerzielles Add-on zur Synchronisierung](https://obsidian.md/sync) mit mobilen Apps auf iOS und Android. (https://obsidian.md/pricing).

Du startest Obsidian mit `Super + Shift + O`. Um Theme-Synchronisierung zu nutzen, musst du in den Einstellungen das `Omarchy`-Theme auswählen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ist Omarchys eigene, denkbar einfache Markdown-Schreib-App. Keine Vaults, keine Plugins, nur du und die Worte.

Du startest Omawrite mit `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ist ein einfaches Bildbearbeitungswerkzeug, das sich hervorragend zum Zuschneiden, Skalieren und für andere grundlegende Bearbeitungen eignet. Erwarte nur keine Photoshop-Alternative. Aber es hat trotzdem einen Zauberstab und Ebenen!

Du startest Pinta über den App-Launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ist eine Theming-App, die Farben aus einem Hintergrundbild extrahieren und sie in ein komplettes, stimmiges Theme verwandeln kann. Das ist der einfachste Weg, [dein eigenes Theme zu erstellen](43-making-your-own-theme.md).

Du startest Aether über den App-Launcher (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lässt dich Dateien an andere Geräte im selben Netzwerk senden, auf denen die App läuft, wie Apples AirDrop. Es ist allerdings plattformübergreifend, sodass du Dateien mit Windows, macOS, Android, iOS und natürlich Linux hin- und hersenden kannst.

Du kannst das Share-Menü mit `Super + Ctrl + S` oder unter _Trigger > Share_ im Omarchy-Menü öffnen. Es bietet dir vier Optionen:

- **Clipboard** sendet alles, was du kopiert hast, als Textdatei. Ideal, um einen Link oder ein Snippet auf dein Handy zu bekommen, ohne dir selbst eine E-Mail zu schicken.
- **File** öffnet eine Dateiauswahl, in der du mehrere auf einmal auswählen kannst.
- **Folder** sendet ein gesamtes Verzeichnis.
- **Receive** öffnet LocalSend selbst, damit ein anderes Gerät dir etwas senden kann.

Dasselbe geht vom Terminal aus mit `omarchy share clipboard`, `omarchy share file [path]` und `omarchy share folder [path]`. Lass den Pfad weg, und du bekommst die Auswahl.

Du kannst auch direkt aus dem Dateimanager senden: Klicke mit der rechten Maustaste auf eine beliebige Auswahl in Nautilus und wähle _Send via LocalSend_.

Omarchys Firewall ist standardmäßig geschlossen, mit Ausnahme des Ports von LocalSend, sodass das auf einer frischen Installation sofort funktioniert. Siehe [Sicherheit](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ist ein komplettes Office-Paket mit Textverarbeitung, Tabellenkalkulation, Präsentationen, Zeichenprogramm und mehr. Es ist mit Dateien aus Microsoft Office kompatibel, also eine großartige Möglichkeit, diese Word-Dokumente öffnen zu können.

Du startest LibreOffice über den App-Launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ist Omarchys eigene, denkbar einfache Präsentations-App. Dein Deck ist eine einzelne Markdown-Datei mit ihren Bildern und Videos daneben: Schreibe jede Folie unter einer Live-Vorschau, ziehe Folien in die richtige Reihenfolge und präsentiere dann im Vollbild oder exportiere nach PDF und PowerPoint. Es übernimmt sogar dein Omarchy-Theme.

Du startest Hype über den App-Launcher (`Super + Space`). Drücke `?` darin, um alle Tastaturkürzel zu sehen.

## Signed

[Signed](https://github.com/omacom/signed) ist Omarchys eigene, denkbar einfache Möglichkeit, PDFs zu signieren und auszufüllen. Platziere deine gespeicherte Unterschrift, Text und das heutige Datum an beliebiger Stelle auf einer Seite und speichere dann eine signierte Kopie neben dem Original. Siehe [PDFs ausfüllen](27-filling-out-pdfs.md), wie das geht.

Du startest Signed über den App-Launcher (`Super + Space`) oder öffnest ein PDF aus dem Dateimanager damit.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) ist Omarchys eigenes 3D-Schachspiel. Spiele mit einem Freund am selben Computer oder gegen den eingebauten Gegner auf drei Stufen, auf vier gestalteten Sets, die sich jeweils auf ihre eigene Weise bewegen: Fluggeräte im Orbit, geschnitztes Holz und Elfenbein, Waldkreaturen und Süßigkeiten. Spiele haben keine Uhr und werden nach jedem Zug gespeichert.

Du startest Checkmate über den App-Launcher (`Super + Space`), wo es als Chess aufgeführt ist. Drücke `?` darin, um alle Tastaturkürzel zu sehen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ist Omarchys eigener, denkbar einfacher Rechner, der in einem schwebenden Fenster öffnet.

Du startest Omacalc mit `Super + Shift + Q` (oder mit der Rechner-Taste, falls deine Tastatur eine hat).

## Signal

[Signal](https://signal.org/) ist der Pionier der E2E-verschlüsselten Nachrichtenübertragung und eine großartige Kommunikationsoption für alle, die lieber nicht über einen der großen Tech-Konzerne gehen möchten.

Du startest Signal mit `Super + Shift + G`. Es ist nicht Teil der Basisinstallation, sodass Omarchy dir beim ersten Drücken anbieten wird, es für dich zu installieren (es steht auch unter _Install > Service_ im Omarchy-Menü).

## Omaview

[Omaview](https://github.com/omacom/omaview) ist Omarchys eigener, denkbar einfacher Bildbetrachter und Mediaplayer: ein Fenster für deine Fotos, Videos und Musik. Öffne ein Foto, und die Pfeiltasten blättern durch den Rest seines Ordners, `N` und `P` tun das für alles, und `Ctrl + M` zeigt den gesamten Ordner als Raster. Es zeigt auch HEIC-, AVIF- und JPEG XL-Fotos und macht bei allem Längeren dort weiter, wo du aufgehört hast.

Drücke `F` für Vollbild, `E`, um ein Bild in Omasnap zu bearbeiten oder ein Video in Omacut zu trimmen, `Ctrl + P`, um ein Bild zu drucken, und `Delete`, um eine Datei in den Papierkorb zu verschieben (`Ctrl + Z` holt sie zurück). Drücke `?` darin, um alle Tastaturkürzel zu sehen.

Du startest Omaview als _Media Viewer_ über den App-Launcher (`Super + Space`) oder doppelklickst einfach auf ein Bild, ein Video oder einen Song im Dateimanager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ist Omarchys eigener, denkbar einfacher Video-Trimmer. Wenn du nur Anfang und Ende eines Clips abschneiden musst, schlägt das allemal, einen kompletten Video-Editor zu starten.

Du startest Omacut über den App-Launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ist Omarchys eigener, denkbar einfacher Webcam-Recorder. Wähle einmal deine Kamera und dein Mikrofon aus, drücke dann `Space`, um aufzunehmen, und noch einmal, um dieselbe Aufnahme zu pausieren und fortzusetzen. Es nimmt immer mit der höchsten Auflösung deiner Kamera auf, mit einer Live-Mikrofonanzeige, sodass du deine Pegel vor dem Start prüfen kannst.

Beende die Aufnahme, und sie öffnet sich sofort in einem eingebauten Editor. Doppelklicke auf einen Clip, um ihn zu teilen, ziehe an den Griffen, um jedes Stück zu trimmen, und entferne die Teile, die du nicht willst. Speichere ihn dann als MP4. Deine Originalaufnahme bleibt erhalten, bis du sie verwirfst, sodass du jederzeit zurückkommen und sie anders schneiden kannst.

Du startest Monologue über den App-Launcher (`Super + Space`).
