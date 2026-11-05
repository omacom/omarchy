# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) to zachwycająca alternatywa dla czegoś takiego jak aplikacja GitHub Desktop, a działa wewnątrz terminala.

Możesz uruchomić go bezpośrednio, przechodząc do dowolnego katalogu zarządzanego przez git i uruchamiając `lazygit`. Albo możesz uruchomić go wewnątrz Neovim, gdzie można go wystartować za pomocą `Space G G`.

Przeskakujesz między różnymi panelami za pomocą `Tab`. W panelu Files wybierasz pliki do stagingu za pomocą `Space`, a następnie możesz utworzyć nowy commit za pomocą `c`. Wszystkie dostępne polecenia możesz zobaczyć za pomocą `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) to piękny menedżer zasobów, który pokazuje użycie pamięci, CPU, dysku i sieci. Wyświetla też wszystkie aktywne procesy i pozwala nimi zarządzać.

Omarchy nazywa go Activity, a uruchamiasz go, naciskając `Super + Shift + T`. Otwiera się jako pływające okno, które możesz dokować za pomocą `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) to terminalowy menedżer przestrzeni roboczych, który daje ci przestrzenie robocze, karty i panele, a wszystkie trzyma uruchomione w trwałej sesji, od której możesz się odłączyć i do której możesz wrócić później.

Uruchamiasz go (albo ponownie podłączasz się do istniejącej sesji) za pomocą `Super + Ctrl + Return`. Omarchy dostarcza konfigurację Herdr, która odzwierciedla jego konfigurację Tmux, więc tutaj klawisz prefix to również `Ctrl + Space`. Wszystkie przypisania klawiszy możesz przeglądać za pomocą `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) pokazuje informacje o systemie, takie jak wersja kernela, czas działania, motyw, CPU, pamięć i nie tylko. To następca popularnego narzędzia neofetch.

Omarchy spakowało to jako _About_ w menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) to retro terminalowy odtwarzacz muzyki inspirowany Winamp 2.x, z wbudowanymi stacjami radiowymi z lo-fi beats. Uruchom go za pomocą `Super + Shift + Alt + M` albo z menu Omarchy w sekcji _Apps_. Naciśnij `?`, aby zobaczyć pełną listę przypisań klawiszy.

## Co z Wi-Fi i Bluetooth?

Nie znajdziesz TUI do Wi-Fi i Bluetooth — te zadania należą do powłoki Omarchy. Kliknij ikonę Wi-Fi na górnym pasku (albo naciśnij `Super + Ctrl + N`), aby zobaczyć sieci i się połaczyć, i kliknij ikonę Bluetooth (albo naciśnij `Super + Ctrl + B`), aby parować i łączyć urządzenia. Zobacz [sieć](35-networking.md), aby poznać pełną historię.

## Dodawanie własnych

Każdy program terminalowy może dostać pełne traktowanie aplikacji. Przejdź do _Install > TUI_ w menu Omarchy (`Super + Space`), nadaj mu nazwę, polecenie uruchamiania, styl okna i ikonę, a pojawi się w launcherze aplikacji jak każda inna aplikacja. Możesz go ponownie usunąć w sekcji _Remove > TUI_.
