# GUIs

## Files

Files (Folio) ist der grafische Dateimanager. `Super + Shift + F` öffnet ihn, und `Super + Shift + Alt + F` öffnet ihn in dem Verzeichnis, in dem dein Terminal gerade ist, was dir eine Menge Klicken erspart. Mit `Ctrl + L` kannst du einen Pfad eintippen, und wenn du bei einer beliebigen Datei `Space` drückst, siehst du sie in voller Größe als Vorschau, ohne sie zu öffnen.

Stecke einen USB-Stick oder eine SD-Karte ein, und sie wird automatisch eingehängt, sodass sie einfach in der Seitenleiste auftaucht. Für alles Aufwendigere — ein Laufwerk formatieren, den SMART-Zustand prüfen, Partitionen erstellen — starte _Disks_ über den App-Launcher (`Super + Space`).

Ein verschlüsseltes Laufwerk fragt beim Einstecken nach seinem Passwort. Damit sich eines von selbst entsperrt, füge ihm mit `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` eine Schlüsseldatei hinzu und lege diese Schlüsseldatei unter `~/.config/omarchy/drive-keys/<UUID>` ab, benannt nach der UUID, die `lsblk -dno UUID /dev/sdX1` für die verschlüsselte Partition ausgibt, und nur für dich lesbar (`chmod 600`). Fehlt diese Schlüsseldatei oder wird sie abgelehnt, wirst du wie üblich nach dem Passwort gefragt.

Doppelklicks folgen sinnvollen Standardeinstellungen: Bilder, Videos und Musik öffnen sich in Omaview, PDFs in Document Viewer, Markdown in Omawrite und reiner Text in deinem Editor, Plain, sofern du unter _Setup > Defaults > Editor_ keinen anderen auswählst.

## Disktree

Wenn das Laufwerk voll ist und du keine Ahnung hast, was es auffrisst, starte [Disktree](https://github.com/tobi/disktree) über den App-Launcher (`Super + Space`). Es zeigt eine grafische Treemap deines Home-Verzeichnisses. Größere Blöcke belegen mehr Platz; bewege dich mit Tastatur oder Maus in Verzeichnisse hinein, markiere, was weg soll, und überprüfe deine Auswahl, bevor du irgendetwas entfernst. Führe `disktree --disk` aus, um die gesamte Platte zu scannen.

## Obsidian

[Obsidian](https://obsidian.md/) ist eine kostenlose und stark erweiterbare Anwendung für Notizen, die zur Speicherung einfache Markdown-Dateien verwendet.

Obsidian ist für alle Zwecke kostenlos, auch für persönliche, kommerzielle und gemeinnützige Nutzung.

Obsidian bietet außerdem ein [kommerzielles Add-on für die Synchronisierung](https://obsidian.md/sync) mit mobilen Apps auf iOS und Android. (https://obsidian.md/pricing).

Du startest Obsidian mit `Super + Shift + O`. Um die Theme-Synchronisierung zu nutzen, musst du in den Einstellungen das `Omarchy`-Theme auswählen.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) ist Omarchys eigene, denkbar einfache Markdown-Schreib-App. Keine Vaults, keine Plugins, nur du und die Worte.

Du startest Omawrite mit `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) ist ein einfaches Bildbearbeitungswerkzeug, das sich hervorragend zum Zuschneiden, Ändern der Größe und für andere einfache Bearbeitungen eignet. Erwarte nur keinen Photoshop-Ersatz. Aber eine Magic Wand und Ebenen hat es trotzdem!

Du startest Pinta über den Application Launcher (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) ist eine Theming-Anwendung, die Farben aus einem Hintergrundbild extrahieren und sie in ein vollständiges, stimmiges Theme verwandeln kann. Das ist der einfachste Weg, um [dein eigenes Theme zu erstellen](43-making-your-own-theme.md).

Du startest Aether über den Application Launcher (`Super + Space`).

## LocalSend

Mit [LocalSend](https://localsend.org/) kannst du Dateien an andere Geräte im selben Netzwerk senden, auf denen die App läuft, ähnlich wie mit Apples AirDrop. Es ist allerdings plattformübergreifend, sodass du Dateien an Windows, macOS, Android, iOS und natürlich Linux senden und von dort empfangen kannst.

Das Share-Menü öffnest du mit `Super + Ctrl + S` oder über _Trigger > Share_ im Omarchy-Menü. Es bietet dir vier Optionen:

- **Clipboard** sendet alles, was du kopiert hast, als Textdatei. Ideal, um einen Link oder einen Ausschnitt auf dein Handy zu bekommen, ohne dir selbst eine E-Mail zu schicken.
- **File** öffnet eine Dateiauswahl, in der du mehrere Dateien auf einmal auswählen kannst.
- **Folder** sendet ein gesamtes Verzeichnis.
- **Receive** öffnet LocalSend selbst, damit ein anderes Gerät dir etwas senden kann.

Vom Terminal aus geht dasselbe mit `omarchy share clipboard`, `omarchy share file [path]` und `omarchy share folder [path]`. Lass den Pfad weg und du bekommst die Auswahl.

Du kannst auch direkt aus dem Dateimanager senden: Klicke in Files mit der rechten Maustaste auf eine beliebige Auswahl und teile sie mit LocalSend.

Omarchys Firewall ist standardmäßig geschlossen, außer für den Port von LocalSend, sodass dies bei einer frischen Installation sofort funktioniert. Siehe [Sicherheit](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) ist ein komplettes Office-Paket mit Textverarbeitung, Tabellenkalkulation, Präsentationen, Zeichenprogramm und mehr. Es ist mit Dateien aus Microsoft Office kompatibel, also eine hervorragende Möglichkeit, diese Word-Dokumente öffnen zu können.

Du startest LibreOffice über den Application Launcher (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) ist Omarchys eigene, denkbar einfache Präsentations-App. Deine Präsentation ist eine einzige Markdown-Datei, neben der ihre Bilder und Videos liegen: Schreibe jede Folie unter einer Live-Vorschau, ziehe die Folien in die richtige Reihenfolge und präsentiere dann im Vollbild oder exportiere nach PDF und PowerPoint. Sie übernimmt sogar dein Omarchy-Theme.

Du startest Hype über den Application Launcher (`Super + Space`). Drücke darin `?`, um jede Tastenkombination zu sehen.

## Signed

[Signed](https://github.com/omacom/signed) ist Omarchys eigene, denkbar einfache Möglichkeit, PDFs zu signieren und auszufüllen. Platziere deine gespeicherte Signatur, Text und das heutige Datum irgendwo auf einer Seite und speichere dann eine signierte Kopie neben dem Original. Wie das geht, steht unter [PDFs ausfüllen](27-filling-out-pdfs.md).

Du startest Signed über den Application Launcher (`Super + Space`) oder öffnest ein PDF aus dem Dateimanager damit.

## Game Vibes

Game Vibes im Application Launcher (`Super + Space`) ist der Ort, an dem Omarchys kleine Spiele leben: Checkmate, ein 3D-Schachspiel gegen einen Freund oder den eingebauten Gegner; Cards, Klondike-Solitär; Death Wish, ein pixelgenauer Platformer mit zehn Räumen voller Stacheln und Sägen; und Neon Swarm, ein Arcade-Shooter. Jedes ist eine einzige Webseite, die deinem Theme folgt. Wähle eines mit den Pfeiltasten und `Enter` aus und kehre mit `Esc` vom Titelbildschirm eines Spiels oder mit `Q`, während es pausiert ist, zur Liste zurück. Es öffnet sich im Vollbild: `Super + F` macht es zu einem Fenster, und `Super + W` schließt es.

Die Spiele, die du mit einem Agenten erstellst, tauchen hier auch auf: Wähle im Agenten-Panel _Make something cool → Game_ und beschreibe eines, oder nenne ein Spiel, das bereits in Game Vibes ist, um weiter daran zu arbeiten. Der Agent kopiert es nach `~/Games/vibes`, wo du es nach Belieben ändern kannst, und öffnet es, wenn er fertig ist. Diese Kopie kannst du selbst mit `omarchy games vibes copy <game>` erstellen. Ein Spiel, das jemand anderes teilt, lässt sich wie ein Theme installieren: Wähle _Install > Gaming > Game Vibes_ und füge seine Git-Adresse ein, oder führe `omarchy games vibes install <git-repo-url>` aus. _Remove > Gaming_ entfernt eines wieder, und _Update > Game Vibes Games_ holt neue Versionen. Spiele laden three.js aus dem Web, daher brauchen sie zum Starten eine Verbindung.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) ist Omarchys eigener, denkbar einfacher Taschenrechner, der sich in einem schwebenden Fenster öffnet.

Du startest Omacalc mit `Super + Shift + Q` (oder mit der Taschenrechnertaste, falls deine Tastatur eine hat).

## Signal

[Signal](https://signal.org/) ist der Pionier der E2E-verschlüsselten Nachrichtenübermittlung und eine großartige Kommunikationsmöglichkeit für alle, die lieber nicht über einen der großen Tech-Konzerne gehen möchten.

Du startest Signal mit `Super + Shift + G`. Es ist nicht Teil der Basisinstallation, daher bietet Omarchy dir beim ersten Drücken an, es für dich zu installieren (es steht auch unter _Install > Service_ im Omarchy-Menü).

## Omaview

[Omaview](https://github.com/omacom/omaview) ist Omarchys eigener, denkbar einfacher Bildbetrachter und Media Player: ein Fenster für deine Fotos, Videos und Musik. Öffne ein Foto und die Pfeiltasten blättern durch den Rest seines Ordners, `N` und `P` tun das für alles, und `Ctrl + M` zeigt den gesamten Ordner als Raster. Es zeigt auch HEIC-, AVIF- und JPEG XL-Fotos und macht bei allem Langen dort weiter, wo du aufgehört hast.

Drücke `F` für Vollbild, `E`, um ein Bild in Omasnap zu bearbeiten oder ein Video in Omacut zu zuschneiden, `Ctrl + P`, um ein Bild zu drucken, und `Delete`, um eine Datei in den Papierkorb zu verschieben (`Ctrl + Z` holt sie zurück). Drücke darin `?`, um jede Tastenkombination zu sehen.

Du startest Omaview als _Media Viewer_ über den Application Launcher (`Super + Space`) oder doppelklickst einfach im Dateimanager auf ein Bild, ein Video oder einen Song.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) ist Omarchys eigener, denkbar einfacher Video-Trimmer. Wenn du nur Anfang und Ende eines Clips abschneiden musst, ist das besser, als einen vollständigen Video-Editor zu starten.

Du startest Omacut über den Application Launcher (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) ist Omarchys eigener, denkbar einfacher Webcam-Recorder. Wähle einmal deine Kamera und dein Mikrofon aus, drücke dann `Space` zum Aufnehmen und noch einmal, um dieselbe Aufnahme zu pausieren und fortzusetzen. Er nimmt immer mit der höchsten Auflösung deiner Kamera auf, mit einer Live-Mikrofonanzeige, sodass du deine Pegel überprüfen kannst, bevor du startest.

Beende die Aufnahme, und sie öffnet sich sofort in einem eingebauten Editor. Doppelklicke auf einen Clip, um ihn zu teilen, ziehe an den Griffen, um jedes Stück zu trimmen, und entferne die Teile, die du nicht willst. Speichere ihn dann als MP4. Deine Originalaufnahme bleibt erhalten, bis du sie verwirfst, sodass du jederzeit zurückkommen und sie anders schneiden kannst.

Du startest Monologue über den Application Launcher (`Super + Space`).
