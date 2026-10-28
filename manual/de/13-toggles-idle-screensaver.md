# Schalter, Leerlauf & der Bildschirmschoner

Vieles von dem, was du im Alltag änderst, ist nicht wirklich eine Einstellung. Es ist ein Modus, den du für eine Stunde einschaltest und danach wieder aus: Nachtlicht, während du lange arbeitest, Nicht stören, während du präsentierst, wach bleiben, während du dir etwas ansiehst. Omarchy nennt das Schalter, und sie funktionieren alle gleich — eine Tastenkombination, ein Menüeintrag und ein Befehl, alle betätigen denselben Schalter.

### Das Schalter-Menü

`Super + Ctrl + O` öffnet _Trigger > Toggle_ direkt, oder du gehst über das Omarchy-Menü (`Super + Space`) dorthin. Alles in dieser Liste ist ein Schalter, den du umlegen kannst, ohne darüber nachzudenken, wo der Zustand gespeichert ist. Schalter dafür, wie der Desktop aussieht, sitzen daneben, unter _Appearance_.

Vom Terminal aus sind dieselben Schalter `omarchy toggle <thing>`. Führe `omarchy toggle` allein aus, um die ganze Gruppe zu sehen.

| Schalter | Tastenkombination | Befehl |
| ------ | ------ | ------- |
| Nachtlicht | — | `omarchy toggle nightlight` |
| Benachrichtigungen stummschalten | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Wach bleiben (keine Leerlauf-Sperre) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Absturz-Erfassung | — | `omarchy toggle crash-capture` |
| Bildschirmschoner | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) Theme-Abgleich | — | `omarchy toggle theme sync` |
| Menüleiste | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Die Schalter für Touchpad, Touchscreen und Hybrid GPU befinden sich unter _Trigger > Hardware_ (`Super + Ctrl + H`) statt unter Toggle, da sie nur erscheinen, wenn du diese Hardware tatsächlich hast. Die Schalter für Touchpad und Touchscreen überstehen ein Neuladen von Hyprland — der Name des deaktivierten Geräts wird in einer kleinen Zustandsdatei gespeichert, die Hyprland beim Start liest, um es erneut zu deaktivieren.

_Appearance_ enthält die Menüleiste und Animationen, plus ein paar Dinge, die keine `omarchy toggle`-Befehle sind, sich aber genauso verhalten: die Batterieanzeige in Prozent in der Leiste, das Standard-Layout der Arbeitsbereiche und unter _Windows_ die Fensterabstände (`Super + Shift + Backspace`) und das quadratische Seitenverhältnis bei 1 Fenster (`Super + Ctrl + Backspace`).

Die meisten davon sind einfach eine Flag-Datei unter `~/.local/state/omarchy/toggles/`. Wenn du in einem Skript auf eine davon verzweigen willst, liefert dir `omarchy-toggle-enabled` einen Exit-Code, statt dass du selbst danach suchen musst:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Die Flags sind nach dem Aus-Zustand benannt — `screensaver-off`, `suspend-off`, `bar-off` — ihre Anwesenheit bedeutet also, dass die Funktion deaktiviert ist.

### Indikatoren in der Leiste

Wenn ein Modus aktiv ist, bekommst du ein kleines Symbol in der Mitte der oberen Leiste neben der Uhr. Das ist das Indikatoren-Widget, und es enthält Diktat, Bildschirmaufnahme, ausstehende Erinnerungen, Nachtlicht, Nicht stören und Wach bleiben.

Inaktive Indikatoren sind ausgeblendet. Fahre mit dem Mauszeiger irgendwo über die Leiste, und sie werden abgedunkelt eingeblendet, sodass du einen anklicken kannst, um ihn einzuschalten, ohne seine Tastenkombination zu kennen. Ein Klick auf einen aktiven schaltet ihn wieder aus. Wenn du sie lieber alle ständig sehen willst, setze `alwaysShow` auf `true` beim Eintrag `omarchy.indicators` in `~/.config/omarchy/shell.json` — siehe [die obere Leiste](05-the-top-bar.md) dazu, wie Leisten-Widgets konfiguriert werden.

### Nachtlicht

Das Nachtlicht wärmt den Bildschirm auf 4000K, und erneutes Umschalten stellt ihn wieder auf 6500K zurück. Schalte es über das Schalter-Menü (`Super + Ctrl + O`) oder mit `omarchy toggle nightlight` um. Es wird von hyprsunset gesteuert, das der Schalter für dich startet, falls es nicht bereits läuft.

Standardmäßig macht hyprsunset überhaupt nichts mit deinem Bildschirm. `~/.config/hypr/hyprsunset.conf` wird mit einem Identitätsprofil ausgeliefert, genau damit die Anzeige unberührt bleibt, bis du Wärme verlangst. Wenn du es lieber nach der Uhr schalten willst, ersetze das durch ein Zeitprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Starte hyprsunset dann beim Anmelden, indem du `o.launch_on_start("hyprsunset")` zu `~/.config/hypr/autostart.lua` hinzufügst. Das vom Schalter verwendete 4000K/6500K-Paar ist fest vorgegeben, also ist die Konfigurationsdatei der Ort, an den du gehst, wenn du eine andere Temperatur willst.

### Nicht stören

`Super + Ctrl + Alt + ,` schaltet Benachrichtigungen stumm. Solange es aktiv ist, poppen keine Toasts auf, und der Indikator mit der durchgestrichenen Glocke sitzt in der Leiste, um dich daran zu erinnern, warum der Desktop still geworden ist.

Nichts geht dabei verloren. Stummgeschaltete Benachrichtigungen werden zurückgehalten: Hole die letzten paar mit `Super + Shift + Alt + ,` wieder auf den Bildschirm. Siehe [Hinweise](10-notices.md) für den Rest.

Zwei Arten von Nachrichten kommen trotzdem durch: Omarchys eigene Bestätigungs-Toasts für etwas, das du gerade getan hast ("Theme geändert", "Screenshot gespeichert"), und kritische Warnungen, die von der Kommandozeile gesendet werden. Chat-Apps, die alles als kritisch markieren, um sich vor dich zu drängen, zählen nicht dazu.

### Leerlauf

Die Omarchy-Shell ist für das Leerlaufverhalten zuständig, und die Zeitvorgaben stehen in einem `idle`-Block auf oberster Ebene in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Beide Zahlen sind Sekunden, gezählt ab dem Moment, in dem du in den Leerlauf gegangen bist — nicht voneinander. Mit den Standardwerten erscheint der Bildschirmschoner also nach zweieinhalb Minuten, und der Sperrbildschirm übernimmt nach fünf Minuten, unabhängig davon, ob der Bildschirmschoner lief. Speichere die Datei, und die Shell übernimmt die neuen Zeitvorgaben sofort.

Wenn du den Bildschirmschoner vor Ablauf der Sperrfrist beendest, zählt das als Aktivität, und die ausstehende Sperre wird abgebrochen. Du wirst nicht ausgesperrt, nur weil du mal kurz auf deinen Rechner geschaut hast.

Um das Sperren im Leerlauf komplett zu stoppen, schaltet `Super + Ctrl + I` — oder `omarchy toggle idle` — Wach bleiben ein, und der Indikator mit der Kaffeetasse erscheint in der Leiste. Den drückst du vor einer langen Präsentation oder einem Build, den du beobachten willst. Drücke ihn erneut, um zum Normalzustand zurückzukehren. `omarchy toggle idle status` gibt den aktuellen Zustand als JSON aus, wenn du ihn aus einem Skript brauchst.

Hier geht es um Sperren und den Bildschirmschoner, nicht um Energie. Suspend und Hibernation haben ihre eigene Einrichtung in [Systemschlaf](36-system-sleep.md).

### Der Bildschirmschoner

Omarchys Bildschirmschoner ist ASCII-Kunst, die durch zufällige Texteffekte läuft, eine Instanz pro Monitor. Jede Taste oder Mausbewegung beendet ihn.

Du kannst ihn bei Bedarf über _System > Screensaver_ (`Super + Esc`) starten, was ihn erzwingt, selbst wenn du den Leerlauf-Bildschirmschoner ausgeschaltet hast. Standardmäßig ist keine Tastenkombination dafür belegt.

`omarchy toggle screensaver` schaltet den Leerlauf-Bildschirmschoner aus, wenn du lieber direkt von der Arbeit in den gesperrten Zustand gehst. Jede Taste, jeder Klick, jedes Scrollen oder jede Mausbewegung schließt ihn.

Das Logo, das er zeichnet, kannst du ändern, unter _Appearance > Branding > Screensaver_. Lade ein png oder svg hoch, und Omarchy wandelt es in ASCII um. Siehe [Branding](41-branding.md).

### Der Sperrbildschirm

`Super + Ctrl + L` sperrt den Rechner. Das startet den Sperrbildschirm der Omarchy-Shell, schaltet die Anzeige schwarz, setzt dein Tastaturlayout auf das erste zurück, damit du dein Passwort nicht im falschen Alphabet tippst, und sperrt — falls es läuft — auf dem Weg nach draußen auch 1Password.

Der Sperrbildschirm akzeptiert ein Passwort, und er akzeptiert auch einen Fingerabdruck, sobald du einen eingerichtet hast. Das und die anderen Wege zur Authentifizierung werden in [Hardware-Authentifizierung](37-hardware-authentication.md) behandelt.
