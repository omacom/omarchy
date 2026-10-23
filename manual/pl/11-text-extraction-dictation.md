# Wyciąganie tekstu i dyktowanie

### Wyciąganie tekstu

Naciśnij `Super + Ctrl + PrtScr`, żeby wybrać obszar ekranu do wyciągnięcia tekstu. Otwarte oprogramowanie OCR tesseract szybko zamieni ten wybór w tekst i umieści go w schowku. Potem po prostu naciśniesz `Super + V`, żeby wkleić.

Jest to bardzo pomocne przy wyciąganiu adresów ze stopek obrazów albo numerów telefonów osadzonych w nagłówkach stron.

 ![text-extraction](images/text-extraction.webp)

### Dyktowanie

Na świeżych instalacjach [Superwhisper](https://superwhisper.com/) jest domyślnym silnikiem dyktowania, używającym przetwarzania w chmurze bez pobierania modeli offline. Wybierasz Superwhisper lub [Voxtype](https://voxtype.io/) przez _Ustawienia > Domyślne > Dyktowanie_ w menu Omarchy. Wybór silnika instaluje go, jeśli trzeba, i czyni go domyślnym dla dyktowania. Voxtype ładuje bazowy model angielski zajmujący 150MB; model zmienisz przez `voxtype setup model`, a pozostałe ustawienia przez `~/.config/voxtype/config.toml`. Superwhisper otwiera swoje ustawienia, żeby wybrać przetwarzanie w chmurze lub lokalne, a OPR utrzymuje aplikację aktualną.

Dyktujesz, trzymając `Right Alt` lub `F9`, albo przełączając przez `Super + Ctrl + X`, a podyktowany tekst pojawi się w skupionym polu wejściowym. Skróty te używają wybranego silnika. Right Alt też zaczyna dyktowanie, gdy jest użyty w akordzie modyfikatorów; do tych akordów używaj Left Alt. Na układach klawiatury, w których Right Alt jest AltGr, użyj `F9`, żeby zachować AltGr do pisania.

Te same skróty działają z każdym silnikiem. Wybierasz swój silnik przez Setup > Defaults > Dictation. Instalator silnika go konfiguruje i zapisuje wybór. Uruchom `omarchy default dictation`, żeby zobaczyć, który jest wybrany. Wybór jest zapisany w `~/.config/omarchy/defaults/dictation`. Świeże instalacje automatycznie wybierają Superwhisper.

Omarchy ładuje integrację pulpitu wybranego silnika automatycznie. W `~/.config/hypr/` nie jest potrzebna żadna konfiguracja Superwhisper.

Niestandardowe przypisania i skrypty mogą używać `omarchy dictation start`, `omarchy dictation stop` oraz `omarchy dictation toggle`. Wybrany silnik obsługuje nagrywanie i transkrypcję. Wybór Superwhisper wyłącza jego natywny skrót przytrzymania i ustawia jego natywne przełączenie na `Alt + Space`, trzymając je z dala od klawiszy nagrywania Omarchy. Superwhisper wymaga co najmniej jednego natywnego skrótu nagrywania, a jego skrót anulowania pozostaje dostępny.

Dodatkowe silniki mogą się integrować bez zmiany Omarchy. Udostępnij na PATH wykonywalny plik o nazwie `omarchy-dictation-<backend>`, który akceptuje `start`, `stop` oraz `toggle` i niezwłocznie wraca, ze statusem niezerowym przy błędzie. Jego instalator konfiguruje dostawcę i po pomyślnej konfiguracji wywołuje `omarchy-dictation-use <backend>`. Zatrzymuje to poprzedni silnik i atomowo zapisuje wybór; `stop` musi się powieść, gdy dostawca jest bezczynny lub niedostępny. Nazwy silników używają małych liter, cyfr i myślników. Udostępnij `omarchy-install-dictation-<backend>` do konfiguracji; `omarchy default dictation <backend>` go uruchamia. Dodaj wpis w menu Domyślne przez rozszerzenie menu Omarchy, żeby wywołać ten selektor. Opcjonalna integracja z pulpitem może mieszkać w `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
