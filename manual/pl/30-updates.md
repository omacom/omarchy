# Aktualizacje

Omarchy i Twoje pakiety są na bieżąco aktualizowane przez _Aktualizacja > Omarchy_ w menu Omarchy (`Super + Space`).

Samo Omarchy jest instalowane jako zwykłe pakiety pacman z [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs), więc aktualizacja instaluje [najnowsze wydanie Omarchy](https://github.com/omacom/omarchy/releases), uruchamia wszelkie oczekujące migracje, aby zsynchronizować Twój system z najnowszą wersją, oraz aktualizuje wszystkie pakiety systemowe z [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) i [AUR](https://aur.archlinux.org/) (jeśli masz zainstalowane jakiekolwiek pakiety AUR).

Gdy pojawią się nowe wydania, po prawej stronie zegara pojawi się ikona strzałki w okręgu. Kliknij ją, a proces aktualizacji się rozpocznie.

![update-available](images/update-available.webp)

### Cztery kanały

Omarchy jest aktualizowane w czterech kanałach: stable, RC, edge i dev. Nowe instalacje zaczynają na kanale stable, który śledzi [oficjalne wydania](https://github.com/omacom/omarchy/releases/), a także [stabilne mirror Omarchy Arch](https://github.com/omacom-io/omarchy-mirror), które jest opóźnione o miesiąc względem najnowszego, dzięki czemu możemy wyłapać wszelkie nowe niezgodności wymagające zmian w konfiguracji, zanim sprawią komuś problemy.

Jeśli jednak chcesz pomóc w wykrywaniu tych potencjalnych problemów, możesz korzystać z kanału edge. Dzięki temu Twoje pakiety Omarchy będą śledzić najnowsze buildy deweloperskie, a Ty będziesz mógł aktualizować do najnowszych pakietów Arch, gdy tylko staną się dostępne. Powinieneś to robić tylko wtedy, gdy masz doświadczenie z Linux i wiesz, jak odzyskać system, w którym wystąpiły problemy.

Przed każdym nowym większym wydaniem będziemy przeprowadzać finalną walidację przy użyciu kanału RC. Jeśli chcesz pomóc w finalnym dopracowywaniu, wpadnij na #omarchy-release-candidates na Discord.

Na koniec jest kanał dev, który łączy Omarchy bezpośrednio z checkout git kodu źródłowego w `~/omarchy`, w połączeniu z pakietami edge. Powinieneś używać tego kanału tylko wtedy, gdy jesteś doświadczonym użytkownikiem Linux, pracujesz bezpośrednio nad Omarchy i jesteś gotów tolerować awarie.

Możesz przełączać się między kanałami za pomocą _Aktualizacja > Kanał_ w menu Omarchy (lub `omarchy-channel-set` w terminalu).

### Przełączanie kerneli

Omarchy uruchamia własny kernel `linux-omarchy`, ale możesz mieć obok niego zainstalowane inne, takie jak standardowy kernel Arch `linux` lub eksperymentalny build, który testujesz. Gdy jest ich więcej niż jeden, _Aktualizacja > Kernel_ w menu Omarchy wyświetla je z zaznaczeniem obok tego, który uruchamia się domyślnie. Wybierz inny, raz wpisz swoje hasło, a uruchomi się po następnym restarcie. Pozostałe kernele pozostają w menu rozruchowym, więc nadal możesz wybrać jeden ręcznie, jeśli nowy domyślny sprawi Ci problemy. W terminalu `omarchy-kernel` pokazuje bieżący domyślny, `omarchy-kernel list` pokazuje, co jest zainstalowane, a `omarchy-kernel set <kernel>` służy do przełączania.

### Aktualizacje firmware

Nie tylko Twoje pakiety się starzeją. Wiele laptopów i urządzeń peryferyjnych dostarcza firmware BIOS, SSD i stacji dokujących przez Linux Vendor Firmware Service, a _Aktualizacja > Firmware_ w menu Omarchy pobierze i zainstaluje wszystko, co czeka na Twój sprzęt. Przy pierwszym uruchomieniu instaluje `fwupd`. Sporo firmware można zapisać tylko podczas restartu, więc nie zdziw się, jeśli zostaniesz o niego poproszony.

### Ostrzeżenie o bezpośrednich aktualizacjach pacman/yay

Jeśli znasz już Arch, może Cię kusić, aby po prostu samemu uruchomić `pacman -Syu` lub `yay -Syu`, ale jeśli to zrobisz, pominiesz snapshot, migracje i aktualizacje konfiguracji, które Omarchy uruchamia razem z nowymi pakietami. Dlatego Omarchy faktycznie zatrzyma bezpośrednią aktualizację systemu i zamiast tego wskaże Ci `omarchy update`. (Jeśli naprawdę wiesz, co robisz, zabezpieczenie powie Ci, jak je ominąć dla jednej transakcji.)

### Wycofywanie złych aktualizacji

Jeśli kiedykolwiek będziesz mieć problem po wykonaniu aktualizacji, możesz wycofać system do snapshotu wykonanego przed aktualizacją. Po prostu uruchom ponownie i wybierz w menu ładowania bootloadera snapshot sprzed rozpoczęcia aktualizacji.

![bootloader](images/bootloader.webp)

Jeśli w jakiś sposób Twoje pliki konfiguracyjne zostały uszkodzone, możesz także wykonać ponowną instalację Omarchy za pomocą `omarchy reinstall` w terminalu. Spowoduje to ponowną instalację wszystkich domyślnych pakietów Omarchy, przełączenie Cię na stable i obniżenie wersji wszelkich pakietów, które są zbyt nowe, oraz zresetowanie wszystkich plików konfiguracyjnych. Pamiętaj, że wszystkie zmiany konfiguracji użytkownika wprowadzone do domyślnych ustawień Omarchy zostaną przy tym nadpisane!
