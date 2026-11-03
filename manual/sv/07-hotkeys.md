# Snabbtangenter

Du kan se alla huvudsakliga tangentbordsbindningar med `Super + K` (Tmux-bindningar med `Super + Alt + K` och Herdr-bindningar med `Super + Ctrl + K`).

## Hur snabbtangenterna är upplagda

Varje snabbtangent sitter på ett plan, som bestäms av dess modifierare, och varje plan har ett jobb. Det är det som hindrar snabbtangenterna från att flyta ihop, och det betyder att du oftast kan gissa var något finns.

| Plan | Vad som finns där | Exempel |
| --- | --- | --- |
| `Super + key` | Systemet: fönster, arbetsytor, layouter och kärnmenyer | `Super + Space` Omarchy-menyn, `Super + W` stäng fönster, `Super + F` helskärm |
| `Super + Shift + key` | Appar | `Super + Shift + B` webbläsare, `Super + Shift + E` e-post, `Super + Shift + N` redigerare |
| `Super + Ctrl + key` | Paneler och systemmenyer | `Super + Ctrl + A` ljud, `Super + Ctrl + N` nätverk, `Super + Ctrl + C` inspelningsmeny |
| `Super + Ctrl + Alt + key` | Snabbåtgärder och meddelanden | `Super + Ctrl + Alt + T` visa tid, `Super + Ctrl + Alt + B` batteri, `Super + Ctrl + Alt + C` skärmdump |

Att lägga till `Alt` på en snabbtangent ger dig en variant av samma sak, aldrig något orelaterat:

- `Super + Shift + B` öppnar webbläsaren; `Super + Shift + Alt + B` öppnar ett privat fönster
- `Super + Shift + E` öppnar e-post; `Super + Shift + Alt + E` startar en ny
- `Super + F` går till helskärm; `Super + Alt + F` går till full bredd
- `Super + Ctrl + C` öppnar inspelningsmenyn; `Super + Ctrl + Alt + C` hoppar över menyn och tar en skärmdump

När du lägger till en snabbtangent:

1. Välj plan utifrån vad den gör, välj sedan tangenten.
2. Flytta inte en befintlig snabbtangent för att göra plats. Hitta en ledig tangent på rätt plan.
3. Använd bara `Alt` för en variant av snabbtangenten utan den.

Några snabbtangenter bryter mot dessa regler för att de är bekväma. `Shift` med en pil eller `Tab` flyttar eller vänder istället för att öppna en app, och `Print`, mediaknapparna, `Alt + Tab` och `Ctrl + Alt + Del` fungerar som de gör överallt annars. De är undantag, inte mönster att kopiera.

Om en standardbindning inte passar dig (säg att du vill ha `Super + Shift + S` för skärmdumpar som i Windows), bind om den i `~/.config/hypr/bindings.lua`.

## Navigering

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy-menyn (appar och allt annat)    |
| `Super + Alt + Space` | Apprutnät |
| `Super + Escape` | Systemmeny (viloläge, omstart, osv.)  |
| `Super + Ctrl + L` | Lås datorn |
| `Super + W` or `Super + Q` | Stäng fönster             |
| `Ctrl + Alt + Del` | Stäng alla fönster |
| `Super + T`               | Växla fönster mellan tiling/flytande             |
| `Super + J` | Växla fönsterposition (horisontell/vertikal) |
| `Super + O`               | Växla om fönstret poppar in i sticky'n'floating |
| `Super + L`               | Växla mellan layouterna dwindle, scrolling och floating |
| `Super + Alt + L`         | Växla mellan layouterna i omvänd ordning |
| `Super + P`               | Växla pseudo-fönsterstil (natural mot stretch) |
| `Super + F`                 | Gå till helskärm              |
| `Super + Alt + F`                 | Gå till full bredd              |
| `Super + Ctrl + F`                 | Gå till helskärm inuti fönstret              |
| `Super + 1/2/3/4`         | Hoppa till specifik arbetsyta på den fokuserade skärmen |
| `Super + Tab` | Hoppa till nästa arbetsyta på den fokuserade skärmen |
| `Super + Shift + Tab` | Hoppa till föregående arbetsyta på den fokuserade skärmen |
| `Super + Ctrl + Tab` | Hoppa till tidigare arbetsyta på den fokuserade skärmen |
| `Super + Shift + 1/2/3/4` | Flytta fönster till arbetsyta på den fokuserade skärmen |
| `Super + Shift + Alt + 1/2/3/4` | Flytta fönster till arbetsyta på den fokuserade skärmen utan att följa efter |
| `Super + S` | Växla full scratchpad |
| `Super + Alt + S` | Flytta fönster till full scratchpad |
| `Super + Grave` | Växla Quake-konsol |
| `Super + Shift + Grave` | Flytta fönster till Quake-konsol |
| `Super + Shift + Ctrl + Arrows` | Flytta fönster till skärmen i den riktningen |
| `Super + Shift + Alt + Arrows` | Flytta arbetsyta till skärmen i den riktningen |
| `Super + Arrow`  | Flytta fokus till fönster i pilens riktning, gå över till skärmen på den sidan vid skärmkanten |
| `Super + Shift + Arrow`  | Byt plats på fönster med ett annat i pilens riktning, inklusive ett på skärmen på den sidan |
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
| `Super + Scroll Wheel` | Scrolla genom arbetsytor på den fokuserade skärmen |
| `Super + G`               | Växla fönstergruppering      |
| `Super + Alt + G`               | Flytta fönster ut ur gruppering      |
| `Super + Alt + Tab`               | Växla mellan fönster i gruppering      |
| `Super + Alt + Shift + Tab`               | Växla bakåt mellan fönster i gruppering      |
| `Super + Alt + Scroll Wheel` | Växla mellan fönster i gruppering |
| `Super + Alt + 1/2/3/4/5`               | Hoppa till specifikt fönster i gruppering      |
| `Super + Alt + Arrow`  | Flytta fönster in i gruppering i pilens riktning, inklusive ett på skärmen på den sidan |
| `Super + Ctrl + Left/Right`  | Flytta mellan fönster inuti en tiling-grupp |
| `Super + Ctrl + Z` | Zooma in på skärmen (upprepa för mer zoom) |
| `Super + Ctrl + Alt + Z` | Zooma ut helt från skärmen |
| `Super + /` | Stega framåt genom skärmskalningsalternativen |
| `Super + Alt + /` | Stega bakåt genom skärmskalningsalternativen |
| `Alt + Tab` | Växla framåt genom fönster på den aktiva arbetsytan |
| `Alt + Shift + Tab` | Växla bakåt genom fönster på den aktiva arbetsytan |
| `Ctrl + Alt + Tab`| Växla fokus framåt genom skärmar |
| `Ctrl + Alt + Shift + Tab`| Växla fokus bakåt genom skärmar |

Snabbtangenterna för storleksändring använder de fysiska tangenterna `code:20` och `code:21` (XKB `<AE11>` och `<AE12>`), oavsett vilka tecken som är tryckta på tangentbordet. På amerikanska tangentbord är dessa tangenter `-` och `=`; på japanska (JIS) tangentbord är de `-` och `^`; på spanska tangentbord är de `'` och `¡`. På JIS är `Super + ^` `Super + Equal`, medan `Super + Shift + -` (som skriver `=`) är `Super + Shift + Minus`.

## Systemkontroller

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ljudpanel    |
| `Super + Ctrl + B`           | Bluetooth-panel    |
| `Super + Ctrl + N`           | Wifi/nätverkspanel    |
| `Super + Ctrl + D`           | Bildskärmspanel    |
| `Super + Ctrl + P`           | Strömpanel    |
| `Super + Ctrl + Alt + D`           | Kalenderpanel    |
| `Super + Ctrl + Alt + E`           | Världsklockspanel    |
| `Super + Ctrl + 1-9`           | Växla panel i listen efter position    |
| `Super + Ctrl + S` | Dela-meny (via LocalSend) |
| `Super + Ctrl + C` | Inspelningskontroller (skärmdump/-inspelning/väljare) |
| `Super + Ctrl + O` | Växla meny |
| `Super + Ctrl + H` | Hårdvarumeny |
| `Super + Ctrl + E` | Emoji-väljare |
| `Super + Ctrl + .` | Transkoda media |
| `Super + Shift + Ctrl + A` | Välj en AI-agent |

## Justeringar

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maximal skärmljusstyrka |
| `Shift + Brightness Down` | Minimal skärmljusstyrka |
| `Alt + Brightness Up/Down` | Exakta ändringar av ljusstyrkan med 1 % |
| `Alt + Volume Up/Down` | Exakta ändringar av volymen med 1 % |
| `Keyboard Brightness Up/Down` | Tangentbordsbelysning ljusare/mörkare |
| `Keyboard Backlight` | Växla mellan nivåerna för tangentbordsbelysning |
| `Alt + Play` | Nästa spår |
| `Alt + Shift + Play` | Föregående spår |

## Starta appar

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux-terminal |
| `Super + Ctrl + Return` | Herdr (agenthanterare) |
| `Super + Shift + Return`           | Webbläsare    |
| `Super + Shift + Alt + B`           | Webbläsare (privat/inkognito)    |
| `Super + Shift + F`           | Filhanterare    |
| `Super + Shift + Alt + F`           | Filhanterare i terminalens cwd    |
| `Super + Shift + M`           | Musik (Spotify)    |
| `Super + Shift + Alt + M`           | Musik (cliamp)    |
| `Super + Shift + /`           | Lösenordshanterare (1password)    |
| `Super + Shift + Q`           | Miniräknare (Omacalc)    |
| `Super + Shift + T`           | Aktivitet (btop)    |
| `Super + Shift + N`           | Redigerare (Neovim)  |
| `Super + Shift + C`           | Kalender ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-post ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Ny e-post ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Meddelandeapp (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Meddelandeapp (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Meddelandeapp (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Skrivande (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Ändra/lägg till bindningar i `~/.config/hypr/bindings.lua`.

## Universell urklipp

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + A`           | Markera allt i appar som stöder `Ctrl + A`    |
| `Super + C`           | Kopiera    |
| `Super + X`           | Klipp ut (inte i terminalen)    |
| `Super + V`           | Klistra in    |
| `Super + Ctrl + V`           | Urklippshanterare    |

Vanligtvis på Linux behöver du `Ctrl + Shift + C/V` för att kopiera och klistra in i terminalen och `Ctrl + C/V` för att göra det överallt annars. De här enhetliga urklippssnabbtangenterna i Omarchy fungerar överallt.

## Inspelning

| Snabbtangent              | Funktion                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Skärmdump                      |
| `Super + Ctrl + Alt + C`            | Skärmdump (samma bild, för tangentbord utan Print Screen-tangent) |
| `Super + Ctrl + C` | Inspelningsmeny |
| `Alt + Print Screen`            | Skärminspelning                     |
| `Super + Print Screen` | Färgväljare |
| `Super + Ctrl + Print Screen` | Textextrahering till urklipp |
| `Super + Alt + [` | Gör webbkameraöverlägget mindre under inspelning |
| `Super + Alt + ]` | Gör webbkameraöverlägget större under inspelning |
| `Alt + Shift + L` | Kopiera aktuell URL från webbapp eller Chromium |
| `Alt + Shift + D` | Ladda ner videon på den aktuella sidan till `~/Videos` |
| `Alt + Space` | Starta/stoppa diktering (kräver _Setup > Defaults > Dictation_) |
| `Right Alt` | Håll för att diktera (kräver _Setup > Defaults > Dictation_) |

Vid skärminspelningar frågar snabbtangenten först vilket ljud du vill ha, sedan startar inspelningen. Tryck på den igen för att stoppa. Se [skärmdumpar och inspelning](12-screenshots-recording.md) för detaljerna.

Alla inspelningsalternativ finns också under _Trigger > Capture_ i Omarchy-menyn (`Super + Space`).

## Aviseringar

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + ,` | Agera på senaste aviseringen: öppna den eller tryck på dess enda knapp, välj bland dess alternativ, eller avfärda den när den inte har några  |
| `Super + Shift + ,` | Avfärda alla aviseringar |
| `Super + Ctrl + ,` | Styr aviseringar med tangentbordet  |
| `Super + Alt + ,` | Avfärda senaste aviseringen  |
| `Super + Shift + Alt + ,` | Öppna aviseringshistorik  |
| `Super + Ctrl + Alt + ,` | Växla tystande av aviseringar  |

## Stil

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Välj ett nytt tema (även `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Välj temabakgrund (även `Super + Ctrl + Space`) |
| `Super + Backspace` | Växla transparens på ett fönster |
| `Super + Ctrl + Backspace` | Växla kvadratiskt format för ett enskilt fönster |

Extra bakgrundsbilder finns i `~/.config/omarchy/backgrounds/<theme name>`. Finns också via _Install > Style > Background_ i Omarchy-menyn.

Alla stilalternativ finns också under _Style_ i Omarchy-menyn (`Super + Space`).

## Växlingar

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Växla låsning vid inaktivitet |
| `Super + Ctrl + Delete` | Växla bärbara datorns skärm på/av |
| `Super + Ctrl + Alt + Delete` | Växla spegling av bärbara datorns skärm |
| `Super + Shift + Space` | Växla den övre listen  |
| `Shift + Mute` | Växla till nästa ljudutgång |
| `Shift + Play` | Växla till nästa mediakälla |
| `Super + Shift + Backspace` | Växla fönstermellanrum |
| `Super + Ctrl + Alt + F` | Växla helskärmsskrivbord (övre listen + fönstermellanrum) |

## Påminnelser

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Ställ in en påminnelse  |
| `Super + Ctrl + Alt + R` | Se alla påminnelser  |
| `Super + Ctrl + Shift + R` | Rensa alla påminnelser  |

## Meddelanden

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Visa tid som avisering  |
| `Super + Ctrl + Alt + B` | Visa batteri som avisering  |
| `Super + Ctrl + Alt + W` | Växla väder som avisering  |

## Tmux

Prefix-tangenten är `Ctrl + Space` (`Ctrl + B` fungerar också). Du kan ändra dessa bindningar i `~/.config/tmux/tmux.conf`.

### Rutor

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dela ruta bredvid (vertikal) |
| `Prefix + h` | Dela ruta nedanför (horisontell) |
| `Prefix + x` | Döda ruta |
| `Prefix + z` | Växla rutzoom (helskärm) |
| `Alt + Enter` | Dela ruta nedanför (utan prefix) |
| `Alt + Shift + Enter` | Dela ruta bredvid (utan prefix) |
| `Alt + Escape` | Döda ruta (utan prefix) |
| `Ctrl + Alt + Arrows` | Flytta mellan rutor |
| `Ctrl + Alt + Shift + Arrows` | Ändra storlek på rutor |

### Fönster

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nytt fönster |
| `Prefix + k` | Döda fönster |
| `Prefix + r` | Byt namn på fönster |
| `Alt + 1-9` | Gå till specifikt fönster |
| `Alt + Arrow Left/Right` | Flytta mellan fönster |
| `Alt + Shift + Arrow Left/Right` | Flytta fönster vänster/höger |

### Sessioner

| Snabbtangent                  | Funktion              |
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

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + [` | Gå in i kopieringsläge |
| `v` | Börja markering (i kopieringsläge) |
| `y` | Kopiera markering (i kopieringsläge) |

### Allmänt

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ladda om konfiguration |
| `Prefix + ?` | Visa Tmux-tangentbindningar |
| `Prefix + :` | Kommandoprompt |

### Tmux-layoutfunktioner

Dessa funktioner måste köras inuti en Tmux-session.

| Kommando | Funktion |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Skapa dev-layout med redigerare, AI och terminal |
| `tdlm <ai> [<second_ai>]` | Skapa dev-layout per underkatalog |
| `tsl <count> <command>` | Skapa swarm-layout med flera rutor |

## Ghostty Terminal

Ghostty-terminalen installeras med _Install > Terminal_ via Omarchy-menyn.

| Snabbtangent                  | Funktion              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Ny delning nedanför |
| `Ctrl + Shift + O` | Ny delning bredvid |
| `Ctrl + Alt + Arrows` | Flytta mellan delningar |
| `Super + Ctrl + Shift + Arrows` | Ändra storlek på delning med 10 rader |
| `Super + Ctrl + Shift + Alt + Arrows` | Ändra storlek på delning med 100 rader |
| `Ctrl + Shift + T` | Ny flik  |
| `Ctrl + Shift + Arrows` | Flytta mellan flikar |
| `Alt + Numbers` | Gå till specifik flik |
| `Shift + Pg Up/Down` | Scrolla historiken |
| `Ctrl + Left mouse` | Öppna länk i webbläsare |

## Filhanterare

| Snabbtangent              | Funktion                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Gå till sökväg                     |
| `Space`               | Förhandsgranska fil (pilar navigerar) |
| `Alt + Up`       | Gå upp till överordnad mapp        |

## Neovim (med lazyvim)

### Navigering

| Snabbtangent                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Visa kommandoalternativ            |
| `Space Space`              | Öppna fil via fuzzy-sökning      |
| `Space E`                  | Växla sidofält                  |
| `Space G G`                | Visa git-kontroller               |
| `Space S G`                | Sök i filinnehåll             |
| `Ctrl + W W`               | Hoppa mellan sidofält och redigerare |
| `Ctrl + Left/right arrow`  | Ändra storlek på sidofält          |
| `Shift + H`                      | Gå till vänster filflik             |
| `Shift + L`                      | Gå till höger filflik            |
| `Space B D`                | Stäng filflik                  |

### I sidofältet

| Snabbtangent                   | Funktion                        |
| ------------------------ | ------------------------------- |
| `A`                        | Lägg till ny fil i överordnad katalog      |
| `Shift + A`                | Lägg till ny underkatalog i överordnad katalog    |
| `D`                        | Ta bort markerad fil/katalog     |
| `M`                        | Flytta markerad fil/katalog       |
| `R`                        | Byt namn på markerad fil/katalog     |
| `?`                        | Visa hjälp för alla kommandon      |

[Se alla Neovim-snabbtangenter som konfigurerats av LazyVim](https://www.lazyvim.org/keymaps).

## Snabba emojis

Du kan använda `Super + Ctrl + E` för att visa en komplett emoji-väljare som lägger valet på urklippet, eller så kan du använda de här snabbåtkomstalternativen.

| Snabbtangent       | EM | Ledtråd       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | leende      |
| `Shift + CapsLock M C` | 😂 | gråt        |
| `Shift + CapsLock M L` | 😍 | kärlek       |
| `Shift + CapsLock M V` | ✌️ | seger    |
| `Shift + CapsLock M H` | ❤️ | hjärta      |
| `Shift + CapsLock M Y` | 👍 | ja        |
| `Shift + CapsLock M N` | 👎 | nej         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | önskan       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | puss       |
| `Shift + CapsLock M E` | 🙄 | himlar med ögonen    |
| `Shift + CapsLock M I` | 😉 | blinkning       |
| `Shift + CapsLock M P` | 🙏 | ber |
| `Shift + CapsLock M D` | 🤤 | dreglar      |
| `Shift + CapsLock M M` | 💰 | pengar      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | skål      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | hälsning |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | sprängs |

## Snabba kompletteringar

| Snabbtangent       | Komplettering       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Ditt namn (som det angavs vid installationen)  |
| `Shift + CapsLock Space E` | Din e-post (som den angavs vid installationen)  |

Du kan lägga till fler egna genom att redigera `~/.XCompose` och sedan köra `omarchy-restart-xcompose` i terminalen för att ändringarna ska börja gälla.
