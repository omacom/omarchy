# Terminalas

[Foot](https://codeberg.org/dnkl/foot) yra numatytasis Omarchy terminalas. Jis greitas, lengvas ir suderinamas net su senais kompiuteriais. Tačiau jis nepalaiko natūralių skirtukų ar padalijimų.

Jei naudojate Tmux, jums gal ir nesvarbu, bet jei ne, mes taip pat visiškai palaikome _Alacritty_, _Ghostty_ ir _Kitty_ kaip parinktis. Savo pageidavimą rinkitės po _Įdiegti > Terminalas_ Omarchy meniu.

Naują terminalą paleidžiate naudodami `Super + Return`. (Šis susiejimas automatiškai rodys į bet kurį Terminalą, kurį įdiegėte per _Įdiegti > Terminalas_, o tarp įdiegtų terminalų galite persijungti po _Nuostatos > Numatytosios > Terminalas_.)

## Tmux

Tmux suteikia nuoseklią, programuojamą sąsają sritims, langams (dar vadinamiems skirtukais) ir atnaujinamoms sesijoms, nepriklausomai nuo jūsų terminalo. Jis net veikia nuotoliniuose kompiuteriuose, todėl, kai per SSH jungiatės prie serverio, galite naudoti tą patį metodą.

Naują Tmux sesiją naujame terminale paleidžiate naudodami `Super + Alt + Return`, ir kadangi Tmux yra nuolatinis procesas, galite atnaujinti savo sesiją, net jei tą terminalą uždarote. Tiesiog paspauskite `Ctrl + Space` (vadinamą prefikso klavišu), tada `s`, kad pamatytumėte visas savo aktyvias sesijas.

Omarchy pateikiama su ergonomiškai optimizuota Tmux konfigūracija, kurioje yra daug klavišų susiejimų, kuriuos reikia išmokti, todėl laikykite [apgaulingą lapą po ranka](07-hotkeys.md#tmux).

## Tmux išdėstymo funkcijos

Kadangi Tmux galima programuoti, galime naudoti funkcijas išdėstymams kurti. Omarchy pateikiama su keturiomis skirtingomis funkcijomis bendriems kūrėjų išdėstymams.

`tdl [agent]` paleidžia trijų dalių, į IDE panašią sąsają su `$EDITOR` kairėje, jūsų pasirinktu AI agentu dešinėje (pavyzdžiui, `c` opencode arba `cx` Claude arba `codex` OpenAI), o tada terminalu apačioje.

Taigi `tdl c` paleistų tai (arba tiesiog `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Taip pat galite paleisti antrą agentą su `tdl c cx` (opencode + claude) (arba tiesiog `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Taip pat yra `tds`, kuris paleidžia keturių dalių kvadratą su redaguokliu viršuje kairėje, gyvu diff stebėtoju viršuje dešinėje, terminalu apačioje kairėje ir opencode apačioje dešinėje.

Taip pat galite paleisti šią išdėstymo konfigūraciją kiekvienam pakatalogiui dabartiniame kataloge naudodami `tdlm [agent]`, tada naršyti naudodami `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Galiausiai galite paleisti agentų spiečių naudodami `tsl [panes] [command]`. Taigi `tsl 4 c` jums duos keturių dalių opencode agentų tinklelį:

 ![tmux-tsl](images/tmux-tsl.webp)
