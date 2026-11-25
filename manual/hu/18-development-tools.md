# Fejlesztői eszközök

## Alternatív szerkesztők

Az Omarchy új telepítéseken alapértelmezett szerkesztőként a Paint szállítja, és a [Neovim](https://neovim.io/) is előre telepítve van, de ha valami általánosabb és ismerősebb dologra vágysz, megnyithatod az Omarchy Menut (`Super + Space`), és megnézheted a lehetőségeket az _Install > Editor_ alatt. Ott szerepel a VSCode, a Cursor, a Zed, a Sublime Text, a Helix, a Vim és az Emacs. Ha nem találod, amit keresel, nézd meg az _Install > Package_ lehetőséget, és ellenőrizd, nincs-e meg egy Arch csomagban (ha pedig nincs, próbáld az _Install > AUR_ lehetőséget az AUR ellenőrzéséhez).

Az eredeti `vi` szerkesztő is elérhető dobozból kivéve. Fájl terminálban történő szerkesztéséhez futtasd a `vi filename` parancsot.

A témák összehangolása a `VSCode`, a `Cursor`, a `VSCodium` és a `Helix` esetében is elérhető.

A rendszerszintű alapértelmezett szerkesztőt a `Setup > Defaults > Editor` alatt állíthatod be.

## Környezet

Az Omarchy rengeteg fejlesztői környezet beállítását támogatja az Omarchy Menu (`Super + Space`) _Install > Development_ szakaszán keresztül. Természetesen megtalálod a _Ruby on Rails_ keretrendszert, de a JavaScript három fő futtatókörnyezetét (Node.js, Bun, Deno) is, valamint az olyan népszerű PHP-keretrendszereket, mint a Laravel és a Symfony. Ó, és ott van a Go, a Rust, a Python, a Java, az Elixir (a Phoenixszel), a .NET, az OCaml, a Zig, a Clojure és a Scala is. Nagyon széles a választék!

Ezeknek a környezeteknek a többségét a [Mise](https://mise.jdx.dev/) kezeli. Ez egy olyan eszköz, amellyel egy programozási nyelv több verzióját is telepítheted és futtathatod ugyanazon a gépen. Olyan, mint az rbenv vagy az rvm a Rubyhoz, vagy a virtualenv a Pythonhoz, de egy csomó különböző környezettel működik.

Ha például a Rubyt szeretnéd telepíteni, futtasd a `mise use -g ruby` parancsot, amely telepíti a Rubyt, és globális alapértelmezésként is beállítja. Vagy ha a projektedben van egy .ruby-version fájl, egyszerűen futtathatod a `mise i` parancsot annak a projektnek a gyökerében.

## Előre telepített CLI eszközök

Az `uv`, a Node.js és a `playwright-cli` (hogy az agentek a telepített Chrome használatával böngészőt vezérelhessenek) csomagként telepítve érkezik, az `omarchy update` pedig a rendszer többi részével együtt naprakészen tartja őket. A `ghui`, a [Hunk](https://github.com/modem-dev/hunk), valamint a Basecamp, a Cloudflare és a HEY CLI egy választásnyira van az _Install > CLI_ alatt, a [kódoló agentek](17-ai.md) pedig az _Install > AI > CLI_ alatt.

A mise csak azokat a futtatókörnyezeteket kezeli, amelyeket az _Install > Development_ alól állítasz be; az Omarchy önmagában semmit sem telepít rajta keresztül. Futtasd az `omarchy update` parancsot, hogy az Omarchy többi részével együtt frissítsd őket; a `mup` alias csak a mise által kezelt eszközöket frissíti. Ha egy másik eszközt szeretnél hozzáadni a saját konfigurációdhoz, használd a `mise use -g <tool>` parancsot.

## Docker

A [Docker](https://www.docker.com/) aligha szorul bemutatásra. Lehetővé teszi elszigetelt konténerek futtatását, és az Omarchy mindent telepít, ami a megfelelő futtatásához szükséges, beleértve magát a Dockert és a [Docker Compose](https://docs.docker.com/compose/) eszközt is.

Alapértelmezés szerint a felhasználód *nem* tagja a `docker` csoportnak. Ez a csoport gyakorlatilag jelszó nélküli root — bármi, ami benne van, futtathatja a `docker run -v /:/host` parancsot, és átveheti az irányítást a gép felett —, így egyetlen, a nevedben futó rosszindulatú szkript vagy függőség egyébként egyetlen parancsra lenne a roottól. Ezért a parancssorban a Dockert `sudo` használatával futtatod (`sudo docker ps`, `sudo docker compose up`), a daemonnal kommunikáló grafikus eszközök — a Windows VM — pedig engedélyt kérnek, amikor szükségük van rá. Ha vissza szeretnéd kapni a sudo nélküli beállítás kényelmét, és érted a kompromisszumot, engedélyezd a **Setup > Security > Sudoless Docker** alatt (vagy futtasd az `omarchy-setup-security-sudoless-docker` parancsot), amely egy figyelmeztetés után hozzáad a `docker` csoporthoz; ezután az egyszerű `docker` és a `d` alias ismét `sudo` nélkül működik.

A helyi fejlesztéshez használt gyakori adatbázisokat Dockerben az Omarchy menü _Install > Development > Docker DB_ pontjával állíthatod be.

## GitHub CLI

A [GitHub CLI](https://cli.github.com/) a `gh`, amely repositoryk, issue-k és pull requestek terminálból történő kezelésére szolgál. A _Setup > Git_ telepíti, amikor ott a GitHubba való bejelentkezést választod, ezután a `gh repo clone org/repo` egy repositoryt klónoz. Futtasd a `gh --help` parancsot a parancsai felfedezéséhez.

Az _Install > CLI > GitHub_ telepíti a GitHub CLI-t, a `gh`-t, a `ghui` mellett, amely egy terminálos felület a pull requestekhez. A [Lazygit](https://github.com/jesseduffield/lazygit) előre telepítve van magával a Gittel való munkához.
