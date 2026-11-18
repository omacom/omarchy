# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) to zachwycająca alternatywa dla czegoś takiego jak aplikacja GitHub Desktop, a działa wewnątrz terminala.

Możesz uruchomić go bezpośrednio, przechodząc do dowolnego katalogu zarządzanego przez git i uruchamiając `lazygit`. Możesz też uruchomić go wewnątrz Neovim, gdzie możesz go uruchomić za pomocą `Space G G`.

Między poszczególnymi panelami przeskakujesz za pomocą `Tab`. W panelu Files wybierasz pliki do umieszczenia w indeksie za pomocą `Space`, a potem możesz utworzyć nowy commit za pomocą `c`. Wszystkie dostępne polecenia możesz zobaczyć za pomocą `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) to piękny menedżer zasobów, który pokazuje zużycie pamięci, CPU, dysku i sieci. Wyświetla też wszystkie aktywne procesy i pozwala nimi zarządzać.

Omarchy nazywa go Activity Monitor, a uruchamiasz go z launchera aplikacji lub naciskając `Super + Shift + T`. Otwiera się jako pływające okno, które możesz ułożyć w układzie kafelkowym za pomocą `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) to terminalowy menedżer przestrzeni roboczych, który zapewnia przestrzenie robocze, karty i panele, a wszystkie działają w trwałej sesji, od której możesz się odłączyć i do której możesz później wrócić.

Uruchamiasz go (lub ponownie podłączasz się do istniejącej sesji) z launchera aplikacji lub za pomocą `Super + Ctrl + Return`. Omarchy dostarcza konfigurację Herdr, która odzwierciedla jego konfigurację Tmux, więc klawisz prefiksu to tutaj również `Ctrl + Space`. Wszystkie skróty klawiszowe możesz przejrzeć za pomocą `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) pokazuje informacje o systemie, takie jak wersja jądra, czas działania, motyw, CPU, pamięć i wiele więcej. Jest następcą popularnego narzędzia neofetch.

Omarchy umieściło to jako _Informacje_ w menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) to odtwarzacz muzyki w terminalu w stylu retro, inspirowany Winamp 2.x, wraz z wbudowanymi stacjami radiowymi z bitami lo-fi. Uruchomisz go za pomocą `Super + Shift + Alt + M` lub z menu Omarchy w sekcji _Aplikacje_. Naciśnij `?`, aby wyświetlić pełną listę skrótów klawiszowych.

## A co z Wi-Fi i Bluetooth?

Nie znajdziesz TUI dla Wi-Fi i Bluetooth — te zadania należą do powłoki Omarchy. Kliknij ikonę Wi-Fi na górnym pasku (lub naciśnij `Super + Ctrl + N`), aby zobaczyć sieci i nawiązać połączenie, a następnie kliknij ikonę Bluetooth (lub naciśnij `Super + Ctrl + B`), aby sparować i połączyć urządzenia. Zobacz [sieć](35-networking.md), aby poznać pełną historię.

## Dodawanie własnych

Każdy program terminalowy może zostać potraktowany jak pełnoprawna aplikacja. Przejdź do _Zainstaluj > TUI_ w menu Omarchy (`Super + Space`), nadaj mu nazwę, polecenie uruchamiania, styl okna i ikonę, a pojawi się w launcherze aplikacji jak każda inna aplikacja. Możesz go ponownie usunąć w sekcji _Usuń > TUI_.
