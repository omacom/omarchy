# Terminal

[Foot](https://codeberg.org/dnkl/foot) er sjálfgefinn terminal fyrir Omarchy. Hann er hraður, léttur og samhæfur jafnvel gömlum tölvum. Hann styður hins vegar ekki innfædda flipa eða skiptingar.

Ef þú notar Tmux skiptir það þig kannski ekki máli, en ef ekki styðjum við fullkomlega _Alacritty_, _Ghostty_ og _Kitty_ sem valkosti líka. Veldu þitt val undir _Setja upp > Terminal_ í Omarchy-valmyndinni.

Þú ræsir nýjan terminal með `Super + Return`. (Þessi tenging bendir sjálfkrafa á hvaða terminal sem þú hefur sett upp með _Setja upp > Terminal_, og þú getur skipt á milli uppsettra terminala undir _Uppsetning > Sjálfgildi > Terminal_.)

## Tmux

Tmux veitir samræmt, forritanlegt viðmót fyrir rúður, glugga (þ.e. flipa) og endurupptakanlegar lotur óháð terminalnum þínum. Það virkar jafnvel á fjarvélum, svo þegar þú ert að SSH-a inn á netþjón geturðu notað sömu nálgun.

Þú byrjar nýja Tmux-lotu í ferskum terminal með `Super + Alt + Return`, og þar sem Tmux er viðvarandi ferli geturðu haldið áfram lotunni þinni jafnvel þó þú lokir þeim terminal. Ýttu bara á `Ctrl + Space` (kallaður forskeytislykillinn) og síðan `s` til að sjá allar virkar loturnar þínar.

Omarchy kemur með vinnuvistfræðilega hagrædda Tmux-stillingu, sem hefur margar lyklatengingar að læra, svo hafðu [svindlblaðið við höndina](07-hotkeys.md#tmux).

## Tmux-skipulagsföll

Þar sem Tmux er forritanlegt getum við notað föll til að búa til skipulag. Omarchy kemur með fjögur mismunandi föll fyrir algeng þróunarskipulag.

`tdl [agent]` byrjar þrískipt IDE-líkt viðmót með `$EDITOR` vinstra megin, valnum gervigreindar-agent þínum hægra megin (eins og `c` fyrir opencode eða `cx` fyrir Claude eða `codex` fyrir OpenAI), og síðan terminal neðst.

Svo `tdl c` myndi byrja þetta (eða bara `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Þú getur líka byrjað annan agent með `tdl c cx` (opencode + claude) (eða bara `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Það er líka `tds`, sem byrjar fjórskiptan ferning með ritilinn efst til vinstri, lifandi mismunaskoðara efst til hægri, terminal neðst til vinstri og opencode neðst til hægri.

Þú getur líka byrjað þessa skipulagsstillingu fyrir hverja undirmöppu í núverandi möppu með `tdlm [agent]` og flett síðan með `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Loks geturðu byrjað sveim af agents með `tsl [panes] [command]`. Svo `tsl 4 c` gefur þér fjórskipt net af opencode-agents:

 ![tmux-tsl](images/tmux-tsl.webp)
