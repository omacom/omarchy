# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) jest zachwycającą alternatywą dla czegoś takiego jak aplikacja GitHub Desktop i działa wewnątrz terminala.

Możesz uruchomić go bezpośrednio, przechodząc do dowolnego katalogu zarządzanego przez git i uruchamiając `lazygit`. Możesz też uruchomić go wewnątrz Neovim, gdzie można go uruchomić za pomocą `Space G G`.

Przeskakujesz między różnymi panelami za pomocą `Tab`. W panelu Files wybierasz pliki do stagingu za pomocą `Space`, a następnie możesz utworzyć nowy commit za pomocą `c`. Możesz zobaczyć wszystkie dostępne polecenia za pomocą `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) jest pięknym menedżerem zasobów, który pokazuje użycie pamięci, CPU, dysku i sieci. Wyświetla również wszystkie aktywne procesy i pozwala nimi zarządzać.

Omarchy nazywa go Activity i uruchamiasz go, naciskając `Super + Ctrl + T`. Otwiera się jako pływające okno, które możesz kafelkować za pomocą `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) jest menedżerem przestrzeni roboczej terminala, który zapewnia obszary robocze, karty i panele oraz utrzymuje je wszystkie działające w trwałej sesji, z której możesz się odłączyć i wrócić później.

Uruchamiasz go (lub ponownie dołączasz do istniejącej sesji) za pomocą `Super + Ctrl + Return`. Omarchy dostarcza konfigurację Herdr, która odzwierciedla jego konfigurację Tmux, więc klawisz prefiksu to tutaj również `Ctrl + Space`. Możesz przeglądać wszystkie skróty klawiszowe za pomocą `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) pokazuje informacje o systemie, takie jak wersja jądra, czas pracy, motyw, CPU, pamięć i więcej. Jest następcą popularnego narzędzia neofetch.

Omarchy zapakował to jako _Informacje_ w menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) jest odtwarzaczem muzyki terminala w stylu retro inspirowanym Winamp 2.x, kompletnym z wbudowanymi stacjami radiowymi z lo-fi beats. Uruchom go za pomocą `Super + Shift + Alt + M` lub z menu Omarchy w _Aplikacje_. Naciśnij `?`, aby zobaczyć pełną listę skrótów klawiszowych.

## A co z Wi-Fi i Bluetooth?

Nie znajdziesz TUI dla Wi-Fi i Bluetooth — te zadania należą do powłoki Omarchy. Kliknij ikonę Wi-Fi na górnym pasku (lub naciśnij `Super + Ctrl + W`), aby zobaczyć sieci i połączyć się, oraz kliknij ikonę Bluetooth (lub naciśnij `Super + Ctrl + B`), aby parować i łączyć urządzenia. Zobacz [sieć](35-networking.md), aby poznać pełną historię.

## Dodawanie własnych

Każdy program terminala może otrzymać pełne traktowanie aplikacji. Przejdź do _Instaluj > TUI_ w menu Omarchy (`Super + Space`), nadaj mu nazwę, polecenie uruchamiania, styl okna i ikonę, a pojawi się w launcherze aplikacji jak każda inna aplikacja. Możesz usunąć go ponownie w _Usuń > TUI_.
