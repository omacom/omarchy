# Tastatur, Maus, Trackpad

Hyprland lässt dich alle deine Eingabegeräte bis ins Detail konfigurieren. Du kannst die Tastenwiederholung überschallschnell machen oder das Trackpad natürliches Scrollen verwenden lassen. All das änderst du in `~/.config/hypr/input.lua`, die du auch über _Setup > Input_ im Omarchy-Menü (`Super + Space`) erreichst. Alles, was du dort einstellst, ersetzt die Standardwerte von Omarchy.

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

Du kannst [alle Eingabeoptionen](https://wiki.hypr.land/Configuring/Basics/Variables/#input) für Eingaben im Hyprland-Wiki ansehen.

CapsLock funktioniert als normale Feststelltaste, und `Shift + CapsLock` ist die Compose-Taste für [schnelle Emojis](07-hotkeys.md#quick-emojis) und [andere Vervollständigungen](07-hotkeys.md#quick-completions). Wenn du die Compose-Taste lieber woanders hättest, ersetze `omarchy:shift_caps_compose` in `kb_options`. Zum Beispiel verschiebt dies die Compose-Taste auf Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funktionstasten

Die oberste Reihe einer Laptop-Tastatur sendet standardmäßig die Medientasten (Lautstärke, Helligkeit und so weiter), und wenn du `Fn` gedrückt hältst, erhältst du F1-F12; `Fn + Esc` sperrt das umgekehrt, bis du es erneut drückst. Die meisten Tastaturen merken sich diese Sperre selbst. ASUS-Laptops und Tastaturen im Apple-Stil überlassen das Linux, das sie bei jedem Start mit den Medientasten startet. Damit sie stattdessen mit F1-F12 starten, führe `omarchy keyboard toprow fnkeys` aus (und `omarchy keyboard toprow mediakeys`, um zurückzugehen); bei manchen Laptops wird das erst nach einem Neustart wirksam. Apple Silicon Macs behalten ihre eigene Einstellung.

### Trackpad-Gesten

Wische auf dem Trackpad, um dich auf dem Desktop zu bewegen:

| Geste | Aktion |
| --- | --- |
| Drei Finger nach links / rechts | Vorheriger / nächster Arbeitsbereich, einschließlich leerer |
| Drei Finger nach oben | Die KI-Konsole umschalten |
| Drei Finger nach unten | Das Omarchy-Menü öffnen |
| Vier Finger nach links / rechts | Das aktive Fenster auf den vorherigen / nächsten Arbeitsbereich verschieben |
| Vier Finger nach unten | Vollbild umschalten |

Um eine zu ändern, hebe sie in `~/.config/hypr/input.lua` auf, bevor du deine eigene [Touchpad-Geste](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) hinzufügst, da Hyprland keine zwei Gesten mit denselben Fingern und in derselben Richtung akzeptiert:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Um alle Gesten von Omarchy auszuschalten, setze `omarchy_default_gestures = false` oben in `~/.config/hypr/hyprland.lua`, bevor die Standardwerte von Omarchy geladen werden.

Bei Dell XPS-Laptops mit einem haptischen Touchpad kannst du die Klickstärke außerdem unter _Trigger > Hardware > Touchpad Haptics_ auf low, mid oder high einstellen.

### Auf Chinesisch, Japanisch und in anderen Sprachen tippen

Wähle Japanisch, Koreanisch, Chinesisch (Vereinfacht, Pinyin), Taiwan (Zhuyin) oder Hong Kong (Cangjie), wenn das Installationsprogramm nach deiner Tastatur fragt. Omarchy konfiguriert die Tastatur und die passende Eingabe-Engine automatisch, auch während der Offline-Einrichtung beim ersten Start. Japanisch verwendet Mozc, Koreanisch verwendet das standardmäßige Hangul mit zwei Sätzen, vereinfachtes Chinesisch verwendet Pinyin, Taiwan verwendet Chewings standardmäßige Zhuyin-Anordnung und Hong Kong verwendet Cangjie mit Hong-Kong-Zeichenformen. Japanisch (US-Tastatur) bietet Mozc mit einem US-Tastaturlayout. Die Tasten für Hangul, Zhuyin und Cangjie bleiben an ihren Standardpositionen, selbst wenn du lateinische Buchstaben mit Dvorak, Colemak oder AZERTY tippst. Wenn du Hangul oder Chewing schon vorher hinzugefügt hast, wähle es unter _Setup > Keyboard > Input Methods_ ab und wieder aus, um seine Tasten dorthin zu verschieben; Omarchy lässt eine Engine, mit der du bereits tippst, in Ruhe.

Das Tippen beginnt im lateinischen Modus. Drücke `Super + I`, um durch die konfigurierten Eingabemethoden zu wechseln, und `Super + Shift + I`, um rückwärts zu wechseln. Tippe `Shift` für sich allein an, um aus einer Eingabemethode wie Pinyin zu lateinischen Buchstaben zu wechseln, und tippe es erneut an, um zurückzugehen, so wie es bei Sogou, Microsoft Pinyin und macOS funktioniert; `Shift` plus ein Buchstabe tippt weiterhin einen Großbuchstaben. Auf japanischen Tastaturen schaltet 全角/半角 die Eingabe um, 変換 schaltet sie ein und 無変換 schaltet sie aus. Bei Koreanisch wechselt 한/영 Hangul und 한자 konvertiert zu Hanja, egal ob deine Tastatur dafür eigene Tasten hat oder Right Alt und Right Ctrl dafür sendet, wie es viele Laptops tun, also sind Right Alt und Right Ctrl dort keine einfachen Modifikatortasten; die Diktierfunktion schaltet stattdessen mit Alt + Space um. `Ctrl + Space` bleibt für Tmux und Herdr verfügbar; `Shift + CapsLock` bleibt die Compose-Taste.

Die Tastaturanzeige erscheint rechts in der Leiste, wenn du mehrere Tastaturlayouts oder Eingabemethoden hast. Klicke sie an, um die Eingabesprachen zu wechseln; Japanisch zeigt あ für Hiragana. Für japanische Zeichenauswahlen wechsle zu Japanisch, tippe ein Wort wie `nihongo` und drücke dann zweimal Space. Drücke Enter, um deine Auswahl zu bestätigen. Wenn du auch mehrere Tastaturlayouts hast, klicke mit der rechten Maustaste auf die Anzeige, um durch diese zu wechseln.

Verwende _Setup > Keyboard > Keyboard Inputs_, um Layouts wie Englisch und Französisch aus denselben Auswahlmöglichkeiten auszuwählen, die auch während der Installation angeboten werden. Verwende _Setup > Keyboard > Input Methods_, um auszuwählen, welche Kompositions-Engines aktiv sind. Beide Auswahlfenster öffnen sich im Omarchy-Menü, wobei deine aktuellen Auswahlen markiert sind. Klicke oder drücke Enter, um eine Auswahl umzuschalten; jede Änderung wird sofort wirksam. Das Abwählen einer Eingabemethode entfernt sie aus dem Wechselzyklus, ohne sie zu deinstallieren; die Tastatur bleibt verfügbar.

Führe `omarchy setup keyboard` oder `omarchy setup input` aus, um dieselben Auswahlfenster zu öffnen. Um eine Sprache von der Befehlszeile aus anzuhängen, verwende `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` oder `cangjie5`. Quick, Boshiamy und Array sind im selben Paket wie Cangjie enthalten und erscheinen im Auswahlfenster für Input Methods. Deine benutzerdefinierten Umschalttasten bleiben erhalten. Für alternative Engine-Layouts oder Tasten installiere `fcitx5-configtool` mit `omarchy pkg add fcitx5-configtool` und starte es von einem Terminal aus. Das Auswählen einer Eingabesprache ändert die Desktop-Sprache nicht. Wenn du unter _Setup > Language_ Japanisch, Koreanisch oder Chinesisch wählst, wird die zugehörige Eingabemethode hinzugefügt, wenn du noch keine hast.

Verwende `Super + I`, um durch Eingabemethoden oder Tastaturlayouts zu wechseln, und `Super + Shift + I`, um in die andere Richtung zurückzugehen, sodass du dich mit drei konfigurierten zwischen zwei Nachbarn bewegen kannst. Die Eingabeanzeige erscheint nur dann rechts in der Leiste, wenn mehr als eine Eingabemethode oder ein Layout konfiguriert ist. Diese Desktop-Tastenkombination funktioniert neben deinen bestehenden Fcitx-Umschalttasten; du kannst sie in `~/.config/hypr/bindings.lua` überschreiben. Die Eingabe-Engines und die Compose-Sequenzen verwenden den [Fcitx5](https://fcitx-im.org/)-Dienst, der bereits in jeder Sitzung läuft.

### ALT als SUPER verwenden

Bei manchen Tastaturen ist es nicht praktisch, die primäre Meta-Taste (Windows/cmd-Taste) als SUPER zu verwenden. Du kannst das stattdessen mit dieser Änderung auf ALT ändern:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
