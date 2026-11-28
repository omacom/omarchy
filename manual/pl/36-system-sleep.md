# Uśpienie systemu

Omarchy domyślnie włącza wstrzymywanie, a hibernację po jej skonfigurowaniu, ale jeśli masz problemy z którąkolwiek z tych funkcji na swoim komputerze, możesz je wyłączyć.

Na komputerach z NVIDIA GB10, takich jak DGX Spark i ASUS Ascent GX10, wstrzymywanie i hibernacja są wyłączone, tak jak w DGX OS od NVIDIA, ponieważ nie wykazano jeszcze, że uśpienie działa na tym sprzęcie. Przełącznik wstrzymywania i konfiguracja hibernacji nie mają tam zastosowania. Aby ponownie włączyć uśpienie, usuń `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` za pomocą `sudo rm`; opcja Suspend wróci wtedy do menu, a hibernację będzie można skonfigurować tak jak na innych komputerach. Uruchomienie `sudo omarchy apply hardware --install-user "$USER"` przywróci ten plik.

### Profile zasilania

Na laptopie Omarchy zapamiętuje twój profil zasilania osobno dla zasilania z sieci i pracy na baterii oraz przełącza się między nimi, gdy podłączasz i odłączasz zasilanie. Domyślnie oznacza to performance przy zasilaniu z sieci i balanced na baterii.

Możesz sprawdzić, co oferuje twój komputer, za pomocą `omarchy powerprofiles list`, i ustawić profil dla stanu, w którym aktualnie się znajdujesz, za pomocą `omarchy powerprofiles set autodetect power-saver`. Aby ustawić profil dla drugiego stanu bez odłączania czegokolwiek, wskaż go bezpośrednio: `omarchy powerprofiles set battery power-saver`. Wybrany przez ciebie profil będzie tym, który otrzymasz z powrotem przy następnym przejściu w dany stan.

### Przełączanie wstrzymywania

Wstrzymywanie przełączasz, uruchamiając `omarchy toggle suspend` w terminalu. Powoduje to jedynie pokazanie/ukrycie opcji w menu _System_ (lub po naciśnięciu `Super + Esc`), dzięki czemu możesz sprawdzić, czy działa ona niezawodnie na twoim systemie. Jeśli nie, możesz ukryć ją ponownie tym samym poleceniem.

### Przełączanie hibernacji

Hibernację konfigurujesz, uruchamiając `omarchy hibernation setup` w terminalu (funkcja ta nie jest dostępna na komputerach Mac z Apple Silicon). Hibernacja tworzy podwolumin /swap na dysku rozruchowym o rozmiarze równej ilości przyznanej fizycznej pamięci RAM, więc upewnij się, że masz dużo wolnego miejsca w zapasie. Na komputerze z 32GB pamięci zawsze będziesz potrzebować ponad 32GB wolnego miejsca na ten wolumin. Hibernacja wymaga również domyślnego bootloadera Limine.

Po skonfigurowaniu zobaczysz opcję hibernacji w menu _System_ (lub po naciśnięciu `Super + Esc`) i będziesz mógł sprawdzić, czy działa ona niezawodnie na twoim systemie. Jeśli nie, możesz usunąć ją ponownie, uruchamiając `omarchy hibernation remove`.
