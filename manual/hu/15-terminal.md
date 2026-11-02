# Terminál

A [Foot](https://codeberg.org/dnkl/foot) az Omarchy alapértelmezett terminálja. Gyors, könnyűsúlyú, és még régi számítógépekkel is kompatibilis. Nem támogat azonban natív lapokat vagy felosztásokat.

Ha Tmuxot használsz, ez talán nem is érdekel, de ha nem, opcióként teljes mértékben támogatjuk az _Alacritty-t_, a _Ghostty-t_ és a _Kitty-t_ is. Válaszd ki a kedvencedet az Omarchy menüben az _Install > Terminal_ pont alatt.

Új terminált a `Super + Return` kombinációval indítasz. (Ez a hozzárendelés automatikusan arra a terminálra mutat, amelyet az _Install > Terminal_ pontban telepítettél, és a telepített terminálok között a _Setup > Defaults > Terminal_ pontban válthatsz.)

## Tmux

A Tmux konzisztens, programozható felületet biztosít táblákhoz, ablakokhoz (aka lapokhoz) és folytatható munkamenetekhez a terminálodtól függetlenül. Távoli gépeken is működik, így amikor SSH-val csatlakozol egy szerverhez, ugyanezt a megközelítést használhatod.

Új Tmux-munkamenetet friss terminálban a `Super + Alt + Return` kombinációval indítasz, és mivel a Tmux állandó folyamat, akkor is folytatni tudod a munkamenetedet, ha bezárod azt a terminált. Csak nyomd meg a `Ctrl + Space` kombinációt (amelyet prefix billentyűnek hívnak), majd az `s` billentyűt, hogy lásd az összes aktív munkamenetedet.

Az Omarchy ergonomikusan optimalizált Tmux-konfigurációval érkezik, amelyben sok megtanulandó billentyűhozzárendelés van, úgyhogy tartsd kéznél [a puskát](07-hotkeys.md#tmux).

## Tmux-kiosztásfüggvények

Mivel a Tmux programozható, függvényekkel kiosztásokat hozhatunk létre. Az Omarchy négy különböző függvénnyel érkezik gyakori fejlesztői kiosztásokhoz.

A `tdl [agent]` háromfelé osztott, IDE-szerű felületet indít, balra az `$EDITOR`-ral, jobbra a választott AI-agenteddel (például `c` az opencode-hoz vagy `cx` a Claude-hoz vagy `codex` az OpenAI-hoz), alul pedig egy terminállal.

Így a `tdl c` ezt indítaná (vagy csak az `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Második agentet is indíthatsz a `tdl c cx` paranccsal (opencode + claude) (vagy csak az `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Van még a `tds` is, amely négyes négyzetet indít: szerkesztő bal fent, élő diff-figyelő jobb fent, terminál bal lent és opencode jobb lent.

Ezt a kiosztási konfigurációt az aktuális mappán belüli minden almappára is elindíthatod a `tdlm [agent]` paranccsal, majd az `alt + 1/2/3/4/5/...` kombinációkkal navigálhatsz:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Végül agentek swarmját is indíthatod a `tsl [panes] [command]` paranccsal. Így a `tsl 4 c` négyes rácsot ad az opencode agentekből:

 ![tmux-tsl](images/tmux-tsl.webp)
