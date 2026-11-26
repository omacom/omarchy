# Wyodrębnianie tekstu i dyktowanie

### Wyodrębnianie tekstu

Naciśnij `Super + Ctrl + PrtScr`, aby zaznaczyć region na ekranie do wyodrębnienia tekstu. Model OCR tesseract o otwartym kodzie źródłowym szybko przekształci to zaznaczenie w tekst i umieści je w schowku. Potem wystarczy nacisnąć `Super + V`, aby wkleić.

Jest to bardzo pomocne przy wyciąganiu adresów ze stopek obrazów lub numerów telefonów osadzonych w nagłówkach stron internetowych.

 ![text-extraction](images/text-extraction.webp)

### Dyktowanie

W nowych instalacjach [Superwhisper](https://superwhisper.com/) jest domyślnym zapleczem dyktowania, korzystającym z przetwarzania w chmurze bez pobierania modeli offline. Wybierz Superwhisper, [Voxtype](https://voxtype.io/) lub [Hex](https://anoma.ly/hex/) w _Setup > Defaults > Dictation_ w menu Omarchy. Wybranie zaplecza instaluje je w razie potrzeby i ustawia je jako domyślne do dyktowania. Voxtype wczytuje podstawowy model języka angielskiego, który zajmuje 150MB; zmień model za pomocą `voxtype setup model`, a inne ustawienia przez `~/.config/voxtype/config.toml`. Superwhisper otwiera swoje ustawienia, aby wybrać przetwarzanie w chmurze lub lokalne, a OPR dba o aktualizowanie aplikacji. Hex pobiera swój model mowy działający na urządzeniu podczas konfiguracji i działa jako usługa użytkownika `hex.service`; otwórz jego okno z ikony zasobnika na pasku lub uruchamiając `hex`, aby zmienić model i inne ustawienia.

Dyktujesz, przytrzymując `Right Alt` albo przełączając za pomocą `Alt + Space`, a podyktowany tekst pojawi się w aktywnym polu wprowadzania. Te skróty korzystają z wybranego zaplecza. Right Alt również rozpoczyna dyktowanie, gdy jest używany w kombinacji modyfikatorów; do takich kombinacji używaj Left Alt. W układach klawiatury, w których Right Alt to AltGr, także gdy taki układ jest jednym z tych, na które się przełączasz, przytrzymaj go samodzielnie przez chwilę, aby dyktować; AltGr naciśnięty razem z innym klawiszem nadal wpisuje jego znak. Instalacje sprzed czasu, gdy `Alt + Space` stało się domyślne, zachowują `F9` do push-to-talk i `Super + Ctrl + X` do przełączania, dodane do `~/.config/hypr/bindings.lua`, gdzie to `Super + Ctrl + X` zajmuje miejsce panelu agentów; usuń je tam, aby oddać te klawisze aplikacjom i panelowi.

Te same skróty działają z każdym zapleczem. Wybierz zaplecze w Setup > Defaults > Dictation. Instalator zaplecza konfiguruje je i zapisuje wybór. Uruchom `omarchy default dictation`, aby zobaczyć, które jest wybrane. Wybór jest zapisywany w `~/.config/omarchy/defaults/dictation`. Nowe instalacje automatycznie wybierają Superwhisper.

Omarchy automatycznie wczytuje integrację pulpitu wybranego zaplecza. Żadna konfiguracja Superwhisper nie jest potrzebna w `~/.config/hypr/`.

Niestandardowe powiązania i skrypty mogą używać `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. Wybrane zaplecze obsługuje nagrywanie i transkrypcję. Wybranie Superwhisper wyłącza jego natywny skrót przytrzymywania i ustawia jego natywne przełączanie na `Ctrl + Alt + Space`, utrzymując je oddzielnie od klawiszy nagrywania Omarchy. Superwhisper wymaga co najmniej jednego natywnego skrótu nagrywania, a jego skrót anulowania pozostaje dostępny.

Dodatkowe zaplecza mogą integrować się bez zmieniania Omarchy. Udostępnij plik wykonywalny o nazwie `omarchy-dictation-<backend>` w PATH, który przyjmuje `start`, `stop` i `toggle` oraz szybko zwraca wynik, ze statusem niezerowym w razie niepowodzenia. Jego instalator konfiguruje dostawcę i wywołuje `omarchy-dictation-use <backend>` po pomyślnej konfiguracji. Powoduje to zatrzymanie poprzedniego zaplecza i atomowe zapisanie wyboru; `stop` musi zakończyć się powodzeniem, gdy dostawca jest bezczynny lub niedostępny. Nazwy zapleczy używają małych liter, cyfr i myślników. Udostępnij `omarchy-install-dictation-<backend>` do konfiguracji; `omarchy default dictation <backend>` uruchamia go. Dodaj wpis menu Defaults poprzez rozszerzenie menu Omarchy, aby wywołać ten selektor. Opcjonalna integracja pulpitu może znajdować się w `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
