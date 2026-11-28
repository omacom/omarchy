# Navigation

Bei Omarchy läuft alles über die Tastatur — _ALLES!_ Wenn das System zum ersten Mal startet, kannst du mit der Maus allein buchstäblich gar nichts machen. Aber du kannst `Super + Space` drücken, um das Omarchy Menu einzublenden, und von hier aus kannst du so gut wie alles machen.

Das Omarchy-Menü ist aber nicht einmal dafür gedacht, die meiste Zeit der Hauptweg zu sein, um das System zu bedienen. Wir können schneller als das werden! Alle wichtigsten Anwendungen sind direkt an einzelne Tastenkürzel gebunden. Du startest das Terminal mit `Super + Return` und einen Browser mit `Super + Shift + Return`. Probier das eine nach dem anderen aus, und du wirst die Magie des Tiling von Hyprland in Aktion sehen:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kannst dann `Super + J` drücken, um sie übereinander statt nebeneinander zu stapeln:

 ![navigation-stacked](images/navigation-stacked.webp)

Drücke erneut `Super + J`, um sie wieder in ihre Positionen nebeneinander zu bringen. Probier dann `Super + Shift + Arrow Right`, während du im Browser bist, um die Fenster zu tauschen.

Probier jetzt `Super + Shift + T` aus, um den Activity monitor zu starten. Das erscheint als schwebendes Fenster, mit einer Titelleiste, an der du es ziehen kannst, und Schaltflächen zum Minimieren, Maximieren und Schließen. Jedes schwebende Fenster bekommt eine, egal wo es ist. Du kannst es mit `Super + T` ins Tiling einfügen (und das erneut drücken, um es wieder schwebend zu machen). Drücke jetzt `Super + Shift + F`, um den Dateimanager zu öffnen. Du hast dann ein übersichtliches Setup mit vier Bereichen:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigierst mit `Super + Arrow` zwischen den Fenstern, die du aktiv haben willst. Das wechselt den Fokus und bewegt den Cursor in die Mitte der neuen Anwendung. Am Rand eines Bildschirms geht es weiter zum Monitor auf dieser Seite.

Wenn du `Super + Shift + 2` drückst, verschiebst du die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich. `Super + Shift + 1` verschiebt sie zurück. (Und `Super + Shift + Alt + 2` verschiebt die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich, ohne dorthin zu wechseln).

Bei mehr als einem Monitor hat jeder Monitor seine eigenen Arbeitsbereiche 1 bis 10. `Super + 2` geht zum zweiten Arbeitsbereich des Monitors, auf dem du dich befindest, und die obere Leiste jedes Monitors zeigt seine eigenen Arbeitsbereiche und den, der gerade angezeigt wird. `Super + Tab` durchläuft die Arbeitsbereiche auf dem Monitor, auf dem du dich befindest, der Reihe nach. `Super + Shift + Ctrl + Arrows` verschiebt das Fenster, auf dem du dich befindest, auf den Monitor in dieser Richtung, auf den Arbeitsbereich, der dort gerade angezeigt wird, und `Super + Shift + Alt + Arrows` verschiebt den Arbeitsbereich, auf dem du dich befindest, auf den Monitor in dieser Richtung, wo er dieselbe Nummer übernimmt, wenn sie frei ist. Ein Monitor behält seine Arbeitsbereiche, wenn du ihn absteckst: Sie schließen sich denen eines anderen Bildschirms an, nummeriert nach denen, die er bereits hat, und kehren unter ihre alten Nummern zurück, wenn der Monitor wieder da ist.

Wenn du `Super` gedrückt hältst und mit der Maus auf ein Fenster klickst, kannst du neu anordnen, wo es sitzt. Wenn du `Super` gedrückt hältst und die rechte Maustaste verwendest, kannst du das Fenster frei in der Größe verändern.

Du schließt ein Fenster mit `Super + W` oder `Super + Q` (und schließt alle Fenster mit `Ctrl + Alt + Delete`).

Du kannst auch mit `Super + F` in den Vollbildmodus gehen oder mit `Super + Alt + F` sogar nur auf volle Breite (wobei die obere Leiste bleibt) oder mit `Super + Ctrl + F` auf Vollbild innerhalb eines Fensters (gut für YouTube!).

### Dwindle vs. Scrolling-Layout

Das Standardlayout von Omarchy heißt dwindle. Es hält alle Fenster, die du auf einem einzelnen Arbeitsbereich öffnest, jederzeit sichtbar, selbst wenn es sie dafür verkleinern muss.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aber du kannst dich auch dafür entscheiden, einen Arbeitsbereich in das Scrolling-Layout zu verwandeln, bei dem die Fenster nebeneinander aufgereiht sind, über den sichtbaren Rand des Displays hinaus. Du verwandelst einen einzelnen Arbeitsbereich mit `Super + L` in dieses Layout.

Erneutes Drücken von `Super + L` macht den Arbeitsbereich schwebend, wo Fenster sich frei überlappen und du sie selbst platzierst, und ein drittes Drücken bringt ihn zurück zu dwindle. `Super + Alt + L` durchläuft sie in der anderen Richtung. Ein Fenster, das ohnehin schwebt — eines, das du mit `Super + T` herausgelöst hast, oder eine App, die immer schwebend öffnet — bleibt schwebend, wenn der Arbeitsbereich zurück zum Tiling wechselt. Die obere Leiste markiert den Arbeitsbereich, auf dem du dich befindest, mit seinem Layout: ein Quadrat für dwindle, ein Kreis für Scrolling und ein Dreieck für schwebend. Ein Klick auf diese Markierung durchläuft das Layout ebenfalls, und das tut auch die Display-Taste bei Laptops, die eine haben.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Die Wahl gilt pro Arbeitsbereich, und sie bleibt erhalten. So kannst du Arbeitsbereich 1 auf dwindle fürs Surfen und Arbeitsbereich 2 auf Scrolling für Code lassen, und sie kommen nach einem Neustart genau so zurück.

Wenn du das Scrolling-Layout als Standard verwenden möchtest, kannst du das in `~/.config/hypr/looknfeel.lua` einstellen:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Schwebende Arbeitsbereiche

Ein schwebender Arbeitsbereich funktioniert wie ein traditioneller Desktop: Fenster überlappen sich, und du verschiebst sie und änderst ihre Größe selbst. Jedes Fenster bekommt eine Titelleiste in den Farben deines Themas, mit Schaltflächen zum Minimieren, Maximieren und Schließen. `Super + M` minimiert auch das fokussierte Fenster. Ein minimiertes Fenster wartet im Dock; klicke auf seine App, um es zurückzuholen. Klicke auf ein Fenster, um es nach vorne zu bringen. Ändere seine Größe von jeder Kante oder Ecke aus. Doppelklicke auf eine Titelleiste, um das Fenster zu maximieren und dabei die obere Leiste sichtbar zu lassen, und erneut, um seine alte Größe zurückzubekommen. Chrome und andere Chromium-basierte Browser, Disks und Document Viewer überspringen die Titelleiste und verwenden stattdessen ihre eigene Kopfzeile; `Super + Alt + F` maximiert sie, und `Super + M` minimiert sie.

Jeder Arbeitsbereich hat ein Dock, mit deinen angehefteten Apps, allem, was gerade läuft, und einem Raster mit jeder App hinter der Apps-Schaltfläche, das `Super + Alt + Space` und _Apps_ im Omarchy-Menü ebenfalls öffnen. Klicke mit der rechten Maustaste auf eine App im Raster, oder drücke `Delete`, um sie zu deinstallieren. Klicke auf eine App, um sie zu öffnen oder ihr Fenster nach vorne zu bringen; klicke erneut, um der Reihe nach durch ihre Fenster zu gehen. Files holt nur ein Fenster vom Arbeitsbereich zurück, auf dem du dich befindest, und öffnet andernfalls ein neues, und Terminal und Agent starten immer ein weiteres, wobei aber ein minimiertes Fenster zuerst zurückkommt. Mittelklick öffnet ein neues Fenster. Ziehe ein Symbol entlang des Docks, um es zu verschieben; eine laufende App zwischen die anderen zu ziehen, behält sie dort. Klicke mit der rechten Maustaste, um eine App im Dock zu behalten, sie herauszunehmen oder sie zu beenden. Das Dock bleibt sichtbar, solange ein Arbeitsbereich leer ist, und sobald der Arbeitsbereich ein Fenster hat, verbirgt es sich, bis der Zeiger seinen Rand erreicht. Ein Vollbildfenster verbirgt es vollständig. Ziehe die Apps-Schaltfläche in Richtung eines anderen Bildschirmrands, um das Dock dorthin zu verschieben. Klicke sie mit der rechten Maustaste für _Position_, um eine Kante zu wählen, und _Layout_, um das Standardlayout so einzustellen, wie es _Appearance > Workspace Layout_ tut. Die Position ist auch unter _Appearance > Dock > Dock Position_, und `omarchy dock position left` stellt sie von einem Terminal aus ein. Apps, die du im Dock behältst, sind verblasst, solange sie nicht laufen. Um das Dock auf schwebende Arbeitsbereiche zu beschränken, verwende _Appearance > Dock > Dock Only on Floating_ oder `omarchy dock tiling off`.

Neue Arbeitsbereiche, und alle, denen du nicht mit `Super + L` ein eigenes Layout gegeben hast, verwenden das Standardlayout. Das Ändern des Standards setzt jeden Arbeitsbereich ohne Fenster darauf zurück, während einer mit Fenstern das Layout behält, das er hat. Ein ins Dock minimiertes Fenster zählt weiterhin als Fenster auf dem Arbeitsbereich, den es verlassen hat. Wähle es unter _Appearance > Workspace Layout_: Tiling, Scrolling oder Floating. `omarchy hyprland workspace layout default scrolling` stellt es von einem Terminal aus ein.

### Fenster gruppieren

Fenster können mit `Super + G` gruppiert werden. Sobald du in einer Gruppe bist, gehört jedes Fenster, das du startest, während diese aktiv ist, zur Gruppe. Du kannst dich mit `Super + Ctrl + Arrow Left/Right` zwischen diesen gruppierten Fenstern bewegen oder mit `Super + Alt + 1/2/3/4` direkt zu gruppierten Fenstern in der Reihenfolge gehen.

Du kannst ein Fenster mit `Super + Alt + G` aus der Gruppierung herausbewegen oder die gesamte Gruppe auflösen, indem du erneut `Super + G` drückst. Schließlich kannst du Fenster außerhalb der Gruppe mit `Super + Alt + Arrows` in sie hineinbewegen.

### Fenster herauslösen

Du kannst ein Fenster mit `Super + O` aus seiner Arbeitsbereichszuordnung herauslösen. Dadurch wird es als schwebendes Fenster angeheftet, das dir auf jeden Arbeitsbereich folgt, zu dem du gehst. Großartig für Videoplayer und dergleichen.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-Arbeitsbereich

Es gibt einen speziellen Scratchpad-Arbeitsbereich in voller Größe, der sich über den Arbeitsbereich legt, auf dem du dich gerade befindest. Du greifst mit `Super + S` auf das zu, was darauf ist, und du platzierst Fenster dort mit `Super + Alt + S`.

Er eignet sich gut für Steuerungen oder ein Terminal, mit dem du schnell interagieren willst, ohne den aktuellen Arbeitsbereich zu verlassen.

### Quake-Konsole

Schließlich gibt es eine Quake-Konsole in halber Höhe, die sich über den Arbeitsbereich herunterklappt, auf dem du dich gerade befindest. Schalte sie mit `Super + the key above Tab` (grave auf US-Layouts) ein und aus, und platziere ein Fenster dort mit `Super + Shift + the key above Tab`.

Beim ersten Öffnen startet sie deinen Standard-Agenten, oder bittet dich, einen auszuwählen, wenn du noch keinen gewählt hast. Solange die Konsole ein einzelnes Fenster enthält, klappt sie als zentriertes Panel herunter, statt sich über den Bildschirm zu spannen. Lege eine zweite App darauf, und sie geht zurück zur vollen Breite, sodass die beiden Platz haben, nebeneinander zu sitzen.

Um ein Fenster entweder vom Scratchpad oder von der Konsole wegzubewegen, sende es direkt an einen anderen Arbeitsbereich, etwa mit `Super + Shift + 1`.

### Man muss sich erst daran gewöhnen!

Es dauert ein wenig, sich daran zu gewöhnen, deinen Desktop so zu navigieren, aber wenn du es einmal getan hast, wird es schwer sein, zu einem traditionellen, mausgesteuerten Desktop-Erlebnis zurückzukehren!
