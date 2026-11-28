# Navigation

Alles in Omarchy läuft über die Tastatur — _ALLES!_ Wenn das System zum ersten Mal startet, kannst du mit der Maus allein buchstäblich gar nichts machen. Aber du kannst `Super + Space` drücken, um das Omarchy-Menü einzublenden, und von hier aus kannst du so ziemlich alles machen.

Aber das Omarchy-Menü ist nicht einmal als die Hauptart gedacht, das System die meiste Zeit zu bedienen. Wir kommen noch schneller hin! Alle wichtigsten Anwendungen sind direkt an einzelne Hotkeys gebunden. Du startest das Terminal mit `Super + Return` und einen Browser mit `Super + Shift + Return`. Probiere eins nach dem anderen aus, und du wirst die Magie von Hyprlands Tiling in Aktion sehen:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kannst dann `Super + J` drücken, um sie übereinander statt nebeneinander zu stapeln:

 ![navigation-stacked](images/navigation-stacked.webp)

Drücke noch einmal `Super + J`, um sie wieder nebeneinander zu bringen. Probiere dann `Super + Shift + Arrow Right`, während du im Browser bist, um die Fenster zu tauschen.

Probiere jetzt `Super + Shift + T`, um den Aktivitätsmonitor zu starten. Der erscheint als schwebendes Fenster. Du kannst ihn mit `Super + T` kacheln (und das noch einmal drücken, um ihn wieder schwebend zu machen). Drücke jetzt `Super + Shift + F`, um den Dateimanager zu öffnen. Du wirst ein schickes Vierfach-Setup haben:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigierst mit `Super + Arrow` zwischen den Fenstern, die aktiv sein sollen. Das wechselt den Fokus und bewegt den Cursor in die Mitte der neuen Anwendung. Am Rand eines Bildschirms geht es weiter zum Monitor auf dieser Seite.

Wenn du `Super + Shift + 2` drückst, verschiebst du die aktuell fokussierte Anwendung auf den zweiten Workspace. `Super + Shift + 1` verschiebt sie zurück. (Und `Super + Shift + Alt + 2` verschiebt die aktuell fokussierte Anwendung auf den zweiten Workspace, ohne zu ihm zu wechseln).

Bei mehr als einem Monitor hat jeder Monitor seine eigenen Workspaces 1 bis 10. `Super + 2` geht zum zweiten Workspace des Monitors, auf dem du dich befindest, und die obere Leiste jedes Monitors zeigt seine eigenen Workspaces und den, den er gerade anzeigt. `Super + Tab` durchläuft die Workspaces auf dem Monitor, auf dem du dich befindest. `Super + Shift + Ctrl + Arrows` verschiebt das Fenster, auf dem du dich befindest, auf den Monitor in dieser Richtung, auf den Workspace, den er gerade anzeigt, und `Super + Shift + Alt + Arrows` verschiebt den Workspace, auf dem du dich befindest, auf den Monitor in dieser Richtung, wo er dieselbe Nummer übernimmt, wenn sie frei ist. Ein Monitor behält seine Workspaces, wenn du ihn aussteckst: Sie schließen sich denen eines anderen Bildschirms an, nummeriert nach denen, die er bereits hat, und gehen unter ihren alten Nummern zurück, wenn der Monitor zurückkehrt.

Wenn du `Super` gedrückt hältst und mit der Maus auf ein Fenster klickst, kannst du neu anordnen, wo es sitzt. Wenn du `Super` hältst und die rechte Maustaste benutzt, kannst du das Fenster frei in der Größe verändern.

Du schließt ein Fenster mit `Super + W` oder `Super + Q` (und schließt alle Fenster mit `Ctrl + Alt + Delete`).

Du kannst auch mit `Super + F` in den Vollbildmodus gehen oder mit `Super + Alt + F` sogar nur auf volle Breite (unter Beibehaltung der oberen Leiste) oder mit `Super + Ctrl + F` in den Vollbildmodus innerhalb eines Fensters (gut für YouTube!).

### Dwindle- vs. Scrolling-Layout

Omarchys Standardlayout heißt dwindle. Es hält alle Fenster, die du auf einem einzelnen Workspace öffnest, jederzeit sichtbar, selbst wenn es sie dafür verkleinern muss.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aber du kannst auch wählen, einen Workspace in das Scrolling-Layout zu verwandeln, bei dem Fenster nebeneinander aufgereiht sind, über den sichtbaren Rand des Displays hinaus. Du verwandelst einen einzelnen Workspace mit `Super + L` in dieses Layout.

Nochmaliges Drücken von `Super + L` macht den Workspace schwebend, wo Fenster frei überlappen und du sie selbst platzierst, und ein dritter Druck bringt ihn zu dwindle zurück. `Super + Alt + L` geht in die andere Richtung durch sie hindurch. Ein Fenster, das ohnehin schwebt — eines, das du mit `Super + T` herausgelöst hast, oder eine App, die immer schwebend öffnet — bleibt schwebend, wenn der Workspace zurück zum Tiling geht. Die obere Leiste markiert den Workspace, auf dem du dich befindest, mit seinem Layout: ein Quadrat für dwindle, ein Kreis für scrolling und ein Dreieck für schwebend. Klicken auf diese Markierung durchläuft das Layout ebenfalls, und das tut auch die Display-Taste auf Laptops, die eine haben.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Die Wahl gilt pro Workspace, und sie bleibt bestehen. So kannst du Workspace 1 auf dwindle zum Surfen und Workspace 2 auf scrolling für Code lassen, und sie kommen nach einem Neustart so zurück.

Wenn du das Scrolling-Layout als Standard verwenden möchtest, kannst du das in `~/.config/hypr/looknfeel.lua` festlegen:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Schwebende Workspaces

Ein schwebender Workspace funktioniert wie ein traditioneller Desktop: Fenster überlappen, und du verschiebst und skalierst sie selbst. Jedes Fenster bekommt eine Titelleiste in den Farben deines Themes, mit Schaltflächen zum Minimieren, Maximieren und Schließen. `Super + M` minimiert das fokussierte Fenster auch. Ein minimiertes Fenster wartet im Dock; klicke auf seine App, um es zurückzubringen. Klicke auf ein Fenster, um es nach vorne zu bringen. Ändere seine Größe von jeder Kante oder Ecke aus. Doppelklicke auf eine Titelleiste, um das Fenster zu maximieren, während die obere Leiste sichtbar bleibt, und noch einmal, um seine alte Größe zurückzubekommen. Chrome und andere auf Chromium basierende Browser, Disks und Document Viewer überspringen die Titelleiste und verwenden stattdessen ihren eigenen Header; `Super + Alt + F` maximiert sie, und `Super + M` minimiert sie.

Ein schwebender Workspace zeigt auch ein Dock mit deinen angehefteten Apps, allem, was gerade läuft, und einem Raster aller Apps hinter der Apps-Schaltfläche, das auch `Super + Alt + Space` und _Apps_ im Omarchy-Menü öffnen. Rechtsklicke auf eine App im Raster, oder drücke `Delete`, um sie zu deinstallieren. Klicke auf eine App, um sie zu öffnen oder ihr Fenster nach vorne zu bringen; klicke erneut, um durch ihre Fenster zu wechseln. Files bringt nur ein Fenster aus dem Workspace zurück, auf dem du dich befindest, und öffnet andernfalls ein neues, und Terminal und Agent starten immer ein weiteres, wobei aber ein minimiertes Fenster zuerst zurückkommt. Mittelklick öffnet ein neues Fenster. Ziehe ein Symbol entlang des Docks, um es zu verschieben; ein laufendes App-Symbol zwischen die anderen zu ziehen behält es dort. Rechtsklicke, um eine App im Dock zu behalten, sie herauszunehmen oder sie zu beenden. Das Dock geht einem Vollbildfenster aus dem Weg. Rechtsklicke auf die Apps-Schaltfläche, um das Dock an eine andere Kante zu verschieben oder es verstecken zu lassen, bis der Zeiger seine Kante erreicht. Die Position ist auch unter _Erscheinungsbild > Dock > Dock-Position_, und `omarchy dock position left` und `omarchy dock autohide on` legen beides von einem Terminal aus fest. Apps, die du im Dock behältst, sind verblasst, während sie nicht laufen.

Neue Workspaces und alle, denen du kein eigenes Layout mit `Super + L` gegeben hast, verwenden das Standardlayout. Das Ändern des Standards setzt jeden Workspace ohne Fenster darauf zurück, während einer mit Fenstern darauf das Layout behält, das er hat. Ein ins Dock minimiertes Fenster zählt weiterhin als Fenster auf dem Workspace, den es verlassen hat. Wähle es unter _Erscheinungsbild > Workspace-Layout_: Tiling, Scrolling oder Floating. `omarchy hyprland workspace layout default scrolling` legt es von einem Terminal aus fest.

### Fenster gruppieren

Fenster können mit `Super + G` gruppiert werden. Sobald du in einer Gruppe bist, gehört jedes Fenster, das du startest, während diese aktiv ist, zur Gruppe. Du kannst dich zwischen diesen gruppierten Fenstern mit `Super + Ctrl + Arrow Left/Right` bewegen oder mit `Super + Alt + 1/2/3/4` direkt zu gruppierten Fenstern in Reihenfolge gehen.

Du kannst ein Fenster mit `Super + Alt + G` aus der Gruppierung bewegen oder die ganze Gruppe auflösen, indem du erneut `Super + G` drückst. Schließlich kannst du Fenster außerhalb der Gruppe mit `Super + Alt + Arrows` in sie hineinbewegen.

### Fenster herauslösen

Du kannst ein Fenster mit `Super + O` aus seiner Workspace-Zuordnung herauslösen. Das heftet es als schwebendes Fenster an, das dir folgt, auf welchen Workspace du auch gehst. Großartig für Videoplayer und dergleichen.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-Workspace

Es gibt einen speziellen Scratchpad-Workspace in voller Größe, der sich über den Workspace legt, auf dem du dich gerade befindest. Du greifst mit `Super + S` auf das zu, was darauf liegt, und platzierst Fenster dort mit `Super + Alt + S`.

Er eignet sich gut für Steuerelemente oder ein Terminal, mit dem du schnell interagieren willst, ohne den aktuellen Workspace zu verlassen.

### Quake-Konsole

Schließlich gibt es eine Quake-Konsole in halber Höhe, die über den Workspace herunterklappt, auf dem du dich gerade befindest. Schalte sie mit `Super + the key above Tab` um (Grave auf US-Layouts), und platziere ein Fenster dort mit `Super + Shift + the key above Tab`.

Beim ersten Öffnen startet sie deinen Standard-Agenten, oder bittet dich, einen auszuwählen, wenn du noch keinen gewählt hast. Während die Konsole ein einzelnes Fenster enthält, klappt sie als zentriertes Panel herunter, statt den Bildschirm zu überspannen. Platziere eine zweite App darauf, und sie geht zur vollen Breite zurück, sodass die beiden Platz haben, nebeneinander zu sitzen.

Um ein Fenster entweder vom Scratchpad oder von der Konsole zu entfernen, sende es direkt mit so etwas wie `Super + Shift + 1` auf einen anderen Workspace.

### Man muss sich erst daran gewöhnen!

Es dauert eine Weile, sich daran zu gewöhnen, deinen Desktop so zu navigieren, aber sobald du es tust, wird es schwer sein, zu einem traditionellen mausgesteuerten Desktop-Erlebnis zurückzukehren!
