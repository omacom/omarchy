# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je prijetna alternativa nečemu, kot je aplikacija GitHub Desktop, in deluje znotraj terminala.

Zaženete ga lahko neposredno, tako da se pomaknete v katero koli mapo, ki jo upravlja git, in zaženete `lazygit`. Lahko pa ga zaženete znotraj Neovim, kjer ga zaženete s `Space G G`.

Med različnimi podokni preklapljate s tipko `Tab`. V podoknu Files datoteke za pripravljanje (staging) izberete s `Space`, nato pa lahko ustvarite nov commit s `c`. Vse razpoložljive ukaze si lahko ogledate s `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je lep upravitelj virov, ki prikazuje porabo pomnilnika, CPU, diska in omrežja. Prav tako našteje vse aktivne procese in omogoča njihovo upravljanje.

Omarchy ga imenuje Activity Monitor, zaženete pa ga iz zaganjalnika aplikacij ali s pritiskom `Super + Shift + T`. Odpre se kot plavajoče okno, ki ga lahko postavite v ploščice s `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je upravitelj delovnih prostorov za terminal, ki vam daje delovne prostore, zavihke in podokna ter jih vse ohranja zagnane v vztrajni seji, iz katere se lahko odklopite in se vanjo pozneje vrnete.

Zaženete ga (ali se znova povežete z obstoječo sejo) iz zaganjalnika aplikacij ali s `Super + Ctrl + Return`. Omarchy prinaša konfiguracijo za Herdr, ki zrcali njegovo konfiguracijo za Tmux, zato je tudi tukaj predpona `Ctrl + Space`. Vse bližnjice na tipkovnici si lahko ogledate s `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) prikazuje sistemske informacije, kot so različica jedra, čas delovanja, tema, CPU, pomnilnik in drugo. Je naslednik priljubljenega orodja neofetch.

Omarchy ga je zapakiral kot _O programu_ v meniju Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro predvajalnik glasbe za terminal, ki ga je navdihnil Winamp 2.x, skupaj z vgrajenimi radijskimi postajami za lo-fi beate. Zaženete ga s `Super + Shift + Alt + M` ali iz menija Omarchy pod _Aplikacije_. Pritisnite `?` za celoten seznam bližnjic na tipkovnici.

## Kaj pa Wi-Fi in Bluetooth?

Za Wi-Fi in Bluetooth ne boste našli TUI-jev — te naloge pripadajo lupini Omarchy. Kliknite ikono Wi-Fi v zgornji vrstici (ali pritisnite `Super + Ctrl + N`), da si ogledate omrežja in se povežete, in kliknite ikono Bluetooth (ali pritisnite `Super + Ctrl + B`), da seznanite in povežete naprave. Za celotno zgodbo si oglejte [omreženje](35-networking.md).

## Dodajanje lastnih

Vsak program za terminal je lahko deležen celotne obravnave kot aplikacija. Pojdite na _Namesti > TUI_ v meniju Omarchy (`Super + Space`), dajte mu ime, ukaz za zagon, slog okna in ikono, in prikazal se bo v zaganjalniku aplikacij kot vsaka druga aplikacija. Znova ga lahko odstranite pod _Odstrani > TUI_.
