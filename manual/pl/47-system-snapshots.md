# Migawki systemu

Migawki tworzymy automatycznie przy każdej aktualizacji Omarchy, ale jeśli chcesz utworzyć własną, możesz użyć `omarchy-snapshot create`.

To, jak uruchamiasz migawkę i jak ją przywracasz, zależy od programu rozruchowego, z którym startuje twój komputer. Nowe instalacje UEFI używają systemd-boot; starsze instalacje i komputery z BIOS-em używają Limine. `omarchy-boot-backend` powie ci, który masz.

## Z systemd-boot

Wybierz _System > Snapshots_ w menu Omarchy i wskaż migawkę, do której chcesz się uruchomić. Komputer uruchomi się do niej jednorazowo. Albo przytrzymaj Space podczas startu komputera, aby zobaczyć menu rozruchowe, w którym każda migawka jest wymieniona od najnowszej, wraz ze swoją wersją Omarchy i datą.

Migawka uruchamia się z tymczasową warstwą na wierzchu, więc możesz używać jej normalnie, ale wszystko, co zmienisz, zniknie przy następnym ponownym uruchomieniu. Aby ją zachować, uczyń ją swoim systemem: kliknij powiadomienie, które pojawi się po zalogowaniu, wybierz _System > Snapshots > Restore This Snapshot_ albo uruchom `omarchy-snapshot restore`. Przywracanie odbywa się podczas ponownego uruchamiania komputera. System w stanie sprzed przywracania pozostaje w menu rozruchowym jako _Before restore_, a `omarchy-snapshot restore backup` przywraca go z powrotem.

Z terminala:

- `omarchy-snapshot list` wyświetla migawki, do których możesz się uruchomić;
- `omarchy-snapshot boot 12` jednorazowo uruchamia ponownie komputer do migawki 12;
- `omarchy-snapshot restore 12` sprawia, że migawka 12 staje się systemem przy następnym ponownym uruchomieniu, a `omarchy-snapshot restore --cancel` pozwala zmienić zdanie przed tym ponownym uruchomieniem.

## Z Limine

Aby uruchomić i przywrócić migawkę, wybierasz ją z programu rozruchowego Limine. Menu rozruchowe domyślnie pozostaje ukryte, więc naciśnij dowolny klawisz, gdy tylko Limine się uruchomi, aby je wyświetlić.

Na tym ekranie wybierz migawkę, do której chcesz się uruchomić, na podstawie daty i wersji. Wersję Omarchy z czasu wykonania migawki widać w lewym dolnym rogu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Po wejściu do środka pojawi się powiadomienie informujące cię, że jesteś w uruchamialnej migawce, a jeśli je klikniesz, rozpocznie proces przywracania. Ewentualnie możesz skorzystać z `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Co obejmuje przywracanie

Przywracanie przywraca główny system plików, ale nie twój `/home`. Działa więc przy cofaniu zepsutej aktualizacji systemu, ale nie przy odzyskiwaniu utraconych plików osobistych.

Oznacza to również, że twój katalog `~/.config` pozostaje bez zmian. Jeśli więc cofasz się do wcześniejszej wersji biblioteki lub aplikacji, która przechowuje pliki konfiguracyjne w nowym formacie, będziesz musiał poradzić sobie z tym ręcznie.

To samo dotyczy własnego zapisu Omarchy o tym, które migracje zostały już uruchomione: znajduje się on w twoim katalogu domowym, więc przetrwa przywracanie. Migracje, które zostały uruchomione po wykonaniu migawki, pozostają oznaczone jako wykonane, mimo że zmiany, które wprowadziły w głównym systemie plików, zostały wycofane, a następne `omarchy update` nie uruchomi ich ponownie. Jeśli więc po przywróceniu znów zaktualizujesz system i nadal brakuje czegoś, co skonfigurowała wcześniejsza aktualizacja, to jest to prawdopodobna przyczyna.
