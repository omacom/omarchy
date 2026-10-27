# Tastatur, Maus, Trackpad

Hyprland lässt dich alle deine Eingabegeräte sehr detailliert konfigurieren. Du kannst die Tastenwiederholung überschallschnell machen oder das Trackpad natürliches Scrollen verwenden lassen. Du änderst all das in `~/.config/hypr/input.lua`, was du auch über _Setup > Input_ im Omarchy-Menü (`Super + Space`) erreichen kannst. Alles, was du dort einstellst, ersetzt Omarchys Standardeinstellungen.

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

CapsLock funktioniert als normale Caps Lock, und `Shift + CapsLock` ist die Compose-Taste für [schnelle Emojis](07-hotkeys.md#quick-emojis) und [andere Vervollständigungen](07-hotkeys.md#quick-completions). Wenn du die Compose-Taste lieber woanders haben möchtest, ersetze `omarchy:shift_caps_compose` in `kb_options`. Dieses Beispiel verschiebt die Compose-Taste zum Beispiel auf Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Trackpad-Gesten

Du kannst auch [Touchpad-Gesten](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) aktivieren, etwa mit drei Fingern wischen, um Workspaces zu wechseln:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Bei Dell XPS-Laptops mit haptischem Touchpad kannst du die Klickstärke außerdem unter _Trigger > Hardware > Touchpad Haptics_ auf low, mid oder high einstellen.

### Auf Chinesisch, Japanisch und in anderen Sprachen tippen

Wähle Japanisch, Koreanisch, Chinesisch (Vereinfacht, Pinyin), Taiwan (Zhuyin) oder Hong Kong (Cangjie), wenn das Installationsprogramm nach deiner Tastatur fragt. Omarchy konfiguriert die Tastatur und die passende Eingabe-Engine automatisch, auch während der Offline-Einrichtung beim ersten Start. Japanisch verwendet Mozc, Koreanisch verwendet das standardmäßige Zwei-Satz-Hangul, Vereinfachtes Chinesisch verwendet Pinyin, Taiwan verwendet Chewings standardmäßige Zhuyin-Anordnung und Hong Kong verwendet Cangjie mit Hong Kong-Zeichenformen. Japanisch (US-Tastatur) bietet Mozc mit einem US-Tastaturlayout. Die Tasten für Hangul, Zhuyin und Cangjie bleiben an ihren Standardpositionen, selbst wenn du lateinische Buchstaben mit Dvorak, Colemak oder AZERTY tippst. Wenn du Hangul oder Chewing vor dem hier hinzugefügt hast, wähle es unter _Setup > Typing > Input Methods_ ab und wieder aus, um seine Tasten dorthin zu verschieben; Omarchy lässt eine Engine, mit der du bereits tippst, in Ruhe.

Das Tippen beginnt im Latin-Modus. Drücke `Super + I`, um durch die konfigurierten Eingabemethoden zu wechseln, und `Super + Shift + I`, um in die andere Richtung zu wechseln. Tippe `Shift` für sich allein an, um aus einer Eingabemethode wie Pinyin zu lateinischen Buchstaben zu wechseln, und tippe es erneut an, um zurückzugehen, so wie Sogou, Microsoft Pinyin und macOS funktionieren; `Shift` plus ein Buchstabe tippt weiterhin einen Großbuchstaben. Auf japanischen Tastaturen schaltet 全角/半角 die Eingabe um, 変換 schaltet sie ein und 無変換 schaltet sie aus. Bei Koreanisch wechselt 한/영 Hangul und 한자 wandelt in Hanja um, egal ob deine Tastatur dedizierte Tasten hat oder dafür Right Alt und Right Ctrl sendet, wie es viele Laptops tun, also sind Right Alt und Right Ctrl dort keine einfachen Modifikatortasten; die Push-to-Talk-Funktion für Diktate bleibt auf F9. `Ctrl + Space` bleibt für Tmux und Herdr verfügbar; `Shift + CapsLock` bleibt die Compose-Taste.

Die Tastaturanzeige erscheint rechts in der Leiste, wenn du mehrere Tastaturlayouts oder Eingabemethoden hast. Klicke darauf, um die Eingabesprachen zu wechseln; Japanisch zeigt あ für Hiragana. Für japanische Zeichenauswahlen wechsle zu Japanisch, tippe ein Wort wie `nihongo` und drücke dann zweimal Space. Drücke Enter, um deine Auswahl zu übernehmen. Wenn du auch mehrere Tastaturlayouts hast, klicke mit der rechten Maustaste auf die Anzeige, um durch diese zu wechseln.

Verwende _Setup > Typing > Keyboard Layouts_, um Layouts wie Englisch und Französisch aus denselben Auswahlmöglichkeiten auszuwählen, die während der Installation angeboten werden. Verwende _Setup > Typing > Input Methods_, um auszuwählen, welche Kompositions-Engines aktiv sind. Beide Auswahlfenster öffnen sich innerhalb des Omarchy-Menüs mit deinen aktuellen Auswahlen angehakt. Klicke oder drücke Enter, um eine Auswahl umzuschalten; jede Änderung gilt sofort. Das Abwählen einer Eingabemethode entfernt sie aus dem Zyklus, ohne sie zu deinstallieren; die Tastatur bleibt verfügbar.

Führe `omarchy setup keyboard` oder `omarchy setup input` aus, um dieselben Auswahlfenster zu öffnen. Um eine Sprache über die Kommandozeile anzuhängen, verwende `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` oder `cangjie5`. Quick, Boshiamy und Array kommen im selben Paket wie Cangjie und erscheinen im Auswahlfenster für Input Methods. Deine benutzerdefinierten Umschalttasten bleiben erhalten. Für alternative Engine-Layouts oder -Tasten installiere `fcitx5-configtool` mit `omarchy pkg add fcitx5-configtool` und starte es von einem Terminal aus. Die Auswahl einer Eingabesprache ändert die Desktopsprache nicht. Die Auswahl von Japanisch, Koreanisch oder Chinesisch unter _Setup > Language_ fügt ihre Eingabemethode hinzu, wenn du noch keine hast.

Verwende `Super + I`, um durch Eingabemethoden oder Tastaturlayouts zu wechseln, und `Super + Shift + I`, um in die andere Richtung zurückzugehen, sodass du dich mit drei konfigurierten zwischen zwei Nachbarn bewegen kannst. Die Eingabeanzeige erscheint nur dann rechts in der Leiste, wenn mehr als eine Eingabemethode oder ein Layout konfiguriert ist. Diese Desktop-Tastenkombination funktioniert neben deinen bestehenden Fcitx-Umschalttasten; du kannst sie in `~/.config/hypr/bindings.lua` überschreiben. Eingabe-Engines und die Compose-Sequenzen verwenden den [Fcitx5](https://fcitx-im.org/)-Dienst, der bereits in jeder Sitzung läuft.

### ALT als SUPER verwenden

Auf manchen Tastaturen ist es nicht bequem, die primäre Meta-Taste (Windows/cmd-Taste) als SUPER zu verwenden. Du kannst das mit dieser Änderung stattdessen auf ALT umstellen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
