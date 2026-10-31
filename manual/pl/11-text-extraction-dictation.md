# Ekstrakcja tekstu i dyktowanie

### Ekstrakcja tekstu

Naciśnij `Super + Ctrl + PrtScr`, aby zaznaczyć obszar ekranu do wyodrębnienia tekstu. Model OCR tesseract o otwartym kodzie źródłowym szybko przekształci to zaznaczenie w tekst i umieści je w schowku. Potem wystarczy nacisnąć `Super + V`, aby wkleić.

To bardzo przydatne do wyciągania adresów ze stopek obrazów albo numerów telefonów osadzonych w nagłówkach stron internetowych.

 ![text-extraction](images/text-extraction.webp)

### Dyktowanie

W świeżych instalacjach [Superwhisper](https://superwhisper.com/) jest domyślnym zapleczem dyktowania, korzystającym z przetwarzania w chmurze bez pobierania modeli offline. Wybierz Superwhisper lub [Voxtype](https://voxtype.io/) w menu Omarchy przez _Setup > Defaults > Dictation_. Wybranie zaplecza instaluje je w razie potrzeby i ustawia jako domyślne dla dyktowania. Voxtype wczytuje podstawowy model angielski zajmujący 150MB; zmień model poleceniem `voxtype setup model`, a pozostałe ustawienia przez `~/.config/voxtype/config.toml`. Superwhisper otwiera swoje ustawienia, aby wybrać przetwarzanie w chmurze lub lokalne, a OPR dba o aktualizację aplikacji.

Dyktujesz, przytrzymując `Right Alt` albo przełączając poleceniem `Alt + Space`, a podyktowany tekst pojawi się w aktywnym polu wprowadzania. Te skróty korzystają z wybranego zaplecza. Right Alt uruchamia dyktowanie także wtedy, gdy jest używany w akordzie modyfikatorów; do takich akordów używaj Left Alt. W układach klawiatury, w których Right Alt to AltGr, używaj `Alt + Space`, aby AltGr pozostał dostępny podczas pisania. Instalacje z okresu, zanim Alt + Space stało się domyślne, zachowują `F9` do funkcji push-to-talk i `Super + Ctrl + X` do przełączania, dodane do `~/.config/hypr/bindings.lua`; usuń je stamtąd, aby oddać te klawisze aplikacjom.

Te same skróty działają z oboma zapleczami. Wybierz zaplecze przez Setup > Defaults > Dictation. Instalator zaplecza konfiguruje je i zapisuje wybór. Uruchom `omarchy default dictation`, aby sprawdzić, które jest wybrane. Wybór jest zapisywany w `~/.config/omarchy/defaults/dictation`. Świeże instalacje automatycznie wybierają Superwhisper.

Omarchy automatycznie wczytuje integrację pulpitu wybranego zaplecza. Żadna konfiguracja Superwhisper nie jest potrzebna w `~/.config/hypr/`.

Własne przypisania klawiszy i skrypty mogą używać `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. Wybrane zaplecze obsługuje nagrywanie i transkrypcję. Wybranie Superwhisper wyłącza jego natywny skrót przytrzymania i ustawia jego natywne przełączanie na `Ctrl + Alt + Space`, oddzielając je od klawiszy nagrywania Omarchy. Superwhisper wymaga co najmniej jednego natywnego skrótu nagrywania, a jego skrót anulowania pozostaje dostępny.

Dodatkowe zaplecza mogą integrować się bez zmieniania Omarchy. Udostępnij w PATH plik wykonywalny o nazwie `omarchy-dictation-<backend>`, który przyjmuje `start`, `stop` i `toggle` oraz szybko zwraca sterowanie, ze statusem niezerowym w przypadku awarii. Jego instalator konfiguruje dostawcę i po udanej konfiguracji wywołuje `omarchy-dictation-use <backend>`. To zatrzymuje poprzednie zaplecze i zapisuje wybór atomowo; `stop` musi kończyć się powodzeniem, gdy dostawca jest bezczynny lub niedostępny. Nazwy zapleczy używają małych liter, cyfr i myślników. Udostępnij `omarchy-install-dictation-<backend>` do konfiguracji; `omarchy default dictation <backend>` go uruchamia. Dodaj wpis menu Defaults poprzez rozszerzenie menu Omarchy, aby wywoływać ten selektor. Opcjonalna integracja pulpitu może znajdować się w `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
