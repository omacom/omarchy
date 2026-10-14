# Navigation

Alles in Omarchy läuft über die Tastatur — _ALLES!_ Wenn das System zum ersten Mal startet, kannst du buchstäblich nichts allein mit der Maus tun. Aber du kannst `Super + Space` drücken, um das Omarchy-Menü einzublenden, und von hier aus kannst du so ziemlich alles tun.

Aber das Omarchy-Menü ist nicht einmal als der Hauptweg gedacht, das System die meiste Zeit zu bedienen. Wir können schneller als das sein! Alle wichtigsten Anwendungen sind direkt an einzelne Hotkeys gebunden. Das Terminal startest du mit `Super + Return` und einen Browser mit `Super + Shift + Return`. Probiere beides nacheinander aus, und du siehst die Magie von Hyprlands Tiling in Aktion:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kannst dann `Super + J` drücken, um sie übereinander statt nebeneinander zu stapeln:

 ![navigation-stacked](images/navigation-stacked.webp)

Drücke erneut `Super + J`, um sie in ihre Positionen nebeneinander zurückzubringen. Probiere dann `Super + Shift + Arrow Right` aus, während du auf dem Browser bist, um die Fenster zu tauschen.

Probiere jetzt `Super + Ctrl + T` aus, um den Aktivitätsmonitor zu starten. Er erscheint als schwebendes Fenster. Du kannst ihn mit `Super + T` kacheln (und das erneut drücken, um ihn wieder schwebend zu machen). Drücke jetzt `Super + Shift + F`, um den Dateimanager zu öffnen. Du erhältst ein hübsches Vierfach-Setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Zwischen den Fenstern, die aktiv sein sollen, navigierst du mit `Super + Arrow`. Das wechselt den Fokus und bewegt den Cursor in die Mitte der neuen Anwendung.

Wenn du `Super + Shift + 2` drückst, verschiebst du die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich. `Super + Shift + 1` verschiebt sie zurück. (Und `Super + Shift + Alt + 2` verschiebt die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich, ohne zu ihm zu wechseln).

Wenn du `Super` gedrückt hältst und mit der Maus auf ein Fenster klickst, kannst du neu anordnen, wo es sitzt. Wenn du `Super` gedrückt hältst und die rechte Maustaste benutzt, kannst du das Fenster frei in der Größe verändern.

Du schließt ein Fenster mit `Super + W` oder `Super + Q` (und schließt alle Fenster mit `Ctrl + Alt + Delete`).

Du kannst auch mit `Super + F` in den Vollbildmodus gehen oder auch nur mit `Super + Alt + F` auf volle Breite (wobei die obere Leiste bleibt) oder mit `Super + Ctrl + F` in den Vollbildmodus innerhalb eines Fensters (gut für YouTube!).

### Dwindle- vs. Scrolling-Layout

Omarchys Standardlayout heißt dwindle. Es hält alle Fenster, die du auf einem einzelnen Arbeitsbereich öffnest, jederzeit sichtbar, selbst wenn es sie dafür verkleinern muss.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aber du kannst einen Arbeitsbereich auch in das Scrolling-Layout versetzen, bei dem die Fenster nebeneinander aufgereiht sind, über den sichtbaren Rand des Displays hinaus. Einen einzelnen Arbeitsbereich versetzt du mit `Super + L` in dieses Layout.

Ein erneutes Drücken von `Super + L` macht den Arbeitsbereich schwebend, bei dem sich Fenster frei überlagern und du sie selbst platzierst, und ein drittes Drücken bringt ihn zurück zu dwindle. `Super + Alt + L` geht sie in der anderen Richtung durch. Ein Fenster, das ohnehin schwebt — eines, das du mit `Super + T` herausgelöst hast, oder eine App, die immer schwebend öffnet — bleibt schwebend, wenn der Arbeitsbereich zum Tiling zurückkehrt. Die obere Leiste markiert den Arbeitsbereich, auf dem du dich befindest, mit seinem Layout: ein Quadrat für dwindle, ein Kreis für Scrolling und ein Dreieck für schwebend. Ein Klick auf diese Markierung wechselt das Layout ebenfalls durch.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Die Wahl gilt pro Arbeitsbereich, und sie bleibt bestehen. So kannst du Arbeitsbereich 1 auf dwindle zum Surfen und Arbeitsbereich 2 auf Scrolling für Code lassen, und sie kommen nach einem Neustart so zurück.

Wenn du das Scrolling-Layout als Standard verwenden möchtest, kannst du das in `~/.config/hypr/looknfeel.lua` einstellen:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Schwebende Arbeitsbereiche

Ein schwebender Arbeitsbereich funktioniert wie ein traditioneller Desktop: Fenster überlagern sich, und du verschiebst und dimensionierst sie selbst. Jedes Fenster bekommt eine Titelleiste in den Farben deines Themes, mit Schaltflächen zum Minimieren, Maximieren und Schließen. `Super + M` minimiert auch das fokussierte Fenster. Ein minimiertes Fenster wartet im Dock; klicke auf seine App, um es zurückzuholen. Klicke auf ein Fenster, um es in den Vordergrund zu holen. Ziehe es an einer beliebigen Kante oder Ecke auf eine andere Größe. Doppelklicke auf eine Titelleiste, um das Fenster zu maximieren, während die obere Leiste sichtbar bleibt, und noch einmal, um seine alte Größe zurückzubekommen.

Ein schwebender Arbeitsbereich zeigt auch ein Dock, mit deinen angehefteten Apps, allem, was gerade läuft, und einem Raster aller Apps hinter der Apps-Schaltfläche, die auch `Super + Alt + Space` und _Apps_ im Omarchy-Menü öffnen. Klicke mit der rechten Maustaste auf eine App im Raster oder drücke `Delete`, um sie zu deinstallieren. Klicke auf eine App, um sie zu öffnen oder ihr Fenster in den Vordergrund zu holen; klicke erneut, um durch ihre Fenster durchzuschalten. Ein Mittelklick öffnet ein neues Fenster. Ziehe ein Symbol entlang des Docks, um es zu verschieben; eine laufende App zwischen die anderen zu ziehen, behält sie dort. Klicke mit der rechten Maustaste, um eine App im Dock zu behalten, sie herauszunehmen oder sie zu beenden. Das Dock geht einem Vollbildfenster aus dem Weg. Klicke mit der rechten Maustaste auf die Apps-Schaltfläche, um das Dock an eine andere Kante zu verschieben oder es auszublenden, bis der Zeiger seine Kante erreicht. Die Position findest du auch unter _Trigger > Appearance > Dock > Dock Position_, und `omarchy dock position left` und `omarchy dock autohide on` stellen beides von einem Terminal aus ein. Apps, die du im Dock behältst, sind ausgeblasst, solange sie nicht laufen.

Neue Arbeitsbereiche und alle, denen du mit `Super + L` kein eigenes Layout gegeben hast, verwenden das Standardlayout. Das Ändern des Standards setzt jeden Arbeitsbereich ohne Fenster auf ihn zurück, während einer mit Fenstern das Layout behält, das er hat. Ein in das Dock minimiertes Fenster zählt weiterhin als Fenster auf dem Arbeitsbereich, den es verlassen hat. Wähle es unter _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling oder Floating. `omarchy-hyprland-workspace-layout-default scrolling` stellt es von einem Terminal aus ein.

### Fenster gruppieren

Fenster können mit `Super + G` gruppiert werden. Sobald du in einer Gruppe bist, gehört jedes Fenster, das du startest, solange das aktiv ist, zu dieser Gruppe. Zwischen diesen gruppierten Fenstern kannst du dich mit `Super + Ctrl + Arrow Left/Right` bewegen oder mit `Super + Alt + 1/2/3/4` direkt zu einem gruppierten Fenster in der Reihenfolge wechseln.

Du kannst ein Fenster mit `Super + Alt + G` aus der Gruppierung herausbewegen oder die gesamte Gruppe auflösen, indem du erneut `Super + G` drückst. Schließlich kannst du Fenster außerhalb der Gruppe mit `Super + Alt + Arrows` in sie hineinbewegen.

### Fenster herauslösen

Du kannst ein Fenster mit `Super + O` aus seiner Arbeitsbereich-Zuweisung herauslösen. Dadurch wird es als schwebendes Fenster angeheftet, das dir folgt, auf welchen Arbeitsbereich du auch gehst. Großartig für Videoplayer und Ähnliches.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-Arbeitsbereich

Schließlich gibt es einen speziellen Scratchpad-Arbeitsbereich, der über den Arbeitsbereich herunterklappt, auf dem du dich gerade befindest, ganz wie eine Quake-Konsole. Schalte ihn mit `Super + Grave` oder `Super + S` um und platziere ein Fenster dort mit `Super + Shift + Grave` oder `Super + Alt + S`.

Er eignet sich besonders gut für ein Terminal, in dem ein Agent läuft, oder für Steuerelemente, mit denen du schnell interagieren möchtest, ohne den aktuellen Arbeitsbereich zu verlassen. Um ein Fenster vom Scratchpad wegzubewegen, sende es direkt an einen anderen Arbeitsbereich mit etwa `Super + Shift + 1`.

Solange der Scratchpad ein einzelnes Fenster enthält, klappt er als zentrales Panel herunter, anstatt den Bildschirm zu überspannen. Platziere eine zweite App darauf und er kehrt zur vollen Breite zurück, damit die beiden Platz haben, nebeneinander zu sitzen.

### Es braucht etwas Gewöhnung!

Es braucht ein wenig Zeit, sich daran zu gewöhnen, auf dem Desktop so zu navigieren, aber sobald du es tust, wird es schwer sein, zu einer traditionellen, mausgesteuerten Desktop-Erfahrung zurückzukehren!
