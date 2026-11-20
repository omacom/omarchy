# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) ist eine erfreuliche Alternative zu so etwas wie der GitHub Desktop-Anwendung, und es läuft im Terminal.

Du kannst es direkt ausführen, indem du in ein beliebiges von git verwaltetes Verzeichnis gehst und `lazygit` ausführst. Oder du kannst es innerhalb von Neovim ausführen, wo es mit `Space G G` gestartet werden kann.

Du springst mit `Tab` zwischen den verschiedenen Bereichen hin und her. Im Files-Bereich wählst du Dateien mit `Space` für das Staging aus, und dann kannst du mit `c` einen neuen Commit erstellen. Alle verfügbaren Befehle kannst du mit `?` sehen.

## Btop

[Btop](https://github.com/aristocratos/btop) ist ein schöner Ressourcenmanager, der Speicher-, CPU-, Festplatten- und Netzwerkauslastung zeigt. Er listet auch alle aktiven Prozesse auf und erlaubt dir, sie zu verwalten.

Omarchy nennt es Activity Monitor, und du startest es über den App-Launcher oder mit `Super + Shift + T`. Es öffnet sich als schwebendes Fenster, das du mit `Super + T` kacheln kannst.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) ist ein Terminal-Workspace-Manager, der dir Workspaces, Tabs und Bereiche gibt und sie alle in einer persistenten Sitzung weiterlaufen lässt, von der du dich trennen und zu der du später zurückkehren kannst.

Du startest ihn (oder kehrst zu deiner bestehenden Sitzung zurück) über den App-Launcher oder mit `Super + Ctrl + Return`. Omarchy liefert eine Herdr-Konfiguration aus, die seine Tmux-Konfiguration spiegelt, sodass die Präfix-Taste auch hier `Ctrl + Space` ist. Du kannst alle Tastaturkürzel mit `Super + Ctrl + K` durchsuchen.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zeigt Systeminformationen wie Kernel-Version, Uptime, Theme, CPU, Speicher und mehr. Es ist ein Nachfolger des beliebten neofetch-Tools.

Omarchy hat dies als _System > About_ im Omarchy-Menü (`Super + Space`) verpackt.

## Cliamp

[Cliamp](https://www.cliamp.stream/) ist ein Retro-Musikplayer für das Terminal, inspiriert von Winamp 2.x, komplett mit integrierten Radiosendern für Lo-Fi-Beats. Starte ihn mit `Super + Shift + Alt + M` oder über das Omarchy-Menü unter _Apps_. Drücke `?` für die vollständige Liste der Tastaturkürzel.

## Was ist mit Wi-Fi und Bluetooth?

Du wirst keine TUIs für Wi-Fi und Bluetooth finden — diese Aufgaben gehören zur Omarchy-Shell. Klicke auf das Wi-Fi-Symbol in der oberen Leiste (oder drücke `Super + Ctrl + N`), um Netzwerke zu sehen und dich zu verbinden, und klicke auf das Bluetooth-Symbol (oder drücke `Super + Ctrl + B`), um Geräte zu koppeln und zu verbinden. Siehe [Netzwerk](35-networking.md) für die ganze Geschichte.

## Eigene hinzufügen

Jedes Terminalprogramm kann die volle App-Behandlung bekommen. Gehe zu _Install > TUI_ im Omarchy-Menü (`Super + Space`), gib ihm einen Namen, einen Startbefehl, einen Fensterstil und ein Symbol, und es wird im App-Launcher wie jede andere Anwendung erscheinen. Du kannst es unter _Remove > TUI_ wieder entfernen.
