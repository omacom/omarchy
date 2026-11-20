# Wyodrębnianie tekstu i dyktowanie

### Wyodrębnianie tekstu

Naciśnij `Super + Ctrl + PrtScr`, aby zaznaczyć obszar na ekranie do wyodrębnienia tekstu. Model OCR open source tesseract szybko przekształci ten zaznaczony obszar w tekst i umieści go w schowku. Potem wystarczy nacisnąć `Super + V`, aby wkleić.

To bardzo przydatne do wyciągania adresów ze stopek obrazów albo numerów telefonów osadzonych w nagłówkach stron internetowych.

 ![text-extraction](images/text-extraction.webp)

### Dyktowanie

W nowych instalacjach [Superwhisper](https://superwhisper.com/) jest domyślnym backendem dyktowania, korzystającym z przetwarzania w chmurze bez pobierania modeli offline. Wybierz Superwhisper, [Voxtype](https://voxtype.io/) lub [Hex](https://anoma.ly/hex/) w _Konfiguracja > Domyślne > Dyktowanie_ w menu Omarchy. Wybór backendu instaluje go w razie potrzeby i ustawia go jako domyślny do dyktowania. Voxtype wczytuje podstawowy model angielski zajmujący 150MB; zmień model poleceniem `voxtype setup model`, a inne ustawienia przez `~/.config/voxtype/config.toml`. Superwhisper otwiera swoje ustawienia, aby wybrać przetwarzanie w chmurze lub lokalne, a OPR utrzymuje aplikację w aktualnej wersji. Hex pobiera swój model mowy działający na urządzeniu podczas konfiguracji i działa jako usługa użytkownika `hex.service`; otwórz jego okno z ikony w zasobniku na pasku lub uruchamiając `hex`, aby zmienić model i inne ustawienia.

Dyktujesz, przytrzymując `Right Alt` albo przełączając za pomocą `Alt + Space`, a podyktowany tekst pojawi się w aktywnym obszarze wprowadzania. Te skróty korzystają z wybranego backendu. Prawy Alt również uruchamia dyktowanie, gdy jest użyty w kombinacji z modyfikatorem; do takich kombinacji używaj lewego Alt. W układach klawiatury, w których prawy Alt to AltGr, używaj `Alt + Space`, aby AltGr pozostał dostępny podczas pisania. Instalacje sprzed czasu, gdy Alt + Space stał się ustawieniem domyślnym, zachowują `F9` do push-to-talk i `Super + Ctrl + X` do przełączania, dodane do `~/.config/hypr/bindings.lua`, gdzie to `Super + Ctrl + X` zajmuje miejsce panelu agentów; usuń je tam, aby oddać te klawisze aplikacjom i panelowi.

Te same skróty działają z każdym backendem. Wybierz backend przez Konfiguracja > Domyślne > Dyktowanie. Instalator backendu konfiguruje go i zapisuje wybór. Uruchom `omarchy default dictation`, aby zobaczyć, który jest wybrany. Wybór jest zapisywany w `~/.config/omarchy/defaults/dictation`. Nowe instalacje automatycznie wybierają Superwhisper.

Omarchy automatycznie wczytuje integrację pulpitową wybranego backendu. Żadna konfiguracja Superwhisper nie jest potrzebna w `~/.config/hypr/`.

Niestandardowe przypisania i skrypty mogą używać `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. Wybrany backend obsługuje nagrywanie i transkrypcję. Wybranie Superwhisper wyłącza jego natywny skrót przytrzymania i ustawia jego natywne przełączanie na `Ctrl + Alt + Space`, utrzymując je oddzielnie od klawiszy nagrywania Omarchy. Superwhisper wymaga co najmniej jednego natywnego skrótu nagrywania, a jego skrót anulowania pozostaje dostępny.

Dodatkowe backendy mogą się integrować bez zmieniania Omarchy. Udostępnij plik wykonywalny o nazwie `omarchy-dictation-<backend>` w PATH, który przyjmuje `start`, `stop` i `toggle` i niezwłocznie zwraca sterowanie, ze statusem niezerowym w przypadku niepowodzenia. Jego instalator konfiguruje dostawcę i po pomyślnej konfiguracji wywołuje `omarchy-dictation-use <backend>`. Zatrzymuje to poprzedni backend i atomowo zapisuje wybór; `stop` musi zakończyć się pomyślnie, gdy dostawca jest bezczynny lub niedostępny. Nazwy backendów używają małych liter, cyfr i myślników. Udostępnij `omarchy-install-dictation-<backend>` do konfiguracji; `omarchy default dictation <backend>` go uruchamia. Dodaj pozycję menu Domyślne przez rozszerzenie menu Omarchy, aby wywołać ten selektor. Opcjonalna integracja pulpitowa może znajdować się w `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
