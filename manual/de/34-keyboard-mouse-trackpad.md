# Tastatur, Maus, Trackpad

Hyprland lässt dich alle deine Eingaben im Detail konfigurieren. Du kannst die Tastaturwiederholung überschallschnell machen oder das Trackpad natürliches Scrollen verwenden lassen. Du änderst alles in `~/.config/hypr/input.lua`, das du auch im Omarchy-Menü (`Super + Space`) über _Einrichtung > Eingabe_ erreichst. Alles, was du dort festlegst, ersetzt die Omarchy-Standards.

Hier ist ein Beispiel:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Du kannst [alle Eingabeoptionen](https://wiki.hypr.land/Configuring/Basics/Variables/#input) im Hyprland-Wiki für Eingaben sehen.

CapsLock funktioniert als normales Caps Lock, und `Shift + CapsLock` ist die Compose-Taste für [Schnell-Emojis](07-hotkeys.md#quick-emojis) und [andere Vervollständigungen](07-hotkeys.md#quick-completions). Wenn du die Compose-Taste lieber woanders hättest, ersetze `omarchy:shift_caps_compose` in `kb_options`. Dies hier verschiebt die Compose-Taste zum Beispiel auf Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad-Gesten

Du kannst auch [Touchpad-Gesten](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) einschalten, zum Beispiel mit drei Fingern wischen, um Arbeitsflächen zu wechseln:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Auf Dell-XPS-Laptops mit haptischem Touchpad kannst du unter _Auslösen > Hardware > Touchpad-Haptik_ die Klickstärke auf niedrig, mittel oder hoch einstellen.

### Auf Chinesisch, Japanisch und in anderen Sprachen tippen

Wähle Japanisch, Koreanisch, Chinesisch (Vereinfacht, Pinyin) oder Chinesisch (Traditionell, Zhuyin), wenn der Installer nach deiner Tastatur fragt. Omarchy konfiguriert die Tastatur und die passende Eingabe-Engine automatisch, auch während der Offline-Ersteinrichtung. Japanisch verwendet Mozc, Koreanisch verwendet das standardmäßige Hangul mit zwei Sätzen, Vereinfachtes Chinesisch verwendet Pinyin und Traditionelles Chinesisch verwendet Chewings standardmäßige Zhuyin-Anordnung. Japanese (US keyboard) bietet Mozc mit einem US-Tastaturlayout.

Das Tippen beginnt im Latin-Modus. Drücke `Super + I`, um durch die konfigurierten Eingabemethoden zu wechseln, und `Super + Shift + I`, um rückwärts zu wechseln. Tippe `Shift` allein an, um aus einer Eingabemethode wie Pinyin in lateinische Buchstaben auszusteigen, und tippe es erneut an, um zurückzugehen, so wie Sogou, Microsoft Pinyin und macOS funktionieren; `Shift` plus ein Buchstabe gibt weiterhin einen Großbuchstaben ein. Auf japanischen Tastaturen schaltet 全角/半角 die Eingabe um, 変換 schaltet sie ein und 無変換 schaltet sie aus. Bei einem koreanischen Tastaturlayout wechseln die dedizierten Tasten 한/영 und 한자 Hangul und konvertieren zu Hanja. `Ctrl + Space` bleibt für Tmux und Herdr verfügbar; `Shift + CapsLock` bleibt die Compose-Taste.

Die Tastaturanzeige erscheint rechts in der Leiste, wenn du mehrere Tastaturlayouts oder Eingabemethoden hast. Klicke sie an, um Eingabesprachen zu wechseln; Japanisch zeigt あ für Hiragana. Für die Auswahl japanischer Zeichen wechsle zu Japanisch, tippe ein Wort wie `nihongo` ein und drücke dann zweimal Space. Drücke Enter, um deine Auswahl zu übernehmen. Wenn du zusätzlich mehrere Tastaturlayouts hast, klicke mit der rechten Maustaste auf die Anzeige, um durch diese zu wechseln.

Verwende _Einrichtung > Tippen > Tastaturlayouts_, um Layouts wie English und French auszuwählen, aus denselben Auswahlmöglichkeiten wie während der Installation. Verwende _Einrichtung > Tippen > Eingabemethoden_, um auszuwählen, welche Kompositions-Engines aktiv sind. Beide Auswahlen öffnen sich im Omarchy-Menü mit deinen aktuellen Auswahlmöglichkeiten angekreuzt. Klicke oder drücke Enter, um eine Auswahl umzuschalten; jede Änderung wirkt sofort. Das Abwählen einer Eingabemethode entfernt sie aus dem Zyklus, ohne sie zu deinstallieren; die Tastatur bleibt verfügbar.

Führe `omarchy setup keyboard` oder `omarchy setup input` aus, um dieselben Auswahlen zu öffnen. Um eine Sprache von der Kommandozeile anzuhängen, verwende `omarchy setup input mozc`, `hangul`, `pinyin` oder `chewing`. Deine benutzerdefinierten Umschalttasten bleiben erhalten. Für alternative Engine-Layouts oder -Tasten installiere `fcitx5-configtool` mit `omarchy pkg add fcitx5-configtool` und starte es von einem Terminal aus. Die Auswahl einer Eingabesprache ändert die Desktop-Sprache nicht.

Verwende `Super + I`, um durch Eingabemethoden oder Tastaturlayouts zu wechseln, und `Super + Shift + I`, um in die andere Richtung zu gehen, sodass du dich bei drei konfigurierten zwischen zwei Nachbarn bewegen kannst. Die Eingabeanzeige erscheint rechts in der Leiste nur, wenn mehr als eine Eingabemethode oder ein Layout konfiguriert ist. Diese Desktop-Bindung funktioniert neben deinen bestehenden Fcitx-Umschalttasten; du kannst sie in `~/.config/hypr/bindings.lua` überschreiben. Die Eingabe-Engines und die Compose-Sequenzen verwenden den Dienst [Fcitx5](https://fcitx-im.org/), der bereits in jeder Sitzung läuft.

### ALT als SUPER verwenden

An einigen Tastaturen ist es unpraktisch, die primäre Meta-Taste (Windows/cmd-Taste) als SUPER zu verwenden. Du kannst dies stattdessen mit dieser Änderung auf ALT umstellen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
