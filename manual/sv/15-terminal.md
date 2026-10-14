# Terminal

[Foot](https://codeberg.org/dnkl/foot) är standardterminalen för Omarchy. Den är snabb, lättviktig och kompatibel med även gamla datorer. Den stöder dock inte inbyggda flikar eller delningar.

Om du använder Tmux kanske du inte bryr dig, men om inte stöder vi fullt ut _Alacritty_, _Ghostty_ och _Kitty_ som alternativ också. Välj din preferens under _Install > Terminal_ i Omarchy-menyn.

Du startar en ny terminal med `Super + Return`. (Denna bindning pekar automatiskt på vilken terminal du än har installerat via _Install > Terminal_, och du kan växla mellan installerade terminaler under _Setup > Defaults > Terminal_.)

## Tmux

Tmux tillhandahåller ett konsekvent, programmerbart gränssnitt för rutor, fönster (alias flikar) och återupptagbara sessioner oavsett din terminal. Det fungerar till och med på fjärrvärdar, så när du SSH:ar in på en server kan du använda samma tillvägagångssätt.

Du startar en ny Tmux-session i en ny terminal med `Super + Alt + Return`, och eftersom Tmux är en beständig process kan du återuppta din session även om du stänger den terminalen. Tryck bara på `Ctrl + Space` (kallas prefixtangenten) och sedan `s` för att se alla dina aktiva sessioner.

Omarchy levereras med en ergonomiskt optimerad Tmux-konfiguration, som har många tangentbindningar att lära sig, så ha [fusklappen till hands](07-hotkeys.md#tmux).

## Tmux layoutfunktioner

Eftersom Tmux är programmerbart kan vi använda funktioner för att skapa layouter. Omarchy levereras med fyra olika funktioner för vanliga utvecklarlayouter.

`tdl [agent]` startar ett trevägsdelat IDE-liknande gränssnitt med `$EDITOR` till vänster, din valda AI-agent till höger (som `c` för opencode eller `cx` för Claude eller `codex` för OpenAI), och sedan en terminal längst ner.

Så `tdl c` skulle starta detta (eller bara `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Du kan också starta en andra agent med `tdl c cx` (opencode + claude) (eller bara `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Det finns också `tds`, som startar en fyrvägsruta med redigeraren uppe till vänster, en live diff-bevakare uppe till höger, en terminal nere till vänster och opencode nere till höger.

Du kan också starta den här layoutkonfigurationen för varje underkatalog i den aktuella katalogen med `tdlm [agent]`, och sedan navigera med `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Slutligen kan du starta en svärm av agenter med `tsl [panes] [command]`. Så `tsl 4 c` ger dig ett fyrvägsrutnät med opencode-agenter:

 ![tmux-tsl](images/tmux-tsl.webp)
