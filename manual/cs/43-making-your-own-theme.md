# Vytvoření vlastního motivu

Vlastní motivy můžete přidávat do `~/.config/omarchy/themes`. Stačí zkopírovat některý z existujících jako základ (podívejte se do `/usr/share/omarchy/themes`) a pak si ho upravit podle libosti. Dokud je váš motiv uvnitř té složky, bude zahrnut v nabídce pro výběr motivu.

Hlavní soubor, který musíte upravit, je `colors.toml`. Ten definuje sadu barev, která se pak použije ke generování konfigurací pro terminál (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt aplikace, podsvícení klávesnice, metodu zadávání, výběr pro sdílení obrazovky, ikony aplikací, několik AI nástrojů (Claude, Pi, Hermes, T3 Code, Herdr) a celé prostředí Omarchy (horní lišta, nabídka, oznámení, OSD a zamykací obrazovka).

K vytvoření nového motivu můžete také použít přiloženou aplikaci Aether s půvabným GUI rozhraním, ve kterém si můžete hrát s barvami a vyhledávat pozadí. Stačí ji spustit z mřížky aplikací pomocí `Super + Alt + Space`.

### Co může nainstalovaný motiv obsahovat

Motiv, který si sami napíšete do `~/.config/omarchy/themes`, může obsahovat, co se vám zlíbí — je to váš stroj a váš soubor a Omarchy použije všechno.

Motiv, který nainstalujete z cizího repozitáře pomocí `omarchy theme install`, si zachová vše, co se týká barev, a přijde o hrstku souborů, které by na vašem stroji spouštěly kód: jakýkoli soubor `.lua`, konfigurace terminálu (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) a `vscode.json`. `hyprland.lua` motivu je Lua, kterou váš compositor spouští při přihlášení, konfigurace terminálu určuje program, který váš terminál spouští, a `vscode.json` určuje rozšíření VSCode, které se má nainstalovat. Instalace něčího motivu by měla změnit, jak vaše plocha vypadá, nikdy ne to, co spouští.

Všechno ostatní dál funguje přesně tak, jak to autor motivu napsal — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, pozadí i náhledy zůstanou zachovány. Pouze to, co bylo vyřazeno, se na vašem stroji znovu vygeneruje z `colors.toml`.

Omarchy je od sebe rozlišuje podle toho, zda má motiv uvnitř vlastní git repozitář, což je to, co po sobě `omarchy theme install` při klonování zanechá. Motiv, který jste napsali, tak zůstane váš a ten, který jste stáhli z internetu, zůstane jen barvami.

### Světlý režim

Pokud vytváříte motiv ve světlém režimu, nastavte na začátek svého `colors.toml` `mode = "light"`. Pak bude automaticky spárován se světlým režimem pro všechny aplikace. (Starý způsob, tedy vložení prázdného souboru s názvem `light.mode` do kořene motivu, funguje také.)

### Obrázek pro odemknutí

Motivy dodávané s obrázky `unlock.png` a `preview-unlock.png` budou uvedeny v části _Vzhled > Odemknutí_. Váš `unlock.png` by měl být nejlépe průhledný png. A náhledový obrázek můžete vytvořit pomocí `omarchy plymouth preview`.

### Motivy pro aplikace, které Omarchy nepokrývá

Pokud používáte aplikaci, která v tom seznamu není, můžete Omarchy naučit, jak pro ni vytvořit motiv, sami pomocí šablony. Vložte do `~/.config/omarchy/themed/` soubor pojmenovaný podle konfigurace, kterou generuje, plus příponu `.tpl`, a napište konfiguraci s `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` až `{{ color15 }}` a zbytkem palety jako zástupnými symboly. Pokaždé, když přepnete motivy, se soubor znovu vygeneruje s barvami daného motivu.

V té složce je plně okomentovaný soubor `alacritty.toml.tpl.sample`, ze kterého můžete vycházet — uvádí každou proměnnou, kterou můžete použít, plus modifikátory `_strip` a `_rgb` pro aplikace, které chtějí své barvy bez `#` nebo jako desítkové RGB. Vaše šablony mají přednost před vlastními šablonami Omarchy, takže to můžete využít i k tomu, abyste přepsali, jak se motiv vytváří pro vestavěnou aplikaci.

### Distribuce vašeho motivu

Pokud chcete svůj motiv distribuovat, aby ho mohli používat ostatní, musíte ho umístit na veřejný git server, jako je GitHub. Pak si ho lidé mohou nainstalovat pomocí _Instalace > Styl > Motiv_ v nabídce Omarchy s použitím té URL. Doporučuje se dodržovat konvenci pojmenování `omarchy-[themename]-theme`, protože se motiv po instalaci v nabídce pro výběr motivu správně zobrazí jen jako `[themename]`.

Tento zbývající `[themename]` se stane názvem adresáře motivu, takže musí být takový, který Omarchy může bezpečně předávat dál: musí začínat písmenem, číslicí nebo podtržítkem a zbytek může obsahovat písmena, číslice, `.`, `_`, `+` a `-`. Velká písmena se pro vás převedou na malá, ale cokoli jiného — mezera, uvozovka, neanglický znak — bude při instalaci odmítnuto, místo aby se z toho stal název adresáře. Takže `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` se nainstalují bez problémů.

Pamatujte, že jakmile je nainstalován z repozitáře, jakékoli `.lua`, konfigurace terminálu nebo `vscode.json`, které obsahuje, bude vyřazeno, takže na nich motiv nestavte.

Svůj motiv můžete nechat přidat na [stránku s dalšími motivy](https://omarchy.org/themes/) zasláním pull requestu do [repozitáře omarchy-site](https://github.com/omacom-io/omarchy-site).
