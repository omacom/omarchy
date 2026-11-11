# Snabbtangenter

Du kan se alla de viktigaste tangentbordsbindningarna med `Super + K` (Tmux-bindningar med `Super + Alt + K` och Herdr-bindningar med `Super + Ctrl + K`).

## Hur snabbtangenterna är upplagda

Varje snabbtangent ligger på ett plan, som bestäms av dess modifierare, och varje plan har ett jobb. Det är det som håller isär snabbtangenterna, och det betyder att du oftast kan gissa var något finns.

| Plan | Vad som finns där | Exempel |
| --- | --- | --- |
| `Super + key` | Systemet: fönster, arbetsytor, layouter och kärnmenyer | `Super + Space` Omarchy-menyn, `Super + W` stäng fönster, `Super + F` helskärm |
| `Super + Shift + key` | Appar | `Super + Shift + B` webbläsare, `Super + Shift + E` e-post, `Super + Shift + N` redigerare |
| `Super + Ctrl + key` | Paneler och systemmenyer | `Super + Ctrl + A` ljud, `Super + Ctrl + N` nätverk, `Super + Ctrl + C` fångstmeny |
| `Super + Ctrl + Alt + key` | Snabbåtgärder och notiser | `Super + Ctrl + Alt + T` visa tiden, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skärmbild |

Att lägga till `Alt` på en snabbtangent ger dig en variant av samma sak, aldrig något orelaterat:

- `Super + Shift + B` öppnar webbläsaren; `Super + Shift + Alt + B` öppnar ett privat fönster
- `Super + Shift + E` öppnar e-post; `Super + Shift + Alt + E` påbörjar ett nytt
- `Super + F` går till helskärm; `Super + Alt + F` går till full bredd
- `Super + Ctrl + C` öppnar fångstmenyn; `Super + Ctrl + Alt + C` hoppar över menyn och tar en skärmbild

När du lägger till en snabbtangent:

1. Välj planet utifrån vad den gör, välj sedan tangenten.
2. Flytta inte en befintlig snabbtangent för att göra plats. Hitta en ledig tangent på rätt plan.
3. Använd bara `Alt` för en variant av snabbtangenten utan den.

Några snabbtangenter bryter mot de här reglerna för att de är praktiska. `Shift` med en piltangent eller `Tab` flyttar eller vänder i stället för att öppna en app, och `Print`, mediaknapparna, `Alt + Tab` och `Ctrl + Alt + Del` fungerar som de gör överallt annars. De är undantag, inte mönster att kopiera.

Om en standardbindning inte passar dig (säg att du vill ha `Super + Shift + S` för skärmbilder som på Windows), bind om den i `~/.config/hypr/bindings.lua`.

## Navigering

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy-menyn (appar och allt annat) |
| `Super + Alt + Space` | Apprutnät |
| `Super + Escape` | Systemmeny (viloläge, omstart osv.) |
| `Super + Ctrl + L` | Lås datorn |
| `Super + W` or `Super + Q` | Stäng fönster |
| `Ctrl + Alt + Del` | Stäng alla fönster |
| `Super + T` | Växla fönster mellan tiling och flytande |
| `Super + J` | Växla fönsterposition (horisontell/vertikal) |
| `Super + O` | Växla att fönstret poppar ut till sticky och flytande |
| `Super + L` | Bläddra igenom layouterna dwindle, scrolling och floating |
| `Super + Alt + L` | Bläddra igenom layouterna baklänges |
| `Super + P` | Växla pseudo-fönsterstil (naturlig mot sträckt) |
| `Super + F` | Gå till helskärm |
| `Super + Alt + F` | Gå till full bredd |
| `Super + Ctrl + F` | Gå till helskärm inuti fönstret |
| `Super + 1/2/3/4` | Hoppa till en specifik arbetsyta på den fokuserade skärmen |
| `Super + Tab` | Hoppa till nästa arbetsyta på den fokuserade skärmen |
| `Super + Shift + Tab` | Hoppa till föregående arbetsyta på den fokuserade skärmen |
| `Super + Ctrl + Tab` | Hoppa till den tidigare arbetsytan på den fokuserade skärmen |
| `Super + Shift + 1/2/3/4` | Flytta fönster till arbetsyta på den fokuserade skärmen |
| `Super + Shift + Alt + 1/2/3/4` | Flytta fönster till arbetsyta på den fokuserade skärmen utan att följa med |
| `Super + S` | Växla fullständig scratchpad |
| `Super + Alt + S` | Flytta fönster till fullständig scratchpad |
| `Super + Grave` | Växla Quake-konsol |
| `Super + Shift + Grave` | Flytta fönster till Quake-konsol |
| `Super + Shift + Ctrl + Arrows` | Flytta fönster till skärmen i den riktningen |
| `Super + Shift + Alt + Arrows` | Flytta arbetsyta till skärmen i den riktningen |
| `Super + Arrow` | Flytta fokus till fönster i piltangentens riktning, och går över till skärmen på den sidan vid skärmkanten |
| `Super + Shift + Arrow` | Byt fönster med ett annat i piltangentens riktning, inklusive ett på skärmen på den sidan |
| `Super + Minus` | Expandera fönster åt vänster |
| `Super + Equal` | Krymp fönster åt vänster |
| `Super + Shift + Minus` | Krymp fönster uppåt |
| `Super + Shift + Equal` | Expandera fönster nedåt |
| `Super + Alt + Minus/Equal` | Samma storleksändring i mindre steg |
| `Super + Ctrl + Minus/Equal` | Samma storleksändring i större steg |
| `Super + Alt + Home` | Spara fönsterbredd |
| `Super + Home` | Återställ sparad fönsterbredd |
| `Super + Left Mouse` | Dra runt fönster |
| `Super + Right Mouse` | Ändra storlek på fönster |
| `Super + Scroll Wheel` | Skrolla igenom arbetsytor på den fokuserade skärmen |
| `Super + G` | Växla fönstergruppering |
| `Super + Alt + G` | Flytta fönster ut ur gruppering |
| `Super + Alt + Tab` | Bläddra mellan fönster i gruppering |
| `Super + Alt + Shift + Tab` | Bläddra bakåt mellan fönster i gruppering |
| `Super + Alt + Scroll Wheel` | Bläddra mellan fönster i gruppering |
| `Super + Alt + 1/2/3/4/5` | Hoppa till ett specifikt fönster i gruppering |
| `Super + Alt + Arrow` | Flytta fönster in i gruppering i piltangentens riktning, inklusive ett på skärmen på den sidan |
| `Super + Ctrl + Left/Right` | Flytta mellan fönster inuti en tiling-grupp |
| `Super + Ctrl + Z` | Zooma in på skärmen (upprepa för mer zoom) |
| `Super + Ctrl + Alt + Z` | Zooma ut helt från skärmen |
| `Super + /` | Stega framåt genom skärmskalningsalternativen |
| `Super + Alt + /` | Stega bakåt genom skärmskalningsalternativen |
| `Alt + Tab` | Bläddra framåt genom fönster på den aktiva arbetsytan |
| `Alt + Shift + Tab` | Bläddra bakåt genom fönster på den aktiva arbetsytan |
| `Ctrl + Alt + Tab` | Bläddra fokus framåt genom skärmar |
| `Ctrl + Alt + Shift + Tab` | Bläddra fokus bakåt genom skärmar |

Genvägar för storleksändring använder de fysiska tangenterna `code:20` och `code:21` (XKB `<AE11>` och `<AE12>`), oavsett vilka tecken som är tryckta på tangentbordet. På amerikanska tangentbord är de här tangenterna `-` och `=`; på japanska (JIS) tangentbord är de `-` och `^`; på spanska tangentbord är de `'` och `¡`. På JIS är `Super + ^` detsamma som `Super + Equal`, medan `Super + Shift + -` (som skriver `=`) är `Super + Shift + Minus`.

## Systemkontroller

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Ljudpanel |
| `Super + Ctrl + B` | Bluetooth-panel |
| `Super + Ctrl + N` | Wi-Fi-/nätverkspanel |
| `Super + Ctrl + D` | Skärmpanel |
| `Super + Ctrl + P` | Strömpanel |
| `Super + Ctrl + X` | Agentpanel |
| `Super + Ctrl + Alt + D` | Kalenderpanel |
| `Super + Ctrl + Alt + E` | Världsklockpanel |
| `Super + Ctrl + 1-9` | Växla fältpanel efter position |
| `Super + Ctrl + S` | Delningsmeny (via LocalSend) |
| `Super + Ctrl + C` | Fångstkontroller (skärmbild/-inspelning/väljare) |
| `Super + Ctrl + O` | Växlingsmeny |
| `Super + Ctrl + H` | Hårdvarumeny |
| `Super + Ctrl + E` | Emojiväljare |
| `Super + Ctrl + .` | Transkoda media |
| `Super + Shift + Ctrl + A` | Välj en AI-agent |

## Justeringar

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximal skärmljusstyrka |
| `Shift + Brightness Down` | Minimal skärmljusstyrka |
| `Alt + Brightness Up/Down` | Exakta ändringar av ljusstyrkan på 1 % |
| `Alt + Volume Up/Down` | Exakta volymändringar på 1 % |
| `Keyboard Brightness Up/Down` | Tangentbordsbelysning ljusare/mörkare |
| `Keyboard Backlight` | Bläddra igenom nivåerna för tangentbordsbelysning |
| `Alt + Play` | Nästa spår |
| `Alt + Shift + Play` | Föregående spår |

## Starta appar

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agenthanterare) |
| `Super + Shift + Return` | Webbläsare |
| `Super + Shift + Alt + B` | Webbläsare (privat/inkognito) |
| `Super + Shift + F` | Filhanterare |
| `Super + Shift + Alt + F` | Filhanterare i terminalens cwd |
| `Super + Shift + M` | Musik (Spotify) |
| `Super + Shift + Alt + M` | Musik (cliamp) |
| `Super + Shift + /` | Lösenordshanterare (1password) |
| `Super + Shift + Q` | Miniräknare (Omacalc) |
| `Super + Shift + T` | Aktivitet (btop) |
| `Super + Shift + N` | Redigerare (Neovim) |
| `Super + Shift + C` | Kalender ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-post ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Ny e-post ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Meddelanden (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Meddelanden (WhatsApp) |
| `Super + Shift + Ctrl + G` | Meddelanden (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Skrivande (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Ändra/lägg till bindningar i `~/.config/hypr/bindings.lua`.

## Universell urklipp

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Super + A` | Markera allt i appar som stöder `Ctrl + A` |
| `Super + C` | Kopiera |
| `Super + X` | Klipp ut (inte i terminalen) |
| `Super + V` | Klistra in |
| `Super + Ctrl + V` | Urklippshanterare |

Normalt på Linux behöver du `Ctrl + Shift + C/V` för att kopiera och klistra in i terminalen och `Ctrl + C/V` för att göra det överallt annars. De här enhetliga snabbtangenterna för urklipp i Omarchy fungerar överallt.

## Fångst

| Snabbtangent | Funktion |
| ------------------- | ------------------------------ |
| `Print Screen` | Skärmbild |
| `Super + Ctrl + Alt + C` | Skärmbild (samma bild, för tangentbord utan Print Screen-tangent) |
| `Super + Ctrl + C` | Fångstmeny |
| `Alt + Print Screen` | Skärminspelning |
| `Super + Print Screen` | Färgväljare |
| `Super + Ctrl + Print Screen` | Textextrahering till urklipp |
| `Super + Alt + [` | Gör webbkameraöverlägget mindre under inspelning |
| `Super + Alt + ]` | Gör webbkameraöverlägget större under inspelning |
| `Alt + Shift + L` | Kopiera aktuell URL från webbapp eller Chromium |
| `Alt + Shift + D` | Ladda ner videon på den aktuella sidan till `~/Videos` |
| `Alt + Space` | Starta/stoppa diktering (kräver _Setup > Defaults > Dictation_) |
| `Right Alt` | Håll in för att diktera (kräver _Setup > Defaults > Dictation_) |

Vid skärminspelningar frågar snabbtangenten först vilket ljud du vill ha, sedan börjar inspelningen. Tryck på den igen för att stoppa. Se [skärmbilder och inspelning](12-screenshots-recording.md) för detaljerna.

Alla fångstalternativ finns också under _Trigger > Capture_ i Omarchy-menyn (`Super + Space`).

## Aviseringar

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Super + ,` | Agera på den senaste aviseringen: öppna den eller tryck på dess enda knapp, välj bland dess alternativ, eller avvisa den när den inte har några |
| `Super + Shift + ,` | Avvisa alla aviseringar |
| `Super + Ctrl + ,` | Styr aviseringar med tangentbordet |
| `Super + Alt + ,` | Avvisa den senaste aviseringen |
| `Super + Shift + Alt + ,` | Öppna aviseringshistorik |
| `Super + Ctrl + Alt + ,` | Växla tystande av aviseringar |

## Stil

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Välj ett nytt tema (även `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Välj temabakgrund (även `Super + Ctrl + Space`) |
| `Super + Backspace` | Växla transparens på ett fönster |
| `Super + Ctrl + Backspace` | Växla kvadratiskt format för ett enskilt fönster |

Extra bakgrundsbilder finns i `~/.config/omarchy/backgrounds/<theme name>`. Finns också via _Install > Style > Background_ i Omarchy-menyn.

Alla stilalternativ finns också under _Style_ i Omarchy-menyn (`Super + Space`).

## Växlingar

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Växla låsning vid inaktivitet |
| `Super + Ctrl + Delete` | Växla den bärbara datorns skärm på/av |
| `Super + Ctrl + Alt + Delete` | Växla spegling av den bärbara datorns skärm |
| `Super + Shift + Space` | Växla det övre fältet |
| `Shift + Mute` | Växla till nästa ljudutgång |
| `Shift + Play` | Växla till nästa mediekälla |
| `Super + Shift + Backspace` | Växla fönstergap |
| `Super + Ctrl + Alt + F` | Växla helskärmsskrivbord (övre fältet + fönstergap) |

## Påminnelser

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Ställ in en påminnelse |
| `Super + Ctrl + Alt + R` | Se alla påminnelser |
| `Super + Ctrl + Shift + R` | Rensa alla påminnelser |

## Notiser

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Visa tiden som avisering |
| `Super + Ctrl + Alt + B` | Visa batteriet som avisering |
| `Super + Ctrl + Alt + W` | Växla vädret som avisering |

## Tmux

Prefix-tangenten är `Ctrl + Space` (`Ctrl + B` fungerar också). Du kan ändra de här bindningarna i `~/.config/tmux/tmux.conf`.

### Paneler

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Prefix + v` | Dela panelen bredvid (vertikalt) |
| `Prefix + h` | Dela panelen nedanför (horisontellt) |
| `Prefix + x` | Döda panelen |
| `Prefix + z` | Växla panelzoom (helskärm) |
| `Alt + Enter` | Dela panelen nedanför (utan prefix) |
| `Alt + Shift + Enter` | Dela panelen bredvid (utan prefix) |
| `Alt + Escape` | Döda panelen (utan prefix) |
| `Ctrl + Alt + Arrows` | Flytta mellan paneler |
| `Ctrl + Alt + Shift + Arrows` | Ändra storlek på paneler |

### Fönster

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Prefix + c` | Nytt fönster |
| `Prefix + k` | Döda fönster |
| `Prefix + r` | Byt namn på fönster |
| `Alt + 1-9` | Gå till ett specifikt fönster |
| `Alt + Arrow Left/Right` | Flytta mellan fönster |
| `Alt + Shift + Arrow Left/Right` | Flytta fönster åt vänster/höger |

### Sessioner

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Prefix + C` | Ny session |
| `Prefix + K` | Döda session |
| `Prefix + R` | Byt namn på session |
| `Prefix + N` | Nästa session |
| `Prefix + P` | Föregående session |
| `Alt + Arrow Up/Down` | Flytta mellan sessioner |
| `Prefix + s` | Lista sessioner |
| `Prefix + d` | Koppla loss från session |

### Kopieringsläge (vi-stil)

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Prefix + [` | Gå in i kopieringsläge |
| `v` | Börja markering (i kopieringsläge) |
| `y` | Kopiera markering (i kopieringsläge) |

### Allmänt

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Prefix + q` | Ladda om konfigurationen |
| `Prefix + ?` | Visa Tmux-tangentbindningar |
| `Prefix + :` | Kommandoprompt |

### Tmux-layoutfunktioner

De här funktionerna måste köras inuti en Tmux-session.

| Kommando | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Skapa utvecklarlayout med redigerare, AI och terminal |
| `tdlm <ai> [<second_ai>]` | Skapa utvecklarlayout per underkatalog |
| `tsl <count> <command>` | Skapa svärmlayout med flera paneler |

## Ghostty-terminalen

Ghostty-terminalen installeras med _Install > Terminal_ via Omarchy-menyn.

| Snabbtangent | Funktion |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ny delning nedanför |
| `Ctrl + Shift + O` | Ny delning bredvid |
| `Ctrl + Alt + Arrows` | Flytta mellan delningar |
| `Super + Ctrl + Shift + Arrows` | Ändra storlek på delning med 10 rader |
| `Super + Ctrl + Shift + Alt + Arrows` | Ändra storlek på delning med 100 rader |
| `Ctrl + Shift + T` | Ny flik |
| `Ctrl + Shift + Arrows` | Flytta mellan flikar |
| `Alt + Numbers` | Gå till en specifik flik |
| `Shift + Pg Up/Down` | Skrolla historiken |
| `Ctrl + Left mouse` | Öppna länk i webbläsaren |

## Filhanterare

| Snabbtangent | Funktion |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Gå till sökväg |
| `Space` | Förhandsgranska fil (piltangenterna navigerar) |
| `Alt + Up` | Gå upp till överordnad mapp |

## Neovim (med lazyvim)

### Navigering

| Snabbtangent | Funktion |
| ------------------------ | ------------------------------- |
| `Space` | Visa kommandoalternativ |
| `Space Space` | Öppna fil via fuzzy-sökning |
| `Space E` | Växla sidofält |
| `Space G G` | Visa git-kontroller |
| `Space S G` | Sök i filinnehåll |
| `Ctrl + W W` | Hoppa mellan sidofält och redigerare |
| `Ctrl + Left/right arrow` | Ändra storlek på sidofältet |
| `Shift + H` | Gå till filtfliken till vänster |
| `Shift + L` | Gå till filtfliken till höger |
| `Space B D` | Stäng filtflik |

### I sidofältet

| Snabbtangent | Funktion |
| ------------------------ | ------------------------------- |
| `A` | Lägg till ny fil i överordnad katalog |
| `Shift + A` | Lägg till ny underkatalog i överordnad katalog |
| `D` | Ta bort markerad fil/katalog |
| `M` | Flytta markerad fil/katalog |
| `R` | Byt namn på markerad fil/katalog |
| `?` | Visa hjälp för alla kommandon |

[Se alla snabbtangenter i Neovim som konfigureras av LazyVim](https://www.lazyvim.org/keymaps).

## Snabba emojier

Du kan använda `Super + Ctrl + E` för att visa en komplett emojiväljare som lägger valet på urklippet, eller så kan du använda de här snabbåtkomstalternativen.

| Snabbtangent | EM | Ledtråd |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | leende |
| `Shift + CapsLock M C` | 😂 | gråt |
| `Shift + CapsLock M L` | 😍 | kärlek |
| `Shift + CapsLock M V` | ✌️ | seger |
| `Shift + CapsLock M H` | ❤️ | hjärta |
| `Shift + CapsLock M Y` | 👍 | ja |
| `Shift + CapsLock M N` | 👎 | nej |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | önska |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | puss |
| `Shift + CapsLock M E` | 🙄 | ögonrullning |
| `Shift + CapsLock M I` | 😉 | blinkning |
| `Shift + CapsLock M P` | 🙏 | be |
| `Shift + CapsLock M D` | 🤤 | dregla |
| `Shift + CapsLock M M` | 💰 | pengar |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | skål |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | hälsning |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | exploderar |

## Snabba kompletteringar

| Snabbtangent | Komplettering |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Ditt namn (som det angavs vid installationen) |
| `Shift + CapsLock Space E` | Din e-post (som den angavs vid installationen) |

Du kan lägga till fler egna genom att redigera `~/.XCompose` och sedan köra `omarchy-restart-xcompose` i terminalen för att ändringarna ska börja gälla.
