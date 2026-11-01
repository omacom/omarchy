# Shell-funkciók

Az Omarchy egy sor shell-funkcióval érkezik, amelyek leegyszerűsítik a gyakori feladatokat, és elrejtik a bonyolult paraméterhívásokat.

## Tömörítés

- `compress [file/dir]`: tar.gz archívumot hoz létre a fájlból/könyvtárból.
- `decompress [file.tar.gz]`: kicsomagol egy tar.gz fájlt.

## Meghajtók

- `iso2sd [image.iso]`: rendszerindításra alkalmas meghajtót hoz létre egy SD-kártyán a hivatkozott iso fájllal, interaktív meghajtóválasztással.
- `format-drive [device] [name]`: egy teljes lemezt formáz egyetlen exFAT-partícióval (amely Windowson és macOS-en is működik). Futtasd argumentumok nélkül az elérhető meghajtók megtekintéséhez. Légy óvatos!

## Dev layoutok

Azonnali, többpanelos fejlesztőkörnyezetek tmuxhoz:

- `tdl [ai]`: létrehoz egy Tmux Dev Layoutot a szerkesztőddel, egy AI-agenttel és egy terminállal. Használd az agentaliásokat, például `tdl c` az opencode-hoz vagy `tdl cx` a Claude Code-hoz, vagy adj meg egy második agentet mindkettő futtatásához, például `tdl c cx`.
- `tds`: létrehoz egy Tmux Dev Square-t szerkesztővel, diffkövetéssel (a `hunk diff --watch` segítségével), terminállal és opencode-dal.
- `tdlm [ai]`: létrehoz egy `tdl` ablakot az aktuális könyvtár minden alkönyvtárához.
- `tsl [count] [command]`: létrehoz egy rácsba rendezett panelrajot, amelyek mind ugyanazt a parancsot futtatják (remek AI-agentekhez).

Ugyanezek a layoutok Herdrhez `hdl`, `hds`, `hdlm` és `hsl` néven érhetők el.

## Git worktree-k

- `ga [branch]`: új worktree-t és branchet hoz létre az aktuális tároló mellett, és belép.
- `gd`: eltávolítja az aktuális worktree-t és a branchét (előtte megerősítést kér).

## Rsync-figyelők

- `rsw [source] [destination]`: háttérfigyelőt indít, amely a forrást a célhelyre rsynceli, amikor bármi megváltozik. A célhely lehet távoli gép is, például `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: kilistáz minden aktív figyelőt.
- `dsw`: leállít minden aktív figyelőt.

## SSH-porttovábbítás

Ideális webfejlesztéshez localhost secure-context jogokkal egy távoli gép ellen.

- `fip`: egy vagy több portot továbbít egy távoli gépről a localhostra SSH-n keresztül.
- `dip`: leválaszt egy vagy több továbbított portot.
- `lip`: kilistáz minden aktív SSH-porttovábbítást.

Tegyük fel, hogy egy `nyc-dev` néven elérhető gépen indítasz egy fejlesztőszervert a `3000` porton, akkor futtathatod az `fip nyc-dev 3000` parancsot a port továbbításához, így a `localhost:3000` ténylegesen eléri a `nyc-dev:3000` címet, de SSL-tanúsítványok nélkül, amelyek a webszoketek és hasonlók teszteléséhez szükséges secure context létrehozásához kellenének.

## SSH-újracsatlakozás

Maga az `ssh` egy olyan függvénybe van csomagolva, amely kitakarítja a terminált, ha egy kapcsolat megszakad, miközben egy távoli tmux, Herdr vagy szerkesztő lefoglalta azt, majd automatikusan újracsatlakozik, amikor egy interaktív munkamenet megszakad (a Ctrl-C állítja le az újrapróbálkozási hurkot).
