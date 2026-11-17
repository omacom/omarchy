# Vytvorenie vlastnej témy

Vlastné témy môžete pridať do `~/.config/omarchy/themes`. Stačí skopírovať niektorú z existujúcich tém ako základ (pozrite sa do `/usr/share/omarchy/themes`) a potom si ju upraviť podľa svojho vkusu. Pokiaľ je vaša téma v tomto priečinku, bude zahrnutá v ponuke výberu témy.

Hlavný súbor, ktorý musíte upraviť, je `colors.toml`. Ten definuje sadu farieb, ktorá sa potom použije na generovanie konfigurácií pre terminál (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian a celé prostredie Omarchy (horný panel, ponuka, oznámenia, OSD a zamknutá obrazovka).

Na vytvorenie novej témy môžete použiť aj priloženú aplikáciu Aether, ktorá ponúka pekné rozhranie GUI na hranie sa s farbami a vyhľadávanie pozadí. Stačí ju spustiť zo siete aplikácií pomocou `Super + Alt + Space`.

### Čo môže nainštalovaná téma obsahovať

Téma, ktorú si sami napíšete v `~/.config/omarchy/themes`, môže obsahovať čokoľvek chcete — je to vaše zariadenie a váš súbor a Omarchy použije všetko.

Téma, ktorú nainštalujete z cudzieho repozitára pomocou `omarchy theme install`, si zachová všetko, čo sa týka farieb, a stratí hŕstku súborov, ktoré by na vašom zariadení spúšťali kód: všetky súbory `.lua`, konfigurácie terminálu (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) a `vscode.json`. Súbor `hyprland.lua` témy je Lua, ktorý váš kompozitor spúšťa pri prihlásení, konfigurácia terminálu určuje program, ktorý váš terminál spúšťa, a `vscode.json` určuje rozšírenie VSCode, ktoré sa má nainštalovať. Inštalácia cudzej témy má zmeniť vzhľad vašej pracovnej plochy, nikdy nie to, čo sa na nej spúšťa.

Všetko ostatné stále funguje presne tak, ako to autor témy napísal — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, pozadia a ukážky zostávajú zachované. Iba to, čo bolo odstránené, sa znova vygeneruje z `colors.toml` na vašom zariadení.

Omarchy ich rozlišuje podľa toho, či má téma vo vnútri vlastný git repozitár, ktorý tam zanechá `omarchy theme install` pri klonovaní. Takže téma, ktorú ste si napísali, zostáva vaša a téma stiahnutá z internetu zostáva len farbami.

### Svetlý režim

Ak vytvárate tému so svetlým režimom, nastavte `mode = "light"` na začiatku súboru `colors.toml`. Potom sa automaticky spáruje so svetlým režimom pre všetky aplikácie. (Starý spôsob, vloženie prázdneho súboru s názvom `light.mode` do koreňového adresára témy, stále funguje tiež.)

### Obrázok odomknutia

Témy dodávané s obrázkami `unlock.png` a `preview-unlock.png` budú uvedené v časti _Vzhľad > Odomknutie_. Váš súbor `unlock.png` by mal byť prednostne priehľadný png. A ukážkový obrázok môžete vytvoriť pomocou `omarchy plymouth preview`.

### Témovanie aplikácií, ktoré Omarchy nepokrýva

Ak používate aplikáciu, ktorá nie je na tomto zozname, môžete Omarchy naučiť, ako ju témovať, pomocou šablóny. Vložte súbor do `~/.config/omarchy/themed/` pomenovaný podľa konfigurácie, ktorú generuje, plus príponu `.tpl`, a konfiguráciu napíšte pomocou `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` až `{{ color15 }}` a zvyšku palety ako zástupných symbolov. Pri každej zmene témy sa súbor znova vygeneruje s farbami tejto témy.

V tomto priečinku je plne komentovaný súbor `alacritty.toml.tpl.sample`, z ktorého môžete kopírovať — uvádza všetky premenné, ktoré môžete použiť, plus modifikátory `_strip` a `_rgb` pre aplikácie, ktoré chcú farby bez znaku `#` alebo ako desiatkové RGB. Vaše šablóny majú prednosť pred vlastnými šablónami Omarchy, takže ich môžete použiť aj na prepísanie spôsobu, akým sa témuje vstavaná aplikácia.

### Distribúcia vašej témy

Ak chcete distribuovať svoju tému, aby ju mohli používať aj ostatní, musíte ju umiestniť na verejný git server, napríklad GitHub. Potom si ju ľudia môžu nainštalovať cez _Inštalácia > Štýl > Téma_ v ponuke Omarchy pomocou danej URL. Odporúča sa dodržiavať konvenciu pomenovania `omarchy-[themename]-theme`, pretože téma sa po inštalácii v ponuke výberu témy zobrazí správne len ako `[themename]`.

Zvyšné `[themename]` sa stane názvom priečinka témy, takže musí byť taký, s ktorým môže Omarchy bezpečne narábať: musí začínať písmenom, číslicou alebo podčiarkovníkom a zvyšok môže obsahovať písmená, číslice, `.`, `_`, `+` a `-`. Veľké písmená sa pre vás prevedú na malé, ale čokoľvek iné — medzera, úvodzovka, neanglický znak — bude pri inštalácii odmietnuté a nebude prevedené na názov priečinka. Takže `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` a `omarchy-c++-theme` sa všetky nainštalujú bez problémov.

Pamätajte, že po inštalácii z repozitára sa všetky súbory `.lua`, konfigurácie terminálu alebo `vscode.json`, ktoré obsahuje, odstránia, takže tému nestavajte na nich.

Svoju tému môžete pridať na [stránku s ďalšími témami](https://omarchy.org/themes/) odoslaním pull requestu do [repozitára omarchy-site](https://github.com/omacom-io/omarchy-site).
