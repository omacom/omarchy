# Navigation

Alles in Omarchy passiert über die Tastatur — _ALLES!_ Wenn das System zum ersten Mal startet, kannst du buchstäblich nichts allein mit der Maus machen. Aber du kannst `Super + Space` drücken, um das Omarchy-Menü einzublenden, und von hier aus kannst du so gut wie alles machen.

Aber das Omarchy-Menü ist die meiste Zeit nicht einmal als Hauptweg gedacht, um das System zu bedienen. Wir können schneller sein als das! Alle wichtigsten Anwendungen sind direkt an einzelne Hotkeys gebunden. Du startest das Terminal mit `Super + Return` und einen Browser mit `Super + Shift + Return`. Probiere eins nach dem anderen aus, und du wirst die Magie von Hyprlands Tiling in Aktion sehen:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Du kannst dann `Super + J` drücken, um sie übereinander statt nebeneinander zu stapeln:

 ![navigation-stacked](images/navigation-stacked.webp)

Drücke erneut `Super + J`, um sie wieder nebeneinander zu bringen. Probiere dann `Super + Shift + Arrow Right`, während du im Browser bist, um die Fenster zu tauschen.

Probiere jetzt `Super + Shift + T`, um den Aktivitätsmonitor zu starten. Der erscheint als schwebendes Fenster. Du kannst ihn mit `Super + T` kacheln (und das erneut drücken, damit er wieder schwebt). Drücke jetzt `Super + Shift + F`, um den Dateimanager zu öffnen. Du erhältst ein sauberes Vierfach-Setup:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Du navigierst mit `Super + Arrow` zwischen den Fenstern, die du aktiv haben willst. Das wechselt den Fokus und bewegt den Cursor in die Mitte der neuen Anwendung. Am Bildschirmrand geht es weiter zum Monitor auf dieser Seite.

Wenn du `Super + Shift + 2` drückst, bewegst du die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich. `Super + Shift + 1` bewegt sie zurück. (Und `Super + Shift + Alt + 2` bewegt die aktuell fokussierte Anwendung auf den zweiten Arbeitsbereich, ohne zu ihm zu wechseln).

Bei mehr als einem Monitor hat jeder Monitor seine eigenen Arbeitsbereiche 1 bis 10. `Super + 2` wechselt zum zweiten Arbeitsbereich des Monitors, auf dem du bist, und die obere Leiste jedes Monitors zeigt seine eigenen Arbeitsbereiche und den, den er gerade zeigt. `Super + Tab` durchläuft die Arbeitsbereiche auf dem Monitor, auf dem du bist. `Super + Shift + Ctrl + Arrows` bewegt das Fenster, auf dem du bist, zum Monitor in dieser Richtung, auf den Arbeitsbereich, den er gerade zeigt, und `Super + Shift + Alt + Arrows` bewegt den Arbeitsbereich, auf dem du bist, hinüber zum Monitor in dieser Richtung, wo er dieselbe Nummer übernimmt, wenn sie frei ist. Ein Monitor behält seine Arbeitsbereiche, wenn du ihn absteckst: Sie schließen sich denen eines anderen Bildschirms an, nummeriert nach denen, die er bereits hat, und kehren unter ihren alten Nummern zurück, wenn der Monitor wieder da ist.

Wenn du `Super` gedrückt hältst und mit der Maus auf ein Fenster klickst, kannst du seine Position neu anordnen. Wenn du `Super` hältst und die rechte Maustaste verwendest, kannst du das Fenster frei in der Größe ändern.

Du schließt ein Fenster mit `Super + W` oder `Super + Q` (und alle Fenster mit `Ctrl + Alt + Delete`).

Du kannst auch mit `Super + F` in den Vollbildmodus gehen oder mit `Super + Alt + F` nur auf volle Breite (wobei die obere Leiste bleibt) oder mit `Super + Ctrl + F` ins Vollbild innerhalb eines Fensters (gut für YouTube!).

### Dwindle vs. Scrolling-Layout

Das Standardlayout von Omarchy heißt dwindle. Es hält alle Fenster, die du auf einem einzelnen Arbeitsbereich öffnest, jederzeit sichtbar, selbst wenn es sie dafür verkleinern muss.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aber du kannst einen Arbeitsbereich auch in das Scrolling-Layout verwandeln, in dem Fenster nebeneinander aufgereiht sind, über den sichtbaren Rand des Displays hinaus. Einen einzelnen Arbeitsbereich versetzt du mit `Super + L` in dieses Layout.

Erneutes Drücken von `Super + L` macht den Arbeitsbereich floating, wo Fenster frei überlappen und du sie selbst platzierst, und ein dritter Druck bringt ihn zu dwindle zurück. `Super + Alt + L` durchläuft sie in der anderen Richtung. Ein Fenster, das ohnehin schwebt — eines, das du mit `Super + T` herausgelöst hast, oder eine App, die immer schwebend öffnet — bleibt schwebend, wenn der Arbeitsbereich zum Tiling zurückkehrt. Die obere Leiste markiert den Arbeitsbereich, auf dem du bist, mit seinem Layout: ein Quadrat für dwindle, ein Kreis für scrolling und ein Dreieck für floating. Ein Klick auf diese Markierung durchläuft das Layout ebenfalls.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Die Wahl gilt pro Arbeitsbereich, und sie bleibt bestehen. So kannst du Arbeitsbereich 1 fürs Browsen auf dwindle und Arbeitsbereich 2 für Code auf scrolling lassen, und sie kommen nach einem Neustart genau so zurück.

Wenn du das Scrolling-Layout als Standard verwenden willst, kannst du das in `~/.config/hypr/looknfeel.lua` einstellen:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Schwebende Arbeitsbereiche

Ein schwebender Arbeitsbereich funktioniert wie ein traditioneller Desktop: Fenster überlappen, und du bewegst und skalierst sie selbst. Jedes Fenster bekommt eine Titelleiste in den Farben deines Themes, mit Schaltflächen zum Minimieren, Maximieren und Schließen. `Super + M` minimiert auch das fokussierte Fenster. Ein minimiertes Fenster wartet im Dock; klicke auf seine App, um es zurückzuholen. Klicke auf ein Fenster, um es nach vorne zu bringen. Ändere seine Größe von jeder Kante oder Ecke aus. Doppelklicke auf eine Titelleiste, um das Fenster zu maximieren, während die obere Leiste sichtbar bleibt, und erneut, um seine alte Größe zurückzubekommen.

Ein schwebender Arbeitsbereich zeigt auch ein Dock, mit deinen angehefteten Apps, allem, was gerade läuft, und einem Raster jeder App hinter der Apps-Schaltfläche, das `Super + Alt + Space` und _Apps_ im Omarchy-Menü ebenfalls öffnen. Klicke mit der rechten Maustaste auf eine App im Raster, oder drücke `Delete`, um sie zu deinstallieren. Klicke auf eine App, um sie zu öffnen oder ihr Fenster nach vorne zu bringen; klicke erneut, um durch ihre Fenster zu durchlaufen. Ein Mittelklick öffnet ein neues Fenster. Ziehe ein Symbol entlang des Docks, um es zu verschieben; eine laufende App zwischen die anderen zu ziehen, hält sie dort. Klicke mit der rechten Maustaste, um eine App im Dock zu behalten, sie zu entfernen oder sie zu beenden. Das Dock weicht einem Vollbildfenster aus dem Weg. Klicke mit der rechten Maustaste auf die Apps-Schaltfläche, um das Dock an eine andere Kante zu verschieben oder es auszublenden, bis der Zeiger seine Kante erreicht. Die Position steht auch unter _Appearance > Dock > Dock Position_, und `omarchy dock position left` und `omarchy dock autohide on` stellen beides von einem Terminal aus ein. Apps, die du im Dock behältst, sind verblasst, während sie nicht laufen.

Neue Arbeitsbereiche, und alle, denen du nicht mit `Super + L` ein eigenes Layout gegeben hast, verwenden das Standardlayout. Das Ändern des Standards setzt jeden Arbeitsbereich ohne Fenster darauf zurück, während einer mit Fenstern darauf das Layout behält, das er hat. Ein ins Dock minimiertes Fenster zählt weiterhin als Fenster auf dem Arbeitsbereich, den es verlassen hat. Wähle es unter _Appearance > Workspace Layout_ aus: Tiling, Scrolling oder Floating. `omarchy-hyprland-workspace-layout-default scrolling` stellt es von einem Terminal aus ein.

### Fenster gruppieren

Fenster können mit `Super + G` gruppiert werden. Sobald du in einer Gruppe bist, gehört jedes Fenster, das du startest, während sie aktiv ist, zu der Gruppe. Du kannst dich mit `Super + Ctrl + Arrow Left/Right` zwischen diesen gruppierten Fenstern bewegen oder mit `Super + Alt + 1/2/3/4` direkt zu gruppierten Fenstern in Reihenfolge gehen.

Du kannst ein Fenster mit `Super + Alt + G` aus der Gruppierung bewegen oder die gesamte Gruppe auflösen, indem du erneut `Super + G` drückst. Schließlich kannst du Fenster außerhalb der Gruppe mit `Super + Alt + Arrows` in sie hineinbewegen.

### Fenster herauslösen

Du kannst ein Fenster mit `Super + O` aus seiner Arbeitsbereich-Zuordnung herauslösen. Das heftet es als schwebendes Fenster an, das dir auf jeden Arbeitsbereich folgt, zu dem du wechselst. Großartig für Videoplayer und dergleichen.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-Arbeitsbereich

Es gibt einen speziellen Scratchpad-Arbeitsbereich in voller Größe, der sich über den Arbeitsbereich legt, auf dem du gerade bist. Du greifst mit `Super + S` auf das zu, was auf ihm liegt, und du platzierst Fenster dort mit `Super + Alt + S`.

Er eignet sich gut für Steuerelemente oder ein Terminal, mit dem du schnell interagieren willst, ohne den aktuellen Arbeitsbereich zu verlassen.

### Quake-Konsole

Schließlich gibt es eine Quake-Konsole in halber Höhe, die über dem Arbeitsbereich, auf dem du gerade bist, herunterfährt. Schalte sie mit `Super + Grave` um, und platziere ein Fenster dort mit `Super + Shift + Grave`.

Sie öffnet sich mit deinem Standard-Agenten einsatzbereit. Solange die Konsole ein einzelnes Fenster enthält, fährt sie als zentriertes Panel herunter, statt sich über den Bildschirm zu spannen. Lege eine zweite App darauf, und sie kehrt zur vollen Breite zurück, damit beide Platz haben, nebeneinander zu sitzen.

Um ein Fenster entweder vom Scratchpad oder von der Konsole wegzubewegen, sende es direkt zu einem anderen Arbeitsbereich, mit etwas wie `Super + Shift + 1`.

### Es braucht etwas Gewöhnung!

Es dauert eine Weile, sich daran zu gewöhnen, deinen Desktop so zu navigieren, aber wenn du es einmal getan hast, wird es schwer sein, zu einem traditionellen mausgesteuerten Desktop-Erlebnis zurückzukehren!
