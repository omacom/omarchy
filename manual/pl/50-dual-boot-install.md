# Instalacja Dual Boot

Możesz zainstalować Omarchy na jednej partycji obok Windows lub innych instalacji.

Ta metoda instalacji nadal domyślnie obejmuje szyfrowanie LUKS dla partycji, więc w praktyce nie różni się od instalacji na całym dysku i po prostu wymaga dostępnego wolnego miejsca na dysku.

## Zwalnianie miejsca w Windows

Aby zainstalować obok Windows, wpisz `disk management` w menu Start i wybierz opcję **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Znajdź odpowiednią partycję, kliknij ją prawym przyciskiem myszy i wybierz **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Wprowadź rozmiar, o jaki chcesz zmniejszyć wolumin. Pamiętaj, że będzie to rozmiar Twojej przyszłej instalacji Omarchy wraz z partycją rozruchową.

 ![dual-boot-3](images/dual-boot-3.webp)

Po zakończeniu powinieneś zobaczyć coś takiego, gdzie sekcja 50GB jest miejscem, w którym w tym przykładzie zainstalujemy Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalowanie Omarchy

Proces instalacji Omarchy jest w praktyce taki sam jak zwykle. Po wybraniu dysku otrzymasz opcję **Free space install**. Wybierz tę opcję, aby zapobiec wyczyszczeniu całego dysku.

 ![dual-boot-5](images/dual-boot-5.webp)

Potwierdź, że wszystko wygląda dobrze, i poczekaj na zakończenie instalacji jak zwykle. To jest również miejsce, w którym możesz wybrać instalację bez szyfrowania (niezalecane), tak jak w przypadku instalacji na całym dysku.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodawanie innych instalacji do bootloadera

Po zakończeniu instalacji Omarchy zauważysz, że domyślnym bootloaderem jest teraz Limine. Dzięki temu możesz również dodać do Limine opcje dla innych instalacji, takich jak Windows.

Aby dodać inne systemy operacyjne, uruchom `limine-scan` i postępuj zgodnie z instrukcjami, aby dodać wybrane wpisy do konfiguracji Limine. Menu rozruchowe pozostaje domyślnie ukryte i po jednej sekundzie uruchamia Omarchy. Aby wybrać Windows lub inny wpis, naciśnij dowolny klawisz, gdy tylko uruchomi się Limine; gdy pojawi się menu, użyj klawiszy strzałek, aby wybrać wpis, i naciśnij Enter. Jeśli Omarchy uruchomi się, zanim naciśniesz klawisz, uruchom ponownie i spróbuj jeszcze raz. Jeśli włączyłeś _Setup > Direct Boot_, oprogramowanie układowe całkowicie pomija Limine, więc wybierz Limine z menu rozruchowego BIOS lub uruchom ponownie _Setup > Direct Boot_, aby usunąć wpis.

## Bitlocker

Warto pamiętać, że ta metoda instalacji nie jest zgodna z Bitlocker, ponieważ szyfruje on cały dysk, a nie tylko partycję. Jeśli napotkasz błąd informujący, że Bitlocker jest włączony, uruchom Windows, przejdź do **Settings -> Privacy & Security -> Device encryption** i wyłącz Bitlocker. Odszyfrowanie dysku może zająć trochę czasu.

 ![dual-boot-7](images/dual-boot-7.webp)
