# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je príjemnou alternatívou k niečomu ako aplikácia GitHub Desktop a beží vnútri terminálu.

Spustiť ho môžete priamo tak, že prejdete do ľubovoľného adresára spravovaného gitom a spustíte `lazygit`. Alebo ho môžete spustiť vnútri Neovimu, kde sa spúšťa pomocou `Space G G`.

Medzi rôznymi panelmi prepínate pomocou `Tab`. V paneli Files vyberáte súbory na staging pomocou `Space` a potom môžete vytvoriť nový commit pomocou `c`. Všetky dostupné príkazy zobrazíte pomocou `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je nádherný správca zdrojov, ktorý zobrazuje využitie pamäte, CPU, disku a siete. Takisto vypíše všetky aktívne procesy a umožňuje vám ich spravovať.

Omarchy ho nazýva Activity Monitor a spustíte ho zo spúšťača aplikácií alebo stlačením `Super + Shift + T`. Otvorí sa ako plávajúce okno, ktoré môžete do dlaždíc prepnúť pomocou `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je správca pracovných priestorov v termináli, ktorý vám poskytne pracovné priestory, karty a panely a všetky ich udržiava spustené v perzistentnej relácii, z ktorej sa môžete odpojiť a neskôr sa k nej vrátiť.

Spustíte ho (alebo sa znova pripojíte k svojej existujúcej relácii) pomocou `Super + Ctrl + Return`. Omarchy dodáva konfiguráciu Herdr, ktorá zrkadlí jeho konfiguráciu Tmux, takže prefixové tlačidlo je tu tiež `Ctrl + Space`. Všetky klávesové skratky si môžete prezrieť pomocou `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje informácie o systéme, ako sú verzia jadra, uptime, téma, CPU, pamäť a ďalšie. Je to nástupca populárneho nástroja neofetch.

Omarchy to zabalil ako _About_ v ponuke Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro hudobný prehrávač pre terminál inšpirovaný Winampom 2.x, doplnený o zabudované rozhlasové stanice s lo-fi beatmi. Spustíte ho pomocou `Super + Shift + Alt + M` alebo z ponuky Omarchy v časti _Apps_. Stlačením `?` zobrazíte úplný zoznam klávesových skratiek.

## A čo Wi-Fi a Bluetooth?

Pre Wi-Fi a Bluetooth TUIs nenájdete — tieto úlohy patria do shellu Omarchy. Kliknite na ikonu Wi-Fi v hornej lište (alebo stlačte `Super + Ctrl + N`), ak chcete zobraziť siete a pripojiť sa, a kliknite na ikonu Bluetooth (alebo stlačte `Super + Ctrl + B`), ak chcete spárovať a pripojiť zariadenia. Celý príbeh nájdete v časti [sieťovanie](35-networking.md).

## Pridanie vlastných

Každý terminálový program môže dostať úplné zaobchádzanie ako aplikácia. Prejdite na _Install > TUI_ v ponuke Omarchy (`Super + Space`), zadajte názov, príkaz na spustenie, štýl okna a ikonu a zobrazí sa v spúšťači aplikácií ako každá iná aplikácia. Znova ho môžete odstrániť v časti _Remove > TUI_.
