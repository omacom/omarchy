# Växlingar, inaktivitet & skärmsläckaren

Mycket av det du ändrar dag för dag är egentligen inte en inställning. Det är ett läge du slår på i en timme och av igen: nattljus medan du jobbar sent, stör ej medan du presenterar, håll vaken medan du tittar på något. Omarchy kallar dem växlingar, och de fungerar alla på samma sätt — en snabbtangent, en menypost och ett kommando, som alla träffar samma strömbrytare.

### Växlingsmenyn

`Super + Ctrl + O` öppnar _Trigger > Toggle_ direkt, eller så kan du gå dit från Omarchy-menyn (`Super + Space`). Allt i den listan är en strömbrytare du kan slå om utan att tänka på var tillståndet bor. Strömbrytare för hur skrivbordet ser ut sitter bredvid, under _Trigger > Appearance_.

Från terminalen är samma strömbrytare `omarchy toggle <thing>`. Kör `omarchy toggle` på egen hand för att se hela gruppen.

| Växling | Snabbtangent | Kommando |
| ------ | ------ | ------- |
| Nattljus | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Tysta aviseringar | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Håll vaken (inget inaktivitetslås) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Kraschregistrering | — | `omarchy toggle crash-capture` |
| Skärmsläckare | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) temasynk | — | `omarchy toggle theme sync` |
| Menyfält | `Super + Shift + Space` | `omarchy toggle bar` |
| Styrplatta | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Pekskärm | — | `omarchy toggle touchscreen` |
| Viloläge | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Strömbrytarna för styrplatta, pekskärm och hybrid-GPU bor under _Trigger > Hardware_ (`Super + Ctrl + H`) snarare än under Toggle, eftersom de bara visas när du faktiskt har den hårdvaran. De för styrplatta och pekskärm överlever en Hyprland-omladdning — den inaktiverade enhetens namn sparas till en liten tillståndsfil som Hyprland läser vid uppstart för att inaktivera den igen.

_Trigger > Appearance_ innehåller menyfältet och animationerna, plus några saker som inte är `omarchy toggle`-kommandon men beter sig likadant: batteriprocent i fältet, standardlayouten för arbetsytor, fönstermellanrum (`Super + Shift + Backspace`) och 1-fönster kvadratisk aspekt (`Super + Ctrl + Backspace`).

De flesta av dessa är bara en flaggfil under `~/.local/state/omarchy/toggles/`. Om du vill grena på en i ett skript ger `omarchy-toggle-enabled` dig en exit-kod i stället för att tvinga dig att leta:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flaggorna är namngivna för av-tillståndet — `screensaver-off`, `suspend-off`, `bar-off` — så deras närvaro betyder att funktionen är inaktiverad.

### Indikatorer i fältet

När ett läge är på får du en liten symbol i mitten av menyfältet bredvid klockan. Det är indikatorwidgeten, och den bär diktering, skärminspelning, väntande påminnelser, nattljus, stör ej och håll vaken.

Inaktiva indikatorer är dolda. Hovra området runt dem så tonas de in nedtonade, så att du kan klicka på en för att slå på den utan att känna till dess snabbtangent. Att klicka på en aktiv stänger av den igen. Om du hellre vill se alla hela tiden, ställ in `alwaysShow` till `true` på posten `omarchy.indicators` i `~/.config/omarchy/shell.json` — se [menyfältet](05-the-top-bar.md) för hur fältwidgetar konfigureras.

### Nattljus

`Super + Ctrl + N` värmer skärmen till 4000K, och att trycka på den igen sätter tillbaka den till 6500K. Den drivs av hyprsunset, som växlingen startar åt dig om den inte redan körs.

Som standard gör hyprsunset ingenting alls med din skärm. `~/.config/hypr/hyprsunset.conf` levereras med en identitetsprofil just för att skärmen ska förbli orörd tills du ber om värme. Om du hellre vill att den växlar efter klockan, ersätt den med en tidsprofil:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Starta sedan hyprsunset vid inloggning genom att lägga till `o.launch_on_start("hyprsunset")` i `~/.config/hypr/autostart.lua`. Paret 4000K/6500K som växlingen använder är fast, så konfigurationsfilen är dit du går om du vill ha en annan temperatur.

### Stör ej

`Super + Ctrl + ,` tystar aviseringar. Inga toasts dyker upp medan det är på, och den överkryssade klockindikatorn sitter i fältet för att påminna dig om varför skrivbordet har blivit tyst.

Ingenting går förlorat dock. En tystad avisering skrivs direkt in i din aviseringshistorik, vilket är precis det register du vill ha när du kommer tillbaka och undrar vad du missade. Öppna den med `Super + Shift + Alt + ,`. Se [notiser](10-notices.md) för resten av aviseringsberättelsen.

Två typer av meddelanden släpps fortfarande igenom: Omarchys egna bekräftelsetoasts för något du just gjorde ("Theme changed", "Screenshot saved") och kritiska varningar skickade från kommandoraden. Chattappar som markerar allt som kritiskt för att tvinga sig framför dig kvalificerar sig inte.

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

Båda numren är sekunder räknade från ögonblicket du blev inaktiv — inte från varandra. Så med standardinställningarna kommer skärmsläckaren upp efter två och en halv minut och låsskärmen tar över vid fem minuter, oavsett om skärmsläckaren kördes eller inte. Spara filen så plockar skalet upp de nya tiderna direkt.

Om du avvisar skärmsläckaren före lås-deadlinen räknas det som aktivitet och det väntande låset avbryts. Du blir inte utelåst för att du kastade en blick på din maskin.

För att helt sluta låsa vid inaktivitet slår `Super + Ctrl + I` — eller `omarchy toggle idle` — på håll vaken, och kaffekoppsindikatorn visas i fältet. Det är den du trycker på före en lång presentation eller en build du vill titta på. Tryck på den igen för att gå tillbaka till normalt. `omarchy toggle idle status` skriver ut det aktuella tillståndet som JSON om du behöver det från ett skript.

Detta handlar om låsning och skärmsläckaren, inte ström. Viloläge och dvala har sin egen konfiguration i [systemvila](36-system-sleep.md).

### Skärmsläckaren

Omarchys skärmsläckare är ASCII-konst som körs genom slumpmässiga texteffekter, en instans per skärm. Valfri tangent eller musrörelse avslutar den.

Du kan starta den på begäran från _System > Screensaver_ (`Super + Esc`), vilket tvingar upp den även om du har stängt av inaktivitetsskärmsläckaren. Det finns ingen snabbtangent bunden till den som standard.

`omarchy toggle screensaver` är det som stänger av inaktivitetsvarianten, om du hellre vill gå rakt från arbete till låst. Den behöver en terminal den vet hur man konfigurerar — Alacritty, Foot, Ghostty eller Kitty — och berättar det för dig om din standardterminal är något annat.

Logotypen den ritar är din att ändra, under _Style > Screensaver_. Ladda upp en png eller svg så konverterar Omarchy den till ASCII. Se [branding](41-branding.md).

### Låsskärmen

`Super + Ctrl + L` låser maskinen. Det kör låsskärmen från Omarchy-skalet, blankar skärmen, återställer din tangentbordslayout till den första så att du inte skriver ditt lösenord i fel alfabet och — om du har det igång — låser 1Password på vägen ut.

Låsskärmen tar ett lösenord, och den tar också ett fingeravtryck när du väl har konfigurerat ett. Det, och de andra sätten att autentisera, behandlas i [hårdvaruauthentisering](37-hardware-authentication.md).
