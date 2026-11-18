# Vývojářské nástroje

## Alternativní editory

Omarchy ve výchozím nastavení obsahuje [Neovim](https://neovim.io/), ale pokud chcete něco běžnějšího a známějšího, můžete spustit Omarchy Menu (`Super + Space`) a podívat se na možnosti v části _Install > Editor_. Máme tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Pokud nenajdete, co hledáte, podívejte se do _Install > Package_ a zjistěte, zda to náhodou není v balíčku Arch (a pokud ne, zkuste _Install > AUR_ a zkontrolujte AUR).

Původní editor `vi` je také k dispozici hned po instalaci. Spuštěním `vi filename` upravíte soubor v terminálu.

Ladění motivů je nabízeno pro `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Celý systémový výchozí editor můžete nastavit v části `Setup > Defaults > Editor`.

## Prostředí

Omarchy podporuje nastavení celé řady vývojových prostředí prostřednictvím části _Install > Development_ v Omarchy Menu (`Super + Space`). Samozřejmě tam najdete _Ruby on Rails_, ale také všechny tři hlavní běhové prostředí pro JavaScript (Node.js, Bun, Deno) a také populární PHP frameworky jako Laravel a Symfony. Ach, a je tam také Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure a Scala. Je to velmi široký výběr!

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

Váš uživatel ve výchozím nastavení *není* ve skupině `docker`. Tato skupina je v podstatě root bez hesla — cokoliv v ní může spustit `docker run -v /:/host` a převzít počítač — takže jediný škodlivý skript nebo závislost běžící pod vaším uživatelem by jinak byla jediný příkaz od root. Na příkazové řádce tedy Docker spouštíte pomocí `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, které komunikují s démonem — VM s Windows — si v případě potřeby vyžádají oprávnění. Pokud chcete zpět pohodlí nastavení bez skupiny a rozumíte kompromisu, povolte jej v části **Setup > Security > Sudoless Docker** (nebo spusťte `omarchy-setup-security-sudoless-docker`), čímž budete po varování přidáni do skupiny `docker`; pak prosté `docker` a alias `d` opět fungují bez `sudo`.

Běžné databáze pro lokální vývoj v Docker můžete nastavit pomocí _Install > Development > Docker DB_ v menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je k dispozici jako `gh` pro práci s repozitáři, issues a pull requesty z terminálu. Spuštěním `gh auth login` jej při prvním použití nainstalujete a ověříte se, poté repozitář naklonujete pomocí `gh repo clone org/repo`. Spuštěním `gh --help` prozkoumáte jeho příkazy.

Pro terminálové rozhraní k pull requestům spusťte `ghui`; mise jej také nainstaluje při prvním použití. [Lazygit](https://github.com/jesseduffield/lazygit) je předinstalovaný pro práci se samotným Gitem.
