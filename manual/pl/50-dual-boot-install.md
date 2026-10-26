# Instalacja równoległa (dual boot)

Możesz zainstalować Omarchy na pojedynczej partycji obok Windowsa albo innych instalacji.

Ta metoda instalacji nadal dostarcza domyślnie szyfrowanie LUKS dla partycji, więc w praktyce niczym się nie różni od instalacji na całym dysku i po prostu wymaga wolnego miejsca na dysku.

## Zwalnianie miejsca w Windowsie

Aby zainstalować obok Windowsa, wpisz `disk management` w menu Start i wybierz opcję **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Znajdź odpowiednią partycję, kliknij ją prawym przyciskiem myszy i wybierz **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Wprowadź ilość, o jaką chcesz zmniejszyć wolumen. Pamiętaj, że będzie to rozmiar twojej przyszłej instalacji Omarchy łącznie z partycją rozruchową.

 ![dual-boot-3](images/dual-boot-3.webp)

Gdy skończysz, powinieneś zobaczyć coś takiego, gdzie sekcja 50GB jest miejscem, w którym w tym przykładzie zainstalujemy Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalacja Omarchy

Proces instalacji Omarchy wygląda w praktyce tak samo jak zwykle. Po wybraniu dysku dostaniesz opcję **Free space install**. Wybierz tę opcję, aby zapobiec wyczyszczeniu całego dysku.

 ![dual-boot-5](images/dual-boot-5.webp)

Potwierdź, że wszystko wygląda dobrze, i poczekaj, aż instalacja się zakończy jak zwykle. To też miejsce, w którym możesz wybrać instalację bez szyfrowania (niezalecane), tak samo jak przy instalacji na całym dysku.
 ![dual-boot-6](images/dual-boot-6.webp)

## Dodawanie innych instalacji do programu rozruchowego

Gdy skończysz instalację Omarchy, zauważysz, że domyślnym programem rozruchowym jest teraz Limine. Dzięki niemu możesz też dodać do Limine opcje dla innych instalacji, takich jak Windows.

Aby to zrobić, uruchom `limine-scan` i postępuj zgodnie z monitami, aby dodać do konfiguracji limine, które elementy chcesz. Wtedy przy rozruchu zobaczysz swoje zwykłe opcje Omarchy, a także Windows Boot Manager i inne.

## Bitlocker

Ważne, aby wiedzieć, że ta metoda instalacji nie jest zgodna z Bitlockerem, bo szyfruje on cały dysk, a nie tylko partycję. Jeśli napotkasz błąd mówiący, że Bitlocker jest włączony, uruchom Windowsa, przejdź do **Settings -> Privacy & Security -> Device encryption** i wyłącz Bitlocker. Odszyfrowanie dysku może trochę potrwać.

 ![dual-boot-7](images/dual-boot-7.webp)
