# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) ist eine herrliche Alternative zu etwas wie der GitHub Desktop-Anwendung, und es läuft im Terminal.

Du kannst es direkt ausführen, indem du in ein beliebiges von git verwaltetes Verzeichnis gehst und `lazygit` ausführst. Oder du führst es in Neovim aus, wo es mit `Space G G` gestartet werden kann.

Mit `Tab` springst du zwischen den verschiedenen Bereichen hin und her. Im Bereich Files wählst du Dateien mit `Space` für das Staging aus, und dann kannst du mit `c` einen neuen Commit erstellen. Mit `?` kannst du alle verfügbaren Befehle sehen.

## Btop

[Btop](https://github.com/aristocratos/btop) ist ein wunderschöner Ressourcenmanager, der Speicher-, CPU-, Festplatten- und Netzwerkauslastung anzeigt. Er listet auch alle aktiven Prozesse auf und ermöglicht dir, sie zu verwalten.

Omarchy nennt es Activity, und du startest es mit `Super + Shift + T`. Es öffnet sich als schwebendes Fenster, das du mit `Super + T` kacheln kannst.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) ist ein Terminal-Workspace-Manager, der dir Workspaces, Tabs und Bereiche gibt und sie alle in einer persistenten Session am Laufen hält, von der du dich trennen und zu der du später zurückkehren kannst.

Du startest es (oder verbindest dich erneut mit deiner bestehenden Session) mit `Super + Ctrl + Return`. Omarchy liefert eine Herdr-Konfiguration aus, die seine Tmux-Konfiguration widerspiegelt, also ist die Prefix-Taste auch hier `Ctrl + Space`. Du kannst alle Tastenkombinationen mit `Super + Ctrl + K` durchsuchen.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zeigt Systeminformationen wie Kernel-Version, Uptime, Theme, CPU, Speicher und mehr. Es ist ein Nachfolger des beliebten neofetch-Tools.

Omarchy hat dies als _About_ im Omarchy-Menü (`Super + Space`) verpackt.

## Cliamp

[Cliamp](https://www.cliamp.stream/) ist ein Retro-Terminal-Musikplayer, inspiriert von Winamp 2.x, komplett mit integrierten Radiosendern für Lo-Fi-Beats. Starte ihn mit `Super + Shift + Alt + M` oder aus dem Omarchy-Menü unter _Apps_. Drücke `?` für die vollständige Liste der Tastenkombinationen.

## Was ist mit Wi-Fi und Bluetooth?

Du wirst keine TUIs für Wi-Fi und Bluetooth finden — diese Aufgaben gehören zur Omarchy-Shell. Klicke auf das Wi-Fi-Symbol in der oberen Leiste (oder drücke `Super + Ctrl + N`), um Netzwerke zu sehen und dich zu verbinden, und klicke auf das Bluetooth-Symbol (oder drücke `Super + Ctrl + B`), um Geräte zu koppeln und zu verbinden. Siehe [Netzwerk](35-networking.md) für die ganze Geschichte.

## Eigene hinzufügen

Jedes Terminalprogramm kann die volle App-Behandlung bekommen. Gehe zu _Install > TUI_ im Omarchy-Menü (`Super + Space`), gib ihm einen Namen, einen Startbefehl, einen Fensterstil und ein Symbol, und es wird im App-Launcher wie jede andere Anwendung angezeigt. Du kannst es unter _Remove > TUI_ wieder entfernen.
