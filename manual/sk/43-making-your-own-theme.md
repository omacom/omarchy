# Vytvorenie vlastnej témy

Vlastné témy môžete pridať do `~/.config/omarchy/themes`. Stačí skopírovať niektorú z existujúcich ako základ (pozrite sa do `/usr/share/omarchy/themes`) a potom ju upraviť podľa svojho vkusu. Pokiaľ je vaša téma v tomto priečinku, bude zahrnutá v ponuke výberu tém.

Hlavný súbor, ktorý musíte upraviť, je `colors.toml`. Ten definuje súpravu farieb, ktorá sa potom používa na generovanie konfigurácií pre terminál (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt aplikácie, podsvietenie klávesnice, metódu vstupu, výber zdieľania obrazovky, ikony aplikácií, niekoľko AI nástrojov (Claude, Pi, Hermes, T3 Code, Herdr) a celé prostredie Omarchy (horná lišta, ponuka, oznámenia, OSD a uzamykacia obrazovka).

Na vytvorenie novej témy môžete použiť aj priloženú aplikáciu Aether s príjemným GUI rozhraním, v ktorom sa môžete hrať s farbami a vyhľadávať pozadia. Stačí ju spustiť z mriežky aplikácií pomocou `Super + Alt + Space`.

### Čo môže obsahovať nainštalovaná téma

Téma, ktorú sami napíšete do `~/.config/omarchy/themes`, môže obsahovať, čokoľvek chcete — je to váš počítač a váš súbor a Omarchy použije všetko z nej.

Téma, ktorú nainštalujete z repozitára niekoho iného pomocou `omarchy theme install`, si zachová všetko, čo je farba, a stratí hŕstku súborov, ktoré by na vašom počítači spúšťali kód: akýkoľvek súbor `.lua`, konfigurácie terminálu (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) a `vscode.json`. Súbor `hyprland.lua` témy je Lua, ktorý váš kompozitor spúšťa pri prihlásení, konfigurácia terminálu udáva program, ktorý váš terminál spúšťa, a `vscode.json` udáva rozšírenie VSCode, ktoré sa má nainštalovať. Inštalácia cudzej témy by mala zmeniť vzhľad vašej pracovnej plochy, nikdy nie to, čo sa na nej spúšťa.

Všetko ostatné stále funguje presne tak, ako to napísal autor témy — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, pozadia a ukážky sú zachované všetky. Len to, čo bolo zahodené, sa na vašom počítači znovu vygeneruje z `colors.toml`.

Omarchy tieto dve možnosti rozlišuje podľa toho, či má téma vo vnútri vlastný git repozitár, čo je to, čo po sebe zanecháva `omarchy theme install`, keď klonuje. Takže téma, ktorú ste napísali vy, zostáva vaša a téma stiahnutá z internetu zostáva len farbami.

### Svetlý režim

Ak vytvárate tému so svetlým režimom, nastavte `mode = "light"` na začiatok svojho `colors.toml`. Potom sa automaticky spáruje so svetlým režimom pre všetky aplikácie. (Starý spôsob vloženia prázdneho súboru s názvom `light.mode` do koreňa vašej témy stále funguje tiež.)

### Obrázok odomknutia

Témy dodávané s obrázkami `unlock.png` a `preview-unlock.png` budú uvedené v časti _Appearance > Unlock_. Váš `unlock.png` by mal byť prednostne priehľadný png. Ukážkový obrázok môžete vytvoriť pomocou `omarchy plymouth preview`.

### Témovanie aplikácií, ktoré Omarchy nepokrýva

Ak používate aplikáciu, ktorá nie je v tomto zozname, môžete Omarchy sami naučiť, ako ju témovať, pomocou šablóny. Vložte súbor do `~/.config/omarchy/themed/` pomenovaný podľa konfigurácie, ktorú generuje, plus príponu `.tpl` a napíšte konfiguráciu s `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` až `{{ color15 }}` a so zvyškom palety ako zástupnými symbolmi. Pri každom prepnutí témy sa súbor znovu vygeneruje s farbami danej témy.

V tomto priečinku je plne okomentovaný súbor `alacritty.toml.tpl.sample`, z ktorého môžete kopírovať — uvádza každú premennú, ktorú môžete použiť, plus modifikátory `_strip` a `_rgb` pre aplikácie, ktoré chcú svoje farby bez `#` alebo ako desiatkové RGB. Vaše šablóny majú prednosť pred šablónami samotného Omarchy, takže toto môžete použiť aj na prepísanie toho, ako sa témuje vstavaná aplikácia.

### Distribúcia vašej témy

Ak chcete distribuovať svoju tému, aby ju mohli používať ostatní, musíte ju umiestniť na verejný git server, ako je GitHub. Potom si ju ľudia môžu nainštalovať pomocou _Install > Style > Theme_ v ponuke Omarchy s použitím tejto URL. Odporúča sa dodržiavať konvenciu pomenovania `omarchy-[themename]-theme`, pretože téma sa po inštalácii v ponuke výberu tém správne zobrazí len ako `[themename]`.

Toto zvyšné `[themename]` sa stáva názvom adresára témy, takže musí byť takým, s ktorým môže Omarchy bezpečne narábať: musí začínať písmenom, číslicou alebo podčiarkovníkom a zvyšok môže obsahovať písmená, číslice, `.`, `_`, `+` a `-`. Veľké písmená sa za vás prevedú na malé, ale čokoľvek iné — medzera, úvodzovka, neanglický znak — sa pri inštalácii odmietne namiesto toho, aby sa premenilo na názov adresára. Takže `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` a `omarchy-c++-theme` sa všetky nainštalujú bez problémov.

Pamätajte, že keď sa téma nainštaluje z repozitára, akýkoľvek súbor `.lua`, konfigurácia terminálu alebo `vscode.json`, ktoré obsahuje, sa zahodí, takže tému nestavajte okolo nich.

Svoju tému môžete pridať na [stránku s ďalšími témami](https://omarchy.org/themes/) odoslaním pull requestu do [repozitára omarchy-site](https://github.com/omacom-io/omarchy-site).
