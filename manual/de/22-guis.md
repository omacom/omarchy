# GUIs

## Dateien

Dateien (Folio) ist der grafische Dateimanager. `Super + Shift + F` öffnet ihn, und `Super + Shift + Alt + F` öffnet ihn in dem Verzeichnis, in dem sich dein Terminal gerade befindet, was dir eine Menge Klicks erspart. Mit `Ctrl + L` kannst du einen Pfad eingeben, und ein Druck auf `Space` bei einer beliebigen Datei zeigt eine Vorschau in voller Größe, ohne sie zu öffnen.

Steck einen USB-Stick oder eine SD-Karte ein und sie wird automatisch eingehängt, sodass sie einfach in der Seitenleiste auftaucht. Für alles Aufwendigere — ein Laufwerk formatieren, den SMART-Zustand prüfen, Partitionen erstellen — starte _Disks_ über den Anwendungsstarter (`Super + Space`).

Doppelklicken folgt vernünftigen Voreinstellungen: Bilder, Videos und Musik öffnen sich in Omaview, PDFs in Document Viewer, Markdown in Omawrite und reiner Text in dem Editor, der unter _Setup > Default > Editor_ ausgewählt ist.

## Disktree

Wenn das Laufwerk voll läuft und du keine Ahnung hast, was es auffrisst, starte [Disktree](https://github.com/tobi/disktree) über den Anwendungsstarter (`Super + Space`). Es zeigt eine grafische Treemap deines Home-Verzeichnisses. Größere Blöcke belegen mehr Platz; bewege dich mit Tastatur oder Maus in Verzeichnisse hinein, markiere, was weg soll, und prüfe deine Auswahl, bevor du irgendetwas entfernst. Führe `disktree --disk` aus, um die ganze Festplatte zu scannen.

## Obsidian

[Obsidian](https://obsidian.md/) ist eine kostenlose und hochgradig erweiterbare Notiz-Anwendung, die einfache Markdown-Dateien zur Speicherung verwendet.

Obsidian ist für alle Zwecke kostenlos, einschließlich persönlicher, kommerzieller und gemeinnütziger Nutzung.

Obsidian bietet außerdem ein [kommerzielles Add-on zum Synchronisieren](https://obsidian.md/sync) mit mobilen Apps auf iOS und Android. (https://obsidian.md/pricing).

Du startest Obsidian mit `Super + Shift + O`. Um die Theme-Synchronisierung zu nutzen, musst du in den Einstellungen das Theme `Omarchy` auswählen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ist Omarchys eigene supereinfache Markdown-Schreib-App. Keine Vaults, keine Plugins, nur du und die Worte.

Du startest Omawrite mit `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ist ein einfaches Bildbearbeitungswerkzeug, das sich hervorragend zum Zuschneiden, Skalieren und für andere grundlegende Bearbeitungen eignet. Erwarte bloß keine Photoshop-Alternative. Aber es hat trotzdem einen Zauberstab und Ebenen!

Du startest Pinta über den Anwendungsstarter (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ist eine Theming-Anwendung, die Farben aus einem Hintergrundbild extrahieren und daraus ein vollständiges, stimmiges Theme machen kann. Es ist der einfachste Weg, [dein eigenes Theme zu erstellen](43-making-your-own-theme.md).

Du startest Aether über den Anwendungsstarter (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) lässt dich Dateien an andere Geräte im selben Netzwerk senden, auf denen die App läuft, wie Apples AirDrop. Sie ist allerdings plattformübergreifend, sodass du Dateien von und nach Windows, macOS, Android, iOS und natürlich Linux senden kannst.

Du kannst das Share-Menü mit `Super + Ctrl + S` oder unter _Trigger > Share_ im Omarchy-Menü öffnen. Es bietet dir vier Optionen:

- **Clipboard** sendet alles, was du kopiert hast, als Textdatei. Großartig, um einen Link oder ein Snippet auf dein Handy zu bekommen, ohne dir selbst eine E-Mail zu schicken.
- **File** öffnet eine Dateiauswahl, in der du mehrere auf einmal auswählen kannst.
- **Folder** sendet ein ganzes Verzeichnis.
- **Receive** öffnet LocalSend selbst, damit ein anderes Gerät dir etwas senden kann.

Dasselbe funktioniert vom Terminal aus mit `omarchy share clipboard`, `omarchy share file [path]` und `omarchy share folder [path]`. Lässt du den Pfad weg, bekommst du die Auswahl.

Du kannst auch direkt aus dem Dateimanager senden: Klicke mit der rechten Maustaste auf eine beliebige Auswahl in Dateien und teile sie mit LocalSend.

Omarchys Firewall ist standardmäßig geschlossen, außer für den Port von LocalSend, sodass dies auf einer frischen Installation sofort funktioniert. Siehe [Sicherheit](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ist ein vollständiges Office-Paket mit Textverarbeitung, Tabellenkalkulation, Präsentationen, Zeichenanwendung und mehr. Es ist mit Dateien aus Microsoft Office kompatibel, sodass dies eine großartige Möglichkeit ist, diese Word-Dokumente öffnen zu können.

Du startest LibreOffice über den Anwendungsstarter (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ist Omarchys eigene supereinfache Präsentations-App. Dein Deck ist eine einzelne Markdown-Datei mit ihren Bildern und Videos daneben: Schreibe jede Folie unter einer Live-Vorschau, ziehe Folien in die richtige Reihenfolge, präsentiere dann im Vollbild oder exportiere nach PDF und PowerPoint. Es übernimmt sogar dein Omarchy-Theme.

Du startest Hype über den Anwendungsstarter (`Super + Space`). Drücke `?` darin, um alle Tastaturkürzel zu sehen.

## Signed

[Signed](https://github.com/omacom/signed) ist Omarchys eigene supereinfache Möglichkeit, PDFs zu signieren und auszufüllen. Platziere deine gespeicherte Unterschrift, Text und das heutige Datum irgendwo auf einer Seite und speichere dann eine signierte Kopie neben dem Original. Siehe [PDFs ausfüllen](27-filling-out-pdfs.md), wie das geht.

Du startest Signed über den Anwendungsstarter (`Super + Space`), oder öffne ein PDF damit aus dem Dateimanager.

## Game Vibes

Game Vibes, im Anwendungsstarter (`Super + Space`), ist der Ort, an dem Omarchys kleine Spiele leben: Checkmate, ein 3D-Schachspiel gegen einen Freund oder den eingebauten Gegner; Cards, Klondike-Solitaire; und Neon Swarm, ein Arcade-Shooter. Jedes ist eine einzelne Webseite, die deinem Theme folgt. Wähle eines mit den Pfeilen und `Enter` aus und kehre mit `Esc` vom Titelbildschirm eines Spiels oder mit `Q`, während es pausiert ist, zur Liste zurück. Es öffnet sich im Vollbild: `Super + F` macht es zu einem Fenster, und `Super + W` schließt es.

Die Spiele, die du mit einem Agenten erstellst, tauchen hier auch auf: Wähle _Make something cool → Game_ im Agenten-Panel und beschreibe eines, oder nenne ein Spiel, das bereits in Game Vibes ist, um weiter daran zu arbeiten. Der Agent kopiert es nach `~/Games/vibes`, wo es dir gehört und du es ändern kannst, und öffnet es, wenn er fertig ist. Du kannst diese Kopie selbst mit `omarchy games vibes copy <game>` erstellen. Ein Spiel, das jemand anderes teilt, wird wie ein Theme installiert: Wähle _Install > Gaming > Game Vibes_ und füge seine Git-Adresse ein, oder führe `omarchy games vibes install <git-repo-url>` aus. _Remove > Gaming_ entfernt eines wieder, und _Update > Game Vibes Games_ holt neue Versionen. Spiele laden three.js aus dem Web, also brauchen sie eine Verbindung, um zu starten.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ist Omarchys eigener supereinfacher Taschenrechner, der sich in einem schwebenden Fenster öffnet.

Du startest Omacalc mit `Super + Shift + Q` (oder der Taschenrechner-Taste, falls deine Tastatur eine hat).

## Signal

[Signal](https://signal.org/) ist der Pionier der E2E-verschlüsselten Nachrichtenübermittlung und eine großartige Kommunikationsoption für alle, die lieber nicht über einen der großen Tech-Konzerne gehen möchten.

Du startest Signal mit `Super + Shift + G`. Es ist nicht Teil der Basisinstallation, also wird Omarchy dir beim ersten Mal, wenn du das drückst, anbieten, es für dich zu installieren (es steht auch unter _Install > Service_ im Omarchy-Menü).

## Omaview

[Omaview](https://github.com/omacom/omaview) ist Omarchys eigener supereinfacher Bildbetrachter und Medienplayer: ein Fenster für deine Fotos, Videos und Musik. Öffne ein Foto und die Pfeiltasten blättern durch den Rest seines Ordners, `N` und `P` tun das für alles, und `Ctrl + M` zeigt den ganzen Ordner als Raster. Es zeigt auch HEIC-, AVIF- und JPEG XL-Fotos und setzt bei längeren Inhalten dort fort, wo du aufgehört hast.

Drücke `F` für Vollbild, `E`, um ein Bild in Omasnap zu bearbeiten oder ein Video in Omacut zu trimmen, `Ctrl + P`, um ein Bild zu drucken, und `Delete`, um eine Datei in den Papierkorb zu verschieben (`Ctrl + Z` holt sie zurück). Drücke `?` darin, um alle Tastaturkürzel zu sehen.

Du startest Omaview als _Media Viewer_ über den Anwendungsstarter (`Super + Space`), oder doppelklicke einfach auf ein Bild, ein Video oder einen Song im Dateimanager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ist Omarchys eigener supereinfacher Video-Trimmer. Wenn du nur Anfang und Ende eines Clips abschneiden musst, schlägt das, einen vollständigen Video-Editor zu starten.

Du startest Omacut über den Anwendungsstarter (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ist Omarchys eigener supereinfacher Webcam-Rekorder. Wähle deine Kamera und dein Mikrofon einmal aus, drücke dann `Space`, um aufzunehmen, und erneut, um dieselbe Aufnahme zu pausieren und fortzusetzen. Es nimmt immer mit der höchsten Auflösung deiner Kamera auf, mit einer Live-Mikrofonanzeige, sodass du deine Pegel prüfen kannst, bevor du startest.

Beende die Aufnahme und sie öffnet sich sofort in einem eingebauten Editor. Doppelklicke auf einen Clip, um ihn zu teilen, ziehe an den Griffen, um jedes Stück zu trimmen, und entferne die Teile, die du nicht willst. Speichere ihn dann als MP4. Deine Originalaufnahme bleibt erhalten, bis du sie verwirfst, sodass du jederzeit zurückkommen und sie anders schneiden kannst.

Du startest Monologue über den Anwendungsstarter (`Super + Space`).
