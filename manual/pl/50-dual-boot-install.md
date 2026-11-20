# Instalacja w trybie Dual Boot

Możesz zainstalować Omarchy na pojedynczej partycji obok Windows lub innych instalacji.

Ta metoda instalacji nadal domyślnie obejmuje szyfrowanie LUKS partycji, więc w praktyce nie różni się od instalacji na całym dysku i po prostu wymaga wolnego miejsca na dysku.

## Zwolnienie miejsca w systemie Windows

Aby zainstalować obok Windows, wpisz `disk management` w menu Start i wybierz opcję **Utwórz i sformatuj partycje dysku twardego**.

 ![dual-boot-1](images/dual-boot-1.webp)

Znajdź odpowiednią partycję, kliknij ją prawym przyciskiem myszy i wybierz **Zmniejsz wolumin**.

![dual-boot-2](images/dual-boot-2.webp)

 Wprowadź wartość, o którą chcesz zmniejszyć wolumin. Pamiętaj, że będzie to rozmiar Twojej przyszłej instalacji Omarchy wraz z partycją rozruchową.

 ![dual-boot-3](images/dual-boot-3.webp)

Gdy skończysz, powinieneś zobaczyć coś takiego, gdzie sekcja 50GB to miejsce, w którym w tym przykładzie zainstalujemy Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalacja Omarchy

Proces instalacji Omarchy jest w praktyce taki sam jak zwykle. Po wybraniu dysku otrzymasz opcję **Instalacja w wolnym miejscu**. Wybierz tę opcję, aby zapobiec wyczyszczeniu całego dysku.

 ![dual-boot-5](images/dual-boot-5.webp)

Potwierdź, że wszystko wygląda dobrze, i poczekaj, aż instalacja zakończy się jak zwykle. To także miejsce, w którym możesz zdecydować się na instalację bez szyfrowania (niezalecane), tak samo jak w przypadku instalacji na całym dysku.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodawanie innych instalacji do bootloadera

Gdy zakończysz instalację Omarchy, zauważysz, że domyślnym bootloaderem jest teraz Limine. Dzięki temu możesz także dodać do Limine opcje dla innych instalacji, takich jak Windows.

Aby dodać inne systemy operacyjne, uruchom `limine-scan` i postępuj zgodnie z monitami, aby dodać wybrane wpisy do konfiguracji Limine. Menu rozruchowe domyślnie pozostaje ukryte i po jednej sekundzie uruchamia Omarchy. Aby wybrać Windows lub inny wpis, naciśnij dowolny klawisz, gdy tylko Limine się uruchomi; gdy pojawi się menu, użyj klawiszy strzałek, aby wybrać wpis, i naciśnij Enter. Jeśli Omarchy uruchomi się, zanim naciśniesz klawisz, uruchom ponownie i spróbuj jeszcze raz.

## Bitlocker

Należy pamiętać, że ta metoda instalacji nie jest zgodna z Bitlocker, ponieważ szyfruje on cały dysk, a nie tylko partycję. Jeśli napotkasz błąd informujący, że Bitlocker jest włączony, uruchom Windows, przejdź do **Ustawienia -> Prywatność i zabezpieczenia -> Szyfrowanie urządzenia** i wyłącz Bitlocker. Odszyfrowanie dysku może potrwać pewien czas.

 ![dual-boot-7](images/dual-boot-7.webp)
