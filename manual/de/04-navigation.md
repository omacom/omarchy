# Navigation

Alles in Omarchy läuft über die Tastatur — _ALLES!_ Wenn das System zum ersten Mal startet, kannst du mit der Maus allein buchstäblich nichts ausrichten. Aber du kannst `Super + Space` drücken, um das Omarchy-Menü einzublenden, und von hier aus kannst du so gut wie alles machen.

Aber das Omarchy-Menü ist die meiste Zeit nicht einmal als Hauptweg gedacht, um das System zu bedienen. Wir können schneller sein als das! Alle wichtigsten Anwendungen sind direkt an einzelne Tastenkürzel gebunden. Du startest das Terminal mit `Super + Return` und einen Browser mit `Super + Shift + Return`. Probiere, das eine nach dem anderen zu tun, und du wirst die Magie von Hyprlands Tiling in Aktion sehen:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kannst dann `Super + J` drücken, um sie übereinander statt nebeneinander zu stapeln:

 ![navigation-stacked](images/navigation-stacked.webp)

Drücke erneut `Super + J`, um sie in ihre Positionen nebeneinander zurückzubringen. Probiere dann `Super + Shift + Arrow Right`, während du im Browser bist, um die Fenster zu tauschen.

Probiere jetzt `Super + Shift + T`, um den Aktivitätsmonitor zu starten. Das erscheint als schwebendes Fenster. Du kannst es mit `Super + T` kacheln (und das erneut drücken, um es wieder schwebend zu machen). Drücke jetzt `Super + Shift + F`, um den Dateimanager zu öffnen. Du wirst ein ordentliches Vierfach-Setup haben:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigierst mit `Super + Arrow` zwischen den Fenstern, die du aktiv haben willst. Dadurch wechselt der Fokus und der Cursor bewegt sich in die Mitte der neuen Anwendung. Am Rand eines Bildschirms geht es weiter zum Monitor auf dieser Seite.

Wenn du `Super + Shift + 2` drückst, verschiebst du die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich. `Super + Shift + 1` verschiebt sie zurück. (Und `Super + Shift + Alt + 2` verschiebt die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich, ohne zu ihm zu wechseln).

Bei mehr als einem Monitor hat jeder Monitor seine eigenen Arbeitsbereiche 1 bis 10. `Super + 2` geht zum zweiten Arbeitsbereich des Monitors, auf dem du dich befindest, und die obere Leiste jedes Monitors zeigt seine eigenen Arbeitsbereiche und den, den er anzeigt. `Super + Tab` durchläuft die Arbeitsbereiche auf dem Monitor, auf dem du dich befindest. `Super + Shift + Ctrl + Arrows` verschiebt das Fenster, auf dem du dich befindest, zum Monitor in dieser Richtung, auf den Arbeitsbereich, den er anzeigt, und `Super + Shift + Alt + Arrows` verschiebt den Arbeitsbereich, auf dem du dich befindest, zum Monitor in dieser Richtung, wo er dieselbe Nummer annimmt, wenn sie frei ist. Ein Monitor behält seine Arbeitsbereiche, wenn du ihn absteckst: Sie schließen sich denen eines anderen Bildschirms an, nummeriert nach denen, die er bereits hat, und gehen unter ihren alten Nummern zurück, wenn der Monitor zurückkehrt.

Wenn du `Super` gedrückt hältst und mit der Maus auf ein Fenster klickst, kannst du neu anordnen, wo es sitzt. Wenn du `Super` gedrückt hältst und die rechte Maustaste benutzt, kannst du die Größe des Fensters frei ändern.

Du schließt ein Fenster mit `Super + W` oder `Super + Q` (und alle Fenster mit `Ctrl + Alt + Delete`).

Du kannst auch mit `Super + F` in den Vollbildmodus gehen oder mit `Super + Alt + F` sogar nur auf volle Breite (wobei die obere Leiste bleibt) oder mit `Super + Ctrl + F` in den Vollbildmodus innerhalb eines Fensters (gut für YouTube!).

### Dwindle vs. Scrolling-Layout

Omarchys Standardlayout heißt dwindle. Es hält alle Fenster, die du auf einem einzelnen Arbeitsbereich öffnest, jederzeit sichtbar, selbst wenn es sie dafür verkleinern muss.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aber du kannst einen Arbeitsbereich auch in das Scrolling-Layout verwandeln, bei dem Fenster nebeneinander aufgereiht sind, über den sichtbaren Rand des Displays hinaus. Du verwandelst einen einzelnen Arbeitsbereich über `Super + L` in dieses Layout.

Erneutes Drücken von `Super + L` macht den Arbeitsbereich schwebend, wo Fenster sich frei überlappen und du sie selbst platzierst, und ein drittes Drücken bringt ihn zu dwindle zurück. `Super + Alt + L` geht in der anderen Richtung durch sie hindurch. Ein Fenster, das ohnehin schwebt — eines, das du mit `Super + T` herausgelöst hast, oder eine App, die immer schwebend öffnet — bleibt schwebend, wenn der Arbeitsbereich zum Tiling zurückgeht. Die obere Leiste markiert den Arbeitsbereich, auf dem du dich befindest, mit seinem Layout: ein Quadrat für dwindle, ein Kreis für scrolling und ein Dreieck für floating. Ein Klick auf diese Markierung durchläuft das Layout ebenfalls.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Die Wahl gilt pro Arbeitsbereich, und sie bleibt bestehen. So kannst du Arbeitsbereich 1 auf dwindle zum Browsen und Arbeitsbereich 2 auf scrolling für Code lassen, und sie werden nach einem Neustart so zurückkommen.

Wenn du das Scrolling-Layout als Standard verwenden willst, kannst du das in `~/.config/hypr/looknfeel.lua` einstellen:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Schwebende Arbeitsbereiche

Ein schwebender Arbeitsbereich funktioniert wie ein traditioneller Desktop: Fenster überlappen sich, und du verschiebst und dimensionierst sie selbst. Jedes Fenster erhält eine Titelleiste in den Farben deines Themes, mit Schaltflächen zum Minimieren, Maximieren und Schließen. `Super + M` minimiert auch das fokussierte Fenster. Ein minimiertes Fenster wartet im Dock; klicke seine App, um es zurückzubringen. Klicke ein Fenster, um es nach vorne zu bringen. Ändere seine Größe von jeder Kante oder Ecke aus. Doppelklicke eine Titelleiste, um das Fenster zu maximieren, während die obere Leiste sichtbar bleibt, und erneut, um seine alte Größe zurückzubekommen.

Ein schwebender Arbeitsbereich zeigt auch ein Dock, mit deinen angehefteten Apps, allem, was läuft, und einem Raster jeder App hinter der Apps-Schaltfläche, die `Super + Alt + Space` und _Apps_ im Omarchy-Menü ebenfalls öffnen. Klicke mit der rechten Maustaste auf eine App im Raster, oder drücke `Delete`, um sie zu deinstallieren. Klicke eine App, um sie zu öffnen oder ihr Fenster nach vorne zu bringen; klicke erneut, um ihre Fenster zu durchlaufen. Ein Mittelklick öffnet ein neues Fenster. Ziehe ein Symbol entlang des Docks, um es zu verschieben; ein Ziehen einer laufenden App zwischen die anderen behält sie dort. Klicke mit der rechten Maustaste, um eine App im Dock zu behalten, sie herauszunehmen oder sie zu beenden. Das Dock macht einem Vollbildfenster Platz. Klicke mit der rechten Maustaste auf die Apps-Schaltfläche, um das Dock an eine andere Kante zu verschieben oder es verstecken zu lassen, bis der Zeiger seine Kante erreicht. Die Position befindet sich auch unter _Appearance > Dock > Dock Position_, und `omarchy dock position left` und `omarchy dock autohide on` stellen beides von einem Terminal aus ein. Apps, die du im Dock behältst, sind ausgegraut, solange sie nicht laufen.

Neue Arbeitsbereiche, und alle, denen du mit `Super + L` kein eigenes Layout gegeben hast, verwenden das Standardlayout. Das Ändern des Standards setzt jeden Arbeitsbereich ohne Fenster darauf zurück, während einer mit Fenstern darauf das Layout behält, das er hat. Ein zum Dock minimiertes Fenster zählt weiterhin als Fenster auf dem Arbeitsbereich, den es verlassen hat. Wähle es unter _Appearance > Workspace Layout_: Tiling, Scrolling oder Floating. `omarchy-hyprland-workspace-layout-default scrolling` stellt es von einem Terminal aus ein.

### Fenster gruppieren

Fenster können mit `Super + G` gruppiert werden. Sobald du in einer Gruppe bist, gehört jedes Fenster, das du startest, solange das aktiv ist, zur Gruppe. Du kannst dich mit `Super + Ctrl + Arrow Left/Right` zwischen diesen gruppierten Fenstern bewegen oder mit `Super + Alt + 1/2/3/4` direkt zum gruppierten Fenster in Reihenfolge gehen.

Du kannst ein Fenster mit `Super + Alt + G` aus der Gruppierung bewegen oder die gesamte Gruppe zerlegen, indem du erneut `Super + G` drückst. Schließlich kannst du Fenster außerhalb der Gruppe mit `Super + Alt + Arrows` in sie hineinbewegen.

### Fenster herauslösen

Du kannst ein Fenster mit `Super + O` aus seiner Arbeitsbereichszuordnung herauslösen. Das heftet es als schwebendes Fenster an, das dir auf jeden Arbeitsbereich folgt, zu dem du gehst. Großartig für Videoplayer und dergleichen.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-Arbeitsbereich

Es gibt einen speziellen Scratchpad-Arbeitsbereich in voller Größe, der sich über den Arbeitsbereich legt, auf dem du dich gerade befindest. Du greifst mit `Super + S` auf das zu, was auf ihm ist, und du platzierst Fenster dort mit `Super + Alt + S`.

Es funktioniert gut für Bedienelemente oder ein Terminal, mit denen du schnell interagieren willst, ohne den aktuellen Arbeitsbereich zu verlassen.

### Quake-Konsole

Schließlich gibt es eine Quake-Konsole mit halber Höhe, die über den Arbeitsbereich herunterklappt, auf dem du dich gerade befindest. Schalte sie mit `Super + Grave` um, und platziere ein Fenster dort mit `Super + Shift + Grave`.

Sie öffnet sich mit deinem Standard-Agenten, bereit loszulegen. Während die Konsole ein einzelnes Fenster enthält, klappt sie als zentriertes Panel herunter, statt sich über den Bildschirm zu spannen. Lege eine zweite App darauf und sie geht zur vollen Breite zurück, sodass die beiden Raum haben, nebeneinander zu sitzen.

Um ein Fenster entweder vom Scratchpad oder von der Konsole zu bewegen, sende es direkt zu einem anderen Arbeitsbereich mit etwas wie `Super + Shift + 1`.

### Es braucht etwas Gewöhnung!

Es dauert eine Weile, sich daran zu gewöhnen, deinen Desktop so zu navigieren, aber sobald du es tust, wird es schwer sein, zu einem traditionellen mausgesteuerten Desktop-Erlebnis zurückzukehren!
