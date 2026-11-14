# Migawki systemu

Tworzymy migawki automatycznie przy każdej aktualizacji Omarchy, ale jeśli chcesz utworzyć własną, możesz użyć `omarchy-snapshot create`.

Aby uruchomić i przywrócić migawkę, wybierasz ją z programu rozruchowego Limine. (Jeśli obecnie uruchamiasz się bezpośrednio do ekranu deszyfrowania Omarchy, najpierw musisz wybrać Limine jako opcję rozruchu w BIOS).

Na tym ekranie wybierz migawkę, do której chcesz się uruchomić, na podstawie daty i wersji. Wersję Omarchy z czasu utworzenia migawki widać w lewym dolnym rogu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Gdy już się zalogujesz, pojawi się powiadomienie informujące, że jesteś w rozruchowej migawce, a po jego kliknięciu rozpocznie się proces przywracania. Alternatywnie możesz skorzystać z `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Spowoduje to przywrócenie głównego systemu plików, ale nie katalogu `/home`. Działa więc w przypadku cofania zepsutej aktualizacji systemu, ale nie w przypadku odzyskiwania utraconych plików osobistych.

Oznacza to również, że katalog `~/.config` pozostaje bez zmian. Jeśli więc wracasz do wcześniejszej wersji biblioteki lub aplikacji, która przechowuje pliki konfiguracyjne w nowym formacie, będziesz musiał poradzić sobie z tym ręcznie.

Dotyczy to również własnego rejestru Omarchy dotyczącego tego, które migracje zostały już uruchomione: znajduje się on w katalogu domowym, więc przetrwa przywracanie. Migracje, które zostały uruchomione po utworzeniu migawki, pozostają oznaczone jako wykonane, nawet jeśli zmiany, które wprowadziły w głównym systemie plików, zostały wycofane, a kolejne `omarchy update` nie uruchomi ich ponownie. Jeśli więc po przywróceniu ponownie zaktualizujesz system i nadal będzie brakowało czegoś, co skonfigurowała wcześniejsza aktualizacja, to jest to prawdopodobna przyczyna.

_Uwaga: Ta funkcja jest dostępna tylko w instalacjach korzystających z programu rozruchowego Limine, który jest domyślny od Omarchy 2.0. Nie jest dostępna, jeśli korzystasz z GRUB lub systemd-boot._

### Pomijanie menu rozruchowego

Jeśli nigdy nie korzystasz z menu rozruchowego i chcesz, aby komputer przechodził od razu do ekranu deszyfrowania, uruchom _Setup > Direct Boot_ w menu Omarchy. Dodaje to wpis EFI wskazujący bezpośrednio na Omarchy, dzięki czemu oprogramowanie układowe uruchamia system bez zatrzymywania się na Limine.

Kompromis jest taki sam, jak wspomniano na początku: przy włączonym bezpośrednim uruchamianiu dostanie się do migawki oznacza najpierw wybranie Limine z menu rozruchowego BIOS. Uruchom ponownie _Setup > Direct Boot_, aby usunąć wpis i wrócić do uruchamiania przez Limine. Niektóre oprogramowanie układowe nie lubi niestandardowych wpisów EFI, więc konfiguracja odmawia uruchomienia na oprogramowaniu układowym American Megatrends i Apple.
