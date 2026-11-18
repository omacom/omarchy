# Aktualizacje

Omarchy i swoje pakiety aktualizujesz przez _Aktualizacja > Omarchy_ w menu Omarchy (`Super + Space`).

Samo Omarchy jest instalowane jako zwykłe pakiety pacman z [Repozytorium pakietów Omarchy](https://github.com/omacom-io/omarchy-pkgs), więc aktualizacja instaluje [najnowsze wydanie Omarchy](https://github.com/omacom/omarchy/releases), uruchamia wszelkie oczekujące migracje, aby zsynchronizować Twój system z najnowszą wersją, i aktualizuje wszystkie pakiety systemowe z [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) i [AUR](https://aur.archlinux.org/) (jeśli masz zainstalowane jakiekolwiek pakiety z AUR).

Gdy pojawią się nowe wydania, po prawej stronie Twojego zegara pojawi się ikona strzałki w kółku. Kliknij ją, a proces aktualizacji się rozpocznie.

![update-available](images/update-available.webp)

### Cztery kanały

Omarchy jest aktualizowane w czterech kanałach: stable, RC, edge i dev. Nowe instalacje zaczynają na kanale stable, który śledzi [oficjalne wydania](https://github.com/omacom/omarchy/releases/), a także [stabilny mirror Arch Omarchy](https://github.com/omacom-io/omarchy-mirror), który działa z miesięcznym opóźnieniem względem najnowszego, dzięki czemu możemy wyłapać wszelkie nowe niezgodności wymagające zmian w konfiguracji, zanim sprawią komuś problemy.

Ale jeśli chcesz pomóc w wyłapywaniu tych potencjalnych problemów, możesz korzystać z kanału edge. Dzięki temu Twoje pakiety Omarchy będą śledzić najnowsze buildy deweloperskie, a Ty będziesz mógł aktualizować się do najnowszych pakietów Arch, gdy tylko staną się dostępne. Powinieneś to robić tylko, jeśli masz doświadczenie z Linuxem i wiesz, jak odzyskać system, który ma problemy.

Przed każdym nowym dużym wydaniem będziemy przeprowadzać końcową walidację na kanale RC. Jeśli chcesz pomóc w ostatnich szlifach, wpadnij na #omarchy-release-candidates na Discordzie.

Wreszcie jest kanał dev, który łączy Omarchy bezpośrednio z checkoutem git kodu źródłowego w `~/omarchy`, w połączeniu z pakietami edge. Powinieneś używać tego kanału tylko, jeśli jesteś doświadczonym użytkownikiem Linuxa, pracujesz bezpośrednio nad Omarchy i jesteś gotów tolerować awarie.

Między kanałami możesz przełączać się za pomocą _Aktualizacja > Kanał_ z menu Omarchy (lub `omarchy-channel-set` w terminalu).

### Przełączanie jąder

Omarchy uruchamia własne jądro `linux-omarchy`, ale obok niego możesz trzymać zainstalowane inne, takie jak standardowe jądro Arch `linux` albo testowany przez Ciebie eksperymentalny build. Gdy jest ich więcej niż jedno, _Aktualizacja > Jądro_ w menu Omarchy wyświetla je z zaznaczeniem obok tego, które uruchamia się domyślnie. Wybierz inne, raz wpisz swoje hasło, a uruchomi się ono po następnym restarcie. Pozostałe jądra zostają w menu rozruchowym, więc nadal możesz wybrać jedno ręcznie, jeśli nowe domyślne sprawi Ci problemy. W terminalu `omarchy-kernel` pokazuje bieżące domyślne, `omarchy-kernel list` pokazuje, co jest zainstalowane, a `omarchy-kernel set <kernel>` służy do przełączania.

### Aktualizacje oprogramowania układowego

Nie tylko Twoje pakiety się starzeją. Wiele laptopów i urządzeń peryferyjnych dostarcza oprogramowanie układowe BIOS, SSD i stacji dokujących za pośrednictwem Linux Vendor Firmware Service, a _Aktualizacja > Firmware_ w menu Omarchy pobierze i zainstaluje wszystko, co czeka na Twój sprzęt. Przy pierwszym uruchomieniu instaluje `fwupd`. Wiele rodzajów oprogramowania układowego można zapisać tylko podczas ponownego uruchomienia, więc nie zdziw się, gdy zostaniesz o nie poproszony.

Gdy musisz zmienić ustawienie w samym BIOS-ie, przytrzymaj `Alt` w menu systemowym (`Super + Escape`), a _Uruchom ponownie_ zamieni się w _Uruchom ponownie do BIOS-u_, co uruchomi komputer ponownie prosto do konfiguracji oprogramowania układowego, bez konieczności wyłapywania właściwego klawisza przy starcie. Z terminala jest to `omarchy system firmware`.

### Ostrzeżenie przed bezpośrednimi aktualizacjami przez pacman/yay

Jeśli znasz już Archa, może Cię kusić, żeby po prostu samemu uruchomić `pacman -Syu` lub `yay -Syu`, ale jeśli to zrobisz, ominą Cię migawka, migracje i aktualizacje konfiguracji, które Omarchy uruchamia razem z nowymi pakietami. Dlatego Omarchy faktycznie zatrzyma bezpośrednią aktualizację systemu i wskaże Ci zamiast tego `omarchy update`. (Jeśli naprawdę wiesz, co robisz, zabezpieczenie powie Ci, jak je ominąć dla jednej transakcji.)

### Wycofywanie nieudanych aktualizacji

Jeśli po wykonaniu aktualizacji kiedykolwiek będziesz mieć problem, możesz wycofać system do migawki wykonanej przed aktualizacją. Po prostu uruchom ponownie komputer i wybierz w menu ładowania rozruchowego migawkę sprzed rozpoczęcia aktualizacji.

![bootloader](images/bootloader.webp)

Jeśli jakimś cudem Twoje pliki konfiguracyjne zostały uszkodzone, możesz też wykonać ponowną instalację Omarchy za pomocą `omarchy reinstall` w terminalu. Spowoduje to ponowne zainstalowanie wszystkich domyślnych pakietów Omarchy, przeniesie Cię na kanał stable i obniży wersję wszystkich pakietów, które są zbyt nowe, oraz zresetuje wszystkie pliki konfiguracyjne. Pamiętaj, że wszystkie Twoje zmiany w konfiguracji użytkownika względem domyślnych ustawień Omarchy zostaną przy tym nadpisane!
