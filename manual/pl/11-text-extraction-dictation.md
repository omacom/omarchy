# Ekstrakcja tekstu i dyktowanie

### Ekstrakcja tekstu

Naciśnij `Super + Ctrl + PrtScr`, aby zaznaczyć obszar na ekranie do ekstrakcji tekstu. Model OCR open source tesseract szybko przekształci to zaznaczenie w tekst i umieści je w schowku. Potem wystarczy nacisnąć `Super + V`, aby wkleić.

Jest to bardzo pomocne przy wyciąganiu adresów ze stopek obrazów lub numerów telefonów osadzonych w nagłówkach stron internetowych.

 ![text-extraction](images/text-extraction.webp)

### Dyktowanie

W nowych instalacjach domyślnym backendem dyktowania jest [Superwhisper](https://superwhisper.com/), korzystający z przetwarzania w chmurze bez pobierania modeli offline. Wybierz Superwhisper, [Voxtype](https://voxtype.io/) lub [Hex](https://anoma.ly/hex/) w menu Omarchy przez _Konfiguracja > Domyślne > Dyktowanie_. Wybranie backendu zainstaluje go w razie potrzeby i ustawi jako domyślny do dyktowania. Voxtype wczytuje bazowy model angielski, który zajmuje 150MB; zmień model poleceniem `voxtype setup model`, a inne ustawienia przez `~/.config/voxtype/config.toml`. Superwhisper otwiera swoje ustawienia, aby wybrać przetwarzanie w chmurze lub lokalnie, a OPR utrzymuje aplikację w aktualnej wersji. Hex pobiera swój model mowy działający na urządzeniu podczas konfiguracji i działa jako usługa użytkownika `hex.service`; otwórz jego okno z ikony w zasobniku na pasku lub uruchom `hex`, aby zmienić model i inne ustawienia.

Dyktujesz, przytrzymując `Right Alt` lub przełączając za pomocą `Alt + Space`, a podyktowany tekst pojawi się w aktywnym polu tekstowym. Skróty te korzystają z wybranego backendu. Right Alt uruchamia dyktowanie także wtedy, gdy jest użyty w kombinacji z modyfikatorem; do takich kombinacji używaj Left Alt. W układach klawiatury, w których Right Alt to AltGr, używaj `Alt + Space`, aby AltGr pozostał dostępny do pisania. Instalacje z czasów, zanim Alt + Space stał się domyślny, zachowują `F9` do funkcji „naciśnij i mów” oraz `Super + Ctrl + X` do przełączania, dodane do `~/.config/hypr/bindings.lua`; usuń je tam, aby oddać te klawisze aplikacjom.

Te same skróty działają z każdym backendem. Wybierz backend w Konfiguracja > Domyślne > Dyktowanie. Instalator backendu konfiguruje go i zapisuje wybór. Uruchom `omarchy default dictation`, aby sprawdzić, który jest wybrany. Wybór jest zapisywany w `~/.config/omarchy/defaults/dictation`. Nowe instalacje automatycznie wybierają Superwhisper.

Omarchy automatycznie wczytuje integrację pulpitu wybranego backendu. W `~/.config/hypr/` nie jest potrzebna żadna konfiguracja Superwhisper.

Własne skróty i skrypty mogą używać `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. Wybrany backend obsługuje nagrywanie i transkrypcję. Wybranie Superwhisper wyłącza jego natywny skrót przytrzymania i ustawia jego natywne przełączanie na `Ctrl + Alt + Space`, dzięki czemu pozostaje oddzielone od klawiszy nagrywania Omarchy. Superwhisper wymaga co najmniej jednego natywnego skrótu nagrywania, a jego skrót anulowania pozostaje dostępny.

Dodatkowe backendy mogą integrować się bez modyfikowania Omarchy. Udostępnij w PATH plik wykonywalny o nazwie `omarchy-dictation-<backend>`, który przyjmuje `start`, `stop` i `toggle` i szybko kończy działanie, ze statusem niezerowym w przypadku błędu. Jego instalator konfiguruje dostawcę i po pomyślnej konfiguracji wywołuje `omarchy-dictation-use <backend>`. Zatrzymuje to poprzedni backend i atomowo zapisuje wybór; `stop` musi kończyć się powodzeniem, gdy dostawca jest bezczynny lub niedostępny. Nazwy backendów używają małych liter, cyfr i myślników. Udostępnij `omarchy-install-dictation-<backend>` do konfiguracji; `omarchy default dictation <backend>` go uruchamia. Dodaj wpis w menu Domyślne za pomocą rozszerzenia menu Omarchy, aby wywoływał ten selektor. Opcjonalna integracja pulpitu może znajdować się w `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
