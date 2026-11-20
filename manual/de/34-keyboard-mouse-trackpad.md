# Tastatur, Maus, Trackpad

Hyprland lässt dich alle deine Eingabegeräte bis ins kleinste Detail konfigurieren. Du kannst die Tastaturwiederholung Überschall-schnell machen oder das Trackpad mit natürlichem Scrollen nutzen lassen. Ändern kannst du alles in `~/.config/hypr/input.lua`, erreichbar auch über _Setup > Input_ im Omarchy-Menü (`Super + Space`). Alles, was du dort einstellst, ersetzt Omarchys Standardwerte.

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

Du findest [alle Eingabeoptionen](https://wiki.hypr.land/Configuring/Basics/Variables/#input) im Hyprland-Wiki für Eingaben.

CapsLock funktioniert als normale Caps Lock, und `Shift + CapsLock` ist die Compose-Taste für [schnelle Emojis](07-hotkeys.md#quick-emojis) und [weitere Vervollständigungen](07-hotkeys.md#quick-completions). Wenn du die Compose-Taste lieber woanders haben willst, ersetze `omarchy:shift_caps_compose` in `kb_options`. Dieses Beispiel verschiebt die Compose-Taste zum Beispiel auf Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funktionstasten

Die obere Reihe einer Laptop-Tastatur sendet standardmäßig die Medientasten (Lautstärke, Helligkeit und so weiter), und mit gedrückter `Fn`-Taste erhältst du F1-F12; `Fn + Esc` sperrt das andersherum, bis du die Kombination erneut drückst. Die meisten Tastaturen merken sich diese Sperre selbst. ASUS-Laptops und Tastaturen im Apple-Stil überlassen das Linux, das sie bei jedem Start mit den Medientasten startet. Damit sie stattdessen mit F1-F12 starten, führe `omarchy device keyboard toprow fnkeys` aus (und `omarchy device keyboard toprow mediakeys`, um zurück zu wechseln); bei manchen Laptops wird das erst nach einem Neustart wirksam. Apple Silicon Macs behalten ihre eigene Einstellung.

### Trackpad-Gesten

Wische auf dem Trackpad, um dich auf dem Desktop zu bewegen:

| Geste | Aktion |
| --- | --- |
| Drei Finger nach links / rechts | Vorheriger / nächster Workspace, einschließlich leerer |
| Drei Finger nach oben | Die AI-Konsole umschalten |
| Drei Finger nach unten | Das Omarchy-Menü öffnen |
| Vier Finger nach links / rechts | Das aktive Fenster auf den vorherigen / nächsten Workspace verschieben |
| Vier Finger nach unten | Vollbild umschalten |

Um eine Geste zu ändern, lösche sie in `~/.config/hypr/input.lua`, bevor du deine eigene [Touchpad-Geste](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) hinzufügst, denn Hyprland akzeptiert keine zwei Gesten für dieselben Finger in dieselbe Richtung:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Um alle Gesten von Omarchy auszuschalten, setze `omarchy_default_gestures = false` oben in `~/.config/hypr/hyprland.lua`, bevor Omarchys Standardwerte geladen werden.

Bei Dell XPS-Laptops mit einem haptischen Touchpad kannst du außerdem die Klickstärke unter _Trigger > Hardware > Touchpad Haptics_ auf low, mid oder high einstellen.

### Auf Chinesisch, Japanisch und in anderen Sprachen tippen

Wähle Japanisch, Koreanisch, Chinesisch (vereinfacht, Pinyin), Taiwan (Zhuyin) oder Hongkong (Cangjie), wenn das Installationsprogramm nach deiner Tastatur fragt. Omarchy konfiguriert die Tastatur und die passende Input-Engine automatisch, auch während der Offline-Ersteinrichtung beim ersten Start. Japanisch nutzt Mozc, Koreanisch nutzt das standardmäßige Two-Set-Hangul, vereinfachtes Chinesisch nutzt Pinyin, Taiwan nutzt Chewings standardmäßige Zhuyin-Anordnung, und Hongkong nutzt Cangjie mit Hongkonger Schriftformen. Japanisch (US-Tastatur) bietet Mozc mit einem US-Tastaturlayout. Die Tasten für Hangul, Zhuyin und Cangjie bleiben an ihren Standardpositionen, auch wenn du lateinische Buchstaben mit Dvorak, Colemak oder AZERTY tippst. Falls du Hangul oder Chewing schon vorher hinzugefügt hattest, wähle es unter _Setup > Keyboard > Input Methods_ ab und wieder aus, um seine Tasten dorthin zu verschieben; Omarchy lässt eine Engine, mit der du bereits tippst, in Ruhe.

Das Tippen beginnt im Latin-Modus. Drücke `Super + I`, um durch die konfigurierten Eingabemethoden zu wechseln, und `Super + Shift + I`, um in der anderen Richtung zu wechseln. Tippe `Shift` allein an, um aus einer Eingabemethode wie Pinyin zu lateinischen Buchstaben zu wechseln, und tippe sie erneut an, um zurückzugehen, so wie Sogou, Microsoft Pinyin und macOS arbeiten; `Shift` plus ein Buchstabe tippt weiterhin einen Großbuchstaben. Auf japanischen Tastaturen schaltet 全角/半角 die Eingabe um, 変換 schaltet sie ein und 無変換 schaltet sie aus. Bei Koreanisch wechselt 한/영 Hangul, und 한자 wandelt in Hanja um, egal ob deine Tastatur dafür eigene Tasten hat oder Right Alt und Right Ctrl sendet, wie viele Laptops das tun; Right Alt und Right Ctrl sind dort also keine einfachen Modifier, stattdessen schaltet Diktieren mit Alt + Space um. `Ctrl + Space` bleibt für Tmux und Herdr verfügbar; `Shift + CapsLock` bleibt die Compose-Taste.

Die Tastaturanzeige erscheint rechts in der Leiste, wenn du mehrere Tastaturlayouts oder Eingabemethoden hast. Klicke sie, um die Eingabesprachen zu wechseln; Japanisch zeigt あ für Hiragana an. Für japanische Zeichenauswahl wechsle zu Japanisch, tippe ein Wort wie `nihongo` und drücke dann zweimal Space. Drücke Enter, um deine Auswahl zu übernehmen. Wenn du auch mehrere Tastaturlayouts hast, rechtsklicke die Anzeige, um durch diese zu wechseln.

Nutze _Setup > Keyboard > Keyboard Inputs_, um Layouts wie Englisch und Französisch aus denselben Auswahlmöglichkeiten auszuwählen, die auch während der Installation angeboten werden. Nutze _Setup > Keyboard > Input Methods_, um auszuwählen, welche Composition-Engines aktiv sind. Beide Auswahlfenster öffnen sich im Omarchy-Menü mit deinen aktuell ausgewählten Einträgen abgehakt. Klicke oder drücke Enter, um eine Auswahl umzuschalten; jede Änderung wird sofort übernommen. Wenn du eine Eingabemethode abwählst, wird sie aus dem Wechsel entfernt, ohne deinstalliert zu werden; die Tastatur bleibt verfügbar.

Führe `omarchy setup keyboard` oder `omarchy setup input` aus, um dieselben Auswahlfenster zu öffnen. Um eine Sprache über die Kommandozeile hinzuzufügen, nutze `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` oder `cangjie5`. Quick, Boshiamy und Array sind im selben Paket wie Cangjie enthalten und erscheinen im Auswahlfenster für Input Methods. Deine eigenen Umschalttasten bleiben erhalten. Für alternative Engine-Layouts oder Tasten installieren `fcitx5-configtool` mit `omarchy pkg add fcitx5-configtool` und starte es von einem Terminal aus. Die Auswahl einer Eingabesprache ändert die Desktop-Sprache nicht. Wenn du unter _Setup > Language_ Japanisch, Koreanisch oder Chinesisch auswählst, wird dessen Eingabemethode hinzugefügt, solange du noch keine hast.

Nutze `Super + I`, um durch Eingabemethoden oder Tastaturlayouts zu wechseln, und `Super + Shift + I`, um in der anderen Richtung zu gehen, sodass du dich mit drei konfigurierten Einträgen zwischen zwei Nachbarn bewegen kannst. Die Eingabeanzeige erscheint nur dann rechts in der Leiste, wenn mehr als eine Eingabemethode oder ein Layout konfiguriert ist. Diese Desktop-Tastenkombination funktioniert neben deinen bestehenden Fcitx-Umschalttasten; du kannst sie in `~/.config/hypr/bindings.lua` überschreiben. Die Eingabe-Engines und die Compose-Sequenzen nutzen den Dienst [Fcitx5](https://fcitx-im.org/), der bereits in jeder Sitzung läuft.

### ALT als SUPER verwenden

Bei manchen Tastaturen ist es nicht bequem, die primäre Meta-Taste (Windows/cmd-Taste) als SUPER zu verwenden. Stattdessen kannst du mit dieser Änderung ALT dafür nutzen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
