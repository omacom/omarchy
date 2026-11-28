# Fejlesztői eszközök

## Alternatív szerkesztők

Az Omarchy új telepítéseken a Plainnel érkezik alapértelmezett szerkesztőként, és a [Neovim](https://neovim.io/) előre telepítve van, de ha valami kicsit általánosabb és ismerősebb dologra vágysz, megnyithatod az Omarchy Menut (`Super + Space`), és megnézheted a lehetőségeket az _Install > Editor_ alatt. Ott szerepel a VSCode, a Cursor, a Zed, a Sublime Text, a Helix, a Vim és az Emacs. Ha nem találod, amit keresel, nézd meg az _Install > Package_ menüpontot, és nézd meg, nincs-e ott egy Arch-csomagban (és ha nincs, próbáld ki az _Install > AUR_ menüpontot az AUR ellenőrzéséhez).

Az eredeti `vi` szerkesztő is elérhető rögtön, dobozból. Egy fájl terminálban történő szerkesztéséhez futtasd a `vi filename` parancsot.

Témaillesztés érhető el a `VSCode`, a `Cursor`, a `VSCodium` és a `Helix` számára.

A rendszerszintű alapértelmezett szerkesztőt a `Setup > Defaults > Editor` alatt állíthatod be.

## Környezet

Az Omarchy rengeteg fejlesztői környezet beállítását támogatja az Omarchy Menu (`Super + Space`) _Install > Development_ részén keresztül. Természetesen megtalálod a _Ruby on Rails_-t, de mindhárom fő JavaScript-futtatókörnyezetet is (Node.js, Bun, Deno), valamint olyan népszerű PHP-keretrendszereket, mint a Laravel és a Symfony. Ó, és ott van a Go, a Rust, a Python, a Java, az Elixir (a Phoenixszel), a .NET, az OCaml, a Zig, a Clojure és a Scala is. Nagyon széles a választék!

E környezetek többségét a [Mise](https://mise.jdx.dev/) kezeli. Ez egy olyan eszköz, amellyel egy programozási nyelv több verzióját telepítheted és futtathatod ugyanazon a gépen. Olyan, mint az rbenv vagy az rvm a Rubyhoz, vagy a virtualenv a Pythonhoz, de egy csomó különböző környezettel működik.

Ha például a Rubyt szeretnéd telepíteni, futtasd a `mise use -g ruby` parancsot, amely telepíti a Rubyt, és beállítja globális alapértelmezettnek is. Vagy ha a projektedben van egy .ruby-version fájl, egyszerűen futtathatod a `mise i` parancsot annak a projektnek a gyökerében.

## Előre telepített CLI-eszközök

Az `uv`, a Node.js és a `playwright-cli` (hogy az ügynökök böngészőt vezérelhessenek a telepített Chrome-mal) csomagként telepítve érkezik, és az `omarchy update` a rendszer többi részével együtt naprakészen tartja őket. A [Hunk](https://github.com/modem-dev/hunk) és a GitHub, a Basecamp, a Cloudflare és a HEY CLI-k egy választásnyira vannak az _Install > CLI_ alatt, a [kódoló ügynökök](17-ai.md) pedig az _Install > AI > CLI_ alatt.

A mise csak azokat a futtatókörnyezeteket kezeli, amelyeket az _Install > Development_ menüpontból állítasz be; az Omarchy a saját nevében semmit sem telepít rajta keresztül. Futtasd az `omarchy update` parancsot, hogy az Omarchy többi részével együtt ezeket is frissítsd; a `mup` alias csak a mise által kezelt eszközöket frissíti. Ha egy másik eszközt szeretnél hozzáadni a saját konfigurációdhoz, használd a `mise use -g <tool>` parancsot.

## Docker

A [Docker](https://www.docker.com/) aligha szorul bemutatásra. Lehetővé teszi elszigetelt konténerek futtatását, és az Omarchy mindent telepít, ami a jó működtetéséhez kell, beleértve magát a Dockert és a [Docker Compose](https://docs.docker.com/compose/)-t is.

Alapértelmezés szerint a felhasználód *nem* tagja a `docker` csoportnak. Ez a csoport gyakorlatilag jelszó nélküli root — bármi, ami benne van, futtathatja a `docker run -v /:/host` parancsot, és átveheti az irányítást a gép felett —, így egyetlen, a nevedben futó rosszindulatú szkript vagy függőség egyébként egyetlen parancsra lenne a roottól. Ezért a parancssorban a Dockert `sudo`-val futtatod (`sudo docker ps`, `sudo docker compose up`), a démonnal kommunikáló grafikus eszközök — a Windows VM — pedig engedélyt kérnek, amikor szükségük van rá. Ha vissza szeretnéd kapni a csoport nélküli beállítás kényelmét, és érted a kompromisszumot, engedélyezd a **Setup > Security > Sudoless Docker** menüpontban (vagy futtasd az `omarchy-setup-security-sudoless-docker` parancsot), amely egy figyelmeztetés után hozzáad a `docker` csoporthoz; ezután a sima `docker` és a `d` alias ismét `sudo` nélkül működik.

A helyi fejlesztéshez használt gyakori adatbázisokat Dockerben az Omarchy menü _Install > Development > Docker DB_ menüpontjával állíthatod be.

## GitHub CLI

A [GitHub CLI](https://cli.github.com/) a `gh`, amellyel tárolókkal, issue-kkal és pull requestekkel dolgozhatsz a terminálból. A _Setup > Git_ telepíti, amikor ott úgy döntesz, hogy bejelentkezel a GitHubra, vagy telepítheted önmagában az _Install > CLI > GitHub_ menüpontból. Ezután a `gh repo clone org/repo` egy tárolót klónoz; futtasd a `gh --help` parancsot a parancsai felfedezéséhez.

A [Lazygit](https://github.com/jesseduffield/lazygit) előre telepítve van, hogy magával a Gittel dolgozhass.
