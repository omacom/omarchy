# Vývojářské nástroje

## Alternativní editory

Omarchy se na nových instalacích dodává s Plain jako výchozím editorem a s předinstalovaným [Neovim](https://neovim.io/), ale pokud chcete něco běžnějšího a důvěrněji známého, můžete otevřít nabídku Omarchy (`Super + Space`) a podívat se na možnosti v části _Instalace > Editor_. Máme tam VSCode, Cursor, Zed, Sublime Text, Helix, Vim a Emacs. Pokud nenajdete, co hledáte, podívejte se do části _Instalace > Balíček_ a zjistěte, zda to není v nějakém balíčku pro Arch (a pokud ne, zkuste _Instalace > AUR_ a prověřte AUR).

Původní editor `vi` je také k dispozici hned po instalaci. Spuštěním `vi filename` upravíte soubor v terminálu.

Sladění motivu je k dispozici pro `VSCode`, `Cursor`, `VSCodium` a `Helix`.

Systémový výchozí editor můžete nastavit v části `Nastavení > Výchozí > Editor`.

## Prostředí

Omarchy podporuje nastavení celé řady vývojových prostředí v sekci _Instalace > Vývoj_ nabídky Omarchy (`Super + Space`). Najdete tam samozřejmě _Ruby on Rails_, ale také všechny tři hlavní běhová prostředí pro JavaScript (Node.js, Bun, Deno) a také populární PHP frameworky jako Laravel a Symfony. A samozřejmě je tam také Go, Rust, Python, Java, Elixir (s Phoenix), .NET, OCaml, Zig, Clojure a Scala. Je to opravdu široký výběr!

Většinu těchto prostředí spravuje [Mise](https://mise.jdx.dev/). Je to nástroj, který vám umožní nainstalovat a spouštět více verzí programovacího jazyka na stejném počítači. Je to jako rbenv nebo rvm pro Ruby nebo virtualenv pro Python, ale funguje pro celou řadu různých prostředí.

Chcete-li nainstalovat třeba Ruby, spustíte `mise use -g ruby`, čímž Ruby zároveň nainstalujete a nastavíte jako globální výchozí. Nebo pokud má váš projekt soubor .ruby-version, stačí v kořenovém adresáři projektu spustit `mise i`.

## Předinstalované CLI nástroje

`uv`, Node.js a `playwright-cli` (aby agenti mohli ovládat prohlížeč pomocí nainstalovaného Chrome) jsou nainstalované jako balíčky a `omarchy update` je udržuje aktuální spolu se zbytkem systému. `ghui`, [Hunk](https://github.com/modem-dev/hunk) a CLI pro Basecamp, Cloudflare a HEY máte na dosah v části _Instalace > CLI_ a [kódovací agenty](17-ai.md) v části _Instalace > AI > CLI_.

mise spravuje pouze běhová prostředí, která si nastavíte v části _Instalace > Vývoj_; Omarchy přes ni samo nic neinstaluje. Spuštěním `omarchy update` je aktualizujete spolu se zbytkem Omarchy; alias `mup` aktualizuje pouze nástroje spravované přes mise. Chcete-li do vlastní konfigurace přidat další nástroj, použijte `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) snad ani nepotřebuje představovat. Umožňuje spouštět izolované kontejnery a Omarchy nainstaluje vše potřebné k tomu, aby dobře fungoval, včetně samotného Dockeru a [Docker Compose](https://docs.docker.com/compose/).

Ve výchozím nastavení váš uživatel *není* ve skupině `docker`. Tato skupina je v podstatě root bez hesla — cokoli v ní může spustit `docker run -v /:/host` a převzít kontrolu nad počítačem — takže jeden podvodný skript nebo závislost běžící pod vaším účtem by jinak byly od rootu vzdálené jediný příkaz. Proto na příkazovém řádku spouštíte Docker pomocí `sudo` (`sudo docker ps`, `sudo docker compose up`) a grafické nástroje, které komunikují s démonem — Windows VM — si v případě potřeby vyžádají autorizaci. Pokud chcete zpět pohodlí nastavení bez skupiny a chápete kompromis, povolte ho v části **Nastavení > Zabezpečení > Sudoless Docker** (nebo spusťte `omarchy-setup-security-sudoless-docker`), což vás po varování přidá do skupiny `docker`; pak prosté `docker` a alias `d` opět fungují bez `sudo`.

Běžné databáze pro lokální vývoj v Dockeru si můžete nastavit pomocí _Instalace > Vývoj > Docker DB_ v nabídce Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) je `gh` pro práci s repozitáři, issues a pull requesty z terminálu. _Nastavení > Git_ ho nainstaluje, když se tam rozhodnete přihlásit ke GitHubu, a poté `gh repo clone org/repo` naklonuje repozitář. Jeho příkazy prozkoumáte spuštěním `gh --help`.

_Instalace > CLI > GitHub_ nainstaluje GitHub CLI, `gh`, spolu s `ghui`, terminálovým rozhraním pro pull requesty. [Lazygit](https://github.com/jesseduffield/lazygit) je předinstalovaný pro práci se samotným Gitem.
