# Snabbtangenter

Du kan se alla de viktigaste tangentbordsgenvägarna med `Super + K` (Tmux-genvägar med `Super + Alt + K` och Herdr-genvägar med `Super + Ctrl + K`).

## Hur snabbtangenterna är upplagda

Varje snabbtangent ligger på ett plan, som bestäms av dess modifierare, och varje plan har en enda uppgift. Det är det som hindrar snabbtangenterna från att flyta ihop, och det betyder att du oftast kan gissa var något hör hemma.

| Plan | Vad som hör hemma där | Exempel |
| --- | --- | --- |
| `Super + key` | Systemet: fönster, arbetsytor, layouter och kärnmenyer | `Super + Space` Omarchy-menyn, `Super + W` stäng fönster, `Super + F` helskärm |
| `Super + Shift + key` | Appar | `Super + Shift + B` webbläsare, `Super + Shift + E` e-post, `Super + Shift + N` redigerare |
| `Super + Ctrl + key` | Paneler och systemmenyer | `Super + Ctrl + A` ljud, `Super + Ctrl + N` nätverk, `Super + Ctrl + C` fångstmeny |
| `Super + Ctrl + Alt + key` | Snabbåtgärder och notiser | `Super + Ctrl + Alt + T` visa tiden, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skärmbild |

Att lägga till `Alt` på en snabbtangent ger dig en variant av samma sak, aldrig något orelaterat:

- `Super + Shift + B` öppnar webbläsaren; `Super + Shift + Alt + B` öppnar ett privat fönster
- `Super + Shift + E` öppnar e-post; `Super + Shift + Alt + E` börjar ett nytt meddelande
- `Super + F` går till helskärm; `Super + Alt + F` går till full bredd
- `Super + Ctrl + C` öppnar fångstmenyn; `Super + Ctrl + Alt + C` hoppar över menyn och tar en skärmbild

När du lägger till en snabbtangent:

1. Välj planet utifrån vad den gör, välj sedan tangenten.
2. Flytta inte en befintlig snabbtangent för att göra plats. Hitta en ledig tangent på rätt plan.
3. Använd bara `Alt` för en variant av snabbtangenten utan den.

Några snabbtangenter bryter mot de här reglerna för att de är bekväma. `Shift` med en pil eller `Tab` flyttar eller vänder i stället för att öppna en app, och `Print`, medietangenterna, `Alt + Tab` och `Ctrl + Alt + Del` fungerar som de gör överallt annars. De är undantag, inte mönster att kopiera.

Om en standardinställning inte passar dig (säg att du vill ha `Super + Shift + S` för skärmbilder som på Windows) binder du om den i `~/.config/hypr/bindings.lua`.

## Navigering

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menyn (appar och allt annat)    |
| `Super + Alt + Space` | Apprutnät |
| `Super + Escape` | Systemmeny (viloläge, omstart, osv.)  |
| `Super + Ctrl + L` | Lås datorn |
| `Super + W` or `Super + Q` | Stäng fönster             |
| `Ctrl + Alt + Del` | Stäng alla fönster |
| `Super + K` | Visa alla snabbtangenter |
| `Super + Alt + K` | Visa tmux-snabbtangenter |
| `Super + Ctrl + K` | Visa herdr-snabbtangenter |
| `Super + M` | Minimera fönstret till dockan |
| `Super + T`               | Växla fönstret mellan kaklat/flytande             |
| `Super + J` | Växla fönstrets position (horisontell/vertikal) |
| `Super + O`               | Växla att fönstret poppar till sticky'n'floating |
| `Super + L`               | Bläddra genom layouterna dwindle, scrolling och floating |
| `Super + Alt + L`         | Bläddra genom layouterna i omvänd ordning |
| `Super + P`               | Växla pseudo-fönsterstil (naturlig mot stretch) |
| `Super + F`                 | Gå till helskärm              |
| `Super + Alt + F`                 | Gå till full bredd              |
| `Super + Ctrl + F`                 | Gå till helskärm inuti fönstret              |
| `Super + 1…9/0`         | Hoppa till en viss arbetsyta (0 är 10) på den fokuserade skärmen |
| `Super + Tab` | Hoppa till nästa arbetsyta på den fokuserade skärmen |
| `Super + Shift + Tab` | Hoppa till föregående arbetsyta på den fokuserade skärmen |
| `Super + Ctrl + Tab` | Hoppa till den tidigare arbetsytan på den fokuserade skärmen |
| `Super + Shift + 1…9/0` | Flytta fönstret till en arbetsyta på den fokuserade skärmen |
| `Super + Shift + Alt + 1…9/0` | Flytta fönstret till en arbetsyta på den fokuserade skärmen utan att följa efter |
| `Super + S` | Växla full scratchpad |
| `Super + Alt + S` | Flytta fönstret till full scratchpad |
| `Super + Grave` | Växla Quake-konsolen |
| `Super + Shift + Grave` | Flytta fönstret till Quake-konsolen |
| `Super + Shift + Ctrl + Arrows` | Flytta fönstret till skärmen i den riktningen |
| `Super + Shift + Alt + Arrows` | Flytta arbetsytan till skärmen i den riktningen |
| `Super + Arrow`  | Flytta fokus till fönstret i pilens riktning, och gå över till skärmen på den sidan vid skärmkanten |
| `Super + Shift + Arrow`  | Byt fönstret mot ett annat i pilens riktning, inklusive ett på skärmen på den sidan |
| `Super + Minus` | Expandera fönstret åt vänster |
| `Super + Equal` | Krymp fönstret åt vänster |
| `Super + Shift + Minus` | Krymp fönstret uppåt |
| `Super + Shift + Equal` | Expandera fönstret nedåt |
| `Super + Alt + Minus/Equal` | Samma storleksändring i mindre steg |
| `Super + Ctrl + Minus/Equal` | Samma storleksändring i större steg |
| `Super + Alt + Home` | Spara fönstrets bredd |
| `Super + Home` | Återställ den sparade fönsterbredden |
| `Super + Left Mouse` | Dra runt fönstret |
| `Super + Right Mouse` | Ändra fönstrets storlek |
| `Super + Scroll Wheel` | Bläddra genom arbetsytor på den fokuserade skärmen |
| `Super + G`               | Växla fönstergruppering      |
| `Super + Alt + G`               | Flytta fönstret ut ur grupperingen      |
| `Super + Alt + Tab`               | Bläddra mellan fönster i grupperingen      |
| `Super + Alt + Shift + Tab`               | Bläddra bakåt mellan fönster i grupperingen      |
| `Super + Alt + Scroll Wheel` | Bläddra mellan fönster i grupperingen |
| `Super + Alt + 1/2/3/4/5`               | Hoppa till ett visst fönster i grupperingen      |
| `Super + Alt + Arrow`  | Flytta fönstret in i grupperingen i pilens riktning, inklusive ett på skärmen på den sidan |
| `Super + Ctrl + Left/Right`  | Flytta mellan fönster inuti en kakelgrupp |
| `Super + Ctrl + Z` | Zooma in på skärmen (upprepa för mer zoom) |
| `Super + Ctrl + Alt + Z` | Zooma ut helt från skärmen |
| `Super + /` | Stega framåt genom alternativen för skärmskalning |
| `Super + Alt + /` | Stega bakåt genom alternativen för skärmskalning |
| `Alt + Tab` | Bläddra framåt genom fönster på den aktiva arbetsytan |
| `Alt + Shift + Tab` | Bläddra bakåt genom fönster på den aktiva arbetsytan |
| `Ctrl + Alt + Tab`| Bläddra fokus framåt genom skärmar |
| `Ctrl + Alt + Shift + Tab`| Bläddra fokus bakåt genom skärmar |
| `Super + I` | Byt inmatningsspråk (med mer än en layout eller inmatningsmetod) |
| `Super + Shift + I` | Byt tillbaka inmatningsspråk |

På en styrplatta växlar svep med tre och fyra fingrar arbetsytor, flyttar fönster och öppnar menyn och Quake-konsolen; se [tangentbord, mus och styrplatta](34-keyboard-mouse-trackpad.md) för gesterna.

Genvägar för storleksändring använder de fysiska tangenterna `code:20` och `code:21` (XKB `<AE11>` och `<AE12>`), oavsett vilka tecken som är tryckta på tangentbordet. På amerikanska tangentbord är de här tangenterna `-` och `=`; på japanska (JIS) tangentbord är de `-` och `^`; på spanska tangentbord är de `'` och `¡`. På JIS är `Super + ^` `Super + Equal`, medan `Super + Shift + -` (som skriver `=`) är `Super + Shift + Minus`.

## Systemkontroller

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ljudpanel    |
| `Super + Ctrl + B`           | Bluetooth-panel    |
| `Super + Ctrl + N`           | Wi-Fi-/nätverkspanel    |
| `Super + Ctrl + D`           | Bildskärmspanel    |
| `Super + Ctrl + P`           | Strömpanel    |
| `Super + Ctrl + X`           | Agentpanel    |
| `Super + Ctrl + Alt + X`           | Panel för lokala modeller    |
| `Super + Ctrl + Alt + D`           | Kalenderpanel    |
| `Super + Ctrl + Alt + E`           | Världsklockpanel    |
| `Super + Ctrl + 1-9`           | Växla panel i listen efter position    |
| `Super + Ctrl + S` | Delningsmeny (via LocalSend) |
| `Super + Ctrl + C` | Fångstkontroller (skärmbild/-inspelning/väljare) |
| `Super + Ctrl + O` | Växla meny |
| `Super + Ctrl + H` | Hårdvarumenu |
| `Super + Ctrl + E` | Emojiväljare |
| `Super + Ctrl + .` | Omkoda media |
| `Super + Shift + Ctrl + A` | Välj en AI-agent |
| `Power` key | Systemmeny |
| `Super + Shift + Copilot` key | Omarchy-menyn |

## Justeringar

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximal skärmljusstyrka |
| `Shift + Brightness Down` | Minimal skärmljusstyrka |
| `Alt + Brightness Up/Down` | Exakta ändringar av ljusstyrkan med 1 % |
| `Alt + Volume Up/Down` | Exakta volymändringar med 1 % |
| `Keyboard Brightness Up/Down` | Tangentbordsbelysningen ljusare/mörkare |
| `Keyboard Backlight` | Bläddra genom nivåerna för tangentbordsbelysning |
| `Ctrl + Brightness Up/Down` | Tangentbordsbelysningen ljusare/mörkare, på tangentbord utan egna tangenter |
| `Mic Mute` | Stäng av mikrofonen |
| `Shift + Mute` | Byt ljudutgång |
| `Touchpad Toggle` | Slå på eller av styrplattan |
| `Display` key | Bläddra genom arbetsytans layout |
| `Alt + Play` | Nästa spår |
| `Alt + Shift + Play` | Föregående spår |

## Starta appar

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agenthanterare) |
| `Super + Shift + Return` or `Super + Shift + B`  | Webbläsare    |
| `Super + Shift + Alt + B`           | Webbläsare (privat/inkognito)    |
| `Super + Shift + F`           | Filhanterare    |
| `Super + Shift + Alt + F`           | Filhanterare i terminalens cwd    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Lösenordshanterare (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkylator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, när det har installerats)    |
| `Super + Shift + T`           | Aktivitet (btop)    |
| `Super + Shift + N`           | Redigerare (Plain, eller den du har valt som standard)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-post ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nytt e-postmeddelande ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Meddelanden (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Meddelanden (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Meddelanden (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Skrivande (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nytt inlägg) |
| `Super + Shift + Y`           | YouTube |

Ändra/lägg till bindningar i `~/.config/hypr/bindings.lua`.

## Universellt urklipp

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + A`           | Markera allt i appar som stöder `Ctrl + A`    |
| `Super + C`           | Kopiera    |
| `Super + X`           | Klipp ut (inte i terminalen)    |
| `Super + V`           | Klistra in    |
| `Super + Ctrl + V`           | Urklippshanterare    |

På Linux behöver du vanligtvis `Ctrl + Shift + C/V` för att kopiera och klistra in i terminalen och `Ctrl + C/V` för att göra det överallt annars. De här enhetliga Omarchy-snabbtangenterna för urklipp fungerar överallt.

## Fånga

| Snabbtangent              | Funktion                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skärmbild                      |
| `Super + Ctrl + Alt + C`            | Skärmbild (samma bild, för tangentbord utan Print Screen-tangent) |
| `Super + Ctrl + C` | Fångstmeny |
| `Alt + Print Screen`            | Skärminspelning                     |
| `Super + Shift + Ctrl + Alt + C` | Skärminspelning utan ljud, hoppar över menyn (tryck igen för att stoppa) |
| `Super + Print Screen` | Färgväljare |
| `Super + Ctrl + Print Screen` | Textextrahering till urklipp |
| `Super + Alt + [` | Gör webbkameraöverlägget mindre under inspelning |
| `Super + Alt + ]` | Gör webbkameraöverlägget större under inspelning |
| `Alt + Shift + L` | Kopiera aktuell URL från webbapp eller webbläsare |
| `Alt + Shift + D` | Ladda ner videon på den aktuella sidan till `~/Videos` |
| `Alt + Space` | Starta/stoppa diktering (kräver _Setup > Defaults > Dictation_) |
| `Right Alt` | Håll in för att diktera (kräver _Setup > Defaults > Dictation_) |

Med skärminspelningar frågar snabbtangenten först vilket ljud du vill ha, sedan börjar inspelningen. Tryck på den igen för att stoppa. Se [skärmbilder och inspelning](12-screenshots-recording.md) för detaljerna.

Alla fångstalternativ finns också under _Trigger > Capture_ i Omarchy-menyn (`Super + Space`).

## Aviseringar

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + ,` | Agera på den senaste aviseringen: öppna den eller tryck på dess enda knapp, välj bland dess alternativ, eller avvisa den när den inte har några  |
| `Super + Shift + ,` | Avvisa alla aviseringar |
| `Super + Ctrl + ,` | Styr aviseringar med tangentbordet  |
| `Super + Alt + ,` | Avvisa den senaste aviseringen  |
| `Super + Shift + Alt + ,` | Öppna aviseringshistoriken  |
| `Super + Ctrl + Alt + ,` | Växla tystande av aviseringar  |

## Stil

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Välj ett nytt tema (även `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Välj temabakgrund (även `Super + Ctrl + Space`) |
| `Super + Backspace` | Växla transparens på ett fönster |
| `Super + Ctrl + Backspace` | Växla kvadratiskt format för ett enskilt fönster |

Extra bakgrundsbilder finns i `~/.config/omarchy/backgrounds/<theme name>`. Finns också via _Install > Style > Background_ i Omarchy-menyn.

Alla stilalternativ finns också under _Appearance_ i Omarchy-menyn (`Super + Space`).

## Växlar

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Växla låsning vid inaktivitet |
| `Super + Ctrl + Delete` | Slå på/av den bärbara datorns skärm |
| `Super + Ctrl + Alt + Delete` | Växla spegling av den bärbara datorns skärm |
| `Super + Shift + Space` | Växla den övre listen  |
| `Shift + Mute` | Byt till nästa ljudutgång |
| `Shift + Play` | Byt till nästa mediekälla |
| `Super + Shift + Backspace` | Växla fönstermellanrum |
| `Super + Ctrl + Alt + F` | Växla helskärmsskrivbord (övre listen + fönstermellanrum) |

## Påminnelser

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Ställ in en påminnelse  |
| `Super + Ctrl + Alt + R` | Se alla påminnelser  |
| `Super + Ctrl + Shift + R` | Rensa alla påminnelser  |

## Notiser

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Visa tiden som en notis  |
| `Super + Ctrl + Alt + B` | Visa batteriet som en notis  |
| `Super + Ctrl + Alt + W` | Växla vädret som en notis  |

## Tmux

Prefix-tangenten är `Ctrl + Space` (`Ctrl + B` fungerar också). Du kan ändra de här bindningarna i `~/.config/tmux/tmux.conf`.

### Rutor

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dela rutan bredvid (vertikalt) |
| `Prefix + h` | Dela rutan nedanför (horisontellt) |
| `Prefix + x` | Stäng rutan |
| `Prefix + z` | Växla rutans zoom (helskärm) |
| `Alt + Enter` | Dela rutan nedanför (inget prefix) |
| `Alt + Shift + Enter` | Dela rutan bredvid (inget prefix) |
| `Alt + Escape` | Stäng rutan (inget prefix) |
| `Ctrl + Alt + Arrows` | Flytta mellan rutor |
| `Ctrl + Alt + Shift + Arrows` | Ändra storlek på rutor |

### Fönster

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nytt fönster |
| `Prefix + k` | Stäng fönstret |
| `Prefix + r` | Byt namn på fönstret |
| `Alt + 1-9` | Gå till ett visst fönster |
| `Alt + Arrow Left/Right` | Flytta mellan fönster |
| `Alt + Shift + Arrow Left/Right` | Flytta fönstret åt vänster/höger |

### Sessioner

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + C` | Ny session |
| `Prefix + K` | Stäng sessionen |
| `Prefix + R` | Byt namn på sessionen |
| `Prefix + N` | Nästa session |
| `Prefix + P` | Föregående session |
| `Alt + Arrow Up/Down` | Flytta mellan sessioner |
| `Prefix + s` | Lista sessioner |
| `Prefix + d` | Koppla bort från sessionen |

### Kopieringsläge (vi-stil)

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + [` | Gå in i kopieringsläge |
| `v` | Börja markera (i kopieringsläge) |
| `y` | Kopiera markeringen (i kopieringsläge) |

### Allmänt

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ladda om konfigurationen |
| `Prefix + ?` | Visa Tmux-tangentbindningar |
| `Prefix + :` | Kommandoprompt |

### Tmux-layoutfunktioner

De här funktionerna måste köras inuti en Tmux-session.

| Kommando | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Skapa en utvecklarlayout med redigerare, AI och terminal |
| `tdlm <ai> [<second_ai>]` | Skapa en utvecklarlayout per underkatalog |
| `tsl <count> <command>` | Skapa en svärmlayout med flera rutor |

## Ghostty-terminalen

Ghostty-terminalen installeras med _Install > Terminal_ via Omarchy-menyn.

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ny delning nedanför |
| `Ctrl + Shift + O` | Ny delning bredvid |
| `Ctrl + Alt + Arrows` | Flytta mellan delningar |
| `Super + Ctrl + Shift + Arrows` | Ändra delningens storlek med 10 rader |
| `Super + Ctrl + Shift + Alt + Arrows` | Ändra delningens storlek med 100 rader |
| `Ctrl + Shift + T` | Ny flik  |
| `Ctrl + Shift + Arrows` | Flytta mellan flikar |
| `Alt + Numbers` | Gå till en viss flik |
| `Shift + Pg Up/Down` | Bläddra i historiken |
| `Ctrl + Left mouse` | Öppna länken i webbläsaren |

## Filhanteraren

| Snabbtangent              | Funktion                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Gå till sökväg                     |
| `Space`               | Förhandsgranska filen (pilarna navigerar) |
| `Alt + Up`       | Gå upp till den överordnade mappen        |

## Neovim (med lazyvim)

### Navigering

| Snabbtangent                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Visa kommandoalternativ            |
| `Space Space`              | Öppna filen via fuzzy-sökning      |
| `Space E`                  | Växla sidofältet                  |
| `Space G G`                | Visa git-kontroller               |
| `Space S G`                | Sök i filens innehåll             |
| `Ctrl + W W`               | Hoppa mellan sidofältet och redigeraren |
| `Ctrl + Left/right arrow`  | Ändra sidofältets storlek          |
| `Shift + H`                      | Gå till filfliken till vänster             |
| `Shift + L`                      | Gå till filfliken till höger            |
| `Space B D`                | Stäng filfliken                  |

### I sidofältet

| Snabbtangent                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lägg till en ny fil i den överordnade katalogen      |
| `Shift + A`                | Lägg till en ny underkatalog i den överordnade katalogen    |
| `D`                        | Ta bort den markerade filen/katalogen     |
| `M`                        | Flytta den markerade filen/katalogen       |
| `R`                        | Byt namn på den markerade filen/katalogen     |
| `?`                        | Visa hjälp för alla kommandon      |

[Se alla Neovim-snabbtangenter som konfigurerats av LazyVim](https://www.lazyvim.org/keymaps).

## Snabb-emojis

Du kan använda `Super + Ctrl + E` för att visa en komplett emojiväljare som lägger markeringen i urklipp, eller så kan du använda de här snabbåtkomstalternativen.

| Snabbtangent       | EM | Ledtråd       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | leende      |
| `Shift + CapsLock M C` | 😂 | gråt        |
| `Shift + CapsLock M L` | 😍 | kärlek       |
| `Shift + CapsLock M V` | ✌️ | seger    |
| `Shift + CapsLock M H` | ❤️ | hjärta      |
| `Shift + CapsLock M Y` | 👍 | ja        |
| `Shift + CapsLock M N` | 👎 | nej         |
| `Shift + CapsLock M F` | 🖕 | fan       |
| `Shift + CapsLock M W` | 🤞 | önska       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | puss       |
| `Shift + CapsLock M E` | 🙄 | himla med ögonen    |
| `Shift + CapsLock M I` | 😉 | blinkning       |
| `Shift + CapsLock M P` | 🙏 | be |
| `Shift + CapsLock M D` | 🤤 | dregla      |
| `Shift + CapsLock M M` | 💰 | pengar      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | skål      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | hälsning |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | sprängs |

## Snabbkompletteringar

| Snabbtangent       | Komplettering       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (långt tankstreck)   |
| `Shift + CapsLock Space N` | Ditt namn (som det angavs vid installationen)  |
| `Shift + CapsLock Space E` | Din e-postadress (som den angavs vid installationen)  |

Du kan lägga till fler egna genom att redigera `~/.XCompose` och sedan köra `omarchy restart xcompose` i terminalen för att ändringarna ska börja gälla.
