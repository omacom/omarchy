# Vytvoření vlastního motivu

Vlastní motivy můžete přidat do `~/.config/omarchy/themes`. Prostě si jako základ zkopírujte jeden z existujících motivů (podívejte se do `/usr/share/omarchy/themes`) a pak si ho upravte podle libosti. Dokud bude váš motiv uvnitř této složky, objeví se v nabídce výběru motivů.

Hlavní soubor, který musíte upravit, je `colors.toml`. Ten definuje sadu barev, která se pak použije ke generování konfigurací pro terminál (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian a celé prostředí Omarchy (horní lištu, nabídku, oznámení, OSD a zamykací obrazovku).

Nový motiv můžete vytvořit také pomocí přiložené aplikace Aether, která nabízí příjemné GUI rozhraní pro hraní si s barvami a vyhledávání pozadí. Stačí ji spustit z mřížky aplikací pomocí `Super + Alt + Space`.

### Co může nainstalovaný motiv obsahovat

Motiv, který si sami napíšete do `~/.config/omarchy/themes`, může obsahovat cokoli chcete — je to váš počítač a váš soubor a Omarchy použije všechno.

Motiv, který nainstalujete z cizího repozitáře pomocí `omarchy theme install`, si zachová vše, co se týká barev, a ztratí hrstku souborů, které by na vašem počítači spouštěly kód: jakýkoli soubor `.lua`, konfigurace terminálu (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) a `vscode.json`. Soubor `hyprland.lua` motivu je Lua, kterou váš compositor spouští při přihlášení, konfigurace terminálu pojmenovává program, který váš terminál spustí, a `vscode.json` pojmenovává rozšíření VSCode, které se má nainstalovat. Instalace něčího motivu by měla změnit, jak vaše plocha vypadá, nikdy ne to, co spouští.

Vše ostatní dál funguje přesně tak, jak to autor motivu napsal — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, pozadí i náhledy zůstanou zachovány. Pouze to, co bylo vynecháno, se na vašem počítači znovu vygeneruje z `colors.toml`.

Omarchy tyto dva případy rozlišuje podle toho, zda má motiv uvnitř vlastní git repozitář, což je to, co po sobě `omarchy theme install` při klonování zanechá. Motiv, který jste napsali vy, tak zůstane váš a motiv, který jste stáhli z internetu, zůstane jen barvami.

### Světlý režim

Pokud vytváříte motiv ve světlém režimu, nastavte na začátek svého `colors.toml` hodnotu `mode = "light"`. Pak se automaticky spáruje se světlým režimem pro všechny aplikace. (Starý způsob, kdy se do kořene motivu vložil prázdný soubor s názvem `light.mode`, stále funguje také.)

### Barvy ikon

Pokud chcete barevně sladit ikony správce souborů se svým motivem, přidejte soubor s názvem `icons.theme` obsahující název sady ikon, kterou chcete použít. Ve výchozím nastavení jsou k dispozici tyto možnosti: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Obrázek odemykací obrazovky

Motivy dodávané s obrázky `unlock.png` a `preview-unlock.png` budou uvedeny v části _Appearance > Unlock_. Váš soubor `unlock.png` by měl být nejlépe průhledný png. Náhledový obrázek můžete vytvořit pomocí `omarchy plymouth preview`.

### Motivy pro aplikace, které Omarchy nepokrývá

Pokud používáte aplikaci, která v tomto seznamu není, můžete Omarchy naučit upravovat její motiv sami pomocí šablony. Vložte do `~/.config/omarchy/themed/` soubor pojmenovaný podle konfigurace, kterou generuje, s příponou `.tpl`, a konfiguraci napište s zástupnými symboly `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` až `{{ color15 }}` a zbytkem palety. Pokaždé, když přepnete motiv, soubor se znovu vygeneruje s barvami daného motivu.

V této složce najdete plně okomentovaný soubor `alacritty.toml.tpl.sample`, ze kterého můžete vycházet — uvádí každou proměnnou, kterou můžete použít, a také modifikátory `_strip` a `_rgb` pro aplikace, které chtějí své barvy bez `#` nebo jako desetinné RGB. Vaše šablony mají přednost před těmi od Omarchy, takže je můžete použít i k přepsání způsobu, jakým se upravuje motiv některé integrované aplikace.

### Distribuce vašeho motivu

Pokud chcete svůj motiv distribuovat, aby ho mohli používat ostatní, musíte ho umístit na veřejný git server, například GitHub. Lidé si ho pak mohou nainstalovat pomocí _Install > Style > Theme_ v nabídce Omarchy s použitím dané URL. Doporučuje se dodržovat konvenci pojmenování `omarchy-[themename]-theme`, protože motiv se po instalaci v nabídce výběru motivů správně zobrazí jen jako `[themename]`.

Tento zbývající `[themename]` se stane názvem adresáře motivu, takže musí jít o název, se kterým Omarchy může bezpečně pracovat: musí začínat písmenem, číslicí nebo podtržítkem a zbytek může obsahovat písmena, číslice, `.`, `_`, `+` a `-`. Velká písmena se pro vás převedou na malá, ale cokoli jiného — mezera, uvozovka, neanglický znak — bude při instalaci odmítnuto, místo aby se z toho stal název adresáře. `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` se tedy nainstalují bez problémů.

Pamatujte, že jakmile se motiv nainstaluje z repozitáře, jakýkoli soubor `.lua`, konfigurace terminálu nebo `vscode.json`, které obsahuje, bude vynechán, takže motiv na nich nestavte.

Svůj motiv můžete nechat přidat na [stránku s dalšími motivy](https://omarchy.org/themes/) zasláním pull requestu do [repozitáře omarchy-site](https://github.com/omacom-io/omarchy-site).
