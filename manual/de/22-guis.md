# GUIs

## Files

Files (Nautilus) ist der grafische Dateimanager. `Super + Shift + F` öffnet ihn, und `Super + Shift + Alt + F` öffnet ihn in dem Verzeichnis, in dem sich dein Terminal gerade befindet, was dir eine Menge Klickerei erspart. Mit `Ctrl + L` kannst du einen Pfad eingeben, und ein Druck auf `Space` bei einer beliebigen Datei zeigt dir eine Schnellvorschau, ohne irgendetwas zu öffnen.

Steck einen USB-Stick oder eine SD-Karte ein, und sie wird automatisch eingehängt, sodass sie einfach in der Seitenleiste auftaucht. Für alles Aufwendigere — ein Laufwerk formatieren, den SMART-Zustand prüfen, Partitionen erstellen — starte _Disks_ über den App-Launcher (`Super + Space`).

Doppelklicks folgen sinnvollen Standardeinstellungen: Bilder öffnen sich in imv, Videos in mpv, PDFs in Document Viewer und reiner Text in Neovim.

## Disktree

Wenn das Laufwerk voll läuft und du keine Ahnung hast, was den ganzen Platz frisst, starte [Disktree](https://github.com/tobi/disktree) über den App-Launcher (`Super + Space`). Es zeigt eine grafische Treemap deines Home-Verzeichnisses. Größere Blöcke belegen mehr Platz; navigiere mit Tastatur oder Maus in Verzeichnisse hinein, markiere, was weg soll, und überprüfe deine Auswahl, bevor du irgendetwas entfernst. Führe `disktree --disk` aus, um die ganze Platte zu scannen.

## Obsidian

[Obsidian](https://obsidian.md/) ist eine kostenlose und stark erweiterbare Notizen-App, die einfache Markdown-Dateien zur Speicherung verwendet.

Obsidian ist für alle Zwecke kostenlos, einschließlich persönlicher, kommerzieller und gemeinnütziger Nutzung.

Obsidian bietet außerdem ein [kommerzielles Add-on zum Synchronisieren](https://obsidian.md/sync) mit mobilen Apps auf iOS und Android. (https://obsidian.md/pricing).

Du startest Obsidian mit `Super + Shift + O`. Um die Theme-Synchronisierung zu nutzen, musst du in den Einstellungen das Theme `Omarchy` auswählen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ist Omarchys eigene, denkbar einfache Markdown-Schreib-App. Keine Vaults, keine Plugins, nur du und die Worte.

Du startest Omawrite mit `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ist ein einfaches Bildbearbeitungswerkzeug, das sich hervorragend zum Zuschneiden, Skalieren und für andere grundlegende Bearbeitungen eignet. Erwarte nur keine Photoshop-Alternative. Aber es hat trotzdem einen Magic Wand und Ebenen!

Du startest Pinta über den App-Launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ist eine Theming-Anwendung, die Farben aus einem Hintergrundbild extrahieren und daraus ein komplettes, stimmiges Theme machen kann. Das ist der einfachste Weg, [dein eigenes Theme zu erstellen](43-making-your-own-theme.md).

Du startest Aether über den App-Launcher (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lässt dich Dateien an andere Geräte im selben Netzwerk senden, auf denen die App läuft, ähnlich wie Apple's AirDrop. Es ist allerdings plattformübergreifend, sodass du Dateien von und nach Windows, macOS, Android, iOS und natürlich Linux senden kannst.

Du kannst das Share-Menü mit `Super + Ctrl + S` oder unter _Trigger > Share_ im Omarchy-Menü öffnen. Es bietet dir vier Optionen:

- **Clipboard** sendet alles, was du kopiert hast, als Textdatei. Ideal, um einen Link oder ein Snippet auf dein Handy zu bekommen, ohne dir selbst eine E-Mail zu schicken.
- **File** öffnet eine Dateiauswahl, in der du mehrere gleichzeitig auswählen kannst.
- **Folder** sendet ein ganzes Verzeichnis.
- **Receive** öffnet LocalSend selbst, sodass dir ein anderes Gerät etwas senden kann.

Dasselbe funktioniert vom Terminal aus mit `omarchy share clipboard`, `omarchy share file [path]` und `omarchy share folder [path]`. Lass den Pfad weg, und du bekommst die Auswahl.

Du kannst auch direkt aus dem Dateimanager senden: Klicke in Nautilus mit der rechten Maustaste auf eine beliebige Auswahl und wähle _Send via LocalSend_.

Omarchys Firewall ist standardmäßig geschlossen, mit Ausnahme des Ports von LocalSend, sodass das bei einer frischen Installation sofort einsatzbereit funktioniert. Siehe [Sicherheit](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ist ein komplettes Office-Paket mit Textverarbeitung, Tabellenkalkulation, Präsentationen, Zeichenprogramm und mehr. Es ist mit Dateien aus Microsoft Office kompatibel, sodass das eine großartige Möglichkeit ist, diese Word-Dokumente öffnen zu können.

Du startest LibreOffice über den App-Launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ist Omarchys eigene, denkbar einfache Präsentations-App. Dein Deck ist eine einzelne Markdown-Datei mit ihren Bildern und Videos daneben: Schreibe jede Folie unter einer Live-Vorschau, ziehe Folien in die richtige Reihenfolge, präsentiere dann im Vollbildmodus oder exportiere nach PDF und PowerPoint. Es übernimmt sogar dein Omarchy-Theme.

Du startest Hype über den App-Launcher (`Super + Space`). Drücke `?` darin, um jeden Shortcut zu sehen.

## Signed

[Signed](https://github.com/omacom/signed) ist Omarchys eigene, denkbar einfache Möglichkeit, PDFs zu signieren und auszufüllen. Platziere deine gespeicherte Signatur, Text und das heutige Datum an beliebiger Stelle auf einer Seite und speichere dann eine signierte Kopie neben dem Original. Wie das geht, erfährst du unter [PDFs ausfüllen](27-filling-out-pdfs.md).

Du startest Signed über den App-Launcher (`Super + Space`) oder öffnest damit ein PDF aus dem Dateimanager.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ist Omarchys eigener, denkbar einfacher Taschenrechner, der sich in einem schwebenden Fenster öffnet.

Du startest Omacalc mit `Super + Shift + Q` (oder mit der Taschenrechnertaste, falls deine Tastatur eine hat).

## Signal

[Signal](https://signal.org/) ist der Pionier der E2E-verschlüsselten Nachrichtenübermittlung und eine großartige Kommunikationsmöglichkeit für alle, die lieber nicht über einen der großen Tech-Konzerne gehen möchten.

Du startest Signal mit `Super + Shift + G`. Es ist nicht Teil der Basisinstallation, sodass Omarchy dir beim ersten Mal, wenn du diese Kombination drückst, anbieten wird, es für dich zu installieren (es befindet sich auch unter _Install > Service_ im Omarchy-Menü).

## mpv

[mpv](https://mpv.io/) ist ein einfacher, schneller Mediaplayer, der fast alles aus jeder Quelle abspielt. Ideal zum Videoschauen.

Du startest mpv über den App-Launcher (`Super + Space`) oder doppelklickst einfach auf ein Video im Dateimanager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ist Omarchys eigener, denkbar einfacher Videotrimmer. Wenn du nur Anfang und Ende eines Clips abschneiden musst, schlägt das allemal, einen kompletten Videoeditor zu starten.

Du startest Omacut über den App-Launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ist Omarchys eigener, denkbar einfacher Webcam-Recorder. Wähle einmal deine Kamera und dein Mikrofon, drücke dann `Space`, um aufzunehmen, und erneut, um dieselbe Aufnahme zu pausieren und fortzusetzen. Es nimmt immer mit der höchsten Auflösung deiner Kamera auf, mit einer Live-Mikrofonanzeige, sodass du deine Pegel überprüfen kannst, bevor du startest.

Stoppe die Aufnahme, und sie öffnet sich sofort in einem integrierten Editor. Doppelklicke auf einen Clip, um ihn zu teilen, ziehe an den Griffen, um jedes Stück zu trimmen, und entferne die Teile, die du nicht willst. Speichere es dann als MP4. Deine Originalaufnahme bleibt erhalten, bis du sie verwirfst, sodass du jederzeit zurückkommen und sie anders schneiden kannst.

Du startest Monologue über den App-Launcher (`Super + Space`).
