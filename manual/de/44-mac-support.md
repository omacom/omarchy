# Mac-Unterstützung

## Omarchy für Apple Silicon

Omarchy für Apple Silicon ist eine offizielle Omacom-Lösung, die erstmals mit Omarchy 4.5 veröffentlicht wurde. Es installiert sich neben macOS, und du wählst beim Start deines Mac zwischen den beiden.

Hast du einen Hinweis zu Omarchy Mac erhalten? Gehe zu [Von Omarchy Mac kommend](#coming-from-omarchy-mac).

Es läuft auf diesen Macs:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Macs mit M4 und neuer werden noch nicht unterstützt. Die Unterstützung für M4 wird auf dem Edge-Channel getestet und kommt als Nächstes. Das Installationsprogramm prüft deinen Mac, bevor es irgendetwas ändert.

Auf jedem Apple-Silicon-Mac, einschließlich M4 und neuer, kannst du Omarchy mit [Try Omarchy](https://github.com/omacom/try-omarchy) in einer virtuellen Maschine ausführen.

### Was du brauchst

- macOS 15 Sequoia oder neuer und ein Administratorkonto
- Freien Speicherplatz für Omarchy. Das Installationsprogramm schlägt eine Größe vor und lässt dich diese ändern.
- Ein Backup deines Mac, Stromversorgung und eine Internetverbindung. Bei der Installation werden mehrere Gigabyte heruntergeladen.

### Installation

Du installierst von macOS aus. Installiere den Omarchy Installer mit [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Oder lade den neuesten Omarchy Installer von seiner [Releases-Seite](https://github.com/omacom/omarchy-mac-installer/releases) herunter und öffne ihn.

Das Installationsprogramm prüft deinen Mac, zeigt dir den Plan und schafft Platz für Omarchy, indem es die macOS-Partition verkleinert. macOS bleibt auf der Festplatte, und es wird kein USB-Laufwerk benötigt. Wenn die erste Phase abgeschlossen ist, führt es dich durch den Abschluss der Einrichtung in macOS Recovery: Fahre den Mac herunter, halte die Einschalttaste gedrückt, bis "Loading startup options" erscheint, wähle Omarchy und folge den Schritten.

Beim ersten Start fragt Omarchy nach einem Passwort, mit dem seine Festplatte verschlüsselt wird. Es gibt keinen Wiederherstellungsschlüssel: Wenn du das Passwort vergisst, können deine Omarchy-Dateien nicht wiederhergestellt werden.

Um später zwischen Omarchy und macOS zu wechseln, fahre den Mac herunter, halte dann die Einschalttaste gedrückt, bis die Startoptionen erscheinen, und wähle eines der beiden aus.

### Von Omarchy Mac kommend

Omarchy Mac ist jetzt Teil von Omarchy für Apple Silicon, und jeder Mac, auf dem es lief, wird unterstützt. Deine aktuelle Installation läuft weiter, und ihre Systempakete werden weiterhin aktualisiert, aber sie erhält keine Omarchy-Updates mehr. Es gibt keine Frist und kein direktes Upgrade: Du erstellst ein Backup, entfernst die alte Installation, installierst frisch und stellst deine Daten wieder her. Die Schritte 2 bis 5 finden in macOS statt, also öffne diese Seite auf deinem Telefon, bevor du neu startest.

1. **Erstelle ein Backup aus Omarchy, außerhalb des Mac.** Das Entfernen der alten Installation löscht diese, und macOS kann die Omarchy-Festplatte nicht lesen. Kopiere deinen Home-Ordner auf ein externes Laufwerk oder einen anderen Computer, einschließlich SSH- und GPG-Schlüssel, Browserprofile und nicht gepushter Arbeit. Speichere deine Paketliste mit `pacman -Qqe > ~/packages.txt`. Erstelle auch ein Backup von macOS, da sowohl das Entfernen als auch das Installieren seine Festplatte in der Größe verändern.
2. **Starte deinen Mac in macOS.** Fahre den Mac herunter, halte die Einschalttaste gedrückt, bis die Startoptionen erscheinen, und wähle macOS.
3. **Installiere den Omarchy Installer** wie unter [Installation](#installing) gezeigt.
4. **Entferne die alte Installation.** Öffne den Omarchy Installer und wähle Installation > Remove Omarchy. Er zeigt dir, was er löschen wird, und gibt den Speicherplatz an macOS zurück. Wenn er deine Installation nicht erkennt, hält er an, ohne die Festplatte zu verändern. Bitte in [Discord](https://discord.gg/tXFUdasqhY) um Hilfe, anstatt Partitionen von Hand zu löschen, was macOS löschen kann.
5. **Installiere Omarchy für Apple Silicon** mit dem Installationsprogramm.
6. **Stelle deine Dateien wieder her.** Übernimm deine Einstellungen Stück für Stück zurück, anstatt das gesamte `~/.config` über die neuen Standardeinstellungen zu kopieren, da alte Einstellungen diese überschreiben können.

### Gut zu wissen

- Wecke M1- und M2-MacBooks aus dem Ruhezustand auf, indem du den Deckel öffnest oder die Einschalttaste drückst.
- Fragen oder Probleme: Frage in unserem [Discord](https://discord.gg/tXFUdasqhY).

Die [README des Installationsprogramms](https://github.com/omacom/omarchy-mac-installer#readme) behandelt Release-Channels, das Aktualisieren des Installationsprogramms und das Entfernen von Omarchy.

## Intel-Macs

In einem einfachen Test konnten wir allein durch die Installation von Omarchy auf einem MacBook Pro von 2019 Leistungsgewinne von 36% erzielen.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy auf dem Mac installieren

Omarchy unterstützt derzeit nur, das **einzige** installierte OS zu sein. Während der Installation wird das Laufwerk gelöscht, und MacOS ist danach nicht mehr bootfähig.

Du kannst es später bei Bedarf immer noch über Internet Recovery wiederherstellen.

Für diesen Abschnitt gehen wir davon aus, dass du [Erste Schritte](02-getting-started.md) bereits gelesen hast und dein USB-Laufwerk bereitliegt. Wenn nicht, hole das jetzt nach.

#### Secure Boot deaktivieren

Es ist notwendig, Apples Secure Boot zu deaktivieren, um den bootfähigen USB-Stick und auch das OS zu booten. Um es zu deaktivieren, gehe wie folgt vor:

1. Schalte deinen Mac aus
2. Schalte ihn ein und halte _sofort_ Command-R gedrückt, bis der Ladebildschirm erscheint
3. Wähle deinen Benutzer aus und gib dein Passwort ein, wenn du dazu aufgefordert wirst
4. Wähle im Wiederherstellungsbildschirm **Utilities > Startup Security Utility** aus der Menüleiste
5. Gib dein Passwort ein, wenn du zur Authentifizierung aufgefordert wirst
6. Wähle "No Security" aus den Secure-Boot-Optionen
7. Wähle "Allow booting from external or removable media" aus den External-Boot-Optionen

#### Installation starten

1. Stecke das USB-Laufwerk ein
2. Starte deinen Mac neu und halte _sofort_ Option gedrückt, bis ein Bildschirm mit Startgeräten erscheint
3. Wähle das orangefarbene EFI Boot-Gerät aus
4. Fahre mit der [Installation wie gewohnt](02-getting-started.md) fort

Das Installationsprogramm erkennt Mac-Hardware und wendet die benötigten Korrekturen automatisch an: Broadcom-Wi-Fi-Treiber und -Firmware, den FaceTime-HD-Kameratreiber auf Geräten mit einem Broadcom 1570 (seine Firmware wird von Apple heruntergeladen, sobald der Mac online ist, da das Installationsprogramm offline arbeitet), den SPI-Tastaturtreiber auf den MacBook-Modellen, die ihn benötigen, und einen NVMe-Suspend-Fix für dieselben Modelle.

### Bekannte Einschränkungen

Mitglieder der Community arbeiten ständig an Lösungen für diese Herausforderungen. Wenn diese für dich problematisch sind, tritt also #omarchy-on-other in unserem [Discord](https://discord.gg/tXFUdasqhY) bei und schau nach, ob es aktuelle Methoden zu ihrer Lösung gibt.

#### FaceTime HD-Kamera

Der Kameratreiber hängt das Gerät auf, wenn er geladen ist, während der Mac in den Ruhezustand geht, also wird er vorher entladen. Er kann nicht entladen werden, solange eine App die Kamera geöffnet hat, also wird der Ruhezustand mit einer Benachrichtigung abgebrochen, die die App benennt: Schließe sie und versetze das Gerät erneut in den Ruhezustand. Das umfasst auch das automatische Versetzen in den Ruhezustand bei kritischem Akkustand sowie Suspend-then-Hibernate, das verweigert wird, bevor es suspendiert. Gewöhnliches Suspend wird vom Treiber selbst ohne Benachrichtigung verweigert, solange die Kamera geöffnet ist.

Die Firmware der Kamera wird von Apple heruntergeladen, also funktioniert die Kamera erst, wenn der Mac online war. Der Download startet beim Booten und wird alle 15 Minuten wiederholt, solange das Netzwerk das Problem ist; wenn sich Apples Datei geändert hat, stoppt er und wartet auf ein Omarchy-Update. Wenn die Kamera nicht erscheint, sagt `journalctl -u facetimehd-firmware-fetcher`, warum, `sudo systemctl restart facetimehd-firmware-fetcher` versucht es erneut, und ein Neustart lädt den Treiber, wenn der Download abgeschlossen ist, die Kamera aber immer noch nicht da ist.

#### Geräte mit T1-Chip

Der Apple T1-Chip wurde Ende 2016 eingeführt und ausschließlich in den MacBook-Pro-Modellen der ersten Generation mit Touch Bar verwendet.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Modell: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Modell: A1708
- MacBook Pro 15-inch (2016) – Modell: A1707

#### Bekannte Probleme

- Die Touch Bar funktioniert nicht
- Der Ton funktioniert nicht

#### Geräte mit T2-Chip

Der Apple T2 Security Chip wurde 2017 eingeführt. Der T2-Chip wurde mit dem ab 2020 erfolgten Umstieg auf Apple Silicon (Chips der M-Serie) eingestellt.

- iMac Pro (2017) – Modell: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Modell: A1989
- MacBook Pro 15-inch (2018) – Modell: A1990
- MacBook Air (Retina, 13-inch, 2018) – Modell: A1932
- Mac mini (2018) – Modell: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Modell: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Modell: A2178
- MacBook Pro 15-inch (2019) – Modell: A1990
- iMac (Retina 5K, 27-inch, 2020) – Modell: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Modell: A2265
- MacBook Pro 15-inch (2020) – Modell: A1990

Auf diesen Modellen richtet das Installationsprogramm automatisch den gepatchten `linux-t2`-Kernel, die T2-Audiokonfiguration, Apples Broadcom-Wi-Fi/Bluetooth-Firmware und die Lüftersteuerung über `t2fanrd` ein. Die Touch Bar läuft mit der im Kernel integrierten Unterstützung im Boot-Camp-Stil.

#### iMac Retina 5K (2017)

Der 27-inch iMac von 2017 hat keinen T2-Chip, also richtet ihn das Installationsprogramm wie die anderen Intel-Macs ein.

- iMac (Retina 5K, 27-inch, 2017) – Modell: A1419

#### Bekannte Probleme

- Das Display läuft nicht mit seiner nativen Auflösung von 5120×2880: Das Panel besteht aus zwei Kacheln, und der Standardtreiber aktiviert nur eine davon
- Der Ton funktioniert nicht
- Die Helligkeitssteuerung hat keine Wirkung
- Der Ruhezustand hängt das Gerät auf; nur Aus- und Wiedereinschalten stellt es wieder her

Ein Community-Patcher für dieses Modell behebt Display, Ton und Helligkeit: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
