# Vývojářské nástroje

## Alternativní editory

Omarchy ve výchozím nastavení obsahuje [Neovim](https://neovim.io/), ale pokud chcete něco o něco mainstreamovějšího a známějšího, můžete spustit nabídku Omarchy (`Super + Space`) a podívat se na možnosti v části _Instalovat > Editor_. Najdete tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Pokud nenajdete, co hledáte, podívejte se do _Instalovat > Balíček_ a zjistěte, jestli to není v některém balíčku pro Arch (a pokud ne, zkuste _Instalovat > AUR_, kde AUR zkontrolujete).

Původní editor `vi` je také k dispozici rovnou po instalaci. Soubor v terminálu upravíte příkazem `vi filename`.

Sladění motivu je nabízeno pro `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Výchozí editor pro celý systém můžete nastavit v části `Setup > Defaults > Editor`.

## Prostředí

Omarchy podporuje nastavení celé řady vývojových prostředí prostřednictvím části _Instalovat > Vývoj_ v nabídce Omarchy (`Super + Space`). Najdete tu samozřejmě _Ruby on Rails_, ale také všechny tři hlavní běhové prostředí pro JavaScript (Node.js, Bun, Deno) a oblíbené frameworky PHP, jako jsou Laravel a Symfony. Aha, a nechybí Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure a Scala. Je to velmi široký výběr!

Většinu těchto prostředí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, který vám umožní nainstalovat a spouštět více verzí programovacího jazyka na jednom počítači. Je to jako rbenv nebo rvm pro Ruby nebo virtualenv pro Python, ale funguje pro řadu různých prostředí.

Chcete-li si nainstalovat například Ruby, spustíte příkaz `mise use -g ruby`, který Ruby nainstaluje a nastaví jako globální výchozí. Nebo pokud má váš projekt soubor .ruby-version, můžete v kořenovém adresáři daného projektu jednoduše spustit příkaz `mise i`.

## Docker

[Docker](https://www.docker.com/) snad ani nepotřebuje představovat. Umožňuje spouštět izolované kontejnery a Omarchy nainstaluje vše, co je potřeba k jeho bezproblémovému běhu, včetně samotného Dockeru a [Docker Compose](https://docs.docker.com/compose/).

Ve výchozím nastavení váš uživatel *není* ve skupině `docker`. Tato skupina je v podstatě rootem bez hesla — cokoliv v ní může spustit `docker run -v /:/host` a převzít počítač — takže jinak by jediný nepoctivý skript nebo závislost spuštěná pod vaším účtem byla jediný příkaz od roota. Takže na příkazovém řádku spouštíte Docker pomocí `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, které komunikují s démonem — virtuální počítač s Windows — si v případě potřeby vyžádají oprávnění. Pokud chcete pohodlí nastavení bez skupiny zpět a rozumíte kompromisu, povolte ho v části **Setup > Security > Sudoless Docker** (nebo spusťte příkaz `omarchy-setup-security-sudoless-docker`), který vás po varování přidá do skupiny `docker`; poté budou prosté `docker` a alias `d` opět fungovat bez `sudo`.

Běžné databáze pro místní vývoj v Dockeru můžete nastavit pomocí části _Instalovat > Vývoj > Docker DB_ v nabídce Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) umožňuje ověřovat se pomocí účtu GitHub a klonovat pomocí něho privátní repozitáře. Je zapojené jako jeden ze zástupných zástupců mise s líným načítáním, takže při prvním spuštění příkazu `gh` se samo nainstaluje. Pro ověření spusťte příkaz `gh auth login`. Poté můžete naklonovat privátní repozitáře pomocí příkazu `gh repo clone org/repo`.

Pomocí tohoto příkazu můžete provádět i řadu dalších operací na GitHubu. Stačí spustit příkaz `gh` a uvidíte vše, co je možné.

Existuje také zástupný zástupný příkaz s línou instalací pro `ghui`, který slouží ke správě vašich žádostí o stažení v TUI. A [lazygit](https://github.com/jesseduffield/lazygit) je předinstalovaný, pokud byste chtěli z TUI ovládat i samotný git.
