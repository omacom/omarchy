# Vytvoření vlastního motivu

Vlastní motivy můžete přidat do `~/.config/omarchy/themes`. Stačí jako základ zkopírovat některý z existujících (podívejte se do `/usr/share/omarchy/themes`) a pak si ho upravit podle libosti. Dokud bude váš motiv v této složce, objeví se v nabídce pro výběr motivu.

Hlavní soubor, který musíte upravit, je `colors.toml`. Ten definuje sadu barev, která se pak používá ke generování konfigurací pro terminál (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplikace Qt, podsvícení klávesnice, metodu zadávání, výběr pro sdílení obrazovky, ikony aplikací, několik nástrojů AI (Claude, Pi, Hermes, T3 Code, Herdr) a celé prostředí Omarchy (horní lištu, nabídku, oznámení, OSD a zamykací obrazovku).

Nový motiv můžete vytvořit také v přiložené aplikaci Aether, která nabízí příjemné grafické rozhraní, kde si můžete hrát s barvami a vyhledávat pozadí. Stačí ji spustit z přehledu aplikací pomocí `Super + Alt + Space`.

### Co může obsahovat nainstalovaný motiv

Motiv, který si sami napíšete do `~/.config/omarchy/themes`, může obsahovat cokoli chcete — je to váš počítač a váš soubor a Omarchy použije všechno.

Motiv, který si nainstalujete z cizího repozitáře pomocí `omarchy theme install`, si zachová vše, co se týká barev, a přijde o těch několik souborů, které by na vašem počítači spouštěly kód: jakýkoli soubor `.lua`, konfigurace terminálu (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) a `vscode.json`. Soubor `hyprland.lua` motivu je Lua, kterou váš kompozitor spouští při přihlášení, konfigurace terminálu určuje program, který váš terminál spustí, a `vscode.json` určuje rozšíření VSCode, které se má nainstalovat. Instalace cizího motivu má změnit, jak vaše pracovní plocha vypadá, nikdy ne to, co spouští.

Všechno ostatní dál funguje přesně tak, jak to autor motivu napsal — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, pozadí i náhledy zůstávají zachované. Jen to, co bylo vynecháno, se na vašem počítači znovu vygeneruje z `colors.toml`.

Omarchy ty dva případy rozlišuje podle toho, zda má motiv uvnitř vlastní repozitář git, který po sobě `omarchy theme install` při klonování zanechá. Motiv, který jste napsali vy, tak zůstává váš a motiv, který jste stáhli z internetu, zůstává jen u barev.

### Světlý režim

Pokud vytváříte motiv ve světlém režimu, nastavte na začátek svého `colors.toml` hodnotu `mode = "light"`. Pak se automaticky spáruje se světlým režimem pro všechny aplikace. (Starý způsob, kdy do kořene motivu vložíte prázdný soubor s názvem `light.mode`, funguje také.)

### Obrazovky při spuštění a přihlášení

Obrazovka, která při spuštění žádá heslo k disku, a přihlašovací obrazovka kreslí logo Omarchy v barvě `accent` vašeho motivu na jeho `background`, s polem pro heslo v barvě `foreground` a s barvou `red` pro špatné heslo. Nemusíte pro ně dodávat nic navíc: Omarchy už nepoužívá soubory `unlock.png` ani `preview-unlock.png` motivu. Na počítačích Mac s Apple Silicon si obrazovka pro heslo k disku bez ohledu na motiv zachovává výchozí vzhled Omarchy.

### Motivy pro aplikace, které Omarchy nepokrývá

Pokud používáte aplikaci, která v tomto seznamu není, můžete Omarchy naučit upravovat její vzhled sami pomocí šablony. Do `~/.config/omarchy/themed/` vložte soubor pojmenovaný podle konfigurace, kterou generuje, s příponou `.tpl`, a konfiguraci napište se zástupnými symboly `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` až `{{ color15 }}` a zbytkem palety. Pokaždé, když přepnete motiv, soubor se znovu vygeneruje s barvami daného motivu.

V této složce najdete plně okomentovaný soubor `alacritty.toml.tpl.sample`, ze kterého můžete vycházet — uvádí každou proměnnou, kterou můžete použít, plus modifikátory `_strip` a `_rgb` pro aplikace, které chtějí své barvy bez `#` nebo jako decimální RGB. Vaše šablony mají přednost před těmi od Omarchy, takže tímto způsobem můžete také přepsat, jak se upravuje vzhled některé vestavěné aplikace.

### Šíření vašeho motivu

Pokud chcete svůj motiv šířit, aby ho mohli používat ostatní, musíte ho umístit na veřejný server git, například GitHub. Lidé si ho pak mohou nainstalovat pomocí _Instalace > Styl > Motiv_ v nabídce Omarchy s použitím dané URL. Doporučuje se dodržet konvenci pojmenování `omarchy-[themename]-theme`, protože se motiv po instalaci v nabídce pro výběr motivu správně zobrazí jen jako `[themename]`.

Tento zbývající název `[themename]` se stane názvem adresáře motivu, takže musí být takový, který může Omarchy bezpečně předávat dál: musí začínat písmenem, číslicí nebo podtržítkem a zbytek může obsahovat písmena, číslice, `.`, `_`, `+` a `-`. Velká písmena se za vás převedou na malá, ale cokoli jiného — mezera, uvozovka, neanglický znak — bude při instalaci odmítnuto, místo aby se z toho stal název adresáře. Takže `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` se nainstalují bez problémů.

Pamatujte, že jakmile se motiv nainstaluje z repozitáře, všechny soubory `.lua`, konfigurace terminálu nebo `vscode.json`, které obsahuje, budou vynechány, takže svůj motiv na nich nestavte.

Svůj motiv můžete nechat přidat na [stránku s dalšími motivy](https://omarchy.org/themes/) zasláním pull requestu do [repozitáře omarchy-site](https://github.com/omacom-io/omarchy-site).
