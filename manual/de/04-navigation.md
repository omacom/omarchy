# Navigation

Alles in Omarchy geschieht über die Tastatur — _ALLES!_ Wenn das System zum ersten Mal startet, kannst du buchstäblich nichts allein mit der Maus tun. Aber du kannst `Super + Space` drücken, um das Omarchy Menu zu öffnen, und von hier aus kannst du so gut wie alles tun.

Aber das Omarchy-Menü ist nicht einmal dafür gedacht, die meiste Zeit die Hauptmethode zur Bedienung des Systems zu sein. Wir können schneller als das sein! Alle wichtigsten Anwendungen sind direkt an einzelne Tastenkürzel gebunden. Du startest das Terminal mit `Super + Return` und einen Browser mit `Super + Shift + Return`. Probier eines nach dem anderen aus, und du wirst die Magie des Tiling von Hyprland in Aktion sehen:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Dann kannst du `Super + J` drücken, um sie übereinander statt nebeneinander zu stapeln:

 ![navigation-stacked](images/navigation-stacked.webp)

Drücke erneut `Super + J`, um sie wieder nebeneinander zu positionieren. Probier dann `Super + Shift + Arrow Right`, während du im Browser bist, um die Fenster zu tauschen.

Probier nun `Super + Shift + T`, um den Aktivitätsmonitor zu starten. Der erscheint als schwebendes Fenster mit einer Titelleiste, an der du es ziehen kannst, und Schaltflächen zum Minimieren, Maximieren und Schließen. Jedes schwebende Fenster bekommt eine, wo auch immer es sich befindet. Du kannst es mit `Super + T` ins Tiling einordnen (und erneut drücken, um es wieder schwebend zu machen). Drücke nun `Super + Shift + F`, um den Dateimanager zu öffnen. Du wirst eine ordentliche Vierfach-Anordnung haben:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigierst mit `Super + Arrow` zwischen den Fenstern, die aktiv sein sollen. Das wechselt den Fokus und bewegt den Cursor in die Mitte der neuen Anwendung. Am Rand eines Bildschirms geht es weiter zum Monitor auf dieser Seite.

Wenn du `Super + Shift + 2` drückst, verschiebst du die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich. `Super + Shift + 1` verschiebt sie zurück. (Und `Super + Shift + Alt + 2` verschiebt die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich, ohne zu ihm zu wechseln).

Mit mehr als einem Monitor hat jeder Monitor seine eigenen Arbeitsbereiche 1 bis 10. `Super + 2` geht zum zweiten Arbeitsbereich des Monitors, auf dem du dich befindest, und die obere Leiste jedes Monitors zeigt seine eigenen Arbeitsbereiche und den, den er gerade anzeigt. `Super + Tab` durchläuft die Arbeitsbereiche auf dem Monitor, auf dem du dich befindest. `Super + Shift + Ctrl + Arrows` verschiebt das Fenster, auf dem du dich befindest, auf den Monitor in dieser Richtung, auf den Arbeitsbereich, den er gerade anzeigt, und `Super + Shift + Alt + Arrows` verschiebt den Arbeitsbereich, auf dem du dich befindest, auf den Monitor in dieser Richtung, wo er dieselbe Nummer übernimmt, wenn sie frei ist. Ein Monitor behält seine Arbeitsbereiche, wenn du ihn trennst: Sie schließen sich denen eines anderen Bildschirms an, nummeriert nach denen, die er bereits hat, und kehren unter ihren alten Nummern zurück, wenn der Monitor wieder da ist.

Wenn du `Super` gedrückt hältst und mit der Maus auf ein Fenster klickst, kannst du seine Position neu anordnen. Wenn du `Super` gedrückt hältst und die rechte Maustaste verwendest, kannst du die Fenstergröße frei ändern.

Du schließt ein Fenster mit `Super + W` oder `Super + Q` (und alle Fenster mit `Ctrl + Alt + Delete`).

Du kannst auch mit `Super + F` in den Vollbildmodus gehen oder mit `Super + Alt + F` sogar nur auf volle Breite (unter Beibehaltung der oberen Leiste) oder mit `Super + Ctrl + F` in den Vollbildmodus innerhalb eines Fensters (gut für YouTube!).

### Dwindle- vs. Scrolling-Layout

Das Standardlayout von Omarchy heißt dwindle. Es hält alle Fenster, die du auf einem einzelnen Arbeitsbereich öffnest, jederzeit sichtbar, selbst wenn es sie dafür verkleinern muss.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aber du kannst einen Arbeitsbereich auch in das Scrolling-Layout verwandeln, bei dem die Fenster nebeneinander aufgereiht sind, über den sichtbaren Rand des Bildschirms hinaus. Du verwandelst einen einzelnen Arbeitsbereich mit `Super + L` in dieses Layout.

Erneutes Drücken von `Super + L` macht den Arbeitsbereich schwebend, wo sich Fenster frei überlappen und du sie selbst platzierst, und ein drittes Drücken bringt ihn zurück zu dwindle. `Super + Alt + L` durchläuft sie in der anderen Richtung. Ein Fenster, das ohnehin schwebt — eines, das du mit `Super + T` herausgelöst hast, oder eine App, die immer schwebend öffnet — bleibt schwebend, wenn der Arbeitsbereich zurück zum Tiling wechselt. Die obere Leiste kennzeichnet den Arbeitsbereich, auf dem du dich befindest, mit seinem Layout: ein Quadrat für dwindle, ein Kreis für Scrolling und ein Dreieck für schwebend. Ein Klick auf diese Kennzeichnung durchläuft ebenfalls das Layout, ebenso wie die Display-Taste an Laptops, die eine haben.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Die Auswahl gilt pro Arbeitsbereich und bleibt bestehen. So kannst du Arbeitsbereich 1 auf dwindle fürs Surfen und Arbeitsbereich 2 auf Scrolling für Code lassen, und sie kommen nach einem Neustart so wieder zurück.

Wenn du das Scrolling-Layout als Standard verwenden möchtest, kannst du das in `~/.config/hypr/looknfeel.lua` einstellen:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Schwebende Arbeitsbereiche

Ein schwebender Arbeitsbereich funktioniert wie ein traditioneller Desktop: Fenster überlappen sich, und du verschiebst und skalierst sie selbst. Jedes Fenster bekommt eine Titelleiste in den Farben deines Themes mit Schaltflächen zum Minimieren, Maximieren und Schließen. `Super + M` minimiert auch das fokussierte Fenster. Ein minimiertes Fenster wartet im Dock; klicke auf seine App, um es zurückzuholen. Klicke auf ein Fenster, um es in den Vordergrund zu bringen. Ändere seine Größe von jeder Kante oder Ecke aus. Doppelklicke auf eine Titelleiste, um das Fenster zu maximieren und dabei die obere Leiste sichtbar zu lassen, und erneut, um seine alte Größe zurückzubekommen. Chrome und andere auf Chromium basierende Browser, Disks und Document Viewer überspringen die Titelleiste und verwenden stattdessen ihre eigene Kopfzeile; `Super + Alt + F` maximiert sie, und `Super + M` minimiert sie.

Jeder Arbeitsbereich hat ein Dock mit deinen angehefteten Apps, allem, was gerade läuft, und einem Raster aller Apps hinter der Apps-Schaltfläche, die auch `Super + Alt + Space` und _Apps_ im Omarchy-Menü öffnen. Klicke mit der rechten Maustaste auf eine App im Raster oder drücke `Delete`, um sie zu deinstallieren. Klicke auf eine App, um sie zu öffnen oder ihr Fenster in den Vordergrund zu bringen; klicke erneut, um durch ihre Fenster zu wechseln. Files bringt nur ein Fenster vom Arbeitsbereich zurück, auf dem du dich befindest, und öffnet andernfalls ein neues, und Terminal und Agent starten immer ein weiteres, wobei ein minimiertes Fenster jedoch zuerst zurückkommt. Ein Mittelklick öffnet ein neues Fenster. Ziehe ein Symbol entlang des Docks, um es zu verschieben; eine laufende App zwischen die anderen zu ziehen, behält sie dort. Klicke mit der rechten Maustaste, um eine App im Dock zu behalten, sie herauszunehmen oder sie zu beenden. Das Dock bleibt sichtbar, solange ein Arbeitsbereich leer ist, und sobald der Arbeitsbereich ein Fenster hat, verbirgt es sich, bis der Zeiger seinen Rand erreicht. Ein Vollbildfenster verbirgt es vollständig. Ziehe die Apps-Schaltfläche in Richtung eines anderen Bildschirmrands, um das Dock dorthin zu verschieben. Klicke sie mit der rechten Maustaste für _Position_, um eine Kante zu wählen, _Layout_, um das Standardlayout so einzustellen, wie es _Appearance > Workspace Layout_ tut, und _Visibility_, um das Dock immer eingeschaltet zu lassen, es von der ersten App verbergen zu lassen oder es immer verborgen zu halten. `omarchy dock visibility always` stellt das von einem Terminal aus ein. Die Position befindet sich auch unter _Appearance > Dock > Dock Position_, und `omarchy dock position left` stellt sie von einem Terminal aus ein. Apps, die du im Dock behältst, sind ausgegraut, solange sie nicht laufen. Um das Dock auf schwebende Arbeitsbereiche zu beschränken, verwende _Appearance > Dock > Dock Only on Floating_ oder `omarchy dock tiling off`.

Neue Arbeitsbereiche und alle, denen du mit `Super + L` kein eigenes Layout gegeben hast, verwenden das Standardlayout. Das Ändern des Standards setzt jeden Arbeitsbereich ohne Fenster darauf zurück, während einer mit Fenstern darauf das Layout behält, das er hat. Ein ins Dock minimiertes Fenster zählt weiterhin als Fenster auf dem Arbeitsbereich, den es verlassen hat. Wähle es unter _Appearance > Workspace Layout_: Tiling, Scrolling oder Floating. `omarchy hyprland workspace layout default scrolling` stellt es von einem Terminal aus ein.

### Fenster gruppieren

Fenster können mit `Super + G` gruppiert werden. Sobald du in einer Gruppe bist, gehört jedes Fenster, das du startest, solange diese aktiv ist, zur Gruppe. Du kannst dich mit `Super + Ctrl + Arrow Left/Right` zwischen diesen gruppierten Fenstern bewegen oder mit `Super + Alt + 1/2/3/4` direkt zu gruppierten Fenstern in der Reihenfolge gehen.

Du kannst ein Fenster mit `Super + Alt + G` aus der Gruppierung herausbewegen oder die gesamte Gruppe auflösen, indem du erneut `Super + G` drückst. Schließlich kannst du Fenster außerhalb der Gruppe mit `Super + Alt + Arrows` in sie hineinbewegen.

### Fenster herauslösen

Du kannst ein Fenster mit `Super + O` aus seiner Arbeitsbereich-Zuordnung herauslösen. Das heftet es als schwebendes Fenster an, das dir folgt, auf welchen Arbeitsbereich du auch gehst. Großartig für Videoplayer und dergleichen.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-Arbeitsbereich

Es gibt einen speziellen Scratchpad-Arbeitsbereich in voller Größe, der über dem Arbeitsbereich liegt, auf dem du dich gerade befindest. Du greifst mit `Super + S` auf das zu, was sich darauf befindet, und platzierst Fenster dort mit `Super + Alt + S`.

Er eignet sich gut für Steuerelemente oder ein Terminal, mit dem du schnell interagieren willst, ohne den aktuellen Arbeitsbereich zu verlassen.

### Quake-Konsole

Schließlich gibt es eine Quake-Konsole mit halber Höhe, die über dem Arbeitsbereich herunterklappt, auf dem du dich gerade befindest. Schalte sie mit `Super + the key above Tab` um (Gravis auf US-Layouts) und platziere ein Fenster dort mit `Super + Shift + the key above Tab`.

Beim ersten Öffnen startet sie deinen Standard-Agenten oder bittet dich, einen auszuwählen, wenn du noch keinen gewählt hast. Solange die Konsole ein einzelnes Fenster enthält, klappt sie als zentriertes Panel herunter, statt sich über den Bildschirm zu erstrecken. Stelle eine zweite App darauf, und sie geht zurück auf die volle Breite, sodass die beiden Platz haben, nebeneinander zu sitzen.

Um ein Fenster entweder vom Scratchpad oder von der Konsole zu entfernen, sende es direkt auf einen anderen Arbeitsbereich, etwa mit `Super + Shift + 1`.

### Daran muss man sich erst gewöhnen!

Es dauert eine Weile, sich an die Navigation auf deinem Desktop auf diese Weise zu gewöhnen, aber sobald du es tust, wird es schwer sein, zu einem traditionellen mausgesteuerten Desktop-Erlebnis zurückzukehren!
