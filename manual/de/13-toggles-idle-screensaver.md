# Toggles, Leerlauf und der Bildschirmschoner

Vieles von dem, was du im Alltag änderst, ist eigentlich keine Einstellung. Es ist ein Modus, den du für eine Stunde ein- und dann wieder ausschaltest: Nachtlicht, während du spät arbeitest, Nicht stören, während du präsentierst, wach bleiben, während du dir etwas ansiehst. Omarchy nennt diese Dinge Toggles, und sie funktionieren alle gleich — eine Tastenkombination, ein Menüeintrag und ein Befehl, die alle denselben Schalter betätigen.

### Das Toggle-Menü

`Super + Ctrl + O` öffnet _Trigger > Toggle_ direkt, oder du gehst über das Omarchy-Menü (`Super + Space`) dorthin. Alles in dieser Liste ist ein Schalter, den du umlegen kannst, ohne darüber nachzudenken, wo der Zustand gespeichert ist. Schalter für das Aussehen des Desktops befinden sich daneben, unter _Appearance_.

Vom Terminal aus sind dieselben Schalter `omarchy toggle <thing>`. Führe `omarchy toggle` allein aus, um die ganze Gruppe zu sehen.

| Toggle | Hotkey | Befehl |
| ------ | ------ | ------- |
| Nachtlicht | — | `omarchy toggle nightlight` |
| Benachrichtigungen stummschalten | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Wach bleiben (keine Leerlauf-Sperre) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Crash-Erfassung | — | `omarchy toggle crash-capture` |
| Bildschirmschoner | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-Theme-Synchronisierung | — | `omarchy toggle theme sync` |
| Menüleiste | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Ruhezustand | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Die Schalter für Touchpad, Touchscreen und Hybrid GPU befinden sich unter _Trigger > Hardware_ (`Super + Ctrl + H`) statt unter Toggle, da sie nur angezeigt werden, wenn du diese Hardware tatsächlich hast. Die Schalter für Touchpad und Touchscreen überleben ein Neuladen von Hyprland — der Name des deaktivierten Geräts wird in einer kleinen Zustandsdatei gespeichert, die Hyprland beim Start liest, um es erneut zu deaktivieren.

_Appearance_ enthält die Menüleiste und Animationen sowie einige Dinge, die keine `omarchy toggle`-Befehle sind, sich aber genauso verhalten: den Akkustand in Prozent in der Leiste, das Standard-Layout der Arbeitsflächen und unter _Windows_ die Fensterabstände (`Super + Shift + Backspace`) und das quadratische Seitenverhältnis bei 1 Fenster (`Super + Ctrl + Backspace`).

Die meisten davon sind einfach eine Flag-Datei unter `~/.local/state/omarchy/toggles/`. Wenn du in einem Skript auf eine davon verzweigen möchtest, gibt dir `omarchy-toggle-enabled` einen Exit-Code, statt dass du selbst danach suchen musst:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Die Flags sind nach dem Aus-Zustand benannt — `screensaver-off`, `suspend-off`, `bar-off` — ihre Anwesenheit bedeutet also, dass die Funktion deaktiviert ist.

### Indikatoren in der Leiste

Wenn ein Modus aktiv ist, erhältst du ein kleines Glyphen-Symbol in der Mitte der oberen Leiste neben der Uhr. Das ist das Indikatoren-Widget, und es enthält Diktat, Bildschirmaufnahme, ausstehende Erinnerungen, Nachtlicht, Nicht stören und Wach bleiben.

Inaktive Indikatoren sind ausgeblendet. Fahre mit der Maus irgendwo über die Leiste, und sie werden abgeblendet eingeblendet, sodass du auf einen klicken kannst, um ihn einzuschalten, ohne seine Tastenkombination zu kennen. Ein Klick auf einen aktiven Indikator schaltet ihn wieder aus. Wenn du lieber alle ständig sehen möchtest, setze `alwaysShow` auf `true` beim Eintrag `omarchy.indicators` in `~/.config/omarchy/shell.json` — siehe [die obere Leiste](05-the-top-bar.md) dazu, wie Widgets der Leiste konfiguriert werden.

### Nachtlicht

Das Nachtlicht wärmt den Bildschirm auf 4000K, und erneutes Umschalten stellt ihn auf 6500K zurück. Lege es über das Toggle-Menü (`Super + Ctrl + O`) oder mit `omarchy toggle nightlight` um. Es wird von hyprsunset gesteuert, das der Toggle für dich startet, wenn es nicht bereits läuft.

Standardmäßig macht hyprsunset überhaupt nichts mit deinem Bildschirm. `~/.config/hypr/hyprsunset.conf` wird mit einem Identity-Profil ausgeliefert, genau damit die Anzeige unberührt bleibt, bis du Wärme anforderst. Wenn du lieber möchtest, dass es nach der Uhr umschaltet, ersetze das durch ein Zeitprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Starte hyprsunset dann beim Anmelden, indem du `o.launch_on_start("hyprsunset")` zu `~/.config/hypr/autostart.lua` hinzufügst. Das vom Toggle verwendete Paar 4000K/6500K ist fest vorgegeben, die Konfigurationsdatei ist also der Ort, an den du gehst, wenn du eine andere Temperatur möchtest.

### Nicht stören

`Super + Ctrl + Alt + ,` schaltet Benachrichtigungen stumm. Während es aktiv ist, erscheinen keine Toasts, und der durchgestrichene Glocken-Indikator sitzt in der Leiste, um dich daran zu erinnern, warum der Desktop still geworden ist.

Nichts geht jedoch verloren. Stummgeschaltete Benachrichtigungen werden zurückgehalten: Hole die letzten paar mit `Super + Shift + Alt + ,` zurück auf den Bildschirm. Siehe [Hinweise](10-notices.md) für den Rest.

Zwei Arten von Nachrichten kommen trotzdem durch: Omarchys eigene Bestätigungs-Toasts für etwas, das du gerade getan hast ("Theme changed", "Screenshot saved"), und kritische Warnungen, die von der Kommandozeile gesendet werden. Chat-Apps, die alles als kritisch markieren, um sich vor dich zu drängen, zählen nicht dazu.

### Leerlauf

Die Omarchy-Shell ist für das Leerlaufverhalten zuständig, und die Zeitangaben sind ein `idle`-Block auf oberster Ebene in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Beide Zahlen sind Sekunden, gezählt ab dem Moment, in dem du in den Leerlauf gegangen bist — nicht abeinander. Mit den Standardeinstellungen erscheint der Bildschirmschoner also nach zweieinhalb Minuten, und der Sperrbildschirm übernimmt nach fünf Minuten, unabhängig davon, ob der Bildschirmschoner lief oder nicht. Speichere die Datei, und die Shell übernimmt die neuen Zeitangaben sofort.

Wenn du den Bildschirmschoner vor der Sperrfrist schließt, zählt das als Aktivität, und die ausstehende Sperre wird abgebrochen. Du wirst nicht ausgesperrt, nur weil du einen Blick auf deinen Rechner geworfen hast.

Um das Sperren im Leerlauf vollständig zu stoppen, legt `Super + Ctrl + I` — oder `omarchy toggle idle` — Wach bleiben um, und der Kaffeetassen-Indikator erscheint in der Leiste. Das ist der Schalter, den du vor einer langen Präsentation oder einem Build drücken solltest, den du beobachten möchtest. Drücke ihn erneut, um zum Normalzustand zurückzukehren. `omarchy toggle idle status` gibt den aktuellen Zustand als JSON aus, wenn du ihn aus einem Skript brauchst.

Hier geht es um Sperren und den Bildschirmschoner, nicht um Stromversorgung. Ruhezustand und Tiefschlaf haben ihre eigene Einrichtung in [Systemschlaf](36-system-sleep.md).

### Der Bildschirmschoner

Omarchys Bildschirmschoner ist ASCII-Kunst, die durch zufällige Texteffekte läuft, eine Instanz pro Monitor. Jede Taste oder Mausbewegung beendet ihn.

Du kannst ihn bei Bedarf über _System > Screensaver_ (`Super + Esc`) starten, was ihn erzwingt, selbst wenn du den Leerlauf-Bildschirmschoner ausgeschaltet hast. Standardmäßig ist keine Tastenkombination dafür gebunden.

`omarchy toggle screensaver` ist der Befehl, der den Leerlauf-Bildschirmschoner ausschaltet, wenn du lieber direkt vom Arbeiten zum Gesperrtsein übergehen möchtest. Er braucht ein Terminal, das er zu konfigurieren weiß — Alacritty, Foot, Ghostty oder Kitty — und wird dir das sagen, wenn dein Standard-Terminal etwas anderes ist.

Das Logo, das er zeichnet, kannst du ändern, unter _Appearance > Branding > Screensaver_. Lade ein png oder svg hoch, und Omarchy wandelt es in ASCII um. Siehe [Branding](41-branding.md).

### Der Sperrbildschirm

`Super + Ctrl + L` sperrt den Rechner. Das führt den Sperrbildschirm der Omarchy-Shell aus, schaltet die Anzeige dunkel, setzt dein Tastaturlayout auf das erste zurück, damit du dein Passwort nicht im falschen Alphabet tippst, und sperrt — falls es läuft — auf dem Weg nach draußen 1Password.

Der Sperrbildschirm akzeptiert ein Passwort, und er akzeptiert auch einen Fingerabdruck, sobald du einen eingerichtet hast. Das und die anderen Authentifizierungsmethoden werden in [Hardware-Authentifizierung](37-hardware-authentication.md) behandelt.
