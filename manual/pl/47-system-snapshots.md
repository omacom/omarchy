# Migawki systemu

Tworzymy migawki automatycznie przy każdej aktualizacji Omarchy, ale jeśli chcesz utworzyć własną, możesz użyć `omarchy-snapshot create`.

Aby uruchomić system z migawki i ją przywrócić, wybierasz ją z boot loadera Limine. Menu rozruchu domyślnie pozostaje ukryte, więc naciśnij dowolny klawisz, gdy tylko uruchomi się Limine, aby je wyświetlić.

Na tym ekranie wybierz migawkę, z której chcesz uruchomić system, na podstawie daty i wersji. Wersję Omarchy z czasu utworzenia migawki widać w lewym dolnym rogu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Kiedy już znajdziesz się w środku, wyskoczy powiadomienie informujące, że jesteś w rozruchowej migawce, a kliknięcie go rozpocznie proces przywracania. Alternatywnie możesz skorzystać z `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Przywróci to Twój główny system plików, ale nie Twój `/home`. Działa to więc przy cofaniu zepsutej aktualizacji systemu, ale nie przy odzyskiwaniu utraconych plików osobistych.

Oznacza to również, że Twój katalog `~/.config` pozostaje bez zmian. Jeśli więc wracasz do wcześniejszej wersji biblioteki lub aplikacji, która przechowuje pliki konfiguracyjne w nowym formacie, będziesz musiał zająć się tym ręcznie.

To samo dotyczy własnego rejestru Omarchy dotyczącego tego, które migracje zostały już uruchomione: znajduje się on w Twoim katalogu domowym, więc przetrwa przywracanie. Migracje uruchomione po utworzeniu migawki pozostają oznaczone jako wykonane, mimo że zmiany, które wprowadziły w głównym systemie plików, zostały cofnięte, a następne `omarchy update` nie uruchomi ich ponownie. Jeśli więc po przywróceniu ponownie dokonasz aktualizacji i nadal będzie brakować czegoś, co skonfigurowała wcześniejsza aktualizacja, to prawdopodobnie właśnie z tego powodu.

_Uwaga: Ta funkcja jest dostępna tylko w instalacjach korzystających z boot loadera Limine, który jest domyślny od Omarchy 2.0. Nie jest dostępna, jeśli korzystasz z GRUB lub systemd-boot._
