# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je príjemnou alternatívou k niečomu ako aplikácia GitHub Desktop a beží priamo v termináli.

Môžete ho spustiť priamo tak, že prejdete do ľubovoľného adresára spravovaného gitom a spustíte `lazygit`. Alebo ho môžete spustiť vnútri Neovim, kde ho spustíte pomocou `Space G G`.

Medzi rôznymi panelmi prepínate pomocou `Tab`. Na paneli Files vyberáte súbory na staging pomocou `Space` a potom môžete vytvoriť nový commit pomocou `c`. Všetky dostupné príkazy môžete vidieť pomocou `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásny správca prostriedkov, ktorý zobrazuje využitie pamäte, CPU, disku a siete. Tiež uvádza všetky aktívne procesy a umožňuje vám ich spravovať.

Omarchy ho nazýva Activity Monitor a spustíte ho zo spúšťača aplikácií alebo stlačením `Super + Shift + T`. Otvorí sa ako plávajúce okno, ktoré môžete previesť do dlaždicového režimu pomocou `Super + T`.

## Herdr

[Herdr](https://herdr.dev) je správca pracovných priestorov pre terminál, ktorý vám poskytuje pracovné priestory, karty a panely a všetky ich udržiava spustené v trvalej relácii, z ktorej sa môžete odpojiť a neskôr sa k nej vrátiť.

Spustíte ho (alebo sa znova pripojíte k vašej existujúcej relácii) zo spúšťača aplikácií alebo pomocou `Super + Ctrl + Return`. Omarchy dodáva konfiguráciu Herdr, ktorá zrkadlí jeho konfiguráciu Tmux, takže prefixový kláves je aj tu `Ctrl + Space`. Všetky klávesové skratky si môžete prezrieť pomocou `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje informácie o systéme, ako je verzia jadra, doba prevádzky, téma, CPU, pamäť a ďalšie. Je nástupcom populárneho nástroja neofetch.

Omarchy to zabalil ako _System > About_ v menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro hudobný prehrávač pre terminál inšpirovaný Winamp 2.x, kompletný so vstavanými rozhlasovými stanicami pre lo-fi beaty. Spustíte ho pomocou `Super + Shift + Alt + M` alebo z menu Omarchy v časti _Apps_. Stlačením `?` zobrazíte úplný zoznam klávesových skratiek.

## A čo Wi-Fi a Bluetooth?

TUIs pre Wi-Fi a Bluetooth nenájdete — tieto úlohy patria do shellu Omarchy. Kliknite na ikonu Wi-Fi v hornom paneli (alebo stlačte `Super + Ctrl + N`), ak chcete zobraziť siete a pripojiť sa, a kliknite na ikonu Bluetooth (alebo stlačte `Super + Ctrl + B`), ak chcete spárovať a pripojiť zariadenia. Úplný príbeh nájdete v časti [sieťovanie](35-networking.md).

## Pridanie vlastných

Každý terminálový program môže dostať plnohodnotné zaobchádzanie ako aplikácia. Prejdite do _Install > TUI_ v menu Omarchy (`Super + Space`), zadajte mu názov, príkaz na spustenie, štýl okna a ikonu a zobrazí sa v spúšťači aplikácií ako ktorákoľvek iná aplikácia. Znova ho môžete odstrániť v časti _Remove > TUI_.
