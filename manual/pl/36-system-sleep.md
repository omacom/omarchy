# Uśpienie systemu

Omarchy domyślnie włącza wstrzymanie i hibernację, ale jeśli na twoim komputerze masz problemy z jednym albo drugim, możesz je wyłączyć.

### Profile zasilania

Na laptopie Omarchy pamięta profil zasilania osobno dla zasilania sieciowego i pracy na baterii i przełącza się między nimi, gdy podłączasz i odłączasz zasilacz. Od razu po zainstalowaniu oznacza to wydajność na zasilaniu sieciowym i zrównoważony na baterii.

Możesz zobaczyć, co oferuje twój komputer, poleceniem `omarchy powerprofiles list`, i ustawić ten, którego chcesz dla stanu, w którym aktualnie jesteś, poleceniem `omarchy powerprofiles set autodetect power-saver`. Aby ustawić drugi stan bez odłączania czegokolwiek, nazwij go wprost: `omarchy powerprofiles set battery power-saver`. Cokolwiek wybierzesz, to samo odzyskasz następnym razem, gdy będziesz w tym stanie.

### Przełączanie wstrzymania

Wstrzymanie przełączasz, uruchamiając w terminalu `omarchy toggle suspend`. To po prostu odsłania/ukrywa opcję w menu _System_ (albo `Super + Esc`), a wtedy możesz sprawdzić, czy działa stabilnie na twoim systemie. Jeśli nie, możesz ją znów ukryć tym samym poleceniem.

### Przełączanie hibernacji

Hibernację konfigurujesz, uruchamiając w terminalu `omarchy hibernation setup`. Hibernacja tworzy na dysku rozruchowym podwolumen /swap o rozmiarze twojej fizycznej pamięci RAM, więc upewnij się, że masz sporo wolnego miejsca. Na komputerze z 32GB zawsze będziesz potrzebować na ten wolumen ponad 32GB wolnego miejsca. Hibernacja wymaga też domyślnego programu rozruchowego Limine.

Po skonfigurowaniu zobaczysz opcję hibernacji w menu _System_ (albo `Super + Esc`), a wtedy możesz sprawdzić, czy działa stabilnie na twoim systemie. Jeśli nie, możesz ją znów usunąć, uruchamiając `omarchy hibernation remove`.
