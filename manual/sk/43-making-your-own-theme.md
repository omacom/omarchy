# Vytvorenie vlastnej témy

Vlastné témy môžeš pridať do `~/.config/omarchy/themes`. Jednoducho skopíruj niektorú z existujúcich tém ako základ (pozri sa do `/usr/share/omarchy/themes`) a potom si ju uprav podľa vlastnej chuti. Pokiaľ je tvoja téma v tomto priečinku, objaví sa v ponuke výberu tém.

Hlavný súbor, ktorý musíš upraviť, je `colors.toml`. Ten definuje sadu farieb, ktorá sa potom používa na generovanie konfigurácií pre terminál (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplikácie Qt, podsvietenie klávesnice, metódu vstupu, výber zdieľania obrazovky, ikony aplikácií, niekoľko nástrojov AI (Claude, Pi, Hermes, T3 Code, Herdr) a celý shell Omarchy (horná lišta, ponuka, oznámenia, OSD a obrazovka uzamknutia).

Na vytvorenie novej témy môžeš použiť aj priloženú aplikáciu Aether, ktorá má pekné GUI rozhranie na hranie sa s farbami a vyhľadávanie pozadí. Stačí ju spustiť zo siete aplikácií pomocou `Super + Alt + Space`.

### Čo môže obsahovať nainštalovaná téma

Téma, ktorú si napíšeš sám v `~/.config/omarchy/themes`, môže obsahovať čokoľvek chceš — je to tvoj počítač a tvoj súbor a Omarchy použije všetko z nej.

Téma, ktorú si nainštaluješ z cudzieho repozitára pomocou `omarchy theme install`, si ponechá všetko, čo sa týka farieb, a stratí hŕstku súborov, ktoré by na tvojom počítači spúšťali kód: ľubovoľný súbor `.lua`, konfigurácie terminálu (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) a `vscode.json`. Súbor `hyprland.lua` témy je Lua, ktorú tvoj kompozitor spúšťa pri prihlásení, konfigurácia terminálu určuje program, ktorý tvoj terminál spúšťa, a `vscode.json` určuje rozšírenie VSCode, ktoré sa má nainštalovať. Inštalácia cudzej témy má zmeniť vzhľad tvojej pracovnej plochy, nikdy nie to, čo sa na nej spúšťa.

Všetko ostatné naďalej funguje presne tak, ako to autor témy napísal — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, pozadia aj ukážky zostávajú zachované. Iba to, čo bolo odstránené, sa na tvojom počítači znovu vygeneruje z `colors.toml`.

Omarchy ich od seba rozoznáva podľa toho, či má téma vo vnútri vlastný repozitár git, čo je to, čo za sebou zanechá `omarchy theme install`, keď ho naklonuje. Takže téma, ktorú si napísal, zostane tvoja a tá, ktorú si stiahol z internetu, zostane len farbami.

### Svetlý režim

Ak vytváraš tému v svetlom režime, nastav `mode = "light"` na začiatku svojho `colors.toml`. Potom sa pre všetky aplikácie automaticky spáruje so svetlým režimom. (Starý spôsob, keď stačilo vložiť prázdny súbor s názvom `light.mode` do koreňa témy, funguje tiež.)

### Obrazovky zavádzania a prihlásenia

Obrazovka, ktorá pri zavádzaní žiada heslo k disku, a prihlasovacia obrazovka kreslia logo Omarchy vo farbe `accent` tvojej témy na jej `background`, pričom pole pre heslo je v jej `foreground` a `red` pre nesprávne heslo. Nemusíš pre ne dodávať nič navyše: Omarchy už nepoužíva súbory `unlock.png` ani `preview-unlock.png` témy. Na počítačoch Mac s Apple Silicon si obrazovka s heslom k disku zachováva predvolený vzhľad Omarchy bez ohľadu na tému.

### Témovanie aplikácií, na ktoré sa Omarchy nevzťahuje

Ak používaš aplikáciu, ktorá nie je na tomto zozname, môžeš Omarchy naučiť, ako ju témovať, pomocou šablóny. Vlož súbor do `~/.config/omarchy/themed/` pomenovaný podľa konfigurácie, ktorú generuje, plus prípona `.tpl`, a napíš konfiguráciu s `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` až `{{ color15 }}` a zvyškom palety ako zástupnými symbolmi. Zakaždým, keď prepneš témy, súbor sa znovu vygeneruje s farbami danej témy.

V tomto priečinku je na skopírovanie plne okomentovaný súbor `alacritty.toml.tpl.sample` — uvádza všetky premenné, ktoré môžeš použiť, plus modifikátory `_strip` a `_rgb` pre aplikácie, ktoré chcú svoje farby bez `#` alebo ako desiatkové RGB. Tvoje šablóny majú prednosť pred vlastnými šablónami Omarchy, takže to môžeš použiť aj na prepísanie spôsobu, akým sa témuje vstavaná aplikácia.

### Distribúcia tvojej témy

Ak chceš svoju tému distribuovať, aby ju mohli používať aj ostatní, musíš ju umiestniť na verejný server git, napríklad GitHub. Potom si ju ľudia môžu nainštalovať pomocou _Inštalovať > Štýl > Téma_ v ponuke Omarchy s použitím tejto URL. Odporúča sa dodržiavať konvenciu pomenovania `omarchy-[themename]-theme`, pretože téma sa po inštalácii v ponuke výberu tém zobrazí správne len ako `[themename]`.

Zvyšný text `[themename]` sa stane názvom adresára témy, takže musí byť taký, s ktorým môže Omarchy bezpečne pracovať: musí začínať písmenom, číslicou alebo podčiarkovníkom a zvyšok môže obsahovať písmená, číslice, `.`, `_`, `+` a `-`. Veľké písmená sa pre teba prevedú na malé, ale čokoľvek iné — medzera, úvodzovka, neanglický znak — sa pri inštalácii odmietne namiesto toho, aby sa z toho stal názov adresára. Takže `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` aj `omarchy-c++-theme` sa nainštalujú bez problémov.

Pamätaj, že akonáhle sa téma nainštaluje z repozitára, všetky súbory `.lua`, konfigurácie terminálu alebo `vscode.json`, ktoré obsahuje, sa zahodia, takže tému na nich nestavaj.

Svoju tému môžeš pridať na [stránku s ďalšími témami](https://omarchy.org/themes/) zaslaním pull requestu do [repozitára omarchy-site](https://github.com/omacom-io/omarchy-site).
