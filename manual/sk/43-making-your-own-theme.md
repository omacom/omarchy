# Vytvorenie vlastnej témy

Vlastné témy môžete pridať do `~/.config/omarchy/themes`. Jednoducho si ako základ skopírujte niektorú z existujúcich tém (pozrite sa do `/usr/share/omarchy/themes`) a potom ju upravte podľa svojich predstáv. Pokiaľ bude vaša téma v tomto priečinku, objaví sa v ponuke na výber témy.

Hlavný súbor, ktorý musíte upraviť, je `colors.toml`. Ten definuje sadu farieb, ktorá sa potom použije na vygenerovanie konfigurácií pre terminál (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian a celé prostredie Omarchy (horná lišta, ponuka, oznámenia, OSD a uzamykacia obrazovka).

Na vytvorenie novej témy môžete použiť aj priloženú aplikáciu Aether s pôvabným GUI rozhraním, v ktorom sa môžete hrať s farbami a vyhľadávať pozadia. Jednoducho ju spustite z mriežky aplikácií pomocou `Super + Alt + Space`.

### Čo môže obsahovať nainštalovaná téma

Téma, ktorú si sami napíšete v `~/.config/omarchy/themes`, môže obsahovať, čokoľvek chcete — je to váš počítač a váš súbor a Omarchy použije všetko z nej.

Téma, ktorú si nainštalujete z cudzieho repozitára pomocou `omarchy theme install`, si zachová všetko, čo sa týka farieb, a stratí hŕstku súborov, ktoré by na vašom počítači spúšťali kód: akýkoľvek súbor `.lua`, konfigurácie terminálu (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) a `vscode.json`. `hyprland.lua` témy je Lua, ktoré váš kompozitor spúšťa pri prihlásení, konfigurácia terminálu uvádza program, ktorý váš terminál spúšťa, a `vscode.json` uvádza rozšírenie VSCode, ktoré sa má nainštalovať. Inštalácia cudzej témy má zmeniť vzhľad vašej pracovnej plochy, nikdy nie to, čo sa na nej spúšťa.

Všetko ostatné naďalej funguje presne tak, ako to autor témy napísal — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, pozadia aj ukážky zostávajú zachované. Len to, čo bolo vynechané, sa na vašom počítači znovu vygeneruje z `colors.toml`.

Omarchy ich od seba rozlišuje podľa toho, či má téma vo vnútri vlastný git repozitár, čo je to, čo po sebe zanechá `omarchy theme install`, keď repozitár naklonuje. Téma, ktorú ste napísali vy, tak zostane vaša a tá, ktorú ste si stiahli z internetu, zostane len farbami.

### Svetlý režim

Ak vytvárate tému so svetlým režimom, nastavte na začiatku súboru `colors.toml` hodnotu `mode = "light"`. Potom sa automaticky spáruje so svetlým režimom pre všetky aplikácie. (Starý spôsob, teda vloženie prázdneho súboru s názvom `light.mode` do koreňového priečinka témy, stále funguje tiež.)

### Farby ikon

Ak chcete farebne zladiť ikony správcu súborov so svojou témou, pridajte súbor s názvom `icons.theme` obsahujúci názov sady ikon, ktorú chcete použiť. Predvolene sú k dispozícii tieto možnosti: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Obrázok odomknutia

Témy dodávané s obrázkami `unlock.png` a `preview-unlock.png` budú uvedené v časti _Vzhľad > Odomknutie_. Váš `unlock.png` by mal byť najlepšie priehľadný png. A ukážkový obrázok môžete vytvoriť pomocou `omarchy plymouth preview`.

### Témovanie aplikácií, ktoré Omarchy nepokrýva

Ak používate aplikáciu, ktorá nie je v tomto zozname, môžete Omarchy naučiť témovať ju sami pomocou šablóny. Vložte do `~/.config/omarchy/themed/` súbor pomenovaný podľa konfigurácie, ktorú generuje, s príponou `.tpl` a napíšte konfiguráciu s použitím `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` až `{{ color15 }}` a zvyšku palety ako zástupných symbolov. Pri každom prepnutí témy sa súbor znovu vygeneruje s farbami danej témy.

V tomto priečinku nájdete plne okomentovaný súbor `alacritty.toml.tpl.sample`, z ktorého môžete vychádzať — uvádza všetky premenné, ktoré môžete použiť, plus modifikátory `_strip` a `_rgb` pre aplikácie, ktoré chcú svoje farby bez `#` alebo ako desiatkové RGB. Vaše šablóny majú prednosť pred vlastnými šablónami Omarchy, takže to môžete použiť aj na prepísanie spôsobu, akým sa témuje vstavaná aplikácia.

### Distribúcia vašej témy

Ak chcete svoju tému distribuovať, aby ju mohli používať aj ostatní, musíte ju umiestniť na verejný git server, napríklad GitHub. Potom si ju ľudia môžu nainštalovať pomocou _Inštalácia > Štýl > Téma_ v ponuke Omarchy s použitím tejto URL. Odporúča sa dodržiavať konvenciu pomenovania `omarchy-[themename]-theme`, pretože sa téma po inštalácii v ponuke na výber témy správne zobrazí len ako `[themename]`.

Tento zvyšný `[themename]` sa stane názvom priečinka témy, takže musí ísť o názov, ktorý Omarchy môže bezpečne odovzdávať ďalej: musí začínať písmenom, číslicou alebo podčiarkovníkom a zvyšok môže obsahovať písmená, číslice, `.`, `_`, `+` a `-`. Veľké písmená sa za vás prevedú na malé, ale čokoľvek iné — medzera, úvodzovka, neanglický znak — sa pri inštalácii odmietne, namiesto toho, aby sa z toho stal názov priečinka. Takže `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` aj `omarchy-c++-theme` sa nainštalujú bez problémov.

Pamätajte, že akonáhle sa téma nainštaluje z repozitára, akékoľvek súbory `.lua`, konfigurácia terminálu alebo `vscode.json`, ktoré obsahuje, sa vynechajú, takže tému okolo nich nestavajte.

Svoju tému môžete pridať na [stránku s ďalšími témami](https://omarchy.org/themes/) zaslaním pull requestu do [repozitára omarchy-site](https://github.com/omacom-io/omarchy-site).
