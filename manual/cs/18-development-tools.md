# Vývojářské nástroje

## Alternativní editory

Omarchy ve výchozím nastavení obsahuje [Neovim](https://neovim.io/), ale pokud chcete něco běžnějšího a známějšího, můžete spustit Omarchy Menu (`Super + Space`) a podívat se na možnosti v části _Install > Editor_. Máme tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Pokud nenajdete, co hledáte, podívejte se do _Install > Package_ a zjistěte, zda to náhodou není v balíčku Arch (a pokud ne, zkuste _Install > AUR_ a zkontrolujte AUR).

Původní editor `vi` je také k dispozici hned po instalaci. Spuštěním `vi filename` upravíte soubor v terminálu.

Ladění motivů je nabízeno pro `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Celý systémový výchozí editor můžete nastavit v části `Setup > Defaults > Editor`.

## Prostředí

Omarchy podporuje nastavení celé řady vývojových prostředí prostřednictvím části _Instalovat > Vývoj_ v nabídce Omarchy (`Super + Space`). Najdete tu samozřejmě _Ruby on Rails_, ale také všechna tři hlavní běhová prostředí pro JavaScript (Node.js, Bun, Deno) a oblíbené frameworky PHP, jako jsou Laravel a Symfony. Aha, a nechybí Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure a Scala. Je to velmi široký výběr!

Většinu těchto prostředí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, který vám umožňuje nainstalovat a spouštět více verzí programovacího jazyka na stejném počítači. Je to jako rbenv nebo rvm pro Ruby nebo virtualenv pro Python, ale funguje pro celou řadu různých prostředí.

Chcete-li nainstalovat například Ruby, spustíte `mise use -g ruby`, čímž Ruby nainstalujete i nastavíte jako globální výchozí. Nebo pokud váš projekt obsahuje soubor .ruby-version, můžete v kořenovém adresáři tohoto projektu jednoduše spustit `mise i`.

## Předinstalované nástroje CLI

Omarchy zpřístupňuje nástroje jako `gh`, `uv` a většinu [kódovacích agentů](17-ai.md) prostřednictvím [líné instalace mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Při prvním spuštění některého z nich jej mise nainstaluje. Při dalších spuštěních se znovu použije nainstalovaná verze; při každém spuštění se nekontroluje aktualizace.

Můžete si také prohlédnout výchozí nastavení nebo si je nainstalovat předem:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Spuštěním `omarchy update` aktualizujete nainstalované nástroje spolu se zbytkem Omarchy. Alias `mup` aktualizuje pouze nástroje spravované mise. Chcete-li do vlastní konfigurace přidat další nástroj, použijte `mise use -g <tool>`.

Nastavení Pythonu také nainstaluje `uv` prostřednictvím mise. Odebráním vývojového prostředí Pythonu zůstane `uv` k dispozici jako nezávislý nástroj.

### Použití vlastní instalace

Příkazy mise jsou na `PATH` před `~/.local/bin`, takže nástroj, který jste si nainstalovali sami, například pomocí vlastního instalačního programu Claude Code nebo Cursor, přesto spouští kopii od mise. Aplikace spuštěné z plochy také nacházejí příkazy mise před systémovými balíčky, takže aplikace, která spouští `gh`, získá kopii od mise, i když jste si `github-cli` nainstalovali pomocí pacman, a mise ji při prvním spuštění nainstaluje. Chcete-li místo toho použít vlastní kopii, zakažte kopii od mise v souboru `~/.config/mise/config.toml`. Například pokud jste si Cursor CLI nainstalovali sami:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Pokud už tabulku `[settings]` máte, přidejte záznam do ní; stávající seznam `disable_tools` rozšiřte, místo abyste jej nahrazovali. Ujistěte se, že je vaše instalace na `PATH`. Použijte název nástroje mise, který se může lišit od jeho příkazu: například `oh-my-pi` poskytuje `omp`. Spouštěč výchozího agenta také upřednostňuje uživatelem nainstalovaný Cursor nebo Muse v `~/.local/bin`.

### Odebrání a obnovení výchozích hodnot

_Remove Preinstalls_ zařídí, že mise pro vašeho uživatele přeskočí deklarace nástrojů Omarchy, a to tak, že je přidá do `ignored_config_paths` v souboru `~/.config/mise/miserc.toml`. _Restore Preinstalls_ tento řádek opět odstraní. Nástroje, které si deklarujete sami, ve vlastní konfiguraci nebo v projektovém souboru `mise.toml`, fungují tak jako tak dál. Pokud po odebrání předinstalací zvolíte výchozího agenta nebo nastavíte Python, daný nástroj se přidá do vaší vlastní konfigurace. Obojí platí pouze pro vašeho uživatele; ostatní uživatelé na počítači si zachovají svou vlastní volbu.

## Docker

[Docker](https://www.docker.com/) sotva potřebuje nějaké představování. Umožňuje vám spouštět izolované kontejnery a Omarchy nainstaluje vše potřebné k jeho dobrému běhu, včetně samotného Docker a [Docker Compose](https://docs.docker.com/compose/).

Ve výchozím nastavení váš uživatel *není* ve skupině `docker`. Členství v ní v podstatě poskytuje oprávnění root bez hesla: příkaz `docker run -v /:/host` umožní převzít kontrolu nad počítačem. Stačil by tak jediný škodlivý skript nebo závislost spuštěná pod vaším účtem. Proto v terminálu používáte `sudo` (`sudo docker ps`, `sudo docker compose up`). Grafické nástroje, například virtuální počítač s Windows, si potřebná oprávnění vyžádají samy. Pokud riziku rozumíte a chcete Docker používat bez sudo, povolte **Nastavení > Zabezpečení > Docker bez sudo** nebo spusťte `omarchy-setup-security-sudoless-docker`. Po varování vás přidá do skupiny `docker`; samotný příkaz `docker` i alias `d` pak budou fungovat bez `sudo`.

Běžné databáze pro lokální vývoj v Docker můžete nastavit pomocí _Install > Development > Docker DB_ v menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je k dispozici jako příkaz `gh` pro práci s repozitáři, issues a pull requesty z terminálu. Příkaz `gh auth login` ho při prvním použití nainstaluje a přihlásí vás. Repozitář pak naklonujete pomocí `gh repo clone org/repo`. Příkaz `gh --help` vypíše všechny jeho příkazy.

Pro práci s pull requesty v terminálovém rozhraní spusťte `ghui`; mise ho také nainstaluje při prvním použití. Pro práci se samotným Gitem je předinstalovaný [lazygit](https://github.com/jesseduffield/lazygit).
