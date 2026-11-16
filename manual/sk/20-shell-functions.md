# Shell funkcie

Omarchy sa dodáva so sadou shell funkcií, ktoré zjednodušujú bežné úlohy a zapuzdrujú komplikované volania parametrov.

## Kompresia

- `compress [file/dir]`: Vytvorí archív tar.gz zo súboru/adresára.
- `decompress [file.tar.gz]`: Rozbalí súbor tar.gz.

## Jednotky

- `iso2sd [image.iso]`: Vytvorí zavádzaciu jednotku na SD karte pomocou odkazovaného súboru iso a interaktívneho výberu jednotky.
- `format-drive [device] [name]`: Naformátuje celý disk jedným oddielom exFAT (ktorý funguje aj vo Windowse a macOS). Spusti to bez argumentov, aby si videl dostupné jednotky. Dávaj pozor!

## Vývojárske rozloženia

Okamžité vývojárske rozloženia s viacerými panelmi pre tmux:

- `tdl [ai]`: Vytvorí vývojárske rozloženie Tmux (Tmux Dev Layout) s tvojím editorom, AI agentom a terminálom. Použi aliasy agentov, napríklad `tdl c` pre opencode alebo `tdl cx` pre Claude Code, alebo odovzdaj druhého agenta a spusti oboch, napríklad `tdl c cx`.
- `tds`: Vytvorí vývojársky štvorec Tmux (Tmux Dev Square) s editorom, sledovaním diffov (prostredníctvom `hunk diff --watch`), terminálom a opencode.
- `tdlm [ai]`: Vytvorí okno `tdl` pre každý podadresár v aktuálnom adresári.
- `tsl [count] [command]`: Vytvorí roj panelov usporiadaných do mriežky, z ktorých všetky vykonávajú ten istý príkaz (skvelé pre AI agentov).

Rovnaké rozloženia sú dostupné pre Herdr ako `hdl`, `hds`, `hdlm` a `hsl`.

## Git worktrees

- `ga [branch]`: Vytvorí nový worktree a vetvu vedľa aktuálneho repozitára a preskočí doň.
- `gd`: Odstráni aktuálny worktree a jeho vetvu (najprv si vyžiada potvrdenie).

## Sledovanie pomocou Rsync

- `rsw [source] [destination]`: Spustí na pozadí sledovač, ktorý pomocou rsync synchronizuje zdroj s cieľom vždy, keď sa niečo zmení. Cieľom môže byť vzdialený hostiteľ, napríklad `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Vypíše všetky aktívne sledovače.
- `dsw`: Zastaví všetky aktívne sledovače.

## Presmerovanie portov SSH

Ideálne na vývoj webu s privilégiami zabezpečeného kontextu localhostu voči vzdialenému počítaču.

- `fip`: Presmeruje jeden alebo viac portov zo vzdialeného hostiteľa na localhost prostredníctvom SSH.
- `dip`: Odpojí jeden alebo viac presmerovaných portov.
- `lip`: Vypíše všetky aktívne presmerovania portov SSH.

Povedzme, že spustíš vývojový server na porte `3000` na počítači dostupnom ako `nyc-dev`. Potom môžeš spustiť `fip nyc-dev 3000` a presmerovať tento port tak, aby `localhost:3000` v skutočnosti dosiahol `nyc-dev:3000`, ale bez potreby certifikátov SSL na vytvorenie zabezpečeného kontextu potrebného na testovanie web socketov a podobne.

## Opätovné pripojenie SSH

Samotný príkaz `ssh` je zabalený do funkcie, ktorá vyčistí terminál, ak spojenie zanikne, zatiaľ čo si ho nárokuje vzdialený tmux, Herdr alebo editor, a potom sa automaticky znova pripojí, keď interaktívna relácia odpadne (Ctrl-C zastaví slučku opakovaných pokusov).
