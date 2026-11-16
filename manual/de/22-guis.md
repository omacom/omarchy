# GUIs

## Dateien

Dateien (Nautilus) ist der grafische Dateimanager. `Super + Shift + F` öffnet ihn, und `Super + Shift + Alt + F` öffnet ihn in dem Verzeichnis, in dem sich dein Terminal gerade befindet, was dir eine Menge Klickerei erspart. Mit `Ctrl + L` kannst du einen Pfad eingeben, und wenn du bei einer beliebigen Datei `Space` drückst, erhältst du eine Schnellvorschau, ohne irgendetwas zu öffnen.

Steck einen USB-Stick oder eine SD-Karte ein und sie wird automatisch eingehängt, sodass sie einfach in der Seitenleiste auftaucht. Für alles Aufwendigere — ein Laufwerk formatieren, den SMART-Zustand prüfen, Partitionen erstellen — starte _Disks_ über den App-Launcher (`Super + Space`).

Doppelklicks folgen sinnvollen Standardeinstellungen: Bilder, Videos und Musik werden in Omaview geöffnet, PDFs in Document Viewer, Markdown in Omawrite und einfacher Text in dem Editor, der unter _Setup > Default > Editor_ ausgewählt ist.

## Disktree

Wenn das Laufwerk voll läuft und du keine Ahnung hast, was es auffrisst, starte [Disktree](https://github.com/tobi/disktree) über den App-Launcher (`Super + Space`). Es zeigt eine grafische Treemap deines Home-Verzeichnisses. Größere Blöcke belegen mehr Speicherplatz; bewege dich mit Tastatur oder Maus in Verzeichnisse hinein, markiere, was weg soll, und überprüfe deine Auswahl, bevor du irgendetwas entfernst. Führe `disktree --disk` aus, um die gesamte Festplatte zu scannen.

## Obsidian

[Obsidian](https://obsidian.md/) ist eine kostenlose und stark erweiterbare Notiz-App, die einfache Markdown-Dateien zur Speicherung verwendet.

Obsidian ist für alle Zwecke kostenlos, einschließlich privater, kommerzieller und gemeinnütziger Nutzung.

Obsidian bietet außerdem ein [kommerzielles Add-on zur Synchronisierung](https://obsidian.md/sync) mit mobilen Apps auf iOS und Android. (https://obsidian.md/pricing).

Du startest Obsidian mit `Super + Shift + O`. Um die Theme-Synchronisierung zu nutzen, musst du in den Einstellungen das `Omarchy`-Theme auswählen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ist Omarchys eigene, kinderleichte Markdown-Schreib-App. Keine Vaults, keine Plugins, nur du und die Worte.

Du startest Omawrite mit `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ist ein einfaches Bildbearbeitungsprogramm, das sich hervorragend zum Zuschneiden, Ändern der Größe und für andere grundlegende Bearbeitungen eignet. Erwarte nur keine Photoshop-Alternative. Aber es hat trotzdem einen Magic Wand und Ebenen!

Du startest Pinta über den App-Launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ist eine Theming-Anwendung, die Farben aus einem Hintergrundbild extrahieren und sie in ein vollständiges, stimmiges Theme verwandeln kann. Es ist der einfachste Weg, [dein eigenes Theme zu erstellen](43-making-your-own-theme.md).

Du startest Aether über den App-Launcher (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ermöglicht es dir, Dateien an andere Geräte im selben Netzwerk zu senden, auf denen die App läuft, ähnlich wie Apples AirDrop. Es ist jedoch plattformübergreifend, sodass du Dateien an und von Windows, macOS, Android, iOS und natürlich Linux senden kannst.

Du kannst das Share-Menü mit `Super + Ctrl + S` oder unter _Trigger > Share_ im Omarchy-Menü öffnen. Es bietet dir vier Optionen:

- **Clipboard** sendet alles, was du kopiert hast, als Textdatei. Großartig, um einen Link oder ein Snippet auf dein Telefon zu bekommen, ohne dir selbst eine E-Mail zu schicken.
- **File** öffnet eine Dateiauswahl, in der du mehrere auf einmal auswählen kannst.
- **Folder** sendet ein gesamtes Verzeichnis.
- **Receive** öffnet LocalSend selbst, sodass dir ein anderes Gerät etwas senden kann.

Das Gleiche funktioniert vom Terminal aus mit `omarchy share clipboard`, `omarchy share file [path]` und `omarchy share folder [path]`. Lass den Pfad weg und du erhältst die Auswahl.

Du kannst auch direkt aus dem Dateimanager senden: Klicke in Nautilus mit der rechten Maustaste auf eine beliebige Auswahl und wähle _Send via LocalSend_.

Omarchys Firewall ist standardmäßig geschlossen, mit Ausnahme des Ports von LocalSend, sodass dies bei einer frischen Installation sofort funktioniert. Siehe [Sicherheit](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ist ein vollständiges Office-Paket mit Textverarbeitung, Tabellenkalkulation, Präsentationen, Zeichenanwendung und mehr. Es ist kompatibel mit Dateien aus Microsoft Office, sodass dies eine großartige Möglichkeit ist, diese Word-Dokumente öffnen zu können.

Du startest LibreOffice über den App-Launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ist Omarchys eigene, kinderleichte Präsentations-App. Dein Deck ist eine einzige Markdown-Datei mit seinen Bildern und Videos daneben: Schreibe jede Folie unterhalb einer Live-Vorschau, ziehe die Folien in die richtige Reihenfolge und präsentiere dann im Vollbildmodus oder exportiere nach PDF und PowerPoint. Es übernimmt sogar dein Omarchy-Theme.

Du startest Hype über den App-Launcher (`Super + Space`). Drücke `?` darin, um jede Tastenkombination zu sehen.

## Signed

[Signed](https://github.com/omacom/signed) ist Omarchys eigene, kinderleichte Möglichkeit, PDFs zu unterschreiben und auszufüllen. Platziere deine gespeicherte Unterschrift, Text und das heutige Datum irgendwo auf einer Seite und speichere dann eine unterschriebene Kopie neben dem Original. Siehe [PDFs ausfüllen](27-filling-out-pdfs.md), wie das geht.

Du startest Signed über den App-Launcher (`Super + Space`) oder öffnest ein PDF aus dem Dateimanager damit.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) ist Omarchys eigenes 3D-Schachspiel. Spiele gegen einen Freund am selben Computer oder gegen den integrierten Gegner in drei Stufen, mit vier modellierten Sets, die sich jeweils auf ihre eigene Art bewegen: orbitale Raumfahrzeuge, geschnitztes Holz und Elfenbein, Waldtiere und Süßigkeiten. Partien haben keine Uhr und werden nach jedem Zug gespeichert.

Du startest Checkmate über den App-Launcher (`Super + Space`). Drücke `?` darin, um jede Tastenkombination zu sehen.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ist Omarchys eigener, kinderleichter Taschenrechner, der sich in einem schwebenden Fenster öffnet.

Du startest Omacalc mit `Super + Shift + Q` (oder mit der Taschenrechner-Taste, falls deine Tastatur eine hat).

## Signal

[Signal](https://signal.org/) ist der Pionier der E2E-verschlüsselten Nachrichtenübertragung und eine großartige Kommunikationsoption für alle, die lieber nicht über einen der großen Tech-Konzerne gehen möchten.

Du startest Signal mit `Super + Shift + G`. Es ist nicht Teil der Basisinstallation, sodass Omarchy dir beim ersten Mal, wenn du das drückst, anbieten wird, es für dich zu installieren (es befindet sich auch unter _Install > Service_ im Omarchy-Menü).

## Omaview

[Omaview](https://github.com/omacom/omaview) ist Omarchys eigener, kinderleichter Bildbetrachter und Mediaplayer: ein Fenster für deine Fotos, Videos und Musik. Öffne ein Foto und die Pfeiltasten blättern durch den Rest seines Ordners, `N` und `P` tun dies für alles, und `Ctrl + M` zeigt den gesamten Ordner als Raster. Es zeigt auch HEIC-, AVIF- und JPEG XL-Fotos und macht bei allem Längeren dort weiter, wo du aufgehört hast.

Drücke `F` für Vollbild, `E`, um ein Bild in Omasnap zu bearbeiten oder ein Video in Omacut zu trimmen, `Ctrl + P`, um ein Bild zu drucken, und `Delete`, um eine Datei in den Papierkorb zu verschieben (`Ctrl + Z` holt sie zurück). Drücke `?` darin, um jede Tastenkombination zu sehen.

Du startest Omaview als _Media Viewer_ über den App-Launcher (`Super + Space`) oder doppelklickst einfach auf ein Bild, ein Video oder einen Song im Dateimanager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ist Omarchys eigener, kinderleichter Video-Trimmer. Wenn du nur Anfang und Ende eines Clips abschneiden musst, ist das besser, als einen vollständigen Video-Editor zu starten.

Du startest Omacut über den App-Launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ist Omarchys eigener, kinderleichter Webcam-Rekorder. Wähle einmal deine Kamera und dein Mikrofon aus, drücke dann `Space`, um aufzunehmen, und erneut, um dieselbe Aufnahme zu pausieren und fortzusetzen. Er nimmt immer mit der höchsten Auflösung deiner Kamera auf, mit einer Live-Mikrofonanzeige, sodass du deine Pegel überprüfen kannst, bevor du startest.

Stoppe die Aufnahme und sie öffnet sich sofort in einem integrierten Editor. Doppelklicke auf einen Clip, um ihn zu teilen, ziehe die Griffe, um jedes Stück zu trimmen, und entferne die Teile, die du nicht möchtest. Speichere ihn dann als MP4. Deine Originalaufnahme bleibt erhalten, bis du sie verwirfst, sodass du jederzeit zurückkommen und sie anders schneiden kannst.

Du startest Monologue über den App-Launcher (`Super + Space`).
