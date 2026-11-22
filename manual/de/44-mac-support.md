# Mac-Unterstützung

## Omarchy für Apple Silicon

Omarchy für Apple Silicon ist eine offizielle Omacom-Lösung, die erstmals mit Omarchy 4.5 veröffentlicht wurde. Es wird neben macOS installiert, und du wählst beim Start deines Macs zwischen den beiden.

Hast du einen Hinweis zu Omarchy Mac erhalten? Gehe zu [Umstieg von Omarchy Mac](#coming-from-omarchy-mac).

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

Macs mit M4 und neuer werden noch nicht unterstützt. Die M4-Unterstützung wird im Edge-Channel getestet und kommt als Nächstes. Der Installer prüft deinen Mac, bevor er irgendetwas ändert.

Auf jedem Apple Silicon Mac, einschließlich M4 und neuer, kannst du Omarchy in einer virtuellen Maschine mit [Try Omarchy](https://github.com/omacom/try-omarchy) ausführen.

### Was du brauchst

- macOS 15 Sequoia oder neuer und ein Administratorkonto
- Freien Speicherplatz für Omarchy. Der Installer schlägt eine Größe vor und lässt dich diese ändern.
- Ein Backup deines Macs, Stromversorgung und eine Internetverbindung. Bei der Installation werden mehrere Gigabyte heruntergeladen.

### Installation

Du installierst von macOS aus. Installiere den Omarchy Installer mit [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Oder lade den neuesten Omarchy Installer von seiner [Releases-Seite](https://github.com/omacom/omarchy-mac-installer/releases) herunter und öffne ihn.

Der Installer prüft deinen Mac, zeigt dir den Plan und schafft Platz für Omarchy, indem er die macOS-Partition verkleinert. macOS bleibt auf der Festplatte und es ist kein USB-Laufwerk erforderlich. Wenn die erste Phase abgeschlossen ist, führt er dich durch den Abschluss der Einrichtung in macOS Recovery: Fahre herunter, halte die Einschalttaste gedrückt, bis "Loading startup options" erscheint, wähle Omarchy und folge den Schritten.

Beim ersten Start fragt Omarchy nach einem Passwort, das seine Festplatte verschlüsselt. Es gibt keinen Wiederherstellungsschlüssel: Wenn du das Passwort vergisst, können deine Omarchy-Dateien nicht wiederhergestellt werden.

Um später zwischen Omarchy und macOS zu wechseln, fahre herunter, halte dann die Einschalttaste gedrückt, bis die Startoptionen erscheinen, und wähle eines aus.

### Umstieg von Omarchy Mac

Omarchy Mac ist jetzt Teil von Omarchy für Apple Silicon, und jeder Mac, auf dem es lief, wird unterstützt. Deine aktuelle Installation läuft weiter, und ihre Systempakete werden weiterhin aktualisiert, aber sie erhält keine Omarchy-Updates mehr. Es gibt keine Frist und kein direktes Upgrade an Ort und Stelle: Du sicherst, entfernst die alte Installation, installierst frisch und stellst wieder her. Die Schritte 2 bis 5 finden in macOS statt, also öffne diese Seite auf deinem Telefon, bevor du neu startest.

1. **Sichere von Omarchy aus, außerhalb des Macs.** Das Entfernen der alten Installation löscht sie, und macOS kann die Omarchy-Festplatte nicht lesen. Kopiere deinen Home-Ordner auf ein externes Laufwerk oder einen anderen Computer, einschließlich SSH- und GPG-Schlüsseln, Browserprofilen und nicht gepushter Arbeit. Speichere deine Paketliste mit `pacman -Qqe > ~/packages.txt`. Sichere auch macOS, da sowohl das Entfernen als auch die Installation die Größe seiner Festplatte ändern.
2. **Starte deinen Mac in macOS.** Fahre herunter, halte die Einschalttaste gedrückt, bis die Startoptionen erscheinen, und wähle macOS.
3. **Installiere den Omarchy Installer** wie unter [Installation](#installing) gezeigt.
4. **Entferne die alte Installation.** Öffne den Omarchy Installer und wähle Installation > Remove Omarchy. Er zeigt, was er löschen wird, und gibt den Speicherplatz an macOS zurück. Wenn er deine Installation nicht erkennt, stoppt er, ohne die Festplatte zu ändern. Bitte in [Discord](https://discord.gg/tXFUdasqhY) um Hilfe, anstatt Partitionen von Hand zu löschen, was macOS löschen kann.
5. **Installiere Omarchy für Apple Silicon** mit dem Installer.
6. **Stelle deine Dateien wieder her.** Bringe deine Einstellungen Stück für Stück zurück, anstatt ganz `~/.config` über die neuen Standardeinstellungen zu kopieren, da alte Einstellungen diese überschreiben können.

### Gut zu wissen

- Bei M1- und M2-MacBooks weckst du das Gerät aus dem Ruhezustand auf, indem du den Deckel öffnest oder die Einschalttaste drückst.
- Fragen oder Probleme: Frage in unserem [Discord](https://discord.gg/tXFUdasqhY).

Die [README des Installers](https://github.com/omacom/omarchy-mac-installer#readme) behandelt Release-Channels, das Aktualisieren des Installers und das Entfernen von Omarchy.

## Intel-Macs

In einem einfachen Test konnten wir auf einem MacBook Pro von 2019 allein durch die Installation von Omarchy einen Leistungsgewinn von 36% erzielen.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy auf dem Mac installieren

Omarchy unterstützt derzeit nur, das **einzige** installierte OS zu sein. Während der Installation wird das Laufwerk gelöscht und macOS ist danach nicht mehr bootfähig.

Du kannst es später auf Wunsch immer noch über Internet Recovery wiederherstellen.

Für diesen Teil gehen wir davon aus, dass du [Erste Schritte](02-getting-started.md) bereits gelesen hast und dein USB-Laufwerk bereitliegt. Wenn nicht, hole das jetzt nach.

#### Secure Boot deaktivieren

Es ist notwendig, Apples Secure Boot zu deaktivieren, um vom bootfähigen USB-Laufwerk sowie das OS zu booten. Um ihn zu deaktivieren, gehe wie folgt vor:

1. Schalte deinen Mac aus
2. Schalte ihn ein und halte _sofort_ Command-R gedrückt, bis du den Ladebildschirm siehst
3. Wähle deinen Benutzer und gib dein Passwort ein, wenn du dazu aufgefordert wirst
4. Wähle im Wiederherstellungsbildschirm **Utilities > Startup Security Utility** aus der Menüleiste
5. Gib dein Passwort ein, wenn du zur Authentifizierung aufgefordert wirst
6. Wähle "No Security" aus den Secure Boot-Optionen
7. Wähle "Allow booting from external or removable media" aus den External Boot-Optionen

#### Installation starten

1. Stecke das USB-Laufwerk ein
2. Starte deinen Mac neu und halte _sofort_ Option gedrückt, bis du einen Bildschirm mit Boot-Geräten siehst
3. Wähle das orangefarbene EFI Boot-Gerät
4. Fahre mit der [Installation wie gewohnt](02-getting-started.md) fort

Der Installer erkennt Mac-Hardware und wendet die benötigten Fixes automatisch an: Broadcom Wi-Fi-Treiber und -Firmware, den SPI-Tastaturtreiber auf den MacBook-Modellen, die ihn benötigen, und einen NVMe-Suspend-Fix für dieselben Modelle.

### Bekannte Einschränkungen

Mitglieder der Community arbeiten ständig an Lösungen für diese Herausforderungen. Wenn diese für dich problematisch sind, tritt #omarchy-on-other in unserem [Discord](https://discord.gg/tXFUdasqhY) bei und sieh nach, ob es aktuelle Methoden zu ihrer Lösung gibt.

#### Geräte mit T1-Chip

Der Apple T1-Chip wurde Ende 2016 eingeführt und ausschließlich in den MacBook Pro-Modellen der ersten Generation mit Touch Bar verwendet.
- MacBook Pro 13-Zoll (2016, zwei Thunderbolt 3-Anschlüsse) – Modell: A1706
- MacBook Pro 13-Zoll (2016, vier Thunderbolt 3-Anschlüsse) – Modell: A1708
- MacBook Pro 15-Zoll (2016) – Modell: A1707

#### Bekannte Probleme

- Die Touch Bar ist nicht funktionsfähig
- Sound funktioniert nicht

#### Geräte mit T2-Chip

Der Apple T2 Security Chip wurde 2017 eingeführt. Der T2-Chip wurde mit dem Übergang zu Apple Silicon (Chips der M-Serie) ab 2020 eingestellt.

- iMac Pro (2017) – Modell: A1862
- MacBook Pro 13-Zoll (2018, vier Thunderbolt 3-Anschlüsse) – Modell: A1989
- MacBook Pro 15-Zoll (2018) – Modell: A1990
- MacBook Air (Retina, 13-Zoll, 2018) – Modell: A1932
- Mac mini (2018) – Modell: A1998
- MacBook Pro 13-Zoll (2019, zwei Thunderbolt 3-Anschlüsse) – Modell: A2159
- MacBook Pro 13-Zoll (2019, vier Thunderbolt 3-Anschlüsse) – Modell: A2178
- MacBook Pro 15-Zoll (2019) – Modell: A1990
- iMac (Retina 5K, 27-Zoll, 2020) – Modell: A2115 (iMac20,1 und iMac20,2)
- MacBook Pro 13-Zoll (2020, zwei Thunderbolt 3-Anschlüsse) – Modell: A2265
- MacBook Pro 15-Zoll (2020) – Modell: A1990

Auf diesen Modellen richtet der Installer automatisch den gepatchten `linux-t2`-Kernel, die T2-Audiokonfiguration, Apples Broadcom Wi-Fi/Bluetooth-Firmware und die Lüftersteuerung über `t2fanrd` ein. Die Touch Bar läuft mit der im Kernel integrierten, Boot Camp-artigen Unterstützung.

#### iMac Retina 5K (2017)

Der 27-Zoll-iMac von 2017 hat keinen T2-Chip, also richtet der Installer ihn wie die anderen Intel-Macs ein.

- iMac (Retina 5K, 27-Zoll, 2017) – Modell: A1419

#### Bekannte Probleme

- Das Display läuft nicht mit seiner nativen Auflösung von 5120×2880: Das Panel besteht aus zwei Kacheln, und der Standardtreiber leuchtet nur eine aus
- Sound funktioniert nicht
- Die Helligkeitssteuerung hat keine Wirkung
- Der Ruhezustand hängt die Maschine auf; nur ein Aus- und Wiedereinschalten stellt sie wieder her

Ein Community-Patcher für dieses Modell behebt Display, Sound und Helligkeit: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
