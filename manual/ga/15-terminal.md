# Teirminéal

Is é [Foot](https://codeberg.org/dnkl/foot) an teirminéal réamhshocraithe do Omarchy. Tá sé tapa, éadrom, agus comhoiriúnach le ríomhairí sean fiú. Ní thacaíonn sé, áfach, le cluaisíní ná scoilteanna dúchasacha.

Má úsáideann tú Tmux, b'fhéidir nach cuma leat, ach mura n-úsáideann, tacaímid go hiomlán le _Alacritty_, _Ghostty_, agus _Kitty_ mar roghanna freisin. Roghnaigh do rogha faoi _Suiteáil > Teirminéal_ i roghchlár Omarchy.

Tosaíonn tú teirminéal nua le `Super + Return`. (Léireoidh an ceangal seo go huathoibríoch chuig cibé Teirminéal atá suiteáilte agat trí _Suiteáil > Teirminéal_, agus is féidir leat athrú idir teirminéil suiteáilte faoi _Socrú > Réamhshocruithe > Teirminéal_.)

## Tmux

Soláthraíonn Tmux comhéadan comhsheasmhach, in-ríomhchláraithe do phánaí, d'fhuinneoga (aka cluaisíní), agus do sheisiúin in-atosaithe beag beann ar do theirminéal. Oibríonn sé ar óstaigh chianda fiú, mar sin nuair atá tú ag SSHáil isteach i bhfreastalaí, is féidir leat an cur chuige céanna a úsáid.

Tosaíonn tú seisiún Tmux nua i teirminéal úr le `Super + Alt + Return`, agus toisc gur próiseas leanúnach é Tmux, is féidir leat do sheisiún a atosú fiú má dhúnann tú an teirminéal sin. Ní gá duit ach `Ctrl + Space` a bhualadh (ar a dtugtar an eochair réimíre) ansin `s` chun do sheisiúin ghníomhacha uile a fheiceáil.

Tagann cumraíocht Tmux eirgeanamaíochta-optamaithe le Omarchy, a bhfuil go leor ceangail eochracha le foghlaim aici, mar sin coinnigh [an bhileog caimiléireachta ar láimh](07-hotkeys.md#tmux).

## Feidhmeanna leagan amach Tmux

Toisc go bhfuil Tmux in-ríomhchláraithe, is féidir linn feidhmeanna a úsáid chun leaganacha amach a chruthú. Tagann ceithre fheidhm dhifriúla le Omarchy do leaganacha amach forbróra coitianta.

Tosaíonn `tdl [agent]` comhéadan cosúil le IDE trí-bhealach scoilte leis an `$EDITOR` ar chlé, do ghníomhaire AI roghnaithe ar dheis (cosúil le `c` do opencode nó `cx` do Claude nó `codex` do OpenAI), agus ansin teirminéal ag an mbun.

Mar sin thosódh `tdl c` é seo (nó díreach `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Is féidir leat an dara gníomhaire a thosú freisin le `tdl c cx` (opencode + claude) (nó díreach `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Tá `tds` ann freisin, a thosaíonn cearnóg ceithre-bhealach leis an eagarthóir ag barr ar chlé, faireoir diff beo ag barr ar dheis, teirminéal ag bun ar chlé, agus opencode ag bun ar dheis.

Is féidir leat an chumraíocht leagan amach seo a thosú freisin do gach focheannlann san eolaire reatha le `tdlm [agent]`, ansin nascleanúint le `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Ar deireadh, is féidir leat saith gníomhairí a thosú le `tsl [panes] [command]`. Mar sin tabharfaidh `tsl 4 c` greille ceithre-bhealach de ghníomhairí opencode duit:

 ![tmux-tsl](images/tmux-tsl.webp)
