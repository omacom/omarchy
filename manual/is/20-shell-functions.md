# Shell-föll

Omarchy kemur með safni af shell-föllum til að einfalda algeng verkefni og fela flókin færibreytuköll.

## Þjöppun

- `compress [file/dir]`: Búa til tar.gz-safn úr skránni/möppunni.
- `decompress [file.tar.gz]`: Þenja út tar.gz-skrá.

## Drif

- `iso2sd [image.iso]`: Búa til ræsanlegt drif á SD-korti með vísaðri iso-skrá og velja drifið gagnvirkt.
- `format-drive [device] [name]`: Forsníða heilan disk með einni exFAT-sneið (sem virkar líka á Windows og macOS). Keyrðu það án viðfanga til að sjá tiltæk drif. Vertu varkár!

## Þróunaruppsetningar

Skyndi-fjölrúðu þróunaruppsetningar fyrir tmux:

- `tdl [ai]`: Búa til Tmux Dev Layout með ritlinum þínum, AI-agent og terminal. Notaðu agent-aliasana, eins og `tdl c` fyrir opencode eða `tdl cx` fyrir Claude Code, eða sendu annan agent til að keyra báða, eins og `tdl c cx`.
- `tds`: Búa til Tmux Dev Square með ritli, diff-vöktun (í gegnum `hunk diff --watch`), terminal og opencode.
- `tdlm [ai]`: Búa til `tdl`-glugga fyrir hverja undirmöppu í núverandi möppu.
- `tsl [count] [command]`: Búa til hóp af rúðum flísalagðar í rist, allar að keyra sömu skipun (frábært fyrir AI-agenta).

Sömu uppsetningar eru fáanlegar fyrir Herdr sem `hdl`, `hds`, `hdlm` og `hsl`.

## Git-vinnutré

- `ga [branch]`: Búa til nýtt vinnutré og grein við hlið núverandi repositoríu og stökkva inn í það.
- `gd`: Fjarlægja núverandi vinnutré og grein þess (biður fyrst um staðfestingu).

## Rsync-vaktarar

- `rsw [source] [destination]`: Ræsa bakgrunnsvaktara sem rsync-ar uppruna á áfangastað í hvert skipti sem eitthvað breytist. Áfangastaðurinn getur verið fjarlægur hýsill, eins og `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Lista alla virka vaktara.
- `dsw`: Stöðva alla virka vaktara.

## SSH-portframsending

Tilvalið til að stunda vefþróun með localhost secure-context réttindum gegn fjarlægri vél.

- `fip`: Framsenda eitt eða fleiri port frá fjarlægum hýsli til localhost í gegnum SSH.
- `dip`: Aftengja eitt eða fleiri framsend port.
- `lip`: Lista allar virkar SSH-portframsendingar.

Segjum að þú ræsir þróunarþjón á porti `3000` á vél sem er aðgengileg sem `nyc-dev`, þá geturðu keyrt `fip nyc-dev 3000` til að framsenda það port, þannig að `localhost:3000` nær raunverulega til `nyc-dev:3000`, en án þess að þurfa SSL-skilríki til að koma á öruggu samhengi sem þarf til að prófa vefsoketa eða þess háttar.

## SSH-endurtenging

`ssh` sjálft er vafið í fall sem hreinsar upp í terminalinu ef tenging deyr á meðan fjarlægur tmux, Herdr eða ritill hefur lagt hald á það, og tengist síðan sjálfkrafa aftur þegar gagnvirk lota fellur niður (Ctrl-C stöðvar endurtilraunalykkjuna).
