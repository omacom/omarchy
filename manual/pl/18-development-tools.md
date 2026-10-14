# Narzędzia programistyczne

## Alternatywne edytory

Omarchy domyślnie dostarcza [Neovim](https://neovim.io/), ale jeśli wolisz coś bardziej mainstreamowego i znajomego, możesz uruchomić menu Omarchy (`Super + Space`) i zobaczyć opcje w _Instaluj > Editor_. Mamy tam wymienione VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Jeśli nie znajdziesz tego, czego szukasz, zajrzyj do _Instaluj > Package_ i sprawdź, czy nie ma tego w pakiecie Arch (a jeśli nie, spróbuj _Instaluj > AUR_, aby sprawdzić AUR).

Oryginalny edytor `vi` jest również dostępny od razu. Uruchom `vi filename`, aby edytować plik w terminalu.

Dopasowywanie motywu jest oferowane dla `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Możesz ustawić domyślny edytor całego systemu w `Ustawienia > Defaults > Editor`.

## Środowisko

Omarchy obsługuje konfigurowanie całej gamy środowisk programistycznych poprzez sekcję _Instaluj > Development_ w menu Omarchy (`Super + Space`). Znajdziesz tam oczywiście _Ruby on Rails_, ale także wszystkie trzy główne środowiska uruchomieniowe JavaScript (Node.js, Bun, Deno), a także popularne frameworki PHP, takie jak Laravel i Symfony. Och, jest też Go, Rust, Python, Java, Elixir (z Phoenix), .NET, OCaml, Zig, Clojure i Scala. To bardzo szeroki wybór!

Większość tych środowisk jest zarządzana przez [Mise](https://mise.jdx.dev/). To narzędzie, które pozwala instalować i uruchamiać wiele wersji języka programowania na tym samym komputerze. To jak rbenv lub rvm dla Ruby albo virtualenv dla Pythona, ale działa dla wielu różnych środowisk.

Aby zainstalować na przykład Ruby, uruchomisz `mise use -g ruby`, co zarówno zainstaluje Ruby, jak i ustawi go jako globalny domyślny. Lub, jeśli twój projekt ma plik .ruby-version, możesz po prostu uruchomić `mise i` w katalogu głównym tego projektu.

## Docker

[Docker](https://www.docker.com/) nie potrzebuje praktycznie żadnego wstępu. Pozwala uruchamiać izolowane kontenery, a Omarchy instaluje wszystko, co potrzebne, aby działał dobrze, w tym samego Dockera i [Docker Compose](https://docs.docker.com/compose/).

Domyślnie twój użytkownik *nie* należy do grupy `docker`. Ta grupa jest w praktyce rootem bez hasła — wszystko, co do niej należy, może wykonać `docker run -v /:/host` i przejąć komputer — więc jeden nieuczciwy skrypt lub zależność działająca jako ty byłaby w przeciwnym razie o jedno polecenie od roota. Dlatego w wierszu poleceń uruchamiasz Dockera z `sudo` (`sudo docker ps`, `sudo docker compose up`), a narzędzia graficzne komunikujące się z demonem — maszyna wirtualna Windows — proszą o autoryzację, gdy jej potrzebują. Jeśli chcesz odzyskać wygodę konfiguracji bez grupy i rozumiesz kompromis, włącz ją w **Ustawienia > Security > Sudoless Docker** (lub uruchom `omarchy-setup-security-sudoless-docker`), co doda cię do grupy `docker` po ostrzeżeniu; wtedy zwykłe `docker` i alias `d` znów będą działać bez `sudo`.

Możesz skonfigurować typowe bazy danych do lokalnego programowania w Dockerze, używając _Instaluj > Development > Docker DB_ w menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) pozwala uwierzytelnić się na koncie GitHub i klonować za jego pomocą prywatne repozytoria. Jest podłączony jako jeden z leniwie ładowanych stubów mise, więc za pierwszym razem, gdy uruchomisz `gh`, zainstaluje się sam. Aby się uwierzytelnić, uruchom `gh auth login`. Następnie możesz pobierać prywatne repozytoria za pomocą `gh repo clone org/repo`.

Możesz również wykonywać wiele innych operacji GitHub za pomocą tego polecenia. Po prostu uruchom `gh`, aby zobaczyć wszystko, co jest możliwe.

Istnieje również leniwie instalujący się stub dla `ghui` do zarządzania pull requestami w TUI. A [lazygit](https://github.com/jesseduffield/lazygit) jest preinstalowany, jeśli chcesz również obsługiwać samego gita z TUI.
