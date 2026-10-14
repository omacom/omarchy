# Terminál

[Foot](https://codeberg.org/dnkl/foot) je predvolený terminál Omarchy. Je rýchly, ľahký a kompatibilný aj so starými počítačmi. Nepodporuje však natívne karty ani rozdelenia.

Ak používate Tmux, možno vám to nebude vadiť, ale ak nie, plne podporujeme aj _Alacritty_, _Ghostty_ a _Kitty_ ako možnosti. Vyberte si svoju preferenciu pod _Inštalovať > Terminál_ v menu Omarchy.

Nový terminál spustíte pomocou `Super + Return`. (Táto väzba bude automaticky ukazovať na ktorýkoľvek terminál, ktorý ste nainštalovali cez _Inštalovať > Terminál_, a medzi nainštalovanými terminálmi môžete prepínať pod _Nastavenie > Predvolené > Terminál_.)

## Tmux

Tmux poskytuje konzistentné, programovateľné rozhranie pre panely, okná (alias karty) a obnoviteľné relácie bez ohľadu na váš terminál. Funguje to aj na vzdialených hostiteľoch, takže pri SSH pripojení k serveru môžete použiť rovnaký prístup.

Novú reláciu Tmux v čerstvom termináli spustíte pomocou `Super + Alt + Return` a keďže Tmux je trvalý proces, môžete reláciu obnoviť, aj keď tento terminál zatvoríte. Stačí stlačiť `Ctrl + Space` (nazýva sa prefixový kláves) a potom `s`, aby ste videli všetky svoje aktívne relácie.

Omarchy sa dodáva s ergonomicky optimalizovanou konfiguráciou Tmux, ktorá má veľa klávesových väzieb na naučenie, takže majte [ťahák po ruke](07-hotkeys.md#tmux).

## Funkcie rozloženia Tmux

Keďže Tmux je programovateľný, môžeme použiť funkcie na vytváranie rozložení. Omarchy sa dodáva so štyrmi rôznymi funkciami pre bežné vývojárske rozloženia.

`tdl [agent]` spustí trojcestné rozdelené rozhranie podobné IDE s `$EDITOR` vľavo, vami zvoleným AI agentom vpravo (napríklad `c` pre opencode alebo `cx` pre Claude alebo `codex` pre OpenAI) a potom terminálom dole.

Takže `tdl c` by spustilo toto (alebo len `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Môžete tiež spustiť druhého agenta pomocou `tdl c cx` (opencode + claude) (alebo len `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Existuje aj `tds`, ktoré spustí štvorcový štvorec s editorom vľavo hore, živým sledovačom rozdielov vpravo hore, terminálom vľavo dole a opencode vpravo dole.

Túto konfiguráciu rozloženia môžete tiež spustiť pre každý podadresár v aktuálnom adresári pomocou `tdlm [agent]` a potom navigovať pomocou `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Nakoniec môžete spustiť roj agentov pomocou `tsl [panes] [command]`. Takže `tsl 4 c` vám dá štvorcestnú mriežku agentov opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
