# Narzędzia programistyczne

## Alternatywne edytory

Omarchy w nowych instalacjach ma Plain jako domyślny edytor i preinstalowany [Neovim](https://neovim.io/), ale jeśli chcesz czegoś trochę bardziej mainstreamowego i znajomego, możesz uruchomić Omarchy Menu (`Super + Space`) i zobaczyć opcje w _Install > Editor_. Mamy tam wymienione VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Jeśli nie znajdziesz tego, czego szukasz, sprawdź _Install > Package_ i zobacz, czy nie ma tego w pakiecie Arch (a jeśli nie, spróbuj _Install > AUR_, aby sprawdzić AUR).

Oryginalny edytor `vi` jest również dostępny od razu po instalacji. Uruchom `vi filename`, aby edytować plik w terminalu.

Dopasowanie motywu jest oferowane dla `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Ogólnosystemowy domyślny edytor możesz ustawić w `Setup > Defaults > Editor`.

## Środowisko

Omarchy umożliwia konfigurację całej gamy środowisk programistycznych przez sekcję _Install > Development_ w Omarchy Menu (`Super + Space`). Znajdziesz tam oczywiście _Ruby on Rails_, ale też wszystkie trzy główne środowiska uruchomieniowe dla JavaScript (Node.js, Bun, Deno), a także popularne frameworki PHP, takie jak Laravel i Symfony. Aha, jest też Go, Rust, Python, Java, Elixir (z Phoenix), .NET, OCaml, Zig, Clojure i Scala. To bardzo szeroki wybór!

Większością tych środowisk zarządza [Mise](https://mise.jdx.dev/). To narzędzie, które pozwala instalować i uruchamiać wiele wersji języka programowania na tej samej maszynie. Działa jak rbenv lub rvm dla Ruby albo virtualenv dla Pythona, ale obsługuje mnóstwo różnych środowisk.

Aby zainstalować na przykład Ruby, uruchomisz `mise use -g ruby`, co zarówno zainstaluje Ruby, jak i ustawi go jako globalną wersję domyślną. Albo, jeśli twój projekt ma plik .ruby-version, możesz po prostu uruchomić `mise i` w katalogu głównym tego projektu.

## Preinstalowane narzędzia CLI

`uv`, Node.js i `playwright-cli` (aby agenty mogły sterować przeglądarką, korzystając z zainstalowanego Chrome) są zainstalowane jako pakiety, a `omarchy update` utrzymuje je w aktualnym stanie wraz z resztą systemu. [Hunk](https://github.com/modem-dev/hunk) oraz narzędzia CLI dla GitHub, Basecamp, Cloudflare i HEY są na wyciągnięcie ręki w _Install > CLI_, a [agenty kodujące](17-ai.md) znajdziesz w _Install > AI > CLI_.

Mise zarządza wyłącznie środowiskami uruchomieniowymi, które skonfigurujesz z poziomu _Install > Development_; Omarchy samodzielnie nic przez niego nie instaluje. Uruchom `omarchy update`, aby zaktualizować je wraz z resztą Omarchy; alias `mup` aktualizuje tylko narzędzia zarządzane przez mise. Aby dodać kolejne narzędzie do własnej konfiguracji, użyj `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) właściwie nie potrzebuje żadnego wstępu. Pozwala uruchamiać odizolowane kontenery, a Omarchy instaluje wszystko, co potrzebne, aby działał dobrze, w tym samego Dockera i [Docker Compose](https://docs.docker.com/compose/).

Domyślnie twój użytkownik *nie* należy do grupy `docker`. Ta grupa to w praktyce root bez hasła — wszystko, co do niej należy, może wykonać `docker run -v /:/host` i przejąć maszynę — więc jeden nieuczciwy skrypt albo zależność uruchomiona jako ty byłaby inaczej tylko o jedno polecenie od roota. Dlatego w wierszu poleceń uruchamiasz Dockera z `sudo` (`sudo docker ps`, `sudo docker compose up`), a narzędzia graficzne komunikujące się z daemonem — VM z Windows — proszą o autoryzację, gdy jej potrzebują. Jeśli chcesz odzyskać wygodę korzystania bez `sudo` i rozumiesz kompromis, włącz ją w **Setup > Security > Sudoless Docker** (lub uruchom `omarchy-setup-security-sudoless-docker`), co po ostrzeżeniu doda cię do grupy `docker`; wtedy zwykłe `docker` i alias `d` znów działają bez `sudo`.

Popularne bazy danych do lokalnego programowania w Dockerze możesz skonfigurować, korzystając z _Install > Development > Docker DB_ w menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) to `gh`, do pracy z repozytoriami, zgłoszeniami i pull requestami z poziomu terminala. _Setup > Git_ instaluje go, gdy zdecydujesz się tam zalogować do GitHuba, albo zainstaluj go osobno z _Install > CLI > GitHub_. Następnie `gh repo clone org/repo` klonuje repozytorium; uruchom `gh --help`, aby poznać jego polecenia.

[Lazygit](https://github.com/jesseduffield/lazygit) jest preinstalowany do pracy z samym Gitem.
