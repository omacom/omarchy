# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) to fantastyczna alternatywa dla czegoś takiego jak aplikacja GitHub Desktop, a do tego działa w terminalu.

Możesz uruchomić go bezpośrednio, przechodząc do dowolnego katalogu zarządzanego przez git i wpisując `lazygit`. Możesz też uruchomić go w Neovim, gdzie startuje po naciśnięciu `Space G G`.

Między poszczególnymi panelami przeskakujesz klawiszem `Tab`. W panelu Files klawiszem `Space` zaznaczasz pliki do dodania do staging, a potem klawiszem `c` tworzysz nowy commit. Wszystkie dostępne polecenia zobaczysz po naciśnięciu `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) to piękny menedżer zasobów, który pokazuje zużycie pamięci, CPU, dysku i sieci. Wyświetla też listę wszystkich aktywnych procesów i pozwala nimi zarządzać.

Omarchy nazywa go Activity Monitor, a uruchomisz go z launchera aplikacji albo naciskając `Super + Shift + T`. Otwiera się jako pływające okno, które możesz przekształcić w okno kafelkowe kombinacją `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) to menedżer przestrzeni roboczej w terminalu, który daje Ci przestrzenie robocze, karty i panele oraz utrzymuje je wszystkie w trwałej sesji, od której możesz się odłączyć i wrócić do niej później.

Uruchomisz go (albo ponownie podepniesz się do istniejącej sesji) kombinacją `Super + Ctrl + Return`. Omarchy dostarcza konfigurację Herdr odzwierciedlającą jego konfigurację Tmux, więc klawisz prefiksu to tutaj również `Ctrl + Space`. Wszystkie skróty klawiszowe przejrzysz kombinacją `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) pokazuje informacje o systemie, takie jak wersja jądra, czas pracy, motyw, CPU, pamięć i wiele więcej. To następca popularnego narzędzia neofetch.

Omarchy umieściło to w menu Omarchy (`Super + Space`) pod nazwą _About_.

## Cliamp

[Cliamp](https://www.cliamp.stream/) to odtwarzacz muzyki w terminalu w stylu retro, inspirowany Winamp 2.x, z wbudowanymi stacjami radiowymi z bitami lo-fi. Uruchomisz go kombinacją `Super + Shift + Alt + M` albo z menu Omarchy w sekcji _Apps_. Naciśnij `?`, żeby zobaczyć pełną listę skrótów klawiszowych.

## A co z Wi-Fi i Bluetooth?

Nie znajdziesz TUI do Wi-Fi ani Bluetooth — te zadania należą do powłoki Omarchy. Kliknij ikonę Wi-Fi na górnym pasku (albo naciśnij `Super + Ctrl + N`), żeby zobaczyć sieci i się połączyć, oraz kliknij ikonę Bluetooth (albo naciśnij `Super + Ctrl + B`), żeby sparować i połączyć urządzenia. Całą historię znajdziesz w sekcji [sieć](35-networking.md).

## Dodawanie własnych

Każdy program terminalowy może zostać potraktowany jak pełnoprawna aplikacja. Przejdź do _Install > TUI_ w menu Omarchy (`Super + Space`), nadaj mu nazwę, polecenie uruchamiania, styl okna i ikonę, a pojawi się w launcherze aplikacji jak każda inna aplikacja. Możesz go ponownie usunąć w sekcji _Remove > TUI_.
