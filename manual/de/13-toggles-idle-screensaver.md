# Umschalter, Leerlauf & der Bildschirmschoner

Vieles von dem, was du im Alltag änderst, ist eigentlich keine Einstellung. Es ist ein Modus, den du für eine Stunde einschaltest und dann wieder aus: Nachtlicht, wenn du spät arbeitest, Nicht stören, wenn du präsentierst, wach bleiben, wenn du dir etwas ansiehst. Omarchy nennt diese Dinge Umschalter, und sie funktionieren alle gleich — ein Tastenkürzel, ein Menüeintrag und ein Befehl, die alle denselben Schalter betätigen.

### Das Umschalter-Menü

`Super + Ctrl + O` öffnet direkt _Auslöser > Umschalter_, oder du gehst über das Omarchy-Menü (`Super + Space`) dorthin. Alles in dieser Liste ist ein Schalter, den du umlegen kannst, ohne darüber nachzudenken, wo der Zustand liegt. Schalter dafür, wie der Desktop aussieht, sitzen daneben unter _Darstellung_.

Vom Terminal aus sind dieselben Schalter `omarchy toggle <thing>`. Führe `omarchy toggle` allein aus, um die ganze Gruppe zu sehen.

| Umschalter | Tastenkürzel | Befehl |
| ------ | ------ | ------- |
| Nachtlicht | — | `omarchy toggle nightlight` |
| Benachrichtigungen stummschalten | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Wach bleiben (keine Sperre bei Leerlauf) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Absturzerfassung | — | `omarchy toggle crash-capture` |
| Bildschirmschoner | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-Designsynchronisierung | — | `omarchy toggle theme sync` |
| Menüleiste | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Touchscreen | — | `omarchy device touchscreen` |
| Ruhezustand | — | `omarchy toggle suspend` |
| Hybride GPU | — | `omarchy toggle hybrid gpu` |

Die Schalter für Touchpad, Touchscreen und hybride GPU liegen unter _Auslöser > Hardware_ (`Super + Ctrl + H`) statt unter Umschalter, da sie nur erscheinen, wenn du diese Hardware tatsächlich hast. Die für Touchpad und Touchscreen überstehen ein Neuladen von Hyprland — der Name des deaktivierten Geräts wird in einer kleinen Zustandsdatei gespeichert, die Hyprland beim Start liest, um es erneut zu deaktivieren.

_Darstellung_ enthält die Menüleiste und Animationen sowie ein paar Dinge, die keine `omarchy toggle`-Befehle sind, sich aber genauso verhalten: den Batterieprozentsatz in der Leiste, das Standardlayout der Arbeitsflächen und unter _Fenster_ die Fensterabstände (`Super + Shift + Backspace`) und das quadratische Seitenverhältnis bei 1 Fenster (`Super + Ctrl + Backspace`).

Wenn Hyprland keine GPU zum Zeichnen hat und stattdessen auf der CPU rendert (llvmpipe), wie auf Macs, deren GPU noch nicht unterstützt wird, in den meisten virtuellen Maschinen oder wenn ein Grafiktreiber nicht lädt, schaltet Omarchy Animationen, Unschärfe und Schatten für diese Sitzung aus und teilt dir das einmal per Benachrichtigung mit. _Darstellung > Animationen ein_ bringt sie zurück, und Omarchy merkt sich das auch für spätere Sitzungen.

Die meisten davon sind nur eine Flag-Datei unter `~/.local/state/omarchy/toggles/`. Wenn du in einem Skript auf eine davon verzweigen willst, gibt dir `omarchy-toggle-enabled` einen Exit-Code, statt dass du selbst danach suchen musst:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Die Flags sind nach dem Aus-Zustand benannt — `screensaver-off`, `suspend-off`, `bar-off` — ihr Vorhandensein bedeutet also, dass die Funktion deaktiviert ist.

### Indikatoren in der Leiste

Wenn ein Modus aktiv ist, bekommst du in der Mitte der oberen Leiste neben der Uhr eine kleine Glyphe. Das ist das Indikatoren-Widget, und es enthält Diktat, Bildschirmaufnahme, anstehende Erinnerungen, Nachtlicht, Nicht stören und Wach bleiben.

Inaktive Indikatoren sind ausgeblendet. Fahre mit der Maus irgendwo über die Leiste, und sie blenden abgedunkelt ein, sodass du einen anklicken kannst, um ihn einzuschalten, ohne sein Tastenkürzel zu kennen. Ein Klick auf einen aktiven Indikator schaltet ihn wieder aus. Wenn du lieber alle ständig sehen willst, setze `alwaysShow` auf `true` beim Eintrag `omarchy.indicators` in `~/.config/omarchy/shell.json` — siehe [die obere Leiste](05-the-top-bar.md), wie Leisten-Widgets konfiguriert werden.

### Nachtlicht

Das Nachtlicht wärmt den Bildschirm auf 4000K, und erneutes Umschalten stellt ihn auf 6500K zurück. Lege es im Umschalter-Menü (`Super + Ctrl + O`) oder mit `omarchy toggle nightlight` um. Es wird von hyprsunset angetrieben, das der Umschalter für dich startet, falls es nicht schon läuft.

Standardmäßig tut hyprsunset deinem Bildschirm überhaupt nichts. `~/.config/hypr/hyprsunset.conf` wird mit einem Identitätsprofil ausgeliefert, gerade damit die Anzeige unberührt bleibt, bis du Wärme verlangst. Wenn du lieber nach der Uhr umschalten lassen willst, ersetze das durch ein Zeitprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Starte hyprsunset dann bei der Anmeldung, indem du `o.launch_on_start("hyprsunset")` zu `~/.config/hypr/autostart.lua` hinzufügst. Das vom Umschalter verwendete Paar 4000K/6500K ist fest, die Konfigurationsdatei ist also die Stelle, an die du gehst, wenn du eine andere Temperatur willst.

### Nicht stören

`Super + Ctrl + Alt + ,` schaltet Benachrichtigungen stumm. Solange es aktiv ist, tauchen keine Toasts auf, und der Indikator mit der durchgestrichenen Glocke sitzt in der Leiste, um dich daran zu erinnern, warum der Desktop still geworden ist.

Verloren geht aber nichts. Stummgeschaltete Benachrichtigungen werden zurückgehalten: Bringe die letzten paar mit `Super + Shift + Alt + ,` wieder auf den Bildschirm. Siehe [Hinweise](10-notices.md) für den Rest.

Zwei Arten von Nachrichten kommen trotzdem durch: Omarchys eigene Bestätigungs-Toasts für etwas, das du gerade getan hast ("Theme changed", "Screenshot saved"), und kritische Warnungen, die von der Kommandozeile gesendet werden. Chat-Apps, die alles als kritisch markieren, um sich vor dich zu drängen, fallen nicht darunter.

### Leerlauf

Die Omarchy-Shell besitzt das Leerlaufverhalten, und die Zeitangaben sind ein `idle`-Block auf oberster Ebene in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Beide Zahlen sind Sekunden, gezählt ab dem Moment, in dem du in den Leerlauf gegangen bist — nicht voneinander. Mit den Standardeinstellungen erscheint der Bildschirmschoner also nach zweieinhalb Minuten und der Sperrbildschirm übernimmt nach fünf Minuten, egal ob der Bildschirmschoner lief oder nicht. Speichere die Datei, und die Shell übernimmt die neuen Zeitangaben sofort.

Wenn du den Bildschirmschoner vor der Sperrfrist wegklickst, zählt das als Aktivität und die anstehende Sperre wird abgebrochen. Du wirst nicht ausgesperrt, nur weil du einen Blick auf deinen Rechner geworfen hast.

Um das Sperren bei Leerlauf ganz zu stoppen, legst du mit `Super + Ctrl + I` — oder `omarchy toggle idle` — Wach bleiben um, und der Kaffeetassen-Indikator erscheint in der Leiste. Das ist der, den du vor einer langen Präsentation oder einem Build drücken solltest, den du beobachten willst. Drücke ihn erneut, um zum Normalzustand zurückzukehren. `omarchy toggle idle status` gibt den aktuellen Zustand als JSON aus, falls du ihn aus einem Skript brauchst.

Hier geht es um Sperren und den Bildschirmschoner, nicht um Strom. Ruhezustand und Tiefschlaf haben ihre eigene Einrichtung in [Systemschlaf](36-system-sleep.md).

### Der Bildschirmschoner

Omarchys Bildschirmschoner ist ASCII-Kunst, die durch zufällige Texteffekte läuft, eine Instanz pro Monitor. Jede Taste oder Mausbewegung beendet ihn.

Du kannst ihn bei Bedarf aus _System > Bildschirmschoner_ (`Super + Esc`) starten, was ihn erzwingt, selbst wenn du den Leerlauf-Bildschirmschoner ausgeschaltet hast. Standardmäßig ist kein Tastenkürzel dafür gebunden.

`omarchy toggle screensaver` schaltet den Leerlauf-Bildschirmschoner aus, falls du lieber direkt vom Arbeiten zum Gesperrtsein übergehen willst. Jede Taste, jeder Klick, jedes Scrollen oder jede Mausbewegung schließt ihn.

Das Logo, das er zeichnet, kannst du ändern, unter _Darstellung > Branding > Bildschirmschoner_. Lade eine png- oder svg-Datei hoch, und Omarchy wandelt sie in ASCII um. Siehe [Branding](41-branding.md).

### Der Sperrbildschirm

`Super + Ctrl + L` sperrt den Rechner. Das führt den Sperrbildschirm aus der Omarchy-Shell aus, dunkelt die Anzeige ab, setzt dein Tastaturlayout auf das erste zurück, damit du dein Passwort nicht im falschen Alphabet tippst, und sperrt — falls es läuft — auf dem Weg nach draußen 1Password.

Der Sperrbildschirm nimmt ein Passwort, und er nimmt auch einen Fingerabdruck, sobald du einen eingerichtet hast. Das und die anderen Wege zur Authentifizierung werden in [Hardware-Authentifizierung](37-hardware-authentication.md) behandelt.
