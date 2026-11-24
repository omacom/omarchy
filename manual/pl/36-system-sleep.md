# Usypianie systemu

Omarchy domyślnie włącza wstrzymywanie, a po skonfigurowaniu także hibernację, ale jeśli masz na swojej maszynie problemy z którąś z tych funkcji, możesz je wyłączyć.

Na maszynach z układem NVIDIA GB10, takich jak DGX Spark i ASUS Ascent GX10, wstrzymywanie i hibernacja są wyłączone, tak samo jak w systemie DGX OS firmy NVIDIA, ponieważ nie wykazano jeszcze, że usypianie działa na tym sprzęcie. To samo dotyczy laptopa ASUS Zenbook A16 (UX3607OA), w którym wstrzymywanie nie usypia jeszcze w pełni układu i może zawiesić się przez noc. Przełącznik wstrzymywania i konfiguracja hibernacji nie mają tam zastosowania. Aby ponownie włączyć usypianie, usuń `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` poleceniem `sudo rm`; opcja Suspend wróci wtedy do menu, a hibernację będzie można skonfigurować tak jak na innych maszynach. Uruchomienie polecenia `sudo omarchy apply hardware --install-user "$USER"` przywraca ten plik.

### Profile zasilania

Na laptopie Omarchy zapamiętuje profil zasilania osobno dla pracy z podłączonym zasilaniem i pracy na baterii oraz przełącza się między nimi przy podłączaniu i odłączaniu zasilania. Domyślnie oznacza to profil performance na zasilaniu AC i balanced na baterii.

Możesz sprawdzić, co oferuje Twoja maszyna, poleceniem `omarchy powerprofiles list`, i ustawić profil dla stanu, w którym aktualnie się znajdujesz, poleceniem `omarchy powerprofiles set autodetect power-saver`. Aby ustawić profil dla drugiego stanu bez odłączania czegokolwiek, wskaż go bezpośrednio: `omarchy powerprofiles set battery power-saver`. Cokolwiek wybierzesz, dokładnie to otrzymasz z powrotem, gdy następnym razem znajdziesz się w tym stanie.

### Przełączanie wstrzymywania

Wstrzymywanie przełączasz, uruchamiając `omarchy toggle suspend` w terminalu. Spowoduje to tylko pokazanie/ukrycie opcji w menu _System_ (lub pod `Super + Esc`), a potem możesz sprawdzić, czy działa ona stabilnie w Twoim systemie. Jeśli nie, możesz ukryć ją ponownie tym samym poleceniem.

### Przełączanie hibernacji

Hibernację konfigurujesz, uruchamiając `omarchy hibernation setup` w terminalu (nie jest dostępna na komputerach Mac z Apple Silicon). Hibernacja tworzy na dysku rozruchowym podwolumin /swap o rozmiarze równym ilości fizycznej pamięci RAM, więc upewnij się, że masz na nim dużo wolnego miejsca. Na maszynie z 32GB pamięci zawsze będziesz potrzebować ponad 32GB wolnego miejsca na ten wolumin. Hibernacja wymaga również domyślnego programu rozruchowego Limine.

Po skonfigurowaniu zobaczysz opcję hibernacji w menu _System_ (lub pod `Super + Esc`) i będziesz mógł sprawdzić, czy działa ona stabilnie w Twoim systemie. Jeśli nie, możesz usunąć ją ponownie, uruchamiając `omarchy hibernation remove`.
