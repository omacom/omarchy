# Navigation

Alles in Omarchy läuft über die Tastatur — _ALLES!_ Wenn das System zum ersten Mal startet, kannst du mit der Maus allein buchstäblich nichts anfangen. Aber du kannst `Super + Space` drücken, um das Omarchy Menu zu öffnen, und von hier aus kannst du so gut wie alles tun.

Aber das Omarchy-Menü ist nicht einmal als die Hauptart gedacht, das System die meiste Zeit zu bedienen. Es geht noch schneller! Alle wichtigsten Anwendungen sind direkt an einzelne Hotkeys gebunden. Du startest das Terminal mit `Super + Return` und einen Browser mit `Super + Shift + Return`. Probier das eine nach dem anderen aus, und du siehst die Magie von Hyprlands Tiling in Aktion:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kannst dann `Super + J` drücken, um sie übereinander statt nebeneinander zu stapeln:

 ![navigation-stacked](images/navigation-stacked.webp)

Drücke noch einmal `Super + J`, um sie wieder in ihre Positionen nebeneinander zurückzubringen. Probiere dann `Super + Shift + Arrow Right`, während du im Browser bist, um die Fenster zu tauschen.

Probiere jetzt `Super + Shift + T`, um den Activity Monitor zu starten. Der erscheint als schwebendes Fenster. Du kannst ihn mit `Super + T` kacheln (und mit derselben Taste wieder schwebend machen). Drücke jetzt `Super + Shift + F`, um den Dateimanager zu öffnen. Du erhältst ein sauberes Vierer-Setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Zwischen den Fenstern, von denen eines aktiv sein soll, navigierst du mit `Super + Arrow`. Das wechselt den Fokus und bewegt den Cursor in die Mitte der neuen Anwendung. Am Rand eines Bildschirms geht es weiter zum Monitor auf dieser Seite.

Wenn du `Super + Shift + 2` drückst, verschiebst du die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich. `Super + Shift + 1` verschiebt sie zurück. (Und `Super + Shift + Alt + 2` verschiebt die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich, ohne dorthin zu wechseln).

Bei mehr als einem Monitor hat jeder Monitor seine eigenen Arbeitsbereiche 1 bis 10. `Super + 2` geht zum zweiten Arbeitsbereich des Monitors, auf dem du dich befindest, und die obere Leiste jedes Monitors zeigt seine eigenen Arbeitsbereiche und den, den er gerade anzeigt. `Super + Tab` durchläuft die Arbeitsbereiche auf dem Monitor, auf dem du dich befindest. `Super + Shift + Ctrl + Arrows` verschiebt das Fenster, in dem du dich befindest, auf den Monitor in dieser Richtung, auf den Arbeitsbereich, den dieser gerade anzeigt, und `Super + Shift + Alt + Arrows` verschiebt den Arbeitsbereich, auf dem du dich befindest, auf den Monitor in dieser Richtung, wo er dieselbe Nummer übernimmt, wenn sie frei ist. Ein Monitor behält seine Arbeitsbereiche, wenn du ihn absteckst: Sie schließen sich denen eines anderen Bildschirms an, nummeriert nach denen, die dieser bereits hat, und kehren unter ihren alten Nummern zurück, wenn der Monitor wieder da ist.

Wenn du `Super` gedrückt hältst und mit der Maus auf ein Fenster klickst, kannst du neu anordnen, wo es sitzt. Wenn du `Super` gedrückt hältst und die rechte Maustaste verwendest, kannst du die Fenstergröße frei ändern.

Du schließt ein Fenster mit `Super + W` oder `Super + Q` (und alle Fenster mit `Ctrl + Alt + Delete`).

Du kannst auch mit `Super + F` in den Vollbildmodus gehen oder mit `Super + Alt + F` sogar nur die volle Breite nutzen (unter Beibehaltung der oberen Leiste) oder mit `Super + Ctrl + F` den Vollbildmodus innerhalb eines Fensters verwenden (gut für YouTube!).

### Dwindle vs. Scrolling-Layout

Omarchys Standard-Layout heißt dwindle. Es hält alle Fenster, die du auf einem einzelnen Arbeitsbereich öffnest, jederzeit sichtbar, selbst wenn es sie dafür verkleinern muss.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Du kannst dich aber auch dafür entscheiden, einen Arbeitsbereich in das Scrolling-Layout zu verwandeln, bei dem die Fenster nebeneinander aufgereiht sind, bis über den sichtbaren Rand des Displays hinaus. Einen einzelnen Arbeitsbereich verwandelst du mit `Super + L` in dieses Layout.

Wenn du noch einmal `Super + L` drückst, wird der Arbeitsbereich schwebend, wobei die Fenster sich frei überlappen und du sie selbst platzierst, und ein drittes Drücken bringt ihn zurück zu dwindle. `Super + Alt + L` geht sie in der anderen Richtung durch. Ein Fenster, das ohnehin schwebt — eines, das du mit `Super + T` herausgelöst hast, oder eine App, die immer schwebend öffnet — bleibt schwebend, wenn der Arbeitsbereich zurück zum Kacheln wechselt. Die obere Leiste kennzeichnet den Arbeitsbereich, auf dem du dich befindest, mit seinem Layout: ein Quadrat für dwindle, ein Kreis für scrolling und ein Dreieck für floating. Ein Klick auf diese Kennzeichnung wechselt das Layout ebenfalls, und ebenso tut es die Display-Taste auf Laptops, die eine haben.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Die Wahl gilt pro Arbeitsbereich, und sie bleibt bestehen. Du kannst also Arbeitsbereich 1 auf dwindle zum Surfen und Arbeitsbereich 2 auf scrolling für Code lassen, und sie kommen nach einem Neustart genau so zurück.

Wenn du das Scrolling-Layout als Standard verwenden möchtest, kannst du das in `~/.config/hypr/looknfeel.lua` einstellen:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Schwebende Arbeitsbereiche

Ein schwebender Arbeitsbereich funktioniert wie ein traditioneller Desktop: Die Fenster überlappen sich, und du verschiebst und skalierst sie selbst. Jedes Fenster bekommt eine Titelleiste in den Farben deines Themas, mit Schaltflächen zum Minimieren, Maximieren und Schließen. Auch `Super + M` minimiert das fokussierte Fenster. Ein minimiertes Fenster wartet im Dock; klicke auf seine App, um es zurückzubringen. Klicke auf ein Fenster, um es nach vorne zu bringen. Ändere seine Größe von jeder Kante oder Ecke aus. Doppelklicke auf eine Titelleiste, um das Fenster zu maximieren und dabei die obere Leiste sichtbar zu lassen, und noch einmal, um seine alte Größe zurückzubekommen. Chrome und andere Chromium-basierte Browser, Disks und Document Viewer überspringen die Titelleiste und verwenden stattdessen ihre eigene Kopfzeile; `Super + Alt + F` maximiert sie, und `Super + M` minimiert sie.

Ein schwebender Arbeitsbereich zeigt auch ein Dock, mit deinen angehefteten Apps, allem, was gerade läuft, und einem Raster jeder App hinter der Apps-Schaltfläche, die auch `Super + Alt + Space` und _Apps_ im Omarchy-Menü öffnen. Klicke mit der rechten Maustaste auf eine App im Raster, oder drücke `Delete`, um sie zu deinstallieren. Klicke auf eine App, um sie zu öffnen oder ihr Fenster nach vorne zu bringen; klicke noch einmal, um durch ihre Fenster zu wechseln. Files bringt nur ein Fenster vom Arbeitsbereich zurück, auf dem du dich befindest, und öffnet andernfalls ein neues, und Terminal und Agent starten immer ein weiteres, wobei allerdings ein minimiertes Fenster zuerst zurückkommt. Ein Mittelklick öffnet ein neues Fenster. Ziehe ein Symbol entlang des Docks, um es zu verschieben; ein laufendes Programm zwischen die anderen zu ziehen, behält es dort. Klicke mit der rechten Maustaste, um eine App im Dock zu behalten, sie herauszunehmen oder sie zu beenden. Das Dock weicht einem Vollbildfenster aus. Klicke mit der rechten Maustaste auf die Apps-Schaltfläche, um das Dock an eine andere Kante zu verschieben oder es verstecken zu lassen, bis der Zeiger seine Kante erreicht. Die Position befindet sich auch unter _Appearance > Dock > Dock Position_, und `omarchy dock position left` und `omarchy dock autohide on` stellen beides von einem Terminal aus ein. Apps, die du im Dock behältst, sind ausgegraut, während sie nicht laufen.

Neue Arbeitsbereiche, und alle, denen du mit `Super + L` kein eigenes Layout gegeben hast, verwenden das Standard-Layout. Das Ändern des Standards setzt jeden Arbeitsbereich ohne Fenster darauf zurück, während einer mit Fenstern darauf das Layout behält, das er hat. Ein ins Dock minimiertes Fenster zählt weiterhin als Fenster auf dem Arbeitsbereich, den es verlassen hat. Wähle es unter _Appearance > Workspace Layout_: Tiling, Scrolling oder Floating. `omarchy hyprland workspace layout default scrolling` stellt es von einem Terminal aus ein.

### Fenster gruppieren

Fenster können mit `Super + G` gruppiert werden. Sobald du in einer Gruppe bist, gehört jedes Fenster, das du startest, während diese aktiv ist, zur Gruppe. Zwischen diesen gruppierten Fenstern kannst du dich mit `Super + Ctrl + Arrow Left/Right` bewegen oder mit `Super + Alt + 1/2/3/4` direkt zu gruppierten Fenstern in der Reihenfolge gehen.

Du kannst ein Fenster mit `Super + Alt + G` aus der Gruppierung herausbewegen oder die gesamte Gruppe auflösen, indem du noch einmal `Super + G` drückst. Schließlich kannst du Fenster von außerhalb der Gruppe mit `Super + Alt + Arrows` in sie hineinbewegen.

### Fenster herauslösen

Du kannst ein Fenster mit `Super + O` aus seiner Arbeitsbereichszuordnung herauslösen. Das heftet es als schwebendes Fenster an, das dir folgt, auf welchen Arbeitsbereich du auch gehst. Großartig für Videoplayer und dergleichen.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-Arbeitsbereich

Es gibt einen speziellen Scratchpad-Arbeitsbereich in voller Größe, der sich über den Arbeitsbereich legt, auf dem du dich gerade befindest. Auf das, was sich darauf befindet, greifst du mit `Super + S` zu, und Fenster platzierst du dort mit `Super + Alt + S`.

Er eignet sich gut für Steuerungen oder ein Terminal, mit dem du schnell interagieren willst, ohne den aktuellen Arbeitsbereich zu verlassen.

### Quake-Konsole

Schließlich gibt es eine Quake-Konsole mit halber Höhe, die über dem Arbeitsbereich herunterklappt, auf dem du dich gerade befindest. Schalte sie mit `Super + Grave` um, und platziere ein Fenster dort mit `Super + Shift + Grave`.

Beim ersten Öffnen startet sie deinen Standard-Agenten, oder bittet dich, einen auszuwählen, wenn du noch keinen gewählt hast. Solange die Konsole ein einzelnes Fenster enthält, klappt sie als zentriertes Panel herunter, statt sich über den ganzen Bildschirm zu spannen. Lege eine zweite App darauf, und sie geht zurück zur vollen Breite, damit die beiden Platz haben, nebeneinander zu sitzen.

Um ein Fenster entweder vom Scratchpad oder von der Konsole herunterzubewegen, sende es direkt auf einen anderen Arbeitsbereich, etwa mit `Super + Shift + 1`.

### Da muss man sich erst dran gewöhnen!

Es dauert eine Weile, sich daran zu gewöhnen, so auf deinem Desktop zu navigieren, aber wenn du es einmal kannst, wird es schwer sein, zu einem traditionellen, mausgesteuerten Desktop-Erlebnis zurückzukehren!
