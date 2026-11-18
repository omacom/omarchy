# Mac-Unterstützung

Omarchy hat integrierte Unterstützung für **Intel Macs**. Es gibt im Moment ein paar bekannte Einschränkungen, aber solange du dir dessen bewusst bist und damit einverstanden bist, kannst du deinen alten Macs neues Leben einhauchen, indem du Omarchy darauf lädst.

Bitte beachte, dass eine Installation auf einem Mac der M-Serie derzeit nicht direkt unterstützt wird. Mehr über den aktuellen Stand dazu erfährst du in #omarchy-on-other in unserem [Discord](https://discord.gg/tXFUdasqhY).

In einem einfachen Test konnten wir allein durch die Installation von Omarchy eine Leistungssteigerung von 36 % auf einem 2019 MacBook Pro erzielen.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy auf dem Mac installieren

Omarchy unterstützt derzeit nur, das **einzige** installierte OS zu sein. Während der Installation wird das Laufwerk gelöscht und MacOS wird nicht mehr bootfähig sein.

Du kannst es später bei Bedarf weiterhin über Internet Recovery wiederherstellen.

Für diesen Teil gehen wir davon aus, dass du [Erste Schritte](02-getting-started.md) bereits gelesen hast und dein USB-Laufwerk bereit ist. Falls nicht, hole das jetzt nach.

#### Secure Boot deaktivieren

Es ist notwendig, Apples Secure Boot zu deaktivieren, um sowohl vom bootfähigen USB-Stick als auch das OS zu booten. Um es zu deaktivieren, gehe wie folgt vor:

1. Schalte deinen Mac aus
2. Schalte ihn ein und halte _sofort_ Command-R gedrückt, bis du den Ladebildschirm siehst
3. Wähle deinen Benutzer aus und gib dein Passwort ein, wenn du dazu aufgefordert wirst
4. Wähle im Wiederherstellungsbildschirm in der Menüleiste **Dienstprogramme > Startsicherheitsdienstprogramm**
5. Gib dein Passwort ein, wenn du zur Authentifizierung aufgefordert wirst
6. Wähle "Keine Sicherheit" aus den Secure Boot-Optionen
7. Wähle "Starten von externen oder Wechselmedien erlauben" aus den Optionen für externes Starten

#### Die Installation starten

1. Stecke das USB-Laufwerk ein
2. Starte deinen Mac neu und halte _sofort_ Option gedrückt, bis du einen Bildschirm mit Startgeräten siehst
3. Wähle das orangefarbene EFI Boot-Gerät aus
4. Fahre mit der [Installation wie üblich](02-getting-started.md) fort

Das Installationsprogramm erkennt Mac-Hardware und wendet automatisch die benötigten Korrekturen an: Broadcom Wi-Fi-Treiber und -Firmware, den SPI-Tastaturtreiber auf den MacBook-Modellen, die ihn benötigen, und eine NVMe-Suspend-Korrektur für dieselben Modelle.

### Bekannte Einschränkungen

Mitglieder der Community arbeiten ständig an Lösungen für diese Herausforderungen. Wenn diese für dich problematisch sind, komm deshalb in #omarchy-on-other in unserem [Discord](https://discord.gg/tXFUdasqhY) und sieh nach, ob es aktuelle Methoden zu ihrer Behebung gibt.

#### Geräte mit T1-Chip

Der Apple T1-Chip wurde Ende 2016 eingeführt und ausschließlich in den MacBook Pro-Modellen der ersten Generation mit Touch Bar verwendet.
- MacBook Pro 13-Zoll (2016, zwei Thunderbolt 3-Ports) – Modell: A1706
- MacBook Pro 13-Zoll (2016, vier Thunderbolt 3-Ports) – Modell: A1708
- MacBook Pro 15-Zoll (2016) – Modell: A1707

#### Bekannte Probleme

- Touch Bar ist nicht funktionsfähig
- Ton funktioniert nicht

#### Geräte mit T2-Chip

Der Apple T2 Security Chip wurde 2017 eingeführt. Der T2-Chip wurde mit dem Umstieg auf Apple Silicon (Chips der M-Serie) ab 2020 eingestellt.

- iMac Pro (2017) – Modell: A1862
- MacBook Pro 13-Zoll (2018, vier Thunderbolt 3-Ports) – Modell: A1989
- MacBook Pro 15-Zoll (2018) – Modell: A1990
- MacBook Air (Retina, 13-Zoll, 2018) – Modell: A1932
- Mac mini (2018) – Modell: A1998
- MacBook Pro 13-Zoll (2019, zwei Thunderbolt 3-Ports) – Modell: A2159
- MacBook Pro 13-Zoll (2019, vier Thunderbolt 3-Ports) – Modell: A2178
- MacBook Pro 15-Zoll (2019) – Modell: A1990
- iMac (Retina 5K, 27-Zoll, 2020) – Modell: A2115 (iMac20,1 und iMac20,2)
- MacBook Pro 13-Zoll (2020, zwei Thunderbolt 3-Ports) – Modell: A2265
- MacBook Pro 15-Zoll (2020) – Modell: A1990

Auf diesen Modellen richtet das Installationsprogramm automatisch den gepatchten `linux-t2`-Kernel, die T2-Audiokonfiguration, Apples Broadcom Wi-Fi/Bluetooth-Firmware und die Lüftersteuerung über `t2fanrd` ein. Die Touch Bar läuft mit der im Kernel integrierten Unterstützung im Boot Camp-Stil.

#### iMac Retina 5K (2017)

Der 27-Zoll-iMac von 2017 hat keinen T2-Chip, daher richtet das Installationsprogramm ihn wie die anderen Intel Macs ein.

- iMac (Retina 5K, 27-Zoll, 2017) – Modell: A1419

#### Bekannte Probleme

- Das Display läuft nicht mit seiner nativen Auflösung von 5120×2880: Das Panel besteht aus zwei Kacheln, und der Standardtreiber aktiviert nur eine
- Ton funktioniert nicht
- Die Helligkeitssteuerung hat keine Wirkung
- Der Ruhezustand hängt die Maschine auf; nur ein Aus- und Wiedereinschalten stellt sie wieder her

Ein Community-Patcher für dieses Modell behebt Display, Ton und Helligkeit: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
