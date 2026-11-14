# Navigation

Alles in Omarchy läuft über die Tastatur — _ALLES!_ Wenn das System zum ersten Mal startet, kannst du buchstäblich nichts allein mit der Maus tun. Aber du kannst `Super + Space` drücken, um das Omarchy-Menü einzublenden, und von hier aus kannst du so gut wie alles tun.

Aber das Omarchy-Menü ist nicht einmal als die Hauptart gedacht, das System die meiste Zeit zu bedienen. Wir können schneller sein als das! Alle wichtigsten Anwendungen sind direkt an einzelne Tastenkürzel gebunden. Du startest das Terminal mit `Super + Return` und einen Browser mit `Super + Shift + Return`. Probier das eine nach dem anderen aus, und du siehst die Magie des Tilings von Hyprland in Aktion:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Dann kannst du `Super + J` drücken, um sie übereinander zu stapeln statt nebeneinander:

 ![navigation-stacked](images/navigation-stacked.webp)

Drücke erneut `Super + J`, um sie wieder nebeneinander zu bringen. Probier dann `Super + Shift + Arrow Right`, während du im Browser bist, um die Fenster zu tauschen.

Probier jetzt `Super + Shift + T`, um den Aktivitätsmonitor zu starten. Der erscheint als schwebendes Fenster. Du kannst ihn mit `Super + T` ins Tiling einfügen (und das erneut drücken, damit er wieder schwebt). Drücke jetzt `Super + Shift + F`, um den Dateimanager zu öffnen. Du erhältst ein sauberes Vierer-Setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigierst mit `Super + Arrow` zwischen den Fenstern, die aktiv sein sollen. Das wechselt den Fokus und bewegt den Cursor in die Mitte der neuen Anwendung. Am Rand eines Bildschirms geht es weiter zum Monitor auf dieser Seite.

Wenn du `Super + Shift + 2` drückst, verschiebst du die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich. `Super + Shift + 1` verschiebt sie zurück. (Und `Super + Shift + Alt + 2` verschiebt die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich, ohne dorthin zu wechseln).

Bei mehr als einem Monitor hat jeder Monitor seine eigenen Arbeitsbereiche 1 bis 10. `Super + 2` geht zum zweiten Arbeitsbereich des Monitors, auf dem du dich befindest, und die obere Leiste jedes Monitors zeigt seine eigenen Arbeitsbereiche und den, den er gerade zeigt. `Super + Tab` durchläuft die Arbeitsbereiche auf dem Monitor, auf dem du dich befindest. `Super + Shift + Ctrl + Arrows` verschiebt das Fenster, auf dem du dich befindest, auf den Monitor in dieser Richtung, auf den Arbeitsbereich, den er zeigt, und `Super + Shift + Alt + Arrows` verschiebt den Arbeitsbereich, auf dem du dich befindest, auf den Monitor in dieser Richtung, wo er dieselbe Nummer übernimmt, falls sie frei ist. Ein Monitor behält seine Arbeitsbereiche, wenn du ihn absteckst: Sie wechseln zu einem anderen Bildschirm, nummeriert nach den Arbeitsbereichen, die dieser bereits hat, und kehren unter ihren alten Nummern zurück, wenn der Monitor wieder da ist.

Wenn du `Super` gedrückt hältst und mit der Maus auf ein Fenster klickst, kannst du seine Position neu anordnen. Wenn du `Super` gedrückt hältst und die rechte Maustaste benutzt, kannst du die Größe des Fensters frei ändern.

Du schließt ein Fenster mit `Super + W` oder `Super + Q` (und schließt alle Fenster mit `Ctrl + Alt + Delete`).

Du kannst auch mit `Super + F` in den Vollbildmodus gehen oder mit `Super + Alt + F` sogar nur auf volle Breite (wobei die obere Leiste bleibt) oder mit `Super + Ctrl + F` in den Vollbildmodus innerhalb eines Fensters (gut für YouTube!).

### Dwindle vs. Scrolling-Layout

Das Standardlayout von Omarchy heißt dwindle. Es hält alle Fenster, die du auf einem einzelnen Arbeitsbereich öffnest, jederzeit sichtbar, selbst wenn es sie dafür verkleinern muss.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aber du kannst einen Arbeitsbereich auch in das Scrolling-Layout verwandeln, in dem Fenster nebeneinander aufgereiht sind, über den sichtbaren Rand der Anzeige hinaus. Du verwandelst einen einzelnen Arbeitsbereich mit `Super + L` in dieses Layout.

Erneut `Super + L` zu drücken macht den Arbeitsbereich schwebend, wo Fenster frei überlappen und du sie selbst platzierst, und ein drittes Drücken bringt ihn zurück zu dwindle. `Super + Alt + L` durchläuft sie in der anderen Richtung. Ein Fenster, das ohnehin schwebt — eines, das du mit `Super + T` herausgelöst hast, oder eine App, die immer schwebend öffnet — bleibt schwebend, wenn der Arbeitsbereich zurück zum Tiling wechselt. Die obere Leiste kennzeichnet den Arbeitsbereich, auf dem du dich befindest, mit seinem Layout: ein Quadrat für dwindle, ein Kreis für Scrolling und ein Dreieck für schwebend. Ein Klick auf dieses Zeichen durchläuft das Layout ebenfalls.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Die Auswahl gilt pro Arbeitsbereich und bleibt bestehen. So kannst du Arbeitsbereich 1 auf dwindle zum Surfen und Arbeitsbereich 2 auf Scrolling für Code behalten, und sie kommen nach einem Neustart so wieder.

Wenn du das Scrolling-Layout als Standard verwenden möchtest, kannst du das in `~/.config/hypr/looknfeel.lua` einstellen:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Schwebende Arbeitsbereiche

Ein schwebender Arbeitsbereich funktioniert wie ein traditioneller Desktop: Fenster überlappen, und du verschiebst und skalierst sie selbst. Jedes Fenster bekommt eine Titelleiste in den Farben deines Themes, mit Schaltflächen zum Minimieren, Maximieren und Schließen. `Super + M` minimiert auch das fokussierte Fenster. Ein minimiertes Fenster wartet im Dock; klicke auf seine App, um es zurückzuholen. Klicke auf ein Fenster, um es nach vorne zu bringen. Ändere seine Größe an einer beliebigen Kante oder Ecke. Doppelklicke auf eine Titelleiste, um das Fenster zu maximieren und dabei die obere Leiste sichtbar zu lassen, und erneut, um seine alte Größe zurückzubekommen. Chrome und andere auf Chromium basierende Browser, Disks und Document Viewer überspringen die Titelleiste und verwenden stattdessen ihre eigene Kopfzeile; `Super + Alt + F` maximiert sie, und `Super + M` minimiert sie.

Ein schwebender Arbeitsbereich zeigt auch ein Dock, mit deinen angehefteten Apps, allem, was gerade läuft, und einem Raster jeder App hinter der Apps-Schaltfläche, die auch `Super + Alt + Space` und _Apps_ im Omarchy-Menü öffnen. Klicke mit der rechten Maustaste auf eine App im Raster oder drücke `Delete`, um sie zu deinstallieren. Klicke auf eine App, um sie zu öffnen oder ihr Fenster nach vorne zu bringen; klicke erneut, um ihre Fenster zu durchlaufen. Ein Mittelklick öffnet ein neues Fenster. Ziehe ein Symbol entlang des Docks, um es zu verschieben; eine laufende App zwischen die anderen zu ziehen behält sie dort. Klicke mit der rechten Maustaste, um eine App im Dock zu behalten, sie herauszunehmen oder sie zu beenden. Das Dock macht einem Vollbildfenster Platz. Klicke mit der rechten Maustaste auf die Apps-Schaltfläche, um das Dock an eine andere Kante zu verschieben oder es auszublenden, bis der Zeiger seine Kante erreicht. Die Position befindet sich auch unter _Appearance > Dock > Dock Position_, und `omarchy dock position left` und `omarchy dock autohide on` stellen beides von einem Terminal aus ein. Apps, die du im Dock behältst, sind ausgeblendet, solange sie nicht laufen.

Neue Arbeitsbereiche und alle, denen du mit `Super + L` kein eigenes Layout gegeben hast, verwenden das Standardlayout. Das Ändern des Standards setzt jeden Arbeitsbereich ohne Fenster darauf zurück, während einer mit Fenstern darauf das Layout behält, das er hat. Ein Fenster, das ins Dock minimiert wurde, zählt immer noch als Fenster auf dem Arbeitsbereich, den es verlassen hat. Wähle es unter _Appearance > Workspace Layout_: Tiling, Scrolling oder Floating. `omarchy-hyprland-workspace-layout-default scrolling` stellt es von einem Terminal aus ein.

### Fenster gruppieren

Fenster können mit `Super + G` gruppiert werden. Sobald du in einer Gruppe bist, gehört jedes Fenster, das du startest, während diese aktiv ist, zur Gruppe. Du kannst mit `Super + Ctrl + Arrow Left/Right` zwischen diesen gruppierten Fenstern wechseln oder mit `Super + Alt + 1/2/3/4` direkt zu gruppierten Fenstern in der Reihenfolge gehen.

Du kannst ein Fenster mit `Super + Alt + G` aus der Gruppierung herausnehmen oder die gesamte Gruppe auflösen, indem du erneut `Super + G` drückst. Schließlich kannst du Fenster außerhalb der Gruppe mit `Super + Alt + Arrows` in sie hinein verschieben.

### Fenster herauslösen

Du kannst ein Fenster mit `Super + O` aus seiner Arbeitsbereichszuordnung herauslösen. Das heftet es als schwebendes Fenster an, das dir auf jeden Arbeitsbereich folgt, auf den du gehst. Großartig für Videoplayer und dergleichen.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-Arbeitsbereich

Es gibt einen speziellen Scratchpad-Arbeitsbereich in voller Größe, der sich über den Arbeitsbereich legt, auf dem du dich gerade befindest. Du greifst mit `Super + S` auf das zu, was sich darauf befindet, und platzierst Fenster dort mit `Super + Alt + S`.

Er eignet sich gut für Bedienelemente oder ein Terminal, mit dem du schnell interagieren willst, ohne den aktuellen Arbeitsbereich zu verlassen.

### Quake-Konsole

Schließlich gibt es eine Quake-Konsole in halber Höhe, die über den Arbeitsbereich herunterklappt, auf dem du dich gerade befindest. Schalte sie mit `Super + Grave` um und platziere ein Fenster dort mit `Super + Shift + Grave`.

Sie öffnet sich mit deinem Standard-Agenten, bereit loszulegen. Solange die Konsole ein einzelnes Fenster enthält, klappt sie als zentriertes Panel herunter, statt sich über den Bildschirm zu spannen. Platziere eine zweite App darauf, und sie geht zurück auf die volle Breite, damit die beiden Platz haben, nebeneinander zu sitzen.

Um ein Fenster entweder vom Scratchpad oder von der Konsole weg zu verschieben, sende es direkt auf einen anderen Arbeitsbereich mit etwas wie `Super + Shift + 1`.

### Daran muss man sich erst gewöhnen!

Es dauert eine Weile, sich daran zu gewöhnen, den Desktop so zu navigieren, aber sobald du es tust, wird es schwer sein, zu einem traditionellen, mausgesteuerten Desktop-Erlebnis zurückzukehren!
