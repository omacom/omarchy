# Terminali

[Foot](https://codeberg.org/dnkl/foot) ndiyo terminali chaguomsingi ya Omarchy. Ni ya haraka, nyepesi, na inaendana hata na kompyuta za zamani. Hata hivyo, haiunga mkono vichupo wala mgawanyiko wa asili.

Ikiwa unatumia Tmux, huenda usiijali, lakini ikiwa la, tunaunga mkono kikamilifu _Alacritty_, _Ghostty_, na _Kitty_ kama chaguo pia. Chagua unachopendelea chini ya _Sakinisha > Terminali_ katika menyu ya Omarchy.

Unaanzisha terminali mpya ukitumia `Super + Return`. (Ufungaji huu utaelekea kiotomatiki kwenye Terminali yoyote uliyosakinisha kupitia _Sakinisha > Terminali_, na unaweza kubadili kati ya terminali zilizosakinishwa chini ya _Sanidi > Chaguomsingi > Terminali_.)

## Tmux

Tmux hutoa kiolesura thabiti, chenye kupangwa kwa paneli, madirisha (aka vichupo), na vipindi vinavyoweza kuendelea bila kujali terminali yako. Hata hufanya kazi kwenye wapangishaji wa mbali, kwa hiyo unapoingia kwenye seva kwa SSH, unaweza kutumia njia hiyo hiyo.

Unaanzisha kipindi kipya cha Tmux katika terminali mpya ukitumia `Super + Alt + Return`, na kwa sababu Tmux ni mchakato unaoendelea, unaweza kuendelea na kipindi chako hata ukifunga terminali hiyo. Bonyeza tu `Ctrl + Space` (inaitwa kitufe cha kiambishi awali) kisha `s` kuona vipindi vyako vyote vinavyotumika.

Omarchy hutumwa na usanidi wa Tmux ulioboreshwa kwa ergonomiki, ambao una mikato mingi ya vitufe ya kujifunza, kwa hiyo weka [karatasi ya dokezo karibu](07-hotkeys.md#tmux).

## Vitendaji vya mpangilio wa Tmux

Kwa sababu Tmux inaweza kupangwa, tunaweza kutumia vitendaji kuunda mipangilio. Omarchy hutumwa na vitendaji vinne tofauti kwa mipangilio ya kawaida ya msanidii.

`tdl [agent]` huanzisha kiolesura cha mgawanyiko wa njia tatu kama IDE na `$EDITOR` upande wa kushoto, ajenti wako wa AI uliyechagua upande wa kulia (kama `c` kwa opencode au `cx` kwa Claude au `codex` kwa OpenAI), na kisha terminali chini.

Kwa hiyo `tdl c` ingeanzisha hii (au tu `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Unaweza pia kuanzisha ajenti wa pili kwa `tdl c cx` (opencode + claude) (au tu `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Kuna pia `tds`, ambayo huanzisha mraba wa njia nne na kihariri juu kushoto, kiangaliaji cha tofauti cha moja kwa moja juu kulia, terminali chini kushoto, na opencode chini kulia.

Unaweza pia kuanzisha usanidi huu wa mpangilio kwa kila saraka ndogo katika saraka ya sasa ukitumia `tdlm [agent]`, kisha kusogeza ukitumia `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Mwishowe, unaweza kuanzisha kundi la maajenti ukitumia `tsl [panes] [command]`. Kwa hiyo `tsl 4 c` itakupa gridi ya njia nne ya maajenti wa opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
