# Aktualizacje

Omarchy i twoje pakiety są utrzymywane na bieżąco za pośrednictwem _Aktualizuj > Omarchy_ w menu Omarchy (`Super + Space`).

Sam Omarchy jest instalowany jako zwykłe pakiety pacman z [Repozytorium Pakietów Omarchy](https://github.com/omacom-io/omarchy-pkgs), więc aktualizacja instaluje [najnowszą wersję Omarchy](https://github.com/omacom/omarchy/releases), uruchamia wszelkie oczekujące migracje, aby zsynchronizować system z najnowszą wersją, i aktualizuje wszystkie pakiety systemowe z [Mirror Arch Omarchy](https://github.com/omacom-io/omarchy-mirror) i [AUR](https://aur.archlinux.org/) (jeśli zainstalowałeś jakiekolwiek pakiety AUR).

Gdy zostaną wydane nowe wersje, po prawej stronie zegara pojawi się ikona strzałki w kółku. Kliknij ją, a rozpocznie się proces aktualizacji.

![update-available](images/update-available.webp)

### Cztery kanały

Omarchy jest aktualizowany wzdłuż czterech kanałów: stable, RC, edge i dev. Nowe instalacje rozpoczynają się na kanale stable, który śledzi [oficjalne wydania](https://github.com/omacom/omarchy/releases/), a także [stabilny mirror Arch Omarchy](https://github.com/omacom-io/omarchy-mirror), który działa miesiąc za najnowszym, abyśmy mogli wyłapać wszelkie nowe niekompatybilności wymagające zmian konfiguracji, zanim spowodują problemy dla ludzi.

Ale jeśli chcesz pomóc wyłapać te potencjalne problemy, możesz działać na kanale edge. To utrzyma twoje pakiety Omarchy śledzące najnowsze kompilacje deweloperskie i pozwoli ci aktualizować do najnowszych pakietów Arch, gdy tylko będą dostępne. Powinieneś robić to tylko, jeśli masz doświadczenie z Linuksem i wiesz, jak odzyskać system, który ma problemy.

Przed każdym nowym głównym wydaniem będziemy przeprowadzać finalną walidację przy użyciu kanału RC. Jeśli chcesz pomóc w finalnym dopracowaniu, wpadnij na #omarchy-release-candidates na Discordzie.

Na koniec jest kanał dev, który łączy Omarchy bezpośrednio z checkoutem git kodu źródłowego w `~/omarchy`, połączonym z pakietami edge. Powinieneś używać tego kanału tylko, jeśli jesteś doświadczonym użytkownikiem Linuksa, pracujesz bezpośrednio nad Omarchy i jesteś gotów tolerować awarie.

Możesz przełączać się między kanałami, używając _Aktualizuj > Channel_ z menu Omarchy (lub `omarchy-channel-set` w terminalu).

### Aktualizacje firmware

Twoje pakiety nie są jedyną rzeczą, która się starzeje. Wiele laptopów i urządzeń peryferyjnych dostarcza firmware BIOS, SSD i stacji dokującej poprzez Linux Vendor Firmware Service, a _Aktualizuj > Firmware_ w menu Omarchy pobierze i zainstaluje wszystko, co twój sprzęt ma w oczekiwaniu. Instaluje `fwupd` przy pierwszym uruchomieniu. Wiele firmware można zapisać tylko podczas ponownego uruchomienia, więc nie dziw się, jeśli zostaniesz o nie poproszony.

### Ostrzeżenie o bezpośrednich aktualizacjach pacman/yay

Jeśli znasz już Arch, możesz mieć pokusę, aby po prostu samodzielnie uruchomić `pacman -Syu` lub `yay -Syu`, ale jeśli to zrobisz, ominiesz snapshot, migracje i aktualizacje konfiguracji, które Omarchy uruchamia razem z nowymi pakietami. Dlatego Omarchy faktycznie zatrzyma bezpośrednią aktualizację systemu i wskaże ci zamiast tego `omarchy update`. (Jeśli naprawdę wiesz, co robisz, strażnik powie ci, jak ominąć go dla pojedynczej transakcji).

### Wycofywanie złych aktualizacji

Jeśli kiedykolwiek będziesz mieć problem po wykonaniu aktualizacji, możesz wycofać system do snapshotu wykonanego przed aktualizacją. Po prostu uruchom ponownie i wybierz snapshot w menu ładowania bootowania sprzed rozpoczęcia aktualizacji.

![bootloader](images/bootloader.webp)

Jeśli w jakiś sposób twoje pliki konfiguracyjne zostały uszkodzone, możesz również wykonać reinstalację Omarchy, używając `omarchy reinstall` w terminalu. To zainstaluje ponownie wszystkie domyślne pakiety Omarchy, umieści cię na stable i obniży wersję wszelkich pakietów, które są zbyt nowe, oraz zresetuje wszystkie pliki konfiguracyjne. Zauważ, że wszystkie twoje zmiany konfiguracji użytkownika w domyślnych ustawieniach Omarchy zostaną nadpisane!
