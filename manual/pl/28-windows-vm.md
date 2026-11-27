# Windows VM

Omarchy oferuje prosty sposób na uruchomienie systemu Windows za pośrednictwem maszyny wirtualnej Docker na komputerach z architekturą x86_64. Możesz ją zainstalować, używając opcji _Install > Windows_ z menu Omarchy (`Super + Space`).

Twój komputer potrzebuje do tego wirtualizacji KVM, którą większość obsługuje — ale czasami jest ona wyłączona w BIOS-ie i instalator poinformuje cię, jeśli tak jest. Będziesz też potrzebować miejsca na dysku: tyle, ile przydzielisz systemowi Windows, plus około 10GB na sam obraz.

Instalator pyta, ile pamięci RAM, ile rdzeni CPU i ile miejsca na dysku przekazać (64GB lub więcej to rozsądne minimum), a następnie o nazwę użytkownika i hasło do systemu Windows. Zostaw je puste, a otrzymasz `docker` / `admin`. Pobieranie trwa chwilę — 10-15 minut to norma — a postęp możesz śledzić w przeglądarce pod adresem `http://127.0.0.1:8006`. Przed otwarciem konsoli przeglądarka poprosi o tę samą nazwę użytkownika i hasło.

 ![windows-vm](images/windows-vm.webp)

## Korzystanie z niej

Po zainstalowaniu uruchom _Windows_ z programu uruchamiającego aplikacje. Spowoduje to uruchomienie maszyny wirtualnej, jeśli jeszcze nie działa, i połączy cię przez RDP, na pełnym ekranie. Daj jej 15-30 sekund przy zimnym starcie.

Sesja RDP przenosi dźwięk, twój mikrofon i współdzielony schowek, więc kopiowanie tekstu między Linuksem a Windows po prostu działa. Rozdzielczość podąża za twoim oknem, a Omarchy przekazuje skalowanie twojego ekranu, więc na ekranie HiDPI nie jest to rozmazany bałagan.

Gdy zamkniesz okno RDP, maszyna wirtualna wyłączy się automatycznie. Jeśli wolisz zostawić ją działającą — powiedzmy, że coś tam w środku sobie pracuje — uruchom ją zamiast tego poleceniem `omarchy windows vm launch --keep-alive`.

Pozostałe elementy sterowania znajdują się w tym samym poleceniu:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Udostępnianie plików

Katalog `~/Windows` w twoim katalogu domowym jest automatycznie udostępniany maszynie wirtualnej. Umieszczaj tam pliki, jeśli chcesz, aby były dostępne dla systemu Windows. Maszyna wirtualna nie ma dostępu do żadnej innej części twojego systemu plików, więc jesteś bezpieczny przed wszystkim paskudnym po stronie Windows. Jej własny dysk wirtualny jest dostępny pod adresem `~/.windows`.

Te znajome ścieżki domowe pozostają we własnych systemach plików. Mogą też być dowiązaniami symbolicznymi do katalogów, których jesteś właścicielem, co jest przydatne, gdy dysk wirtualny znajduje się na większym dysku. Instalator mierzy wolne miejsce w systemie plików, który faktycznie zawiera `~/.windows`, a niekoniecznie w systemie plików zawierającym twój katalog domowy.

Trzymaj ścieżki dysku i ścieżki udostępniane jako osobne, nienakładające się na siebie katalogi. Usuwanie celowo opróżnia katalog dysku, ale zachowuje katalog udostępniany. Bezpośrednio przed usunięciem Omarchy przeprowadza ograniczoną kontrolę zawierania i odmawia usunięcia czegokolwiek, jeśli kontrola przekroczy limit czasu lub nie będzie w stanie udowodnić, że te dwa drzewa są odrębne.

Przed uruchomieniem maszyny wirtualnej Omarchy otwiera i przypina te dwa katalogi, a następnie montuje za pomocą bind dokładne i-węzły katalogów na prywatnych kotwicach dla poszczególnych użytkowników poniżej `/var/lib/omarchy/windows/mounts`. Docker widzi tylko te kotwice chronione przez roota. Zachowuje to niestandardowe lokalizacje dysku, a jednocześnie uniemożliwia innemu procesowi działającemu jako ty podmienienie sprawdzonej ścieżki, zanim uprzywilejowany kontener ją wykorzysta. Istniejące katalogi dysku i katalogi udostępniane mają podczas migracji zaostrzany tryb do `0700`, aby inne konta lokalne nie mogły przeglądać ich zawartości.

Porty maszyny wirtualnej są powiązane wyłącznie z localhost, więc nic w twojej sieci nie może połączyć się z maszyną z systemem Windows. Konsola internetowa wymaga również skonfigurowanej nazwy użytkownika i hasła do systemu Windows, co uniemożliwia innemu kontu lokalnemu sterowanie maszyną wirtualną przez port 8006.

## Ograniczenia i licencjonowanie

W tej konfiguracji nie ma przekazywania GPU, więc nie nadaje się ona do gier ani edycji wideo. To świetny sposób na uruchomienie Microsoft Office lub czegokolwiek innego, co absolutnie musisz mieć.

Zainstalowana wersja to Windows 11 Pro, nieaktywowana. Będziesz potrzebować własnego klucza licencyjnego, aby korzystać z funkcji objętych ograniczeniami.

Jeśli ten komputer był dostarczony z systemem Windows, klucz OEM nadal znajduje się w oprogramowaniu układowym, nawet po zainstalowaniu Omarchy. Wypisz go poleceniem `omarchy windows key`. Ten klucz jest powiązany z tą maszyną — aktywuje system Windows ponownie zainstalowany na tym sprzęcie, ale zazwyczaj nie aktywuje maszyny wirtualnej.

Możesz później zmienić przydział zasobów, uruchamiając w terminalu `omarchy windows vm install`, co przepisze konfigurację maszyny wirtualnej na podstawie twoich odpowiedzi. Sam plik compose znajduje się teraz pod adresem `/var/lib/omarchy/windows/docker-compose.yml` i należy do roota — jest to celowe, aby proces działający jako ty nie mógł go przepisać i sprawić, by uprzywilejowane uruchomienie zamontowało cały twój dysk w kontenerze. Jeśli musisz edytować go ręcznie (na przykład aby zamontować urządzenie USB), edytuj go za pomocą `sudo` i zobacz wszystkie opcje w [projekcie Dockur Windows](https://github.com/dockur/windows).

Aby pozbyć się tego wszystkiego, użyj opcji _Remove > Windows_ z menu Omarchy. Spowoduje to usunięcie dysku maszyny wirtualnej w `~/.windows` i wszystkiego, co zainstalowano wewnątrz systemu Windows, więc najpierw skopiuj z maszyny wirtualnej wszystko, czego potrzebujesz. Twój udostępniany folder `~/Windows` zostanie pozostawiony w spokoju.
