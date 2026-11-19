# Aplikacje graficzne

## Pliki

Files (Nautilus) to graficzny menedżer plików. `Super + Shift + F` otwiera go, a `Super + Shift + Alt + F` otwiera go w katalogu, w którym znajduje się twój terminal, co oszczędza mnóstwo klikania. `Ctrl + L` pozwala wpisać ścieżkę, a naciśnięcie `Space` na dowolnym pliku daje szybki podgląd bez otwierania czegokolwiek.

Podłącz pendrive USB lub kartę SD, a zostaną zamontowane automatycznie, więc po prostu pojawią się na pasku bocznym. Do bardziej zaawansowanych zadań — formatowania dysku, sprawdzania stanu SMART, tworzenia partycji — uruchom _Disks_ z programu uruchamiającego aplikacje (`Super + Space`).

Dwukrotne kliknięcie działa według rozsądnych ustawień domyślnych: zdjęcia, filmy i muzyka otwierają się w Omaview, pliki PDF w Document Viewer, Markdown w Omawrite, a zwykły tekst w edytorze wybranym w _Setup > Default > Editor_.

## Disktree

Gdy dysk się zapełnia i nie masz pojęcia, co go zjada, uruchom [Disktree](https://github.com/tobi/disktree) z programu uruchamiającego aplikacje (`Super + Space`). Pokazuje graficzną mapę drzewa twojego katalogu domowego. Większe bloki zajmują więcej miejsca; wchodź do katalogów za pomocą klawiatury lub myszy, zaznacz to, co ma zostać usunięte, i przejrzyj swoje wybory przed usunięciem czegokolwiek. Uruchom `disktree --disk`, aby przeskanować cały dysk.

## Obsidian

[Obsidian](https://obsidian.md/) to darmowa i wysoce rozszerzalna aplikacja do robienia notatek, która do przechowywania używa prostych plików Markdown.

Obsidian jest darmowy do wszystkich celów, w tym do użytku osobistego, komercyjnego i non-profit.

Obsidian oferuje również [komercyjny dodatek do synchronizacji](https://obsidian.md/sync) z aplikacjami mobilnymi na iOS i Android. (https://obsidian.md/pricing).

Obsidiana uruchomisz za pomocą `Super + Shift + O`. Aby korzystać z synchronizacji motywu, musisz wybrać motyw `Omarchy` w ustawieniach.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) to własna, banalnie prosta aplikacja Omarchy do pisania w Markdown. Żadnych skarbców, żadnych wtyczek, tylko ty i słowa.

Omawrite uruchomisz za pomocą `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) to podstawowe narzędzie do edycji obrazów, które świetnie nadaje się do przycinania, zmiany rozmiaru i innych podstawowych operacji. Tylko nie oczekuj alternatywy dla Photoshopa. Ale ma też Magic Wand i warstwy!

Pintę uruchomisz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) to aplikacja do tworzenia motywów, która potrafi wyodrębnić kolory z obrazu tła i zamienić je w kompletny, spójny motyw. To najłatwiejszy sposób, aby [stworzyć własny motyw](43-making-your-own-theme.md).

Aether uruchomisz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) pozwala wysyłać pliki do innych urządzeń w tej samej sieci, na których działa ta aplikacja, podobnie jak AirDrop od Apple. Jest jednak wieloplatformowy, więc możesz wysyłać pliki do i z Windows, macOS, Android, iOS i oczywiście Linux.

Menu Share możesz otworzyć za pomocą `Super + Ctrl + S` lub w menu Omarchy w _Trigger > Share_. Daje ci cztery opcje:

- **Clipboard** wysyła to, co skopiowałeś, jako plik tekstowy. Świetne, aby przesłać link lub fragment na telefon bez wysyłania sobie e-maila.
- **File** otwiera selektor plików, w którym możesz wybrać kilka naraz.
- **Folder** wysyła cały katalog.
- **Receive** otwiera właściwy LocalSend, aby inne urządzenie mogło wysłać coś do ciebie.

To samo działa z terminala za pomocą `omarchy share clipboard`, `omarchy share file [path]` i `omarchy share folder [path]`. Pomiń ścieżkę, a otrzymasz selektor.

Możesz także wysyłać bezpośrednio z menedżera plików: kliknij prawym przyciskiem myszy dowolne zaznaczenie w Nautilus i wybierz _Send via LocalSend_.

Zapora sieciowa Omarchy jest domyślnie zamknięta, z wyjątkiem portu LocalSend, więc działa to od razu po świeżej instalacji. Zobacz [bezpieczeństwo](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) to kompletny pakiet biurowy z procesorem tekstu, arkuszem kalkulacyjnym, prezentacjami, aplikacją do rysowania i nie tylko. Jest zgodny z plikami z Microsoft Office, więc to świetny sposób, aby móc otwierać te dokumenty Word.

LibreOffice uruchomisz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) to własna, banalnie prosta aplikacja Omarchy do prezentacji. Twoja prezentacja to jeden plik Markdown wraz ze znajdującymi się obok niego obrazami i filmami: pisz każdy slajd pod podglądem na żywo, przeciągaj slajdy, aby ustawić ich kolejność, a następnie prezentuj na pełnym ekranie lub eksportuj do PDF i PowerPoint. Przejmuje nawet twój motyw Omarchy.

Hype uruchomisz za pomocą programu uruchamiającego aplikacje (`Super + Space`). Naciśnij `?` w aplikacji, aby zobaczyć wszystkie skróty.

## Signed

[Signed](https://github.com/omacom/signed) to własny, banalnie prosty sposób Omarchy na podpisywanie plików PDF i ich wypełnianie. Umieść zapisany podpis, tekst i dzisiejszą datę w dowolnym miejscu na stronie, a następnie zapisz podpisaną kopię obok oryginału. Zobacz [Wypełnianie plików PDF](27-filling-out-pdfs.md), aby dowiedzieć się, jak to zrobić.

Signed uruchomisz za pomocą programu uruchamiającego aplikacje (`Super + Space`) lub otworzysz nim plik PDF z menedżera plików.

## Game Vibes

Game Vibes, w programie uruchamiającym aplikacje (`Super + Space`), to miejsce, w którym mieszkają małe gry Omarchy: Checkmate, trójwymiarowa gra w szachy przeciwko znajomemu lub wbudowanemu przeciwnikowi; Cards, pasjans Klondike; oraz Neon Swarm, strzelanka arcade. Każda to pojedyncza strona internetowa, która podąża za twoim motywem. Wybierz jedną za pomocą strzałek i `Enter`, a do listy wrócisz za pomocą `Esc` z ekranu tytułowego gry lub `Q`, gdy jest wstrzymana. Otwiera się na pełnym ekranie: `Super + F` zamienia ją w okno, a `Super + W` ją zamyka.

Gry, które tworzysz z agentem, również pojawiają się tutaj: wybierz _Make something cool → Game_ w panelu agentów i opisz jedną lub wskaż grę, która już jest w Game Vibes, aby dalej nad nią pracować. Agent kopiuje ją do `~/Games/vibes`, gdzie należy do ciebie i możesz ją zmieniać, i otwiera ją po zakończeniu. Możesz samodzielnie wykonać tę kopię za pomocą `omarchy games vibes copy <game>`. Gra udostępniona przez kogoś innego instaluje się jak motyw: wybierz _Install > Gaming > Game Vibes_ i wklej jej adres git lub uruchom `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ usuwa ją ponownie, a _Update > Game Vibes Games_ pobiera nowe wersje. Gry ładują three.js z sieci, więc do uruchomienia potrzebują połączenia.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) to własny, banalnie prosty kalkulator Omarchy, który otwiera się w pływającym oknie.

Omacalc uruchomisz za pomocą `Super + Shift + Q` (lub klawisza kalkulatora, jeśli twoja klawiatura go ma).

## Signal

[Signal](https://signal.org/) to pionier szyfrowanej komunikacji E2E i świetna opcja komunikacyjna dla każdego, kto wolałby nie korzystać z jednego z wielkich konglomeratów technologicznych.

Signal uruchomisz za pomocą `Super + Shift + G`. Nie jest częścią instalacji podstawowej, więc gdy naciśniesz to po raz pierwszy, Omarchy zaoferuje zainstalowanie go za ciebie (jest również w menu Omarchy w _Install > Service_). 

## Omaview

[Omaview](https://github.com/omacom/omaview) to własny, banalnie prosty program Omarchy do przeglądania zdjęć i odtwarzania multimediów: jedno okno dla twoich zdjęć, filmów i muzyki. Otwórz zdjęcie, a klawisze strzałek będą przechodzić przez resztę jego folderu, `N` i `P` robią to dla wszystkiego, a `Ctrl + M` pokazuje cały folder jako siatkę. Pokazuje również zdjęcia HEIC, AVIF i JPEG XL i wznawia długie materiały od miejsca, w którym przerwałeś.

Naciśnij `F`, aby przejść do pełnego ekranu, `E`, aby edytować zdjęcie w Omasnap lub przyciąć film w Omacut, `Ctrl + P`, aby wydrukować zdjęcie, i `Delete`, aby przenieść plik do Kosza (`Ctrl + Z` przywraca go). Naciśnij `?` w aplikacji, aby zobaczyć wszystkie skróty.

Omaview uruchomisz jako _Media Viewer_ za pomocą programu uruchamiającego aplikacje (`Super + Space`) lub po prostu kliknij dwukrotnie zdjęcie, film lub piosenkę w menedżerze plików.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) to własny, banalnie prosty program Omarchy do przycinania wideo. Gdy potrzebujesz tylko odciąć początek i koniec klipu, przebija odpalanie pełnego edytora wideo.

Omacut uruchomisz za pomocą programu uruchamiającego aplikacje (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) to własny, banalnie prosty rejestrator kamery internetowej Omarchy. Wybierz kamerę i mikrofon raz, a następnie naciśnij `Space`, aby nagrywać, i ponownie, aby wstrzymać i wznowić to samo ujęcie. Zawsze nagrywa w najwyższej rozdzielczości twojej kamery, z miernikiem mikrofonu na żywo, dzięki czemu możesz sprawdzić poziomy przed rozpoczęciem.

Zatrzymaj ujęcie, a otworzy się od razu we wbudowanym edytorze. Kliknij dwukrotnie klip, aby go podzielić, przeciągnij uchwyty, aby przyciąć każdy fragment, i usuń części, których nie chcesz. Następnie zapisz go jako MP4. Twoje oryginalne nagranie jest przechowywane do momentu, aż je odrzucisz, więc zawsze możesz wrócić i przyciąć je inaczej.

Monologue uruchomisz za pomocą programu uruchamiającego aplikacje (`Super + Space`).
