# Kesta funktsioonid

Omarchy tuleb komplekti kestafunktsioonidega, et lihtsustada tavalisi ülesandeid ja kapseldada keerukaid parameetrikõnesid.

## Pakkimine

- `compress [file/dir]`: loo failist/kaustast tar.gz arhiiv.
- `decompress [file.tar.gz]`: paki tar.gz fail lahti.

## Draivid

- `iso2sd [image.iso]`: loo SD-kaardile buuditav draiv, kasutades viidatud iso-faili ja valides draivi interaktiivselt.
- `format-drive [device] [name]`: vorminda kogu ketas ühe exFAT partitsiooniga (mis töötab ka Windowsis ja macOS-is). Käivita ilma argumentideta, et näha saadaolevaid draive. Ole ettevaatlik!

## Arenduspaigutused

Kohe saadavad mitme paaniga arenduspaigutused tmuxile:

- `tdl [ai]`: loo Tmux Dev Layout koos redaktori, AI agendi ja terminaliga. Kasuta agendi aliaseid, näiteks `tdl c` opencode'i jaoks või `tdl cx` Claude Code'i jaoks, või anna teine agent, et käitada mõlemaid, näiteks `tdl c cx`.
- `tds`: loo Tmux Dev Square koos redaktori, diffi jälgimise (käsu `hunk diff --watch` kaudu), terminali ja opencode'iga.
- `tdlm [ai]`: loo `tdl` aken iga praeguse kausta alamkausta jaoks.
- `tsl [count] [command]`: loo ruudustikku plaaditud paanide parv, mis kõik käitavad sama käsku (suurepärane AI agentide jaoks).

Samad paigutused on Herdr'ile saadaval kui `hdl`, `hds`, `hdlm` ja `hsl`.

## Giti worktree'd

- `ga [branch]`: loo praeguse repo kõrvale uus worktree ja haru ning hüppa sinna sisse.
- `gd`: eemalda praegune worktree ja selle haru (küsib enne kinnitust).

## Rsync jälgijad

- `rsw [source] [destination]`: käivita taustal jälgija, mis rsyncib allika sihtkohta iga kord, kui midagi muutub. Sihtkoht võib olla kaughost, näiteks `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: loetle kõik aktiivsed jälgijad.
- `dsw`: peata kõik aktiivsed jälgijad.

## SSH pordisuunamine

Ideaalne veebiarenduseks localhosti turvalise konteksti privileegidega kaugmasina vastu.

- `fip`: suuna üks või mitu porti kaughostist localhosti SSH kaudu.
- `dip`: ühenda lahti üks või mitu suunatud porti.
- `lip`: loetle kõik aktiivsed SSH pordisuunamised.

Ütleme, et käivitad arendusserveri pordil `3000` masinal, millele pääseb ligi nimega `nyc-dev`, siis saad käivitada `fip nyc-dev 3000`, et see port suunata, nii et `localhost:3000` jõuab tegelikult aadressile `nyc-dev:3000`, kuid ilma SSL-sertifikaatide vajaduseta, et luua turvaline kontekst, mida on vaja näiteks veebisoklite testimiseks.

## SSH taastühendus

`ssh` ise on mähitud funktsiooni, mis koristab terminali, kui ühendus sureb ajal, mil kauge tmux, Herdr või redaktor on selle hõivanud, ja ühendab seejärel automaatselt uuesti, kui interaktiivne seanss katkeb (Ctrl-C peatab uuesti proovimise ahela).
