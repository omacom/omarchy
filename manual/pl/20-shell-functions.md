# Funkcje powłoki

Omarchy zawiera zestaw funkcji powłoki, które upraszczają typowe zadania i encapsulują zawiłe wywołania parametrów.

## Kompresja

- `compress [file/dir]`: Utwórz archiwum tar.gz z pliku/katalogu.
- `decompress [file.tar.gz]`: Rozpakuj plik tar.gz.

## Dyski

- `iso2sd [image.iso]`: Utwórz rozruchowy dysk na karcie SD, używając wskazanego pliku iso i wybierając dysk interaktywnie.
- `format-drive [device] [name]`: Sformatuj cały dysk jedną partycją exFAT (która działa również w Windows i macOS). Uruchom bez argumentów, aby zobaczyć dostępne dyski. Bądź ostrożny!

## Układy programistyczne

Natychmiastowe wielopanelowe układy programistyczne dla tmux:

- `tdl [ai]`: Utwórz Tmux Dev Layout z edytorem, agentem AI i terminalem. Używaj aliasów agentów, takich jak `tdl c` dla opencode lub `tdl cx` dla Claude Code, albo podaj drugiego agenta, aby uruchomić oba, na przykład `tdl c cx`.
- `tds`: Utwórz Tmux Dev Square z edytorem, obserwowaniem diffów (za pomocą `hunk diff --watch`), terminalem i opencode.
- `tdlm [ai]`: Utwórz okno `tdl` dla każdego podkatalogu w bieżącym katalogu.
- `tsl [count] [command]`: Utwórz rój paneli ułożonych w siatce, wszystkie uruchamiające to samo polecenie (świetne dla agentów AI).

Te same układy są dostępne dla Herdr jako `hdl`, `hds`, `hdlm` i `hsl`.

## Git worktrees

- `ga [branch]`: Utwórz nowy worktree i branch obok bieżącego repozytorium i przeskocz do niego.
- `gd`: Usuń bieżący worktree i jego branch (najpierw prosi o potwierdzenie).

## Obserwatorzy Rsync

- `rsw [source] [destination]`: Uruchom obserwatora w tle, który rsyncuje źródło do miejsca docelowego za każdym razem, gdy coś się zmieni. Miejsce docelowe może być zdalnym hostem, na przykład `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Wyświetl wszystkich aktywnych obserwatorów.
- `dsw`: Zatrzymaj wszystkich aktywnych obserwatorów.

## Przekierowywanie portów SSH

Idealne do programowania webowego z przywilejami bezpiecznego kontekstu localhost względem zdalnej maszyny.

- `fip`: Przekieruj jeden lub więcej portów ze zdalnego hosta na localhost przez SSH.
- `dip`: Odłącz jeden lub więcej przekierowanych portów.
- `lip`: Wyświetl wszystkie aktywne przekierowania portów SSH.

Załóżmy, że uruchamiasz serwer deweloperski na porcie `3000` na maszynie dostępnej jako `nyc-dev`, wtedy możesz uruchomić `fip nyc-dev 3000`, aby przekierować ten port, tak aby `localhost:3000` rzeczywiście sięgał `nyc-dev:3000`, ale bez potrzeby certyfikatów SSL do ustanowienia bezpiecznego kontekstu potrzebnego do testowania web socketów itp.

## Ponowne łączenie SSH

Samo `ssh` jest owinięte w funkcję, która czyści terminal, jeśli połączenie umrze, gdy zdalny tmux, Herdr lub edytor go przejął, a następnie automatycznie ponownie łączy, gdy interaktywna sesja zostanie przerwana (Ctrl-C zatrzymuje pętlę ponownych prób).
