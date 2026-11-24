# Instalacja Dual Boot

Możesz zainstalować Omarchy na jednej partycji obok Windows lub innych instalacji.

Ta metoda instalacji domyślnie nadal obejmuje szyfrowanie LUKS dla partycji, więc w praktyce nie różni się od instalacji na całym dysku i po prostu wymaga dostępnego wolnego miejsca na dysku.

## Zwalnianie miejsca w Windows

Aby zainstalować obok Windows, wpisz `disk management` w menu Start i wybierz opcję **Utwórz i sformatuj partycje dysku twardego**.

 ![dual-boot-1](images/dual-boot-1.webp)

Znajdź odpowiednią partycję, kliknij ją prawym przyciskiem myszy i wybierz **Zmniejsz wolumen**.

![dual-boot-2](images/dual-boot-2.webp)

 Wprowadź wartość, o jaką chcesz zmniejszyć wolumen. Pamiętaj, że będzie to rozmiar Twojej przyszłej instalacji Omarchy wraz z partycją rozruchową.

 ![dual-boot-3](images/dual-boot-3.webp)

Po zakończeniu powinieneś zobaczyć coś takiego, gdzie sekcja 50GB to w tym przykładzie miejsce, w którym zainstalujemy Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalowanie Omarchy

Proces instalacji Omarchy jest w praktyce taki sam jak zwykle. Po wybraniu dysku otrzymasz opcję **Free space install**. Wybierz tę opcję, aby zapobiec wyczyszczeniu całego dysku.

 ![dual-boot-5](images/dual-boot-5.webp)

Potwierdź, że wszystko wygląda dobrze, i poczekaj na zakończenie instalacji jak zwykle. To również miejsce, w którym możesz zdecydować się na instalację bez szyfrowania (niezalecane), tak samo jak przy instalacji na całym dysku.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodawanie innych instalacji do bootloadera

Po zakończeniu instalacji Omarchy zauważysz, że bootloader Limine jest teraz domyślny. Dzięki temu możesz również dodać do Limine opcje dla innych instalacji, takich jak Windows.

Aby dodać inne systemy operacyjne, uruchom `limine-scan` i postępuj zgodnie z instrukcjami, aby dodać wybrane wpisy do konfiguracji Limine. Menu rozruchowe domyślnie pozostaje ukryte i uruchamia Omarchy po jednej sekundzie. Aby wybrać Windows lub inny wpis, naciśnij dowolny klawisz, gdy tylko uruchomi się Limine; gdy pojawi się menu, użyj klawiszy strzałek, aby wybrać wpis, i naciśnij Enter. Jeśli Omarchy uruchomi się, zanim naciśniesz klawisz, uruchom ponownie komputer i spróbuj jeszcze raz.

## Bitlocker

Należy pamiętać, że ta metoda instalacji nie jest zgodna z Bitlocker, ponieważ szyfruje on cały dysk, a nie tylko partycję. Jeśli napotkasz błąd informujący, że Bitlocker jest włączony, uruchom Windows, przejdź do **Settings -> Privacy & Security -> Device encryption** i wyłącz Bitlocker. Odszyfrowanie dysku może zająć trochę czasu.

 ![dual-boot-7](images/dual-boot-7.webp)

## Ponowna instalacja Windows

Jeśli ten komputer był dostarczony z Windows, jego klucz produktu jest przechowywany w oprogramowaniu układowym. Uruchom `omarchy windows key`, aby go wyświetlić, dzięki czemu będziesz mógł ponownie aktywować Windows, jeśli kiedykolwiek zainstalujesz go ponownie na tym komputerze.
