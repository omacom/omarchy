# Tastatur, Maus, Trackpad

In Hyprland kannst du alle deine Eingabegeräte bis ins Detail konfigurieren. Du kannst die Tastenwiederholung überschallschnell machen oder das Trackpad mit natürlichem Scrollen verwenden. All das änderst du in `~/.config/hypr/input.lua`, auch erreichbar über _Setup > Input_ im Omarchy-Menü (`Super + Space`). Alles, was du dort festlegst, ersetzt Omarchys Standardeinstellungen.

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

Du kannst [alle Eingabeoptionen ansehen](https://wiki.hypr.land/Configuring/Basics/Variables/#input) in der Hyprland-Wiki zu Eingaben.

CapsLock funktioniert als normale Feststelltaste, und `Shift + CapsLock` ist die Compose-Taste für [schnelle Emojis](07-hotkeys.md#quick-emojis) und [andere Vervollständigungen](07-hotkeys.md#quick-completions). Wenn du die Compose-Taste lieber woanders haben willst, ersetze `omarchy:shift_caps_compose` in `kb_options`. Zum Beispiel verschiebt dies die Compose-Taste auf Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad-Gesten

Wische auf dem Trackpad, um dich auf dem Desktop zu bewegen:

| Geste | Aktion |
| --- | --- |
| Drei Finger nach links / rechts | Vorheriger / nächster Workspace, auch leere |
| Drei Finger nach oben | KI-Konsole umschalten |
| Drei Finger nach unten | Omarchy-Menü öffnen |
| Vier Finger nach links / rechts | Aktives Fenster auf den vorherigen / nächsten Workspace verschieben |
| Vier Finger nach unten | Vollbild umschalten |

Um eine Geste zu ändern, hebe sie in `~/.config/hypr/input.lua` auf, bevor du deine eigene [Touchpad-Geste](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) hinzufügst, denn Hyprland akzeptiert keine zwei Gesten mit denselben Fingern und in dieselbe Richtung:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Um alle Gesten von Omarchy auszuschalten, setze `omarchy_default_gestures = false` oben in `~/.config/hypr/hyprland.lua`, bevor Omarchys Standardeinstellungen geladen werden.

Bei Dell XPS-Laptops mit haptischem Touchpad kannst du die Klickstärke auch unter _Trigger > Hardware > Touchpad Haptics_ auf niedrig, mittel oder hoch einstellen.

### Auf Chinesisch, Japanisch und in anderen Sprachen tippen

Wähle Japanisch, Koreanisch, Chinesisch (vereinfacht, Pinyin), Taiwan (Zhuyin) oder Hong Kong (Cangjie), wenn das Installationsprogramm nach deiner Tastatur fragt. Omarchy konfiguriert die Tastatur und die passende Eingabe-Engine automatisch, auch bei der Offline-Einrichtung beim ersten Start. Japanisch nutzt Mozc, Koreanisch nutzt das standardmäßige Zwei-Satz-Hangul, vereinfachtes Chinesisch nutzt Pinyin, Taiwan nutzt Chewings standardmäßige Zhuyin-Anordnung und Hong Kong nutzt Cangjie mit Hong-Kong-Zeichenformen. Japanisch (US-Tastatur) bietet Mozc mit einem US-Tastaturlayout. Die Tasten für Hangul, Zhuyin und Cangjie bleiben an ihren Standardpositionen, auch wenn du lateinische Buchstaben mit Dvorak, Colemak oder AZERTY tippst. Wenn du Hangul oder Chewing schon vorher hinzugefügt hast, wähle es unter _Setup > Typing > Input Methods_ ab und wieder aus, um seine Tasten dorthin zu verschieben; eine Engine, mit der du bereits tippst, lässt Omarchy in Ruhe.

Das Tippen beginnt im Latin-Modus. Drücke `Super + I`, um durch die konfigurierten Eingabemethoden zu wechseln, und `Super + Shift + I`, um rückwärts durchzuwechseln. Tippe `Shift` für sich allein an, um aus einer Eingabemethode wie Pinyin zu lateinischen Buchstaben zu wechseln, und tippe es erneut an, um zurückzugehen, so wie Sogou, Microsoft Pinyin und macOS es machen; `Shift` plus ein Buchstabe schreibt weiterhin einen Großbuchstaben. Auf japanischen Tastaturen schaltet 全角/半角 die Eingabe um, 変換 schaltet sie ein und 無変換 schaltet sie aus. Bei Koreanisch wechselt 한/영 zu Hangul und 한자 konvertiert zu Hanja, egal ob deine Tastatur dafür eigene Tasten hat oder Right Alt und Right Ctrl dafür sendet, wie es viele Laptops tun, also sind Right Alt und Right Ctrl dort keine einfachen Modifikatortasten; die Diktierfunktion schaltet stattdessen mit Alt + Space um. `Ctrl + Space` bleibt für Tmux und Herdr verfügbar; `Shift + CapsLock` bleibt die Compose-Taste.

Die Tastaturanzeige erscheint rechts in der Leiste, wenn du mehrere Tastaturlayouts oder Eingabemethoden hast. Klicke darauf, um die Eingabesprachen zu wechseln; Japanisch zeigt あ für Hiragana an. Für die japanische Zeichenauswahl wechsle zu Japanisch, tippe ein Wort wie `nihongo` und drücke dann zweimal Space. Drücke Enter, um deine Auswahl zu übernehmen. Wenn du auch mehrere Tastaturlayouts hast, klicke mit der rechten Maustaste auf die Anzeige, um durch diese zu wechseln.

Nutze _Setup > Typing > Keyboard Layouts_, um Layouts wie Englisch und Französisch auszuwählen, aus denselben Optionen, die auch bei der Installation angeboten werden. Nutze _Setup > Typing > Input Methods_, um auszuwählen, welche Composition-Engines aktiv sind. Beide Auswahlfenster öffnen sich im Omarchy-Menü, mit deinen aktuellen Auswahlen angehakt. Klicke oder drücke Enter, um eine Option umzuschalten; jede Änderung gilt sofort. Das Abwählen einer Eingabemethode entfernt sie aus dem Wechselzyklus, ohne sie zu deinstallieren; die Tastatur bleibt verfügbar.

Führe `omarchy setup keyboard` oder `omarchy setup input` aus, um dieselben Auswahlfenster zu öffnen. Um eine Sprache über die Befehlszeile anzuhängen, nutze `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` oder `cangjie5`. Quick, Boshiamy und Array sind im selben Paket wie Cangjie enthalten und erscheinen in der Auswahl für Input Methods. Deine eigenen Umschalttasten bleiben erhalten. Für alternative Engine-Layouts oder Tasten installiere `fcitx5-configtool` mit `omarchy pkg add fcitx5-configtool` und starte es aus einem Terminal. Die Auswahl einer Eingabesprache ändert die Desktopsprache nicht. Die Auswahl von Japanisch, Koreanisch oder Chinesisch unter _Setup > Language_ fügt seine Eingabemethode hinzu, wenn du noch keine hast.

Nutze `Super + I`, um durch Eingabemethoden oder Tastaturlayouts zu wechseln, und `Super + Shift + I`, um in die andere Richtung zurückzugehen, sodass du dich mit drei konfigurierten zwischen zwei Nachbarn bewegen kannst. Die Eingabeanzeige erscheint nur dann rechts in der Leiste, wenn mehr als eine Eingabemethode oder ein Layout konfiguriert ist. Diese Desktop-Tastenkombination funktioniert neben deinen bestehenden Fcitx-Umschalttasten; du kannst sie in `~/.config/hypr/bindings.lua` überschreiben. Die Eingabe-Engines und die Compose-Sequenzen nutzen den [Fcitx5](https://fcitx-im.org/)-Dienst, der bereits in jeder Sitzung läuft.

### ALT als SUPER verwenden

Bei manchen Tastaturen ist es nicht praktisch, die primäre Meta-Taste (Windows/cmd-Taste) als SUPER zu verwenden. Du kannst stattdessen ALT dafür verwenden, mit dieser Änderung:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
