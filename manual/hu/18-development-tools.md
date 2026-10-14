# Fejlesztői eszközök

## Alternatív szerkesztők

Az Omarchy alapértelmezetten a [Neovimot](https://neovim.io/) szállítja, de ha valami elterjedtebbet és ismerősebbet szeretnél, indítsd el az Omarchy menüt (`Super + Space`), és nézd meg a lehetőségeket az _Install > Editor_ alatt. Ott megtalálod a VSCode-ot, a Cursort, a Zedet, a Sublime Textet, a Helixet, a Vimet és az Emacset. Ha nem találod, amit keresel, nézd meg az _Install > Package_ pontot, hátha benne van valamelyik Arch csomagban (ha mégsem, próbáld az _Install > AUR_ pontot az AUR ellenőrzéséhez).

Az eredeti `vi` szerkesztő is azonnal elérhető. Futtasd a `vi filename` parancsot egy fájl terminálban történő szerkesztéséhez.

Témaszinkronizálást a `VSCode`, a `Cursor`, a `VSCodium` és a `Helix` esetében kínálunk.

A rendszerszintű alapértelmezett szerkesztődet a `Setup > Defaults > Editor` alatt állíthatod be.

## Környezet

Az Omarchy rengeteg fejlesztőkörnyezet beállítását támogatja az Omarchy menü (`Super + Space`) _Install > Development_ szakaszában. Természetesen megtalálod a _Ruby on Railset_, de a JavaScript mindhárom fontos futtatókörnyezetét is (Node.js, Bun, Deno), valamint népszerű PHP-keretrendszereket, mint a Laravel és a Symfony. Ja, és ott van még a Go, a Rust, a Python, a Java, az Elixir (a Phoenixszel), a .NET, az OCaml, a Zig, a Clojure és a Scala is. Nagyon széles a választék!

Ezen környezetek többségét a [Mise](https://mise.jdx.dev/) kezeli. Ez egy olyan eszköz, amellyel egy programozási nyelv több verzióját telepítheted és futtathatod ugyanazon a gépen. Olyan, mint az rbenv vagy az rvm a Rubyhoz, vagy a virtualenv a Pythonhoz, de sokféle környezethez működik.

Például a Ruby telepítéséhez futtathatod a `mise use -g ruby` parancsot, amely egyszerre telepíti a Rubyt és beállítja globális alapértelmezettként. Vagy ha a projekted tartalmaz egy .ruby-version fájlt, egyszerűen futtathatod a `mise i` parancsot annak a projektnek a gyökerében.

## Docker

A [Docker](https://www.docker.com/) aligha kell bemutatni. Lehetővé teszi elszigetelt konténerek futtatását, és az Omarchy mindent telepít, ami a megfelelő működéséhez kell, beleértve magán a Dockeren kívül a [Docker Compose-t](https://docs.docker.com/compose/) is.

Alapértelmezetten a felhasználód *nincs* benne a `docker` csoportban. Ez a csoport gyakorlatilag jelszó nélküli root jogot jelent — bármi, ami benne van, futtathatja a `docker run -v /:/host` parancsot, és átveheti az irányítást a gép felett —, így egyetlen, a nevedben futó rosszindulatú szkript vagy függőség egyébként egyetlen parancsra lenne a root jogtól. Ezért a parancssorban a Dockert `sudo`-val futtatod (`sudo docker ps`, `sudo docker compose up`), és a daemonnal kommunikáló grafikus eszközök — a Windows VM — engedélyt kérnek, amikor szükségük van rá. Ha szeretnéd visszakapni a csoport nélküli beállítás kényelmét, és érted a kompromisszumot, engedélyezd a **Setup > Security > Sudoless Docker** alatt (vagy futtasd az `omarchy-setup-security-sudoless-docker` parancsot), amely egy figyelmeztetés után hozzáad a `docker` csoporthoz; ezt követően a sima `docker` és a `d` aliás ismét `sudo` nélkül működik.

A helyi fejlesztéshez használt gyakori adatbázisokat Dockerben az Omarchy menü _Install > Development > Docker DB_ pontjában állíthatod be.

## GitHub CLI

[A GitHub CLI](https://cli.github.com/) lehetővé teszi, hogy hitelesítsd magad a GitHub-fiókoddal, és azzal klónozz privát tárolókat. A lazy-betöltéses mise-csonkok egyikeként van bekábelezve, így amikor először futtatod a `gh` parancsot, magától telepítődik. A hitelesítéshez futtasd a `gh auth login` parancsot. Ezután a `gh repo clone org/repo` paranccsal klónozhatsz privát tárolókat.

Ezzel a paranccsal rengeteg egyéb GitHub-műveletet is elvégezhetsz. Csak futtasd a `gh` parancsot, és megmutatja minden lehetőségét.

Van egy lazy-települő csonk a `ghui`-hoz is a pull requestjeid TUI-ban történő kezeléséhez. A [lazygit](https://github.com/jesseduffield/lazygit) pedig előre telepítve érkezik, ha magát a gitet is TUI-ból szeretnéd kezelni.
