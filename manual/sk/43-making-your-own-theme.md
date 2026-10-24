# Vytvorenie vlastnej témy

Vlastné témy môžete pridávať do `~/.config/omarchy/themes`. Stačí skopírovať jednu z existujúcich tém ako základ (pozrite sa do `/usr/share/omarchy/themes`) a potom si ju upravte podľa svojho gusta. Pokiaľ je vaša téma vo vnútri toho priečinka, bude zahrnutá do ponuky výberu témy.

Hlavný súbor, ktorý musíte upraviť, je `colors.toml`. Ten definuje sadu farieb, ktorá sa potom používa na generovanie konfigurácií pre terminál (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian a celý shell Omarchy (horná lišta, ponuka, upozornenia, OSD a zamknutá obrazovka).

Môžete tiež použiť priloženú aplikáciu Aether na vytvorenie novej témy pomocou príjemného grafického rozhrania, v ktorom sa môžete hrať s farbami a hľadať pozadia. Stačí ju spustiť zo siete aplikácií skratkou `Super + Alt + Space`.

### Čo môže obsahovať nainštalovaná téma

Téma, ktorú si sami napíšete v `~/.config/omarchy/themes`, môže obsahovať, čokoľvek chcete — je to váš stroj a váš súbor a Omarchy použije všetko z toho.

Téma, ktorú si nainštalujete z repozitára niekoho iného príkazom `omarchy theme install`, si zachová všetko, čo je farba, a stratí tú hŕstku súborov, ktoré by na vašom stroji spúšťali kód: akýkoľvek súbor `.lua`, konfigurácie terminálu (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) a `vscode.json`. Súbor `hyprland.lua` témy je kód Lua, ktorý váš kompozitor spúšťa pri prihlásení, konfigurácia terminálu udáva program, ktorý váš terminál spúšťa, a `vscode.json` udáva rozšírenie VSCode, ktoré sa má nainštalovať. Inštalácia témy niekoho iného by mala zmeniť to, ako vaša pracovná plocha vyzerá, nikdy to, čo spúšťa.

Všetko ostatné naďalej funguje presne tak, ako to autor témy napísal — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, pozadia a ukážky zostávajú všetky zachované. Len to, čo bolo zahodené, sa na vašom stroji znova vygeneruje zo súboru `colors.toml`.

Omarchy ich rozlišuje podľa toho, či má téma vo vnútri vlastný git repozitár, čo je to, čo `omarchy theme install` zanechá po klonovaní. Takže téma, ktorú ste napísali, zostáva vašou, a tá, ktorú ste si stiahli z internetu, zostáva pri farbách.

### Svetlý režim

Ak vytvárate tému v svetlom režime, nastavte `mode = "light"` na začiatok svojho súboru `colors.toml`. Potom sa automaticky spáruje so svetlým režimom pre všetky aplikácie. (Starý spôsob, keď ste do koreňa svojej témy vložili prázdny súbor s názvom `light.mode`, stále funguje tiež.)

### Farby ikon

Ak chcete farebne zladiť ikony správcu súborov s vašou témou, pridajte súbor s názvom `icons.theme` s názvom sady ikon, ktorú chcete používať. Predvolene sú možnosti: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Obrázok na odomknutie

Témy dodávané s obrázkami `unlock.png` a `preview-unlock.png` budú uvedené v časti _Štýl > Odomknúť_. Váš súbor `unlock.png` by mal byť najlepšie priehľadný png. A ukážkový obrázok môžete vytvoriť príkazom `omarchy plymouth preview`.

### Tematizácia aplikácií, ktoré Omarchy nepokrýva

Ak používate aplikáciu, ktorá nie je v tom zozname, môžete Omarchy naučiť, aby ju tematizoval sám, pomocou šablóny. Vložte súbor do `~/.config/omarchy/themed/` pomenovaný podľa konfigurácie, ktorú generuje, plus príponu `.tpl`, a napíšte konfiguráciu so zástupnými symbolmi `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` až `{{ color15 }}` a zvyšok palety. Zakaždým, keď prepnete témy, súbor sa znova vygeneruje s farbami danej témy.

V tom priečinku je plne okomentovaný súbor `alacritty.toml.tpl.sample`, z ktorého môžete kopírovať — uvádza každú premennú, ktorú môžete použiť, plus modifikátory `_strip` a `_rgb` pre aplikácie, ktoré chcú svoje farby bez `#` alebo ako desatinné RGB. Vaše šablóny majú prednosť pred vlastnými šablónami Omarchy, takže toto môžete použiť aj na prepísanie toho, ako sa tematizuje vstavaná aplikácia.

### Distribúcia vašej témy

Ak chcete svoju tému distribuovať, aby ju mohli používať aj ostatní, musíte ju umiestniť na verejný git server, napríklad GitHub. Potom si ju ľudia môžu nainštalovať cez _Inštalovať > Style > Theme_ v ponuke Omarchy pomocou tej adresy URL. Odporúča sa, aby ste dodržali konvenciu pomenovania `omarchy-[themename]-theme`, keďže téma sa po inštalácii v ponuke výberu témy správne zobrazí ako len `[themename]`.

Ten zvyšný `[themename]` sa stane názvom adresára témy, takže musí byť taký, ktorý Omarchy dokáže bezpečne odovzdávať ďalej: musí začínať písmenom, číslicou alebo podčiarkovníkom a zvyšok môže obsahovať písmená, číslice, `.`, `_`, `+` a `-`. Veľké písmená sa pre vás premenia na malé, ale čokoľvek iné — medzera, úvodzovka, neanglický znak — sa pri inštalácii odmietne, namiesto toho, aby sa premenilo na názov adresára. Takže `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` a `omarchy-c++-theme` sa všetky nainštalujú v poriadku.

Pamätajte, že akonáhle sa nainštaluje z repozitára, akýkoľvek súbor `.lua`, konfigurácia terminálu alebo `vscode.json`, ktorý dodáva, sa zahodí, takže tému okolo nich nebudujte.

Vašu tému môžete pridať na [stránku s ďalšími témami](https://omarchy.org/themes/) zaslaním pull requestu do [repozitára omarchy-site](https://github.com/omacom-io/omarchy-site).
