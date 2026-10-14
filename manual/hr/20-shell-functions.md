# Funkcije ljuske

Omarchy dolazi sa skupom funkcija ljuske za pojednostavljenje uobičajenih zadataka i enkapsulaciju zamršenih poziva s parametrima.

## Kompresija

- `compress [file/dir]`: Stvori tar.gz arhivu iz datoteke/direktorija.
- `decompress [file.tar.gz]`: Raspakiraj tar.gz datoteku.

## Pogoni

- `iso2sd [image.iso]`: Stvori pogon za pokretanje na SD kartici koristeći referenciranu iso datoteku i interaktivnim odabirom pogona.
- `format-drive [device] [name]`: Formatiraj cijeli disk s jednom exFAT particijom (koja radi i na Windowsu i macOS-u). Pokreni bez argumenata da vidiš dostupne pogone. Budi pažljiv!

## Razvojni rasporedi

Trenutačni višestruki razvojni rasporedi za tmux:

- `tdl [ai]`: Stvori Tmux Dev Layout s tvojim uređivačem, AI agentom i terminalom. Koristi aliase agenata, poput `tdl c` za opencode ili `tdl cx` za Claude Code, ili proslijedi drugog agenta za pokretanje obaju, poput `tdl c cx`.
- `tds`: Stvori Tmux Dev Square s uređivačem, praćenjem diff-a (putem `hunk diff --watch`), terminalom i opencodeom.
- `tdlm [ai]`: Stvori `tdl` prozor za svaki poddirektorij u trenutnom direktoriju.
- `tsl [count] [command]`: Stvori roj okana popločanih u rešetku, svi pokreću istu naredbu (odlično za AI agente).

Isti rasporedi dostupni su za Herdr kao `hdl`, `hds`, `hdlm` i `hsl`.

## Git worktreeji

- `ga [branch]`: Stvori novi worktree i granu pokraj trenutnog repozitorija i skoči u njega.
- `gd`: Ukloni trenutni worktree i njegovu granu (prvo traži potvrdu).

## Rsync nadzornici

- `rsw [source] [destination]`: Pokreni pozadinskog nadzornika koji rsynca iz izvora na odredište kad god se nešto promijeni. Odredište može biti udaljeni host, poput `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Ispiši sve aktivne nadzornike.
- `dsw`: Zaustavi sve aktivne nadzornike.

## SSH prosljeđivanje portova

Idealno za web razvoj s privilegijama localhost secure-context prema udaljenom računalu.

- `fip`: Proslijedi jedan ili više portova s udaljenog hosta na localhost putem SSH-a.
- `dip`: Odspoji jedan ili više proslijeđenih portova.
- `lip`: Ispiši sva aktivna SSH prosljeđivanja portova.

Recimo da pokreneš dev poslužitelj na portu `3000` na računalu dostupnom kao `nyc-dev`, zatim možeš pokrenuti `fip nyc-dev 3000` za prosljeđivanje tog porta, tako da `localhost:3000` zapravo doseže `nyc-dev:3000`, ali bez potrebe za SSL certifikatima za uspostavu sigurnog konteksta potrebnog za testiranje web socketa ili slično.

## SSH ponovno spajanje

Sam `ssh` omotan je u funkciju koja čisti terminal ako veza umre dok ga je udaljeni tmux, Herdr ili uređivač zauzeo, a zatim se automatski ponovno spaja kad interaktivna sesija padne (Ctrl-C zaustavlja petlju ponovnih pokušaja).
