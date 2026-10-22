# Tangentbord, mus, styrplatta

Hyprland låter dig konfigurera alla dina indata i stor detalj. Du kan ändra tangentbordsupprepningen till att vara överljudssnabb eller få styrplattan att använda naturlig skrollning. Du ändrar allt i `~/.config/hypr/input.lua`, som du också kan nå via _Installation > Input_ i Omarchy-menyn (`Super + Space`). Allt du ställer in där ersätter Omarchys standarder.

Här är ett exempel:

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

Du kan [se alla indataalternativ](https://wiki.hypr.land/Configuring/Basics/Variables/#input) på Hyprland-wikin för indata.

CapsLock fungerar som en vanlig Caps Lock, och `Shift + CapsLock` är compose-tangenten för [snabba emojis](07-hotkeys.md#quick-emojis) och [andra kompletteringar](07-hotkeys.md#quick-completions). Om du hellre vill ha compose-tangenten någon annanstans, ersätt `omarchy:shift_caps_compose` i `kb_options`. Till exempel, det här flyttar compose-tangenten till Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Styrplattegester

Du kan också slå på [styrplattegester](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), som att svepa med tre fingrar för att byta arbetsytor:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

På Dell XPS-laptops med en haptisk styrplatta kan du också ställa in klickstyrkan till låg, medel eller hög under _Utlös > Hardware > Styrplattehaptik_.

### Skriva på kinesiska, japanska och andra språk

Välj Japanese, Korean, Chinese (Simplified, Pinyin), eller Chinese (Traditional, Zhuyin) när installern frågar efter ditt tangentbord. Omarchy konfigurerar tangentbordet och matchande inmatningsmotor automatiskt, inklusive under offline-uppsättningen vid första starten. Japanese använder Mozc, Korean använder standard två-uppsättnings Hangul, Simplified Chinese använder Pinyin, och Traditional Chinese använder Chewings standard Zhuyin-arrangemang. Japanese (US keyboard) tillhandahåller Mozc med en US-tangentbordslayout.

Skrivandet börjar i Latin-läge. Tryck `Super + I` för att cykla genom konfigurerade inmatningsmetoder, och `Super + Shift + I` för att cykla tillbaka. Tryck `Shift` ensam för att stiga ur en inmatningsmetod som Pinyin till latinska bokstäver, och tryck den igen för att gå tillbaka, på det sätt som Sogou, Microsoft Pinyin och macOS fungerar; `Shift` plus en bokstav skriver fortfarande en versal. På japanska tangentbord växlar 全角/半角 inmatning, 変換 slår på den, och 無変換 stänger av den. På en koreansk tangentbordslayout växlar dedikerade 한/영- och 한자-tangenter Hangul och konverterar till Hanja. `Ctrl + Space` stannar tillgänglig för Tmux och Herdr; `Shift + CapsLock` stannar som compose-tangenten.

Tangentbordsindikatorn visas till höger i fältet när du har flera tangentbordslayouter eller inmatningsmetoder. Klicka på den för att byta inmatningsspråk; Japanese visar あ för hiragana. För japanska teckenval, byt till Japanese, skriv ett ord som `nihongo`, tryck sedan Space två gånger. Tryck Enter för att acceptera ditt val. Om du också har flera tangentbordslayouter, högerklicka på indikatorn för att cykla dem.

Använd _Installation > Inmatning > Tangentbordslayouter_ för att välja layouter som English och French, från samma val som erbjuds under installationen. Använd _Installation > Inmatning > Inmatningsmetoder_ för att välja vilka kompositionsmotorer som är aktiva. Båda väljarna öppnas inuti Omarchy-menyn med dina aktuella val ikryssade. Klicka eller tryck Enter för att växla ett val; varje ändring gäller omedelbart. Att avmarkera en inmatningsmetod tar bort den från cykeln utan att avinstallera den; tangentbordet stannar tillgängligt.

Kör `omarchy setup keyboard` eller `omarchy setup input` för att öppna samma väljare. För att lägga till ett språk från kommandoraden, använd `omarchy setup input mozc`, `hangul`, `pinyin` eller `chewing`. Dina anpassade bytestangenter bevaras. För alternativa motorlayouter eller tangenter, installera `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` och starta den från en terminal. Att välja ett inmatningsspråk ändrar inte skrivbordsspråket.

Använd `Super + I` för att cykla genom inmatningsmetoder eller tangentbordslayouter, och `Super + Shift + I` för att gå tillbaka åt andra hållet, så att du med tre konfigurerade kan röra dig mellan två grannar. Inmatningsindikatorn visas till höger i fältet endast när mer än en inmatningsmetod eller layout är konfigurerad. Den här skrivbordsbindningen fungerar tillsammans med dina befintliga Fcitx-bytestangenter; du kan åsidosätta den i `~/.config/hypr/bindings.lua`. Inmatningsmotorer och compose-sekvenserna använder [Fcitx5](https://fcitx-im.org/)-tjänsten som redan körs i varje session.

### Använd ALT som SUPER

På vissa tangentbord är det inte praktiskt att använda den primära meta-tangenten (Windows/cmd-tangenten) som SUPER. Du kan ändra detta till att vara ALT istället med den här ändringen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
