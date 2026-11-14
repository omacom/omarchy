# Vytvoření vlastního motivu

Vlastní motivy můžete přidat do `~/.config/omarchy/themes`. Stačí zkopírovat některý z existujících jako základ (hledejte v `/usr/share/omarchy/themes`) a pak si ho upravit podle libosti. Dokud je váš motiv v této složce, objeví se v nabídce výběru motivů.

Hlavní soubor, který musíte upravit, je `colors.toml`. Ten definuje sadu barev, která se pak použije ke generování konfigurací pro terminál (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian a celé prostředí Omarchy (horní lišta, nabídka, oznámení, OSD a zamykací obrazovka).

Nový motiv můžete vytvořit také pomocí přiložené aplikace Aether, která nabízí příjemné GUI rozhraní pro hraní si s barvami a vyhledávání pozadí. Stačí ji spustit z mřížky aplikací pomocí `Super + Alt + Space`.

### Co může nainstalovaný motiv obsahovat

Motiv, který si sami napíšete do `~/.config/omarchy/themes`, může obsahovat cokoli chcete — je to váš počítač a váš soubor a Omarchy použije všechno.

Motiv, který nainstalujete z cizího repozitáře pomocí `omarchy theme install`, si zachová vše, co se týká barev, a ztratí hrstku souborů, které by na vašem počítači spouštěly kód: jakýkoli soubor `.lua`, konfigurace terminálu (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) a `vscode.json`. Soubor `hyprland.lua` motivu je Lua, kterou váš compositor spouští při přihlášení, konfigurace terminálu určuje program, který váš terminál spustí, a `vscode.json` určuje rozšíření VSCode, které se má nainstalovat. Instalace něčího motivu má změnit, jak vaše plocha vypadá, nikdy ne to, co spouští.

Vše ostatní dál funguje přesně tak, jak to autor motivu napsal — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, pozadí i náhledy zůstanou zachovány. Pouze to, co bylo vyřazeno, se na vašem počítači znovu vygeneruje z `colors.toml`.

Omarchy je od sebe odliší podle toho, zda má motiv uvnitř vlastní git repozitář, což je to, co `omarchy theme install` po klonování zanechá. Motiv, který jste napsali, tak zůstane váš a motiv stažený z internetu zůstane jen barvami.

### Světlý režim

Pokud vytváříte motiv ve světlém režimu, nastavte na začátek svého souboru `colors.toml` hodnotu `mode = "light"`. Pak se automaticky spáruje se světlým režimem pro všechny aplikace. (Starý způsob, kdy se do kořene motivu vložil prázdný soubor s názvem `light.mode`, stále funguje také.)

### Obrázek odemknutí

Motivy dodávané s obrázky `unlock.png` a `preview-unlock.png` budou uvedeny v části _Vzhled > Odemknutí_. Váš soubor `unlock.png` by měl být nejlépe průhledný png. A náhledový obrázek můžete vytvořit pomocí `omarchy plymouth preview`.

### Nastavení motivu aplikací, které Omarchy nepokrývá

Pokud používáte aplikaci, která v tomto seznamu není, můžete Omarchy naučit nastavovat její motiv sami pomocí šablony. Vložte soubor do `~/.config/omarchy/themed/` s názvem podle konfigurace, kterou generuje, plus příponou `.tpl`, a napište konfiguraci se zástupnými symboly `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` až `{{ color15 }}` a zbytkem palety. Při každé změně motivu se soubor znovu vygeneruje s barvami daného motivu.

V této složce je plně okomentovaný soubor `alacritty.toml.tpl.sample`, ze kterého můžete kopírovat — uvádí každou proměnnou, kterou můžete použít, plus modifikátory `_strip` a `_rgb` pro aplikace, které chtějí své barvy bez `#` nebo jako decimální RGB. Vaše šablony mají přednost před vlastními šablonami Omarchy, takže tak můžete také přepsat, jak se nastavuje motiv vestavěné aplikace.

### Distribuce vašeho motivu

Pokud chcete svůj motiv distribuovat, aby ho mohli používat ostatní, musíte ho umístit na veřejný git server, například GitHub. Pak si ho lidé mohou nainstalovat pomocí _Instalace > Styl > Motiv_ v nabídce Omarchy s použitím této URL. Doporučujeme dodržovat konvenci pojmenování `omarchy-[themename]-theme`, protože se motiv po instalaci v nabídce výběru motivů správně zobrazí jen jako `[themename]`.

Tento zbývající `[themename]` se stane názvem adresáře motivu, takže musí být takový, se kterým může Omarchy bezpečně pracovat: musí začínat písmenem, číslicí nebo podtržítkem a zbytek může obsahovat písmena, číslice, `.`, `_`, `+` a `-`. Velká písmena se pro vás převedou na malá, ale cokoli jiného — mezera, uvozovka, neanglický znak — bude při instalaci odmítnuto, místo aby se z toho stal název adresáře. Takže `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` se nainstalují bez problémů.

Nezapomeňte, že jakmile je motiv nainstalován z repozitáře, jakýkoli soubor `.lua`, konfigurace terminálu nebo `vscode.json`, který obsahuje, bude vyřazen, takže svůj motiv na nich nestavte.

Svůj motiv můžete nechat přidat na [stránku dalších motivů](https://omarchy.org/themes/) zasláním pull requestu do [repozitáře omarchy-site](https://github.com/omacom-io/omarchy-site).
