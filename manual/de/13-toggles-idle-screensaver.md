# Umschalter, Leerlauf & der Bildschirmschoner

Vieles von dem, was du im Alltag änderst, ist eigentlich keine Einstellung. Es ist ein Modus, den du für eine Stunde einschaltest und dann wieder ausschaltest: Nachtlicht, während du lange arbeitest, Nicht stören, während du präsentierst, wach bleiben, während du etwas anschaust. Omarchy nennt diese Dinge Umschalter, und sie funktionieren alle auf die gleiche Weise — ein Tastenkürzel, ein Menüeintrag und ein Befehl, die alle denselben Schalter betätigen.

### Das Umschalter-Menü

`Super + Ctrl + O` öffnet _Trigger > Toggle_ direkt, oder du gelangst über das Omarchy-Menü (`Super + Space`) dorthin. Alles in dieser Liste ist ein Schalter, den du umlegen kannst, ohne darüber nachzudenken, wo der Zustand gespeichert ist. Schalter für das Aussehen des Desktops befinden sich daneben, unter _Appearance_.

Vom Terminal aus sind dieselben Schalter `omarchy toggle <thing>`. Führe `omarchy toggle` allein aus, um die ganze Gruppe zu sehen.

| Umschalter | Tastenkürzel | Befehl |
| ------ | ------ | ------- |
| Nachtlicht | — | `omarchy toggle nightlight` |
| Benachrichtigungen stummschalten | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Wach bleiben (keine Leerlauf-Sperre) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Absturz-Erfassung | — | `omarchy toggle crash-capture` |
| Bildschirmschoner | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) Theme-Synchronisierung | — | `omarchy toggle theme sync` |
| Menüleiste | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Die Touchpad-, Touchscreen- und Hybrid GPU-Schalter befinden sich unter _Trigger > Hardware_ (`Super + Ctrl + H`) statt unter Toggle, da sie nur auftauchen, wenn du diese Hardware tatsächlich hast. Die Touchpad- und Touchscreen-Schalter überleben ein Neuladen von Hyprland — der Name des deaktivierten Geräts wird in einer kleinen Zustandsdatei gespeichert, die Hyprland beim Start liest, um es wieder zu deaktivieren.

_Appearance_ enthält die Menüleiste und Animationen, plus ein paar Dinge, die keine `omarchy toggle`-Befehle sind, sich aber genauso verhalten: den Batterieprozentsatz in der Leiste, das Standard-Workspace-Layout und unter _Windows_ die Fensterabstände (`Super + Shift + Backspace`) und das quadratische 1-Fenster-Seitenverhältnis (`Super + Ctrl + Backspace`).

Wenn Hyprland keine GPU zum Zeichnen hat und stattdessen auf der CPU rendert (llvmpipe), wie auf Macs, deren GPU noch nicht unterstützt wird, in den meisten virtuellen Maschinen oder wenn ein Grafiktreiber nicht lädt, schaltet Omarchy Animationen, Blur und Schatten für diese Sitzung aus und sagt dir das einmal mit einer Benachrichtigung. _Appearance > Animations On_ bringt sie zurück, und Omarchy merkt sich das auch für spätere Sitzungen.

Die meisten davon sind einfach eine Flag-Datei unter `~/.local/state/omarchy/toggles/`. Wenn du in einem Skript danach verzweigen willst, gibt dir `omarchy-toggle-enabled` einen Exit-Code, statt dass du selbst danach suchen musst:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Die Flags sind nach dem Aus-Zustand benannt — `screensaver-off`, `suspend-off`, `bar-off` — ihre Anwesenheit bedeutet also, dass das Feature deaktiviert ist.

### Indikatoren in der Leiste

Wenn ein Modus an ist, bekommst du eine kleine Glyphe in der Mitte der oberen Leiste neben der Uhr. Das ist das Indikatoren-Widget, und es trägt Diktat, Bildschirmaufnahme, ausstehende Erinnerungen, Nachtlicht, Nicht stören und Wach bleiben.

Inaktive Indikatoren sind ausgeblendet. Fahre mit der Maus irgendwo über die Leiste, und sie blenden abgedunkelt ein, sodass du einen anklicken kannst, um ihn einzuschalten, ohne sein Tastenkürzel zu kennen. Ein Klick auf einen aktiven schaltet ihn wieder aus. Wenn du lieber alle ständig sehen willst, setze `alwaysShow` bei dem Eintrag `omarchy.indicators` in `~/.config/omarchy/shell.json` auf `true` — siehe [die obere Leiste](05-the-top-bar.md) für die Konfiguration der Leisten-Widgets.

### Nachtlicht

Nachtlicht wärmt den Bildschirm auf 4000K, und erneutes Umschalten stellt ihn auf 6500K zurück. Lege es über das Umschalter-Menü (`Super + Ctrl + O`) oder mit `omarchy toggle nightlight` um. Es wird von hyprsunset gesteuert, das der Umschalter für dich startet, falls es nicht bereits läuft.

Standardmäßig tut hyprsunset überhaupt nichts mit deinem Bildschirm. `~/.config/hypr/hyprsunset.conf` wird mit einem Identity-Profil ausgeliefert, gerade damit die Anzeige unberührt bleibt, bis du Wärme anforderst. Wenn du es lieber nach der Uhr umschalten lassen willst, ersetze das durch ein Zeitprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Starte hyprsunset dann beim Anmelden, indem du `o.launch_on_start("hyprsunset")` zu `~/.config/hypr/autostart.lua` hinzufügst. Das vom Umschalter verwendete Paar 4000K/6500K ist fest, die Konfigurationsdatei ist also der Ort, an den du gehst, wenn du eine andere Temperatur willst.

### Nicht stören

`Super + Ctrl + Alt + ,` schaltet Benachrichtigungen stumm. Solange es an ist, tauchen keine Toasts auf, und der durchgestrichene Glocken-Indikator sitzt in der Leiste, um dich daran zu erinnern, warum der Desktop still geworden ist.

Nichts geht jedoch verloren. Stummgeschaltete Benachrichtigungen werden zurückgehalten: Bringe die letzten paar mit `Super + Shift + Alt + ,` wieder auf den Bildschirm. Siehe [Hinweise](10-notices.md) für den Rest.

Zwei Arten von Nachrichten kommen trotzdem durch: Omarchys eigene Bestätigungs-Toasts für etwas, das du gerade getan hast („Theme geändert“, „Screenshot gespeichert“), und kritische Warnungen, die von der Kommandozeile gesendet werden. Chat-Apps, die alles als kritisch markieren, um sich vor dich zu drängen, zählen nicht dazu.

### Leerlauf

Die Omarchy-Shell besitzt das Leerlaufverhalten, und die Zeitvorgaben sind ein `idle`-Block auf oberster Ebene in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Beide Zahlen sind Sekunden, gezählt ab dem Moment, in dem du in den Leerlauf gegangen bist — nicht voneinander. Mit den Standardeinstellungen kommt der Bildschirmschoner also nach zweieinhalb Minuten und der Sperrbildschirm übernimmt bei fünf Minuten, egal ob der Bildschirmschoner gelaufen ist oder nicht. Speichere die Datei, und die Shell übernimmt die neuen Zeitvorgaben sofort.

Wenn du den Bildschirmschoner vor der Sperrfrist beendest, zählt das als Aktivität, und die ausstehende Sperrung wird abgebrochen. Du wirst nicht ausgesperrt, nur weil du kurz auf deinen Rechner geschaut hast.

Um die Sperrung im Leerlauf ganz zu stoppen, legt `Super + Ctrl + I` — oder `omarchy toggle idle` — Wach bleiben um, und der Kaffeetassen-Indikator erscheint in der Leiste. Das ist der, den du vor einer langen Präsentation oder einem Build drücken solltest, den du beobachten willst. Drücke ihn erneut, um zum Normalzustand zurückzukehren. `omarchy toggle idle status` gibt den aktuellen Zustand als JSON aus, falls du ihn aus einem Skript brauchst.

Hier geht es um Sperren und den Bildschirmschoner, nicht um Energie. Suspend und Hibernation haben ihre eigene Einrichtung in [System-Schlafmodus](36-system-sleep.md).

### Der Bildschirmschoner

Omarchys Bildschirmschoner ist ASCII-Art, die durch zufällige Texteffekte läuft, eine Instanz pro Monitor. Jede Taste oder Mausbewegung beendet ihn.

Du kannst ihn bei Bedarf aus _System > Screensaver_ (`Super + Esc`) starten, was ihn erzwingt, selbst wenn du den Leerlauf-Bildschirmschoner ausgeschaltet hast. Standardmäßig ist kein Tastenkürzel dafür gebunden.

Mit `omarchy toggle screensaver` schaltest du den Leerlauf-Bildschirmschoner aus, wenn du lieber direkt von der Arbeit zur Sperrung gehen willst. Jede Taste, jeder Klick, jedes Scrollen oder jede Mausbewegung schließt ihn.

Das Logo, das er zeichnet, kannst du ändern, unter _Appearance > Branding > Screensaver_. Lade ein png oder svg hoch, und Omarchy wandelt es in ASCII um. Siehe [Branding](41-branding.md).

### Der Sperrbildschirm

`Super + Ctrl + L` sperrt den Rechner. Das führt den Sperrbildschirm aus der Omarchy-Shell aus, schaltet die Anzeige schwarz, setzt dein Tastaturlayout auf das erste zurück, damit du dein Passwort nicht im falschen Alphabet tippst, und — falls du es laufen hast — sperrt 1Password auf dem Weg nach draußen.

Der Sperrbildschirm nimmt ein Passwort, und er nimmt auch einen Fingerabdruck, sobald du einen eingerichtet hast. Das und die anderen Wege zur Authentifizierung werden in [Hardware-Authentifizierung](37-hardware-authentication.md) behandelt.
