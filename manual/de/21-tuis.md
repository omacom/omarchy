# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) ist eine herrliche Alternative zu so etwas wie der GitHub Desktop-Anwendung, und es läuft im Terminal.

Du kannst es direkt ausführen, indem du in ein beliebiges von git verwaltetes Verzeichnis wechselst und `lazygit` ausführst. Oder du führst es in Neovim aus, wo es mit `Space G G` gestartet werden kann.

Mit `Tab` springst du zwischen den verschiedenen Bereichen hin und her. Im Files-Bereich wählst du mit `Space` Dateien für das Staging aus, und dann kannst du mit `c` einen neuen Commit erstellen. Mit `?` siehst du alle verfügbaren Befehle.

## Btop

[Btop](https://github.com/aristocratos/btop) ist ein wunderschöner Ressourcenmanager, der Speicher-, CPU-, Festplatten- und Netzwerkauslastung zeigt. Er listet auch alle aktiven Prozesse auf und ermöglicht es dir, sie zu verwalten.

Omarchy nennt ihn Activity Monitor, und du startest ihn über den App-Launcher oder mit `Super + Shift + T`. Er öffnet sich als schwebendes Fenster, das du mit `Super + T` gekachelt anordnen kannst.

## Herdr

[Herdr](https://herdr.dev) ist ein Terminal-Workspace-Manager, der dir Workspaces, Tabs und Bereiche bietet und sie alle in einer persistenten Sitzung am Laufen hält, von der du dich trennen und zu der du später zurückkehren kannst.

Du startest ihn (oder verbindest dich erneut mit deiner bestehenden Sitzung) über den App-Launcher oder mit `Super + Ctrl + Return`. Omarchy liefert eine Herdr-Konfiguration aus, die seine Tmux-Konfiguration spiegelt, sodass die Präfix-Taste auch hier `Ctrl + Space` ist. Alle Tastenkürzel kannst du mit `Super + Ctrl + K` durchsuchen.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zeigt Systeminformationen wie Kernel-Version, Uptime, Theme, CPU, Speicher und mehr. Es ist ein Nachfolger des beliebten neofetch-Tools.

Omarchy hat dies als _System > About_ im Omarchy-Menü (`Super + Space`) verpackt.

## Cliamp

[Cliamp](https://www.cliamp.stream/) ist ein Retro-Musikplayer für das Terminal, inspiriert von Winamp 2.x, komplett mit integrierten Radiosendern für Lo-Fi-Beats. Starte ihn mit `Super + Shift + Alt + M` oder über das Omarchy-Menü unter _Apps_. Drücke `?`, um die vollständige Liste der Tastenkürzel zu sehen.

## Was ist mit Wi-Fi und Bluetooth?

Du wirst keine TUIs für Wi-Fi und Bluetooth finden — diese Aufgaben gehören zur Omarchy-Shell. Klicke auf das Wi-Fi-Symbol in der oberen Leiste (oder drücke `Super + Ctrl + N`), um Netzwerke zu sehen und dich zu verbinden, und klicke auf das Bluetooth-Symbol (oder drücke `Super + Ctrl + B`), um Geräte zu koppeln und zu verbinden. Siehe [Netzwerk](35-networking.md) für alle Details.

## Eigene hinzufügen

Jedes Terminalprogramm kann die volle App-Behandlung bekommen. Gehe im Omarchy-Menü (`Super + Space`) zu _Install > TUI_, gib ihm einen Namen, einen Startbefehl, einen Fensterstil und ein Symbol, und es wird im App-Launcher wie jede andere Anwendung angezeigt. Unter _Remove > TUI_ kannst du es wieder entfernen.
