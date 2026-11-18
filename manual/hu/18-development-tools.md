# Fejlesztői eszközök

## Alternatív szerkesztők

Az Omarchy alapértelmezetten a [Neovim](https://neovim.io/) szerkesztővel érkezik, de ha valami elterjedtebbre és ismerősebbre vágysz, indítsd el az Omarchy Menu menüt (`Super + Space`), és nézd meg a lehetőségeket a _Telepítés > Szerkesztő_ alatt. Ott szerepel a VSCode, a Cursor, a Zed, a Sublime Text, a Helix, a Vim és az Emacs. Ha nem találod, amit keresel, nézd meg a _Telepítés > Csomag_ menüpontot, és ellenőrizd, nincs-e benne egy Arch-csomagban (ha pedig nincs, próbáld ki a _Telepítés > AUR_ lehetőséget az AUR ellenőrzéséhez).

Az eredeti `vi` szerkesztő is azonnal használható. Fájl terminálban történő szerkesztéséhez futtasd a `vi filename` parancsot.

Témához illesztés érhető el a `VSCode`, a `Cursor`, a `VSCodium` és a `Helix` esetében.

A rendszer szintű alapértelmezett szerkesztőt a `Beállítás > Alapértelmezések > Szerkesztő` alatt állíthatod be.

## Környezet

Az Omarchy rengeteg fejlesztői környezet beállítását támogatja az Omarchy Menu (`Super + Space`) _Telepítés > Fejlesztés_ szakaszán keresztül. Természetesen megtalálod ott a _Ruby on Rails_ keretrendszert, de a JavaScript három fő futtatókörnyezetét (Node.js, Bun, Deno) is, valamint népszerű PHP-keretrendszereket, például a Laravelt és a Symfonyt. Ja, és van Go, Rust, Python, Java, Elixir (Phoenixszel), .NET, OCaml, Zig, Clojure és Scala is. Ez egy nagyon széles választék!

Ezeknek a környezeteknek a többségét a [Mise](https://mise.jdx.dev/) kezeli. Ez egy olyan eszköz, amellyel egy programozási nyelv több verzióját telepítheted és futtathatod ugyanazon a gépen. Olyan, mint az rbenv vagy az rvm Rubyhoz, vagy a virtualenv Pythonhoz, de egy csomó különböző környezettel működik.

Ha például Rubyt szeretnél telepíteni, futtasd a `mise use -g ruby` parancsot, amely telepíti a Rubyt, és beállítja globális alapértelmezettként. Ha pedig a projektedben van egy .ruby-version fájl, egyszerűen futtathatod a `mise i` parancsot annak a projektnek a gyökerében.

## Előre telepített CLI-eszközök

Az Omarchy olyan eszközöket tesz elérhetővé, mint a `gh`, az `uv` és a legtöbb [kódolóügynök](17-ai.md), a [mise lusta telepítésén](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) keresztül. Amikor először futtatsz egyet, a mise telepíti. A későbbi futtatások a telepített verziót használják újra; nem ellenőriznek frissítést minden indításkor.

Megnézheted az alapértelmezéseket is, vagy előre telepítheted őket:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Futtasd az `omarchy update` parancsot a telepített eszközök frissítéséhez az Omarchy többi részével együtt. A `mup` alias csak a mise által kezelt eszközöket frissíti. Ha egy másik eszközt szeretnél hozzáadni a saját konfigurációdhoz, használd a `mise use -g <tool>` parancsot.

A Python beállítása az `uv` eszközt is telepíti a mise segítségével. A Python fejlesztői környezet eltávolítása után az `uv` független eszközként továbbra is elérhető marad.

### Saját telepítés használata

A mise parancsai a `~/.local/bin` előtt szerepelnek a `PATH` változóban, ezért egy saját magad által telepített eszköz, például a Claude Code vagy a Cursor saját telepítőjével, továbbra is a mise példányát futtatja. Az asztalról indított alkalmazások is a rendszer csomagjai előtt találják meg a mise parancsait, így egy alkalmazás, amely a `gh` parancsot futtatja, a mise példányát kapja meg akkor is, ha a `github-cli` csomagot a pacman segítségével telepítetted, és a mise az első alkalommal telepíti azt a példányt. Ha helyette a sajátodat szeretnéd használni, tiltsd le a mise példányát a `~/.config/mise/config.toml` fájlban. Ha például a Cursor CLI-t magad telepítetted:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Ha már van `[settings]` táblád, oda add hozzá a bejegyzést; egy meglévő `disable_tools` listát bővíts, ne cseréld le. Győződj meg róla, hogy a telepítésed szerepel a `PATH` változóban. A mise eszköznevét használd, amely eltérhet a parancsától: az `oh-my-pi` például az `omp` parancsot biztosítja. Az alapértelmezett ügynökindító szintén előnyben részesíti a felhasználó által a `~/.local/bin` könyvtárba telepített Cursort vagy Muse-ot.

### Az alapértelmezések eltávolítása és visszaállítása

Az _Előre telepítettek eltávolítása_ hatására a mise kihagyja az Omarchy eszközdeklarációit a felhasználódnál azáltal, hogy hozzáadja őket az `ignored_config_paths` beállításhoz a `~/.config/mise/miserc.toml` fájlban. Az _Előre telepítettek visszaállítása_ ismét eltávolítja ezt a sort. Az általad deklarált eszközök, a saját konfigurációdban vagy egy projekt `mise.toml` fájljában, mindkét esetben tovább működnek. Ha az előre telepítettek eltávolítása után választasz alapértelmezett ügynököt vagy beállítod a Pythont, az eszköz bekerül a saját konfigurációdba. Mindkettő csak a te felhasználódra vonatkozik; a gép többi felhasználója megtartja a saját választását.

## Docker

A [Docker](https://www.docker.com/) aligha szorul bemutatásra. Lehetővé teszi elszigetelt konténerek futtatását, és az Omarchy mindent telepít, ami a megfelelő működéséhez szükséges, beleértve magát a Dockert és a [Docker Compose](https://docs.docker.com/compose/) eszközt is.

Alapértelmezetten a felhasználód *nem* tagja a `docker` csoportnak. Ez a csoport gyakorlatilag jelszó nélküli root hozzáférést jelent — minden, ami tagja, futtathatja a `docker run -v /:/host` parancsot, és átveheti az irányítást a gép felett —, így egyetlen, a nevedben futó rosszindulatú szkript vagy függőség egyébként egyetlen parancsra lenne a root hozzáféréstől. Ezért a parancssorban a Dockert `sudo` segítségével futtatod (`sudo docker ps`, `sudo docker compose up`), a démonnal kommunikáló grafikus eszközök — a Windows VM — pedig engedélyt kérnek, amikor szükségük van rá. Ha vissza szeretnéd kapni a csoport nélküli beállítás kényelmét, és érted a kompromisszumot, engedélyezd a **Beállítás > Biztonság > Sudoless Docker** menüpontban (vagy futtasd az `omarchy-setup-security-sudoless-docker` parancsot), amely egy figyelmeztetés után hozzáad a `docker` csoporthoz; ezután az egyszerű `docker` parancs és a `d` alias ismét `sudo` nélkül működik.

A helyi fejlesztéshez használt gyakori adatbázisokat Dockerben az Omarchy menü _Telepítés > Fejlesztés > Docker DB_ menüpontjával állíthatod be.

## GitHub CLI

A [GitHub CLI](https://cli.github.com/) `gh` néven érhető el adattárakkal, issue-kkal és pull requestekkel való munkához a terminálból. Futtasd a `gh auth login` parancsot az első használatkor történő telepítéshez és hitelesítéshez, majd a `gh repo clone org/repo` parancsot egy adattár klónozásához. Futtasd a `gh --help` parancsot a parancsai felfedezéséhez.

Pull requestekhez való terminálfelületért futtasd a `ghui` parancsot; a mise ezt is telepíti az első használatkor. A [Lazygit](https://github.com/jesseduffield/lazygit) előre telepítve érkezik a Gittel való munkához.
