# Växlar, inaktivitet & skärmsläckaren

Mycket av det du ändrar till vardags är egentligen ingen inställning. Det är ett läge du slår på i en timme och sedan slår av igen: nattljus när du jobbar sent, stör ej när du presenterar, håll dig vaken när du tittar på något. Omarchy kallar dem växlar, och de fungerar alla på samma sätt — en snabbtangent, ett menyval och ett kommando som alla träffar samma omkopplare.

### Växelmenyn

`Super + Ctrl + O` öppnar _Utlösare > Växel_ direkt, eller så kan du gå dit från Omarchy-menyn (`Super + Space`). Allt i den listan är en omkopplare du kan slå om utan att fundera på var tillståndet bor. Omkopplare för hur skrivbordet ser ut sitter bredvid, under _Utseende_.

Från terminalen är samma omkopplare `omarchy toggle <thing>`. Kör `omarchy toggle` på egen hand för att se hela gruppen.

| Växel | Snabbtangent | Kommando |
| ------ | ------ | ------- |
| Nattljus | — | `omarchy toggle nightlight` |
| Tysta aviseringar | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Håll dig vaken (ingen låsning vid inaktivitet) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kraschfångst | — | `omarchy toggle crash-capture` |
| Skärmsläckare | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev)-temasynk | — | `omarchy toggle theme sync` |
| Menyrad | `Super + Shift + Space` | `omarchy toggle bar` |
| Styrplatta | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Pekskärm | — | `omarchy toggle touchscreen` |
| Viloläge | — | `omarchy toggle suspend` |
| Hybrid-GPU | — | `omarchy toggle hybrid gpu` |

Omkopplarna för styrplatta, pekskärm och hybrid-GPU finns under _Utlösare > Hårdvara_ (`Super + Ctrl + H`) i stället för under Växel, eftersom de bara visas när du faktiskt har den hårdvaran. Omkopplarna för styrplatta och pekskärm överlever en omladdning av Hyprland — namnet på den inaktiverade enheten sparas i en liten tillståndsfil som Hyprland läser vid start för att inaktivera den igen.

_Utseende_ innehåller menyraden och animationer, plus några saker som inte är `omarchy toggle`-kommandon men beter sig likadant: batteriprocent i raden, standardlayouten för arbetsytor och, under _Fönster_, mellanrum mellan fönster (`Super + Shift + Backspace`) och det kvadratiska bildförhållandet för 1 fönster (`Super + Ctrl + Backspace`).

När Hyprland inte har någon GPU att rita med och renderar på CPU:n i stället (llvmpipe), som på Mac-datorer vars GPU ännu inte stöds, i de flesta virtuella maskiner eller när en grafikdrivrutin inte laddas, stänger Omarchy av animationer, oskärpa och skuggor för den sessionen och meddelar dig det en gång med en avisering. _Utseende > Animationer på_ tar tillbaka dem, och Omarchy kommer ihåg det även för senare sessioner.

De flesta av dessa är bara en flaggfil under `~/.local/state/omarchy/toggles/`. Om du vill grena på en av dem i ett skript ger `omarchy-toggle-enabled` dig en exitkod i stället för att tvinga dig att leta:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flaggorna är uppkallade efter av-läget — `screensaver-off`, `suspend-off`, `bar-off` — så deras närvaro betyder att funktionen är inaktiverad.

### Indikatorer i raden

När ett läge är på får du en liten glyf i mitten av den övre raden bredvid klockan. Det är indikatorwidgeten, och den bär diktering, skärminspelning, väntande påminnelser, nattljus, stör ej och håll dig vaken.

Inaktiva indikatorer är dolda. Håll muspekaren var som helst över raden så tonar de in nedtonade, så att du kan klicka på en för att slå på den utan att kunna dess snabbtangent. Klickar du på en aktiv stängs den av igen. Om du hellre vill se alla hela tiden sätter du `alwaysShow` till `true` på posten `omarchy.indicators` i `~/.config/omarchy/shell.json` — se [den övre raden](05-the-top-bar.md) för hur widgetar i raden konfigureras.

### Nattljus

Nattljus värmer skärmen till 4000K, och slår du om det igen går den tillbaka till 6500K. Slå om det från växelmenyn (`Super + Ctrl + O`) eller med `omarchy toggle nightlight`. Det drivs av hyprsunset, som växeln startar åt dig om det inte redan körs.

Som standard gör hyprsunset ingenting alls med din skärm. `~/.config/hypr/hyprsunset.conf` levereras med en identitetsprofil just för att displayen ska förbli orörd tills du ber om värme. Om du hellre vill att det växlar efter klockan ersätter du den med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Starta sedan hyprsunset vid inloggning genom att lägga till `o.launch_on_start("hyprsunset")` i `~/.config/hypr/autostart.lua`. 4000K/6500K-paret som växeln använder är fast, så konfigurationsfilen är dit du går om du vill ha en annan temperatur.

### Stör ej

`Super + Ctrl + Alt + ,` tystar aviseringar. Inga toasts dyker upp medan det är på, och den överstrukna klockindikatorn sitter i raden för att påminna dig om varför skrivbordet har blivit tyst.

Ingenting går förlorat, dock. Tystade aviseringar hålls tillbaka: sätt tillbaka de senaste på skärmen med `Super + Shift + Alt + ,`. Se [aviseringar](10-notices.md) för resten.

Två sorters meddelanden släpps fortfarande igenom: Omarchys egna bekräftelse-toasts för något du just gjorde ("Temat ändrat", "Skärmbild sparad"), och kritiska varningar som skickas från kommandoraden. Chattappar som markerar allt som kritiskt för att tvinga sig framför dig räknas inte.

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

Båda talen är sekunder räknat från ögonblicket du blev inaktiv — inte från varandra. Så med standardvärdena kommer skärmsläckaren upp efter två och en halv minut och låsskärmen tar över vid fem minuter, oavsett om skärmsläckaren kördes eller inte. Spara filen så plockar skalet upp de nya tiderna direkt.

Om du avfärdar skärmsläckaren före låsdeadlinen räknas det som aktivitet och den väntande låsningen avbryts. Du blir inte utelåst för att du kastade en blick på maskinen.

För att sluta låsa vid inaktivitet helt slår `Super + Ctrl + I` — eller `omarchy toggle idle` — på håll dig vaken, och kaffekoppsindikatorn visas i raden. Det är den du ska trycka på före en lång presentation eller ett bygge du vill titta på. Tryck på den igen för att återgå till normalt. `omarchy toggle idle status` skriver ut det aktuella läget som JSON om du behöver det från ett skript.

Det här handlar om låsning och skärmsläckaren, inte ström. Viloläge och dvala har sin egen konfiguration i [systemvila](36-system-sleep.md).

### Skärmsläckaren

Omarchys skärmsläckare är ASCII-konst som körs genom slumpmässiga texteffekter, en instans per bildskärm. Vilken tangent som helst eller en musrörelse avslutar den.

Du kan starta den på begäran från _System > Skärmsläckare_ (`Super + Esc`), vilket tvingar upp den även om du har stängt av skärmsläckaren vid inaktivitet. Det finns ingen snabbtangent bunden till den som standard.

`omarchy toggle screensaver` är det som stänger av den vid inaktivitet, om du hellre går direkt från arbete till låst. Vilken tangent, klick, rullning eller musrörelse som helst stänger den.

Logotypen den ritar är din att ändra, under _Utseende > Varumärkesprofil > Skärmsläckare_. Ladda upp en png eller svg så konverterar Omarchy den till ASCII. Se [varumärkesprofil](41-branding.md).

### Låsskärmen

`Super + Ctrl + L` låser maskinen. Det kör låsskärmen från Omarchy-skalet, gör displayen tom, återställer din tangentbordslayout till den första så att du inte skriver ditt lösenord i fel alfabet, och — om du har det igång — låser 1Password på vägen ut.

Låsskärmen tar ett lösenord, och den tar ett fingeravtryck också när du väl har ställt in ett. Det, och de andra sätten att autentisera, täcks i [hårdvaruautentisering](37-hardware-authentication.md).
