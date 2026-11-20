# Uśpienie systemu

Omarchy domyślnie włącza wstrzymywanie i hibernację, ale jeśli masz problemy z którąś z tych opcji na swojej maszynie, możesz je wyłączyć.

Na maszynach z NVIDIA GB10, takich jak DGX Spark i ASUS Ascent GX10, wstrzymywanie i hibernacja są wyłączone, tak jak w systemie DGX OS firmy NVIDIA, ponieważ nie wykazano jeszcze, że uśpienie działa na tym sprzęcie. To samo dotyczy ASUS Zenbook A16 (UX3607OA), w którym wstrzymywanie nie usypia jeszcze w pełni układu i może zawiesić się przez noc. Przełącznik wstrzymywania i konfiguracja hibernacji nie mają tam zastosowania. Aby ponownie włączyć uśpienie, usuń `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` za pomocą `sudo rm`; wstrzymywanie wraca wtedy do menu, a hibernację można skonfigurować tak jak na innych maszynach. Uruchomienie `sudo omarchy apply hardware --install-user "$USER"` przywraca ten plik.

### Profile zasilania

Na laptopie Omarchy zapamiętuje profil zasilania oddzielnie dla zasilania z sieci i pracy na baterii oraz przełącza między nimi, gdy podłączasz i odłączasz zasilanie. Domyślnie oznacza to wydajność na zasilaniu sieciowym i tryb zrównoważony na baterii.

Możesz sprawdzić, co oferuje twoja maszyna, za pomocą `omarchy powerprofiles list`, i ustawić ten, którego chcesz dla stanu, w którym obecnie się znajdujesz, za pomocą `omarchy powerprofiles set autodetect power-saver`. Aby ustawić drugi stan bez odłączania czegokolwiek, nazwij go bezpośrednio: `omarchy powerprofiles set battery power-saver`. Cokolwiek wybierzesz, to właśnie otrzymasz z powrotem następnym razem, gdy będziesz w tym stanie.

### Przełączanie wstrzymywania

Wstrzymywanie przełączasz, uruchamiając `omarchy toggle suspend` z terminala. To po prostu pokazuje/ukrywa opcję w _System_ (lub `Super + Esc`), a potem możesz sprawdzić, czy działa niezawodnie na twoim systemie. Jeśli nie, możesz ukryć ją ponownie tą samą komendą.

### Przełączanie hibernacji

Hibernację konfigurujesz, uruchamiając `omarchy hibernation setup` z terminala. Hibernacja tworzy podwolumin /swap na dysku rozruchowym o rozmiarze twojej fizycznej pamięci RAM, więc upewnij się, że masz dużo wolnego miejsca. Na maszynie z 32GB zawsze będziesz potrzebować 32GB+ wolnego miejsca na ten wolumin. Hibernacja wymaga również domyślnego bootloadera Limine.

Po skonfigurowaniu zobaczysz opcję hibernacji w _System_ (lub `Super + Esc`), a potem możesz sprawdzić, czy działa niezawodnie na twoim systemie. Jeśli nie, możesz usunąć ją ponownie, uruchamiając `omarchy hibernation remove`.
