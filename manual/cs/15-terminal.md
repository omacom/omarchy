# Terminál

Výchozím terminálem pro Omarchy je [Foot](https://codeberg.org/dnkl/foot). Je rychlý, lehký a kompatibilní i se starými počítači. Nepodporuje však nativní záložky ani rozdělení.

Pokud používáte Tmux, nemusí vám to vadit, ale pokud ne, plně podporujeme také _Alacritty_, _Ghostty_ a _Kitty_ jako možnosti. Svou preferenci si vyberte v _Instalovat > Terminál_ v nabídce Omarchy.

Nový terminál spustíte pomocí `Super + Return`. (Tato zkratka bude automaticky ukazovat na jakýkoli Terminál, který jste nainstalovali přes _Instalovat > Terminál_, a mezi nainstalovanými terminály můžete přepínat v _Nastavení > Výchozí > Terminál_.)

## Tmux

Tmux poskytuje konzistentní, programovatelné rozhraní pro panely, okna (alias záložky) a obnovitelné relace bez ohledu na váš terminál. Funguje dokonce i na vzdálených hostitelích, takže když se připojujete přes SSH na server, můžete použít stejný přístup.

Novou relaci Tmux v čerstvém terminálu spustíte pomocí `Super + Alt + Return`, a protože Tmux je trvalý proces, můžete svou relaci obnovit, i když tento terminál zavřete. Stačí stisknout `Ctrl + Space` (říká se tomu prefixová klávesa) a poté `s` a uvidíte všechny své aktivní relace.

Omarchy se dodává s ergonomicky optimalizovanou konfigurací Tmuxu, která má mnoho klávesových zkratek k naučení, takže mějte [tahák po ruce](07-hotkeys.md#tmux).

## Funkce rozložení Tmuxu

Protože je Tmux programovatelný, můžeme k vytváření rozložení používat funkce. Omarchy se dodává se čtyřmi různými funkcemi pro běžná vývojářská rozložení.

`tdl [agent]` spustí trojcestné rozdělené rozhraní podobné IDE s `$EDITOR` nalevo, vámi vybraným AI agentem napravo (například `c` pro opencode nebo `cx` pro Claude nebo `codex` pro OpenAI) a terminálem dole.

Takže `tdl c` by spustilo toto (nebo prostě `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Můžete také spustit druhého agenta pomocí `tdl c cx` (opencode + claude) (nebo prostě `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Existuje také `tds`, který spustí čtyřcestný čtverec s editorem vlevo nahoře, živým sledovačem diffů vpravo nahoře, terminálem vlevo dole a opencode vpravo dole.

Tuto konfiguraci rozložení můžete spustit také pro každý podadresář v aktuálním adresáři pomocí `tdlm [agent]` a poté se pohybovat pomocí `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Nakonec můžete spustit roj agentů pomocí `tsl [panes] [command]`. Takže `tsl 4 c` vám dá čtyřcestnou mřížku agentů opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
