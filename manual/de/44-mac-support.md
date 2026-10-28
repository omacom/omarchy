# Mac-Unterstützung

Omarchy unterstützt **Intel-Macs** von Haus aus. Im Moment gibt es ein paar bekannte Einschränkungen, aber solange du sie kennst und damit einverstanden bist, kannst du deinen alten Macs mit Omarchy neues Leben einhauchen.

Bitte beachte, dass die Installation auf einem Mac der M-Serie derzeit nicht direkt unterstützt wird. Mehr über den Stand der Dinge findest du unter #omarchy-on-other in unserem [Discord](https://discord.gg/tXFUdasqhY).

In einem einfachen Test konnten wir auf einem MacBook Pro von 2019 allein durch die Installation von Omarchy 36 % mehr Leistung erzielen.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy auf dem Mac installieren

Omarchy unterstützt derzeit nur, das **einzige** installierte Betriebssystem zu sein. Während der Installation wird das Laufwerk gelöscht und MacOS ist danach nicht mehr bootfähig.

Du kannst es später über die Internet-Wiederherstellung wiederherstellen, wenn du möchtest.

Für diesen Abschnitt gehen wir davon aus, dass du [Erste Schritte](02-getting-started.md) bereits gelesen hast und dein USB-Stick bereit ist. Falls nicht, hole das jetzt nach.

#### Sicheren Systemstart deaktivieren

Es ist nötig, Apples sicheren Systemstart zu deaktivieren, um den bootfähigen USB-Stick und das Betriebssystem zu starten. Gehe dazu wie folgt vor:

1. Schalte deinen Mac aus
2. Schalte ihn ein und halte _sofort_ Command-R gedrückt, bis der Ladebildschirm erscheint
3. Wähle deinen Benutzer und gib dein Passwort ein, wenn du dazu aufgefordert wirst
4. Wähle im Wiederherstellungsbildschirm in der Menüleiste **Utilities > Startup Security Utility**
5. Gib dein Passwort ein, wenn du zur Authentifizierung aufgefordert wirst
6. Wähle „No Security“ aus den Optionen für den sicheren Systemstart
7. Wähle „Allow booting from external or removable media“ aus den Optionen für externen Start

#### Die Installation starten

1. Stecke den USB-Stick ein
2. Starte deinen Mac neu und halte _sofort_ Option gedrückt, bis ein Bildschirm mit Boot-Geräten erscheint
3. Wähle das orange Gerät EFI Boot
4. Fahre fort mit der [normalen Installation](02-getting-started.md)

Der Installer erkennt Mac-Hardware und wendet die nötigen Korrekturen automatisch an: Broadcom-WLAN-Treiber und -Firmware, den SPI-Tastaturtreiber auf den MacBook-Modellen, die ihn brauchen, und eine NVMe-Suspend-Korrektur für dieselben Modelle.

### Bekannte Einschränkungen

Mitglieder der Community arbeiten ständig an Lösungen für diese Herausforderungen. Wenn sie für dich problematisch sind, schau unter #omarchy-on-other in unserem [Discord](https://discord.gg/tXFUdasqhY) vorbei und sieh nach, ob es aktuelle Methoden gibt, sie zu lösen.

#### Geräte mit T1-Chip

Der Apple T1-Chip wurde Ende 2016 eingeführt und ausschließlich in den MacBook-Pro-Modellen der ersten Generation mit Touch Bar verwendet.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Bekannte Probleme

- Touch Bar funktioniert nicht
- Ton funktioniert nicht

#### Geräte mit T2-Chip

Der Apple T2 Security Chip wurde 2017 eingeführt. Der T2-Chip wurde mit dem Übergang zu Apple Silicon (Chips der M-Serie) ab 2020 eingestellt.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Auf diesen Modellen richtet der Installer automatisch den gepatchten `linux-t2`-Kernel, die T2-Audio-Konfiguration, Apples Broadcom-WLAN-/Bluetooth-Firmware und die Lüftersteuerung über `t2fanrd` ein. Die Touch Bar läuft mit der im Kernel eingebauten Unterstützung im Boot-Camp-Stil.
