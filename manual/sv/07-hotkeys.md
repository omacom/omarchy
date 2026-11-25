# Snabbtangenter

Du kan se alla de viktigaste tangentbordsbindningarna med `Super + K` (Tmux-bindningar med `Super + Alt + K` och Herdr-bindningar med `Super + Ctrl + K`).

## Hur snabbtangenterna är upplagda

Varje snabbtangent ligger på ett plan, bestämt av dess modifierare, och varje plan har en uppgift. Det är det som hindrar snabbtangenterna från att flyta ihop, och det betyder att du oftast kan gissa var något finns.

| Plan | Vad som finns där | Exempel |
| --- | --- | --- |
| `Super + key` | Systemet: fönster, arbetsytor, layouter och kärnmenyer | `Super + Space` Omarchy-menyn, `Super + W` stäng fönster, `Super + F` helskärm |
| `Super + Shift + key` | Appar | `Super + Shift + B` webbläsare, `Super + Shift + E` e-post, `Super + Shift + N` redigerare |
| `Super + Ctrl + key` | Paneler och systemmenyer | `Super + Ctrl + A` ljud, `Super + Ctrl + N` nätverk, `Super + Ctrl + C` fångstmenyn |
| `Super + Ctrl + Alt + key` | Snabbåtgärder och notiser | `Super + Ctrl + Alt + T` visa tid, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skärmbild |

Att lägga till `Alt` till en snabbtangent ger dig en variant av samma sak, aldrig något orelaterat:

- `Super + Shift + B` öppnar webbläsaren; `Super + Shift + Alt + B` öppnar ett privat fönster
- `Super + Shift + E` öppnar e-post; `Super + Shift + Alt + E` påbörjar ett nytt
- `Super + F` går till helskärm; `Super + Alt + F` går till full bredd
- `Super + Ctrl + C` öppnar fångstmenyn; `Super + Ctrl + Alt + C` hoppar över menyn och tar en skärmbild

När du lägger till en snabbtangent:

1. Välj planet utifrån vad den gör, välj sedan tangenten.
2. Flytta inte en befintlig snabbtangent för att göra plats. Hitta en ledig tangent på rätt plan.
3. Använd bara `Alt` för en variant av snabbtangenten utan den.

Några få snabbtangenter bryter mot dessa regler eftersom de är bekväma. `Shift` med en piltangent eller `Tab` flyttar eller vänder i stället för att öppna en app, och `Print`, mediatangenterna, `Alt + Tab` och `Ctrl + Alt + Del` fungerar som de gör överallt annars. De är undantag, inte mönster att kopiera.

Om en standardinställning inte passar dig (säg att du vill ha `Super + Shift + S` för skärmbilder som på Windows), bind om den i `~/.config/hypr/bindings.lua`.

## Navigera

| Snabbtangent | Funktion |
| --- | --- |
| `Super + Space` | Omarchy-menyn (appar och allt annat) |
| `Super + Alt + Space` | Apprutnät |
| `Super + Escape` | Systemmeny (viloläge, omstart osv.) |
| `Super + Ctrl + L` | Lås datorn |
| `Super + W` or `Super + Q` | Stäng fönster |
| `Ctrl + Alt + Del` | Stäng alla fönster |
| `Super + K` | Visa alla snabbtangenter |
| `Super + Alt + K` | Visa tmux-snabbtangenter |
| `Super + Ctrl + K` | Visa herdr-snabbtangenter |
| `Super + M` | Minimera fönstret till dockan |
| `Super + T` | Växla fönstret mellan kakelläge och flytande läge |
| `Super + J` | Växla fönsterposition (horisontell/vertikal) |
| `Super + O` | Växla att fönstret poppar in i sticky'n'floating |
| `Super + L` | Bläddra genom layouterna dwindle, scrolling och floating |
| `Super + Alt + L` | Bläddra genom layouterna i omvänd ordning |
| `Super + P` | Växla pseudo-fönsterstil (naturlig vs utsträckt) |
| `Super + F` | Gå till helskärm |
| `Super + Alt + F` | Gå till full bredd |
| `Super + Ctrl + F` | Gå till helskärm inuti fönstret |
| `Super + 1…9/0` | Hoppa till specifik arbetsyta (0 är 10) på den fokuserade skärmen |
| `Super + Tab` | Hoppa till nästa arbetsyta på den fokuserade skärmen |
| `Super + Shift + Tab` | Hoppa till föregående arbetsyta på den fokuserade skärmen |
| `Super + Ctrl + Tab` | Hoppa till senast använda arbetsyta på den fokuserade skärmen |
| `Super + Shift + 1…9/0` | Flytta fönstret till arbetsyta på den fokuserade skärmen |
| `Super + Shift + Alt + 1…9/0` | Flytta fönstret till arbetsyta på den fokuserade skärmen utan att följa med |
| `Super + S` | Växla full scratchpad |
| `Super + Alt + S` | Flytta fönstret till full scratchpad |
| `Super + the key above Tab` (grave på amerikanska layouter) | Växla Quake-konsolen |
| `Super + Shift + the key above Tab` (grave på amerikanska layouter) | Flytta fönstret till Quake-konsolen |
| `Super + Shift + Ctrl + Arrows` | Flytta fönstret till skärmen i den riktningen |
| `Super + Shift + Alt + Arrows` | Flytta arbetsytan till skärmen i den riktningen |
| `Super + Arrow` | Flytta fokus till fönstret i piltangentens riktning, och går över till skärmen på den sidan vid skärmens kant |
| `Super + Shift + Arrow` | Byt plats på fönstret med ett annat i piltangentens riktning, inklusive ett på skärmen på den sidan |
| `Super + Minus` | Expandera fönstret åt vänster |
| `Super + Equal` | Krymp fönstret åt vänster |
| `Super + Shift + Minus` | Krymp fönstret uppåt |
| `Super + Shift + Equal` | Expandera fönstret nedåt |
| `Super + Alt + Minus/Equal` | Samma storleksändring i mindre steg |
| `Super + Ctrl + Minus/Equal` | Samma storleksändring i större steg |
| `Super + Alt + Home` | Spara fönsterbredd |
| `Super + Home` | Återställ sparad fönsterbredd |
| `Super + Left Mouse` | Dra runt fönstret |
| `Super + Right Mouse` | Ändra storlek på fönstret |
| `Super + Scroll Wheel` | Rulla genom arbetsytor på den fokuserade skärmen |
| `Super + G` | Växla fönstergruppering |
| `Super + Alt + G` | Flytta fönstret ut ur grupperingen |
| `Super + Alt + Tab` | Bläddra mellan fönster i grupperingen |
| `Super + Alt + Shift + Tab` | Bläddra bakåt mellan fönster i grupperingen |
| `Super + Alt + Scroll Wheel` | Bläddra mellan fönster i grupperingen |
| `Super + Alt + 1/2/3/4/5` | Hoppa till specifikt fönster i grupperingen |
| `Super + Alt + Arrow` | Flytta fönstret in i grupperingen i piltangentens riktning, inklusive ett på skärmen på den sidan |
| `Super + Ctrl + Left/Right` | Flytta mellan fönster inuti en kakelgrupp |
| `Super + Ctrl + Z` | Zooma in på skärmen (upprepa för mer zoom) |
| `Super + Ctrl + Alt + Z` | Zooma ut helt från skärmen |
| `Super + /` | Stega framåt genom alternativen för skärmskalning |
| `Super + Alt + /` | Stega bakåt genom alternativen för skärmskalning |
| `Alt + Tab` | Bläddra framåt genom fönster på den aktiva arbetsytan |
| `Alt + Shift + Tab` | Bläddra bakåt genom fönster på den aktiva arbetsytan |
| `Ctrl + Alt + Tab` | Bläddra fokus framåt genom skärmar |
| `Ctrl + Alt + Shift + Tab` | Bläddra fokus bakåt genom skärmar |
| `Super + I` | Byt inmatningsspråk (med mer än en layout eller inmatningsmetod) |
| `Super + Shift + I` | Byt tillbaka inmatningsspråk |

På en styrplatta växlar svep med tre och fyra fingrar arbetsytor, flyttar fönster och öppnar menyn och Quake-konsolen; se [tangentbord, mus och styrplatta](34-keyboard-mouse-trackpad.md) för gesterna.

Storleksändring använder de två tangenterna till höger om 0, oavsett vad ditt tangentbord har tryckt på dem: `-` och `=` på amerikanska tangentbord, `+` och `´` på danska och svenska, `+` och `\` på norska, `ß` och `´` på tyska, `'` och `¡` på spanska, och `-` och `^` på japanska (JIS). `Super + K` listar dem som ditt tangentbord trycker dem. På JIS är `Super + ^` `Super + Equal`, medan `Super + Shift + -` (som skriver `=`) är `Super + Shift + Minus`. Skärmskalning och lösenordshanteraren använder `/`; på layouter som bara skriver `/` med Shift, som de flesta europeiska gör, använder de tangenten till vänster om höger Shift i stället (`-` på danska och tyska).

## Systemkontroller

| Snabbtangent | Funktion |
| --- | --- |
| `Super + Ctrl + A` | Ljudpanel |
| `Super + Ctrl + B` | Bluetooth-panel |
| `Super + Ctrl + N` | Wifi-/nätverkspanel |
| `Super + Ctrl + D` | Skärmpanel |
| `Super + Ctrl + P` | Strömpanel |
| `Super + Ctrl + X` | Agentpanel |
| `Super + Ctrl + Alt + D` | Kalenderpanel |
| `Super + Ctrl + Alt + E` | Världsklockpanel |
| `Super + Ctrl + 1-9` | Växla panel i överlisten efter position |
| `Super + Ctrl + S` | Dela-menyn (via LocalSend) |
| `Super + Ctrl + C` | Fångstkontroller (skärmbild/-inspelning/väljare) |
| `Super + Ctrl + O` | Växla menyn |
| `Super + Ctrl + H` | Maskinvarumeny |
| `Super + Ctrl + E` | Emojiväljare |
| `Super + Ctrl + .` | Transkoda media |
| `Super + Shift + Ctrl + A` | Starta din standardagent |
| `Power`-tangenten | Systemmeny |
| `Super + Shift + Copilot`-tangenten | Omarchy-menyn |

## Justeringar

| Snabbtangent | Funktion |
| --- | --- |
| `Shift + Brightness Up` | Maximal skärmljusstyrka |
| `Shift + Brightness Down` | Minimal skärmljusstyrka |
| `Alt + Brightness Up/Down` | Precisa ändringar av ljusstyrkan med 1 % |
| `Alt + Volume Up/Down` | Precisa volymändringar med 1 % |
| `Keyboard Brightness Up/Down` | Tangentbordets bakgrundsbelysning ljusare/mörkare |
| `Keyboard Backlight` | Bläddra genom nivåerna för tangentbordets bakgrundsbelysning |
| `Ctrl + Brightness Up/Down` | Tangentbordets bakgrundsbelysning ljusare/mörkare, på tangentbord utan egna tangenter för det |
| `Mic Mute` | Stäng av mikrofonen |
| `Shift + Mute` | Byt ljudutgång |
| `Touchpad Toggle` | Slå på eller av styrplattan |
| `Display`-tangenten | Bläddra genom arbetsytans layout |
| `Alt + Play` | Nästa spår |
| `Alt + Shift + Play` | Föregående spår |

## Starta appar

| Snabbtangent | Funktion |
| --- | --- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agenthanterare) |
| `Super + Shift + Return` or `Super + Shift + B` | Webbläsare |
| `Super + Shift + Alt + B` | Webbläsare (privat/inkognito) |
| `Super + Shift + F` | Filhanterare |
| `Super + Shift + Alt + F` | Filhanterare i terminalens cwd |
| `Super + Shift + M` | Musik (Spotify) |
| `Super + Shift + Alt + M` | Musik (cliamp) |
| `Super + Shift + /` | Lösenordshanterare (1password) |
| `Super + Shift + Q` or `Calculator`-tangenten | Kalkylator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, när den är installerad) |
| `Super + Shift + T` | Aktivitet (btop) |
| `Super + Shift + N` | Redigerare (Plain, eller ditt valda standardval) |
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
| `Super + Shift + Alt + X` | X (nytt inlägg) |
| `Super + Shift + Y` | YouTube |

Ändra/lägg till bindningar i `~/.config/hypr/bindings.lua`.

## Universellt urklipp

| Snabbtangent | Funktion |
| --- | --- |
| `Super + A` | Markera allt i appar som stöder `Ctrl + A` |
| `Super + C` | Kopiera |
| `Super + X` | Klipp ut (inte i terminalen) |
| `Super + V` | Klistra in |
| `Super + Ctrl + V` | Urklippshanterare |

Vanligtvis på Linux behöver du `Ctrl + Shift + C/V` för att kopiera och klistra in i terminalen och `Ctrl + C/V` för att göra det överallt annars. Dessa enhetliga Omarchy-snabbtangenter för urklipp fungerar överallt.

## Fångst

| Snabbtangent | Funktion |
| --- | --- |
| `Print Screen` | Skärmbild |
| `Super + Ctrl + Alt + C` | Skärmbild (samma bild, för tangentbord utan Print Screen-tangent) |
| `Super + Ctrl + C` | Fångstmeny |
| `Alt + Print Screen` | Skärminspelning |
| `Super + Shift + Ctrl + Alt + C` | Skärminspelning utan ljud, utan menyn (tryck igen för att stoppa) |
| `Super + Print Screen` | Färgväljare |
| `Super + Ctrl + Print Screen` | Textextrahering till urklipp |
| `Super + Alt + [` | Gör webbkamerans överlägg mindre under inspelning |
| `Super + Alt + ]` | Gör webbkamerans överlägg större under inspelning |
| `Alt + Shift + L` | Kopiera aktuell URL från webbapp eller webbläsare |
| `Alt + Shift + D` | Ladda ner videon på den aktuella sidan till `~/Videos` |
| `Alt + Space` | Starta/stoppa diktering (kräver _Konfiguration > Standard > Diktering_) |
| `Right Alt` | Håll för att diktera (kräver _Konfiguration > Standard > Diktering_) |

Med skärminspelningar frågar snabbtangenten först vilket ljud du vill ha, sedan startar den inspelningen. Tryck på den igen för att stoppa. Se [skärmbilder och inspelning](12-screenshots-recording.md) för detaljerna.

Alla fångstalternativ finns också under _Utlösare > Fångst_ i Omarchy-menyn (`Super + Space`).

## Aviseringar

| Snabbtangent | Funktion |
| --- | --- |
| `Super + ,` | Agera på den senaste aviseringen: öppna den eller tryck på dess enda knapp, välj bland dess val, eller avfärda den när den inte har några |
| `Super + Shift + ,` | Avfärda alla aviseringar |
| `Super + Ctrl + ,` | Styr aviseringar med tangentbordet |
| `Super + Alt + ,` | Avfärda den senaste aviseringen |
| `Super + Shift + Alt + ,` | Öppna aviseringshistoriken |
| `Super + Ctrl + Alt + ,` | Växla att aviseringar tystas |

## Stil

| Snabbtangent | Funktion |
| --- | --- |
| `Super + Ctrl + T` | Välj ett nytt tema (även `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Välj temabakgrund (även `Super + Ctrl + Space`) |
| `Super + Backspace` | Växla transparens på ett fönster |
| `Super + Ctrl + Backspace` | Växla kvadratiskt bildförhållande för ett enskilt fönster |

Extra bakgrundsbilder finns i `~/.config/omarchy/backgrounds/<theme name>`. Finns också via _Installera > Stil > Bakgrund_ i Omarchy-menyn.

Alla stilalternativ finns också under _Utseende_ i Omarchy-menyn (`Super + Space`).

## Växlingar

| Snabbtangent | Funktion |
| --- | --- |
| `Super + Ctrl + I` | Växla låsning vid inaktivitet |
| `Super + Ctrl + Delete` | Växla den bärbara datorns skärm på/av |
| `Super + Ctrl + Alt + Delete` | Växla spegling av den bärbara datorns skärm |
| `Super + Shift + Space` | Växla överlisten |
| `Shift + Mute` | Byt till nästa ljudutgång |
| `Shift + Play` | Byt till nästa mediakälla |
| `Super + Shift + Backspace` | Växla fönstergap |
| `Super + Ctrl + Alt + F` | Växla helskärmskrivbord (överlist + fönstergap) |

## Påminnelser

| Snabbtangent | Funktion |
| --- | --- |
| `Super + Ctrl + R` | Ställ in en påminnelse |
| `Super + Ctrl + Alt + R` | Se alla påminnelser |
| `Super + Ctrl + Shift + R` | Rensa alla påminnelser |

## Notiser

| Snabbtangent | Funktion |
| --- | --- |
| `Super + Ctrl + Alt + T` | Visa tiden som en avisering |
| `Super + Ctrl + Alt + B` | Visa batteriet som en avisering |
| `Super + Ctrl + Alt + W` | Växla vädret som en avisering |

## Tmux

Prefix-tangenten är `Ctrl + Space` (`Ctrl + B` fungerar också). Du kan ändra dessa bindningar i `~/.config/tmux/tmux.conf`.

### Rutor

| Snabbtangent | Funktion |
| --- | --- |
| `Prefix + v` | Dela rutan bredvid (vertikalt) |
| `Prefix + h` | Dela rutan nedanför (horisontellt) |
| `Prefix + x` | Döda rutan |
| `Prefix + z` | Växla rutans zoom (helskärm) |
| `Alt + Enter` | Dela rutan nedanför (utan prefix) |
| `Alt + Shift + Enter` | Dela rutan bredvid (utan prefix) |
| `Alt + Escape` | Döda rutan (utan prefix) |
| `Ctrl + Alt + Arrows` | Flytta mellan rutor |
| `Ctrl + Alt + Shift + Arrows` | Ändra storlek på rutor |

### Fönster

| Snabbtangent | Funktion |
| --- | --- |
| `Prefix + c` | Nytt fönster |
| `Prefix + k` | Döda fönstret |
| `Prefix + r` | Byt namn på fönstret |
| `Alt + 1-9` | Gå till specifikt fönster |
| `Alt + Arrow Left/Right` | Flytta mellan fönster |
| `Alt + Shift + Arrow Left/Right` | Flytta fönstret åt vänster/höger |

### Sessioner

| Snabbtangent | Funktion |
| --- | --- |
| `Prefix + C` | Ny session |
| `Prefix + K` | Döda sessionen |
| `Prefix + R` | Byt namn på sessionen |
| `Prefix + N` | Nästa session |
| `Prefix + P` | Föregående session |
| `Alt + Arrow Up/Down` | Flytta mellan sessioner |
| `Prefix + s` | Lista sessioner |
| `Prefix + d` | Koppla loss från sessionen |

### Kopieringsläge (vi-stil)

| Snabbtangent | Funktion |
| --- | --- |
| `Prefix + [` | Gå in i kopieringsläge |
| `v` | Börja markera (i kopieringsläge) |
| `y` | Kopiera markeringen (i kopieringsläge) |

### Allmänt

| Snabbtangent | Funktion |
| --- | --- |
| `Prefix + q` | Ladda om konfigurationen |
| `Prefix + ?` | Visa Tmux-tangentbindningar |
| `Prefix + :` | Kommandoprompt |

### Tmux-layoutfunktioner

Dessa funktioner måste köras inuti en Tmux-session.

| Kommando | Funktion |
| --- | --- |
| `tdl <ai> [<second_ai>]` | Skapa utvecklarlayout med redigerare, AI och terminal |
| `tdlm <ai> [<second_ai>]` | Skapa utvecklarlayout per underkatalog |
| `tsl <count> <command>` | Skapa svärmlayout med flera rutor |

## Ghostty-terminalen

Ghostty-terminalen installeras med _Installera > Terminal_ via Omarchy-menyn.

| Snabbtangent | Funktion |
| --- | --- |
| `Ctrl + Shift + E` | Ny delning nedanför |
| `Ctrl + Shift + O` | Ny delning bredvid |
| `Ctrl + Alt + Arrows` | Flytta mellan delningar |
| `Super + Ctrl + Shift + Arrows` | Ändra storlek på delningen med 10 rader |
| `Super + Ctrl + Shift + Alt + Arrows` | Ändra storlek på delningen med 100 rader |
| `Ctrl + Shift + T` | Ny flik |
| `Ctrl + Shift + Arrows` | Flytta mellan flikar |
| `Alt + Numbers` | Gå till specifik flik |
| `Shift + Pg Up/Down` | Rulla historiken |
| `Ctrl + Left mouse` | Öppna länken i webbläsaren |

## Filhanteraren

| Snabbtangent | Funktion |
| --- | --- |
| `Ctrl + L` | Gå till sökväg |
| `Space` | Förhandsvisa filen (piltangenterna navigerar) |
| `Alt + Up` | Gå upp till överordnad mapp |

## Neovim (w/ lazyvim)

### Navigering

| Snabbtangent | Funktion |
| --- | --- |
| `Space` | Visa kommandoalternativ |
| `Space Space` | Öppna fil via fuzzysökning |
| `Space E` | Växla sidofältet |
| `Space G G` | Visa git-kontroller |
| `Space S G` | Sök i filinnehåll |
| `Ctrl + W W` | Hoppa mellan sidofältet och redigeraren |
| `Ctrl + Left/right arrow` | Ändra storlek på sidofältet |
| `Shift + H` | Gå till filfliken till vänster |
| `Shift + L` | Gå till filfliken till höger |
| `Space B D` | Stäng filfliken |

### I sidofältet

| Snabbtangent | Funktion |
| --- | --- |
| `A` | Lägg till ny fil i överordnad katalog |
| `Shift + A` | Lägg till ny underkatalog i överordnad katalog |
| `D` | Ta bort markerad fil/katalog |
| `M` | Flytta markerad fil/katalog |
| `R` | Byt namn på markerad fil/katalog |
| `?` | Visa hjälp för alla kommandon |

[Se alla Neovim-snabbtangenter som konfigurerats av LazyVim](https://www.lazyvim.org/keymaps).

## Snabba emojier

Du kan använda `Super + Ctrl + E` för att visa en komplett emojiväljare som lägger valet på urklippet, eller så kan du använda dessa snabbåtkomstalternativ.

| Snabbtangent | EM | Ledtråd |
| --- | --- | --- |
| `Shift + CapsLock M S` | 😄 | leende |
| `Shift + CapsLock M C` | 😂 | gråt |
| `Shift + CapsLock M L` | 😍 | kärlek |
| `Shift + CapsLock M V` | ✌️ | seger |
| `Shift + CapsLock M H` | ❤️ | hjärta |
| `Shift + CapsLock M Y` | 👍 | ja |
| `Shift + CapsLock M N` | 👎 | nej |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | önskan |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | puss |
| `Shift + CapsLock M E` | 🙄 | himla med ögonen |
| `Shift + CapsLock M I` | 😉 | blinkning |
| `Shift + CapsLock M P` | 🙏 | be |
| `Shift + CapsLock M D` | 🤤 | dregla |
| `Shift + CapsLock M M` | 💰 | pengar |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | skål |
| `Shift + CapsLock M O` | 👌 | ok |
| `Shift + CapsLock M G` | 👋 | hälsning |
| `Shift + CapsLock M A` | 💪 | arm |
| `Shift + CapsLock M B` | 🤯 | sprängs |

## Snabbkompletteringar

| Snabbtangent | Komplettering |
| --- | --- |
| `Shift + CapsLock Space Space` | — (långt tankstreck) |
| `Shift + CapsLock Space N` | Ditt namn (som du angav vid konfigurationen) |
| `Shift + CapsLock Space E` | Din e-post (som du angav vid konfigurationen) |

Du kan lägga till fler av dina egna genom att redigera `~/.XCompose` och sedan köra `omarchy restart xcompose` i terminalen för att ändringarna ska börja gälla.
