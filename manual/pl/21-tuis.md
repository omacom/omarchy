# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) to zachwycająca alternatywa dla czegoś takiego jak aplikacja GitHub Desktop i działa w terminalu.

Możesz uruchomić go bezpośrednio, przechodząc do dowolnego katalogu zarządzanego przez git i uruchamiając `lazygit`. Możesz też uruchomić go wewnątrz Neovim, gdzie można go uruchomić za pomocą `Space G G`.

Między poszczególnymi panelami przeskakujesz za pomocą `Tab`. W panelu Files wybierasz pliki do dodania do poczekalni za pomocą `Space`, a następnie możesz utworzyć nowy commit za pomocą `c`. Wszystkie dostępne polecenia możesz zobaczyć za pomocą `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) to piękny menedżer zasobów, który pokazuje użycie pamięci, CPU, dysku i sieci. Wyświetla też listę wszystkich aktywnych procesów i pozwala nimi zarządzać.

Omarchy nazywa go Activity Monitor i uruchamiasz go z launchera aplikacji albo naciskając `Super + Shift + T`. Otwiera się jako okno pływające, które możesz zamienić w okno kafelkowe za pomocą `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) to menedżer przestrzeni roboczych w terminalu, który daje Ci przestrzenie robocze, karty i panele oraz utrzymuje je wszystkie uruchomione w trwałej sesji, od której możesz się odłączyć i do której możesz później wrócić.

Uruchamiasz go (albo ponownie podłączasz się do istniejącej sesji) z launchera aplikacji albo za pomocą `Super + Ctrl + Return`. Omarchy dostarcza konfigurację Herdr, która odzwierciedla jego konfigurację Tmux, więc klawisz prefiksu to tutaj również `Ctrl + Space`. Wszystkie skróty klawiszowe możesz przeglądać za pomocą `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) pokazuje informacje o systemie, takie jak wersja jądra, czas działania, motyw, CPU, pamięć i nie tylko. To następca popularnego narzędzia neofetch.

Omarchy umieściło to w menu Omarchy (`Super + Space`) jako _System > Informacje_.

## Cliamp

[Cliamp](https://www.cliamp.stream/) to terminalowy odtwarzacz muzyki w stylu retro inspirowany Winamp 2.x, wraz z wbudowanymi stacjami radiowymi z lo-fi beats. Uruchom go za pomocą `Super + Shift + Alt + M` albo z menu Omarchy w sekcji _Aplikacje_. Naciśnij `?`, aby zobaczyć pełną listę skrótów klawiszowych.

## A co z Wi-Fi i Bluetooth?

Nie znajdziesz TUI dla Wi-Fi i Bluetooth — tymi zadaniami zajmuje się powłoka Omarchy. Kliknij ikonę Wi-Fi na górnym pasku (albo naciśnij `Super + Ctrl + N`), aby zobaczyć sieci i się połączyć, oraz kliknij ikonę Bluetooth (albo naciśnij `Super + Ctrl + B`), aby sparować i połączyć urządzenia. Zobacz [sieć](35-networking.md), aby poznać całą historię.

## Dodawanie własnych

Każdy program terminalowy może zostać potraktowany jak pełnoprawna aplikacja. Przejdź do _Zainstaluj > TUI_ w menu Omarchy (`Super + Space`), nadaj mu nazwę, polecenie uruchamiania, styl okna i ikonę, a pojawi się w launcherze aplikacji jak każda inna aplikacja. Możesz go ponownie usunąć w sekcji _Usuń > TUI_.
