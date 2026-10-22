# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je príjemná alternatíva k niečomu ako aplikácii GitHub Desktop a beží vnútri terminálu.

Môžeš ho spustiť priamo tak, že prejdeš do ľubovoľného adresára spravovaného gitom a spustíš `lazygit`. Alebo ho môžeš spustiť vnútri editora Neovim, kde sa dá spustiť pomocou `Space G G`.

Medzi rôznymi panelmi preskakuješ pomocou `Tab`. V paneli Files vyberieš súbory na staging pomocou `Space` a potom môžeš vytvoriť nový commit pomocou `c`. Všetky dostupné príkazy uvidíš pomocou `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásny správca prostriedkov, ktorý zobrazuje využitie pamäte, procesora, disku a siete. Vypisuje tiež všetky aktívne procesy a umožňuje ti ich spravovať.

Omarchy ho nazýva Activity a spúšťaš ho stlačením `Super + Ctrl + T`. Otvorí sa ako plávajúce okno, ktoré môžeš vydláždiť pomocou `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je správca terminálových pracovných priestorov, ktorý ti poskytuje pracovné priestory, karty a panely a udržuje ich všetky spustené v trvalej relácii, od ktorej sa môžeš odpojiť a vrátiť sa k nej neskôr.

Spúšťaš ho (alebo sa znova pripájaš k svojej existujúcej relácii) pomocou `Super + Ctrl + Return`. Omarchy sa dodáva s konfiguráciou Herdr, ktorá zrkadlí jeho konfiguráciu Tmux, takže aj tu je prefixový kláves `Ctrl + Space`. Všetky klávesové skratky si môžeš prezrieť pomocou `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje systémové informácie, ako sú verzia jadra, doba prevádzky, téma, procesor, pamäť a ďalšie. Je to nástupca populárneho nástroja neofetch.

Omarchy to zabalil ako _Informácie_ v menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro terminálový hudobný prehrávač inšpirovaný prehrávačom Winamp 2.x vrátane zabudovaných rozhlasových staníc s lo-fi beatmi. Spusti ho pomocou `Super + Shift + Alt + M` alebo z menu Omarchy v časti _Aplikácie_. Stlačením `?` zobrazíš úplný zoznam klávesových skratiek.

## A čo Wi-Fi a Bluetooth?

Pre Wi-Fi a Bluetooth nenájdeš žiadne TUI — tieto úlohy patria shellu Omarchy. Klikni na ikonu Wi-Fi v hornej lište (alebo stlač `Super + Ctrl + W`) a pozri si siete a pripoj sa, a klikni na ikonu Bluetooth (alebo stlač `Super + Ctrl + B`) a spáruj a pripoj zariadenia. Celý príbeh nájdeš v časti [sieťovanie](35-networking.md).

## Pridanie vlastných

Každý terminálový program môže dostať plnohodnotné zaobchádzanie ako aplikácia. Prejdi do časti _Inštalovať > TUI_ v menu Omarchy (`Super + Space`), zadaj mu názov, príkaz na spustenie, štýl okna a ikonu a objaví sa v spúšťači aplikácií ako každá iná aplikácia. Znova ho môžeš odstrániť v časti _Odstrániť > TUI_.
