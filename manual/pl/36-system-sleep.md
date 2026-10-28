# Uśpienie systemu

Omarchy domyślnie włącza wstrzymanie i hibernację, ale jeśli masz na swoim komputerze problemy z którąkolwiek z tych funkcji, możesz ją wyłączyć.

Na komputerach z NVIDIA GB10, takich jak DGX Spark i ASUS Ascent GX10, wstrzymanie i hibernacja są wyłączone, tak jak w systemie NVIDIA DGX OS, ponieważ nie wykazano jeszcze, że uśpienie działa na tym sprzęcie. Przełącznik wstrzymania i konfiguracja hibernacji nie mają tam zastosowania. Aby ponownie włączyć uśpienie, usuń `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` za pomocą `sudo rm`; wstrzymanie wróci wtedy do menu, a hibernację będzie można skonfigurować tak jak na innych komputerach. Uruchomienie `sudo omarchy apply hardware --install-user "$USER"` przywraca ten plik.

### Profile zasilania

Na laptopie Omarchy zapamiętuje profil zasilania osobno dla zasilania sieciowego i pracy na baterii oraz przełącza się między nimi, gdy podłączasz i odłączasz zasilanie. Domyślnie oznacza to tryb wydajności przy zasilaniu sieciowym i tryb zrównoważony na baterii.

Możesz sprawdzić, co oferuje twój komputer, za pomocą `omarchy powerprofiles list`, i ustawić profil dla stanu, w którym obecnie jesteś, za pomocą `omarchy powerprofiles set autodetect power-saver`. Aby ustawić drugi stan bez odłączania czegokolwiek, wskaż go bezpośrednio: `omarchy powerprofiles set battery power-saver`. Cokolwiek wybierzesz, to właśnie otrzymasz, gdy następnym razem znajdziesz się w tym stanie.

### Przełączanie wstrzymania

Wstrzymanie przełączasz, uruchamiając `omarchy toggle suspend` w terminalu. To po prostu pokazuje/ukrywa opcję w menu _System_ (lub `Super + Esc`), a potem możesz sprawdzić, czy działa ona stabilnie w twoim systemie. Jeśli nie, możesz ją ponownie ukryć tym samym poleceniem.

### Przełączanie hibernacji

Hibernację konfigurujesz, uruchamiając `omarchy hibernation setup` w terminalu. Hibernacja tworzy podwolumin /swap na dysku rozruchowym o rozmiarze twojej fizycznej pamięci RAM, więc upewnij się, że masz dużo wolnego miejsca. Na komputerze z 32GB będziesz zawsze potrzebować na ten wolumin ponad 32GB wolnego miejsca. Hibernacja wymaga także domyślnego bootloadera Limine.

Po skonfigurowaniu zobaczysz opcję hibernacji w menu _System_ (lub `Super + Esc`) i będziesz mógł sprawdzić, czy działa ona stabilnie w twoim systemie. Jeśli nie, możesz ją ponownie usunąć, uruchamiając `omarchy hibernation remove`.
