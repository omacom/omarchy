# Funkcije lupine

Omarchy prinaša nabor funkcij lupine za poenostavitev pogostih opravil in enkapsulacijo zapletenih klicev s parametri.

## Stiskanje

- `compress [file/dir]`: Ustvari arhiv tar.gz iz datoteke/mape.
- `decompress [file.tar.gz]`: Razširi datoteko tar.gz.

## Pogoni

- `iso2sd [image.iso]`: Ustvari zagonski pogon na kartici SD z navedeno iso datoteko in interaktivno izbiro pogona.
- `format-drive [device] [name]`: Formatira celoten disk z eno samo particijo exFAT (ki deluje tudi v Windows in macOS). Zaženite brez argumentov, da vidite razpoložljive pogone. Previdno!

## Razvojne postavitve

Takojšnje večokenske razvojne postavitve za tmux:

- `tdl [ai]`: Ustvari postavitev Tmux Dev Layout z vašim urejevalnikom, agentom AI in terminalom. Uporabite vzdevke agentov, kot je `tdl c` za opencode ali `tdl cx` za Claude Code, ali podajte drugega agenta, da zaženete oba, na primer `tdl c cx`.
- `tds`: Ustvari kvadrat Tmux Dev Square z urejevalnikom, spremljanjem diffov (prek `hunk diff --watch`), terminalom in opencode.
- `tdlm [ai]`: Ustvari okno `tdl` za vsako podmapo v trenutni mapi.
- `tsl [count] [command]`: Ustvari roj oken, razporejenih v mrežo, vsa izvajajo isti ukaz (odlično za agente AI).

Iste postavitve so na voljo za Herdr kot `hdl`, `hds`, `hdlm` in `hsl`.

## Delovna drevesa Git

- `ga [branch]`: Ustvari novo delovno drevo in vejo poleg trenutnega repozitorija in skoči vanj.
- `gd`: Odstrani trenutno delovno drevo in njegovo vejo (najprej prosi za potrditev).

## Opazovalci Rsync

- `rsw [source] [destination]`: Zažene opazovalca v ozadju, ki sinhronizira vir na cilj z rsync, kadar koli se kaj spremeni. Cilj je lahko oddaljeni gostitelj, na primer `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Našteje vse aktivne opazovalce.
- `dsw`: Ustavi vse aktivne opazovalce.

## Posredovanje vrat SSH

Idealno za spletni razvoj s privilegiji varnega konteksta localhost proti oddaljenemu računalniku.

- `fip`: Posreduje ena ali več vrat z oddaljenega gostitelja na localhost prek SSH.
- `dip`: Odklopi ena ali več posredovanih vrat.
- `lip`: Našteje vsa aktivna posredovanja vrat SSH.

Recimo, da zaženete razvojni strežnik na vratih `3000` na računalniku, dostopnem kot `nyc-dev`, nato lahko zaženete `fip nyc-dev 3000` za posredovanje teh vrat, tako da `localhost:3000` dejansko doseže `nyc-dev:3000`, vendar brez potrebe po potrdilih SSL za vzpostavitev varnega konteksta, potrebnega za preskušanje spletnih vtičnic ali podobnega.

## Ponovna povezava SSH

`ssh` sam je zavit v funkcijo, ki počisti terminal, če povezava umre, medtem ko ga je prevzel oddaljeni tmux, Herdr ali urejevalnik, in nato samodejno znova vzpostavi povezavo, ko interaktivna seja pade (Ctrl-C ustavi zanko ponavljanja).
