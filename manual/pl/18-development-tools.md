# Narzędzia programistyczne

## Alternatywne edytory

Omarchy jest dostarczane z Plain jako domyślnym edytorem w nowych instalacjach i z preinstalowanym [Neovim](https://neovim.io/), ale jeśli chcesz czegoś bardziej mainstreamowego i znajomego, możesz uruchomić Omarchy Menu (`Super + Space`) i zobaczyć opcje w _Install > Editor_. Mamy tam wymienione VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Jeśli nie znajdziesz tego, czego szukasz, zajrzyj do _Install > Package_ i sprawdź, czy nie ma tego w pakiecie Arch (a jeśli nie, spróbuj _Install > AUR_, aby sprawdzić AUR).

Oryginalny edytor `vi` jest również dostępny od razu po instalacji. Uruchom `vi filename`, aby edytować plik w terminalu.

Dopasowywanie motywu jest oferowane dla `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Ogólnosystemowy domyślny edytor możesz ustawić w `Setup > Defaults > Editor`.

## Środowisko

Omarchy obsługuje konfigurowanie całej gamy środowisk programistycznych za pośrednictwem sekcji _Install > Development_ w Omarchy Menu (`Super + Space`). Oczywiście znajdziesz tam _Ruby on Rails_, ale także wszystkie trzy główne środowiska uruchomieniowe dla JavaScript (Node.js, Bun, Deno), jak również popularne frameworki PHP, takie jak Laravel i Symfony. Och, a jest też Go, Rust, Python, Java, Elixir (z Phoenix), .NET, OCaml, Zig, Clojure i Scala. To bardzo szeroki wybór!

Większość tych środowisk jest zarządzana przez [Mise](https://mise.jdx.dev/). To narzędzie, które pozwala instalować i uruchamiać wiele wersji języka programowania na tej samej maszynie. To jak rbenv lub rvm dla Ruby albo virtualenv dla Pythona, ale działa dla całej masy różnych środowisk.

Aby zainstalować, powiedzmy, Ruby, uruchomisz `mise use -g ruby`, co zarówno zainstaluje Ruby, jak i ustawi je jako globalną wersję domyślną. Albo, jeśli Twój projekt ma plik .ruby-version, możesz po prostu uruchomić `mise i` w katalogu głównym tego projektu.

## Preinstalowane narzędzia CLI

`uv`, Node.js i `playwright-cli` (do tego, by agenci sterowali przeglądarką, używając zainstalowanego Chrome) są zainstalowane jako pakiety, a `omarchy update` utrzymuje je w aktualności wraz z resztą systemu. `ghui`, [Hunk](https://github.com/modem-dev/hunk) oraz CLI dla Basecamp, Cloudflare i HEY są o jedno wybranie stąd w _Install > CLI_, a [agenty kodujące](17-ai.md) w _Install > AI > CLI_.

mise zarządza wyłącznie środowiskami uruchomieniowymi, które skonfigurujesz w _Install > Development_; Omarchy samo z siebie nie instaluje przez nie niczego. Uruchom `omarchy update`, aby zaktualizować je wraz z resztą Omarchy; alias `mup` aktualizuje wyłącznie narzędzia zarządzane przez mise. Aby dodać kolejne narzędzie do własnej konfiguracji, użyj `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) chyba nie potrzebuje żadnego wprowadzenia. Pozwala uruchamiać izolowane kontenery, a Omarchy instaluje wszystko, co potrzebne, aby dobrze go uruchamiać, w tym samego Dockera i [Docker Compose](https://docs.docker.com/compose/).

Domyślnie Twój użytkownik *nie* należy do grupy `docker`. Ta grupa to w praktyce root bez hasła — wszystko, co do niej należy, może wykonać `docker run -v /:/host` i przejąć maszynę — więc jeden nieuczciwy skrypt albo zależność uruchomiona jako Ty byłaby w przeciwnym razie o jedno polecenie od roota. Dlatego w wierszu poleceń uruchamiasz Dockera z `sudo` (`sudo docker ps`, `sudo docker compose up`), a narzędzia graficzne, które komunikują się z demonem — VM z Windows — proszą o autoryzację, gdy jej potrzebują. Jeśli chcesz z powrotem wygody konfiguracji bez grupy i rozumiesz kompromis, włącz ją w **Setup > Security > Sudoless Docker** (albo uruchom `omarchy-setup-security-sudoless-docker`), co po ostrzeżeniu doda Cię do grupy `docker`; wtedy zwykłe `docker` i alias `d` znów działają bez `sudo`.

Typowe bazy danych do lokalnego programowania w Dockerze możesz skonfigurować, używając _Install > Development > Docker DB_ w menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) to `gh`, do pracy z repozytoriami, zgłoszeniami i pull requestami z terminala. _Setup > Git_ instaluje je, gdy zdecydujesz się tam zalogować do GitHuba, a potem `gh repo clone org/repo` klonuje repozytorium. Uruchom `gh --help`, aby poznać jego polecenia.

_Install > CLI > GitHub_ instaluje GitHub CLI, `gh`, wraz z `ghui`, terminalowym interfejsem do pull requestów. [Lazygit](https://github.com/jesseduffield/lazygit) jest preinstalowany do pracy z samym Gitem.
