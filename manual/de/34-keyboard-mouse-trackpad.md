# Tastatur, Maus, Trackpad

Hyprland lässt dich alle deine Eingabegeräte bis ins Detail konfigurieren. Du kannst die Tastenwiederholung überschallschnell einstellen oder das Trackpad mit natürlichem Scrollen nutzen lassen. All das änderst du in `~/.config/hypr/input.lua`, die du auch über _Setup > Input_ im Omarchy-Menü (`Super + Space`) erreichst. Alles, was du dort einstellst, ersetzt die Standardeinstellungen von Omarchy.

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

Du kannst dir [alle Eingabeoptionen](https://wiki.hypr.land/Configuring/Basics/Variables/#input) auf der Hyprland-Wiki-Seite für Eingaben ansehen.

CapsLock funktioniert als normale Feststelltaste, und `Shift + CapsLock` ist die Compose-Taste für [schnelle Emojis](07-hotkeys.md#quick-emojis) und [andere Vervollständigungen](07-hotkeys.md#quick-completions). Wenn du die Compose-Taste lieber woanders haben möchtest, ersetze `omarchy:shift_caps_compose` in `kb_options`. Dieses Beispiel legt die Compose-Taste zum Beispiel auf Right Alt:

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
| Drei Finger nach links / rechts | Vorheriger / nächster Arbeitsbereich, einschließlich leerer |
| Drei Finger nach oben | Die KI-Konsole umschalten |
| Drei Finger nach unten | Das Omarchy-Menü öffnen |
| Vier Finger nach links / rechts | Das aktive Fenster auf den vorherigen / nächsten Arbeitsbereich verschieben |
| Vier Finger nach unten | Vollbild umschalten |

Um eine zu ändern, hebe sie in `~/.config/hypr/input.lua` auf, bevor du deine eigene [Touchpad-Geste](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) hinzufügst, da Hyprland keine zwei Gesten mit denselben Fingern und derselben Richtung akzeptiert:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Um alle Gesten von Omarchy auszuschalten, setze `omarchy_default_gestures = false` nahe am Anfang von `~/.config/hypr/hyprland.lua`, bevor die Standardeinstellungen von Omarchy geladen werden.

Bei Dell XPS-Laptops mit haptischem Touchpad kannst du die Klickstärke außerdem unter _Trigger > Hardware > Touchpad Haptics_ auf niedrig, mittel oder hoch einstellen.

### Auf Chinesisch, Japanisch und in anderen Sprachen tippen

Wähle Japanisch, Koreanisch, Chinesisch (vereinfacht, Pinyin), Taiwan (Zhuyin) oder Hongkong (Cangjie), wenn das Installationsprogramm nach deiner Tastatur fragt. Omarchy konfiguriert die Tastatur und die passende Eingabe-Engine automatisch, auch während der Offline-Einrichtung beim ersten Start. Japanisch verwendet Mozc, Koreanisch verwendet das standardmäßige Hangul mit zwei Zeichensätzen, vereinfachtes Chinesisch verwendet Pinyin, Taiwan verwendet Chewings standardmäßige Zhuyin-Anordnung, und Hongkong verwendet Cangjie mit Hongkong-Zeichenformen. Japanisch (US-Tastatur) bietet Mozc mit einem US-Tastaturlayout. Hangul-, Zhuyin- und Cangjie-Tasten bleiben an ihren Standardpositionen, selbst wenn du lateinische Buchstaben mit Dvorak, Colemak oder AZERTY tippst. Wenn du Hangul oder Chewing schon vorher hinzugefügt hattest, wähle es unter _Setup > Typing > Input Methods_ ab und dann erneut aus, um seine Tasten dorthin zu verschieben; eine Engine, mit der du bereits tippst, lässt Omarchy in Ruhe.

Das Tippen beginnt im lateinischen Modus. Drücke `Super + I`, um durch die konfigurierten Eingabemethoden zu wechseln, und `Super + Shift + I`, um rückwärts durch sie zu wechseln. Tippe `Shift` allein an, um aus einer Eingabemethode wie Pinyin zu lateinischen Buchstaben zu wechseln, und tippe es erneut an, um zurückzugehen, so wie es Sogou, Microsoft Pinyin und macOS machen; `Shift` plus ein Buchstabe tippt weiterhin einen Großbuchstaben. Auf japanischen Tastaturen schaltet 全角/半角 die Eingabe um, 変換 schaltet sie ein, und 無変換 schaltet sie aus. Bei Koreanisch wechselt 한/영 Hangul, und 한자 konvertiert zu Hanja, egal ob deine Tastatur dafür eigene Tasten hat oder Right Alt und Right Ctrl sendet, wie es viele Laptops tun, also sind Right Alt und Right Ctrl dort keine einfachen Modifikatortasten; das Diktat-Push-to-talk bleibt auf F9. `Ctrl + Space` bleibt für Tmux und Herdr verfügbar; `Shift + CapsLock` bleibt die Compose-Taste.

Die Tastaturanzeige erscheint rechts in der Leiste, wenn du mehrere Tastaturlayouts oder Eingabemethoden hast. Klicke darauf, um die Eingabesprachen zu wechseln; Japanisch zeigt あ für Hiragana an. Für die japanische Zeichenauswahl wechsle zu Japanisch, tippe ein Wort wie `nihongo`, und drücke dann zweimal Space. Drücke Enter, um deine Auswahl zu bestätigen. Wenn du außerdem mehrere Tastaturlayouts hast, klicke mit der rechten Maustaste auf die Anzeige, um durch sie zu wechseln.

Nutze _Setup > Typing > Keyboard Layouts_, um Layouts wie Englisch und Französisch aus denselben Auswahlmöglichkeiten auszuwählen, die auch während der Installation angeboten werden. Nutze _Setup > Typing > Input Methods_, um auszuwählen, welche Kompositions-Engines aktiv sind. Beide Auswahlfenster öffnen sich im Omarchy-Menü, wobei deine aktuelle Auswahl markiert ist. Klicke oder drücke Enter, um eine Auswahl umzuschalten; jede Änderung wird sofort wirksam. Das Abwählen einer Eingabemethode entfernt sie aus dem Wechselzyklus, ohne sie zu deinstallieren; die Tastatur bleibt verfügbar.

Führe `omarchy setup keyboard` oder `omarchy setup input` aus, um dieselben Auswahlfenster zu öffnen. Um eine Sprache über die Befehlszeile hinzuzufügen, verwende `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` oder `cangjie5`. Quick, Boshiamy und Array sind im selben Paket wie Cangjie enthalten und erscheinen im Auswahlfenster für Input Methods. Deine benutzerdefinierten Umschalttasten bleiben erhalten. Für alternative Engine-Layouts oder Tasten installiere `fcitx5-configtool` mit `omarchy pkg add fcitx5-configtool` und starte es aus einem Terminal. Das Auswählen einer Eingabesprache ändert die Desktopsprache nicht. Wenn du unter _Setup > Language_ Japanisch, Koreanisch oder Chinesisch auswählst, wird die zugehörige Eingabemethode hinzugefügt, falls du noch keine hast.

Verwende `Super + I`, um durch Eingabemethoden oder Tastaturlayouts zu wechseln, und `Super + Shift + I`, um in die andere Richtung zurückzugehen, sodass du dich mit drei konfigurierten zwischen zwei Nachbarn bewegen kannst. Die Eingabeanzeige erscheint nur dann rechts in der Leiste, wenn mehr als eine Eingabemethode oder ein Layout konfiguriert ist. Diese Desktop-Tastenkombination funktioniert neben deinen bestehenden Fcitx-Umschalttasten; du kannst sie in `~/.config/hypr/bindings.lua` überschreiben. Die Eingabe-Engines und die Compose-Sequenzen nutzen den [Fcitx5](https://fcitx-im.org/)-Dienst, der bereits in jeder Sitzung läuft.

### ALT als SUPER verwenden

Auf manchen Tastaturen ist es nicht praktisch, die primäre Meta-Taste (Windows-/cmd-Taste) als SUPER zu verwenden. Du kannst stattdessen ALT verwenden, indem du diese Änderung vornimmst:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
