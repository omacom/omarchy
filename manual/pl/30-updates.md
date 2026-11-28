# Aktualizacje

Omarchy i Twoje pakiety są aktualizowane przez _Update > Omarchy_ w menu Omarchy (`Super + Space`).

Omarchy samo jest instalowane jako zwykłe pakiety pacman z [repozytorium pakietów Omarchy](https://github.com/omacom-io/omarchy-pkgs), więc aktualizacja instaluje [najnowsze wydanie Omarchy](https://github.com/omacom/omarchy/releases), uruchamia wszelkie oczekujące migracje, aby zsynchronizować system z najnowszą wersją, i aktualizuje wszystkie pakiety systemowe z [mirror Arch Omarchy](https://github.com/omacom-io/omarchy-mirror) i [AUR](https://aur.archlinux.org/) (jeśli masz zainstalowane jakiekolwiek pakiety z AUR).

Kiedy pojawiają się nowe wydania, po prawej stronie zegara pojawi się ikona strzałki w kole. Kliknij ją, a proces aktualizacji się rozpocznie.

![update-available](images/update-available.webp)

### Cztery kanały

Omarchy jest aktualizowane w czterech kanałach: stable, RC, edge i dev. Nowe instalacje zaczynają na kanale stable, który śledzi [oficjalne wydania](https://github.com/omacom/omarchy/releases/), a także [stabilny mirror Arch Omarchy](https://github.com/omacom-io/omarchy-mirror), który jest opóźniony o miesiąc względem najnowszych wersji, abyśmy mogli wyłapać wszelkie nowe niezgodności wymagające zmian w konfiguracji, zanim spowodują problemy u użytkowników.

Ale jeśli chcesz pomóc w wykrywaniu tych potencjalnych problemów, możesz korzystać z kanału edge. Dzięki temu Twoje pakiety Omarchy będą śledzić najnowsze kompilacje deweloperskie i umożliwią aktualizację do najnowszych pakietów Arch, gdy tylko staną się dostępne. Powinieneś to robić tylko, jeśli masz doświadczenie z Linuksem i wiesz, jak odzyskać system, który ma problemy.

Przed każdym nowym ważnym wydaniem będziemy przeprowadzać końcową walidację przy użyciu kanału RC. Jeśli chcesz pomóc w końcowym dopracowaniu, wpadnij na #omarchy-release-candidates na Discordzie.

Na koniec jest kanał dev, który łączy Omarchy bezpośrednio z kopią kodu źródłowego pobraną przez git w `~/omarchy`, w połączeniu z pakietami edge. Powinieneś używać tego kanału tylko, jeśli jesteś doświadczonym użytkownikiem Linuksa, pracujesz bezpośrednio nad Omarchy i jesteś gotów tolerować awarie.

Możesz przełączać się między kanałami, używając _Update > Channel_ w menu Omarchy (lub `omarchy channel set <stable|rc|edge|dev>` w terminalu, a `omarchy channel current` sprawdzi, gdzie jesteś).

### Przełączanie jąder

Omarchy uruchamia własne jądro `linux-omarchy`, ale możesz mieć obok niego zainstalowane inne, na przykład standardowe jądro Arch `linux` lub eksperymentalną kompilację, którą testujesz. Gdy jest ich więcej niż jedno, _Update > Kernel_ w menu Omarchy wyświetla ich listę z zaznaczeniem obok tego, które uruchamia się domyślnie. Wybierz inne, wprowadź hasło raz, a uruchomi się po następnym ponownym uruchomieniu. Pozostałe jądra pozostają w menu rozruchowym, więc nadal możesz wybrać jedno ręcznie, jeśli nowe domyślne sprawi Ci problemy. W terminalu `omarchy kernel` pokazuje bieżące domyślne, `omarchy kernel list` pokazuje, co jest zainstalowane, a `omarchy kernel set <kernel>` służy do przełączenia.

### Aktualizacje oprogramowania sprzętowego

Nie tylko pakiety się starzeją. Wiele laptopów i urządzeń peryferyjnych dostarcza oprogramowanie sprzętowe BIOS, SSD i stacji dokujących przez Linux Vendor Firmware Service, a _Update > Firmware_ w menu Omarchy pobierze i zainstaluje wszystko, co czeka na Twój sprzęt. Przy pierwszym uruchomieniu instaluje `fwupd`. Wiele oprogramowania sprzętowego można zapisać tylko podczas ponownego uruchomienia, więc nie zdziw się, jeśli zostaniesz o nie poproszony.

Gdy potrzebujesz zmienić ustawienie w samym BIOS-ie, przytrzymaj `Alt` w menu systemowym (`Super + Escape`), a _Reboot_ zmieni się w _Reboot to BIOS_, co spowoduje ponowne uruchomienie bezpośrednio do konfiguracji oprogramowania sprzętowego, bez konieczności trafiania w odpowiedni klawisz przy rozruchu. Z terminala jest to `omarchy system firmware`.

### Ostrzeżenie o bezpośrednich aktualizacjach pacman/yay

Jeśli znasz już Arch, możesz mieć pokusę, aby po prostu samodzielnie uruchomić `pacman -Syu` lub `yay -Syu`, ale jeśli to zrobisz, ominie Cię migawka, migracje i aktualizacje konfiguracji, które Omarchy wykonuje razem z nowymi pakietami. Dlatego Omarchy faktycznie przerwie bezpośrednią aktualizację systemu i wskaże Ci zamiast tego `omarchy update`. (Jeśli naprawdę wiesz, co robisz, zabezpieczenie powie Ci, jak je ominąć dla jednej transakcji.)

### Wycofywanie złych aktualizacji

Jeśli kiedykolwiek będziesz mieć problem po wykonaniu aktualizacji, możesz przywrócić system do migawki wykonanej przed aktualizacją. Po prostu uruchom ponownie i wybierz migawkę w menu programu ładującego sprzed rozpoczęcia aktualizacji.

![bootloader](images/bootloader.webp)

Jeśli w jakiś sposób Twoje pliki konfiguracyjne zostały uszkodzone, możesz także wykonać ponowną instalację Omarchy, używając `omarchy reinstall` w terminalu. Spowoduje to ponowne zainstalowanie wszystkich domyślnych pakietów Omarchy, przełączenie Cię na stable (edge na Apple Silicon) i obniżenie wersji wszelkich pakietów, które są zbyt nowe, oraz zresetowanie wszystkich plików konfiguracyjnych. Pamiętaj, że wszystkie Twoje zmiany użytkownika w konfiguracji domyślnej Omarchy zostaną przy tym nadpisane!
