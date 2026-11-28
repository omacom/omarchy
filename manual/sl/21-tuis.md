# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je prijetna alternativa nečemu, kot je aplikacija GitHub Desktop, in deluje v terminalu.

Zaženete ga lahko neposredno, tako da se pomaknete v katero koli mapo, ki jo upravlja git, in zaženete `lazygit`. Lahko pa ga zaženete v Neovimu, kjer ga lahko zaženete s `Space G G`.

Med različnimi podokni preklapljate s `Tab`. V podoknu Files izberete datoteke za pripravo na uveljavitev s `Space`, nato pa lahko ustvarite nov commit s `c`. Vse razpoložljive ukaze si lahko ogledate z `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je lep upravitelj virov, ki prikazuje porabo pomnilnika, CPU, diska in omrežja. Navede tudi vse aktivne procese in vam omogoča njihovo upravljanje.

Omarchy ga imenuje Activity Monitor, zaženete pa ga iz zaganjalnika aplikacij ali s pritiskom na `Super + Shift + T`. Odpre se kot plavajoče okno, ki ga lahko razporedite v ploščice s `Super + T`.

## Herdr

[Herdr](https://herdr.dev) je upravitelj delovnih prostorov v terminalu, ki vam ponuja delovne prostore, zavihke in podokna ter jih vse ohranja v trajni seji, iz katere se lahko odklopite in se vanjo pozneje vrnete.

Zaženete ga (ali se znova povežete z obstoječo sejo) iz zaganjalnika aplikacij ali s `Super + Ctrl + Return`. Omarchy vključuje konfiguracijo za Herdr, ki zrcali njegovo konfiguracijo za Tmux, zato je tipka za predpono tudi tukaj `Ctrl + Space`. Vse bližnjice na tipkovnici lahko prebrskate s `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) prikazuje sistemske informacije, kot so različica jedra, čas delovanja, tema, CPU, pomnilnik in drugo. Je naslednik priljubljenega orodja neofetch.

Omarchy ga je zapakiral kot _System > About_ v meniju Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro predvajalnik glasbe v terminalu, navdihnjen z Winamp 2.x, skupaj z vgrajenimi radijskimi postajami za lo-fi beate. Zaženite ga s `Super + Shift + Alt + M` ali iz menija Omarchy pod _Apps_. Pritisnite `?` za celoten seznam bližnjic na tipkovnici.

## Kaj pa Wi-Fi in Bluetooth?

Za Wi-Fi in Bluetooth ne boste našli TUI-jev — ta opravila pripadajo lupini Omarchy. Kliknite ikono Wi-Fi v zgornji vrstici (ali pritisnite `Super + Ctrl + N`), da si ogledate omrežja in se povežete, in kliknite ikono Bluetooth (ali pritisnite `Super + Ctrl + B`), da seznanite in povežete naprave. Za celotno zgodbo si oglejte [omrežje](35-networking.md).

## Dodajanje lastnih

Vsak terminalski program lahko dobi celotno obravnavo aplikacije. Pojdite na _Install > TUI_ v meniju Omarchy (`Super + Space`), mu dajte ime, ukaz za zagon, slog okna in ikono, in prikazal se bo v zaganjalniku aplikacij kot vsaka druga aplikacija. Odstranite ga lahko znova pod _Remove > TUI_.
