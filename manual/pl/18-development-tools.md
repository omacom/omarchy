# Narzędzia programistyczne

## Alternatywne edytory

Omarchy jest dostarczane z Plain jako domyślnym edytorem w nowych instalacjach i z preinstalowanym [Neovim](https://neovim.io/), ale jeśli chcesz czegoś nieco bardziej popularnego i znajomego, możesz uruchomić Menu Omarchy (`Super + Space`) i zobaczyć opcje w sekcji _Install > Editor_. Mamy tam wymienione VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Jeśli nie znajdziesz tego, czego szukasz, sprawdź _Install > Package_ i zobacz, czy nie ma tego w pakiecie Arch (a jeśli nie, spróbuj _Install > AUR_, aby sprawdzić AUR).

Oryginalny edytor `vi` jest również dostępny od razu po instalacji. Uruchom `vi filename`, aby edytować plik w terminalu.

Dopasowywanie motywu jest oferowane dla `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Ogólnosystemowy domyślny edytor możesz ustawić w sekcji `Setup > Defaults > Editor`.

## Środowisko

Omarchy obsługuje konfigurowanie całego szeregu środowisk programistycznych za pośrednictwem sekcji _Install > Development_ w Menu Omarchy (`Super + Space`). Znajdziesz tam oczywiście _Ruby on Rails_, ale także wszystkie trzy główne środowiska uruchomieniowe dla JavaScript (Node.js, Bun, Deno), a także popularne frameworki PHP, takie jak Laravel i Symfony. Aha, jest też Go, Rust, Python, Java, Elixir (z Phoenix), .NET, OCaml, Zig, Clojure i Scala. To bardzo szeroki wybór!

Większością tych środowisk zarządza [Mise](https://mise.jdx.dev/). To narzędzie, które pozwala instalować i uruchamiać wiele wersji języka programowania na tej samej maszynie. To jak rbenv lub rvm dla Ruby albo virtualenv dla Pythona, ale działa dla wielu różnych środowisk.

Aby zainstalować, powiedzmy, Ruby, uruchomisz `mise use -g ruby`, co zarówno zainstaluje Ruby, jak i ustawi je jako globalną wersję domyślną. Albo, jeśli Twój projekt ma plik .ruby-version, możesz po prostu uruchomić `mise i` w katalogu głównym tego projektu.

## Preinstalowane narzędzia CLI

Omarchy udostępnia narzędzia takie jak `gh`, `uv` i większość [agentów kodujących](17-ai.md) za pośrednictwem [leniwej instalacji mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Przy pierwszym uruchomieniu jednego z nich mise je instaluje. Agenty kodujące sprawdzają następnie przed uruchomieniem, czy jest dostępna aktualizacja, nie częściej niż raz na cztery godziny; inne narzędzia, takie jak `gh` i `uv`, korzystają z zainstalowanej wersji do czasu, aż je zaktualizujesz.

Możesz też sprawdzić ustawienia domyślne lub zainstalować je z wyprzedzeniem:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Uruchom `omarchy update`, aby zaktualizować zainstalowane narzędzia wraz z resztą Omarchy. Alias `mup` aktualizuje tylko narzędzia zarządzane przez mise. Aby dodać kolejne narzędzie do własnej konfiguracji, użyj `mise use -g <tool>`.

Konfiguracja Pythona instaluje również `uv` za pośrednictwem mise. Usunięcie środowiska programistycznego Pythona pozostawia `uv` dostępne jako niezależne narzędzie.

### Korzystanie z własnej instalacji

Polecenia mise znajdują się przed `~/.local/bin` w `PATH`, więc narzędzie, które zainstalowałeś samodzielnie, na przykład za pomocą własnego instalatora Claude Code lub Cursor, nadal uruchamia kopię mise. Aplikacje uruchamiane z pulpitu również znajdują polecenia mise przed pakietami systemowymi, więc aplikacja, która uruchamia `gh`, otrzymuje kopię mise, nawet jeśli zainstalowałeś `github-cli` za pomocą pacman, a mise instaluje tę kopię przy pierwszym użyciu. Aby zamiast tego korzystać ze swojej, wyłącz kopię mise w `~/.config/mise/config.toml`. Na przykład, jeśli samodzielnie zainstalowałeś Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Jeśli masz już tabelę `[settings]`, dodaj wpis w niej; rozszerz istniejącą listę `disable_tools`, zamiast ją zastępować. Upewnij się, że Twoja instalacja znajduje się w `PATH`. Użyj nazwy narzędzia mise, która może różnić się od jego polecenia: na przykład `oh-my-pi` dostarcza `omp`. Program uruchamiający domyślnego agenta również preferuje zainstalowane przez użytkownika Cursor lub Muse w `~/.local/bin`.

### Usuwanie i przywracanie ustawień domyślnych

_Remove > Preinstalls_ usuwa preinstalowane przez Omarchy aplikacje webowe, TUI i aplikacje oraz sprawia, że mise pomija deklaracje narzędzi Omarchy dla Twojego użytkownika, dodając je do `ignored_config_paths` w `~/.config/mise/miserc.toml`. _Install > Preinstalls_ przywraca je i ponownie usuwa tę linię. Narzędzia, które zadeklarujesz samodzielnie, we własnej konfiguracji lub w pliku `mise.toml` projektu, działają w obu przypadkach. Jeśli wybierzesz domyślnego agenta lub skonfigurujesz Pythona po usunięciu preinstalowanych elementów, to narzędzie zostanie dodane do Twojej własnej konfiguracji. Ustawienie mise dotyczy tylko Twojego użytkownika, a inni użytkownicy zachowują własny wybór; aplikacje są jednak pakietami, więc usuwanie lub przywracanie ich zmienia je dla wszystkich na maszynie.

## Docker

[Docker](https://www.docker.com/) właściwie nie wymaga żadnego przedstawiania. Pozwala uruchamiać izolowane kontenery, a Omarchy instaluje wszystko, co potrzebne, aby działał dobrze, w tym samego Docker i [Docker Compose](https://docs.docker.com/compose/).

Domyślnie Twój użytkownik *nie* należy do grupy `docker`. Ta grupa to w praktyce root bez hasła — wszystko, co do niej należy, może wykonać `docker run -v /:/host` i przejąć kontrolę nad maszyną — więc jeden nieuczciwy skrypt lub zależność działająca jako Ty byłaby w przeciwnym razie o jedno polecenie od roota. Dlatego w wierszu poleceń uruchamiasz Docker z `sudo` (`sudo docker ps`, `sudo docker compose up`), a narzędzia graficzne komunikujące się z daemonem — VM z Windows — proszą o autoryzację, gdy jej potrzebują. Jeśli chcesz przywrócić wygodę konfiguracji bez grupy i rozumiesz kompromis, włącz ją w **Setup > Security > Sudoless Docker** (lub uruchom `omarchy-setup-security-sudoless-docker`), co po ostrzeżeniu doda Cię do grupy `docker`; wtedy zwykłe `docker` i alias `d` znów działają bez `sudo`.

Popularne bazy danych do lokalnego programowania w Dockerze możesz skonfigurować, korzystając z _Install > Development > Docker DB_ w menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) jest dostępny jako `gh` do pracy z repozytoriami, zgłoszeniami i pull requestami z terminala. Uruchom `gh auth login`, aby zainstalować go przy pierwszym użyciu i uwierzytelnić się, a następnie `gh repo clone org/repo`, aby sklonować repozytorium. Uruchom `gh --help`, aby poznać jego polecenia.

Aby korzystać z terminalowego interfejsu do pull requestów, uruchom `ghui`; mise instaluje go również przy pierwszym użyciu. [Lazygit](https://github.com/jesseduffield/lazygit) jest preinstalowany do pracy z samym Gitem.
