# Skallfunksjoner

Omarchy kommer med et sett skallfunksjoner for å forenkle vanlige oppgaver og kapsle inn innviklede parameterkall.

## Komprimering

- `compress [file/dir]`: Opprett et tar.gz-arkiv fra filen/mappen.
- `decompress [file.tar.gz]`: Pakk ut en tar.gz-fil.

## Disker

- `iso2sd [image.iso]`: Opprett en oppstartbar disk på et SD-kort med den refererte iso-filen, og velg disken interaktivt.
- `format-drive [device] [name]`: Formater en hel disk med én enkelt exFAT-partisjon (som også fungerer på Windows og macOS). Kjør den uten argumenter for å se de tilgjengelige diskene. Vær forsiktig!

## Utviklingsoppsett

Umiddelbare flerrute utviklingsoppsett for tmux:

- `tdl [ai]`: Opprett et Tmux Dev Layout med editoren din, en KI-agent og en terminal. Bruk agentaliasene, som `tdl c` for opencode eller `tdl cx` for Claude Code, eller gi en andre agent for å kjøre begge, som `tdl c cx`.
- `tds`: Opprett et Tmux Dev Square med editor, diff-overvåking (via `hunk diff --watch`), terminal og opencode.
- `tdlm [ai]`: Opprett et `tdl`-vindu for hver undermappe i gjeldende mappe.
- `tsl [count] [command]`: Opprett en sverm av ruter flislagt i et rutenett, som alle kjører samme kommando (flott for KI-agenter).

De samme oppsettene er tilgjengelige for Herdr som `hdl`, `hds`, `hdlm` og `hsl`.

## Git-arbeidstrær

- `ga [branch]`: Opprett et nytt arbeidstre og en ny gren ved siden av gjeldende repo og hopp inn i det.
- `gd`: Fjern gjeldende arbeidstre og grenen dets (ber om bekreftelse først).

## Rsync-overvåkere

- `rsw [source] [destination]`: Start en bakgrunnsovervåker som synkroniserer kilde til destinasjon med rsync når noe endrer seg. Destinasjonen kan være en ekstern vert, som `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: List opp alle aktive overvåkere.
- `dsw`: Stopp alle aktive overvåkere.

## SSH-portvideresending

Ideelt for webutvikling med localhost secure-context-rettigheter mot en ekstern boks.

- `fip`: Videresend én eller flere porter fra en ekstern vert til localhost via SSH.
- `dip`: Koble fra én eller flere videresendte porter.
- `lip`: List opp alle aktive SSH-portvideresendinger.

Si du starter en dev-server på port `3000` på en maskin tilgjengelig som `nyc-dev`, da kan du kjøre `fip nyc-dev 3000` for å videresende porten, slik at `localhost:3000` faktisk når `nyc-dev:3000`, men uten behov for SSL-sertifikater for å etablere den sikre konteksten som trengs for å teste websokler eller lignende.

## SSH-gjenoppkopling

Selve `ssh` er pakket inn i en funksjon som rydder opp i terminalen hvis en forbindelse dør mens en ekstern tmux, Herdr eller editor har krevd den, og deretter kopler til på nytt automatisk når en interaktiv økt faller ut (Ctrl-C stopper forsøksløkken).
