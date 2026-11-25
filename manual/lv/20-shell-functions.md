# Čaulas funkcijas

Omarchy nāk kopā ar čaulas funkciju kopumu, kas vienkāršo ierastus uzdevumus un iekapsulē sarežģītus parametru izsaukumus.

## Saspiešana

- `compress [file/dir]`: Izveidot tar.gz arhīvu no faila/direktorijas.
- `decompress [file.tar.gz]`: Izvērst tar.gz failu.

## Diski

- `iso2sd [image.iso]`: Izveidot sāknējamu disku SD kartē, izmantojot norādīto iso failu un interaktīvi izvēloties disku.
- `format-drive [device] [name]`: Formatēt veselu disku ar vienu exFAT nodalījumu (kas darbojas arī Windows un macOS vidē). Palaidiet bez argumentiem, lai redzētu pieejamos diskus. Esiet uzmanīgi!

## Izstrādes izkārtojumi

Tūlītēji vairāku rūšu izstrādes izkārtojumi tmux vidē:

- `tdl [ai]`: Izveidot Tmux Dev Layout ar jūsu redaktoru, mākslīgā intelekta aģentu un termināli. Izmantojiet aģentu aizstājvārdus, piemēram, `tdl c` priekš opencode vai `tdl cx` priekš Claude Code, vai nododiet otru aģentu, lai palaistu abus, piemēram, `tdl c cx`.
- `tds`: Izveidot Tmux Dev Square ar redaktoru, starpību novērošanu (ar `hunk diff --watch`), termināli un opencode.
- `tdlm [ai]`: Izveidot `tdl` logu katrai pašreizējās direktorijas apakšdirektorijai.
- `tsl [count] [command]`: Izveidot rūšu baru, kas izklāts režģī un kurās visas darbina vienu un to pašu komandu (lieliski mākslīgā intelekta aģentiem).

Tie paši izkārtojumi Herdr vidē ir pieejami kā `hdl`, `hds`, `hdlm` un `hsl`.

## Git darba kopijas (worktrees)

- `ga [branch]`: Izveidot jaunu darba kopiju un zaru blakus pašreizējai repozitorijai un pārlēkt tajā.
- `gd`: Noņemt pašreizējo darba kopiju un tās zaru (vispirms prasa apstiprinājumu).

## Rsync novērotāji

- `rsw [source] [destination]`: Palaist fona novērotāju, kas ar rsync sinhronizē avotu uz mērķi ikreiz, kad kaut kas mainās. Mērķis var būt attālināts resursdators, piemēram, `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Uzskaitīt visus aktīvos novērotājus.
- `dsw`: Apturēt visus aktīvos novērotājus.

## SSH portu pārsūtīšana

Ideāli tīmekļa izstrādei ar localhost drošā konteksta privilēģijām pret attālinātu datoru.

- `fip`: Pārsūtīt vienu vai vairākus portus no attālināta resursdatora uz localhost, izmantojot SSH.
- `dip`: Atvienot vienu vai vairākus pārsūtītos portus.
- `lip`: Uzskaitīt visus aktīvos SSH portu pārsūtījumus.

Pieņemsim, ka jūs palaižat izstrādes serveri portā `3000` datorā, kuram var piekļūt kā `nyc-dev`, tad varat palaist `fip nyc-dev 3000`, lai pārsūtītu šo portu, tā ka `localhost:3000` patiesībā sasniedz `nyc-dev:3000`, bet bez nepieciešamības pēc SSL sertifikātiem, lai izveidotu drošo kontekstu, kas vajadzīgs tīmekļa ligzdu vai tām līdzīgu lietu testēšanai.

## SSH atjaunošana

Pats `ssh` ir ietverts funkcijā, kas sakārto termināli, ja savienojums izmirst, kamēr to ir aizņēmis attālināts tmux, Herdr vai redaktors, un pēc tam automātiski atjauno savienojumu, kad interaktīva sesija pārtrūkst (Ctrl-C aptur mēģinājumu ciklu).
