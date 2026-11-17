# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je skvelá alternatíva k niečomu ako aplikácia GitHub Desktop a beží priamo v termináli.

Spustíte ho priamo tak, že prejdete do ľubovoľného adresára spravovaného gitom a spustíte `lazygit`. Alebo ho môžete spustiť vnútri Neovim, kde sa spúšťa pomocou `Space G G`.

Medzi jednotlivými panelmi prepínate pomocou `Tab`. V paneli Files vyberiete súbory na staging pomocou `Space` a potom môžete vytvoriť nový commit pomocou `c`. Všetky dostupné príkazy zobrazíte pomocou `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je nádherný správca prostriedkov, ktorý zobrazuje využitie pamäte, CPU, disku a siete. Zobrazuje tiež všetky aktívne procesy a umožňuje vám ich spravovať.

Omarchy ho nazýva Activity Monitor a spustíte ho zo spúšťača aplikácií alebo stlačením `Super + Shift + T`. Otvorí sa ako plávajúce okno, ktoré môžete zaradiť medzi dlaždice pomocou `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je správca pracovných priestorov pre terminál, ktorý vám poskytuje pracovné priestory, karty a panely a všetky ich udržiava spustené v trvalej relácii, od ktorej sa môžete odpojiť a neskôr sa k nej vrátiť.

Spustíte ho (alebo sa znova pripojíte k svojej existujúcej relácii) zo spúšťača aplikácií alebo pomocou `Super + Ctrl + Return`. Omarchy dodáva konfiguráciu Herdr, ktorá odráža jeho konfiguráciu Tmux, takže aj tu je prefixová klávesa `Ctrl + Space`. Všetky klávesové skratky si môžete prezrieť pomocou `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje systémové informácie, ako je verzia jadra, doba prevádzky, téma, CPU, pamäť a ďalšie. Je nástupcom populárneho nástroja neofetch.

Omarchy ho zabalilo ako _About_ v ponuke Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro hudobný prehrávač pre terminál inšpirovaný Winamp 2.x, vrátane zabudovaných rozhlasových staníc s lo-fi beatmi. Spustíte ho pomocou `Super + Shift + Alt + M` alebo z ponuky Omarchy v časti _Apps_. Stlačením `?` zobrazíte úplný zoznam klávesových skratiek.

## A čo Wi-Fi a Bluetooth?

Nenájdete TUIs pre Wi-Fi a Bluetooth — tieto úlohy patria do shellu Omarchy. Kliknite na ikonu Wi-Fi v hornom paneli (alebo stlačte `Super + Ctrl + N`), ak chcete zobraziť siete a pripojiť sa, a kliknite na ikonu Bluetooth (alebo stlačte `Super + Ctrl + B`), ak chcete spárovať a pripojiť zariadenia. Celý príbeh nájdete v kapitole [siete](35-networking.md).

## Pridanie vlastného

Každý terminálový program môže dostať plnohodnotné zaobchádzanie ako aplikácia. Prejdite do _Install > TUI_ v ponuke Omarchy (`Super + Space`), zadajte mu názov, príkaz na spustenie, štýl okna a ikonu a zobrazí sa v spúšťači aplikácií ako každá iná aplikácia. Znova ho môžete odstrániť v časti _Remove > TUI_.
