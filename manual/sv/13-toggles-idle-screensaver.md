# Växlingar, inaktivitet och skärmsläckaren

Mycket av det du ändrar till vardags är egentligen inte en inställning. Det är ett läge du slår på i en timme och sedan slår av igen: nattljus när du jobbar sent, stör ej när du presenterar, håll dig vaken när du tittar på något. Omarchy kallar dem växlingar, och de fungerar alla på samma sätt — en snabbtangent, en menypost och ett kommando, som alla träffar samma omkopplare.

### Växlingsmenyn

`Super + Ctrl + O` öppnar _Trigger > Toggle_ direkt, eller så kan du ta dig dit från Omarchy-menyn (`Super + Space`). Allt i den listan är en omkopplare du kan slå om utan att fundera på var tillståndet bor. Omkopplare för hur skrivbordet ser ut sitter bredvid, under _Appearance_.

Från terminalen är samma omkopplare `omarchy toggle <thing>`. Kör `omarchy toggle` för sig själv för att se hela gruppen.

| Växling | Snabbtangent | Kommando |
| ------ | ------ | ------- |
| Nattljus | — | `omarchy toggle nightlight` |
| Tysta aviseringar | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Håll dig vaken (ingen låsning vid inaktivitet) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Insamling vid krasch | — | `omarchy toggle crash-capture` |
| Skärmsläckare | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temasynk | — | `omarchy toggle theme sync` |
| Menyrad | `Super + Shift + Space` | `omarchy toggle bar` |
| Skrivbord i helskärm (ingen rad, inga mellanrum) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animationer, oskärpa och skuggor | — | `omarchy toggle animations` |
| Styrplatta | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Pekskärm | — | `omarchy device touchscreen` |
| Försätt i vänteläge | — | `omarchy toggle suspend` |
| Hybrid-GPU | — | `omarchy device gpu hybrid` |

Omkopplarna för styrplatta, pekskärm och hybrid-GPU finns under _Trigger > Hardware_ (`Super + Ctrl + H`) i stället för under Toggle, eftersom de bara visas när du faktiskt har den hårdvaran. De för styrplatta och pekskärm överlever en omladdning av Hyprland — den inaktiverade enhetens namn sparas i en liten tillståndsfil som Hyprland läser vid start för att inaktivera den igen.

_Appearance_ innehåller menyraden och animationerna, plus några saker som inte är `omarchy toggle`-kommandon men beter sig likadant: batteriprocent i raden, standardlayouten för arbetsytor, och under _Windows_, fönstermellanrum (`Super + Shift + Backspace`) och det kvadratiska formatet för 1 fönster (`Super + Ctrl + Backspace`).

När Hyprland inte har någon GPU att rita med och renderar på CPU:n i stället (llvmpipe), som på Mac-datorer vars GPU ännu inte stöds, i de flesta virtuella maskiner, eller när en grafikdrivrutin inte laddas, stänger Omarchy av animationer, oskärpa och skuggor för den sessionen och berättar det en gång med en avisering. _Appearance > Animations On_ tar tillbaka dem, och Omarchy kommer ihåg det även för senare sessioner.

De flesta av dem är bara en flaggfil under `~/.local/state/omarchy/toggles/`. Om du vill grena på en av dem i ett skript ger `omarchy-toggle-enabled` dig en slutkod i stället för att tvinga dig att leta:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flaggorna är namngivna efter av-läget — `screensaver-off`, `suspend-off`, `bar-off` — så deras närvaro betyder att funktionen är inaktiverad.

### Indikatorer i raden

När ett läge är på får du en liten glyph i mitten av den övre raden bredvid klockan. Det är indikatorwidgeten, och den bär skärminspelning, väntande påminnelser, nattljus, stör ej och håll dig vaken, plus varningar medan lösenordslös sudo är på eller någon är ansluten till en fjärrsession.

Inaktiva indikatorer är dolda. Håll muspekaren var som helst på raden så tonas de in nedtonade, så du kan klicka på en för att slå på den utan att känna till dess snabbtangent. Klickar du på en aktiv stängs den av igen. Om du hellre vill se alla hela tiden sätter du `alwaysShow` till `true` på posten `omarchy.indicators` i `~/.config/omarchy/shell.json` — se [den övre raden](05-the-top-bar.md) för hur widgetar i raden konfigureras.

### Nattljus

Nattljus värmer skärmen till 4000K, och växlar du det igen sätts den tillbaka till 6500K. Slå om det från växlingsmenyn (`Super + Ctrl + O`) eller med `omarchy toggle nightlight`. Det drivs av hyprsunset, som växlingen startar åt dig om det inte redan körs.

Som standard gör hyprsunset ingenting alls med din skärm. `~/.config/hypr/hyprsunset.conf` levereras med en identitetsprofil just för att skärmen ska förbli orörd tills du ber om värme. Om du hellre vill att det växlar efter klockan ersätter du den med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Starta sedan hyprsunset vid inloggning genom att lägga till `o.launch_on_start("hyprsunset")` i `~/.config/hypr/autostart.lua`. Paret 4000K/6500K som växlingen använder är fast, så konfigurationsfilen är dit du går om du vill ha en annan temperatur.

### Stör ej

`Super + Ctrl + Alt + ,` tystar aviseringar. Inga toast-rutor dyker upp medan det är på, och indikatorn med den överstrukna klockan sitter i raden för att påminna dig om varför skrivbordet har tystnat.

Inget går förlorat, dock. Tystade aviseringar hålls tillbaka: sätt tillbaka de senaste på skärmen med `Super + Shift + Alt + ,`. Se [aviseringar](10-notices.md) för resten.

Tre slags meddelanden tar sig fortfarande igenom: Omarchys egna bekräftelsetoasts för något du just gjorde ("Theme changed", "Screenshot saved"), kritiska varningar som skickas från kommandoraden, och verifieringskoder. Chattappar som markerar allt som kritiskt för att tvinga sig in framför dig kvalificerar sig inte.

### Inaktivitet

Omarchy-skalet äger inaktivitetsbeteendet, och tiderna är ett `idle`-block på toppnivå i `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Båda talen är sekunder räknade från ögonblicket då du blev inaktiv — inte från varandra. Så med standardvärdena kommer skärmsläckaren upp efter två och en halv minut och låsskärmen tar över vid fem minuter, oavsett om skärmsläckaren kördes eller inte. Spara filen så plockar skalet upp de nya tiderna direkt.

Om du avfärdar skärmsläckaren före låsdeadlinen räknas det som aktivitet och den väntande låsningen avbryts. Du blir inte utlåst för att du kastar en blick på din maskin.

För att helt sluta låsa vid inaktivitet slår `Super + Ctrl + I` — eller `omarchy toggle idle` — på håll dig vaken, och kaffekoppsindikatorn visas i raden. Det är den du ska trycka på före en lång presentation eller en byggprocess du vill titta på. Tryck igen för att återgå till normalt. `omarchy toggle idle status` skriver ut aktuellt tillstånd som JSON om du behöver det från ett skript.

Det här handlar om låsning och skärmsläckaren, inte om ström. Vänteläge och dvala har sin egen konfiguration i [systemvila](36-system-sleep.md).

### Skärmsläckaren

Omarchys skärmsläckare är ASCII-konst som körs genom slumpmässiga texteffekter, en instans per bildskärm. Vilken tangent som helst eller musrörelse avslutar den.

Du kan starta den på begäran från _System > Screensaver_ (`Super + Esc`), vilket tvingar upp den även om du har stängt av skärmsläckaren vid inaktivitet. Det finns ingen snabbtangent bunden till den som standard.

`omarchy toggle screensaver` är det som stänger av den vid inaktivitet, om du hellre vill gå direkt från arbete till låst. Vilken tangent som helst, klick, scrollning eller musrörelse stänger den.

Logotypen den ritar kan du ändra, under _Appearance > Branding > Screensaver_. Ladda upp en png eller svg så konverterar Omarchy den till ASCII. Se [varumärke](41-branding.md).

### Låsskärmen

`Super + Ctrl + L` låser maskinen. Det kör låsskärmen från Omarchy-skalet, släcker skärmen, återställer din tangentbordslayout till den första så att du inte skriver ditt lösenord med fel alfabet, och — om du har det igång — låser 1Password på vägen ut.

Låsskärmen tar ett lösenord, och den tar ett fingeravtryck också när du väl har ställt in ett. Det, och de andra sätten att autentisera, täcks i [hårdvaruautentisering](37-hardware-authentication.md).
