# Terminal

[Foot](https://codeberg.org/dnkl/foot) is de standaardterminal voor Omarchy. Hij is snel, lichtgewicht en compatibel met zelfs oude computers. Hij ondersteunt echter geen native tabbladen of splitsingen.

Als je Tmux gebruikt, vind je dat misschien niet erg, maar zo niet, dan ondersteunen we ook volledig _Alacritty_, _Ghostty_ en _Kitty_ als opties. Kies je voorkeur onder _Installeren > Terminal_ in het Omarchy-menu.

Je start een nieuwe terminal met `Super + Return`. (Deze binding wijst automatisch naar welke Terminal je ook hebt geïnstalleerd via _Installeren > Terminal_, en je kunt wisselen tussen geïnstalleerde terminals onder _Instellen > Standaardwaarden > Terminal_.)

## Tmux

Tmux biedt een consistente, programmeerbare interface voor panes, vensters (aka tabbladen) en hervatbare sessies ongeacht je terminal. Het werkt zelfs op externe hosts, dus wanneer je via SSH op een server inlogt, kun je dezelfde aanpak gebruiken.

Je start een nieuwe Tmux-sessie in een verse terminal met `Super + Alt + Return`, en omdat Tmux een persistent proces is, kun je je sessie hervatten zelfs als je die terminal sluit. Druk gewoon op `Ctrl + Space` (de prefix-toets genoemd) en dan `s` om al je actieve sessies te zien.

Omarchy wordt geleverd met een ergonomisch geoptimaliseerde Tmux-configuratie, die veel keybindings heeft om te leren, dus houd [de cheatsheet bij de hand](07-hotkeys.md#tmux).

## Tmux-layoutfuncties

Omdat Tmux programmeerbaar is, kunnen we functies gebruiken om layouts te maken. Omarchy wordt geleverd met vier verschillende functies voor veelvoorkomende ontwikkelaarslayouts.

`tdl [agent]` start een drieweg-gesplitste IDE-achtige interface met de `$EDITOR` links, je gekozen AI-agent rechts (zoals `c` voor opencode of `cx` voor Claude of `codex` voor OpenAI), en dan een terminal onderaan.

Dus `tdl c` zou dit starten (of gewoon `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Je kunt ook een tweede agent starten met `tdl c cx` (opencode + claude) (of gewoon `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Er is ook `tds`, dat een vierweg-vierkant start met de editor linksboven, een live diff-watcher rechtsboven, een terminal linksonder en opencode rechtsonder.

Je kunt deze layoutconfiguratie ook starten voor elke subdirectory in de huidige map met `tdlm [agent]`, en vervolgens navigeren met `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Ten slotte kun je een zwerm agents starten met `tsl [panes] [command]`. Dus `tsl 4 c` geeft je een vierweg-raster van opencode-agents:

 ![tmux-tsl](images/tmux-tsl.webp)
