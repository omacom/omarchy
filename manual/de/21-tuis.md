# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) ist eine erfrischende Alternative zu so etwas wie der Anwendung GitHub Desktop, und es läuft im Terminal.

Du kannst es direkt ausführen, indem du in ein beliebiges von Git verwaltetes Verzeichnis gehst und `lazygit` ausführst. Oder du führst es in Neovim aus, wo es mit `Space G G` gestartet werden kann.

Zwischen den verschiedenen Panes springst du mit `Tab`. Im Pane Files wählst du Dateien mit `Space` zum Stagen aus, und dann kannst du mit `c` einen neuen Commit erstellen. Alle verfügbaren Befehle siehst du mit `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) ist ein schöner Ressourcenmanager, der Speicher-, CPU-, Platten- und Netzwerkauslastung zeigt. Er listet auch alle aktiven Prozesse auf und erlaubt dir, sie zu verwalten.

Omarchy nennt es Activity, und du startest es mit `Super + Ctrl + T`. Es öffnet sich als schwebendes Fenster, das du mit `Super + T` kacheln kannst.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) ist ein Terminal-Workspace-Manager, der dir Arbeitsflächen, Tabs und Panes bietet und sie alle in einer dauerhaften Sitzung laufen lässt, von der du dich trennen und zu der du später zurückkehren kannst.

Du startest es (oder verbindest dich wieder mit deiner bestehenden Sitzung) mit `Super + Ctrl + Return`. Omarchy liefert eine Herdr-Konfiguration mit, die seiner Tmux-Konfiguration entspricht, sodass die Präfix-Taste hier ebenfalls `Ctrl + Space` ist. Alle Tastenkürzel kannst du mit `Super + Ctrl + K` durchsuchen.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zeigt Systeminformationen wie Kernelversion, Laufzeit, Design, CPU, Speicher und mehr. Es ist ein Nachfolger des beliebten Werkzeugs neofetch.

Omarchy hat dies als _Über_ im Omarchy-Menü (`Super + Space`) verpackt.

## Cliamp

[Cliamp](https://www.cliamp.stream/) ist ein Retro-Musikplayer fürs Terminal, inspiriert von Winamp 2.x, komplett mit eingebauten Radiosendern für Lo-Fi-Beats. Starte ihn mit `Super + Shift + Alt + M` oder aus dem Omarchy-Menü unter _Apps_. Drücke `?` für die vollständige Liste der Tastenkürzel.

## Was ist mit WLAN und Bluetooth?

Für WLAN und Bluetooth findest du keine TUIs — diese Aufgaben gehören zur Omarchy-Shell. Klicke auf das WLAN-Symbol in der Menüleiste (oder drücke `Super + Ctrl + W`), um Netzwerke zu sehen und dich zu verbinden, und klicke auf das Bluetooth-Symbol (oder drücke `Super + Ctrl + B`), um Geräte zu koppeln und zu verbinden. Siehe [Networking](35-networking.md) für die ganze Geschichte.

## Eigene hinzufügen

Jedes Terminalprogramm kann die volle App-Behandlung erhalten. Gehe im Omarchy-Menü (`Super + Space`) zu _Installieren > TUI_, gib ihm einen Namen, einen Startbefehl, einen Fensterstil und ein Symbol, und es erscheint wie jede andere Anwendung im App-Launcher. Unter _Entfernen > TUI_ kannst du es wieder entfernen.
