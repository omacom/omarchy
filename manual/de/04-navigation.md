# Navigation

Alles in Omarchy läuft über die Tastatur — _ALLES!_ Wenn das System zum ersten Mal startet, kannst du buchstäblich nichts allein mit der Maus machen. Aber du kannst `Super + Space` drücken, um das Omarchy Menu zu öffnen, und von hier aus kannst du so gut wie alles machen.

Aber das Omarchy-Menü soll die meiste Zeit nicht einmal der Hauptweg sein, um das System zu bedienen. Wir können schneller sein als das! Alle wichtigsten Anwendungen sind direkt an einzelne Hotkeys gebunden. Du startest das Terminal mit `Super + Return` und einen Browser mit `Super + Shift + Return`. Probiere eins nach dem anderen aus, und du wirst die Magie des Tilings von Hyprland in Aktion sehen:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kannst dann `Super + J` drücken, um sie übereinander statt nebeneinander zu stapeln:

 ![navigation-stacked](images/navigation-stacked.webp)

Drücke erneut `Super + J`, um sie wieder in ihre nebeneinanderliegenden Positionen zu bringen. Probiere dann `Super + Shift + Arrow Right`, während du im Browser bist, um die Fenster zu tauschen.

Probiere jetzt `Super + Shift + T`, um den Activity monitor zu starten. Das erscheint als schwebendes Fenster. Du kannst es mit `Super + T` tilen (und das erneut drücken, um es wieder schwebend zu machen). Drücke jetzt `Super + Shift + F`, um den Dateimanager zu öffnen. Du erhältst ein sauberes Vierfach-Layout:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigierst mit `Super + Arrow` zu dem Fenster, das aktiv sein soll. Das wechselt den Fokus und bewegt den Cursor in die Mitte der neuen Anwendung. Am Rand eines Bildschirms geht es weiter zum Monitor auf dieser Seite.

Wenn du `Super + Shift + 2` drückst, verschiebst du die aktuell fokussierte Anwendung auf den zweiten Workspace. `Super + Shift + 1` verschiebt sie zurück. (Und `Super + Shift + Alt + 2` verschiebt die aktuell fokussierte Anwendung auf den zweiten Workspace, ohne zu ihm zu wechseln).

Mit mehr als einem Monitor hat jeder Monitor seine eigenen Workspaces 1 bis 10. `Super + 2` geht zum zweiten Workspace des Monitors, auf dem du bist, und die obere Leiste jedes Monitors zeigt seine eigenen Workspaces und den, den er gerade anzeigt. `Super + Tab` durchläuft die Workspaces auf dem Monitor, auf dem du bist. `Super + Shift + Ctrl + Arrows` verschiebt das Fenster, auf dem du bist, auf den Monitor in dieser Richtung, auf den Workspace, den er gerade anzeigt, und `Super + Shift + Alt + Arrows` verschiebt den Workspace, auf dem du bist, auf den Monitor in dieser Richtung, wo er dieselbe Nummer übernimmt, wenn sie frei ist. Ein Monitor behält seine Workspaces, wenn du ihn absteckst: Sie schließen sich denen eines anderen Bildschirms an, nummeriert nach denen, die er bereits hat, und gehen unter ihren alten Nummern zurück, wenn der Monitor zurückkommt.

Wenn du `Super` gedrückt hältst und mit der Maus auf ein Fenster klickst, kannst du neu anordnen, wo es sitzt. Wenn du `Super` gedrückt hältst und die rechte Maustaste verwendest, kannst du die Größe des Fensters frei ändern.

Du schließt ein Fenster mit `Super + W` oder `Super + Q` (und alle Fenster mit `Ctrl + Alt + Delete`).

Du kannst auch mit `Super + F` in den Vollbildmodus gehen oder mit `Super + Alt + F` sogar nur auf volle Breite (wobei die obere Leiste bleibt) oder mit `Super + Ctrl + F` in den Vollbildmodus innerhalb eines Fensters (gut für YouTube!).

### Dwindle vs. Scrolling-Layout

Omarchys Standardlayout heißt dwindle. Es hält alle Fenster, die du auf einem einzelnen Workspace öffnest, jederzeit sichtbar, selbst wenn es sie dafür verkleinern muss.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aber du kannst einen Workspace auch in das Scrolling-Layout verwandeln, in dem Fenster nebeneinander aufgereiht sind, über den sichtbaren Rand des Displays hinaus. Du verwandelst einen einzelnen Workspace mit `Super + L` in dieses Layout.

Erneutes Drücken von `Super + L` macht den Workspace floating, wobei Fenster sich frei überlappen und du sie selbst platzierst, und ein drittes Drücken bringt ihn zurück zu dwindle. `Super + Alt + L` geht in die andere Richtung durch sie hindurch. Ein Fenster, das ohnehin schwebt — eines, das du mit `Super + T` herausgelöst hast, oder eine App, die immer schwebend öffnet — bleibt schwebend, wenn der Workspace zurück zum Tiling geht. Die obere Leiste markiert den Workspace, auf dem du bist, mit seinem Layout: ein Quadrat für dwindle, ein Kreis für scrolling und ein Dreieck für floating. Klicken auf diese Markierung wechselt das Layout ebenfalls durch.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Die Wahl gilt pro Workspace und bleibt bestehen. So kannst du Workspace 1 auf dwindle zum Surfen und Workspace 2 auf scrolling für Code lassen, und sie kommen nach einem Neustart so zurück.

Wenn du das Scrolling-Layout als Standard verwenden möchtest, kannst du das in `~/.config/hypr/looknfeel.lua` einstellen:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Schwebende Workspaces

Ein schwebender Workspace funktioniert wie ein traditioneller Desktop: Fenster überlappen sich, und du verschiebst sie und änderst ihre Größe selbst. Jedes Fenster bekommt eine Titelleiste in den Farben deines Themes, mit Schaltflächen zum Minimieren, Maximieren und Schließen. `Super + M` minimiert auch das fokussierte Fenster. Ein minimiertes Fenster wartet im Dock; klicke auf seine App, um es zurückzubringen. Klicke auf ein Fenster, um es nach vorne zu bringen. Ändere seine Größe von jeder Kante oder Ecke aus. Doppelklicke auf eine Titelleiste, um das Fenster zu maximieren, während die obere Leiste sichtbar bleibt, und erneut, um seine alte Größe zurückzubekommen. Chrome und andere Chromium-basierte Browser, Disks und Document Viewer überspringen die Titelleiste und verwenden stattdessen ihre eigene Kopfzeile; `Super + Alt + F` maximiert sie, und `Super + M` minimiert sie.

Ein schwebender Workspace zeigt auch ein Dock mit deinen angehefteten Apps, allem, was gerade läuft, und einem Raster jeder App hinter der Apps-Schaltfläche, das `Super + Alt + Space` und _Apps_ im Omarchy-Menü ebenfalls öffnen. Klicke mit der rechten Maustaste auf eine App im Raster oder drücke `Delete`, um sie zu deinstallieren. Klicke auf eine App, um sie zu öffnen oder ihr Fenster nach vorne zu bringen; klicke erneut, um durch ihre Fenster zu wechseln. Files bringt nur ein Fenster vom Workspace zurück, auf dem du bist, und öffnet andernfalls ein neues, und Terminal und Agent starten immer ein weiteres, wobei ein minimiertes Fenster aber zuerst zurückkommt. Mittelklick öffnet ein neues Fenster. Ziehe ein Symbol entlang des Docks, um es zu verschieben; ziehst du eine laufende App zwischen die anderen, bleibt sie dort. Klicke mit der rechten Maustaste, um eine App im Dock zu behalten, sie zu entfernen oder sie zu beenden. Das Dock weicht einem Vollbildfenster aus dem Weg. Klicke mit der rechten Maustaste auf die Apps-Schaltfläche, um das Dock an eine andere Kante zu verschieben oder es auszublenden, bis der Zeiger seine Kante erreicht. Die Position steht auch unter _Appearance > Dock > Dock Position_, und `omarchy dock position left` und `omarchy dock autohide on` stellen beides von einem Terminal aus ein. Apps, die du im Dock behältst, sind ausgeblasst, solange sie nicht laufen.

Neue Workspaces und alle, denen du mit `Super + L` kein eigenes Layout gegeben hast, verwenden das Standardlayout. Das Ändern des Standards setzt jeden Workspace ohne Fenster darauf zurück, während einer mit Fenstern darauf das Layout behält, das er hat. Ein ins Dock minimiertes Fenster zählt weiterhin als Fenster auf dem Workspace, den es verlassen hat. Wähle es unter _Appearance > Workspace Layout_: Tiling, Scrolling oder Floating. `omarchy-hyprland-workspace-layout-default scrolling` stellt es von einem Terminal aus ein.

### Fenster gruppieren

Fenster können mit `Super + G` gruppiert werden. Sobald du in einer Gruppe bist, gehört jedes Fenster, das du startest, solange das aktiv ist, zur Gruppe. Du kannst dich zwischen diesen gruppierten Fenstern mit `Super + Ctrl + Arrow Left/Right` bewegen oder mit `Super + Alt + 1/2/3/4`, um direkt in Reihenfolge zu gruppierten Fenstern zu gehen.

Du kannst ein Fenster mit `Super + Alt + G` aus der Gruppierung bewegen oder die gesamte Gruppe auflösen, indem du erneut `Super + G` drückst. Schließlich kannst du Fenster außerhalb der Gruppe mit `Super + Alt + Arrows` in sie hinein verschieben.

### Fenster herauslösen

Du kannst ein Fenster mit `Super + O` aus seiner Workspace-Zuordnung herauslösen. Das heftet es als schwebendes Fenster an, das dir folgt, auf welchen Workspace du auch gehst. Großartig für Videoplayer und dergleichen.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-Workspace

Es gibt einen speziellen Scratchpad-Workspace in voller Größe, der sich über den Workspace legt, auf dem du gerade bist. Du greifst mit `Super + S` auf das zu, was auf ihm ist, und du platzierst Fenster dort mit `Super + Alt + S`.

Es funktioniert gut für Steuerungen oder ein Terminal, mit dem du schnell interagieren willst, ohne den aktuellen Workspace zu verlassen.

### Quake-Konsole

Schließlich gibt es eine Quake-Konsole mit halber Höhe, die über dem Workspace herunterklappt, auf dem du gerade bist. Schalte sie mit `Super + Grave` um, und platziere ein Fenster dort mit `Super + Shift + Grave`.

Sie öffnet sich mit deinem Standard-Agenten bereit zum Loslegen. Solange die Konsole ein einziges Fenster enthält, klappt sie als zentriertes Panel herunter, statt den Bildschirm zu überspannen. Platziere eine zweite App darauf, und sie geht zurück zur vollen Breite, sodass die beiden Platz haben, nebeneinander zu sitzen.

Um ein Fenster entweder vom Scratchpad oder von der Konsole zu bewegen, schicke es direkt auf einen anderen Workspace mit etwas wie `Super + Shift + 1`.

### Es braucht etwas Gewöhnung!

Es dauert eine Weile, sich daran zu gewöhnen, deinen Desktop so zu navigieren, aber sobald du es tust, wird es schwer sein, zu einem traditionellen mausgesteuerten Desktop-Erlebnis zurückzukehren!
