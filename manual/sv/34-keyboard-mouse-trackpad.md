# Tangentbord, mus, styrplatta

Hyprland låter dig konfigurera alla dina inmatningsenheter in i minsta detalj. Du kan göra tangentbordsupprepningen supersoniskt snabb eller få styrplattan att använda naturlig rullning. Du ändrar allt i `~/.config/hypr/input.lua`, som du också kan nå via _Setup > Input_ i Omarchy-menyn (`Super + Space`). Allt du ställer in där ersätter Omarchys standardinställningar.

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

Du kan [se alla inmatningsalternativ](https://wiki.hypr.land/Configuring/Basics/Variables/#input) på Hyprland-wikin för inmatningar.

CapsLock fungerar som ett vanligt Caps Lock, och `Shift + CapsLock` är compose-tangenten för [snabba emojis](07-hotkeys.md#quick-emojis) och [andra kompletteringar](07-hotkeys.md#quick-completions). Om du hellre vill ha compose-tangenten någon annanstans ersätter du `omarchy:shift_caps_compose` i `kb_options`. Det här exemplet flyttar till exempel compose-tangenten till Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Funktionstangenter

Den översta raden på ett tangentbord för bärbara datorer skickar medietangenterna (volym, ljusstyrka och så vidare) som standard, och om du håller ned `Fn` får du F1-F12; `Fn + Esc` låser det tvärtom tills du trycker på den igen. De flesta tangentbord kommer ihåg det låset själva. Bärbara datorer från ASUS och tangentbord i Apple-stil överlåter det åt Linux, som startar dem på medietangenterna vid varje uppstart. För att de i stället ska starta på F1-F12 kör du `omarchy keyboard toprow fnkeys` (och `omarchy keyboard toprow mediakeys` för att gå tillbaka); på vissa bärbara datorer börjar det gälla efter en omstart. Apple Silicon-Macar behåller sin egen inställning.

### Styrplattagester

Svep på styrplattan för att röra dig runt på skrivbordet:

| Gest | Åtgärd |
| --- | --- |
| Tre fingrar åt vänster / höger | Föregående / nästa arbetsyta, inklusive tomma |
| Tre fingrar upp | Växla AI-konsolen |
| Tre fingrar ned | Öppna Omarchy-menyn |
| Fyra fingrar åt vänster / höger | Flytta det aktiva fönstret till föregående / nästa arbetsyta |
| Fyra fingrar ned | Växla helskärm |

För att ändra en av dem tar du bort den i `~/.config/hypr/input.lua` innan du lägger till din egen [styrplattagest](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), eftersom Hyprland inte accepterar två gester på samma fingrar och i samma riktning:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

För att stänga av alla Omarchys gester ställer du in `omarchy_default_gestures = false` nära början av `~/.config/hypr/hyprland.lua`, innan Omarchys standardinställningar laddas.

På bärbara Dell XPS-datorer med haptisk styrplatta kan du också ställa in klickstyrkan på låg, medel eller hög under _Trigger > Hardware > Touchpad Haptics_.

### Att skriva på kinesiska, japanska och andra språk

Välj Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) eller Hong Kong (Cangjie) när installationsprogrammet frågar efter ditt tangentbord. Omarchy konfigurerar tangentbordet och den matchande inmatningsmotorn automatiskt, även under offlinekonfigurationen vid första uppstarten. Japanese använder Mozc, Korean använder standard-Hangul med två uppsättningar, Simplified Chinese använder Pinyin, Taiwan använder Chewings standardarrangemang för Zhuyin och Hong Kong använder Cangjie med teckenformer från Hong Kong. Japanese (US keyboard) ger Mozc med en amerikansk tangentbordslayout. Tangenterna för Hangul, Zhuyin och Cangjie stannar kvar på sina standardpositioner även när du skriver latinska bokstäver med Dvorak, Colemak eller AZERTY. Om du lade till Hangul eller Chewing innan detta avmarkerar du det och väljer det igen under _Setup > Keyboard > Input Methods_ för att flytta dess tangenter dit; Omarchy lämnar en motor som du redan skriver med i fred.

Skrivandet börjar i latinskt läge. Tryck på `Super + I` för att växla mellan konfigurerade inmatningsmetoder, och `Super + Shift + I` för att växla tillbaka. Tryck på `Shift` för sig själv för att kliva ur en inmatningsmetod som Pinyin till latinska bokstäver, och tryck på den igen för att gå tillbaka, på samma sätt som Sogou, Microsoft Pinyin och macOS fungerar; `Shift` plus en bokstav skriver fortfarande en versal. På japanska tangentbord växlar 全角/半角 inmatning, 変換 slår på den och 無変換 stänger av den. Med Korean växlar 한/영 Hangul och 한자 konverterar till Hanja, oavsett om ditt tangentbord har särskilda tangenter eller skickar Right Alt och Right Ctrl för dem, som många bärbara datorer gör, så Right Alt och Right Ctrl är inte vanliga modifieringstangenter där; diktering växlar i stället med Alt + Space. `Ctrl + Space` förblir tillgängligt för Tmux och Herdr; `Shift + CapsLock` förblir compose-tangenten.

Tangentbordsindikatorn visas till höger i panelen när du har flera tangentbordslayouter eller inmatningsmetoder. Klicka på den för att byta inmatningsspråk; Japanese visar あ för hiragana. För japanska teckenval byter du till Japanese, skriver ett ord som `nihongo` och trycker sedan på Space två gånger. Tryck på Enter för att acceptera ditt val. Om du också har flera tangentbordslayouter högerklickar du på indikatorn för att växla mellan dem.

Använd _Setup > Keyboard > Keyboard Inputs_ för att välja layouter som English och French, från samma val som erbjöds under installationen. Använd _Setup > Keyboard > Input Methods_ för att välja vilka kompositionsmotorer som är aktiva. Båda väljarna öppnas inuti Omarchy-menyn med dina nuvarande val markerade. Klicka eller tryck på Enter för att växla ett val; varje ändring börjar gälla omedelbart. Att avmarkera en inmatningsmetod tar bort den från växlingen utan att avinstallera den; tangentbordet förblir tillgängligt.

Kör `omarchy setup keyboard` eller `omarchy setup input` för att öppna samma väljare. För att lägga till ett språk från kommandoraden använder du `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` eller `cangjie5`. Quick, Boshiamy och Array levereras i samma paket som Cangjie och visas i väljaren Input Methods. Dina anpassade växlingstangenter bevaras. För alternativa motorlayouter eller tangenter installerar du `fcitx5-configtool` med `omarchy pkg add fcitx5-configtool` och startar det från en terminal. Att välja ett inmatningsspråk ändrar inte skrivbordsspråket. Att välja Japanese, Korean eller Chinese under _Setup > Language_ lägger till dess inmatningsmetod när du inte har någon ännu.

Använd `Super + I` för att växla mellan inmatningsmetoder eller tangentbordslayouter, och `Super + Shift + I` för att gå tillbaka åt andra hållet, så med tre konfigurerade kan du röra dig mellan två grannar. Inmatningsindikatorn visas till höger i panelen endast när mer än en inmatningsmetod eller layout är konfigurerad. Den här skrivbordsbindningen fungerar tillsammans med dina befintliga växlingstangenter i Fcitx; du kan åsidosätta den i `~/.config/hypr/bindings.lua`. Inmatningsmotorerna och compose-sekvenserna använder tjänsten [Fcitx5](https://fcitx-im.org/) som redan körs i varje session.

### Använd ALT som SUPER

På vissa tangentbord är det inte praktiskt att använda den primära metatangenten (Windows/cmd-tangenten) som SUPER. Du kan ändra detta till ALT i stället med den här ändringen:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
