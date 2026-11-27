# Aplikacje graficzne

## Pliki

Files (Folio) to graficzny menedżer plików. `Super + Shift + F` go otwiera, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się Twój terminal, co oszczędza sporo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku pokazuje jego podgląd w pełnym rozmiarze bez otwierania go.

Podłącz pamięć USB lub kartę SD, a zostanie zamontowana automatycznie, więc po prostu pojawi się na pasku bocznym. Do bardziej zaawansowanych zadań — formatowania dysku, sprawdzania stanu SMART, tworzenia partycji — uruchom _Disks_ z programu uruchamiającego aplikacje (`Super + Space`).

Zaszyfrowany dysk poprosi o hasło po podłączeniu. Aby odblokowywał się sam, dodaj do niego plik klucza poleceniem `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` i umieść ten plik klucza w `~/.config/omarchy/drive-keys/<UUID>`, nazywając go identyfikatorem UUID, który `lsblk -dno UUID /dev/sdX1` wypisuje dla zaszyfrowanej partycji, i z dostępem wyłącznie dla Ciebie (`chmod 600`). Jeśli tego pliku klucza brakuje lub zostanie odrzucony, system poprosi Cię o hasło jak zwykle.

Dwukrotne kliknięcie kieruje się rozsądnymi ustawieniami domyślnymi: zdjęcia, filmy i muzyka otwierają się w Omaview, pliki PDF w Document Viewer, Markdown w Omawrite, a zwykły tekst w Twoim edytorze, Plain, chyba że wybierzesz inny w _Setup > Defaults > Editor_.

## Disktree

Kiedy dysk się zapełni i nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z programu uruchamiającego aplikacje (`Super + Space`). Pokazuje graficzną mapę drzewa Twojego katalogu domowego. Większe bloki zajmują więcej miejsca; wchodź do katalogów za pomocą klawiatury lub myszy, zaznaczaj, co ma zostać usunięte, i przeglądaj wybrane elementy przed usunięciem czegokolwiek. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która do przechowywania używa prostych plików Markdown.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje też [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Obsidian uruchamiasz skrótem `Super + Shift + O`. Aby korzystać z synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, szalenie prosta aplikacja Omarchy do pisania w Markdown. Żadnych skarbców, żadnych wtyczek, tylko Ty i słowa.

Omawrite uruchamiasz skrótem `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, świetne do przycinania, zmiany rozmiaru i innych podstawowych operacji. Tylko nie oczekuj alternatywy dla Photoshopa. Ale i tak ma Magic Wand i warstwy!

Pintę uruchamiasz przez program uruchamiający aplikacje (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do tworzenia motywów, która potrafi wyodrębnić kolory z obrazu tła i zamienić je w kompletny, spójny motyw. To najłatwiejszy sposób, aby [stworzyć własny motyw](43-making-your-own-theme.md).

Aether uruchamiasz przez program uruchamiający aplikacje (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa ta aplikacja, podobnie jak AirDrop firmy Apple. Jest jednak wieloplatformowy, więc możesz wysyłać pliki do i z Windows, macOS, Android, iOS i oczywiście Linux.

Menu udostępniania możesz otworzyć skrótem `Super + Ctrl + S` lub w menu Omarchy, w _Trigger > Share_. Daje Ci cztery opcje:

- **Clipboard** wysyła wszystko, co skopiowałeś, jako plik tekstowy. Świetne, aby przenieść link lub fragment tekstu na telefon bez wysyłania sobie e-maila.
- **File** otwiera selektor plików, w którym możesz wybrać kilka plików naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło wysłać coś do Ciebie.

To samo działa z terminala poleceniami `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a pojawi się selektor.

Możesz też wysyłać bezpośrednio z menedżera plików: kliknij prawym przyciskiem myszy dowolny wybór w Files i udostępnij go przez LocalSend.

Zapora sieciowa Omarchy jest domyślnie zamknięta, z wyjątkiem portu LocalSend, więc na świeżej instalacji działa to od razu po wyjęciu z pudełka. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z edytorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest zgodny z plikami z Microsoft Office, więc to świetny sposób, aby móc otwierać te dokumenty Worda.

LibreOffice uruchamiasz przez program uruchamiający aplikacje (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, szalenie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to pojedynczy plik Markdown z obrazami i filmami obok niego: piszesz każdy slajd pod podglądem na żywo, przeciągasz slajdy, aby ustawić ich kolejność, a potem prezentujesz na pełnym ekranie lub eksportujesz do PDF i PowerPoint. Przejmuje nawet Twój motyw Omarchy.

Hype uruchamiasz przez program uruchamiający aplikacje (`Super + Space`). Naciśnij `?` w aplikacji, aby zobaczyć wszystkie skróty.

## Signed

[Signed](https://github.com/omacom/signed) to własny, szalenie prosty sposób Omarchy na podpisywanie plików PDF i wypełnianie ich. Umieść zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu strony, a potem zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się jak.

Signed uruchamiasz przez program uruchamiający aplikacje (`Super + Space`) albo otwierasz w nim plik PDF z menedżera plików.

## Game Vibes

Game Vibes, w programie uruchamiającym aplikacje (`Super + Space`), to miejsce, w którym mieszkają małe gry Omarchy: Checkmate, trójwymiarowa gra w szachy przeciwko znajomemu lub wbudowanemu przeciwnikowi; Cards, pasjans Klondike; Death Wish, precyzyjna co do piksela platformówka składająca się z dziesięciu pokoi pełnych kolców i pił; oraz Neon Swarm, zręcznościowa strzelanka. Każda z nich to pojedyncza strona internetowa, która podąża za Twoim motywem. Wybierz jedną strzałkami i klawiszem `Enter`, a wróć do listy klawiszem `Esc` z ekranu tytułowego gry lub klawiszem `Q`, gdy gra jest wstrzymana. Otwiera się na pełnym ekranie: `Super + F` zamienia ją w okno, a `Super + W` ją zamyka.

Gry, które tworzysz z agentem, też się tu pojawiają: wybierz _Make something cool → Game_ w panelu agentów i opisz grę albo wskaż grę już znajdującą się w Game Vibes, aby kontynuować pracę nad nią. Agent kopiuje ją do `~/Games/vibes`, gdzie należy do Ciebie i możesz ją zmieniać, i otwiera ją, gdy skończy. Możesz samodzielnie wykonać tę kopię poleceniem `omarchy games vibes copy <game>`. Gra udostępniona przez kogoś innego instaluje się jak motyw: wybierz _Install > Gaming > Game Vibes_ i wklej jej adres git albo uruchom `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ usuwa grę, a _Update > Game Vibes Games_ pobiera nowe wersje. Gry wczytują three.js z sieci, więc do uruchomienia potrzebują połączenia.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, szalenie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Omacalc uruchamiasz skrótem `Super + Shift + Q` (lub klawiszem kalkulatora, jeśli Twoja klawiatura taki ma).

## Signal

[Signal](https://signal.org/) to pionier szyfrowanej komunikacji E2E i świetna opcja komunikacyjna dla każdego, kto wolałby nie korzystać z jednego z wielkich konglomeratów technologicznych.

Signal uruchamiasz skrótem `Super + Shift + G`. Nie jest częścią instalacji podstawowej, więc za pierwszym razem, gdy naciśniesz ten skrót, Omarchy zaproponuje zainstalowanie go dla Ciebie (jest też dostępny w menu Omarchy, w _Install > Service_).

## Omaview

[Omaview](https://github.com/omacom/omaview) to własna, szalenie prosta przeglądarka zdjęć i odtwarzacz multimediów Omarchy: jedno okno dla Twoich zdjęć, filmów i muzyki. Otwórz zdjęcie, a klawisze strzałek przewijają pozostałe zdjęcia z jego folderu, `N` i `P` robią to samo dla wszystkiego, a `Ctrl + M` pokazuje cały folder jako siatkę. Wyświetla też zdjęcia HEIC, AVIF i JPEG XL oraz wznawia odtwarzanie wszystkiego, co długie, w miejscu, w którym je przerwałeś.

Naciśnij `F`, aby włączyć pełny ekran, `E`, aby edytować zdjęcie w Omasnap lub przyciąć film w Omacut, `Ctrl + P`, aby wydrukować zdjęcie, i `Delete`, aby przenieść plik do kosza (`Ctrl + Z` go przywraca). Naciśnij `?` w aplikacji, aby zobaczyć wszystkie skróty.

Omaview uruchamiasz jako _Media Viewer_ przez program uruchamiający aplikacje (`Super + Space`) albo po prostu klikasz dwukrotnie zdjęcie, film lub utwór w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własny, szalenie prosty przycinacz filmów Omarchy. Kiedy potrzebujesz tylko odciąć początek i koniec klipu, przebija odpalanie pełnego edytora wideo.

Omacut uruchamiasz przez program uruchamiający aplikacje (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własny, szalenie prosty rejestrator kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a potem naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo nagranie. Zawsze nagrywa w najwyższej rozdzielczości Twojej kamery, z miernikiem poziomu mikrofonu na żywo, abyś mógł sprawdzić poziomy przed rozpoczęciem.

Zatrzymaj nagranie, a otworzy się od razu we wbudowanym edytorze. Kliknij dwukrotnie klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń części, których nie chcesz. Następnie zapisz go jako MP4. Oryginalne nagranie jest przechowywane, dopóki go nie odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Monologue uruchamiasz przez program uruchamiający aplikacje (`Super + Space`).
