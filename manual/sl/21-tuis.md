# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je čudovita alternativa nečemu, kot je aplikacija GitHub Desktop, in deluje znotraj terminala.

Zaženete ga lahko neposredno tako, da greste v kateri koli imenik, ki ga upravlja git, in zaženete `lazygit`. Lahko pa ga zaženete znotraj Neovima, kjer ga lahko zaženete s `Space G G`.

Med različnimi podokni skačete z uporabo `Tab`. V podoknu Files datoteke za pripravo na uveljavitev izberete s `Space`, nato pa lahko z `c` ustvarite novo uveljavitev. Vse razpoložljive ukaze si lahko ogledate z `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je čudovit upravljalnik virov, ki prikazuje porabo pomnilnika, CPU, diska in omrežja. Navede tudi vse aktivne procese in vam omogoča njihovo upravljanje.

Omarchy ga imenuje Dejavnost, zaženete pa ga s pritiskom na `Super + Shift + T`. Odpre se kot plavajoče okno, ki ga lahko vključite v postavitev s ploščicami s `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je upravljalnik delovnih prostorov v terminalu, ki vam daje delovne prostore, zavihke in podokna ter jih vse ohranja v trajni seji, s katere se lahko odklopite in se nanjo pozneje vrnete.

Zaženete ga (ali se znova povežete z obstoječo sejo) s `Super + Ctrl + Return`. Omarchy ima priloženo konfiguracijo za Herdr, ki zrcali njegovo konfiguracijo za Tmux, zato je tipka za predpono tudi tukaj `Ctrl + Space`. Vse bližnjice na tipkovnici si lahko ogledate s `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) prikazuje informacije o sistemu, kot so različica jedra, čas delovanja, tema, CPU, pomnilnik in še več. Je naslednik priljubljenega orodja neofetch.

Omarchy je to zapakiral kot _Vizitka_ v meniju Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro glasbeni predvajalnik za terminal, ki ga je navdihnil Winamp 2.x, skupaj z vgrajenimi radijskimi postajami za lo-fi ritme. Zaženite ga s `Super + Shift + Alt + M` ali iz menija Omarchy pod _Aplikacije_. Pritisnite `?` za celoten seznam bližnjic na tipkovnici.

## Kaj pa Wi-Fi in Bluetooth?

Za Wi-Fi in Bluetooth ne boste našli TUI-jev — ta opravila pripadajo lupini Omarchy. Kliknite ikono Wi-Fi v zgornji vrstici (ali pritisnite `Super + Ctrl + N`), da si ogledate omrežja in se povežete, in kliknite ikono Bluetooth (ali pritisnite `Super + Ctrl + B`), da seznanite in povežete naprave. Za celotno zgodbo si oglejte [omrežje](35-networking.md).

## Dodajanje lastnih

Vsak terminalski program lahko dobi obravnavo kot prava aplikacija. Pojdite na _Namesti > TUI_ v meniju Omarchy (`Super + Space`), mu dajte ime, ukaz za zagon, slog okna in ikono, in prikazal se bo v zaganjalniku aplikacij kot vsaka druga aplikacija. Znova ga lahko odstranite pod _Odstrani > TUI_.
