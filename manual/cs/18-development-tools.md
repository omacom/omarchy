# Vývojářské nástroje

## Alternativní editory

Omarchy se na nových instalacích dodává s Plain jako výchozím editorem a s předinstalovaným [Neovim](https://neovim.io/), ale pokud chcete něco o něco běžnějšího a známějšího, můžete spustit Omarchy Menu (`Super + Space`) a podívat se na možnosti v _Install > Editor_. Najdete tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Pokud nenajdete, co hledáte, podívejte se do _Install > Package_ a zjistěte, zda to není v některém balíčku Arch (a pokud ne, zkuste _Install > AUR_ a zkontrolujte AUR).

Původní editor `vi` je také k dispozici hned po instalaci. Soubor v terminálu upravíte spuštěním `vi filename`.

Sladění motivu se nabízí pro `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Výchozí editor pro celý systém můžete nastavit v `Setup > Defaults > Editor`.

## Prostředí

Omarchy podporuje nastavení celé řady vývojových prostředí prostřednictvím sekce _Install > Development_ v Omarchy Menu (`Super + Space`). Samozřejmě tam najdete _Ruby on Rails_, ale také všechny tři hlavní běhové prostředí pro JavaScript (Node.js, Bun, Deno), stejně jako oblíbené PHP frameworky jako Laravel a Symfony. Jo, a je tam také Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure a Scala. Je to opravdu široký výběr!

Většinu těchto prostředí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, který vám umožňuje nainstalovat a spouštět více verzí programovacího jazyka na stejném počítači. Je to jako rbenv nebo rvm pro Ruby nebo virtualenv pro Python, ale funguje pro celou řadu různých prostředí.

Chcete-li nainstalovat třeba Ruby, spustíte `mise use -g ruby`, čímž Ruby nainstalujete a zároveň nastavíte jako globální výchozí. Nebo pokud má váš projekt soubor .ruby-version, můžete v kořenu tohoto projektu prostě spustit `mise i`.

## Předinstalované nástroje CLI

`uv`, Node.js a `playwright-cli` (aby agenti mohli ovládat prohlížeč pomocí nainstalovaného Chrome) se dodávají nainstalované jako balíčky a `omarchy update` je udržuje aktuální spolu se zbytkem systému. [Hunk](https://github.com/modem-dev/hunk) a CLI pro GitHub, Basecamp, Cloudflare a HEY máte na dosah v _Install > CLI_ a [programovací agenty](17-ai.md) v _Install > AI > CLI_.

mise spravuje pouze běhová prostředí, která si nastavíte z _Install > Development_; Omarchy přes něj sama nic neinstaluje. Spuštěním `omarchy update` je aktualizujete spolu se zbytkem Omarchy; alias `mup` aktualizuje pouze nástroje spravované přes mise. Chcete-li do vlastní konfigurace přidat další nástroj, použijte `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) sotva potřebuje nějaké představování. Umožňuje vám spouštět izolované kontejnery a Omarchy nainstaluje vše potřebné k tomu, aby dobře fungoval, včetně samotného Dockeru a [Docker Compose](https://docs.docker.com/compose/).

Ve výchozím nastavení váš uživatel *není* ve skupině `docker`. Tato skupina je fakticky root bez hesla — cokoli v ní může spustit `docker run -v /:/host` a převzít kontrolu nad počítačem — takže jediný škodlivý skript nebo závislost běžící pod vaším účtem by jinak dělil od roota jen jeden příkaz. Na příkazové řádce proto Docker spouštíte pomocí `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, které komunikují s démonem — Windows VM — si vyžádají autorizaci, když ji potřebují. Pokud chcete zpět pohodlí nastavení bez skupiny a rozumíte kompromisu, zapněte ho v **Setup > Security > Sudoless Docker** (nebo spusťte `omarchy-setup-security-sudoless-docker`), což vás po varování přidá do skupiny `docker`; pak prosté `docker` a alias `d` opět fungují bez `sudo`.

Běžné databáze pro místní vývoj v Dockeru si můžete nastavit pomocí _Install > Development > Docker DB_ v menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je `gh` pro práci s repozitáři, issues a pull requesty z terminálu. _Setup > Git_ ho nainstaluje, když se tam rozhodnete přihlásit ke GitHubu, nebo si ho nainstalujte samostatně z _Install > CLI > GitHub_. Potom `gh repo clone org/repo` naklonuje repozitář; jeho příkazy prozkoumáte spuštěním `gh --help`.

[Lazygit](https://github.com/jesseduffield/lazygit) je předinstalovaný pro práci se samotným Gitem.
