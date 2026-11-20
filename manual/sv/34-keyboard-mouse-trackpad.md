# Tangentbord, mus, styrplatta

Hyprland låter dig konfigurera alla dina inmatningsenheter i minsta detalj. Du kan göra tangentbordsupprepningen överljudssnabb eller få styrplattan att använda naturlig rullning. Allt det ändrar du i `~/.config/hypr/input.lua`, som du också når via _Setup > Input_ i Omarchy-menyn (`Super + Space`). Allt du ställer in där ersätter Omarchys standardinställningar.

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

Du kan [se alla inmatningsalternativ](https://wiki.hypr.land/Configuring/Basics/Variables/#input) på Hyprland-wikin för inmatning.

CapsLock fungerar som en vanlig Caps Lock, och `Shift + CapsLock` är compose-tangenten för [snabba emojier](07-hotkeys.md#quick-emojis) och [andra kompletteringar](07-hotkeys.md#quick-completions). Om du hellre vill ha compose-tangenten någon annanstans ersätter du `omarchy:shift_caps_compose` i `kb_options`. Det här flyttar till exempel compose-tangenten till Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funktionstangenter

Den översta raden på ett bärbart tangentbord skickar medietangenterna (volym, ljusstyrka och så vidare) som standard, och om du håller ned `Fn` får du F1-F12; `Fn + Esc` låser det åt andra hållet tills du trycker på det igen. De flesta tangentbord kommer själva ihåg det låset. Bärbara datorer från ASUS och tangentbord i Apple-stil lämnar det till Linux, som startar dem på medietangenterna vid varje uppstart. För att de i stället ska starta på F1-F12 kör du `omarchy device keyboard toprow fnkeys` (och `omarchy device keyboard toprow mediakeys` för att gå tillbaka); på vissa bärbara datorer börjar det gälla efter en omstart. Mac-datorer med Apple Silicon behåller sin egen inställning.

### Gester på styrplattan

Svep på styrplattan för att röra dig runt på skrivbordet:

| Gest | Åtgärd |
| --- | --- |
| Tre fingrar åt vänster / höger | Föregående / nästa arbetsyta, inklusive tomma |
| Tre fingrar uppåt | Växla AI-konsolen |
| Tre fingrar nedåt | Öppna Omarchy-menyn |
| Fyra fingrar åt vänster / höger | Flytta det aktiva fönstret till föregående / nästa arbetsyta |
| Fyra fingrar nedåt | Växla helskärm |

För att ändra en gest tar du bort den i `~/.config/hypr/input.lua` innan du lägger till din egen [gest för styrplattan](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), eftersom Hyprland inte accepterar två gester med samma fingrar och riktning:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

För att stänga av alla Omarchys gester ställer du in `omarchy_default_gestures = false` nära början av `~/.config/hypr/hyprland.lua`, innan Omarchys standardinställningar laddas.

På bärbara Dell XPS-datorer med en haptisk styrplatta kan du också ställa in klickstyrkan på låg, medel eller hög under _Trigger > Hardware > Touchpad Haptics_.

### Skriva på kinesiska, japanska och andra språk

Välj japanska, koreanska, kinesiska (förenklad, Pinyin), Taiwan (Zhuyin) eller Hongkong (Cangjie) när installationsprogrammet frågar efter ditt tangentbord. Omarchy konfigurerar tangentbordet och den matchande inmatningsmotorn automatiskt, även under installationen vid första uppstarten utan internet. Japanska använder Mozc, koreanska använder standard-Hangul med två uppsättningar, förenklad kinesiska använder Pinyin, Taiwan använder Chewings standardarrangemang för Zhuyin och Hongkong använder Cangjie med teckenformer från Hongkong. Japanska (amerikanskt tangentbord) ger Mozc med en amerikansk tangentbordslayout. Tangenterna för Hangul, Zhuyin och Cangjie stannar på sina standardpositioner även när du skriver latinska bokstäver med Dvorak, Colemak eller AZERTY. Om du lade till Hangul eller Chewing före detta avmarkerar du och markerar det igen under _Setup > Keyboard > Input Methods_ för att flytta dess tangenter dit; Omarchy lämnar en motor som du redan skriver med i fred.

Skrivandet börjar i latinskt läge. Tryck på `Super + I` för att bläddra igenom konfigurerade inmatningsmetoder och på `Super + Shift + I` för att bläddra bakåt. Tryck på `Shift` för sig för att kliva ut ur en inmatningsmetod som Pinyin till latinska bokstäver och tryck på den igen för att gå tillbaka, på samma sätt som Sogou, Microsoft Pinyin och macOS fungerar; `Shift` plus en bokstav skriver fortfarande en versal. På japanska tangentbord växlar 全角/半角 inmatning, 変換 slår på den och 無変換 stänger av den. Med koreanska växlar 한/영 Hangul och 한자 konverterar till Hanja, oavsett om ditt tangentbord har dedikerade tangenter eller skickar Right Alt och Right Ctrl för dem, som många bärbara datorer gör, så Right Alt och Right Ctrl är inte vanliga modifierartangenter där; diktering växlas i stället med Alt + Space. `Ctrl + Space` förblir tillgängligt för Tmux och Herdr; `Shift + CapsLock` förblir compose-tangenten.

Tangentbordsindikatorn visas till höger i fältet när du har flera tangentbordslayouter eller inmatningsmetoder. Klicka på den för att byta inmatningsspråk; japanska visar あ för hiragana. För japanska teckenval byter du till japanska, skriver ett ord som `nihongo` och trycker sedan på Space två gånger. Tryck på Enter för att acceptera ditt val. Om du också har flera tangentbordslayouter högerklickar du på indikatorn för att bläddra igenom dem.

Använd _Setup > Keyboard > Keyboard Inputs_ för att välja layouter som engelska och franska, bland samma val som erbjöds under installationen. Använd _Setup > Keyboard > Input Methods_ för att välja vilka kompositionsmotorer som är aktiva. Båda väljarna öppnas inuti Omarchy-menyn med dina nuvarande val markerade. Klicka eller tryck på Enter för att växla ett val; varje ändring gäller omedelbart. Att avmarkera en inmatningsmetod tar bort den från cykeln utan att avinstallera den; tangentbordet förblir tillgängligt.

Kör `omarchy setup keyboard` eller `omarchy setup input` för att öppna samma väljare. För att lägga till ett språk från kommandoraden använder du `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eller `cangjie5`. Quick, Boshiamy och Array ingår i samma paket som Cangjie och visas i väljaren Input Methods. Dina anpassade växlingstangenter bevaras. För alternativa motorlayouter eller tangenter installerar du `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` och startar det från en terminal. Att välja ett inmatningsspråk ändrar inte skrivbordsspråket. Att välja japanska, koreanska eller kinesiska under _Setup > Language_ lägger till dess inmatningsmetod när du inte har någon ännu.

Använd `Super + I` för att bläddra igenom inmatningsmetoder eller tangentbordslayouter och `Super + Shift + I` för att gå tillbaka åt andra hållet, så att du med tre konfigurerade kan flytta mellan två grannar. Inmatningsindikatorn visas till höger i fältet endast när mer än en inmatningsmetod eller layout är konfigurerad. Den här skrivbordsbindningen fungerar sida vid sida med dina befintliga Fcitx-växlingstangenter; du kan åsidosätta den i `~/.config/hypr/bindings.lua`. Inmatningsmotorer och compose-sekvenserna använder tjänsten [Fcitx5](https://fcitx-im.org/) som redan körs i varje session.

### Använd ALT som SUPER

På vissa tangentbord är det inte praktiskt att använda den primära metatangenten (Windows/cmd-tangenten) som SUPER. Du kan ändra det till att vara ALT i stället med den här ändringen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
