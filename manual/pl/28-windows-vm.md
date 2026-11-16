# Maszyna wirtualna Windows

Omarchy oferuje łatwy sposób na uruchomienie Windows przez maszynę wirtualną Docker. Możesz zainstalować ją, używając _Instaluj > Windows_ z menu Omarchy (`Super + Space`).

Twoja maszyna potrzebuje do tego wirtualizacji KVM, którą większość posiada — ale czasami jest wyłączona w BIOS-ie, a instalator powie ci, jeśli tak jest. Będziesz również potrzebować miejsca na dysku: tyle, ile dasz Windows, plus około 10GB na sam obraz.

Instalator pyta, ile RAM-u, ile rdzeni CPU i ile dysku przekazać (64GB lub więcej to rozsądne minimum), a następnie o nazwę użytkownika i hasło Windows. Pozostaw je puste, a otrzymasz `docker` / `admin`. Pobieranie trwa chwilę — 10-15 minut to norma — a postęp możesz śledzić w przeglądarce pod adresem `http://127.0.0.1:8006`. Przeglądarka poprosi o tę samą nazwę użytkownika i hasło przed otwarciem konsoli.

 ![windows-vm](images/windows-vm.webp)

## Używanie jej

Gdy jest zainstalowana, uruchom _Windows_ z launchera aplikacji. To uruchamia maszynę wirtualną, jeśli jeszcze nie działa, i łączy cię przez RDP na pełnym ekranie. Daj jej 15-30 sekund przy zimnym starcie.

Sesja RDP przenosi dźwięk, twój mikrofon i wspólny schowek, więc kopiowanie tekstu między Linuksem a Windows po prostu działa. Rozdzielczość podąża za twoim oknem, a Omarchy przekazuje skalowanie wyświetlacza, więc nie jest to rozmyty bałagan na ekranie HiDPI.

Gdy zamkniesz okno RDP, maszyna wirtualna wyłącza się automatycznie. Jeśli wolisz zostawić ją działającą — powiedzmy, że coś tam pracuje — uruchom ją zamiast tego za pomocą `omarchy windows vm launch --keep-alive`.

Pozostałe kontrole znajdują się w tym samym poleceniu:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Udostępnianie plików

Katalog `~/Windows` w twoim katalogu domowym jest automatycznie udostępniany maszynie wirtualnej. Umieszczaj tam pliki, jeśli chcesz, aby były dostępne dla Windows. Maszyna wirtualna nie ma dostępu do żadnej innej części twojego systemu plików, więc jesteś bezpieczny przed czymkolwiek nieprzyjemnym po stronie Windows. Jej własny dysk wirtualny jest dostępny pod adresem `~/.windows`.

Te znajome ścieżki domowe pozostają na własnych systemach plików. Mogą być również dowiązaniami symbolicznymi do katalogów, których jesteś właścicielem, co jest przydatne, gdy dysk wirtualny mieszka na większym dysku. Instalator mierzy wolne miejsce na systemie plików, który rzeczywiście zawiera `~/.windows`, niekoniecznie na systemie plików zawierającym twój katalog domowy.

Utrzymuj ścieżki dysku i udostępniane jako oddzielne, nienakładające się katalogi. Usuwanie celowo opróżnia katalog dysku, ale zachowuje katalog udostępniany. Bezpośrednio przed usunięciem Omarchy wykonuje ograniczoną kontrolę zawierania i odmawia usunięcia czegokolwiek, jeśli ta kontrola przekroczy limit czasu lub nie może udowodnić, że oba drzewa są oddzielne.

Przed uruchomieniem maszyny wirtualnej Omarchy otwiera i przypina te dwa katalogi, a następnie bind-montuje dokładne inode katalogów na prywatne kotwice per-użytkownika poniżej `/var/lib/omarchy/windows/mounts`. Docker widzi tylko te chronione przez roota kotwice. Zachowuje to niestandardowe lokalizacje dysku, zapobiegając jednocześnie, aby inny proces działający jako ty zamienił sprawdzoną ścieżkę, zanim uprzywilejowany kontener ją wykorzysta. Istniejące katalogi dysku i udostępniane są podczas migracji zaostrzane do trybu `0700`, aby inne konta lokalne nie mogły przeglądać ich zawartości.

Porty maszyny wirtualnej są powiązane tylko z localhost, więc nic w twojej sieci nie może dosięgnąć maszyny Windows. Konsola webowa wymaga również skonfigurowanej nazwy użytkownika i hasła Windows, zapobiegając, aby inne konto lokalne sterowało maszyną wirtualną przez port 8006.

## Ograniczenia i licencjonowanie

W tej konfiguracji nie ma passthrough GPU, więc nie nadaje się do gier ani edycji wideo. To świetny sposób na uruchomienie Microsoft Office lub czegokolwiek innego, co absolutnie musisz mieć.

Zainstalowana wersja to Windows 11 Pro, nieaktywowana. Będziesz potrzebować własnego klucza licencyjnego, aby korzystać z funkcji objętych bramką.

Jeśli ten komputer był dostarczony z Windows, klucz OEM nadal znajduje się w firmware nawet po zainstalowaniu Omarchy. Wypisz go za pomocą `omarchy windows key`. Ten klucz jest powiązany z tym komputerem — aktywuje Windows ponownie zainstalowany na tym sprzęcie, ale zwykle nie aktywuje maszyny wirtualnej.

Możesz zmienić alokację zasobów później, ponownie uruchamiając `omarchy-windows-vm install`, co przepisuje konfigurację maszyny wirtualnej na podstawie twoich odpowiedzi. Sam plik compose mieszka teraz w `/var/lib/omarchy/windows/docker-compose.yml` i jest własnością roota — jest to celowe, aby proces działający jako ty nie mógł go przepisać i sprawić, aby uprzywilejowane uruchomienie zamontowało cały twój dysk do kontenera. Jeśli musisz go edytować ręcznie (na przykład, aby zamontować urządzenie USB), edytuj go za pomocą `sudo` i zobacz wszystkie opcje w [projekcie Dockur Windows](https://github.com/dockur/windows).

Aby pozbyć się całości, użyj _Usuń > Windows_ z menu Omarchy. To usuwa dysk maszyny wirtualnej i wszystkie jej dane, więc najpierw upewnij się, że wszystko, na czym ci zależy, jest poza `~/Windows`.
