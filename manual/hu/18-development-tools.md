# Fejlesztői eszközök

## Alternatív szerkesztők

Az Omarchy új telepítéseken alapértelmezett szerkesztőként a Plaint szállítja, és a [Neovim](https://neovim.io/) is előre telepítve van, de ha valami elterjedtebbre és ismerősebbre vágysz, megnyithatod az Omarchy Menut (`Super + Space`), és megnézheted a lehetőségeket az _Install > Editor_ alatt. Ott szerepel a VSCode, a Cursor, a Zed, a Sublime Text, a Helix, a Vim és az Emacs. Ha nem találod, amit keresel, nézd meg az _Install > Package_ menüpontot, és ellenőrizd, nincs-e meg egy Arch csomagban (ha pedig nincs, próbáld az _Install > AUR_ lehetőséget az AUR ellenőrzéséhez).

Az eredeti `vi` szerkesztő is elérhető rögtön a telepítés után. Egy fájl terminálban történő szerkesztéséhez futtasd a `vi filename` parancsot.

Témához illesztés érhető el a `VSCode`, a `Cursor`, a `VSCodium` és a `Helix` esetében.

A rendszer egészére érvényes alapértelmezett szerkesztőt a `Setup > Defaults > Editor` alatt állíthatod be.

## Környezet

Az Omarchy számos fejlesztői környezet beállítását támogatja az Omarchy Menu (`Super + Space`) _Install > Development_ részében. Természetesen megtalálod a _Ruby on Rails_t, de a JavaScript három nagy futtatókörnyezetét is (Node.js, Bun, Deno), valamint az olyan népszerű PHP keretrendszereket is, mint a Laravel és a Symfony. Ó, és ott van még a Go, a Rust, a Python, a Java, az Elixir (a Phoenixszel), a .NET, az OCaml, a Zig, a Clojure és a Scala is. Nagyon széles a választék!

E környezetek többségét a [Mise](https://mise.jdx.dev/) kezeli. Ez egy olyan eszköz, amellyel egy programozási nyelv több verzióját is telepítheted és futtathatod ugyanazon a gépen. Olyan, mint az rbenv vagy az rvm a Rubyhoz, vagy a virtualenv a Pythonhoz, de egy csomó különböző környezettel működik.

A Ruby telepítéséhez például a `mise use -g ruby` parancsot kell futtatnod, amely telepíti a Rubyt, és be is állítja globális alapértelmezésként. Ha pedig a projektedben van egy .ruby-version fájl, egyszerűen futtasd a `mise i` parancsot annak a projektnek a gyökerében.

## Előre telepített CLI eszközök

Az Omarchy az olyan eszközöket, mint a `gh`, az `uv`, és a legtöbb [kódoló ágenst](17-ai.md) a [mise lusta telepítésén](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) keresztül teszi elérhetővé. Amikor először futtatsz egyet közülük, a mise telepíti. A kódoló ágensek ezután futás előtt ellenőrzik, elérhető-e frissítés, legfeljebb négyóránként egyszer; a többi eszköz, például a `gh` és az `uv`, a telepített verziót használja újra, amíg nem frissítesz.

Megnézheted az alapértelmezéseket is, vagy előre telepítheted őket:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Futtasd az `omarchy update` parancsot a telepített eszközök frissítéséhez az Omarchy többi részével együtt. A `mup` alias csak a mise által kezelt eszközöket frissíti. Ha egy másik eszközt szeretnél hozzáadni a saját konfigurációdhoz, használd a `mise use -g <tool>` parancsot.

A Python beállítása a `uv` eszközt is telepíti a mise segítségével. A Python fejlesztői környezet eltávolítása után a `uv` független eszközként elérhető marad.

### A saját telepítésed használata

A mise parancsai a `PATH` változóban a `~/.local/bin` előtt szerepelnek, így egy eszköz, amelyet magad telepítettél, például a Claude Code vagy a Cursor saját telepítőjével, továbbra is a mise példányát futtatja. Az asztalról indított alkalmazások is a rendszercsomagok előtt találják meg a mise parancsait, így egy alkalmazás, amely a `gh` parancsot futtatja, a mise példányát kapja, még akkor is, ha a `github-cli` csomagot a pacmannel telepítetted, és a mise ezt a példányt az első alkalommal telepíti. Ha inkább a sajátodat szeretnéd használni, tiltsd le a mise példányát a `~/.config/mise/config.toml` fájlban. Például, ha a Cursor CLI-t magad telepítetted:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ha már van `[settings]` táblád, oda add hozzá a bejegyzést; egy meglévő `disable_tools` listát bővíts, ne cseréld le. Győződj meg róla, hogy a telepítésed szerepel a `PATH` változóban. A mise eszköznevét használd, amely eltérhet a parancsától: az `oh-my-pi` például az `omp` parancsot biztosítja. Az alapértelmezett ágenst indító program is előnyben részesíti a felhasználó által telepített Cursort vagy Claude Code-ot a `~/.local/bin` könyvtárban.

### Az alapértelmezések eltávolítása és visszaállítása

A _Remove > Preinstalls_ eltávolítja az Omarchy előre telepített webalkalmazásait, TUI-jait és alkalmazásait, és arra készteti a mise-t, hogy a felhasználód esetében hagyja ki az Omarchy eszközdeklarációit, azáltal, hogy hozzáadja őket az `ignored_config_paths` bejegyzéshez a `~/.config/mise/miserc.toml` fájlban. Az _Install > Preinstalls_ visszahozza őket, és újra eltávolítja azt a sort. Az eszközök, amelyeket magad deklarálsz, a saját konfigurációdban vagy egy projekt `mise.toml` fájljában, mindkét esetben tovább működnek. Ha az előre telepítettek eltávolítása után választasz alapértelmezett ágenst vagy beállítod a Pythont, az az eszköz a saját konfigurációdhoz adódik hozzá. A mise beállítása csak a te felhasználódra vonatkozik, a többi felhasználó megtartja a saját választását; az alkalmazások azonban csomagok, így eltávolításuk vagy visszaállításuk mindenki számára megváltoztatja őket a gépen.

## Docker

A [Docker](https://www.docker.com/) aligha szorul bemutatásra. Lehetővé teszi elszigetelt konténerek futtatását, és az Omarchy mindent telepít, ami a jó működtetéséhez kell, beleértve magát a Dockert és a [Docker Compose](https://docs.docker.com/compose/) eszközt is.

Alapértelmezés szerint a felhasználód *nem* tagja a `docker` csoportnak. Ez a csoport gyakorlatilag jelszó nélküli root jogosultságot jelent — bármi, ami benne van, futtathatja a `docker run -v /:/host` parancsot, és átveheti az irányítást a gép felett —, így egyetlen, a te nevedben futó rosszindulatú szkript vagy függőség egyébként egyetlen parancsra lenne a root jogosultságtól. A parancssorban tehát a Dockert a `sudo` segítségével futtatod (`sudo docker ps`, `sudo docker compose up`), a démonnal kommunikáló grafikus eszközök — a Windows VM — pedig engedélyt kérnek, amikor szükségük van rá. Ha vissza szeretnéd kapni a sudo nélküli használat kényelmét, és tisztában vagy a kompromisszummal, engedélyezd a **Setup > Security > Sudoless Docker** menüpontban (vagy futtasd az `omarchy-setup-security-sudoless-docker` parancsot), amely egy figyelmeztetés után hozzáad a `docker` csoporthoz; ezután a sima `docker` és a `d` alias ismét `sudo` nélkül működik.

A helyi fejlesztéshez használt gyakori adatbázisokat a Dockerben az Omarchy menü _Install > Development > Docker DB_ menüpontjával állíthatod be.

## GitHub CLI

A [GitHub CLI](https://cli.github.com/) `gh` néven érhető el repók, issue-k és pull requestek terminálból történő kezeléséhez. Futtasd a `gh auth login` parancsot, hogy az első használatkor telepítsd és hitelesítsd magad, majd a `gh repo clone org/repo` parancsot egy repó klónozásához. Futtasd a `gh --help` parancsot a parancsai felfedezéséhez.

A pull requestek terminálos felületéhez futtasd a `ghui` parancsot; a mise ezt is telepíti az első használatkor. A [Lazygit](https://github.com/jesseduffield/lazygit) előre telepítve van magával a Gittel végzett munkához.
