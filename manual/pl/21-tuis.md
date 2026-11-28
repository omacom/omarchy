# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) to zachwycająca alternatywa dla czegoś takiego jak aplikacja GitHub Desktop, a działa wewnątrz terminala.

Możesz uruchomić go bezpośrednio, przechodząc do dowolnego katalogu zarządzanego przez git i uruchamiając `lazygit`. Możesz też uruchomić go wewnątrz Neovim, gdzie można go wystartować za pomocą `Space G G`.

Między poszczególnymi panelami przeskakujesz przy użyciu `Tab`. W panelu Files wybierasz pliki do umieszczenia w obszarze przechowalni przy użyciu `Space`, a następnie możesz utworzyć nowy commit przy użyciu `c`. Wszystkie dostępne polecenia możesz zobaczyć przy użyciu `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) to piękny menedżer zasobów, który pokazuje zużycie pamięci, CPU, dysku i sieci. Wyświetla też listę wszystkich aktywnych procesów i pozwala nimi zarządzać.

Omarchy nazywa go Activity Monitor, a uruchamiasz go z programu uruchamiającego aplikacje albo naciskając `Super + Shift + T`. Otwiera się jako okno pływające, które możesz zamienić w kafelek przy użyciu `Super + T`.

## Herdr

[Herdr](https://herdr.dev) to terminalowy menedżer przestrzeni roboczych, który daje Ci przestrzenie robocze, karty i panele oraz utrzymuje je wszystkie w działającej, trwałej sesji, od której możesz się odłączyć i do której możesz wrócić później.

Uruchamiasz go (albo ponownie podłączasz się do istniejącej sesji) z programu uruchamiającego aplikacje albo przy użyciu `Super + Ctrl + Return`. Omarchy dostarcza konfigurację Herdr, która odzwierciedla jego konfigurację Tmux, więc klawisz prefiksu to tutaj również `Ctrl + Space`. Wszystkie skróty klawiaturowe możesz przeglądać przy użyciu `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) pokazuje informacje o systemie, takie jak wersja jądra, czas pracy, motyw, CPU, pamięć i nie tylko. To następca popularnego narzędzia neofetch.

Omarchy umieściło go jako _System > About_ w menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) to retro terminalowy odtwarzacz muzyki inspirowany Winamp 2.x, w komplecie z wbudowanymi stacjami radiowymi z lo-fi beats. Uruchom go przy użyciu `Super + Shift + Alt + M` albo z menu Omarchy w sekcji _Apps_. Naciśnij `?`, aby zobaczyć pełną listę skrótów klawiaturowych.

## A co z Wi-Fi i Bluetooth?

Nie znajdziesz TUI dla Wi-Fi i Bluetooth — te zadania należą do powłoki Omarchy. Kliknij ikonę Wi-Fi na górnym pasku (albo naciśnij `Super + Ctrl + N`), aby zobaczyć sieci i się z nimi połączyć, i kliknij ikonę Bluetooth (albo naciśnij `Super + Ctrl + B`), aby sparować i połączyć urządzenia. Pełną historię znajdziesz w rozdziale [sieć](35-networking.md).

## Dodawanie własnych

Każdy program terminalowy może otrzymać pełne traktowanie aplikacji. Przejdź do _Install > TUI_ w menu Omarchy (`Super + Space`), nadaj mu nazwę, polecenie uruchamiania, styl okna i ikonę, a pojawi się w programie uruchamiającym aplikacje jak każda inna aplikacja. Możesz go ponownie usunąć w _Remove > TUI_.
