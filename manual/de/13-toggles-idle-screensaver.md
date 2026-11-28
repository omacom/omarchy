# Umschalter, Leerlauf & der Bildschirmschoner

Vieles von dem, was du im Alltag änderst, ist eigentlich keine Einstellung. Es ist ein Modus, den du für eine Stunde einschaltest und dann wieder ausschaltest: Nachtlicht, während du spät arbeitest, Nicht stören, während du präsentierst, wach bleiben, während du dir etwas ansiehst. Omarchy nennt das Umschalter, und sie funktionieren alle gleich — eine Tastenkombination, ein Menüeintrag und ein Befehl, die alle denselben Schalter betätigen.

### Das Umschalter-Menü

`Super + Ctrl + O` öffnet _Trigger > Toggle_ direkt, oder du gehst über das Omarchy-Menü (`Super + Space`) dorthin. Alles in dieser Liste ist ein Schalter, den du umlegen kannst, ohne darüber nachzudenken, wo der Zustand gespeichert ist. Die Schalter für das Aussehen des Desktops sitzen daneben, unter _Appearance_.

Vom Terminal aus sind dieselben Schalter `omarchy toggle <thing>`. Führe `omarchy toggle` allein aus, um die ganze Gruppe zu sehen.

| Umschalter | Tastenkombination | Befehl |
| ------ | ------ | ------- |
| Nachtlicht | — | `omarchy toggle nightlight` |
| Benachrichtigungen stummschalten | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Wach bleiben (keine Leerlaufsperre) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Absturzerfassung | — | `omarchy toggle crash-capture` |
| Bildschirmschoner | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-Designabgleich | — | `omarchy toggle theme sync` |
| Menüleiste | `Super + Shift + Space` | `omarchy toggle bar` |
| Vollbild-Desktop (keine Leiste, keine Abstände) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animationen, Unschärfe und Schatten | — | `omarchy toggle animations` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Touchscreen | — | `omarchy device touchscreen` |
| Standby | — | `omarchy toggle suspend` |
| Hybride GPU | — | `omarchy device gpu hybrid` |

Die Schalter für Touchpad, Touchscreen und hybride GPU leben unter _Trigger > Hardware_ (`Super + Ctrl + H`) statt unter Toggle, da sie nur auftauchen, wenn du diese Hardware tatsächlich hast. Die Schalter für Touchpad und Touchscreen überleben ein Neuladen von Hyprland — der Name des deaktivierten Geräts wird in einer kleinen Zustandsdatei gespeichert, die Hyprland beim Start liest, um es erneut zu deaktivieren.

_Appearance_ enthält die Menüleiste und die Animationen, plus ein paar Dinge, die keine `omarchy toggle`-Befehle sind, sich aber genauso verhalten: den Akkustand in Prozent in der Leiste, das Standardlayout der Arbeitsbereiche und, unter _Windows_, die Fensterabstände (`Super + Shift + Backspace`) und das quadratische Seitenverhältnis bei 1 Fenster (`Super + Ctrl + Backspace`).

Wenn Hyprland keine GPU zum Zeichnen hat und stattdessen auf der CPU rendert (llvmpipe), wie auf Macs, deren GPU noch nicht unterstützt wird, in den meisten virtuellen Maschinen oder wenn ein Grafiktreiber nicht lädt, schaltet Omarchy Animationen, Unschärfe und Schatten für diese Sitzung ab und sagt dir das einmal mit einer Benachrichtigung. _Appearance > Animations On_ bringt sie zurück, und Omarchy merkt sich das auch für spätere Sitzungen.

Die meisten davon sind einfach eine Flag-Datei unter `~/.local/state/omarchy/toggles/`. Wenn du in einem Skript darauf verzweigen willst, gibt dir `omarchy-toggle-enabled` einen Exit-Code, statt dass du selbst danach suchen musst:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Die Flags sind nach dem Aus-Zustand benannt — `screensaver-off`, `suspend-off`, `bar-off` — ihre Anwesenheit bedeutet also, dass die Funktion deaktiviert ist.

### Indikatoren in der Leiste

Wenn ein Modus an ist, bekommst du ein kleines Symbol in der Mitte der oberen Leiste neben der Uhr. Das ist das Indikatoren-Widget, und es enthält Bildschirmaufnahme, ausstehende Erinnerungen, Nachtlicht, Nicht stören und Wach bleiben, plus Warnungen, während passwortloses sudo an ist oder jemand mit einer Remote-Sitzung verbunden ist.

Inaktive Indikatoren sind ausgeblendet. Fahre mit der Maus irgendwo über die Leiste, und sie blenden abgedunkelt ein, sodass du einen anklicken kannst, um ihn einzuschalten, ohne seine Tastenkombination zu kennen. Ein Klick auf einen aktiven schaltet ihn wieder aus. Wenn du sie lieber die ganze Zeit alle sehen willst, setze `alwaysShow` auf `true` beim Eintrag `omarchy.indicators` in `~/.config/omarchy/shell.json` — siehe [die obere Leiste](05-the-top-bar.md) dafür, wie die Widgets der Leiste konfiguriert werden.

### Nachtlicht

Das Nachtlicht wärmt den Bildschirm auf 4000K, und erneutes Umschalten stellt ihn auf 6500K zurück. Lege es aus dem Umschalter-Menü (`Super + Ctrl + O`) um oder mit `omarchy toggle nightlight`. Es wird von hyprsunset angetrieben, das der Umschalter für dich startet, falls es nicht bereits läuft.

Standardmäßig tut hyprsunset deinem Bildschirm überhaupt nichts. `~/.config/hypr/hyprsunset.conf` wird mit einem Identitätsprofil ausgeliefert, gerade damit das Display unberührt bleibt, bis du um Wärme bittest. Wenn du es lieber nach der Uhr schalten lassen willst, ersetze das durch ein Zeitprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Starte hyprsunset dann beim Anmelden, indem du `o.launch_on_start("hyprsunset")` zu `~/.config/hypr/autostart.lua` hinzufügst. Das vom Umschalter verwendete Paar 4000K/6500K ist fest, die Konfigurationsdatei ist also der Ort, an den du gehst, wenn du eine andere Temperatur willst.

### Nicht stören

`Super + Ctrl + Alt + ,` schaltet Benachrichtigungen stumm. Während es an ist, tauchen keine Toasts auf, und der durchgestrichene Glockenindikator sitzt in der Leiste, um dich daran zu erinnern, warum der Desktop still geworden ist.

Nichts geht jedoch verloren. Stummgeschaltete Benachrichtigungen werden zurückgehalten: Hole die letzten paar mit `Super + Shift + Alt + ,` zurück auf den Bildschirm. Siehe [Hinweise](10-notices.md) für den Rest.

Drei Arten von Nachrichten kommen trotzdem durch: Omarchys eigene Bestätigungs-Toasts für etwas, das du gerade getan hast ("Theme changed", "Screenshot saved"), kritische Warnungen, die von der Kommandozeile gesendet werden, und Verifizierungscodes. Chat-Apps, die alles als kritisch markieren, um sich vor dich zu drängen, qualifizieren sich nicht.

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

Beide Zahlen sind Sekunden, gezählt ab dem Moment, in dem du in den Leerlauf gegangen bist — nicht voneinander. Mit den Standardwerten kommt der Bildschirmschoner also nach zweieinhalb Minuten, und der Sperrbildschirm übernimmt nach fünf Minuten, ob der Bildschirmschoner nun lief oder nicht. Speichere die Datei, und die Shell übernimmt die neuen Zeitvorgaben sofort.

Wenn du den Bildschirmschoner vor der Sperrfrist wegklickst, zählt das als Aktivität, und die ausstehende Sperre wird abgebrochen. Du wirst nicht ausgesperrt, nur weil du einen Blick auf deinen Rechner geworfen hast.

Um das Sperren im Leerlauf ganz zu stoppen, legt `Super + Ctrl + I` — oder `omarchy toggle idle` — Wach bleiben um, und der Kaffeetassenindikator erscheint in der Leiste. Das ist der, den du vor einer langen Präsentation oder einem Build, den du beobachten willst, drücken solltest. Drücke ihn erneut, um zum Normalzustand zurückzukehren. `omarchy toggle idle status` gibt den aktuellen Zustand als JSON aus, falls du ihn aus einem Skript brauchst.

Hier geht es um Sperren und den Bildschirmschoner, nicht um Strom. Standby und Ruhezustand haben ihre eigene Einrichtung in [System-Ruhezustand](36-system-sleep.md).

### Der Bildschirmschoner

Omarchys Bildschirmschoner ist ASCII-Kunst, die durch zufällige Texteffekte läuft, eine Instanz pro Monitor. Jede Taste oder Mausbewegung beendet ihn.

Du kannst ihn bei Bedarf aus _System > Screensaver_ (`Super + Esc`) starten, was ihn erzwingt, selbst wenn du den Leerlauf-Bildschirmschoner ausgeschaltet hast. Standardmäßig ist keine Tastenkombination daran gebunden.

`omarchy toggle screensaver` ist das, was den Leerlauf-Bildschirmschoner ausschaltet, falls du lieber direkt vom Arbeiten zum Gesperrtsein gehen willst. Jede Taste, jeder Klick, jedes Scrollen oder jede Mausbewegung schließt ihn.

Das Logo, das er zeichnet, kannst du ändern, unter _Appearance > Branding > Screensaver_. Lade ein png oder svg hoch, und Omarchy wandelt es in ASCII um. Siehe [Branding](41-branding.md).

### Der Sperrbildschirm

`Super + Ctrl + L` sperrt den Rechner. Das führt den Sperrbildschirm aus der Omarchy-Shell aus, dunkelt das Display ab, setzt dein Tastaturlayout auf das erste zurück, damit du dein Passwort nicht im falschen Alphabet tippst, und — falls du es laufen hast — sperrt auf dem Weg nach draußen 1Password.

Der Sperrbildschirm nimmt ein Passwort, und er nimmt auch einen Fingerabdruck, sobald du einen eingerichtet hast. Das und die anderen Wege, dich zu authentifizieren, werden in [Hardware-Authentifizierung](37-hardware-authentication.md) behandelt.
