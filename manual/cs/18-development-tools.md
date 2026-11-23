# Vývojářské nástroje

## Alternativní editory

Omarchy se na nových instalacích dodává s Plain jako výchozím editorem a s předinstalovaným [Neovim](https://neovim.io/), ale pokud byste chtěli něco trochu mainstreamovějšího a povědomějšího, můžete spustit Omarchy Menu (`Super + Space`) a podívat se na možnosti v části _Install > Editor_. Najdete tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Pokud nenajdete to, co hledáte, podívejte se do _Install > Package_ a zjistěte, zda to není v nějakém balíčku Arch (a pokud ne, zkuste _Install > AUR_ a zkontrolujte AUR).

Původní editor `vi` je také k dispozici hned po instalaci. Soubor v terminálu upravíte spuštěním `vi filename`.

Přizpůsobení motivu se nabízí pro `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Výchozí editor pro celý systém můžete nastavit v části `Setup > Defaults > Editor`.

## Prostředí

Omarchy podporuje nastavení celé řady vývojových prostředí prostřednictvím části _Install > Development_ v Omarchy Menu (`Super + Space`). Samozřejmě tam najdete _Ruby on Rails_, ale také všechny tři hlavní runtime pro JavaScript (Node.js, Bun, Deno), stejně jako populární PHP frameworky jako Laravel a Symfony. A je tam také Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure a Scala. Je to opravdu široký výběr!

Většinu těchto prostředí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, který vám umožňuje nainstalovat a spouštět více verzí programovacího jazyka na stejném počítači. Je to jako rbenv nebo rvm pro Ruby nebo virtualenv pro Python, ale funguje pro spoustu různých prostředí.

Chcete-li nainstalovat třeba Ruby, spustíte `mise use -g ruby`, čímž Ruby nainstalujete a zároveň nastavíte jako globální výchozí. Nebo pokud má váš projekt soubor .ruby-version, můžete v kořenovém adresáři tohoto projektu jednoduše spustit `mise i`.

## Předinstalované nástroje CLI

Omarchy zpřístupňuje nástroje jako `gh`, `uv` a většinu [kódovacích agentů](17-ai.md) prostřednictvím [líné instalace mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Při prvním spuštění některého z nich ho mise nainstaluje. Kódovací agenti pak před spuštěním kontrolují aktualizaci, nejvýše jednou za čtyři hodiny; ostatní nástroje, jako `gh` a `uv`, používají nainstalovanou verzi, dokud neprovedete aktualizaci.

Výchozí nastavení si také můžete prohlédnout nebo je nainstalovat předem:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Spuštěním `omarchy update` aktualizujete nainstalované nástroje spolu se zbytkem Omarchy. Alias `mup` aktualizuje pouze nástroje spravované mise. Chcete-li do vlastní konfigurace přidat další nástroj, použijte `mise use -g <tool>`.

Nastavení Pythonu také nainstaluje `uv` prostřednictvím mise. Odebráním vývojového prostředí Pythonu zůstane `uv` k dispozici jako nezávislý nástroj.

### Použití vlastní instalace

Příkazy mise mají na `PATH` přednost před `~/.local/bin`, takže nástroj, který jste si nainstalovali sami, například vlastním instalátorem Claude Code nebo Cursor, přesto spouští kopii od mise. Aplikace spouštěné z plochy také nacházejí příkazy mise před systémovými balíčky, takže aplikace, která spustí `gh`, dostane kopii od mise, i když jste `github-cli` nainstalovali pomocí pacman, a mise tuto kopii napoprvé nainstaluje. Chcete-li místo ní používat svou vlastní, zakažte kopii od mise v `~/.config/mise/config.toml`. Pokud jste si například sami nainstalovali Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Pokud už tabulku `[settings]` máte, přidejte záznam tam; existující seznam `disable_tools` rozšiřte, místo abyste ho nahrazovali. Ujistěte se, že vaše instalace je na `PATH`. Použijte název nástroje mise, který se může lišit od jeho příkazu: například `oh-my-pi` poskytuje `omp`. Spouštěč výchozího agenta také upřednostňuje uživatelem nainstalovaný Cursor nebo Muse v `~/.local/bin`.

### Odebrání a obnovení výchozích nastavení

_Remove > Preinstalls_ odebere předinstalované webové aplikace, TUI a aplikace Omarchy a způsobí, že mise pro vašeho uživatele přeskočí deklarace nástrojů Omarchy, a to jejich přidáním do `ignored_config_paths` v `~/.config/mise/miserc.toml`. _Install > Preinstalls_ je přivede zpět a tento řádek opět odebere. Nástroje, které si deklarujete sami, ve vlastní konfiguraci nebo v projektovém `mise.toml`, fungují dál v obou případech. Pokud si po odebrání předinstalací vyberete výchozího agenta nebo nastavíte Python, tento nástroj se přidá do vaší vlastní konfigurace. Nastavení mise platí pouze pro vašeho uživatele a ostatní uživatelé si ponechají vlastní volbu; aplikace jsou ale balíčky, takže jejich odebrání nebo obnovení je změní pro všechny na počítači.

## Docker

[Docker](https://www.docker.com/) sotva potřebuje nějaké představování. Umožňuje vám spouštět izolované kontejnery a Omarchy nainstaluje vše potřebné k jeho dobrému provozu, včetně samotného Dockeru a [Docker Compose](https://docs.docker.com/compose/).

Ve výchozím nastavení váš uživatel *není* ve skupině `docker`. Tato skupina je v podstatě root bez hesla — cokoliv v ní může spustit `docker run -v /:/host` a převzít počítač — takže jediný zlotřilý skript nebo závislost běžící pod vaším účtem by jinak byly od rootu vzdáleny jediný příkaz. Takže na příkazovém řádku spouštíte Docker pomocí `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, které komunikují s démonem — VM s Windows — si vyžádají autorizaci, když ji potřebují. Pokud chcete zpět pohodlí nastavení bez skupiny a rozumíte kompromisu, povolte ho z **Setup > Security > Sudoless Docker** (nebo spusťte `omarchy-setup-security-sudoless-docker`), což vás po varování přidá do skupiny `docker`; poté prosté `docker` a alias `d` opět fungují bez `sudo`.

Běžné databáze pro místní vývoj v Dockeru můžete nastavit pomocí _Install > Development > Docker DB_ v menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je k dispozici jako `gh` pro práci s repozitáři, issues a pull requesty z terminálu. Spuštěním `gh auth login` ho při prvním použití nainstalujete a ověříte se, poté pomocí `gh repo clone org/repo` naklonujete repozitář. Jeho příkazy prozkoumáte spuštěním `gh --help`.

Pro terminálové rozhraní k pull requestům spusťte `ghui`; mise ho také nainstaluje při prvním použití. [Lazygit](https://github.com/jesseduffield/lazygit) je předinstalovaný pro práci se samotným Gitem.
