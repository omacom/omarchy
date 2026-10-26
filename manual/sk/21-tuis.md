# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je skvelá alternatíva k niečomu ako aplikácia GitHub Desktop a beží priamo v termináli.

Môžete ho spustiť priamo tak, že prejdete do ľubovoľného adresára spravovaného gitom a spustíte `lazygit`. Alebo ho môžete spustiť vnútri Neovim, kde ho spustíte pomocou `Space G G`.

Medzi jednotlivými panelmi prepínate pomocou `Tab`. V paneli Files vyberáte súbory na staging pomocou `Space` a potom môžete vytvoriť nový commit pomocou `c`. Všetky dostupné príkazy zobrazíte pomocou `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásny správca zdrojov, ktorý zobrazuje využitie pamäte, CPU, disku a siete. Zobrazuje aj všetky aktívne procesy a umožňuje vám ich spravovať.

Omarchy ho nazýva Activity a spustíte ho stlačením `Super + Shift + T`. Otvorí sa ako plávajúce okno, ktoré môžete usporiadať do dlaždíc pomocou `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je terminálový správca pracovných priestorov, ktorý vám dáva pracovné priestory, karty a panely a všetky ich necháva bežať v trvalej relácii, od ktorej sa môžete odpojiť a neskôr sa k nej vrátiť.

Spustíte ho (alebo sa znova pripojíte k svojej existujúcej relácii) pomocou `Super + Ctrl + Return`. Omarchy dodáva konfiguráciu Herdr, ktorá zrkadlí jeho konfiguráciu Tmux, takže prefixový kláves je aj tu `Ctrl + Space`. Všetky klávesové skratky si môžete prezrieť pomocou `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje informácie o systéme, ako je verzia jadra, doba prevádzky, téma, CPU, pamäť a ďalšie. Je nástupcom populárneho nástroja neofetch.

Omarchy to zabalila ako _About_ v menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro terminálový hudobný prehrávač inšpirovaný Winamp 2.x, doplnený o vstavané rádiové stanice s lo-fi beatmi. Spustíte ho pomocou `Super + Shift + Alt + M` alebo z menu Omarchy v časti _Apps_. Stlačením `?` zobrazíte úplný zoznam klávesových skratiek.

## A čo Wi-Fi a Bluetooth?

Pre Wi-Fi a Bluetooth TUIs nenájdete — tieto úlohy patria do shellu Omarchy. Kliknite na ikonu Wi-Fi v hornom paneli (alebo stlačte `Super + Ctrl + N`), ak chcete zobraziť siete a pripojiť sa, a kliknite na ikonu Bluetooth (alebo stlačte `Super + Ctrl + B`), ak chcete spárovať a pripojiť zariadenia. Celý príbeh nájdete v časti [sieťovanie](35-networking.md).

## Pridanie vlastných

Každý terminálový program môže dostať plnohodnotné zaobchádzanie ako aplikácia. Prejdite na _Install > TUI_ v menu Omarchy (`Super + Space`), dajte mu názov, príkaz na spustenie, štýl okna a ikonu a zobrazí sa v spúšťači aplikácií ako každá iná aplikácia. Znova ho môžete odstrániť v časti _Remove > TUI_.
