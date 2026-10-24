# Migawki systemu

Migawki tworzymy automatycznie przy każdej aktualizacji Omarchy, ale gdybyś chciał utworzyć własną, możesz użyć `omarchy-snapshot create`.

Aby uruchomić i przywrócić migawkę, wybierasz ją z programu rozruchowego Limine. (Jeśli obecnie uruchamiasz się wprost do ekranu odszyfrowywania Omarchy, najpierw musisz wybrać Limine jako opcję rozruchu w BIOS-ie).

Na tym ekranie wybierz migawkę, którą chcesz uruchomić, na podstawie daty i wersji. Wersję Omarchy z chwili utworzenia migawki widać w lewym dolnym rogu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Gdy znajdziesz się w środku, wyskoczy powiadomienie informujące cię, że jesteś w startowej migawce, a jeśli je klikniesz, rozpocznie proces przywracania. Alternatywnie możesz skorzystać z `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Przywróci to twój główny system plików, ale nie twój `/home`. Działa więc przy wycofywaniu zepsutej aktualizacji systemu, ale nie przy odzyskiwaniu utraconych plików osobistych.

Oznacza to też, że twój katalog `~/.config` pozostaje bez zmian. Więc jeśli wycofujesz się do wcześniejszej wersji biblioteki albo aplikacji, która przechowuje pliki konfiguracyjne w nowym formacie, będziesz musiał uporać się z tym ręcznie.

_Uwaga: Ta funkcja jest dostępna tylko w instalacjach używających programu rozruchowego Limine, który jest domyślny od Omarchy 2.0. Nie jest dostępna, jeśli używasz GRUB-a albo systemd-boot._

### Pomijanie menu rozruchowego

Jeśli nigdy nie dotykasz menu rozruchowego i chcesz tylko, aby komputer przechodził wprost do ekranu odszyfrowywania, uruchom _Ustawienia > Bezpośredni rozruch_ w menu Omarchy. Dodaje to wpis EFI wskazujący wprost na Omarchy, więc oprogramowanie sprzętowe uruchamia je bez zatrzymywania się na Limine.

Kompromis jest ten wspomniany na górze: przy włączonym bezpośrednim rozruchu dostanie się do migawki oznacza najpierw wybranie Limine z menu rozruchowego BIOS-u. Uruchom _Ustawienia > Bezpośredni rozruch_ ponownie, aby usunąć wpis i wrócić do uruchamiania przez Limine. Niektóre oprogramowanie sprzętowe nie znosi dobrze niestandardowych wpisów EFI, więc konfiguracja odmawia działania na oprogramowaniu sprzętowym American Megatrends i Apple.
