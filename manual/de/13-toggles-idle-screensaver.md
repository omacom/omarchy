# Schalter, Leerlauf & der Bildschirmschoner

Vieles von dem, was du Tag für Tag änderst, ist nicht wirklich eine Einstellung. Es ist ein Modus, den du für eine Stunde einschaltest und wieder ausschaltest: Nachtlicht, während du spät arbeitest, Nicht stören, während du präsentierst, Wach bleiben, während du dir etwas ansiehst. Omarchy nennt diese Schalter, und sie funktionieren alle gleich — ein Tastenkürzel, ein Menüeintrag und ein Befehl, die alle denselben Schalter treffen.

### Das Umschalten-Menü

`Super + Ctrl + O` öffnet _Auslösen > Umschalten_ direkt, oder du kannst vom Omarchy-Menü (`Super + Space`) dorthin gehen. Alles in dieser Liste ist ein Schalter, den du umlegen kannst, ohne darüber nachzudenken, wo der Zustand lebt. Schalter dafür, wie der Desktop aussieht, sitzen daneben, unter _Auslösen > Aussehen_.

Vom Terminal aus sind dieselben Schalter `omarchy toggle <thing>`. Führe `omarchy toggle` allein aus, um die ganze Gruppe zu sehen.

| Schalter | Tastenkürzel | Befehl |
| ------ | ------ | ------- |
| Nachtlicht | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Benachrichtigungen stumm schalten | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Wach bleiben (keine Leerlauf-Sperre) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Absturzerfassung | — | `omarchy toggle crash-capture` |
| Bildschirmschoner | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-Design-Sync | — | `omarchy toggle theme sync` |
| Menüleiste | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Standby | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Die Schalter für Touchpad, Touchscreen und Hybrid GPU leben unter _Auslösen > Hardware_ (`Super + Ctrl + H`) statt unter Umschalten, da sie nur erscheinen, wenn du diese Hardware tatsächlich hast. Die für Touchpad und Touchscreen überstehen ein Hyprland-Neuladen — der Name des deaktivierten Geräts wird in einer kleinen Zustandsdatei gespeichert, die Hyprland beim Start liest, um es wieder zu deaktivieren.

_Auslösen > Aussehen_ enthält die Menüleiste und Animationen plus ein paar Dinge, die keine `omarchy toggle`-Befehle sind, sich aber gleich verhalten: Akkuprozentsatz in der Leiste, das Standard-Arbeitsflächenlayout, Fensterabstände (`Super + Shift + Backspace`) und das quadratische 1-Fenster-Seitenverhältnis (`Super + Ctrl + Backspace`).

Die meisten davon sind nur eine Flag-Datei unter `~/.local/state/omarchy/toggles/`. Wenn du in einem Skript auf einer verzweigen willst, gibt dir `omarchy-toggle-enabled` einen Exit-Code, anstatt dich suchen zu lassen:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Die Flags sind nach dem Aus-Zustand benannt — `screensaver-off`, `suspend-off`, `bar-off` — sodass ihre Anwesenheit bedeutet, dass die Funktion deaktiviert ist.

### Anzeigen in der Leiste

Wenn ein Modus eingeschaltet ist, bekommst du eine kleine Glyphe in der Mitte der Menüleiste neben der Uhr. Das ist das Anzeigen-Widget, und es trägt Diktat, Bildschirmaufnahme, ausstehende Erinnerungen, Nachtlicht, Nicht stören und Wach bleiben.

Inaktive Anzeigen sind ausgeblendet. Fahre mit der Maus über den Bereich um sie herum, und sie blenden gedimmt ein, sodass du auf eine klicken kannst, um sie einzuschalten, ohne ihr Tastenkürzel zu kennen. Ein Klick auf eine aktive schaltet sie wieder aus. Wenn du sie lieber die ganze Zeit alle sehen willst, setze `alwaysShow` auf dem Eintrag `omarchy.indicators` in `~/.config/omarchy/shell.json` auf `true` — siehe [die Menüleiste](05-the-top-bar.md), um zu erfahren, wie Leisten-Widgets konfiguriert werden.

### Nachtlicht

`Super + Ctrl + N` erwärmt den Bildschirm auf 4000 K, und erneutes Drücken stellt ihn auf 6500 K zurück. Es wird von hyprsunset gesteuert, das der Schalter für dich startet, wenn es nicht bereits läuft.

Standardmäßig tut hyprsunset überhaupt nichts mit deinem Bildschirm. `~/.config/hypr/hyprsunset.conf` wird mit einem Identitätsprofil ausgeliefert, gerade damit das Display unberührt bleibt, bis du um Wärme bittest. Wenn du es lieber nach der Uhr wechseln lassen willst, ersetze das durch ein Zeitprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Starte dann hyprsunset bei der Anmeldung, indem du `o.launch_on_start("hyprsunset")` zu `~/.config/hypr/autostart.lua` hinzufügst. Das vom Schalter verwendete Paar 4000 K/6500 K ist fest, sodass die Konfigurationsdatei der Ort ist, an den du gehst, wenn du eine andere Temperatur willst.

### Nicht stören

`Super + Ctrl + ,` schaltet Benachrichtigungen stumm. Während es eingeschaltet ist, poppen keine Toasts auf, und die durchgestrichene Glockenanzeige sitzt in der Leiste, um dich daran zu erinnern, warum der Desktop still geworden ist.

Nichts geht jedoch verloren. Eine stummgeschaltete Benachrichtigung wird direkt in deinen Benachrichtigungsverlauf geschrieben, was genau der Datensatz ist, den du willst, wenn du zurückkommst und dich fragst, was du verpasst hast. Öffne ihn mit `Super + Shift + Alt + ,`. Siehe [Hinweise](10-notices.md) für den Rest der Benachrichtigungsgeschichte.

Zwei Arten von Nachrichten kommen trotzdem durch: Omarchys eigene Bestätigungs-Toasts für etwas, das du gerade getan hast („Design geändert“, „Screenshot gespeichert“), und kritische Warnungen, die von der Kommandozeile gesendet werden. Chat-Apps, die alles als kritisch markieren, um sich vor dich zu drängen, qualifizieren sich nicht.

### Leerlauf

Die Omarchy-Shell besitzt das Leerlaufverhalten, und die Zeiten sind ein `idle`-Block auf oberster Ebene in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Beide Zahlen sind Sekunden, gezählt ab dem Moment, in dem du in den Leerlauf gegangen bist — nicht voneinander. Mit den Standards kommt der Bildschirmschoner also nach zweieinhalb Minuten, und der Sperrbildschirm übernimmt bei fünf Minuten, egal ob der Bildschirmschoner lief oder nicht. Speichere die Datei, und die Shell übernimmt die neuen Zeiten sofort.

Wenn du den Bildschirmschoner vor der Sperrfrist schließt, zählt das als Aktivität, und die ausstehende Sperre wird abgebrochen. Du wirst nicht ausgesperrt, weil du einen Blick auf deine Maschine geworfen hast.

Um das Sperren bei Leerlauf vollständig zu stoppen, schaltet `Super + Ctrl + I` — oder `omarchy toggle idle` — Wach bleiben ein, und die Kaffeetassenanzeige erscheint in der Leiste. Das ist der, den du vor einer langen Präsentation oder einem Build, den du beobachten willst, drücken solltest. Drücke ihn erneut, um zum Normalzustand zurückzukehren. `omarchy toggle idle status` gibt den aktuellen Zustand als JSON aus, wenn du ihn von einem Skript aus brauchst.

Hier geht es um Sperren und den Bildschirmschoner, nicht um Strom. Standby und Ruhezustand haben ihr eigenes Setup in [Systemschlaf](36-system-sleep.md).

### Der Bildschirmschoner

Omarchys Bildschirmschoner ist ASCII-Kunst, die durch zufällige Texteffekte läuft, eine Instanz pro Monitor. Jede Taste oder Mausbewegung beendet ihn.

Du kannst ihn bei Bedarf über _System > Bildschirmschoner_ (`Super + Esc`) starten, was ihn erzwingt, selbst wenn du den Leerlauf-Bildschirmschoner ausgeschaltet hast. Standardmäßig ist kein Tastenkürzel daran gebunden.

`omarchy toggle screensaver` schaltet den Leerlauf-Bildschirmschoner aus, wenn du lieber direkt von der Arbeit zur Sperre gehen willst. Er braucht ein Terminal, das er zu konfigurieren weiß — Alacritty, Foot, Ghostty oder Kitty — und sagt dir das, wenn dein Standardterminal etwas anderes ist.

Das Logo, das er zeichnet, kannst du ändern, unter _Stil > Bildschirmschoner_. Lade ein png oder svg hoch, und Omarchy wandelt es in ASCII um. Siehe [Branding](41-branding.md).

### Der Sperrbildschirm

`Super + Ctrl + L` sperrt die Maschine. Das führt den Sperrbildschirm aus der Omarchy-Shell aus, schaltet das Display aus, setzt dein Tastaturlayout auf das erste zurück, sodass du dein Passwort nicht im falschen Alphabet tippst, und sperrt — wenn es läuft — auf dem Weg hinaus 1Password.

Der Sperrbildschirm nimmt ein Passwort, und er nimmt auch einen Fingerabdruck, sobald du einen eingerichtet hast. Das und die anderen Wege zur Authentifizierung werden in [Hardware-Authentifizierung](37-hardware-authentication.md) behandelt.
