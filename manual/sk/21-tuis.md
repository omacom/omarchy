# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je príjemná alternatíva k niečomu, ako je aplikácia GitHub Desktop, a beží vnútri terminálu.

Spustiť ho môžeš priamo tak, že prejdeš do akéhokoľvek adresára spravovaného gitom a spustíš `lazygit`. Alebo ho môžeš spustiť vnútri Neovimu, kde sa dá spustiť pomocou `Space G G`.

Medzi rôznymi panelmi preskakuješ pomocou `Tab`. V paneli Files vyberáš súbory na prípravu na commit pomocou `Space` a potom môžeš vytvoriť nový commit pomocou `c`. Všetky dostupné príkazy si môžeš pozrieť pomocou `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je krásny správca zdrojov, ktorý zobrazuje využitie pamäte, CPU, disku a siete. Uvádza aj všetky aktívne procesy a umožňuje ti ich spravovať.

Omarchy ho nazýva Activity Monitor a spustíš ho zo spúšťača aplikácií alebo stlačením `Super + Shift + T`. Otvorí sa ako plávajúce okno, ktoré môžeš prepnúť na dlaždicové pomocou `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je správca pracovných priestorov pre terminál, ktorý ti dáva pracovné priestory, karty a panely a necháva ich všetky bežať v trvalej relácii, od ktorej sa môžeš odpojiť a neskôr sa k nej vrátiť.

Spustíš ho (alebo sa znova pripojíš k existujúcej relácii) zo spúšťača aplikácií alebo pomocou `Super + Ctrl + Return`. Omarchy dodáva konfiguráciu Herdr, ktorá zrkadlí jej konfiguráciu Tmux, takže kláves prefixu je aj tu `Ctrl + Space`. Všetky klávesové skratky si môžeš prezrieť pomocou `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) zobrazuje systémové informácie, ako sú verzia jadra, čas prevádzky, téma, CPU, pamäť a ďalšie. Je nástupcom obľúbeného nástroja neofetch.

Omarchy ho zabalila ako _System > About_ v menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro hudobný prehrávač do terminálu inšpirovaný Winamp 2.x, doplnený o zabudované rozhlasové stanice s lo-fi beatmi. Spustíš ho pomocou `Super + Shift + Alt + M` alebo z menu Omarchy v časti _Apps_. Stlačením `?` zobrazíš úplný zoznam klávesových skratiek.

## A čo Wi-Fi a Bluetooth?

TUIs pre Wi-Fi a Bluetooth nenájdeš — tie úlohy patria shellu Omarchy. Klikni na ikonu Wi-Fi v hornom paneli (alebo stlač `Super + Ctrl + N`), ak chceš vidieť siete a pripojiť sa, a klikni na ikonu Bluetooth (alebo stlač `Super + Ctrl + B`), ak chceš párovať a pripájať zariadenia. Celý príbeh nájdeš v [networkingu](35-networking.md).

## Pridanie vlastných

Plnohodnotné zaobchádzanie ako s aplikáciou môže dostať akýkoľvek terminálový program. Choď na _Install > TUI_ v menu Omarchy (`Super + Space`), daj mu názov, príkaz na spustenie, štýl okna a ikonu a objaví sa v spúšťači aplikácií ako akákoľvek iná aplikácia. Znova ho môžeš odstrániť v časti _Remove > TUI_.
